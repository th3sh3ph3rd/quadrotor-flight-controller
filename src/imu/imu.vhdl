--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 28.05.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.fp_pkg.all;
use work.imu_pkg.all;

entity imu is

        port
        (
            -- global synchronization
            clk     : in std_logic;
            res_n   : in std_logic;

            -- output angles
            imu_rdy : out std_logic;
            roll    : out FP_T;
            pitch   : out FP_T;
            yaw     : out FP_T; 
            
            -- SPI
            ss_n    : in std_logic;
            sclk    : in std_logic;
            mosi    : in std_logic;
            miso    : out std_logic
        );

end entity imu;

architecture behavior of imu is
  
    constant ADC_WIDTH  : natural := 12;
    constant SPI_BITS   : natural := 16;

    -- fsm state
    type STATE_T is (IDLE, RECV_ROLL, RECV_PITCH, RECV_YAW, DONE, WAIT_SS);

    type REGISTER_T is record
        state       : STATE_T;
        sclk_meta   : std_logic;
        sclk        : std_logic;
        sclk_prev   : std_logic;
        bit_cnt     : natural range 0 to SPI_BITS-1;
        buf         : signed(SPI_BITS-1 downto 0);
        roll        : FP_T;
        pitch       : FP_T;
        yaw         : FP_T;
    end record;
    signal R, R_next : REGISTER_T;

    constant R_reset : REGISTER_T :=
    (
        state       => IDLE,
        sclk_meta   => '0',
        sclk        => '0',
        sclk_prev   => '0',
        bit_cnt     => 0,
        buf         => (others => '0'),
        roll        => (others => '0'),
        pitch       => (others => '0'),
        yaw         => (others => '0')
    );

begin
    
    sync : process(all)
    begin
        if res_n = '0' then
            R <= R_reset;
        elsif rising_edge(clk) then
            R <= R_next;
        end if;
    end process sync;

    async : process(all)
        
        variable S : REGISTER_T;

    begin

        --output
        imu_rdy  <= '0';
        roll     <= R.roll;
        pitch    <= R.pitch;
        yaw      <= R.yaw;
        miso     <= 'Z';
        
        S := R;

        --synchronizer chain

        S.sclk_meta := sclk;
        S.sclk      := R.sclk_meta;
        S.sclk_prev := R.sclk;
        
        case R.state is

            when IDLE =>
                if ss_n = '0' then
                    S.state := RECV_PITCH;
                end if;
            
            when RECV_PITCH =>
                miso <= '0';
                if R.sclk_prev = '0' and R.sclk = '1' then --detect rising edge
                    S.buf := R.buf(SPI_BITS-2 downto 0) & mosi;
                    if R.bit_cnt = SPI_BITS-1 then
                        S.bit_cnt   := 0;
                        --S.pitch     := shift_left(resize(S.buf(ADC_WIDTH-1 downto 0), FP_WIDTH), FP_FRAC_BITS); --sign-extend the ADC value and convert to fixe-point type
                        S.pitch     := shift_left(resize(R.buf(ADC_WIDTH-2 downto 0)&mosi, FP_WIDTH), FP_FRAC_BITS); --sign-extend the ADC value and convert to fixe-point type
                        S.buf       := (others => '0');
                        S.state     := RECV_ROLL;
                    else
                        S.bit_cnt := R.bit_cnt + 1;
                    end if;
                end if;


            when RECV_ROLL =>
                miso <= '0';
                if R.sclk_prev = '0' and R.sclk = '1' then --detect rising edge
                    S.buf := R.buf(SPI_BITS-2 downto 0) & mosi;
                    if R.bit_cnt = SPI_BITS-1 then
                        S.bit_cnt   := 0;
                        --S.roll      := shift_left(resize(S.buf(ADC_WIDTH-1 downto 0), FP_WIDTH), FP_FRAC_BITS); --sign-extend the ADC value and convert to fixe-point type
                        S.roll      := shift_left(resize(R.buf(ADC_WIDTH-2 downto 0)&mosi, FP_WIDTH), FP_FRAC_BITS); --sign-extend the ADC value and convert to fixe-point type
                        S.buf       := (others => '0');
                        S.state     := RECV_YAW;
                    else
                        S.bit_cnt := R.bit_cnt + 1;
                    end if;
                end if;

            when RECV_YAW =>
                miso <= '0';
                if R.sclk_prev = '0' and R.sclk = '1' then --detect rising edge
                    S.buf := R.buf(SPI_BITS-2 downto 0) & mosi;
                    if R.bit_cnt = SPI_BITS-1 then
                        S.bit_cnt   := 0;
                        --S.yaw       := shift_left(resize(S.buf(ADC_WIDTH-1 downto 0), FP_WIDTH), FP_FRAC_BITS); --sign-extend the ADC value and convert to fixe-point type
                        S.yaw       := shift_left(resize(R.buf(ADC_WIDTH-2 downto 0)&mosi, FP_WIDTH), FP_FRAC_BITS); --sign-extend the ADC value and convert to fixe-point type
                        S.buf       := (others => '0');
                        S.state     := DONE;
                    else
                        S.bit_cnt := R.bit_cnt + 1;
                    end if;
                end if;

            when DONE =>
                imu_rdy <= '1';
                S.state := WAIT_SS;

            when WAIT_SS =>
                if ss_n = '1' then
                    S.state := IDLE;
                end if;

        end case;

        R_next <= S;

    end process async;

end architecture behavior;

