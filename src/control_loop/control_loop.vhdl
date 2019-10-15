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
use work.control_loop_pkg.all;

entity control_loop is

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

end entity control_loop;

architecture structure of control_loop is

    signal roll_rdy, pitch_rdy, yaw_rdy, new_thrust : std_logic;
    signal roll_pid, pitch_pid, yaw_pid : FP_T;

    component pid is
        generic
        (
            GAIN_P : FP_T; 
            GAIN_I : FP_T; 
            GAIN_D : FP_T 
        ); 
        port
        (
            -- global synchronization
            clk         : in std_logic;
            res_n       : in std_logic;

            -- setpoint
            new_sp      : in std_logic;
            setpoint    : in FP_T;
            
            -- current process state
            new_state   : in std_logic;
            adc         : in FP_T;
            
            -- control output
            pid_rdy     : out std_logic;
            dac         : out FP_T
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
            roll        : in FP_T;
            pitch       : in FP_T;
            yaw         : in FP_T;

            -- motor speeds
            speed_rdy   : out std_logic;
            m0          : out motor_rpm;
            m1          : out motor_rpm;
            m2          : out motor_rpm;
            m3          : out motor_rpm
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
        setpoint => roll_set,
        new_state => new_state,
        adc => roll_is,
        pid_rdy => roll_rdy,
        dac => roll_pid
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
        setpoint => pitch_set,
        new_state => new_state,
        adc => pitch_is,
        pid_rdy => pitch_rdy,
        dac => pitch_pid
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
        setpoint => yaw_set,
        new_state => new_state,
        adc => yaw_is,
        pid_rdy => yaw_rdy,
        dac => yaw_pid
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
        roll => roll_pid,
        pitch => pitch_pid,
        yaw => yaw_pid,
        speed_rdy => new_rpm,
        m0 => m0_rpm,
        m1 => m1_rpm,
        m2 => m2_rpm,
        m3 => m3_rpm
    );

end architecture structure;

