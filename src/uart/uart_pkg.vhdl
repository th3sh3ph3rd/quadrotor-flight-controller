--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 23.04.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sync_pkg.all;
use work.ram_pkg.all;

package uart_pkg is

    component uart is 

        generic
        (
            CLK_FREQ        : integer;
            BAUD_RATE       : integer;
            SYNC_STAGES     : integer;
            TX_FIFO_DEPTH   : integer;
            RX_FIFO_DEPTH   : integer
        );
        port
        (
            -- global synchronization
            clk         : in std_logic;                       
            res_n       : in std_logic;                     

            -- tx interface
            tx_data     : in std_logic_vector(7 downto 0);  
            tx_wr       : in std_logic;			
            tx_full     : out std_logic;	

            -- rx interface
            rx_data     : out std_logic_vector(7 downto 0);
            rx_rd       : in std_logic;			
            rx_full     : out std_logic;	
            rx_empty    : out std_logic;

            -- uart io pins
            rx          : in std_logic;
            tx          : out std_logic
        );

    end component uart;

end package uart_pkg;

