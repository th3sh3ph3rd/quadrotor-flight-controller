----------------------------------------------------------------------------------
-- Company:      TU Wien - ECS Group                                            --
-- Engineer:     Thomas Polzer                                                  --
--                                                                              --
-- Create Date:  21.09.2010                                                     --
-- Design Name:  DIDELU                                                         --
-- Module Name:  sync                                                           --
-- Project Name: DIDELU                                                         --
-- Description:  Synchronizer - Entity                                          --
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
--                                LIBRARIES                                     --
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--------------------------------------------------------------------------------
--                                 ENTITY                                     --
--------------------------------------------------------------------------------

entity sync is
	generic (
		-- number of stages in the input synchronizer
		SYNC_STAGES : integer range 2 to integer'high;
		-- reset value of the output signal
		RESET_VALUE : std_logic
	);
	port (
		clk   : in std_logic;
		res_n : in std_logic;

		data_in   : in std_logic;
		data_out  : out std_logic
	);
end entity;

--------------------------------------------------------------------------------
--                               ARCHITECTURE                                 --
--------------------------------------------------------------------------------

architecture beh of sync is
	-- synchronizer stages
	signal sync : std_logic_vector(1 to SYNC_STAGES);
begin

	--------------------------------------------------------------------
	--                    PROCESS : SYNC                              --
	--------------------------------------------------------------------
	sync_proc : process(clk, res_n)
	begin
		if res_n = '0' then
			sync <= (others => RESET_VALUE);
		elsif rising_edge(clk) then
			sync(1) <= data_in; -- get new data
			-- forward data to next synchronizer stage
			for i in 2 to SYNC_STAGES loop
				sync(i) <= sync(i - 1);
			end loop;
		end if;
	end process sync_proc;

	-- output synchronized data
	data_out <= sync(SYNC_STAGES);
end architecture;
