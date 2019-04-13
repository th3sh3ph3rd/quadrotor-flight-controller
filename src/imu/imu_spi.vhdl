--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 13.04.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.imu_spi_pkg.all;

entity imu_spi is

        generic
        (
            SPI_CLK_DIVISIOR : integer;
        );

        port
        (
            -- global synchronization
            clk     : in std_logic;
            res_n   : in std_logic;

            -- communication interface
            busy    : out std_logic;
            tx_en   : in std_logic;
            rx_en   : in std_logic;
            rx_rdy  : out std_logic;
            tx_addr : in std_logic_vector(7 downto 0);
            tx_data : in std_logic_vector(7 downto 0);
            rx_len  : in natural;
            rx_addr : in std_logic_vector(7 downto 0);
            rx_data : in std_logic_vector(7 downto 0);

            -- SPI
            scl     : out std_logic;
            cs_n    : out std_logic;
            sdo     : out std_logic;
            sdi     : in std_logic
        );

end entity imu_spi;

architecture beh of imu_spi is
    type SPI_STATE_TYPE is (IDLE, TX, RX);

    signal spi_state        : SPI_STATE_TYPE;
    signal spi_state_next   : SPI_STATE_TYPE;

begin

    sync : process(all)
    begin
        if res_n = '0' then
            spi_state <= IDLE;
        elsif rising_edge(clk) then
            spi_state
        end if;
    end process;

end architecture beh;

