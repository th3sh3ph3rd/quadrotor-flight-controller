--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 27.04.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.uart_pkg.all;
use work.debug_pkg.all;

entity debug is

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

end entity debug;

architecture beh of debug is

    type STATE_TYPE is (IDLE, WRITE, WRITE_NL, WAIT_UART);
    signal state, state_next : STATE_TYPE;

    type REGISTERS is record
        msg : debug_msg;
        len : debug_len;
        cnt : debug_len;
    end record;
    signal regs, regs_next : REGISTERS;

    signal tx_wr, tx_full : std_logic;
    signal tx_data        : std_logic_vector(7 downto 0);

begin

    uart_inst : uart
    generic map 
    (
        CLK_FREQ => CLK_FREQ,
        BAUD_RATE => BAUD_RATE,
        SYNC_STAGES => 2,
        TX_FIFO_DEPTH => 8,
        RX_FIFO_DEPTH => 8
    )
    port map
    (
        clk => clk,
        res_n => res_n,

        tx_data => tx_data,
        tx_wr => tx_wr,
        tx_full => tx_full,

        rx_data => open,
        rx_rd => '0',
        rx_full => open,
        rx_empty => open,

        tx => tx,
        rx => rx
    );
    
    sync : process(all) is
    begin

        if res_n = '0' then
            state       <= IDLE;
            regs.msg    <= (others => (others => '0'));
            regs.len    <= 0;
            regs.cnt    <= 0;
        elsif rising_edge(clk) then
            state <= state_next;
            regs  <= regs_next;
        end if;

    end process sync;

    next_state : process(all) is
    begin

        state_next <= state;

        case state is
            
            when IDLE =>
                if en = '1' then
                    state_next <= WAIT_UART;
                end if;

            when WRITE =>
                state_next <= WAIT_UART;

            when WRITE_NL =>
                state_next <= IDLE;

            when WAIT_UART =>
                if tx_full = '0' then
                    if regs.cnt = regs.len+1 then
                        state_next <= WRITE_NL; 
                    else
                        state_next <= WRITE;
                    end if;
                end if;

        end case;

    end process next_state;

    output : process(all) is
    begin

        regs_next <= regs;
        tx_data   <= (others => '0');
        tx_wr     <= '0';

        case state is
            
            when IDLE =>
                if en = '1' then
                    regs_next.msg <= msg;
                    regs_next.len <= len;
                end if;

            when WRITE =>
                tx_wr <= '1';
                tx_data <= regs.msg(regs.cnt);
                regs_next.cnt <= regs.cnt+1;

            when WRITE_NL =>
                tx_wr <= '1';
                tx_data <= X"0A"; --newline character
                regs_next.cnt <= 0;

            when WAIT_UART =>

        end case;

    end process output;

end architecture beh;

