VSIM = vsim

compile_pwm:
	$(VSIM) -c do "do compile_pwm.do; quit -f"

sim_pwm: compile_pwm
	$(VSIM) -c do "do sim_pwm.do; quit -f"

clean:
	rm -rf work
	rm -f transcript
	rm -f *.wlf
	rm -f modelsim.ini

