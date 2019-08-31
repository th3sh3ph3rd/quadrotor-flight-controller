--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 28.08.2019
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
    signal led_state : std_logic;

    signal res_n, new_set, new_state, new_rpm_cl, new_rpm : std_logic;
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

    control_loop_inst : control_loop
    generic map
    (
        --hex notation
        GAIN_P_ROLL  => X"0006", 
        GAIN_I_ROLL  => X"0002",
        GAIN_D_ROLL  => X"0002", 
        GAIN_P_PITCH => X"0006", 
        GAIN_I_PITCH => X"0002",
        GAIN_D_PITCH => X"0002", 
        GAIN_P_YAW   => X"0006", 
        GAIN_I_YAW   => X"0002",
        GAIN_D_YAW   => X"0002", 
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
        pwm_out => open 
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
        pwm_out => open 
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
        pwm_out => open 
    );

    sync : process(all) is
    begin
        
        if res_n = '0' then
            counter <= 0;
            led_state <= '1';
            state <= INIT;
            arm_wait <= 0;
            pid_step <= 0;
            angle <= 0;
        elsif rising_edge(clk) then
            state <= state_next;
            if counter = SYS_CLK_FREQ-1 then
                led_state <= not led_state;
                counter <= 0;
                arm_wait <= arm_wait + 1;
            else
                counter <= counter + 1;
            end if;
            if pid_step = (SYS_CLK_FREQ/100)-1 then
                pid_step <= 0;
                if angle = 90 then
                    angle <= 0;
                else
                    angle <= angle + 1;
                end if;
            else
                pid_step <= pid_step + 1;
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
        roll <= X"0000";
        pitch <= X"0000";
        yaw <= X"0000";
        new_rpm <= new_rpm_cl;
        m0_rpm <= m0_rpm_cl;
        m1_rpm <= m1_rpm_cl;
        m2_rpm <= m2_rpm_cl;
        m3_rpm <= m3_rpm_cl;

        --physical output
        leds(0) <= led_state;
        --leds(PWM_CHANNELS downto 1) <= pwm_out;
        --pmodb(PWM_CHANNELS-1+4 downto 4) <= pwm_out;

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
                if pid_step = (SYS_CLK_FREQ/100)-1 then
                    new_set <= '1';
                    new_state <= '1';
                    pitch <= std_logic_vector(to_signed(90 - angle, IMU_ANGLE_WIDTH));
                end if;

        end case;

    end process;

end structure;

