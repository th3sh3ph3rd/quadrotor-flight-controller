VSIM = vsim

compile_imu_spi:
	$(VSIM) -c do "do compile_imu_spi.do; quit -f"

sim_imu_spi: compile_imu_spi
	$(VSIM) -c do "do sim_imu_spi.do; quit -f"

compile_imu_init:
	$(VSIM) -c do "do compile_imu_init.do; quit -f"

sim_imu_init: compile_imu_init
	$(VSIM) -c do "do sim_imu_init.do; quit -f"

clean:
	rm -rf work
	rm -f transcript
	rm -f *.wlf
	rm -f modelsim.ini

