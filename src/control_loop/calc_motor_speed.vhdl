--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 21.05.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.fp_pkg.all;
use work.motor_pwm_pkg.all;

entity calc_motor_speed is

        generic
        (
            THRUST_Z : motor_rpm 
        ); 
        port
        (
            -- global synchronization
            clk         : in std_logic;
            res_n       : in std_logic;

            -- angular thrust
            new_thrust  : in std_logic;
            roll        : in FP_T;
            pitch       : in FP_T;
            yaw         : in FP_T;

            -- motor speed values
            speed_rdy   : out std_logic;
            m0          : out motor_rpm;
            m1          : out motor_rpm;
            m2          : out motor_rpm;
            m3          : out motor_rpm
        );

end entity calc_motor_speed;

architecture behavior of calc_motor_speed is

    type STATE_T is (IDLE, CALC, DONE);

    type REGISTER_T is record
        state   : STATE_T;
        roll    : integer;
        pitch   : integer;
        yaw     : integer;
        mfcw      : integer;
        mfccw      : integer;
        mrcw      : integer;
        mrccw      : integer;
    end record;
    signal R, R_next : REGISTER_T;

    constant R_reset : REGISTER_T :=
    (
        state   => IDLE,
        roll    => 0,
        pitch   => 0,
        yaw     => 0,
        mfcw      => 0,
        mfccw      => 0,
        mrcw      => 0,
        mrccw      => 0
    );

begin
    
    sync : process(all)
    begin
        if res_n = '0' then
            R <= R_reset;
        elsif rising_edge(clk) then
            R <= R_next;
        end if;
    end process sync;
    
    async : process(all)

        variable S : REGISTER_T;

    begin

        --convert output integer value
        speed_rdy   <= '0';
        m0          <= std_logic_vector(to_unsigned(R.mfcw, MOTOR_RPM_WIDTH));
        m1          <= std_logic_vector(to_unsigned(R.mfccw, MOTOR_RPM_WIDTH));
        m2          <= std_logic_vector(to_unsigned(R.mrcw, MOTOR_RPM_WIDTH));
        m3          <= std_logic_vector(to_unsigned(R.mrccw, MOTOR_RPM_WIDTH));

        S := R;

        case R.state is

            when IDLE =>
                if new_thrust = '1' then
                    S.roll  := fp2int(roll);
                    S.pitch := fp2int(pitch);
                    S.yaw   := fp2int(yaw);
                    S.state := CALC;
                end if;

            when CALC => --calculate the thrust values for every rotor
                S.mfcw      := to_integer(unsigned(THRUST_Z)) + R.roll + R.pitch + R.yaw;
                S.mfccw     := to_integer(unsigned(THRUST_Z)) - R.roll + R.pitch - R.yaw;
                S.mrcw      := to_integer(unsigned(THRUST_Z)) - R.roll - R.pitch + R.yaw;
                S.mrccw     := to_integer(unsigned(THRUST_Z)) + R.roll - R.pitch - R.yaw;
                S.state     := DONE;

            when DONE =>
                speed_rdy   <= '1';
                S.state     := IDLE;

        end case;

        R_next <= S;

    end process async;

end architecture behavior;

