library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.imu_pkg.all;
use work.control_loop_pkg.all;

entity imu_control_loop_tb is
end entity imu_control_loop_tb;

architecture tb of imu_control_loop_tb is

    constant SYS_CLK_FREQ   : integer := 50000000;
    constant SYS_CLK_PERIOD : time := 20 ns;
    constant SPI_CLK_PERIOD : time := 200 ns;    -- 4 MHz 

    signal clk, res_n : std_logic;

    signal imu_rdy, sclk, ss_n, mosi, new_set : std_logic;
    signal roll, pitch, yaw : imu_angle;

begin

    UUT1 : imu
    port map
    (
       clk => clk,
       res_n => res_n,
       imu_rdy => imu_rdy,
       roll => roll,
       pitch => pitch,
       yaw => yaw,
       sclk => sclk,
       ss_n => ss_n,
       mosi => mosi,
       miso => open
    );

    UUT2 : control_loop
    generic map
    (
        GAIN_P_ROLL  => X"0006", 
        GAIN_I_ROLL  => X"0002",
        GAIN_D_ROLL  => X"0002", 
        GAIN_P_PITCH => X"0006", 
        GAIN_I_PITCH => X"0002",
        GAIN_D_PITCH => X"0002", 
        GAIN_P_YAW   => X"0006", 
        GAIN_I_YAW   => X"0002",
        GAIN_D_YAW   => X"0002", 
        THRUST_Z     => X"0000"
    )
    port map
    (
        clk => clk,         
        res_n => res_n,       
        new_set => new_set,
        roll_set => X"0000",
        pitch_set => X"0000",
        yaw_set => X"0000",
        new_state => imu_rdy,
        roll_is => roll,
        pitch_is => pitch,
        yaw_is => yaw,
        new_rpm => open,
        m0_rpm => open,
        m1_rpm => open,
        m2_rpm => open,
        m3_rpm => open
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
        sclk <= '0';
        ss_n <= '1';
        mosi <= '0';
        new_set <= '0';
        wait for SYS_CLK_PERIOD;
        res_n <= '1';
        wait for SYS_CLK_PERIOD;
       
        new_set <= '1';
        wait for SYS_CLK_PERIOD;
        new_set <= '0';

        ss_n <= '0';
        wait for 1 ns;
        wait for SPI_CLK_PERIOD;

        -- roll
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        wait for SPI_CLK_PERIOD;
        
        -- pitch
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        wait for SPI_CLK_PERIOD;
        
        -- yaw
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        wait for SPI_CLK_PERIOD;
        
        ss_n <= '1';

        wait;
    end process stimulus;

end architecture tb;

