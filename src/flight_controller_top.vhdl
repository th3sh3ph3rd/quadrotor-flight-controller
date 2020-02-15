--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 22.01.2020
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
    signal led0_state, led1_state : std_logic;

    signal res_n, arm_button_n, arm_old_n, arm_n, inc, inc_next : std_logic;
    signal ss_n, sclk, mosi : std_logic;
    signal new_set, new_state, new_rpm_cl, new_rpm, imu_rdy : std_logic;
    signal roll, pitch, yaw : FP_T;
    signal mfcw_rpm_cl, mfccw_rpm_cl, mrcw_rpm_cl, mrccw_rpm_cl : motor_rpm;
    signal mfcw_rpm, mfccw_rpm, mrcw_rpm, mrccw_rpm : motor_rpm;
    signal rpm_next : natural range 0 to MAX_RPM;

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
    
    slave_select_sync : sync
    generic map 
    (
        SYNC_STAGES => 2,
        RESET_VALUE => '1'
    )
    port map 
    (
        clk => clk,
        res_n => '1',
        data_in => pmodb(3),
        data_out => ss_n
    );
    
    mosi_sync : sync
    generic map 
    (
        SYNC_STAGES => 2,
        RESET_VALUE => '1'
    )
    port map 
    (
        clk => clk,
        res_n => '1',
        data_in => pmodb(2),
        data_out => mosi
    );
    
    imu_inst : imu
    port map
    (
        clk => clk,    
        res_n => res_n,
        imu_rdy => imu_rdy,
        roll => roll,
        pitch => pitch,
        yaw => yaw,
        ss_n => ss_n, 
        sclk => pmodb(0),
        mosi => mosi,
        miso => pmodb(1)
    );

    control_loop_inst : control_loop
    generic map
    (

        THRUST_Z     => std_logic_vector(to_signed(MIN_RPM+(MAX_RPM-MIN_RPM)/2-(MAX_RPM-MIN_RPM)/16, MOTOR_RPM_WIDTH))
        --THRUST_Z     => std_logic_vector(to_signed(MIN_RPM+(MAX_RPM-MIN_RPM)/4+(MAX_RPM-MIN_RPM)/16+(MAX_RPM-MIN_RPM)/32+(MAX_RPM-MIN_RPM)/128+(MAX_RPM-MIN_RPM)/256, MOTOR_RPM_WIDTH))
        --THRUST_Z     => std_logic_vector(to_signed(MIN_RPM+(MAX_RPM-MIN_RPM)/4+(MAX_RPM-MIN_RPM)/16+(MAX_RPM-MIN_RPM)/32+(MAX_RPM-MIN_RPM)/64+(MAX_RPM-MIN_RPM)/128+(MAX_RPM-MIN_RPM)/128, MOTOR_RPM_WIDTH))
    )
    port map
    (
        clk => clk,         
        res_n => res_n,       
        new_set => new_set,
        roll_set => int2fp(0),
        pitch_set => int2fp(0),
        yaw_set => int2fp(0),
        new_state => imu_rdy,
        roll_is => roll,
        pitch_is => pitch,
        yaw_is => yaw,
        new_rpm => new_rpm_cl,
        m0_rpm => mfcw_rpm_cl,
        m1_rpm => mfccw_rpm_cl,
        m2_rpm => mrcw_rpm_cl,
        m3_rpm => mrccw_rpm_cl
    );
     
    mfcw : motor_pwm
    generic map
    (
        SYS_CLK_FREQ => SYS_CLK_FREQ
    )
    port map
    (
        clk => clk,
        res_n => res_n,
        new_rpm => new_rpm,
        rpm => mfcw_rpm,
        pwm_out => pmodb(4)
    );
    
    mfccw : motor_pwm
    generic map
    (
        SYS_CLK_FREQ => SYS_CLK_FREQ
    )
    port map
    (
        clk => clk,
        res_n => res_n,
        new_rpm => new_rpm,
        rpm => mfccw_rpm,
        pwm_out => pmodb(6) 
    );
    
    mrcw : motor_pwm
    generic map
    (
        SYS_CLK_FREQ => SYS_CLK_FREQ
    )
    port map
    (
        clk => clk,
        res_n => res_n,
        new_rpm => new_rpm,
        rpm => mrcw_rpm,
        pwm_out => pmodb(7)
    );
    
    mrccw : motor_pwm
    generic map
    (
        SYS_CLK_FREQ => SYS_CLK_FREQ
    )
    port map
    (
        clk => clk,
        res_n => res_n,
        new_rpm => new_rpm,
        rpm => mrccw_rpm,
        pwm_out => pmodb(5)
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
            inc <= '0';
        elsif rising_edge(clk) then
            state <= state_next;
            arm_n <= arm_button_n;
            arm_old_n <= arm_n;
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

    fsm : process(all)
    begin
        state_next <= state;

        new_set     <= '0';

        new_rpm     <= '0';
        mfcw_rpm    <= std_logic_vector(to_unsigned(MIN_RPM, MOTOR_RPM_WIDTH)); 
        mfccw_rpm   <= std_logic_vector(to_unsigned(MIN_RPM, MOTOR_RPM_WIDTH)); 
        mrcw_rpm    <= std_logic_vector(to_unsigned(MIN_RPM, MOTOR_RPM_WIDTH)); 
        mrccw_rpm   <= std_logic_vector(to_unsigned(MIN_RPM, MOTOR_RPM_WIDTH)); 

        --physical output
        leds(0) <= led0_state;
        leds(1) <= LED_OFF;

        case state is
            when INIT =>
                new_set <= '1';
                state_next <= UNARMED;

            when UNARMED =>
                new_rpm <= '1';
                if arm_old_n = '0' and arm_n = '1' then
                    state_next <= ARMED;
                end if;

            when ARMED =>
                leds(1) <= led1_state;
                new_rpm <= new_rpm_cl;
                mfcw_rpm <= mfcw_rpm_cl; 
                mfccw_rpm <= mfccw_rpm_cl; 
                mrcw_rpm <= mrcw_rpm_cl; 
                mrccw_rpm <= mrccw_rpm_cl; 
                if arm_old_n = '0' and arm_n = '1' then
                    state_next <= UNARMED;
                end if;

        end case; 

    end process;

end structure;

