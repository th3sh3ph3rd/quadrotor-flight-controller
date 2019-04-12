--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 12.04.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.control_loop_pkg.all;

entity control_loop is

        port
        (
            -- global synchronization
            clk         : in std_logic;
            res_n       : in std_logic;

            -- state set values
            roll_set    : in imu_angle;
            pitch_set   : in imu_angle;
            yaw_set     : in imu_angle;
            
            -- state is values
            roll_is     : in imu_angle;
            pitch_is    : in imu_angle;
            yaw_is      : in imu_angle;

            -- motor rpm values
            m0_rpm      : out motor_rmp;
            m1_rpm      : out motor_rmp;
            m2_rpm      : out motor_rmp;
            m3_rpm      : out motor_rmp 
        );

end entity control_loop;

architecture beh of control_loop is

begin

end architecture beh;

