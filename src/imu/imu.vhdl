--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 12.04.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.imu_pkg.all;

entity imu is

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
            yaw     : out imu_angle;
        );

end entity imu;

architecture beh of imu is

begin

end architecture beh;

