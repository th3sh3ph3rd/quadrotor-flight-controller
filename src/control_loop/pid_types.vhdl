--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 17.05.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package pid_types is
 
    constant FIXED_POINT_SHIFT : natural := 4;
    
    constant PID_IN_WIDTH : natural := 16;
    subtype pid_in is signed (PID_IN_WIDTH-1 downto 0);
    constant PID_GAIN_WIDTH : natural := PID_IN_WIDTH;
    subtype pid_gain is signed (PID_GAIN_WIDTH-1 downto 0);
    constant PID_OUT_WIDTH : natural := PID_IN_WIDTH+PID_GAIN_WIDTH;
    subtype pid_out is signed (PID_OUT_WIDTH-1 downto 0);
    
end package pid_types; 

