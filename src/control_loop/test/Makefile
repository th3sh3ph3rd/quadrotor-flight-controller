VSIM = vsim

compile_pid:
	$(VSIM) -c do "do compile_pid.do; quit -f"

sim_pid: compile_pid
	$(VSIM) -c do "do sim_pid.do; quit -f"

compile_calc_motor_speed:
	$(VSIM) -c do "do compile_calc_motor_speed.do; quit -f"

sim_calc_motor_speed: compile_calc_motor_speed
	$(VSIM) -c do "do sim_calc_motor_speed.do; quit -f"

clean:
	rm -rf work
	rm -f transcript
	rm -f *.wlf
	rm -f modelsim.ini

