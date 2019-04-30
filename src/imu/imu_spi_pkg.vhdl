--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 13.04.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package imu_spi_pkg is

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
            busy    : out std_logic;
            enable  : in std_logic;
            rx_en   : in std_logic;
            rx_rdy  : out std_logic;
            addr    : in std_logic_vector(7 downto 0);
            tx_data : in std_logic_vector(7 downto 0);
            rx_len  : in natural;
            rx_data : out std_logic_vector(7 downto 0);

            -- SPI
            scl     : out std_logic;
            cs_n    : out std_logic;
            sdo     : out std_logic;
            sdi     : in std_logic
        );
    end component imu_spi;

end package imu_spi_pkg; 

