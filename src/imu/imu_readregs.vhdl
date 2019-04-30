--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 29.04.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity imu_readregs is

        port
        (
            -- global synchronization
            clk     : in std_logic;
            res_n   : in std_logic;
        );

end entity imu_readregs;

architecture behavior of imu_readregs is

begin


end architecture behavior;

