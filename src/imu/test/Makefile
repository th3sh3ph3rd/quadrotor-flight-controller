VSIM = vsim

compile_imu_spi:
	$(VSIM) -c do "do compile_imu_spi.do; quit -f"

sim_imu_spi: compile_imu_spi
	$(VSIM) -c do "do sim_imu_spi.do; quit -f"

