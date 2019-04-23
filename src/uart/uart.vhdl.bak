--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 23.04.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sync_pkg.all;
use work.ram_pkg.all;

entity uart is 

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

end entity;

architecture structure of uart is

    signal rd_data      : std_logic_vector(7 downto 0);
    signal tx_empty     : std_logic;
    signal rd           : std_logic;

    signal rx_sync      : std_logic;
    signal new_data     : std_logic;
    signal wr_data      : std_logic_vector(7 downto 0);

    component uart_tx is 

        generic 
        (
            CLK_DIVISOR : integer
        );
        port 
        (
            -- global synchronization
            clk     : in std_logic;
            res_n   : in std_logic;
              
            -- tx pin
            tx      : out std_logic; 

            -- tx interface
            data    : in std_logic_vector(7 downto 0);
            empty   : in std_logic;                 
            rd      : out std_logic                   
        );
    
    end component uart_tx;

    component uart_rx is 

        generic
        (
            CLK_DIVISOR : integer
        );
        port
        (
            -- global synchronization
            clk         : in std_logic; 
            res_n       : in std_logic; 

            -- rx pin
            rx          : in std_logic;   

            -- rx interface
            new_data    : out std_logic;
            data        : out std_logic_vector(7 downto 0)
        );
    
    end component uart_rx;

begin

    sys_inst : sync
    generic map
    (
        SYNC_STAGES => SYNC_STAGES,
        RESET_VALUE => '1'
    )
    port map 
    (
        clk => clk,
        res_n => res_n,
        data_in => rx,
        data_out => rx_sync
    );

    uart_tx_inst : uart_tx
    generic map 
    (
        CLK_DIVISOR => CLK_FREQ / BAUD_RATE
    )
    port map 
    (
        clk => clk,
        res_n => res_n,

        tx => tx,

        data => rd_data,
        empty => tx_empty,
        rd => rd
    );

    tx_fifo_inst : fifo_1c1r1w
    generic map
    (
        MIN_DEPTH => TX_FIFO_DEPTH,
        DATA_WIDTH => 8 
    )
    port map 
    (
        clk => clk,
        res_n => res_n,
        rd_data => rd_data,
        rd => rd,
        wr_data => tx_data,
        wr => tx_wr,
        empty => tx_empty,
        full => tx_full,
        fill_level => open
    );

    uart_rx_inst : uart_rx
    generic map
    (
        CLK_DIVISOR => CLK_FREQ / BAUD_RATE
    )
    port map 
    (
        clk => clk,
        res_n => res_n,

        rx => rx_sync,

        new_data => new_data,
        data => wr_data
    );

    rx_fifo_inst : fifo_1c1r1w
    generic map
    (
        MIN_DEPTH => RX_FIFO_DEPTH,
        DATA_WIDTH => 8 
    )
    port map 
    (
        clk => clk,
        res_n => res_n,
        rd_data => rx_data,
        rd => rx_rd,
        wr_data => wr_data,
        wr => new_data,
        empty => rx_empty,
        full => rx_full,
        fill_level => open
    );
	
end architecture uart;

