--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 21.01.2020
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sync_pkg.all;
use work.debug_pkg.all;

use work.fp_pkg.all;
use work.imu_pkg.all;
use work.control_loop_pkg.all;
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
    
    constant PWM_FREQ       : natural := 400;
    constant PWM_CHANNELS   : natural := 1;
    constant PWM_DC_RES     : natural := 16;

    constant LED_OFF        : std_logic := '1';
    constant LED_ON         : std_logic := '0';

    -- fsm state
    type state_type is (INIT, UNARMED, ARMED);
    signal state, state_next : state_type; 
    signal clk_cnt : natural range 0 to SYS_CLK_FREQ/1000-1;
    signal ms_cnt : natural range 0 to 9;
    signal hs_cnt : natural range 0 to 9;
    signal ts_cnt : natural range 0 to 9;
    signal pid_step : natural range 0 to (SYS_CLK_FREQ/100)-1;
    signal angle : natural range 0 to 90;
    signal led0_state, led1_state : std_logic;

    signal res_n, arm_button_n, arm_old_n, arm_n, new_rpm, inc, inc_next : std_logic;
    signal m0_rpm, m1_rpm, m2_rpm, m3_rpm : motor_rpm;
    signal rpm, rpm_next : natural range 0 to MAX_RPM;

begin

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
    
    arm_button_sync : sync
    generic map 
    (
        SYNC_STAGES => 2,
        RESET_VALUE => '1'
    )
    port map 
    (
        clk => clk,
        res_n => '1',
        data_in => buttons(1),
        data_out => arm_button_n
    );
     
    m0 : motor_pwm
    generic map
    (
        SYS_CLK_FREQ => SYS_CLK_FREQ
    )
    port map
    (
        clk => clk,
        res_n => res_n,
        new_rpm => new_rpm,
        rpm => m0_rpm,
        pwm_out => pmodb(4)
    );
    
    m1 : motor_pwm
    generic map
    (
        SYS_CLK_FREQ => SYS_CLK_FREQ
    )
    port map
    (
        clk => clk,
        res_n => res_n,
        new_rpm => new_rpm,
        rpm => m1_rpm,
        pwm_out => pmodb(5) 
    );
    
    m2 : motor_pwm
    generic map
    (
        SYS_CLK_FREQ => SYS_CLK_FREQ
    )
    port map
    (
        clk => clk,
        res_n => res_n,
        new_rpm => new_rpm,
        rpm => m2_rpm,
        pwm_out => pmodb(6)
    );
    
    m3 : motor_pwm
    generic map
    (
        SYS_CLK_FREQ => SYS_CLK_FREQ
    )
    port map
    (
        clk => clk,
        res_n => res_n,
        new_rpm => new_rpm,
        rpm => m3_rpm,
        pwm_out => pmodb(7)
    );

    sync : process(all) is
    begin
        
        if res_n = '0' then
            clk_cnt <= 0;
            hs_cnt <= 0;
            ts_cnt <= 0;
            led0_state <= LED_OFF;
            led0_state <= LED_OFF;
            state <= INIT;
            arm_n <= '1';
            arm_old_n <= '1';
            rpm <= MIN_RPM;
            inc <= '0';
        elsif rising_edge(clk) then
            state <= state_next;
            arm_n <= arm_button_n;
            arm_old_n <= arm_n;
            rpm <= rpm_next;
            inc <= inc_next;
            if clk_cnt = SYS_CLK_FREQ/1000-1 then -- 1ms
                clk_cnt <= 0;
                if ms_cnt = 9 then -- 1 hundreth sec
                    ms_cnt <= 0;
                    if hs_cnt = 9 then -- 1 tenth sec
                        led1_state <= not led1_state; 
                        hs_cnt <= 0;
                        if ts_cnt = 9 then -- 1 sec
                            led0_state <= not led0_state;
                            ts_cnt <= 0;
                        else
                            ts_cnt <= ts_cnt + 1;
                        end if;
                    else
                        hs_cnt <= hs_cnt + 1;
                    end if;
                else
                    ms_cnt <= ms_cnt + 1;
                end if;
            else
                clk_cnt <= clk_cnt + 1;
            end if;
        end if;

    end process;

    next_state : process(all)
    begin

        state_next <= state;

        case state is
            when INIT =>
                state_next <= UNARMED;

            when UNARMED =>
                if arm_old_n = '0' and arm_n = '1' then
                    state_next <= ARMED;
                end if;

            when ARMED =>
                if arm_old_n = '0' and arm_n = '1' then
                    state_next <= UNARMED;
                end if;

        end case;

    end process;

    output : process(all)
    begin

        new_rpm <= '0';
        m0_rpm <= (others => '0'); 
        m1_rpm <= (others => '0'); 
        m2_rpm <= (others => '0'); 
        m3_rpm <= (others => '0'); 

        --physical output
        leds(0) <= led0_state;
        leds(1) <= LED_OFF;
        leds(2) <= inc;

        rpm_next <= rpm;
        inc_next <= inc;

        case state is
            when INIT =>
                rpm_next <= MIN_RPM;

            when UNARMED =>
                new_rpm <= '1';
                rpm_next <= MIN_RPM;
                inc_next <= '1';

            when ARMED =>
                leds(1) <= led1_state;
                if ms_cnt = 9 and clk_cnt = SYS_CLK_FREQ/1000-1 then -- 1 hundreth sec
                    new_rpm <= '1';
                    if inc = '1' then
                        rpm_next <= rpm + 10;
                        if rpm >= MAX_RPM then
                            inc_next <= '0';
                        end if;
                    else
                        rpm_next <= rpm - 10;
                        if rpm <= MIN_RPM then
                            inc_next <= '1';
                        end if;
                    end if;
                end if;

        end case;
                
        m0_rpm <= std_logic_vector(to_unsigned(rpm, MOTOR_RPM_WIDTH));
        m1_rpm <= std_logic_vector(to_unsigned(rpm, MOTOR_RPM_WIDTH));
        m2_rpm <= std_logic_vector(to_unsigned(rpm, MOTOR_RPM_WIDTH));
        m3_rpm <= std_logic_vector(to_unsigned(rpm, MOTOR_RPM_WIDTH));

    end process;

end structure;

