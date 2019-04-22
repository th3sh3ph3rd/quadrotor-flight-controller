--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 12.04.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.imu_pkg.all;
use work.imu_spi_pkg.all;

entity imu is

        port
        (
            -- global synchronization
            clk     : in std_logic;
            res_n   : in std_logic;

            -- output angles
            imu_rdy : out std_logic;
            roll    : out imu_angle;
            pitch   : out imu_angle;
            yaw     : out imu_angle 
        );

end entity imu;

architecture beh of imu is

    signal spi_busy, spi_enable, spi_rx_en, spi_rx_rdy : std_logic;
    signal spi_addr, spi_tx_data spi_rx_data : std_logic_vector(7 downto 0);
    signal spi_rx_len : natural;

    procedure write_register(constant addr  : std_logic_vector(7 downto 0);
                             constant data  : std_logic_vector(7 downto 0)) is
    begin

    end procedure write_register;

    procedure read_register(constant addr   : std_logic_vector(7 downto 0);
                            constant len    : natural) is
    begin

    end procedure read_register;

begin

    entity imu_spi
    generic map
    (
        CLK_DIVISOR => 4
    )
    port map
    (
        clk <= clk,
        res_n <= res_n,
        
    );

end architecture beh;

