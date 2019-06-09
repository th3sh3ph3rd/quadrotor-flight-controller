library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_tb is
end entity pwm_tb;

architecture tb of pwm_tb is

    constant SYS_CLK_FREQ   : integer := 50000000;
    constant SYS_CLK_PERIOD : time := 20 ns;
    constant PWM_FREQ       : integer := 100000; --100 KHz
    constant PWM_PERIOD     : time := 10 us;
    constant PWM_CHANNELS   : integer := 4;
    constant PWM_DC_RES     : integer := 16;

    signal clk, res_n : std_logic;

    signal new_dc : std_logic;
    signal dc     : array(0 to PWM_CHANNELS-1) of unsigned(PWM_DC_RES-1 downto 0);

    component pwm is
        generic
        (
            SYS_CLK_FREQ : integer,
            PWM_FREQ : integer,
            PWM_CHANNELS : integer,
            PWM_DC_RES : integer
        ); 
        port
        (
            -- global synchronization
            clk     : in std_logic;
            res_n   : in std_logic;

            -- PWM duty cycle
            new_dc  : in std_logic;
            dc      : in array(0 to PWM_CHANNELS-1) of unsigned(PWM_DC_RES-1 downto 0);

            -- PWM output
            pwm     : out std_logic_vector(PWM_CHANNELS-1 downto 0) 
        );
    end component;

begin

    UUT : pwm
    generic map
    (
        SYS_CLK_FREQ <= SYS_CLK_FREQ,
        PWM_FREQ <= PWM_FREQ,
        PWM_CHANNELS <= PWM_CHANNELS,
        PWM_DC_RES <= PWM_DC_RES
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
        for i in 0 to PWM_CHANNEL-1 loop
            dc(i) <= (others => '0');
        end loop;
        wait for SYS_CLK_PERIOD;
        res_n <= '1';
        wait for SYS_CLK_PERIOD;
        
        new_dc <= '1';
        for i in 0 to PWM_CHANNEL-1 loop
            dc(i) <= (2**PWM_DC_RES)/2;
        end loop;
        wait for SYS_CLK_PERIOD;
        new_dc <= '0';
        wait for 4*PWM_PERIOD;


        -- roll
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        wait for SPI_CLK_PERIOD;
        
        -- pitch
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        wait for SPI_CLK_PERIOD;
        
        -- yaw
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        mosi <= '0';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '1';
        wait for SPI_CLK_PERIOD/2;
        sclk <= '0';
        wait for SPI_CLK_PERIOD;
        
        ss_n <= '1';

        wait;
    end process stimulus;

end architecture tb;

