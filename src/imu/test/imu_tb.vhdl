library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.spi_bfm_pkg.all;
use work.imu_pkg.all;

entity imu_tb is
end entity imu_tb;

architecture tb of imu_tb is

    constant SYS_CLK_FREQ   : natural := 50000000;
    constant SYS_CLK_PERIOD : time := 1 sec / SYS_CLK_FREQ;
    constant SPI_CLK_FREQ   : natural := 4000000; --4 MHz

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
        spi_init(ss_n, sclk, mosi);
        wait for SYS_CLK_PERIOD;
        res_n <= '1';
        wait for SYS_CLK_PERIOD;
       
        spi_begin(ss_n, SPI_CLK_FREQ);

        -- roll
        spi_transmit16(sclk, mosi, X"69a5", SPI_CLK_FREQ);

        -- pitch
        spi_transmit16(sclk, mosi, X"5a69", SPI_CLK_FREQ);
        
        -- yaw
        spi_transmit16(sclk, mosi, X"965a", SPI_CLK_FREQ);

        spi_end(ss_n, sclk, SPI_CLK_FREQ);

        wait;
    end process stimulus;

end architecture tb;

