--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 29.04.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity imu_init is

        generic
        (
            CLK_FREQ : integer 
        ); 
        port
        (
            -- global synchronization
            clk     : in std_logic;
            res_n   : in std_logic;

            -- init signals
            init    : in std_logic;
            done    : out std_logic 
           
            -- communication interface for SPI
            spi_en  : out std_logic;
            spi_fin : in std_logic;
            rx_en   : out std_logic;
            rx_rdy  : in std_logic;
            addr    : out std_logic_vector(7 downto 0);
            tx_data : out std_logic_vector(7 downto 0);
            rx_len  : out natural;
            rx_data : in std_logic_vector(7 downto 0);
        );

end entity imu_init;

architecture behavior of imu_init is

    -- time constants
    constant RST_WAIT_CLKS : natural := CLK_FREQ/10; -- 100 ms

    -- fsm state
    type state_type is (IDLE, RST, WAITRST, WAKEUP, RD_WAI, DONE);
    signal state, state_next : state_type;

    -- clock counter
    signal clk_cnt, clk_cnt_next : natural;

begin

    sync : process(all)
    begin
        if res_n = '0' then
            state   <= IDLE;
            clk_cnt <= 0;
        elsif rising_edge(clk) then
            state   <= state_next;
            clk_cnt <= clk_cnt_next;
        end if; 
    end process sync;
    
    next_state : process(all)
    begin
        state_next <= state;

        case state is
            when IDLE =>
                if init = '1' then
                    state_next <= RST;
                end if;

            when RST =>
                if spi_fin = '1' then
                    state_next = WAITRST;
                end if;

            when WAITRST =>
                if clk_cnt = RST_WAIT_CLKS-1 then
                    state_next <= WAKEUP;
                end if;

            when WAKEUP =>
                if spi_fin = '1' then
                    state_next = RD_WAI;
                end if;

            when RD_WAI =>

            when DONE =>

        end case;
    end process next_state;
    
    output : process(all)
    begin
        done <= '0';
        spi_en <= '0';
        rx_en <= '0';
        addr <= (others => '0');
        tx_data <= (others => '0');
        rx_len <= 0;

        clk_cnt_next <= 0;

        case state is
            when IDLE =>

            when RST =>
                if clk_cnt = 0 then
                    spi_en <= '1';
                    addr <= X"6B";
                    tx_data <= X"80";
                end if;
                if spi_fin = '1' then
                    clk_cnt_next <= 0;
                else
                    clk_cnt_next <= clk_cnt + 1;
                end if;

            when WAITRST =>
                if clk_cnt = RST_WAIT_CLKS-1 then
                    clk_cnt_next <= 0;
                else
                    clk_cnt_next <= clk_cnt + 1;
                end if; 
            
            when WAKEUP =>
                if clk_cnt = 0 then
                    spi_en <= '1';
                    addr <= X"6B";
                    tx_data <= X"00";
                end if;
                if spi_fin = '1' then
                    clk_cnt_next <= 0;
                else
                    clk_cnt_next <= clk_cnt + 1;
                end if;

            when RD_WAI =>
                if clk_cnt = 0 then
                    spi_en <= '1';
                    rx_en <= '1';
                    addr <= X"6B";
                    rx_len <= 1;
                end if;
                if rx_rdy = '1' then

                end if;
                if spi_fin = '1' then
                    clk_cnt_next <= 0;
                else
                    clk_cnt_next <= clk_cnt + 1;
                end if;

            when DONE =>
                done <= '1';

        end case;
    end process output;

end architecture behavior;

