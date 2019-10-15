vcom -work work -2008 ../control_loop/fp_pkg.vhdl
vcom -work work -2008 ../imu/imu_pkg.vhdl
vcom -work work -2008 ../imu/test/spi_bfm_pkg.vhdl
vcom -work work -2008 ../control_loop/control_loop_pkg.vhdl
vcom -work work -2008 ../motor_pwm/motor_pwm_pkg.vhdl
vcom -work work -2008 flight_controller_tb.vhdl

vsim -t ps work.flight_controller_tb

add wave /flight_controller_tb/UUT_imu/*
add wave /flight_controller_tb/UUT_ctrl_loop/*
add wave /flight_controller_tb/UUT_m0/*
add wave /flight_controller_tb/UUT_m1/*
add wave /flight_controller_tb/UUT_m2/*
add wave /flight_controller_tb/UUT_m3/*

run 700 ms

