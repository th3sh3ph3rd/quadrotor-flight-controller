# LED Test

PROJ_NAME := quadrotor-flight-controller

VHDL_FILES := src/flight_controller_top.vhdl
PID_PARAMS := src/control_loop/pid_params.vhdl

TOP_ENTITY := flight_controller_top
PROJ_DIR := quartus
BITSTREAM := $(PROJ_DIR)/output_files/$(TOP_ENTITY).sof
BLASTER_TYPE ?= USB-BlasterII

all: $(BITSTREAM)

pidparams:
	cd tools; ./computePIDParams.py; cd -

$(BITSTREAM): $(VHDL_FILES) $(PID_PARAMS)
	quartus_map $(PROJ_DIR)/$(TOP_ENTITY)
	quartus_fit $(PROJ_DIR)/$(TOP_ENTITY)
	quartus_asm $(PROJ_DIR)/$(TOP_ENTITY)
	quartus_sta $(PROJ_DIR)/$(TOP_ENTITY)

config: $(BITSTREAM)
	-killall -q jtagd
	jtagd
	quartus_pgm -c $(BLASTER_TYPE) -m JTAG -o "P;$(BITSTREAM)"

config_pid:
	make pidparams
	quartus_map $(PROJ_DIR)/$(TOP_ENTITY)
	quartus_fit $(PROJ_DIR)/$(TOP_ENTITY)
	quartus_asm $(PROJ_DIR)/$(TOP_ENTITY)
	quartus_sta $(PROJ_DIR)/$(TOP_ENTITY)
	-killall -q jtagd
	jtagd
	quartus_pgm -c $(BLASTER_TYPE) -m JTAG -o "P;$(BITSTREAM)"
	

# Be careful with the clean command!
# If $(PROJ_DIR) is not set, this removes your entire filesystem!
clean:
	find $(PROJ_DIR)/* ! -name '*.qsf' ! -name '*.qpf' ! -name '*.sdc' -exec rm -rf {} +
