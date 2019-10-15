library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.fp_pkg.all;

entity pid_tb is
end entity pid_tb;

architecture tb of pid_tb is

    constant SYS_CLK_FREQ   : integer := 50000000;
    constant SYS_CLK_PERIOD : time := 20 ns;

    signal clk, res_n : std_logic;

    signal new_sp, new_state, pid_rdy : std_logic;
    signal setpoint, proc_state : FP_T;

    component pid is
        generic
        (
            GAIN_P : FP_T; 
            GAIN_I : FP_T; 
            GAIN_D : FP_T 
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
    end component pid;

begin

    UUT : pid
    generic map
    (
--        GAIN_P => int2fp(2),
--        GAIN_I => int2fp(3),
--        GAIN_D => int2fp(-5)
        GAIN_P => '0' & X"0027",
        GAIN_I => '0' & X"003f",
        GAIN_D => '1' & X"1153"
    )
    port map
    (
       clk => clk,
       res_n => res_n,
       new_sp => new_sp,
       setpoint => setpoint,
       new_state => new_state,
       adc => proc_state,
       pid_rdy => pid_rdy,
       dac => open
    );

    clk_gen : process
    begin
        clk <= '1';
        wait for SYS_CLK_PERIOD/2;
        clk <= '0';
        wait for SYS_CLK_PERIOD/2;
    end process clk_gen;

    stimulus : process
    begin
        res_n <= '0';
        new_sp <= '0';
        setpoint <= (others => '0');
        new_state <= '0';
        proc_state <= (others => '0');
        wait for SYS_CLK_PERIOD;
        res_n <= '1';
        wait for SYS_CLK_PERIOD;

        new_sp <= '1';
        setpoint <= int2fp(0);
        wait for SYS_CLK_PERIOD;
        new_sp <= '0';

        new_state <= '1';
        proc_state <= int2fp(0);
        wait for SYS_CLK_PERIOD;
        new_state <= '0';
        wait until pid_rdy = '1';
        wait for SYS_CLK_PERIOD;

        new_state <= '1';
        proc_state <= int2fp(-180);
        wait for SYS_CLK_PERIOD;
        new_state <= '0';
        wait until pid_rdy = '1';
        wait for SYS_CLK_PERIOD;
        
        new_state <= '1';
        proc_state <= int2fp(180);
        wait for SYS_CLK_PERIOD;
        new_state <= '0';
        wait until pid_rdy = '1';
        wait for SYS_CLK_PERIOD;

        wait;
    end process stimulus;

end architecture tb;

