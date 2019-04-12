--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 12.04.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package imu_pkg is

    constant IMU_ANGLE_WIDTH : natural := 16;
    subtype imu_angle is std_logic_vector(IMU_ANGLE_WIDTH-1 downto 0); 

    component imu is

        port
        (
            -- global synchronization
            clk     : in std_logic;
            res_n   : in std_logic;

            -- SPI
            scl     : out std_logic;
            cs_n    : out std_logic;
            sdo     : out std_logic;
            sdi     : in std_logic;

            -- output angles
            roll    : out imu_angle;
            pitch   : out imu_angle;
            yaw     : out imu_angle 
        );

    end component imu;

end package imu_pkg; 

