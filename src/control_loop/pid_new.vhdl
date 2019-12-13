--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 17.05.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.fp_pkg.all;

entity pid is

        -- TODO add integral saturation
        generic
        (
            A0 : FP_T; 
            A1 : FP_T; 
            A2 : FP_T 
        ); 
        port
        (
            -- global synchronization
            clk         : in std_logic;
            res_n       : in std_logic;

            -- setpoint
            new_sp      : in std_logic;
            setpoint    : in FP_T;
            
            -- current process state
            new_state   : in std_logic;
            adc         : in FP_T;
            
            -- control output
            pid_rdy     : out std_logic;
            dac         : out FP_T
        );

end entity pid;

architecture behavior of pid is

    -- fsm state
    type STATE_T is (IDLE, CALC_ERR, CALC_TERMS, ADD_TERMS, DONE);

    type REGISTER_T is record
        state       : STATE_T;
        sp          : FP_T;
        adc         : FP_T;
        err         : FP_T;
        err1        : FP_T;
        err2        : FP_T;
        t0          : FP_MULRES_T;
        t1          : FP_MULRES_T;
        t2          : FP_MULRES_T;
        dac         : FP_T;
    end record;
    signal R, R_next : REGISTER_T;

    constant R_reset : REGISTER_T :=
    (
        state       => IDLE,
        sp          => (others => '0'),
        adc         => (others => '0'),
        err         => (others => '0'),
        err1        => (others => '0'),
        err2        => (others => '0'),
        t0          => (others => '0'),
        t1          => (others => '0'),
        t2          => (others => '0'),
        dac         => (others => '0') 
    );

begin
    
    sync : process(all)
    begin
        if res_n = '0' then
            R <= R_reset;
        elsif rising_edge(clk) then
            R <= R_next;
        end if;
    end process sync;
     
    async : process(all)

        variable S : REGISTER_T;

    begin

        --output
        pid_rdy <= '0';
        dac     <= R.dac;

        S := R;

        if new_sp = '1' then
            S.sp := setpoint;
        end if;

        case R.state is
            when IDLE =>
                if new_state = '1' then
                    S.adc   := adc;
                    S.state := CALC_ERR;
                end if;

            when CALC_ERR =>
                S.err   := R.sp - R.adc;
                S.err1  := R.err; 
                S.err2  := R.err1;
                S.state := CALC_TERMS;

            when CALC_TERMS =>
                S.t0    := A0 * R.err;
                S.t1    := A1 * R.err1;
                S.t2    := A2 * R.err2;
                S.state := ADD_TERMS;

            when ADD_TERMS => --extract fixed point value from multiplication result and add values
                S.dac   := R.dac +
                           fp_mulres2fp(R.t0) + 
                           fp_mulres2fp(R.t1) + 
                           fp_mulres2fp(R.t2);
                S.state := DONE;

            when DONE =>
                pid_rdy <= '1';
                S.state := IDLE;

        end case;
        
        R_next  <= S;

    end process async;

end architecture behavior;

