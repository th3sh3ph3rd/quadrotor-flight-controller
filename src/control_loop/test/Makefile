VSIM = vsim

compile_pid:
	$(VSIM) -c do "do compile_pid.do; quit -f"

sim_pid: compile_pid
	$(VSIM) -c do "do sim_pid.do; quit -f"

clean:
	rm -rf work
	rm -f transcript
	rm -f *.wlf
	rm -f modelsim.ini

