# Clock input pin (50 MHz)
create_clock -period 20 [get_ports clk]

# Create generated clocks based on PLLs
#derive_pll_clocks -use_tan_name

derive_clock_uncertainty

# ** Input/Output Delays

# Use FPGA-centric constraints (general pins)
# Tsu 5 ns
set_max_delay -from [all_inputs] -to [all_registers] 5
set_min_delay -from [all_inputs] -to [all_registers] 0
# Tco 10 ns
set_max_delay -from [all_registers] -to [all_outputs] 10
set_min_delay -from [all_registers] -to [all_outputs] 0