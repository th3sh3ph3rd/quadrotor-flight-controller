library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.imu_pkg.all;
use work.control_loop_pkg.all;
use work.motor_pwm_pkg.all;

entity control_loop_motor_pwm_tb is
end entity control_loop_motor_pwm_tb;

architecture tb of control_loop_motor_pwm_tb is

    constant SYS_CLK_FREQ   : integer := 50000000;
    constant SYS_CLK_PERIOD : time := 20 ns;

    signal clk, res_n : std_logic;

    signal new_set, new_state, new_rpm : std_logic;
    signal roll, pitch, yaw : imu_angle;
    signal m0_rpm, m1_rpm, m2_rpm, m3_rpm : motor_rpm;

begin

    UUT0 : control_loop
    generic map
    (
        --hex notation
        GAIN_P_ROLL  => X"0006", 
        GAIN_I_ROLL  => X"0002",
        GAIN_D_ROLL  => X"0002", 
        GAIN_P_PITCH => X"0006", 
        GAIN_I_PITCH => X"0002",
        GAIN_D_PITCH => X"0002", 
        GAIN_P_YAW   => X"0006", 
        GAIN_I_YAW   => X"0002",
        GAIN_D_YAW   => X"0002", 
        THRUST_Z     => X"9AE2"
    )
    port map
    (
        clk => clk,         
        res_n => res_n,       
        new_set => new_set,
        roll_set => X"0000",
        pitch_set => X"0000",
        yaw_set => X"0000",
        new_state => new_state,
        roll_is => roll,
        pitch_is => pitch,
        yaw_is => yaw,
        new_rpm => new_rpm,
        m0_rpm => m0_rpm,
        m1_rpm => m1_rpm,
        m2_rpm => m2_rpm,
        m3_rpm => m3_rpm
    );

    UUT1 : motor_pwm
    generic map
    (
        SYS_CLK_FREQ => SYS_CLK_FREQ
    )
    port map
    (
        clk => clk,
        res_n => res_n,
        new_rpm => new_rpm,
        rpm => m0_rpm,
        pwm_out => open 
    );
    
    UUT2 : motor_pwm
    generic map
    (
        SYS_CLK_FREQ => SYS_CLK_FREQ
    )
    port map
    (
        clk => clk,
        res_n => res_n,
        new_rpm => new_rpm,
        rpm => m1_rpm,
        pwm_out => open 
    );
    
    UUT3 : motor_pwm
    generic map
    (
        SYS_CLK_FREQ => SYS_CLK_FREQ
    )
    port map
    (
        clk => clk,
        res_n => res_n,
        new_rpm => new_rpm,
        rpm => m2_rpm,
        pwm_out => open 
    );
    
    UUT4 : motor_pwm
    generic map
    (
        SYS_CLK_FREQ => SYS_CLK_FREQ
    )
    port map
    (
        clk => clk,
        res_n => res_n,
        new_rpm => new_rpm,
        rpm => m3_rpm,
        pwm_out => open 
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
        new_set <= '0';
        new_state <= '0';
        wait for SYS_CLK_PERIOD;
        res_n <= '1';
        wait for SYS_CLK_PERIOD;
       
        new_set <= '1';
        new_state <= '1';
        roll <= X"0000";
        pitch <= X"0000";
        yaw <= X"0000";
        wait for SYS_CLK_PERIOD;
        new_set <= '0';
        new_state <= '0';
        
        wait until new_rpm = '1';
        wait for SYS_CLK_PERIOD;
        new_state <= '1';
        roll <= X"05A0"; --90*16 => 90°
        wait for SYS_CLK_PERIOD;
        new_state <= '0';

        --test roll axis
        for i in 0 to 90*16/20 loop --take fixed point shift of 4 bits into consideration
            wait until new_rpm = '1';
            wait for SYS_CLK_PERIOD;
            new_state <= '1';
            roll <= std_logic_vector(to_signed(1440, IMU_ANGLE_WIDTH) - to_signed(20*i, IMU_ANGLE_WIDTH));
            wait for SYS_CLK_PERIOD;
            new_state <= '0';
        end loop;
        
        wait until new_rpm = '1';
        wait for SYS_CLK_PERIOD;
        new_state <= '1';
        roll <= X"05A0"; --90*16 => 90°
        pitch <= X"FA60"; --90*16 => -90°
        yaw <= X"0000";
        wait for SYS_CLK_PERIOD;
        new_state <= '0';

        --test roll and pitch axis
        for i in 0 to 90*16/20 loop --take fixed point shift of 4 bits into consideration
            wait until new_rpm = '1';
            wait for SYS_CLK_PERIOD;
            new_state <= '1';
            roll <= std_logic_vector(to_signed(1440, IMU_ANGLE_WIDTH) - to_signed(20*i, IMU_ANGLE_WIDTH));
            pitch <= std_logic_vector(to_signed(-1440, IMU_ANGLE_WIDTH) + to_signed(20*i, IMU_ANGLE_WIDTH));
            wait for SYS_CLK_PERIOD;
            new_state <= '0';
        end loop;

        wait until new_rpm = '1';
        wait for SYS_CLK_PERIOD;
        new_state <= '1';
        roll <= X"05A0"; --90*16 => 90°
        pitch <= X"FA60"; --90*16 => -90°
        yaw <= X"05A0"; --90*16 => 90°
        wait for SYS_CLK_PERIOD;
        new_state <= '0';

        --test roll, pitch and yaw axis
        for i in 0 to 90*16/20 loop --take fixed point shift of 4 bits into consideration
            wait until new_rpm = '1';
            wait for SYS_CLK_PERIOD;
            new_state <= '1';
            roll <= std_logic_vector(to_signed(1440, IMU_ANGLE_WIDTH) - to_signed(20*i, IMU_ANGLE_WIDTH));
            pitch <= std_logic_vector(to_signed(-1440, IMU_ANGLE_WIDTH) + to_signed(20*i, IMU_ANGLE_WIDTH));
            yaw <= std_logic_vector(to_signed(1440, IMU_ANGLE_WIDTH) - to_signed(20*i, IMU_ANGLE_WIDTH));
            wait for SYS_CLK_PERIOD;
            new_state <= '0';
        end loop;
        
        wait;
    end process stimulus;

end architecture tb;

