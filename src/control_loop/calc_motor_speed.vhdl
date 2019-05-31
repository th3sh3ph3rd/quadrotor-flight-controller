--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 21.05.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pid_types.all;
use work.control_loop_pkg.all;

entity calc_motor_speed is

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

            -- motor speed values
            new_speed   : out std_logic;
            s_m0        : out motor_rpm;
            s_m1        : out motor_rpm;
            s_m2        : out motor_rpm;
            s_m3        : out motor_rpm
        );

end entity calc_motor_speed;

architecture behavior of calc_motor_speed is

    signal new_s, new_s_next : std_logic;

    type speeds is record
        m0 : pid_t;
        m1 : pid_t;
        m2 : pid_t;
        m3 : pid_t;    
    end record;
    signal speed, speed_next : speeds;

begin
    
    sync : process(all)
    begin
        if res_n = '0' then
            new_s    <= '0';
            speed.m0 <= (others => '0');
            speed.m1 <= (others => '0');
            speed.m2 <= (others => '0');
            speed.m3 <= (others => '0');
        elsif rising_edge(clk) then
            new_s <= new_s_next;
            speed <= speed_next; 
        end if;
    end process sync;
    
    output : process(all)
    begin
        s_m0 <= std_logic_vector(speed.m0);
        s_m1 <= std_logic_vector(speed.m1);
        s_m2 <= std_logic_vector(speed.m2);
        s_m3 <= std_logic_vector(speed.m3);
        new_speed <= new_s;
        
        new_s_next <= '0';
        speed_next <= speed;

        if new_thrust = '1' then
            new_s_next    <= '1';
            -- remove fixed point shift
            -- TODO make shift generic and define zero vector with appropriate length
            speed_next.m0 <= THRUST_Z - ("0000" & t_roll(15 downto 4)) + ("0000" & t_pitch(15 downto 4)) + ("0000" & t_yaw(15 downto 4));
            speed_next.m1 <= THRUST_Z - ("0000" & t_roll(15 downto 4)) - ("0000" & t_pitch(15 downto 4)) - ("0000" & t_yaw(15 downto 4));
            speed_next.m2 <= THRUST_Z + ("0000" & t_roll(15 downto 4)) - ("0000" & t_pitch(15 downto 4)) + ("0000" & t_yaw(15 downto 4));
            speed_next.m3 <= THRUST_Z + ("0000" & t_roll(15 downto 4)) + ("0000" & t_pitch(15 downto 4)) - ("0000" & t_yaw(15 downto 4));
        end if;
    end process output;

end architecture behavior;

