vcom -work work -2008 ../fp_pkg.vhdl
vcom -work work -2008 ../../motor_pwm/motor_pwm_pkg.vhdl
vcom -work work -2008 ../calc_motor_speed.vhdl

vsim -t ps work.calc_motor_speed_tb

add wave /calc_motor_speed_tb/UUT/*

run 10 us


