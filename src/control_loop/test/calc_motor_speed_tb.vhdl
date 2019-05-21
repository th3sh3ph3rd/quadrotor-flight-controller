library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pid_types.all;

entity calc_motor_speed_tb is
end entity calc_motor_speed_tb;

architecture tb of calc_motor_speed_tb is

    constant SYS_CLK_FREQ   : integer := 50000000;
    constant SYS_CLK_PERIOD : time := 20 ns;

    signal clk, res_n : std_logic;

    signal new_thrust, new_speed : std_logic;
    signal t_roll, t_pitch, t_yaw : pid_t;

    component calc_motor_speed is
        generic
        (
            THRUST_Z : pid_t 
        ); 
        port
        (
            -- global synchronization
            clk         : in std_logic;
            res_n       : in std_logic;

            -- angular thrust
            new_thrust  : in std_logic;
            t_roll      : in pid_t;
            t_pitch     : in pid_t;
            t_yaw       : in pid_t;

            -- motor speeds
            new_speed   : out std_logic;
            s_m0        : out pid_t;
            s_m1        : out pid_t;
            s_m2        : out pid_t;
            s_m3        : out pid_t
        );
    end component calc_motor_speed;

begin

    UUT : calc_motor_speed
    generic map
    (
        THRUST_Z => X"0000"
    )
    port map
    (
       clk => clk,
       res_n => res_n,
       new_thrust => new_thrust,
       t_roll => t_roll,
       t_pitch => t_pitch,
       t_yaw => t_yaw,
       new_speed => new_speed,
       s_m0 => open,
       s_m1 => open,
       s_m2 => open,
       s_m3 => open
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
        new_thrust <= '0';
        t_roll <= (others => '0');
        t_pitch <= (others => '0');
        t_yaw <= (others => '0');
        wait for SYS_CLK_PERIOD;
        res_n <= '1';
        wait for SYS_CLK_PERIOD;

        -- test rest position 
        new_thrust <= '1';
        wait for SYS_CLK_PERIOD;
        new_thrust <= '0';
        wait until new_speed = '1';
        wait for SYS_CLK_PERIOD;

        -- test roll
        new_thrust <= '1';
        t_roll <= to_signed(28800, 16);
        wait for SYS_CLK_PERIOD;
        new_thrust <= '0';
        wait until new_speed = '1';
        wait for SYS_CLK_PERIOD;
        new_thrust <= '1';
        t_roll <= to_signed(-28800, 16);
        wait for SYS_CLK_PERIOD;
        new_thrust <= '0';
        t_roll <= (others => '0');
        wait until new_speed = '1';
        wait for SYS_CLK_PERIOD;

        -- test pitch
        new_thrust <= '1';
        t_pitch <= to_signed(28800, 16);
        wait for SYS_CLK_PERIOD;
        new_thrust <= '0';
        wait until new_speed = '1'; 
        wait for SYS_CLK_PERIOD;
        new_thrust <= '1';
        t_pitch <= to_signed(-28800, 16);
        wait for SYS_CLK_PERIOD;
        new_thrust <= '0';
        t_pitch <= (others => '0');
        wait until new_speed = '1';
        wait for SYS_CLK_PERIOD;
        
        -- test yaw
        new_thrust <= '1';
        t_yaw <= to_signed(28800, 16);
        wait for SYS_CLK_PERIOD;
        new_thrust <= '0';
        wait until new_speed = '1'; 
        wait for SYS_CLK_PERIOD;
        new_thrust <= '1';
        t_yaw <= to_signed(-28800, 16);
        wait for SYS_CLK_PERIOD;
        new_thrust <= '0';
        t_yaw <= (others => '0');
        wait until new_speed = '1';
        wait for SYS_CLK_PERIOD;
       
        -- test multi 1
        new_thrust <= '1';
        t_roll <= to_signed(10000, 16);
        t_pitch <= to_signed(-5000, 16);
        wait for SYS_CLK_PERIOD;
        new_thrust <= '0';
        t_pitch <= (others => '0');
        t_roll <= (others => '0');
        wait until new_speed = '1'; 
        wait for SYS_CLK_PERIOD;
        
        -- test multi 2
        new_thrust <= '1';
        t_roll <= to_signed(-10000, 16);
        t_pitch <= to_signed(7000, 16);
        t_yaw <= to_signed(28800, 16);
        wait for SYS_CLK_PERIOD;
        new_thrust <= '0';
        t_roll <= (others => '0');
        t_pitch <= (others => '0');
        t_yaw <= (others => '0');
        wait until new_speed = '1'; 
        wait for SYS_CLK_PERIOD;

        wait;
    end process stimulus;

end architecture tb;


