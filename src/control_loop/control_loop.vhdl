--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 12.04.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pid_types.all;
use work.control_loop_pkg.all;

entity control_loop is

        generic
        (
            GAIN_P   : pid_gain; 
            GAIN_I   : pid_gain; 
            GAIN_D   : pid_gain; 
            THRUST_Z : pid_t 
        ); 
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
            new_state   : in std_logic;
            roll_is     : in imu_angle;
            pitch_is    : in imu_angle;
            yaw_is      : in imu_angle;

            -- motor rpm values
            new_rpm     : out std_logic;
            m0_rpm      : out motor_rmp;
            m1_rpm      : out motor_rmp;
            m2_rpm      : out motor_rmp;
            m3_rpm      : out motor_rmp
        );

end entity control_loop;

architecture structure of control_loop is

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
            
            -- current process state
            new_state   : in std_logic;
            proc_state  : in pid_t;
            
            -- control output
            pid_rdy     : out std_logic;
            pid         : out pid_t
        );
    end component pid;

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
    

end architecture structure;

