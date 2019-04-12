library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity flight_controller_top is
  port (
    clk : in  std_logic;
    led : out std_logic
  );
end flight_controller_top;

architecture rtl of flight_controller_top is
  constant CLK_FREQ : natural := 50000000;

  signal counter : natural range 0 to CLK_FREQ-1;
  signal led_state : std_logic;

begin
  process (clk) is
  begin
    if rising_edge(clk) then
      if counter = CLK_FREQ-1 then
        led_state <= not led_state;
        counter <= 0;
      else
        counter <= counter + 1;
      end if;
    end if;
  end process;

  led <= led_state;
end rtl;
