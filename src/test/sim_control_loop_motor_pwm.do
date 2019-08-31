vcom -work work -2008 ../control_loop/control_loop_pkg.vhdl
vcom -work work -2008 ../motor_pwm/motor_pwm_pkg.vhdl
vcom -work work -2008 control_loop_motor_pwm_tb.vhdl

vsim -t ps work.control_loop_motor_pwm_tb

add wave /control_loop_motor_pwm_tb/UUT0/*
add wave /control_loop_motor_pwm_tb/UUT1/*
add wave /control_loop_motor_pwm_tb/UUT2/*
add wave /control_loop_motor_pwm_tb/UUT3/*
add wave /control_loop_motor_pwm_tb/UUT4/*

run 100 us

