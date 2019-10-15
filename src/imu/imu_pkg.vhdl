--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 28.05.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.fp_pkg.all;

package imu_pkg is

    component imu is

        port
        (
            -- global synchronization
            clk     : in std_logic;
            res_n   : in std_logic;

            -- output angles
            imu_rdy : out std_logic;
            roll    : out FP_T;
            pitch   : out FP_T;
            yaw     : out FP_T;

            -- SPI
            ss_n    : in std_logic;
            sclk    : in std_logic;
            mosi    : in std_logic;
            miso    : out std_logic
        );

    end component imu;

end package imu_pkg; 

