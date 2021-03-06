library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.motor_pwm_pkg.all;

entity pwm_tb is
end entity pwm_tb;

architecture tb of pwm_tb is

    constant SYS_CLK_FREQ   : natural := 50000000;
    constant SYS_CLK_PERIOD : time := 20 ns;
    constant PWM_FREQ       : natural := 400; --1 MHz
    constant PWM_PERIOD     : time := 2500 us;
--    constant PWM_FREQ       : natural := 1000000; --1 MHz
--    constant PWM_PERIOD     : time := 1 us;
    constant PWM_CHANNELS   : natural := 4;
    constant PWM_DC_RES     : natural := 16;

    signal clk, res_n : std_logic;

    signal new_dc : std_logic; 
    signal dc : pwm_dc(0 to PWM_CHANNELS-1)(PWM_DC_RES-1 downto 0);

    component pwm is
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
    end component;

begin

    UUT : pwm
    generic map
    (
        SYS_CLK_FREQ => SYS_CLK_FREQ,
        PWM_FREQ => PWM_FREQ,
        PWM_CHANNELS => PWM_CHANNELS,
        PWM_DC_RES => PWM_DC_RES
    )
    port map
    (
        clk => clk,
        res_n => res_n,
        new_dc => new_dc,
        dc => dc,
        pwm => open
    );

    clk_gen : process
    begin
        clk <= '1';
        wait for SYS_CLK_PERIOD/2;
        clk <= '0';
        wait for SYS_CLK_PERIOD/2;
    end process clk_gen;

    stimulus : process
    begin
        res_n <= '0';
        new_dc <= '0';
        for i in 0 to PWM_CHANNELS-1 loop
            dc(i) <= (others => '0');
        end loop;
        wait for SYS_CLK_PERIOD;
        res_n <= '1';
        wait for SYS_CLK_PERIOD;
       
        -- 50% dc for all channels
        new_dc <= '1';
        for i in 0 to PWM_CHANNELS-1 loop
            dc(i) <= to_unsigned((2**PWM_DC_RES)/2, PWM_DC_RES);
        end loop;
        wait for SYS_CLK_PERIOD;
        new_dc <= '0';
        wait for 4*PWM_PERIOD;

        -- 0% dc for all channels
        new_dc <= '1';
        for i in 0 to PWM_CHANNELS-1 loop
            dc(i) <= to_unsigned(0, PWM_DC_RES);
        end loop;
        wait for SYS_CLK_PERIOD;
        new_dc <= '0';
        wait for PWM_PERIOD;
        
        -- 10% dc for all channels
        new_dc <= '1';
        for i in 0 to PWM_CHANNELS-1 loop
            dc(i) <= to_unsigned((2**PWM_DC_RES)/10, PWM_DC_RES);
        end loop;
        wait for SYS_CLK_PERIOD;
        new_dc <= '0';
        wait for 4*PWM_PERIOD;
        
        -- 100% dc for all channels
        new_dc <= '1';
        for i in 0 to PWM_CHANNELS-1 loop
            dc(i) <= to_unsigned((2**PWM_DC_RES)-1, PWM_DC_RES);
        end loop;
        wait for SYS_CLK_PERIOD;
        new_dc <= '0';
        wait for PWM_PERIOD;
        
        -- different dc for each channel
        new_dc <= '1';
        dc(0) <= to_unsigned((2**PWM_DC_RES)/4, PWM_DC_RES);
        dc(1) <= to_unsigned((2**PWM_DC_RES)/5, PWM_DC_RES);
        dc(2) <= to_unsigned((2**PWM_DC_RES)/3, PWM_DC_RES);
        dc(3) <= to_unsigned((2**PWM_DC_RES)/7, PWM_DC_RES);
        wait for SYS_CLK_PERIOD;
        new_dc <= '0';
        wait for PWM_PERIOD;
        
        wait;
    end process stimulus;

end architecture tb;

