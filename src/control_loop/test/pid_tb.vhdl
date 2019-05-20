library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pid_types.all;

entity pid_tb is
end entity pid_tb;

architecture tb of pid_tb is

    constant SYS_CLK_FREQ   : integer := 50000000;
    constant SYS_CLK_PERIOD : time := 20 ns;

    signal clk, res_n : std_logic;

    signal new_sp, new_state, pid_rdy : std_logic;
    signal setpoint, proc_state : pid_t;

    component pid is
        generic
        (
            GAIN_P : pid_gain; 
            GAIN_I : pid_gain; 
            GAIN_D : pid_gain 
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
            proc_state  : in pid_t;
            
            -- control output
            pid_rdy     : out std_logic;
            pid         : out pid_t
        );
    end component pid;

begin

    UUT : pid
    generic map
    (
        GAIN_P => X"0006",
        GAIN_I => X"0002",
        GAIN_D => X"0002"
    )
    port map
    (
       clk => clk,
       res_n => res_n,
       new_sp => new_sp,
       setpoint => setpoint,
       new_state => new_state,
       proc_state => proc_state,
       pid_rdy => pid_rdy,
       pid => open
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
        setpoint <= to_signed(180*16, 16);
        wait for SYS_CLK_PERIOD;
        new_sp <= '0';

        new_state <= '1';
        proc_state <= to_signed(0, 16);
        wait for SYS_CLK_PERIOD;
        new_state <= '0';
        wait until pid_rdy = '1';
        wait for SYS_CLK_PERIOD;

        new_state <= '1';
        proc_state <= to_signed(-180*16, 16);
        wait for SYS_CLK_PERIOD;
        new_state <= '0';
        wait until pid_rdy = '1';
        wait for SYS_CLK_PERIOD;

        wait;
    end process stimulus;

end architecture tb;

