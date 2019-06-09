--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 09.06.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.motor_pwm_pkg.all;

entity pwm is

        generic
        (
            SYS_CLK_FREQ : integer;
            PWM_FREQ : integer;
            PWM_CHANNELS : integer;
            PWM_DC_RES : integer
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

    constant PWM_CLKS : integer := SYS_CLK_FREQ / PWM_FREQ;
    signal cnt, cnt_next : integer range 0 to PWM_CLKS-1;
    signal dc_buf, dc_buf_next : pwm_dc(0 to PWM_CHANNELS-1)(PWM_DC_RES-1 downto 0);

    type dc_cnt is array(0 to PWM_CHANNELS) of integer range 0 to (2**PWM_DC_RES)-1;
    signal dc_mid, dc_mid_next : dc_cnt;
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
                dc_mid_next(i) <= to_integer(dc_buf(i))*PWM_CLKS/(2**PWM_DC_RES);
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


