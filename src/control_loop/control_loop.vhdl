--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 12.04.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.control_loop_pkg.all;

entity control_loop is

        port
        (
            -- global synchronization
            clk         : in std_logic;
            res_n       : in std_logic;

            -- state set values
            roll_set    : in imu_angle;
            pitch_set   : in imu_angle;
            yaw_set     : in imu_angle;
            
            -- state is values
            new_state   : in std_logic;
            roll_is     : in imu_angle;
            pitch_is    : in imu_angle;
            yaw_is      : in imu_angle;

            -- motor rpm values
            new_rpm     : out std_logic;
            m0_rpm      : out motor_rmp;
            m1_rpm      : out motor_rmp;
            m2_rpm      : out motor_rmp;
            m3_rpm      : out motor_rmp
        );

end entity control_loop;

architecture beh of control_loop is

    constant kp : natural := 1;
    constant kd : natural := 1;

    -- fsm state
    type state_type is (IDLE, CALC_TERMS, ADD_TERMS, CALC_RPM);
    signal state, state_next : state_type;

    type errors is record
        roll    : imu_angle;
        pitch   : imu_angle;
        yaw     : imu_angle;
    end record;
    signal err, err_next, err_prev, err_prev_next : errors; 
    
    type controller_terms is record
        p : std_logic_vector(15 downto 0);
        d : std_logic_vector(15 downto 0);
    end record;
    signal terms, terms_next : controller_terms;

begin
    
    sync : process(all)
    begin
        if res_n = '0' then
            state    <= IDLE;
            err      <= (others => '0', others => '0', others => '0');
            err_prev <= (others => '0', others => '0', others => '0');
            terms    <= (others => '0', others => '0');
        elsif rising_edge(clk) then
            state    <= state_next;
            err      <= err_next;
            err_prev <= err_prev_next;
            terms    <= terms_next;
        end if;
    end process sync;
    
    next_state : process(all)
    begin
        state_next <= state;

        case state is
            when IDLE =>
                if new_state = '1' then
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
                    if reg_in.rd_en = '1' then
                        buf_next.addr    <= '1' & reg_in.addr(6 downto 0); --apply read flag
                    else
                        buf_next.addr    <= reg_in.addr;
                    end if;
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

end architecture beh;

