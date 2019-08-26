--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 12.04.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.motor_pwm_pkg.all;

entity motor_pwm is

    port
    (
        -- global synchronization
        clk     : in std_logic;
        res_n   : in std_logic;

        -- motor rpm value
        rpm     : in motor_rmp;

        -- PWM output
        pwm     : out std_logic 
    );

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

end entity motor_pwm;

architecture behavior of motor_pwm is

begin

end architecture behavior;

