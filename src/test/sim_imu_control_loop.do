vcom -work work -2008 ../imu/imu_pkg.vhdl
vcom -work work -2008 ../control_loop/control_loop_pkg.vhdl
vcom -work work -2008 imu_control_loop_tb.vhdl

vsim -t ps work.imu_control_loop_tb

add wave /imu_control_loop_tb/UUT1/*
add wave /imu_control_loop_tb/UUT2/*

run 20 us

