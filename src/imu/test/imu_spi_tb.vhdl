library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.imu_spi_pkg.all;

entity imu_spi_tb is
end entity imu_spi_tb;

architecture tb of imu_spi_tb is

    constant SYS_CLK_FREQ   : integer := 50000000;
    constant SYS_CLK_PERIOD : time := 20 ns;
    constant SPI_CLK_PERIOD : time := 80 ns;    -- 12.5 MHz 

    signal clk, res_n : std_logic;

    signal busy, enable, rx_en, sdi : std_logic;
    signal addr, tx_data : std_logic_vector(7 downto 0);
    signal rx_len : natural;

begin

    -- res_n <= transport '1' after 0 ns, '0' after 20 ns, '1' after 40 ns;

    UUT : imu_spi
    generic map
    (
        CLK_DIVISOR => 4 -- 12.5 MHz SPI freq
    )
    port map
    (
       clk => clk,
       res_n => res_n,
       busy => busy,
       enable => enable,
       rx_en => rx_en,
       addr => addr,
       tx_data => tx_data,
       sdi => sdi
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
        enable <= '0';
        rx_en <= '0';
        addr <= (others => '0');
        tx_data <= (others => '0');
        rx_len <= 0;
        sdi <= '0';
        wait for SYS_CLK_PERIOD;
        res_n <= '1';

        -- simple tx test
        enable <= '1';
        addr <= "10011001";
        tx_data <= "10101010";
        wait for SYS_CLK_PERIOD;
        enable <= '0';
        wait until falling_edge(busy);

        -- simple rx test
        enable <= '1';
        rx_en <= '1';
        addr <= "11001100";
        tx_data <= "01100110";
        rx_len <= 1;
        wait for SYS_CLK_PERIOD;
        enable <= '0';
        wait for SYS_CLK_PERIOD + SPI_CLK_PERIOD*8;
        sdi <= '1';
        wait for SPI_SLK_PERIOD; 
        sdi <= '0';
        wait for SPI_SLK_PERIOD; 
        sdi <= '0';
        wait for SPI_SLK_PERIOD; 
        sdi <= '1';
        wait for SPI_SLK_PERIOD; 
        sdi <= '1';
        wait for SPI_SLK_PERIOD; 
        sdi <= '0';
        wait for SPI_SLK_PERIOD; 
        sdi <= '0';
        wait for SPI_SLK_PERIOD; 
        sdi <= '1';
        wait until falling_edge(busy);

        wait;
    end process test;

end architecture imu_spi_tb;

