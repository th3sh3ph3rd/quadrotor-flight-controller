--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 16.09.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sync_pkg.all;
use work.debug_pkg.all;

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

    -- fsm state
    type state_type is (INIT, UNARMED, ARMED);
    signal state, state_next : state_type; 
    signal counter : natural range 0 to SYS_CLK_FREQ-1;
    signal arm_wait : natural range 0 to 5;
    signal pid_step : natural range 0 to (SYS_CLK_FREQ/100)-1;
    signal angle : natural range 0 to 90;
    signal led0_state, led1_state : std_logic;

    signal res_n, ss_n, sclk, mosi, new_set, new_state, new_rpm_cl, new_rpm, imu_rdy : std_logic;
    signal roll, pitch, yaw : imu_angle;
    signal m0_rpm_cl, m1_rpm_cl, m2_rpm_cl, m3_rpm_cl : motor_rpm;
    signal m0_rpm, m1_rpm, m2_rpm, m3_rpm : motor_rpm;

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
        data_in => pmodb(1),
        data_out => ss_n
    );
    
    sclk_sync : sync
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
        data_out => sclk
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
        data_in => pmodb(0),
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
        sclk => sclk,
        mosi => mosi,
        miso => pmodb(3)
    );

    control_loop_inst : control_loop
    generic map
    (
        --hex notation
--        GAIN_P_ROLL  => X"1000", 
--        GAIN_I_ROLL  => X"1000",
--        GAIN_D_ROLL  => X"1000", 
--        GAIN_P_PITCH => X"1000", 
--        GAIN_I_PITCH => X"1000",
--        GAIN_D_PITCH => X"1000", 
--        GAIN_P_YAW   => X"1000", 
--        GAIN_I_YAW   => X"1000",
--        GAIN_D_YAW   => X"1000", 
--        THRUST_Z     => X"9AE2"
        GAIN_P_ROLL  => X"0000", 
        GAIN_I_ROLL  => X"0000",
        GAIN_D_ROLL  => X"0000", 
        GAIN_P_PITCH => X"0000", 
        GAIN_I_PITCH => X"0000",
        GAIN_D_PITCH => X"0000", 
        GAIN_P_YAW   => X"0000", 
        GAIN_I_YAW   => X"0000",
        GAIN_D_YAW   => X"0000", 
        THRUST_Z     => X"9AE2"
    )
    port map
    (
        clk => clk,         
        res_n => res_n,       
        new_set => new_set,
        roll_set => X"0000",
        pitch_set => X"0000",
        yaw_set => X"0000",
        new_state => new_state,
        roll_is => roll,
        pitch_is => pitch,
        yaw_is => yaw,
        new_rpm => new_rpm_cl,
        m0_rpm => m0_rpm_cl,
        m1_rpm => m1_rpm_cl,
        m2_rpm => m2_rpm_cl,
        m3_rpm => m3_rpm_cl
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
            counter <= 0;
            led0_state <= '1';
            state <= INIT;
            arm_wait <= 0;
        elsif rising_edge(clk) then
            state <= state_next;
            if counter = SYS_CLK_FREQ-1 then
                led0_state <= not led0_state;
                counter <= 0;
                arm_wait <= arm_wait + 1;
            else
                counter <= counter + 1;
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
                if arm_wait = 5 then
                    state_next <= ARMED;
                end if;

            when ARMED =>

        end case;

    end process;

    output : process(all)
    begin

        new_set <= '0';
        new_state <= '0';
        new_rpm <= new_rpm_cl;
        m0_rpm <= m0_rpm_cl;
        m1_rpm <= m1_rpm_cl;
        m2_rpm <= m2_rpm_cl;
        m3_rpm <= m3_rpm_cl;

        --physical output
        leds(0) <= led0_state;
        leds(1) <= led1_state;

        case state is
            when INIT =>
                new_set <= '1';
                new_state <= '1';

            when UNARMED =>
                new_rpm <= '1';
                m0_rpm <= std_logic_vector(to_unsigned(MIN_RPM, MOTOR_RPM_WIDTH));
                m1_rpm <= std_logic_vector(to_unsigned(MIN_RPM, MOTOR_RPM_WIDTH));
                m2_rpm <= std_logic_vector(to_unsigned(MIN_RPM, MOTOR_RPM_WIDTH));
                m3_rpm <= std_logic_vector(to_unsigned(MIN_RPM, MOTOR_RPM_WIDTH));

            when ARMED =>
                new_state <= imu_rdy;

        end case;

    end process;

end structure;

