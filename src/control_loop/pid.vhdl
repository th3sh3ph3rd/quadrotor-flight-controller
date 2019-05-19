--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 17.05.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pid_types.all;

entity pid is

        -- TODO add integral and control output saturation
        generic
        (
            gain_p : pid_gain, 
            gain_i : pid_gain, 
            gain_d : pid_gain 
        ); 
        port
        (
            -- global synchronization
            clk         : in std_logic;
            res_n       : in std_logic;

            -- setpoint
            new_sp      : in std_logic;
            setpoint    : in pid_t;
            
            -- current state
            new_state   : in std_logic;
            state       : in pid_t;
            
            -- control output
            pid_rdy     : out std_logic;
            pid         : out pid_t;
        );

end entity pid;

architecture beh of pid is

    -- fsm state
    type state_type is (IDLE, CALC_TERMS, ADD_TERMS, DONE);
    signal state, state_next : state_type;
 
    signal sp, sp_next              : pid_t;
    signal err, err_next            : pid_t;
    signal err_prev, err_prev_next  : pid_t;

    type pid_terms is record
        p   : pid_t;
        i   : pid_t;
        d   : pid_t;
        pid : pid_t;    
    end record;
    signal terms, terms_next : pid_terms;

begin
    
    sync : process(all)
    begin
        if res_n = '0' then
            state    <= IDLE;
            sp       <= (others => '0');
            err      <= (others => '0');
            err_prev <= (others => '0');
            terms    <= (others => '0', others => '0', others => '0', others => '0');
        elsif rising_edge(clk) then
            state    <= state_next;
            sp       <= sp_next;
            err      <= err_next;
            err_prev <= err_prev_next;
            terms    <= terms_next;
        end if;
    end process sync;
    
    next_state : process(all)
    begin
        state_next <= state;

        case state is
            when IDLE =>
                if new_state = '1' then
                    state_next <= CALC_TERMS;
                end if;

            when CALC_TERMS =>
                state_next <= ADD_TERMS;

            when ADD_TERMS =>
                state_next <= DONE;

            when DONE =>
                state_next <= IDLE;

        end case;
    end process next_state;
    
    output : process(all)
    begin
        pid_rdy <= '0';
        pid     <= (others => '0');

        if new_sp = '1' then
            sp_next <= setpoint;
        else
            sp_next <= sp;
        end if;

        err_next      <= err;
        err_prev_next <= err_prev;
        terms_next    <= terms;

        case state is
            when IDLE =>
                if new_state = '1' then
                    err_next <= sp - state;
                    err_prev_next <= err;
                end if;

            when CALC_TERMS =>
                terms_next.p <= gain_p * err;
                terms_next.i <= gain_i * err + terms.i;
                terms_next.d <= gain_d * (err - err_prev);

            when ADD_TERMS =>
                terms_next.pid <= terms.p + terms.i + terms.d;

            when DONE =>
                pid_rdy <= '1';
                pid     <= terms.pid;

        end case;
    end process output;

end architecture beh;

