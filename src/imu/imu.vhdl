--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 28.05.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.imu_pkg.all;

entity imu is

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
            ss_n    : in std_logic;
            sclk    : in std_logic;
            mosi    : in std_logic;
            miso    : out std_logic
        );

end entity imu;

architecture behavior of imu is
    
    -- fsm state
    type state_type is (IDLE, RECV_ROLL, RECV_PITCH, RECV_YAW, DONE);
    signal state, state_next : state_type;

    signal sclk_prev : std_logic;
    signal bit_cnt, bit_cnt_next : natural range 0 to IMU_ANGLE_WIDTH-1;

    -- buffers
    type buffers is record
        roll  : imu_angle;
        pitch : imu_angle;
        yaw   : imu_angle;
    end record;
    signal buf, buf_next : buffers;

begin
    
    sync : process(all)
    begin
        if res_n = '0' then
            state       <= IDLE;
            sclk_prev   <= '0';
            bit_cnt     <= 0;
            buf.roll    <= (others => '0');
            buf.pitch   <= (others => '0');
            buf.yaw     <= (others => '0');
        elsif rising_edge(clk) then
            state     <= state_next;
            sclk_prev <= sclk;
            bit_cnt   <= bit_cnt_next;
            buf       <= buf_next;
        end if;
    end process sync;

    next_state : process(all)
    begin
        state_next <= state;

        case state is
            when IDLE =>
                if ss_n = '0' then
                    state_next <= RECV_ROLL;
                end if;

            when RECV_ROLL =>
                if bit_cnt = IMU_ANGLE_WIDTH-1 and sclk_prev = '1' and sclk = '0' then
                    state_next <= RECV_PITCH;
                end if;

            when RECV_PITCH =>
                if bit_cnt = IMU_ANGLE_WIDTH-1 and sclk_prev = '1' and sclk = '0' then
                    state_next <= RECV_YAW;
                end if;

            when RECV_YAW =>
                if bit_cnt = IMU_ANGLE_WIDTH-1 and sclk_prev = '1' and sclk = '0' then
                    state_next <= DONE;
                end if;

            when DONE =>
                if ss_n = '1' then
                    state_next <= IDLE;
                end if;

        end case;
    end process next_state;

    output : process(all)
    begin
        imu_rdy  <= '0';
        roll     <= buf.roll;
        pitch    <= buf.pitch;
        yaw      <= buf.yaw;
        miso     <= 'Z';
        
        bit_cnt_next <= bit_cnt;
        buf_next <= buf;

        case state is
            when IDLE =>
                miso <= 'Z';

            when RECV_ROLL =>
                miso <= '0';
                if sclk_prev = '1' and sclk = '0' then --detect falling edge
                    buf_next.roll <= buf.roll(IMU_ANGLE_WIDTH-2 downto 0) & mosi;
                    if bit_cnt = IMU_ANGLE_WIDTH-1 then
                        bit_cnt_next <= 0;
                    else
                        bit_cnt_next <= bit_cnt + 1;
                    end if;
                end if;

            when RECV_PITCH =>
                miso <= '0';
                if sclk_prev = '1' and sclk = '0' then 
                    buf_next.pitch <= buf.pitch(IMU_ANGLE_WIDTH-2 downto 0) & mosi;
                    if bit_cnt = IMU_ANGLE_WIDTH-1 then
                        bit_cnt_next <= 0;
                    else
                        bit_cnt_next <= bit_cnt + 1;
                    end if;
                end if;

            when RECV_YAW =>
                miso <= '0';
                if sclk_prev = '1' and sclk = '0' then
                    buf_next.yaw <= buf.yaw(IMU_ANGLE_WIDTH-2 downto 0) & mosi;
                    if bit_cnt = IMU_ANGLE_WIDTH-1 then
                        bit_cnt_next <= 0;
                    else
                        bit_cnt_next <= bit_cnt + 1;
                    end if;
                end if;

            when DONE =>
                imu_rdy <= '1';

        end case;
    end process output;

end architecture behavior;

