VSIM = vsim

compile_imu:
	$(VSIM) -c do "do compile_imu.do; quit -f"

sim_imu: compile_imu
	$(VSIM) -c do "do sim_imu.do; quit -f"

clean:
	rm -rf work
	rm -f transcript
	rm -f *.wlf
	rm -f modelsim.ini

