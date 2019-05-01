vcom -work work -2008 imu_spi_tb.vhdl

vsim -t ps work.imu_spi_tb

add wave /imu_spi_tb/UUT/*

run 10 us

