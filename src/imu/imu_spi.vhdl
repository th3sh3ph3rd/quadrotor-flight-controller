--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 13.04.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.imu_spi_pkg.all;

entity imu_spi is

        generic
        (
            CLK_DIVISIOR : integer;
        );

        port
        (
            -- global synchronization
            clk     : in std_logic;
            res_n   : in std_logic;

            -- communication interface
            busy    : out std_logic;
            enable  : in std_logic;
            rx_en   : in std_logic;
            rx_rdy  : out std_logic;
            addr    : in std_logic_vector(7 downto 0);
            tx_data : in std_logic_vector(7 downto 0);
            rx_len  : in natural;
            rx_data : out std_logic_vector(7 downto 0);

            -- SPI
            scl     : out std_logic;
            cs_n    : out std_logic;
            sdo     : out std_logic;
            sdi     : in std_logic
        );

end entity imu_spi;

architecture beh of imu_spi is
    
    -- fsm state
    type SPI_STATE_TYPE is (IDLE, INIT, WRADDR, WRDATA);
    signal state            : SPI_STATE_TYPE;
    signal state_next       : SPI_STATE_TYPE;

    -- counters
    signal clk_cnt          : natural range 0 to CLK_DIVISOR-1;
    signal clk_cnt_next     : natural range 0 to CLK_DIVISOR-1;
    signal bit_cnt          : natural range 0 to 7;
    signal bit_cnt_next     : natural range 0 to 7;
    signal rx_cnt           : natural; --TODO can we impose a range limit? if yes, also change interface
    signal rx_cnt_next      : natural;

    -- buffers
    signal addr_buf         : std_logic_vector(7 downto 0);
    signal data_buf         : std_logic_vector(7 downto 0);
    signal len_buf          : natural;

begin

    sync : process(all)
    begin
        if res_n = '0' then
            state       <= IDLE;
            clk_cnt     <= 0;
            bit_cnt     <= 7;
            rx_cnt      <= 0;
            addr_buf    <= (others => '0');
            data_buf    <= (others => '0');
            len_buf     <= 0;
        elsif rising_edge(clk) then
            state       <= state_next;
            clk_cnt     <= clk_cnt_next;
            bit_cnt     <= bit_cnt_next;
            rx_cnt      <= rx_cnt_next;
            
            if clk_cnt = CLK_DIVISOR-1 or state = IDLE or state = INIT then
                clk_cnt <= 0;
            else
                clk_cnt <= clk_cnt + 1;
            end if;

            if enable = '1' then
                addr_buf <= addr;
                data_buf <= data;
                len_buf  <= 0;
            else
                addr_buf <= addr_buf;
                data_buf <= data_buf;
                len_buf  <= 0;
            end if;
        end if;
    end process;

    next_state : process(all)
    begin
        state_next <= state;

        case state is
            when IDLE =>
                if enable = '1' then
                    state_next <= INIT;
                end if;

            when INIT =>
                --TODO if we use 1MHz mode this has to be longer
                state_next <= WRADDR;

            when WRADDR =>
                if bit_cnt = 0 then
                    state_next = WRDATA;
                end if;

            when WRDATA =>
                if bit_cnt = 0 then
                    if rx_en = '1' then
                        if rx_cnt = len_buf then
                            state_next <= IDLE;
                        end if;
                    else
                        state_next <= IDLE;
                    end if;
                end if;

        end case;
    end process;

    output : process(all)
    begin
        busy    <= '1';
        rx_rdy  <= '0';
        rx_data <= (others => '0');
        scl     <= '1';
        cs_n    <= '1';
        sdo     <= 'Z'; --TODO tristate correct?
        
        clk_cnt_next <= 0;
        bit_cnt_next <= 7;
        rx_cnt_next  <= 0;

        case state is
            when IDLE =>
                busy <= '0';

            when INIT =>
                cs_n <= '0';

            when WRADDR =>
                if clk_cnt = CLK_DIVISOR-1 then
                    clk_cnt_next <= 0;
                    if bit_cnt = 0 then
                        bit_cnt_next <= 7;i
                    else
                        bit_cnt_next <= bit_cnt - 1;
                    end if;
                else
                    clk_cnt_next <= clk_cnt + 1;
                end if;

                if clk_cnt < CLK_DIVISOR/2 then
                    scl <= '0';
                end if;

                sdo <= addr_buf(bit_cnt);

            when WRDATA =>
                if clk_cnt = CLK_DIVISOR-1 then
                    clk_cnt_next <= 0;
                    if bit_cnt = 0 then
                        bit_cnt_next <= 7;
                        if rx_en = '1' then
                            rx_cnt_next <= rx_cnt + 1;
                            rx_rdy <= '1';
                        end if;
                    else
                        bit_cnt_next <= bit_cnt - 1;
                    end if;
                else
                    clk_cnt_next <= clk_cnt + 1;
                end if;

                if clk_cnt < CLK_DIVISOR/2 then
                    scl <= '0';
                end if;

                if rx_en = '1' then
                    sdo <= '0';
                    data_buf_next <= data_buf(6 downto 0) & sdi; --TODO maybe samble bits on clock transition
                else
                    sdo <= data_buf(bit_cnt);
                end if;

        end case;
    end process;

end architecture beh;

