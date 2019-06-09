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

end entity motor_pwm;

architecture behavior of motor_pwm is

begin

end architecture behavior;

