--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 27.04.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package debug_pkg is

    constant DEBUG_MSG_WIDTH : natural := 31;
    type debug_msg is array (0 to DEBUG_MSG_WIDTH-1) of std_logic_vector(7 downto 0);
    subtype debug_len is natural range 0 to DEBUG_MSG_WIDTH;

    component debug is

        generic
        (
            CLK_FREQ    : integer;
            BAUD_RATE   : integer
        );
        port
        (
            -- global synchronization
            clk     : in std_logic;
            res_n   : in std_logic;

            -- debug interface
            en      : in std_logic;
            msg     : in debug_msg;
            len     : in debug_len;

            -- uart io pins
            rx      : in std_logic;
            tx      : out std_logic
        );

    end component debug;

    function str_to_debug_msg(str : string) return debug_msg;

end package debug_pkg; 

package body debug_pkg is

    -- TODO build in length limit
    function str_to_debug_msg(str : string) return debug_msg is
        variable msg : debug_msg;
    begin
        for i in str'range loop
            msg(i) := std_logic_vector(to_unsigned(character'pos(str(i)), 8));
        end loop;
        return msg;
    end function str_to_debug_msg;

end package body debug_pkg;

