--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 12.04.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package motor_pwm_pkg is
    
    constant MIN_PWM_FREQ : natural := 10;
    constant MAX_PWM_FREQ : natural := 1000000;

    constant MOTOR_RPM_WIDTH : natural := 16;
    subtype motor_rpm is std_logic_vector(MOTOR_RPM_WIDTH-1 downto 0);

    type pwm_dc is array(natural range <>) of unsigned;
     
    component motor_pwm is

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

    end component motor_pwm;

end package motor_pwm_pkg; 
