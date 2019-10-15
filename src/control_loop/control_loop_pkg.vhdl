--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 12.04.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.fp_pkg.all;
use work.imu_pkg.all;
use work.motor_pwm_pkg.all;

package control_loop_pkg is

    component control_loop is

        generic
        (
            GAIN_P_ROLL  : FP_T; 
            GAIN_I_ROLL  : FP_T; 
            GAIN_D_ROLL  : FP_T; 
            GAIN_P_PITCH : FP_T; 
            GAIN_I_PITCH : FP_T; 
            GAIN_D_PITCH : FP_T; 
            GAIN_P_YAW   : FP_T; 
            GAIN_I_YAW   : FP_T; 
            GAIN_D_YAW   : FP_T; 
            THRUST_Z     : motor_rpm 
        ); 
        port
        (
            -- global synchronization
            clk         : in std_logic;
            res_n       : in std_logic;

            -- state set values
            new_set     : in std_logic;
            roll_set    : in FP_T;
            pitch_set   : in FP_T;
            yaw_set     : in FP_T;
            
            -- state is values
            new_state   : in std_logic;
            roll_is     : in FP_T;
            pitch_is    : in FP_T;
            yaw_is      : in FP_T;

            -- motor rpm values
            new_rpm     : out std_logic;
            m0_rpm      : out motor_rpm;
            m1_rpm      : out motor_rpm;
            m2_rpm      : out motor_rpm;
            m3_rpm      : out motor_rpm
        );

    end component control_loop;

end package control_loop_pkg; 

