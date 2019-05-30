VSIM = vsim

compile_imu_control_loop:
	$(VSIM) -c do "do compile_imu_control_loop.do; quit -f"

sim_imu_control_loop: compile_imu_control_loop
	$(VSIM) -c do "do sim_imu_control_loop.do; quit -f"

clean:
	rm -rf work
	rm -f transcript
	rm -f *.wlf
	rm -f modelsim.ini

