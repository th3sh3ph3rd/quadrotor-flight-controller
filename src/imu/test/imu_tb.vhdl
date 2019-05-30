library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.imu_pkg.all;

entity imu_tb is
end entity imu_tb;

architecture tb of imu_tb is

    constant SYS_CLK_FREQ   : integer := 50000000;
    constant SYS_CLK_PERIOD : time := 20 ns;
    constant SPI_CLK_PERIOD : time := 200 ns;    -- 4 MHz 

    signal clk, res_n : std_logic;

    signal imu_rdy, sclk, ss_n, mosi : std_logic;

begin

    UUT : imu
    port map
    (
       clk => clk,
       res_n => res_n,
       imu_rdy => imu_rdy,
       roll => open,
       pitch => open,
       yaw => open,
       sclk => sclk,
       ss_n => ss_n,
       mosi => mosi,
       miso => open
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
        wait for SYS_CLK_PERIOD;
        res_n <= '1';
        wait for SYS_CLK_PERIOD;
        
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

