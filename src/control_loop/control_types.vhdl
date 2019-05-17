--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 17.05.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package pid_types is

    subtype pid_in is signed (15 downto 0);
    subtype pid_out is signed (15 downto 0);
    subtype pid_t is signed (15 downto 0);
    subtype pid_gain is signed (15 downto 0);
    
end package pid_types; 

