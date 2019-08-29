VSIM = vsim

compile_imu_control_loop:
	$(VSIM) -c do "do compile_imu_control_loop.do; quit -f"

sim_imu_control_loop: compile_imu_control_loop
	$(VSIM) -c do "do sim_imu_control_loop.do; quit -f"

compile_control_loop_motor_pwm:
	$(VSIM) -c do "do compile_control_loop_motor_pwm.do; quit -f"

sim_control_loop_motor_pwm: compile_control_loop_motor_pwm
	$(VSIM) -c do "do sim_control_loop_motor_pwm.do; quit -f"

clean:
	rm -rf work
	rm -f transcript
	rm -f *.wlf
	rm -f modelsim.ini

