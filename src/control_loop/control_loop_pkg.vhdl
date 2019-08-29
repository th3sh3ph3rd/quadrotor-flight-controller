--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 12.04.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--TODO maybe use only the subtype
use work.pid_types.all;
use work.imu_pkg.all;
use work.motor_pwm_pkg.all;

package control_loop_pkg is

    component control_loop is

        generic
        (
            GAIN_P_ROLL  : pid_gain; 
            GAIN_I_ROLL  : pid_gain; 
            GAIN_D_ROLL  : pid_gain; 
            GAIN_P_PITCH : pid_gain; 
            GAIN_I_PITCH : pid_gain; 
            GAIN_D_PITCH : pid_gain; 
            GAIN_P_YAW   : pid_gain; 
            GAIN_I_YAW   : pid_gain; 
            GAIN_D_YAW   : pid_gain; 
            THRUST_Z     : motor_rpm 
        ); 
        port
        (
            -- global synchronization
            clk         : in std_logic;
            res_n       : in std_logic;

            -- state set values
            new_set     : in std_logic;
            roll_set    : in imu_angle;
            pitch_set   : in imu_angle;
            yaw_set     : in imu_angle;
            
            -- state is values
            new_state   : in std_logic;
            roll_is     : in imu_angle;
            pitch_is    : in imu_angle;
            yaw_is      : in imu_angle;

            -- motor rpm values
            new_rpm     : out std_logic;
            m0_rpm      : out motor_rpm;
            m1_rpm      : out motor_rpm;
            m2_rpm      : out motor_rpm;
            m3_rpm      : out motor_rpm
        );

    end component control_loop;

end package control_loop_pkg; 

