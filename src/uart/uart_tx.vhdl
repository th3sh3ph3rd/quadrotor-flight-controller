--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 23.04.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is 

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

end entity uart_tx;

architecture beh of uart_tx is
	
    type TRANSMITTER_STATE_TYPE is (IDLE, NEW_DATA, SEND_START_BIT, TRANSMIT_FIRST, TRANSMIT, TRANSMIT_NEXT, TRANSMIT_STOP_NEXT, TRANSMIT_STOP);

    signal transmitter_state : TRANSMITTER_STATE_TYPE;
    signal transmitter_state_next : TRANSMITTER_STATE_TYPE; 

        --clock cycle counter
    signal clk_cnt : integer range 0 to CLK_DIVISOR;
    signal clk_cnt_next : integer range 0 to CLK_DIVISOR;

        --bit counter
    signal bit_cnt : integer range 0 to 7;
    signal bit_cnt_next : integer range 0 to 7;


    signal transmit_data : std_logic_vector(7 downto 0); -- buffer for the current byte
    signal transmit_data_next : std_logic_vector(7 downto 0);

begin

    --------------------------------------------------------------------
    --                    PROCESS : SYNC                              --
    --------------------------------------------------------------------

    sync : process(res_n, clk)
    begin
        if res_n = '0' then
            transmitter_state <= IDLE;
            clk_cnt <= 0;
        elsif rising_edge(clk) then
            transmitter_state <= transmitter_state_next;
            clk_cnt <= clk_cnt_next;
            bit_cnt <= bit_cnt_next;
            transmit_data <= transmit_data_next;
        end if;
    end process;


    --------------------------------------------------------------------
    --                    PROCESS : NEXT_STATE                        --
    --------------------------------------------------------------------

    next_state : process(clk_cnt, bit_cnt, transmitter_state, empty)
    begin
        transmitter_state_next <= transmitter_state; --default

        case transmitter_state is

            when IDLE =>
                if empty = '0' then --check if the fifo is empty
                    transmitter_state_next <= NEW_DATA;
                end if;

            when NEW_DATA =>
                transmitter_state_next <= SEND_START_BIT;

            when SEND_START_BIT => 
                                --check if the bittime is over
                if clk_cnt = CLK_DIVISOR - 2 then 
                    transmitter_state_next <= TRANSMIT_FIRST;
                end if;

            when TRANSMIT_FIRST =>
                transmitter_state_next <= TRANSMIT;

            when TRANSMIT =>
                if clk_cnt = CLK_DIVISOR - 2 and bit_cnt < 7 then 
                    transmitter_state_next <= TRANSMIT_NEXT;
                elsif clk_cnt = CLK_DIVISOR - 2 then
                    transmitter_state_next <= TRANSMIT_STOP_NEXT;
                end if;

            when TRANSMIT_NEXT =>
                transmitter_state_next <= TRANSMIT;

            when TRANSMIT_STOP_NEXT =>
                transmitter_state_next <= TRANSMIT_STOP;

            when TRANSMIT_STOP =>
                if clk_cnt = CLK_DIVISOR - 2 and empty = '0' then
                    transmitter_state_next <= NEW_DATA;
                elsif clk_cnt = CLK_DIVISOR - 2 then
                    transmitter_state_next <= IDLE;
                end if;
        end case;
    end process;


    --------------------------------------------------------------------
    --                    PROCESS : OUTPUT                            --
    --------------------------------------------------------------------
  
    output : process(clk_cnt, bit_cnt, transmitter_state, transmit_data, data)
    begin

        transmit_data_next <= transmit_data;
        clk_cnt_next <= clk_cnt;
        bit_cnt_next <= bit_cnt;
        rd <= '0';
        tx <= '1';	-- the idle state of the tx output is high


        case transmitter_state is

            when IDLE =>
                        --do nothing
            when NEW_DATA =>
                                -- set rd to read the next byte from the fifo, 
                                -- rd is reset automaticly by the default assignment, when the next state is entered
                rd <= '1';
                clk_cnt_next <= 0; --reset counter 

            when SEND_START_BIT => 
                tx <= '0'; --send start bit, low --> automatic reset by default assignment 
                clk_cnt_next <= clk_cnt + 1;

            when TRANSMIT_FIRST =>
                clk_cnt_next <= 0; -- reset clk counter
                transmit_data_next <= data; --read databyte from fifo
                bit_cnt_next <= 0;  
                tx <= '0'; --we are still sending the start bit!

            when TRANSMIT =>
                clk_cnt_next <= clk_cnt + 1;
                tx <= transmit_data(0);		--send bit

            when TRANSMIT_NEXT =>
                clk_cnt_next <= 0;
                bit_cnt_next <= bit_cnt + 1; --update bit counter
                tx <= transmit_data(0);		--still sending the last bit
                transmit_data_next(6 downto 0) <= transmit_data(7 downto 1); -- shift transmitt_data
                                                                             -- srl shift right logical

            when TRANSMIT_STOP_NEXT =>
                clk_cnt_next <= 0;	--reset clk counter
                tx <= transmit_data(0); --still sending the last bit

            when TRANSMIT_STOP =>
                clk_cnt_next <= clk_cnt + 1; --update bit counter
                                             -- the level of the stopbit is high, set automaticly by the default assignment  

        end case;

    end process;

end architecture uart_tx;

