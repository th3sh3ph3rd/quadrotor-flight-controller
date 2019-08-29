--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 21.05.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pid_types.all;
use work.motor_pwm_pkg.all;
use work.control_loop_pkg.all;

entity calc_motor_speed is

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
            t_roll      : in pid_out;
            t_pitch     : in pid_out;
            t_yaw       : in pid_out;

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
        m0 : motor_rpm;
        m1 : motor_rpm;
        m2 : motor_rpm;
        m3 : motor_rpm;    
    end record;
    signal speed, speed_next : speeds;
    signal t_roll_s, t_pitch_s, t_yaw_s : unsigned(MOTOR_RPM_WIDTH-1 downto 0);

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
--            speed_next.m0 <= THRUST_Z - ("0000" & t_roll(15 downto 4)) + ("0000" & t_pitch(15 downto 4)) + ("0000" & t_yaw(15 downto 4));
--            speed_next.m1 <= THRUST_Z - ("0000" & t_roll(15 downto 4)) - ("0000" & t_pitch(15 downto 4)) - ("0000" & t_yaw(15 downto 4));
--            speed_next.m2 <= THRUST_Z + ("0000" & t_roll(15 downto 4)) - ("0000" & t_pitch(15 downto 4)) + ("0000" & t_yaw(15 downto 4));
--            speed_next.m3 <= THRUST_Z + ("0000" & t_roll(15 downto 4)) + ("0000" & t_pitch(15 downto 4)) - ("0000" & t_yaw(15 downto 4));
            t_roll_s <= unsigned(t_roll((MOTOR_RPM_WIDTH+FIXED_POINT_SHIFT-1) downto FIXED_POINT_SHIFT));
            t_pitch_s <= unsigned(t_pitch((MOTOR_RPM_WIDTH+FIXED_POINT_SHIFT-1) downto FIXED_POINT_SHIFT));
            t_yaw_s <= unsigned(t_yaw((MOTOR_RPM_WIDTH+FIXED_POINT_SHIFT-1) downto FIXED_POINT_SHIFT));
            speed_next.m0 <= std_logic_vector(unsigned(THRUST_Z) - t_roll_s + t_pitch_s + t_yaw_s);
            speed_next.m1 <= std_logic_vector(unsigned(THRUST_Z) - t_roll_s - t_pitch_s - t_yaw_s);
            speed_next.m2 <= std_logic_vector(unsigned(THRUST_Z) + t_roll_s - t_pitch_s + t_yaw_s);
            speed_next.m3 <= std_logic_vector(unsigned(THRUST_Z) + t_roll_s + t_pitch_s - t_yaw_s);
        end if;
    end process output;

end architecture behavior;

