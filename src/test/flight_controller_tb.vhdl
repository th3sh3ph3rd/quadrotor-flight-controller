library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.fp_pkg.all;
use work.imu_pkg.all;
use work.control_loop_pkg.all;
use work.motor_pwm_pkg.all;
use work.spi_bfm_pkg.all;

entity flight_controller_tb is
end entity flight_controller_tb;

architecture tb of flight_controller_tb is

    constant SYS_CLK_FREQ   : integer := 50000000;
    constant SYS_CLK_PERIOD : time := 20 ns;
    constant SPI_CLK_FREQ   : natural := 4000000; --4 MHz
    constant PWM_FREQ       : natural := 400;
    constant PWM_PERIOD     : time := 2500 us; 

    signal clk, res_n : std_logic;

    signal ss_n, sclk, mosi, new_set, new_state, new_rpm : std_logic;
    signal roll, pitch, yaw : FP_T;
    signal m0_rpm, m1_rpm, m2_rpm, m3_rpm : motor_rpm;

    procedure imu_reading 
        (
            signal ss_n             : out std_logic;
            signal sclk             : out std_logic;
            signal mosi             : out std_logic;
            constant roll           : std_logic_vector(15 downto 0);
            constant pitch          : std_logic_vector(15 downto 0);
            constant yaw            : std_logic_vector(15 downto 0);
            constant SPI_CLK_FREQ   : natural
        ) is
    begin
        spi_begin(ss_n, SPI_CLK_FREQ);
        spi_transmit16(sclk, mosi, roll, SPI_CLK_FREQ);
        spi_transmit16(sclk, mosi, pitch, SPI_CLK_FREQ);
        spi_transmit16(sclk, mosi, yaw, SPI_CLK_FREQ);
        spi_end(ss_n, sclk, SPI_CLK_FREQ);
    end procedure;

begin

    UUT_imu : imu
    port map
    (
       clk => clk,
       res_n => res_n,
       imu_rdy => new_state,
       roll => roll,
       pitch => pitch,
       yaw => yaw,
       sclk => sclk,
       ss_n => ss_n,
       mosi => mosi,
       miso => open
    );

    UUT_ctrl_loop : control_loop
    generic map
    (
        --hex notation
        GAIN_P_ROLL  => int2fp(2),
        GAIN_I_ROLL  => int2fp(3),
        GAIN_D_ROLL  => int2fp(-5),
        GAIN_P_PITCH => int2fp(2),
        GAIN_I_PITCH => int2fp(3),
        GAIN_D_PITCH => int2fp(-5),
        GAIN_P_YAW   => int2fp(-1),
        GAIN_I_YAW   => int2fp(5),
        GAIN_D_YAW   => int2fp(2),
        THRUST_Z     => X"9AE2"
    )
    port map
    (
        clk => clk,         
        res_n => res_n,       
        new_set => new_set,
        roll_set => int2fp(0),
        pitch_set => int2fp(0),
        yaw_set => int2fp(0),
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

    UUT_m0 : motor_pwm
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
    
    UUT_m1 : motor_pwm
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
    
    UUT_m2 : motor_pwm
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
    
    UUT_m3 : motor_pwm
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
        spi_init(ss_n, sclk, mosi);
        wait for SYS_CLK_PERIOD;
        res_n <= '1';
        wait for SYS_CLK_PERIOD;
       
        new_set <= '1';
        wait for SYS_CLK_PERIOD;
        new_set <= '0';

        --test roll axis
        for i in 0 to 90*16/20 loop --take fixed point shift of 4 bits into consideration
            imu_reading(ss_n, sclk, mosi, 
                        std_logic_vector(to_signed(90, 16) - to_signed(20*i, 16)),
                        X"0000", X"0000", SPI_CLK_FREQ);
            wait for 4*PWM_PERIOD;
        end loop;
        
        --test roll and pitch axis
        for i in 0 to 90*16/20 loop --take fixed point shift of 4 bits into consideration
            imu_reading(ss_n, sclk, mosi, 
                        std_logic_vector(to_signed(90, 16) - to_signed(20*i, 16)),
                        std_logic_vector(to_signed(-90, 16) + to_signed(20*i, 16)),
                        X"0000", SPI_CLK_FREQ);
            wait for 4*PWM_PERIOD;
        end loop;

        --test roll, pitch and yaw axis
        for i in 0 to 90*16/20 loop --take fixed point shift of 4 bits into consideration
            imu_reading(ss_n, sclk, mosi, 
                        std_logic_vector(to_signed(90, 16) - to_signed(20*i, 16)),
                        std_logic_vector(to_signed(-90, 16) + to_signed(20*i, 16)),
                        std_logic_vector(to_signed(90, 16) - to_signed(20*i, 16)),
                        SPI_CLK_FREQ);
            wait for 4*PWM_PERIOD;
        end loop;
        
        wait;
    end process stimulus;

end architecture tb;

