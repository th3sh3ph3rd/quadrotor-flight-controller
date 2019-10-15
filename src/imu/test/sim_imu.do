vcom -work work -2008 ../../control_loop/fp_pkg.vhdl
vcom -work work -2008 ../imu_pkg.vhdl
vcom -work work -2008 spi_bfm_pkg.vhdl
vcom -work work -2008 imu_tb.vhdl

vsim -t ps work.imu_tb

add wave /imu_tb/UUT/*

run 20 us

