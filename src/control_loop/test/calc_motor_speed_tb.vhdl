library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.fp_pkg.all;
use work.motor_pwm_pkg.all;

entity calc_motor_speed_tb is
end entity calc_motor_speed_tb;

architecture tb of calc_motor_speed_tb is

    constant SYS_CLK_FREQ   : integer := 50000000;
    constant SYS_CLK_PERIOD : time := 20 ns;

    signal clk, res_n : std_logic;

    signal new_thrust, new_speed : std_logic;
    signal t_roll, t_pitch, t_yaw : FP_T;

    component calc_motor_speed is
        generic
        (
            THRUST_Z : motor_rpm 
        ); 
        port
        (
            -- global synchronization
            clk         : in std_logic;
            res_n       : in std_logic;

            -- angular thrust
            new_thrust  : in std_logic;
            roll        : in FP_T;
            pitch       : in FP_T;
            yaw         : in FP_T;

            -- motor speed values
            speed_rdy   : out std_logic;
            m0          : out motor_rpm;
            m1          : out motor_rpm;
            m2          : out motor_rpm;
            m3          : out motor_rpm
        );
    end component calc_motor_speed;

begin

    UUT : calc_motor_speed
    generic map
    (
        THRUST_Z => X"9AE2"
    )
    port map
    (
       clk => clk,
       res_n => res_n,
       new_thrust => new_thrust,
       roll => t_roll,
       pitch => t_pitch,
       yaw => t_yaw,
       speed_rdy => new_speed,
       m0 => open,
       m1 => open,
       m2 => open,
       m3 => open
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
        t_roll <= int2fp(28800);
        wait for SYS_CLK_PERIOD;
        new_thrust <= '0';
        wait until new_speed = '1';
        wait for SYS_CLK_PERIOD;
        new_thrust <= '1';
        t_roll <= int2fp(-28800);
        wait for SYS_CLK_PERIOD;
        new_thrust <= '0';
        t_roll <= (others => '0');
        wait until new_speed = '1';
        wait for SYS_CLK_PERIOD;

        -- test pitch
        new_thrust <= '1';
        t_pitch <= int2fp(28800);
        wait for SYS_CLK_PERIOD;
        new_thrust <= '0';
        wait until new_speed = '1'; 
        wait for SYS_CLK_PERIOD;
        new_thrust <= '1';
        t_pitch <= int2fp(-28800);
        wait for SYS_CLK_PERIOD;
        new_thrust <= '0';
        t_pitch <= (others => '0');
        wait until new_speed = '1';
        wait for SYS_CLK_PERIOD;
        
        -- test yaw
        new_thrust <= '1';
        t_yaw <= int2fp(28800);
        wait for SYS_CLK_PERIOD;
        new_thrust <= '0';
        wait until new_speed = '1'; 
        wait for SYS_CLK_PERIOD;
        new_thrust <= '1';
        t_yaw <= int2fp(-28800);
        wait for SYS_CLK_PERIOD;
        new_thrust <= '0';
        t_yaw <= (others => '0');
        wait until new_speed = '1';
        wait for SYS_CLK_PERIOD;
       
        -- test multi 1
        new_thrust <= '1';
        t_roll <= int2fp(10000);
        t_pitch <= int2fp(-5000);
        wait for SYS_CLK_PERIOD;
        new_thrust <= '0';
        t_pitch <= (others => '0');
        t_roll <= (others => '0');
        wait until new_speed = '1'; 
        wait for SYS_CLK_PERIOD;
        
        -- test multi 2
        new_thrust <= '1';
        t_roll <= int2fp(-10000);
        t_pitch <= int2fp(7000);
        t_yaw <= int2fp(28800);
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


