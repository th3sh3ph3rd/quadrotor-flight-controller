--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 09.06.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.motor_pwm_pkg.all;

entity pwm is

        generic
        (
            SYS_CLK_FREQ : natural;
            PWM_FREQ : natural;
            PWM_CHANNELS : natural;
            PWM_DC_RES : natural
        ); 
        port
        (
            -- global synchronization
            clk     : in std_logic;
            res_n   : in std_logic;

            -- PWM duty cycle
            new_dc  : in std_logic;
            dc      : in pwm_dc(0 to PWM_CHANNELS-1)(PWM_DC_RES-1 downto 0);

            -- PWM output
            pwm     : out std_logic_vector(PWM_CHANNELS-1 downto 0) 
        );

end entity pwm;

architecture behavior of pwm is

    constant PWM_CLKS : natural := SYS_CLK_FREQ / PWM_FREQ;
    signal cnt, cnt_next : natural range 0 to PWM_CLKS-1;
    signal dc_buf, dc_buf_next : pwm_dc(0 to PWM_CHANNELS-1)(PWM_DC_RES-1 downto 0);

    type dc_cnt is array(0 to PWM_CHANNELS) of natural range 0 to PWM_CLKS-1;
    signal dc_mid, dc_mid_next : dc_cnt;
    --type mul is array(0 to PWM_CHANNELS) of natural range 0 to (((2**PWM_DC_RES)-1)*124999); --account for multiplication overflow
    --constant MAX_MUL_BITS : natural := natural(ceil(log2(real(((2**PWM_DC_RES)-1)*(PWM_CLKS-1))))); 
    type mul is array(0 to PWM_CHANNELS-1) of unsigned(33 downto 0); --account for multiplication overflow
    signal mul_tmp : mul;

begin
    
    sync : process(all)
    begin
        if res_n = '0' then
            cnt <= 0;
            for i in 0 to PWM_CHANNELS-1 loop
                dc_buf(i) <= (others => '0');
                dc_mid(i) <= 0;
            end loop;
        elsif rising_edge(clk) then
            cnt <= cnt_next;
            dc_buf <= dc_buf_next;
            dc_mid <= dc_mid_next;
        end if;
    end process sync;
    
    output : process(all)
    begin
        cnt_next <= cnt;
        dc_buf_next <= dc_buf;
        dc_mid_next <= dc_mid;

        if new_dc = '1' then
            dc_buf_next <= dc;
        end if;

        if cnt = PWM_CLKS-1 then
            cnt_next <= 0;
            for i in 0 to PWM_CHANNELS-1 loop
                mul_tmp(i) <= dc_buf(i)*to_unsigned(PWM_CLKS, 18); --account for overflow
                dc_mid_next(i) <= to_integer(mul_tmp(i)/(2**PWM_DC_RES));
--                mul_tmp(i) <= to_integer(dc_buf(i))*PWM_CLKS; --account for overflow
--                dc_mid_next(i) <= mul_tmp(i)/(2**PWM_DC_RES);
--                dc_mid_next(i) <= to_integer(to_unsigned(mul_tmp(i), 2**PWM_DC_RES-1));
--                dc_mid_next(i) <= to_integer(dc_buf(i))*PWM_CLKS/(2**PWM_DC_RES);
            end loop;
        else
            cnt_next <= cnt + 1;
        end if;

        for i in 0 to PWM_CHANNELS-1 loop
            if cnt < dc_mid(i) then
                pwm(i) <= '1';
            else
                pwm(i) <= '0';
            end if;
        end loop;
    end process output;

end architecture behavior;

