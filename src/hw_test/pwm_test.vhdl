--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 21.08.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sync_pkg.all;
use work.debug_pkg.all;

use work.motor_pwm_pkg.all;

entity flight_controller_top is
  
    port
    (
        clk     : in  std_logic;
        leds    : out std_logic_vector(4 downto 0);
        buttons : in std_logic_vector(3 downto 0);
        pmoda   : inout std_logic_vector(7 downto 0);
        pmodb   : inout std_logic_vector(7 downto 0)
    );

end flight_controller_top;

architecture structure of flight_controller_top is
 
    constant SYS_CLK_FREQ   : natural := 50000000;
    constant BAUD_RATE      : natural := 9600;
    
    constant PWM_FREQ       : integer := 450;
    constant PWM_CHANNELS   : integer := 1;
    constant PWM_DC_RES     : integer := 16;

    signal res_n, ss_n, sclk, mosi, rx : std_logic;

    signal counter : natural range 0 to SYS_CLK_FREQ-1;
    signal led_state, imu_rdy : std_logic;

    signal new_dc : std_logic;
    signal dc : pwm_dc(0 to PWM_CHANNELS-1)(PWM_DC_RES-1 downto 0);
    signal pwm_out : std_logic_vector(PWM_CHANNELS-1 downto 0);

    component pwm is

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

    end component pwm;

begin

    -- TODO create debug mux between different modules

    sys_reset_sync : sync
    generic map 
    (
        SYNC_STAGES => 2,
        RESET_VALUE => '1'
    )
    port map 
    (
        clk => clk,
        res_n => '1',
        data_in => buttons(0),
        data_out => res_n
    );

    pwm_inst : pwm
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
        pwm => pwm_out
    );
  
    process(all) is
    begin
        
        if res_n = '0' then
            counter <= 0;
            led_state <= '1';
            new_dc <= '1';
            for i in 0 to PWM_CHANNELS-1 loop
                dc(i) <= to_unsigned(0, PWM_DC_RES);
            end loop;
        elsif rising_edge(clk) then
            if counter = SYS_CLK_FREQ-1 then
                led_state <= not led_state;
                counter <= 0;
                new_dc <= '1';
                for i in 0 to PWM_CHANNELS-1 loop
                    dc(i) <= dc(i) + 4095;
                end loop;
            else
                counter <= counter + 1;
                new_dc <= '0';
            end if;
        end if;

    end process;

    leds(0) <= led_state;
    leds(PWM_CHANNELS downto 1) <= pwm_out;

    pmodb(PWM_CHANNELS-1+4 downto 4) <= pwm_out;

end structure;

