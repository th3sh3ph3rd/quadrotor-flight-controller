vcom -work work -2008 ../pid_types.vhdl
vcom -work work -2008 calc_motor_speed_tb.vhdl

vsim -t ps work.calc_motor_speed_tb

add wave /calc_motor_speed_tb/UUT/*

run 10 us


