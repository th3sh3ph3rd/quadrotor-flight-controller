--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 12.04.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package motor_pwm_pkg is

    constant MOTOR_RPM_WIDTH : natural := 16;
    subtype motor_rpm is std_logic_vector(MOTOR_RPM_WIDTH-1 downto 0); 
    
    component motor_pwm is

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

    end component motor_pwm;

end package motor_pwm_pkg; 
