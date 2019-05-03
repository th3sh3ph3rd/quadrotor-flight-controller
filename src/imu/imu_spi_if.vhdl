--
-- @author Jan Nausner <jan.nausner@gmail.com>
-- @date 03.05.2019
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package imu_spi_if is

    type imu_reg_in is record
        start   : std_logic;
        rd_en   : std_logic;
        addr    : std_logic_vector(7 downto 0);
        wr_data : std_logic_vector(7 downto 0);
        rd_len  : natural;
    end record;
    
    type imu_reg_out is record
        finish  : std_logic;
        rd_rdy  : std_logic;
        rd_data : std_logic_vector(7 downto 0);
    end record;
    
    type imu_spi_in is record
        sdi     : std_logic;
    end record;
    
    type imu_spi_out is record
        cs_n    : std_logic;
        scl     : std_logic;
        sdo     : std_logic;
    end record;

end package imu_spi_if; 

