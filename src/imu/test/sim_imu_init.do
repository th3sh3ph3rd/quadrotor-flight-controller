
vcom -work work -2008 ../../util/debug/debug_pkg.vhdl

vcom -work work -2008 ../imu_spi_if.vhdl
vcom -work work -2008 ../imu_spi.vhdl
vcom -work work -2008 ../imu_init.vhdl

vcom -work work -2008 imu_init_tb.vhdl

vsim -t ps work.imu_init_tb

add wave /imu_init_tb/UUT/*
add wave /imu_init_tb/imu_spi_inst/*

run 1000 ms

