--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 12.04.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.imu_spi_if.all;
use work.debug_pkg.all;
use work.imu_pkg.all;

entity imu is

        generic
        (
            CLK_FREQ : integer 
        ); 
        port
        (
            -- global synchronization
            clk     : in std_logic;
            res_n   : in std_logic;

            -- output angles
            imu_rdy : out std_logic;
            roll    : out imu_angle;
            pitch   : out imu_angle;
            yaw     : out imu_angle; 
            
            -- SPI
            spi_in  : in imu_spi_in;
            spi_out : out imu_spi_out;
            
            -- debug port
            dbg     : out debug_if
        );

end entity imu;

architecture structure of imu is
    
    -- time constants
    constant INIT_WAIT_CLKS : natural := CLK_FREQ/1000; -- 1 ms
    signal clk_cnt : natural;
    
    signal reg_in   : imu_reg_in;
    signal reg_out  : imu_reg_out;

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

    imu_spi_inst : imu_spi
    generic map
    (
        CLK_DIVISOR => 50 --6.25 MHz SPI
    )
    port map
    (
        clk => clk,
        res_n => res_n,
        reg_in => reg_in,
        reg_out => reg_out,
        spi_in => spi_in,
        spi_out => spi_out 
    );

    imu_init_inst : imu_init
    generic map
    (
        CLK_FREQ => CLK_FREQ
    )
    port map
    (
        clk => clk,
        res_n => res_n,
        init => init_start,
        done => init_done,
        reg_in => reg_in,
        reg_out => reg_out,
        dbg => dbg
    );

    sync : process(all)
    begin
        if res_n = '0' then
            clk_cnt <= 0;
        elsif rising_edge(clk) then
            clk_cnt <= clk_cnt + 1;
        end if; 
    end process sync;
   
    output : process(all)
    begin
        imu_rdy <= not init_done;

        init_start <= '0';

        if clk_cnt = INIT_WAIT_CLKS-1 then
            init_start <= '1';
        end if;
    end process output;

    -- TODO create SPI and debug mux dependant init finished signal

end architecture structure;

