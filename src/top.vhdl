--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 12.04.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sync_pkg.all;
use work.debug_pkg.all;

use work.imu_pkg.all;

entity flight_controller_top is
  
    port
    (
        clk     : in  std_logic;
        leds    : out std_logic_vector(4 downto 0);
        buttons : in std_logic_vector(3 downto 0);
        pmoda   : inout std_logic_vector(7 downto 0);
        pmodb   : inout std_logic_vector(7 downto 0)
    );

end flight_controller_top;

architecture structure of flight_controller_top is
 
    constant SYS_CLK_FREQ   : natural := 50000000;
    constant BAUD_RATE      : natural := 9600;

    signal res_n, ss_n, sclk, mosi, rx : std_logic;

    signal counter : natural range 0 to SYS_CLK_FREQ-1;
    signal led_state, imu_rdy : std_logic;

    signal spi_cnt, spi_cnt_next : unsigned(3 downto 0);

    signal dbg : debug_if;

    component uart is

        generic
        (
            CLK_FREQ        : integer;
            BAUD_RATE       : integer;
            SYNC_STAGES     : integer;
            TX_FIFO_DEPTH   : integer;
            RX_FIFO_DEPTH   : integer
        );
        port
        (
            -- global synchronization
            clk         : in std_logic;                       
            res_n       : in std_logic;                     

            -- tx interface
            tx_data     : in std_logic_vector(7 downto 0);  
            tx_wr       : in std_logic;			
            tx_full     : out std_logic;	

            -- rx interface
            rx_data     : out std_logic_vector(7 downto 0);
            rx_rd       : in std_logic;			
            rx_full     : out std_logic;	
            rx_empty    : out std_logic;

            -- uart io pins
            rx          : in std_logic;
            tx          : out std_logic
        );

    end component uart;

begin

    -- TODO create debug mux between different modules

    sys_reset_sync : sync
    generic map 
    (
        SYNC_STAGES => 2,
        RESET_VALUE => '1'
    )
    port map 
    (
        clk => clk,
        res_n => '1',
        data_in => buttons(0),
        data_out => res_n
    );

    slave_select_sync : sync
    generic map 
    (
        SYNC_STAGES => 2,
        RESET_VALUE => '1'
    )
    port map 
    (
        clk => clk,
        res_n => '1',
        data_in => pmodb(1),
        data_out => ss_n
    );
    
    sclk_sync : sync
    generic map 
    (
        SYNC_STAGES => 2,
        RESET_VALUE => '1'
    )
    port map 
    (
        clk => clk,
        res_n => '1',
        data_in => pmodb(2),
        data_out => sclk
    );
    
    mosi_sync : sync
    generic map 
    (
        SYNC_STAGES => 2,
        RESET_VALUE => '1'
    )
    port map 
    (
        clk => clk,
        res_n => '1',
        data_in => pmodb(0),
        data_out => mosi
    );
    
    rx_sync : sync
    generic map 
    (
        SYNC_STAGES => 2,
        RESET_VALUE => '1'
    )
    port map 
    (
        clk => clk,
        res_n => '1',
        data_in => pmoda(1),
        data_out => rx
    );
     
    debug_inst : debug
    generic map
    (
        CLK_FREQ => SYS_CLK_FREQ,
        BAUD_RATE => BAUD_RATE
    )
    port map
    (
        clk => clk, 
        res_n => res_n,

        dbg => dbg, 

        rx => rx,
        tx => pmoda(0)
    );

    imu_inst : imu
    port map
    (
        clk => clk,    
        res_n => res_n,
        imu_rdy => imu_rdy,
        roll => open,
        pitch => open,
        yaw => open,
        ss_n => ss_n, 
        sclk => sclk,
        mosi => mosi,
        miso => pmodb(3)
    );
 
    process(all) is
    begin
        
        if res_n = '0' then
            counter <= 0;
            led_state <= '1';
            spi_cnt <= (others => '0');
        elsif rising_edge(clk) then
            if counter = SYS_CLK_FREQ-1 then
                led_state <= not led_state;
                counter <= 0;
            else
                counter <= counter + 1;
            end if;
            if imu_rdy = '1' then
                spi_cnt <= spi_cnt + "0001";
            end if;
        end if;

    end process;

    leds(0) <= led_state;
    leds(4 downto 1) <= std_logic_vector(spi_cnt);

end structure;

