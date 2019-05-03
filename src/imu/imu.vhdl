--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 12.04.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
            yaw     : out imu_angle 
        );

end entity imu;

architecture structure of imu is

    signal spi_busy, spi_enable, spi_rx_en, spi_rx_rdy : std_logic;
    signal spi_addr, spi_tx_data spi_rx_data : std_logic_vector(7 downto 0);
    signal spi_rx_len : natural;

    procedure write_register(constant addr  : std_logic_vector(7 downto 0);
                             constant data  : std_logic_vector(7 downto 0)) is
    begin

    end procedure write_register;

    procedure read_register(constant addr   : std_logic_vector(7 downto 0);
                            constant len    : natural) is
    begin

    end procedure read_register;

    component imu_spi is

        generic
        (
            CLK_DIVISIOR : integer;
        );    
        port
        (
            -- global synchronization
            clk     : in std_logic;
            res_n   : in std_logic;

            -- communication interface
            busy    : out std_logic;
            enable  : in std_logic;
            rx_en   : in std_logic;
            rx_rdy  : out std_logic;
            addr    : in std_logic_vector(7 downto 0);
            tx_data : in std_logic_vector(7 downto 0);
            rx_len  : in natural;
            rx_data : out std_logic_vector(7 downto 0);

            -- SPI
            scl     : out std_logic;
            cs_n    : out std_logic;
            sdo     : out std_logic;
            sdi     : in std_logic
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
            done    : out std_logic 
          
            -- communication interface for SPI
            spi_en  : out std_logic;
            spi_fin : in std_logic;
            rx_en   : out std_logic;
            rx_rdy  : in std_logic;
            addr    : out std_logic_vector(7 downto 0);
            tx_data : out std_logic_vector(7 downto 0);
            rx_len  : out natural;
            rx_data : in std_logic_vector(7 downto 0);

            -- debug port
            dbg     : out debug_if;
        );

    end component imu_init;

    component imu_init is

    end component imu_read;

begin

    imu_spi_inst : imu_spi
    generic map
    (
        CLK_DIVISOR => 4
    )
    port map
    (
        clk <= clk,
        res_n <= res_n,
        
    );

    imu_init_inst : imu_init
    generic map
    (
        CLK_DIVISOR => 4
    )
    port map
    (
        clk <= clk,
        res_n <= res_n,
        
    );


    -- TODO create SPI mux dependant init finished signal

end architecture structure;

