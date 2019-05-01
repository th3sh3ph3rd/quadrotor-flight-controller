library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity imu_spi_tb is
end entity imu_spi_tb;

architecture tb of imu_spi_tb is

    constant SYS_CLK_FREQ   : integer := 50000000;
    constant SYS_CLK_PERIOD : time := 20 ns;
    constant SPI_CLK_PERIOD : time := 80 ns;    -- 12.5 MHz 

    signal clk, res_n : std_logic;

    signal start, finish, rx_en, sdi : std_logic;
    signal addr, tx_data : std_logic_vector(7 downto 0);
    signal rx_len : natural;

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
            start   : in std_logic;
            finish  : out std_logic;
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

begin

    UUT : imu_spi
    generic map
    (
        CLK_DIVISOR => 4 -- 12.5 MHz SPI freq
    )
    port map
    (
       clk => clk,
       res_n => res_n,
       start => start,
       finish => finish,
       rx_en => rx_en,
       rx_rdy => open,
       addr => addr,
       tx_data => tx_data,
       rx_len => rx_len,
       rx_data => open,
       sdi => sdi
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
        start <= '0';
        rx_en <= '0';
        addr <= (others => '0');
        tx_data <= (others => '0');
        rx_len <= 0;
        sdi <= '0';
        wait for SYS_CLK_PERIOD;
        res_n <= '1';

        -- simple tx test
        start <= '1';
        addr <= "10011001";
        tx_data <= "10101010";
        wait for SYS_CLK_PERIOD;
        start <= '0';
        wait until finish = '1';
        wait for SYS_CLK_PERIOD*2;

        -- simple rx test
        start <= '1';
        rx_en <= '1';
        addr <= "11001100";
        rx_len <= 1;
        wait for SYS_CLK_PERIOD;
        start <= '0';
        wait for SYS_CLK_PERIOD + SPI_CLK_PERIOD*8;
        sdi <= '1';
        wait for SPI_CLK_PERIOD; 
        sdi <= '0';
        wait for SPI_CLK_PERIOD; 
        sdi <= '0';
        wait for SPI_CLK_PERIOD; 
        sdi <= '1';
        wait for SPI_CLK_PERIOD; 
        sdi <= '1';
        wait for SPI_CLK_PERIOD; 
        sdi <= '0';
        wait for SPI_CLK_PERIOD; 
        sdi <= '0';
        wait for SPI_CLK_PERIOD; 
        sdi <= '1';
        wait until finish = '1';
        wait for SYS_CLK_PERIOD*2;

        -- multi rx test
        start <= '1';
        rx_en <= '1';
        addr <= "11001100";
        rx_len <= 3;
        wait for SYS_CLK_PERIOD;
        start <= '0';
        wait for SYS_CLK_PERIOD + SPI_CLK_PERIOD*8;
        -- 10011001
        sdi <= '1';
        wait for SPI_CLK_PERIOD; 
        sdi <= '0';
        wait for SPI_CLK_PERIOD; 
        sdi <= '0';
        wait for SPI_CLK_PERIOD; 
        sdi <= '1';
        wait for SPI_CLK_PERIOD; 
        sdi <= '1';
        wait for SPI_CLK_PERIOD; 
        sdi <= '0';
        wait for SPI_CLK_PERIOD; 
        sdi <= '0';
        wait for SPI_CLK_PERIOD; 
        sdi <= '1';
        wait for SPI_CLK_PERIOD;
        -- 11110000
        sdi <= '1';
        wait for SPI_CLK_PERIOD; 
        sdi <= '1';
        wait for SPI_CLK_PERIOD; 
        sdi <= '1';
        wait for SPI_CLK_PERIOD; 
        sdi <= '1';
        wait for SPI_CLK_PERIOD; 
        sdi <= '0';
        wait for SPI_CLK_PERIOD; 
        sdi <= '0';
        wait for SPI_CLK_PERIOD; 
        sdi <= '0';
        wait for SPI_CLK_PERIOD; 
        sdi <= '0';
        wait for SPI_CLK_PERIOD;
        -- 01101101
        sdi <= '0';
        wait for SPI_CLK_PERIOD; 
        sdi <= '1';
        wait for SPI_CLK_PERIOD; 
        sdi <= '1';
        wait for SPI_CLK_PERIOD; 
        sdi <= '0';
        wait for SPI_CLK_PERIOD; 
        sdi <= '1';
        wait for SPI_CLK_PERIOD; 
        sdi <= '1';
        wait for SPI_CLK_PERIOD; 
        sdi <= '0';
        wait for SPI_CLK_PERIOD; 
        sdi <= '1';
        wait until finish = '1';

        wait;
    end process stimulus;

end architecture tb;

