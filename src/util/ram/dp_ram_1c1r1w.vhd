

--------------------------------------------------------------------------------
--                                LIBRARIES                                   --
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------------------------------------------------
--                                 ENTITY                                     --
--------------------------------------------------------------------------------

entity dp_ram_1c1r1w is
	generic (
		ADDR_WIDTH : integer; -- Address bus width
		DATA_WIDTH : integer  -- Data bus width
	);
	port (
		clk    : in  std_logic; -- Connection for the clock signal.
		
		-- read port
		rd1_addr : in  std_logic_vector(ADDR_WIDTH - 1 downto 0); -- The address bus for a reader of the dual port RAM.
		rd1_data : out std_logic_vector(DATA_WIDTH - 1 downto 0); -- The data bus for a reader of the dual port RAM.
		rd1      : in  std_logic; -- The indicator signal for a reader of the dual port RAM (must  be set high in order to be able to read).
		
		-- write port
		wr2_addr : in  std_logic_vector(ADDR_WIDTH - 1 downto 0); -- The address bus for a writer of the dual port RAM.
		wr2_data : in  std_logic_vector(DATA_WIDTH - 1 downto 0); -- The data bus for a writer of the dual port RAM.
		wr2      : in  std_logic  -- The indicator signal for a writer of the dual port RAM (must be set high in order to be able to write).
	);
end entity;


--------------------------------------------------------------------------------
--                               ARCHITECTURE                                 --
--------------------------------------------------------------------------------

architecture beh of dp_ram_1c1r1w is
	subtype ram_entry is std_logic_vector(DATA_WIDTH - 1 downto 0);
	type ram_type is array(0 to (2 ** ADDR_WIDTH) - 1) of ram_entry;
	signal ram : ram_type := (others => (others => '0'));
begin
	sync : process(clk)
	begin
		if rising_edge(clk) then
			if wr2 = '1' then
				ram(to_integer(unsigned(wr2_addr))) <= wr2_data;
			end if;
			if rd1 = '1' then
				rd1_data <= ram(to_integer(unsigned(rd1_addr)));
			end if;
		end if;
	end process;
end architecture;


