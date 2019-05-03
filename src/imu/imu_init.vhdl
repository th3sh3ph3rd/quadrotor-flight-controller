--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 29.04.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.imu_spi_if.all;
use work.debug_pkg.all;

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
            done    : out std_logic; 
          
            -- communication interface for SPI
            reg_in  : out imu_reg_in;
            reg_out : in imu_reg_out;

            -- debug port
            dbg     : out debug_if
        );

end entity imu_init;

architecture behavior of imu_init is

    -- time constants
    constant RST_WAIT_CLKS : natural := CLK_FREQ/10; -- 100 ms

    -- fsm state
    type state_type is (IDLE, RST, WAITRST, WAKEUP, RD_WAI, FIN);
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
                if reg_out.finish = '1' then
                    state_next <= WAITRST;
                end if;

            when WAITRST =>
                if clk_cnt = RST_WAIT_CLKS-1 then
                    state_next <= WAKEUP;
                end if;

            when WAKEUP =>
                if reg_out.finish = '1' then
                    state_next <= RD_WAI;
                end if;

            when RD_WAI =>
                if reg_out.finish = '1' then
                    state_next <= FIN;
                end if;

            when FIN =>

        end case;
    end process next_state;
    
    output : process(all)
    begin
        done <= '0';

        reg_in.start <= '0';
        reg_in.rd_en <= '0';
        reg_in.addr <= (others => '0');
        reg_in.wr_data <= (others => '0');
        reg_in.rd_len <= 0;

        dbg.en <= '0';

        clk_cnt_next <= 0;

        case state is
            when IDLE =>

            when RST =>
                if clk_cnt = 0 then
                    reg_in.start <= '1';
                    reg_in.addr <= X"6B";
                    reg_in.wr_data <= X"80";
                end if;
                if reg_out.finish = '1' then
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
                    reg_in.start <= '1';
                    reg_in.addr <= X"6B";
                    reg_in.wr_data <= X"00";
                end if;
                if reg_out.finish = '1' then
                    clk_cnt_next <= 0;
                else
                    clk_cnt_next <= clk_cnt + 1;
                end if;

            when RD_WAI =>
                if clk_cnt = 0 then
                    reg_in.start <= '1';
                    reg_in.rd_en <= '1';
                    reg_in.addr <= X"75";
                    reg_in.rd_len <= 1;
                end if;
                if reg_out.rd_rdy = '1' then
                    dbg.en <= '1';
                    dbg.msg(0) <= reg_out.rd_data;
                    dbg.len <= 1;
                end if;
                if reg_out.finish = '1' then
                    clk_cnt_next <= 0;
                else
                    clk_cnt_next <= clk_cnt + 1;
                end if;

            when FIN =>
                done <= '1';

        end case;
    end process output;

end architecture behavior;

