library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.imu_spi_if.all;
use work.debug_pkg.all;

entity imu_init_tb is
end entity imu_init_tb;

architecture tb of imu_init_tb is

    constant SYS_CLK_FREQ   : integer := 50000000;
    constant SYS_CLK_PERIOD : time := 20 ns;

    signal clk, res_n : std_logic;

    signal reg_in   : imu_reg_in;
    signal reg_out  : imu_reg_out;
    signal spi_in   : imu_spi_in;

    signal init_start, init_done : std_logic;

    component imu_spi is
        generic
        (
            CLK_DIVISOR : integer 
        ); 
        port
        (
            -- global synchronization
            clk     : in std_logic;
            res_n   : in std_logic;

            -- communication interface
            reg_in  : in imu_reg_in;
            reg_out : out imu_reg_out; 

            -- SPI
            spi_in  : in imu_spi_in;
            spi_out : out imu_spi_out
        );
    end component imu_spi;

    component imu_init is
        generic
        (
            CLK_FREQ : integer 
        ); 
        port
        (
            -- global synchronization
            clk     : in std_logic;
            res_n   : in std_logic;

            -- init signals
            init    : in std_logic;
            done    : out std_logic; 
          
            -- communication interface for SPI
            reg_in  : out imu_reg_in;
            reg_out : in imu_reg_out;

            -- debug port
            dbg     : out debug_if
        );
    end component imu_init;

begin

    UUT : imu_init
    generic map
    (
        CLK_FREQ => SYS_CLK_FREQ 
    ) 
    port map
    (
        clk => clk,
        res_n => res_n,

        init => init_start,
        done => init_done,
      
        reg_in => reg_in,
        reg_out => reg_out,

        dbg => open
    );

    imu_spi_inst : imu_spi
    generic map
    (
        CLK_DIVISOR => 4 -- 12.5 MHz SPI freq
    )
    port map
    (
       clk => clk,
       res_n => res_n,
       reg_in => reg_in,
       reg_out => reg_out,
       spi_in => spi_in,
       spi_out => open
    );

    clk_gen : process
    begin
        clk <= '1';
        wait for SYS_CLK_PERIOD/2;
        clk <= '0';
        wait for SYS_CLK_PERIOD/2;
    end process clk_gen;

    stimulus : process
    begin
        res_n <= '0';
        init_start <= '0';
        wait for SYS_CLK_PERIOD;
        res_n <= '1';
        wait for SYS_CLK_PERIOD;

        init_start <= '1';
        wait for SYS_CLK_PERIOD;
        init_start <= '0';

        wait until init_done = '1';

        wait;
    end process stimulus;

end architecture tb;

