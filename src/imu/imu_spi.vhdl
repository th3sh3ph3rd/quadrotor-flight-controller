--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 13.04.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.imu_spi_if.all;

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
            reg_in  : in imu_reg_in;
            reg_out : out imu_reg_out; 

            -- SPI
            spi_in  : in imu_spi_in;
            spi_out : out imu_spi_out
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
        rd_bytes : natural; --TODO can we impose a range limit? if yes, also change interface
    end record;
    signal cnt, cnt_next : counters;

    -- buffers
    type buffers is record
        addr   : std_logic_vector(7 downto 0);
        data   : std_logic_vector(7 downto 0);
        rd_len : natural;
    end record;
    signal buf, buf_next : buffers;

begin

    sync : process(all)
    begin
        if res_n = '0' then
            state        <= IDLE;
            cnt.clk      <= 0;
            cnt.bits     <= 7;
            cnt.rd_bytes <= 0;
            buf.addr     <= (others => '0');
            buf.data     <= (others => '0');
            buf.rd_len   <= 0;
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
                if reg_in.start = '1' then
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
                    if reg_in.rd_en = '1' then
                        if cnt.rd_bytes+1 = buf.rd_len then --TODO +1 is a dirty fix, maybe find nicer solution
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
        reg_out.finish  <= '0';
        reg_out.rd_rdy  <= '0';
        reg_out.rd_data <= buf.data;
        spi_out.scl     <= '1';
        spi_out.cs_n    <= '0';
        spi_out.sdo     <= 'Z'; --TODO tristate correct?
        
        cnt_next <= cnt;
        buf_next <= buf;

        case state is
            when IDLE =>
                spi_out.cs_n <= '1';
                if reg_in.start = '1' then
                    buf_next.addr    <= reg_in.addr;
                    buf_next.data    <= reg_in.wr_data;
                    buf_next.rd_len  <= reg_in.rd_len;
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
                    spi_out.scl <= '0';
                end if;

                spi_out.sdo <= buf.addr(cnt.bits);

            when WRDATA =>
                if cnt.clk = CLK_DIVISOR-1 then
                    cnt_next.clk <= 0;
                    if cnt.bits = 0 then
                        cnt_next.bits <= 7;
                        if reg_in.rd_en = '1' then
                            cnt_next.rd_bytes <= cnt.rd_bytes + 1;
                            reg_out.rd_rdy <= '1';
                            if cnt.rd_bytes+1 = buf.rd_len then --TODO +1 is a dirty fix, maybe find nicer solution
                                cnt_next.rd_bytes <= 0;
                                reg_out.finish <= '1';
                            end if;
                        else
                            reg_out.finish <= '1';
                        end if;
                    else
                        cnt_next.bits <= cnt.bits - 1;
                    end if;
                else
                    cnt_next.clk <= cnt.clk + 1;
                end if;

                if cnt.clk < CLK_DIVISOR/2 then
                    spi_out.scl <= '0';
                end if;

                if reg_in.rd_en = '1' then
                    spi_out.sdo <= '0'; -- write dummy bits on read
                    if cnt.clk = CLK_DIVISOR/2 then -- sample on clock transition
                        buf_next.data <= buf.data(6 downto 0) & spi_in.sdi;
                    end if;
                else
                    spi_out.sdo <= buf.data(cnt.bits);
                end if;

        end case;
    end process output;

end architecture behavior;

