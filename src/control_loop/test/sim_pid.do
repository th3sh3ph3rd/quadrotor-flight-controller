vcom -work work -2008 ../fp_pkg.vhdl
vcom -work work -2008 pid_tb.vhdl

vsim -t ps work.pid_tb

add wave /pid_tb/UUT/*

run 10 us

