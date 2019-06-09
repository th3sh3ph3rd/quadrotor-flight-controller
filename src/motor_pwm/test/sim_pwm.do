vcom -work work -2008 ../motor_pwm_pkg.vhdl
vcom -work work -2008 pwm_tb.vhdl

vsim -t ps work.pwm_tb

add wave /pwm_tb/UUT/*

run 20 us

