----------------------------------------------------------------------------------
--                                LIBRARIES                                     --
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.math_pkg.all;

----------------------------------------------------------------------------------
--                                 PACKAGE                                      --
----------------------------------------------------------------------------------

package ram_pkg is

	component dp_ram_1c1r1w is
		generic (
			ADDR_WIDTH : integer;
			DATA_WIDTH : integer
		);
		port (
			clk : in std_logic;
			rd1_addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
			rd1_data : out std_logic_vector(DATA_WIDTH - 1 downto 0);
			rd1 : in std_logic;
			wr2_addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
			wr2_data : in std_logic_vector(DATA_WIDTH - 1 downto 0);
			wr2 : in std_logic
		);
	end component;

	component fifo_1c1r1w is
		generic (
			MIN_DEPTH : integer;
			DATA_WIDTH : integer;
			FILL_LEVEL_COUNTER : string := "OFF"
		);
		port (
			clk : in std_logic;
			res_n : in std_logic;
			rd_data : out std_logic_vector(DATA_WIDTH - 1 downto 0);
			rd : in std_logic;
			wr_data : in std_logic_vector(DATA_WIDTH - 1 downto 0);
			wr : in std_logic;
			empty : out std_logic;
			full : out std_logic;
			fill_level : out std_logic_vector(log2c(MIN_DEPTH)-1 downto 0)
		);
	end component;

end package;

