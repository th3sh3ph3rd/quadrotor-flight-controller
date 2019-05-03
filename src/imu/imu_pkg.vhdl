--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 12.04.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.imu_spi_if.all;
use work.debug_pkg.all;

package imu_pkg is

    constant IMU_ANGLE_WIDTH : natural := 16;
    subtype imu_angle is std_logic_vector(IMU_ANGLE_WIDTH-1 downto 0); 

    component imu is

        generic
        (
            CLK_FREQ : integer 
        ); 
        port
        (
            -- global synchronization
            clk     : in std_logic;
            res_n   : in std_logic;

            -- output angles
            imu_rdy : out std_logic;
            roll    : out imu_angle;
            pitch   : out imu_angle;
            yaw     : out imu_angle;

            -- SPI
            spi_in  : in imu_spi_in;
            spi_out : out imu_spi_out
 
            -- debug port
            dbg     : out debug_if
        );

    end component imu;

end package imu_pkg; 

