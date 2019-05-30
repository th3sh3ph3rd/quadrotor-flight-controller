library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.imu_spi_if.all;

entity imu_spi_tb is
end entity imu_spi_tb;

architecture tb of imu_spi_tb is

    constant SYS_CLK_FREQ   : integer := 50000000;
    constant SYS_CLK_PERIOD : time := 20 ns;
    constant SPI_CLK_PERIOD : time := 80 ns;    -- 12.5 MHz 

    signal clk, res_n : std_logic;

    signal reg_in   : imu_reg_in;
    signal reg_out  : imu_reg_out;
    signal spi_in   : imu_spi_in;

    component imu_spi is
        generic
        (
            CLK_DIVISOR : integer 
        ); 
        port
        (
            -- global synchronization
            clk     : in std_logic;
            res_n   : in std_logic;

            -- communication interface
            reg_in  : in imu_reg_in;
            reg_out : out imu_reg_out; 

            -- SPI
            spi_in  : in imu_spi_in;
            spi_out : out imu_spi_out
        );
    end component imu_spi;

begin

    UUT : imu_spi
    generic map
    (
        CLK_DIVISOR => 4 -- 12.5 MHz SPI freq
    )
    port map
    (
       clk => clk,
       res_n => res_n,
       reg_in => reg_in,
       reg_out => reg_out,
       spi_in => spi_in,
       spi_out => open
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
        reg_in.start <= '0';
        reg_in.rd_en <= '0';
        reg_in.addr <= (others => '0');
        reg_in.wr_data <= (others => '0');
        reg_in.rd_len <= 0;
        spi_in.sdi <= '0';
        wait for SYS_CLK_PERIOD;
        res_n <= '1';

        -- simple tx test
        reg_in.start <= '1';
        reg_in.addr <= "10011001";
        reg_in.wr_data <= "10101010";
        wait for SYS_CLK_PERIOD;
        reg_in.start <= '0';
        wait until reg_out.finish = '1';
        wait for SYS_CLK_PERIOD*2;

        -- simple rx test
        reg_in.start <= '1';
        reg_in.rd_en <= '1';
        reg_in.addr <= "11001100";
        reg_in.rd_len <= 1;
        wait for SYS_CLK_PERIOD;
        reg_in.start <= '0';
        wait for SYS_CLK_PERIOD + SPI_CLK_PERIOD*8;
        spi_in.sdi <= '1';
        wait for SPI_CLK_PERIOD; 
        spi_in.sdi <= '0';
        wait for SPI_CLK_PERIOD; 
        spi_in.sdi <= '0';
        wait for SPI_CLK_PERIOD; 
        spi_in.sdi <= '1';
        wait for SPI_CLK_PERIOD; 
        spi_in.sdi <= '1';
        wait for SPI_CLK_PERIOD; 
        spi_in.sdi <= '0';
        wait for SPI_CLK_PERIOD; 
        spi_in.sdi <= '0';
        wait for SPI_CLK_PERIOD; 
        spi_in.sdi <= '1';
        wait until reg_out.finish = '1';
        wait for SYS_CLK_PERIOD*2;

        -- multi rx test
        reg_in.start <= '1';
        reg_in.rd_en <= '1';
        reg_in.addr <= "11001100";
        reg_in.rd_len <= 3;
        wait for SYS_CLK_PERIOD;
        reg_in.start <= '0';
        wait for SYS_CLK_PERIOD + SPI_CLK_PERIOD*8;
        -- 10011001
        spi_in.sdi <= '1';
        wait for SPI_CLK_PERIOD; 
        spi_in.sdi <= '0';
        wait for SPI_CLK_PERIOD; 
        spi_in.sdi <= '0';
        wait for SPI_CLK_PERIOD; 
        spi_in.sdi <= '1';
        wait for SPI_CLK_PERIOD; 
        spi_in.sdi <= '1';
        wait for SPI_CLK_PERIOD; 
        spi_in.sdi <= '0';
        wait for SPI_CLK_PERIOD; 
        spi_in.sdi <= '0';
        wait for SPI_CLK_PERIOD; 
        spi_in.sdi <= '1';
        wait for SPI_CLK_PERIOD;
        -- 11110000
        spi_in.sdi <= '1';
        wait for SPI_CLK_PERIOD; 
        spi_in.sdi <= '1';
        wait for SPI_CLK_PERIOD; 
        spi_in.sdi <= '1';
        wait for SPI_CLK_PERIOD; 
        spi_in.sdi <= '1';
        wait for SPI_CLK_PERIOD; 
        spi_in.sdi <= '0';
        wait for SPI_CLK_PERIOD; 
        spi_in.sdi <= '0';
        wait for SPI_CLK_PERIOD; 
        spi_in.sdi <= '0';
        wait for SPI_CLK_PERIOD; 
        spi_in.sdi <= '0';
        wait for SPI_CLK_PERIOD;
        -- 01101101
        spi_in.sdi <= '0';
        wait for SPI_CLK_PERIOD; 
        spi_in.sdi <= '1';
        wait for SPI_CLK_PERIOD; 
        spi_in.sdi <= '1';
        wait for SPI_CLK_PERIOD; 
        spi_in.sdi <= '0';
        wait for SPI_CLK_PERIOD; 
        spi_in.sdi <= '1';
        wait for SPI_CLK_PERIOD; 
        spi_in.sdi <= '1';
        wait for SPI_CLK_PERIOD; 
        spi_in.sdi <= '0';
        wait for SPI_CLK_PERIOD; 
        spi_in.sdi <= '1';
        wait until reg_out.finish = '1';

        wait;
    end process stimulus;

end architecture tb;

