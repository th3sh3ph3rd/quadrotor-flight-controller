--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 13.04.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- TODO create top module for abstract read/write and remove package
use work.imu_spi_pkg.all;

entity imu_spi is

        generic
        (
            CLK_DIVISOR : integer 
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

architecture behavior of imu_spi is
    
    -- fsm state
    type state_type is (IDLE, INIT, WRADDR, WRDATA);
    signal state, state_next : state_type;

    -- counters
    type counters is record
        clk      : natural range 0 to CLK_DIVISOR-1;
        bits     : natural range 0 to 7;
        rx_bytes : natural; --TODO can we impose a range limit? if yes, also change interface
    end record;
    signal cnt, cnt_next : counters;

    -- buffers
    type buffers is record
        addr   : std_logic_vector(7 downto 0);
        data   : std_logic_vector(7 downto 0);
        rx_len : natural;
    end record;
    signal buf, buf_next : buffers;

begin

    sync : process(all)
    begin
        if res_n = '0' then
            state        <= IDLE;
            cnt.clk      <= 0;
            cnt.bits     <= 7;
            cnt.rx_bytes <= 0;
            buf.addr     <= (others => '0');
            buf.data     <= (others => '0');
            buf.rx_len      <= 0;
        elsif rising_edge(clk) then
            state   <= state_next;
            cnt     <= cnt_next;
            buf     <= buf_next;
        end if;
    end process sync;

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
                if cnt.bits = 0 and cnt.clk = CLK_DIVISOR-1 then
                    state_next <= WRDATA;
                end if;

            when WRDATA =>
                if cnt.bits = 0 and cnt.clk = CLK_DIVISOR-1 then
                    if rx_en = '1' then
                        if cnt.rx_bytes+1 = buf.rx_len then --TODO +1 is a dirty fix, maybe find nicer solution
                            state_next <= IDLE;
                        end if;
                    else
                        state_next <= IDLE;
                    end if;
                end if;

        end case;
    end process next_state;

    output : process(all)
    begin
        busy    <= '1';
        rx_rdy  <= '0';
        rx_data <= buf.data;
        scl     <= '1';
        cs_n    <= '0';
        sdo     <= 'Z'; --TODO tristate correct?
        
        cnt_next <= cnt;
        buf_next <= buf;

        case state is
            when IDLE =>
                busy <= '0';
                cs_n <= '1';
                if enable = '1' then
                    buf_next.addr    <= addr;
                    buf_next.data    <= tx_data;
                    buf_next.rx_len  <= rx_len;
                end if;

            when INIT =>

            when WRADDR =>
                if cnt.clk = CLK_DIVISOR-1 then
                    cnt_next.clk <= 0;
                    if cnt.bits = 0 then
                        cnt_next.bits <= 7;
                    else
                        cnt_next.bits <= cnt.bits - 1;
                    end if;
                else
                    cnt_next.clk <= cnt.clk + 1;
                end if;

                if cnt.clk < CLK_DIVISOR/2 then
                    scl <= '0';
                end if;

                sdo <= buf.addr(cnt.bits);

            when WRDATA =>
                if cnt.clk = CLK_DIVISOR-1 then
                    cnt_next.clk <= 0;
                    if cnt.bits = 0 then
                        cnt_next.bits <= 7;
                        if rx_en = '1' then
                            cnt_next.rx_bytes <= cnt.rx_bytes + 1;
                            rx_rdy <= '1';
                        end if;
                    else
                        cnt_next.bits <= cnt.bits - 1;
                    end if;
                else
                    cnt_next.clk <= cnt.clk + 1;
                end if;

                if cnt.clk < CLK_DIVISOR/2 then
                    scl <= '0';
                end if;

                if rx_en = '1' then
                    sdo <= '0'; -- write dummy bits on read
                    if cnt.clk = CLK_DIVISOR/2 then -- sample on clock transition
                        buf_next.data <= buf.data(6 downto 0) & sdi;
                    end if;
                else
                    sdo <= buf.data(cnt.bits);
                end if;

        end case;
    end process output;

end architecture behavior;

