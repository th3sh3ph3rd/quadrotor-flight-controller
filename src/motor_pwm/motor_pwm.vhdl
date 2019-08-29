--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 12.04.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.motor_pwm_pkg.all;

entity motor_pwm is

    generic
    (
        SYS_CLK_FREQ : natural
    ); 
    port
    (
        -- global synchronization
        clk     : in std_logic;
        res_n   : in std_logic;

        -- motor rpm value
        new_rpm : in std_logic;
        rpm     : in motor_rpm;

        -- PWM output
        pwm_out : out std_logic 
    );

end entity motor_pwm;

architecture behavior of motor_pwm is

    constant PWM_FREQ       : natural := 400;
    constant PWM_CHANNELS   : natural := 1;
    constant PWM_DC_RES     : natural := 16;

    constant PWM_DC_LO      : natural := 29500;
    constant PWM_DC_HI      : natural := 49800;

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

    end component pwm;

begin
    
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
        new_dc => new_rpm,
        dc => dc,
        pwm(0) => pwm_out --hacky syntax
    );

    --motor speed saturation
    output : process(all)
    begin
        if unsigned(rpm) > to_unsigned(PWM_DC_HI, PWM_DC_RES) then
            dc(0) <= to_unsigned(PWM_DC_HI, PWM_DC_RES);
        elsif unsigned(rpm) < to_unsigned(PWM_DC_LO, PWM_DC_RES) then
            dc(0) <= to_unsigned(PWM_DC_LO, PWM_DC_RES);
        else
            dc(0) <= unsigned(rpm);
        end if;
    end process output;
    
end architecture behavior;

