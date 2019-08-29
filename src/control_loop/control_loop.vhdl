--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 12.04.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pid_types.all;
use work.imu_pkg.all;
use work.motor_pwm_pkg.all;
use work.control_loop_pkg.all;

entity control_loop is

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

            -- state set valuesi
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

end entity control_loop;

architecture structure of control_loop is

    signal roll_rdy, pitch_rdy, yaw_rdy, new_thrust : std_logic;
    signal roll_pid, pitch_pid, yaw_pid : pid_out;

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
            setpoint    : in pid_in;
            
            -- current process state
            new_state   : in std_logic;
            proc_state  : in pid_in;
            
            -- control output
            pid_rdy     : out std_logic;
            pid         : out pid_out
        );
    end component pid;

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
            t_roll      : in pid_out;
            t_pitch     : in pid_out;
            t_yaw       : in pid_out;

            -- motor speeds
            new_speed   : out std_logic;
            s_m0        : out motor_rpm;
            s_m1        : out motor_rpm;
            s_m2        : out motor_rpm;
            s_m3        : out motor_rpm
        );
    end component calc_motor_speed;

begin
   
    roll_ctrl : pid
    generic map
    (
        GAIN_P => GAIN_P_PITCH, 
        GAIN_I => GAIN_I_PITCH,
        GAIN_D => GAIN_D_PITCH
    )
    port map
    (
        clk => clk,         
        res_n => res_n, 
        new_sp => new_set, 
        setpoint => signed(roll_set),
        new_state => new_state,
        proc_state => signed(roll_is),
        pid_rdy => roll_rdy,
        pid => roll_pid
    );

    pitch_ctrl : pid
    generic map
    (
        GAIN_P => GAIN_P_PITCH, 
        GAIN_I => GAIN_I_PITCH,
        GAIN_D => GAIN_D_PITCH
    )
    port map
    (
        clk => clk,         
        res_n => res_n, 
        new_sp => new_set, 
        setpoint => signed(pitch_set),
        new_state => new_state,
        proc_state => signed(pitch_is),
        pid_rdy => pitch_rdy,
        pid => pitch_pid
    );

    yaw_ctrl : pid
    generic map
    (
        GAIN_P => GAIN_P_YAW, 
        GAIN_I => GAIN_I_YAW,
        GAIN_D => GAIN_D_YAW
    )
    port map
    (
        clk => clk,         
        res_n => res_n, 
        new_sp => new_set, 
        setpoint => signed(yaw_set),
        new_state => new_state,
        proc_state => signed(yaw_is),
        pid_rdy => yaw_rdy,
        pid => yaw_pid
    );

    new_thrust <= roll_rdy and pitch_rdy and yaw_rdy;

    motor_speed : calc_motor_speed
    generic map
    (
        THRUST_Z => THRUST_Z
    )
    port map
    (
        clk => clk,         
        res_n => res_n, 
        new_thrust => new_thrust,
        t_roll => roll_pid,
        t_pitch => pitch_pid,
        t_yaw => yaw_pid,
        new_speed => new_rpm,
        s_m0 => m0_rpm,
        s_m1 => m1_rpm,
        s_m2 => m2_rpm,
        s_m3 => m3_rpm
    );

end architecture structure;

