
--------------------------------------------------------------------------------
--                                LIBRARIES                                   --
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.math_pkg.all;
use work.ram_pkg.all;

--------------------------------------------------------------------------------
--                                 ENTITY                                     --
--------------------------------------------------------------------------------
--! Generic single clocked FIFO with configureable fill level counter signal
--------------------------------------------------------------------------------
entity fifo_1c1r1w is
	generic (
		MIN_DEPTH  : integer;
		DATA_WIDTH : integer;
		FILL_LEVEL_COUNTER : string := "OFF"
	);
	port (
		clk       : in  std_logic;
		res_n     : in  std_logic;

		rd_data   : out std_logic_vector(DATA_WIDTH - 1 downto 0);
		rd        : in  std_logic;

		wr_data   : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
		wr        : in  std_logic;

		empty     : out std_logic;
		full      : out std_logic;
		fill_level : out std_logic_vector(log2c(MIN_DEPTH)-1 downto 0)
	);
end entity;


--------------------------------------------------------------------------------
--                               ARCHITECTURE                                 --
--------------------------------------------------------------------------------
architecture mixed of fifo_1c1r1w is
	signal read_address, read_address_next : std_logic_vector(log2c(MIN_DEPTH) - 1 downto 0);
	signal write_address, write_address_next : std_logic_vector(log2c(MIN_DEPTH) - 1 downto 0);
	signal full_int, full_next : std_logic;
	signal empty_int, empty_next : std_logic;
	signal wr_int, rd_int : std_logic;
begin

	memory_inst : dp_ram_1c1r1w
		generic map (
			ADDR_WIDTH => log2c(MIN_DEPTH),
			DATA_WIDTH => DATA_WIDTH
		)
		port map (
			clk       => clk,
			rd1_addr  => read_address,
			rd1_data  => rd_data,
			rd1       => rd_int,
			wr2_addr  => write_address,
			wr2_data  => wr_data,
			wr2       => wr_int
		); 

	sync : process(clk, res_n)
	begin
		if res_n = '0' then
			read_address <= (others => '0');
			write_address <= (others => '0');
			full_int <= '0';
			empty_int <= '1';
		elsif rising_edge(clk) then
			read_address <= read_address_next;
			write_address <= write_address_next;
			full_int <= full_next;
			empty_int <= empty_next;
		end if;
	end process;

	--------------------------------------------------------------------
	--                    PROCESS : EXEC                              --
	--------------------------------------------------------------------
	exec : process(write_address, read_address, full_int, empty_int, wr, rd)
	begin
		write_address_next <= write_address;
		read_address_next <= read_address;  
		full_next <= full_int;
		empty_next <= empty_int;
		wr_int <= '0';
		rd_int <= '0';

		if wr = '1' and full_int = '0' then
			wr_int <= '1'; -- only write, if fifo is not full
			write_address_next <= std_logic_vector(unsigned(write_address) + 1);
		end if;

		if rd = '1' and empty_int = '0'  then
			rd_int <= '1'; -- only read, if fifo is not empty
			read_address_next <= std_logic_vector(unsigned(read_address) + 1);
		end if;

		-- if memory is empty after current read operation
		if rd = '1' then
			full_next <= '0';
			if write_address = std_logic_vector(unsigned(read_address) + 1) then
				empty_next <= '1';
			end if;
		end if;

		-- if memory is full after current write operation
		if wr = '1' then
			empty_next <= '0';
			if read_address = std_logic_vector(unsigned(write_address) + 1) then
				full_next <= '1';
			end if;      
		end if;
	end process;


	GENERATE_FILL_LEVEL : if FILL_LEVEL_COUNTER = "ON" generate
		signal fill_level_int : std_logic_vector(log2c(MIN_DEPTH) - 1 downto 0);
		signal fill_level_next : std_logic_vector(log2c(MIN_DEPTH) - 1 downto 0);
	begin
		sync2 : process(clk, res_n)
		begin
			if res_n = '0' then
				fill_level_int <= (others => '0');
			elsif rising_edge(clk) then
				fill_level_int <= fill_level_next;
			end if;
		end process;
	
		fill_level_process : process (full_next, full_int, empty_int, wr, rd, read_address, write_address)
			variable fill_level_temp : std_logic_vector(log2c(MIN_DEPTH) downto 0);
			variable read_address_temp : std_logic_vector(log2c(MIN_DEPTH)-1 downto 0);
			variable write_address_temp : std_logic_vector(log2c(MIN_DEPTH)-1 downto 0);
		begin
			--fill_level_temp := fill_level_int;
			fill_level_next <= (others=>'0');
			fill_level_temp := (others=>'0');
		
			write_address_temp := write_address;
			read_address_temp := read_address;
		
		
			if wr = '1' and full_int = '0' then
				write_address_temp := std_logic_vector(unsigned(write_address) + 1);
			end if;
			if rd = '1' and empty_int = '0'  then
				read_address_temp := std_logic_vector(unsigned(read_address) + 1);
			end if;
		
			if read_address_temp > write_address_temp then
				fill_level_temp  := std_logic_vector(unsigned('1'&write_address_temp)-unsigned('0'&read_address_temp));
				fill_level_next <= fill_level_temp(log2c(MIN_DEPTH)-1 downto 0);
			else
				fill_level_next <= std_logic_vector(unsigned(write_address_temp)-unsigned(read_address_temp));
			end if;
	
			if full_next = '1' then
				fill_level_next <= (others=>'1');
			end if;
	
		end process;
	
		fill_level <= std_logic_vector(unsigned(fill_level_int));
	
	end generate;

	GENERATE_NO_FILL_LEVEL : if FILL_LEVEL_COUNTER = "OFF" generate
		fill_level <= (others=>'0');
	end generate;

	full <= full_int;
	empty <= empty_int;

end architecture;


