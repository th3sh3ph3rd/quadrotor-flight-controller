--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 28.05.2019
--
-- SPI Mode 0 bus functionality model
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package spi_bfm_pkg is

procedure spi_init 
    (
        signal ss_n             : out std_logic;
        signal sclk             : out std_logic;
        signal mosi             : out std_logic
    );

procedure spi_begin 
    (
        signal ss_n             : out std_logic;
        constant SPI_CLK_FREQ   : natural
    );

procedure spi_end
    (
        signal ss_n             : out std_logic;
        signal sclk             : out std_logic;
        constant SPI_CLK_FREQ   : natural
    );

procedure spi_transmit8
    (
        signal sclk             : out std_logic;
        signal mosi             : out std_logic;
        constant data           : std_logic_vector(7 downto 0);
        constant SPI_CLK_FREQ   : natural
    );

procedure spi_transmit16
    (
        signal sclk             : out std_logic;
        signal mosi             : out std_logic;
        constant data           : std_logic_vector(15 downto 0);
        constant SPI_CLK_FREQ   : natural
    );

end package spi_bfm_pkg;

package body spi_bfm_pkg is

procedure spi_init 
    (
        signal ss_n             : out std_logic;
        signal sclk             : out std_logic;
        signal mosi             : out std_logic
    ) is
begin
    ss_n <= '1';
    sclk <= '0';
    mosi <= 'Z';
end procedure spi_init;

procedure spi_begin 
    (
        signal ss_n             : out std_logic;
        constant SPI_CLK_FREQ   : natural
    ) is
    constant CLK_PERIOD : time := 1 sec / SPI_CLK_FREQ;
begin
    ss_n <= '0';
    wait for CLK_PERIOD;
end procedure spi_begin;

procedure spi_end
    (
        signal ss_n             : out std_logic;
        signal sclk             : out std_logic;
        constant SPI_CLK_FREQ   : natural
    ) is
    constant CLK_PERIOD : time := 1 sec / SPI_CLK_FREQ;
begin
    wait for CLK_PERIOD;
    ss_n <= '1';
    sclk <= '0';
end procedure spi_end;

procedure spi_transmit8
    (
        signal sclk             : out std_logic;
        signal mosi             : out std_logic;
        constant data           : std_logic_vector(7 downto 0);
        constant SPI_CLK_FREQ   : natural
    ) is
    constant CLK_PERIOD : time := 1 sec / SPI_CLK_FREQ;
begin
    for i in 7 downto 0 loop
        sclk <= '0';
        mosi <= data(i);
        wait for CLK_PERIOD/2;
        sclk <= '1';
        wait for CLK_PERIOD/2;
    end loop;
end procedure spi_transmit8;

procedure spi_transmit16
    (
        signal sclk             : out std_logic;
        signal mosi             : out std_logic;
        constant data           : std_logic_vector(15 downto 0);
        constant SPI_CLK_FREQ   : natural
    ) is
    constant CLK_PERIOD : time := 1 sec / SPI_CLK_FREQ;
begin
    for i in 15 downto 0 loop
        sclk <= '0';
        mosi <= data(i);
        wait for CLK_PERIOD/2;
        sclk <= '1';
        wait for CLK_PERIOD/2;
    end loop;
end procedure spi_transmit16;

end package body spi_bfm_pkg;

