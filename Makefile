# LED Test

VHDL_FILES := src/flight_controller_top.vhdl

TOP_ENTITY := flight_controller_top
PROJ_DIR := quartus
BITSTREAM := $(PROJ_DIR)/$(TOP_ENTITY).sof
BLASTER_TYPE ?= USB-BlasterII

all: $(BITSTREAM)

$(BITSTREAM): $(VHDL_FILES)
	quartus_map $(PROJ_DIR)/$(TOP_ENTITY)
	quartus_fit $(PROJ_DIR)/$(TOP_ENTITY)
	quartus_asm $(PROJ_DIR)/$(TOP_ENTITY)
	quartus_sta $(PROJ_DIR)/$(TOP_ENTITY)

config: $(BITSTREAM)
	-killall -q jtagd
	jtagd

	quartus_pgm -c $(BLASTER_TYPE) -m JTAG -o "P;$(BITSTREAM)"

# Be careful with the clean command!
# If $(PROJ_DIR) is not set, this removes your entire filesystem!
clean:
	find $(PROJ_DIR)/* ! -name '*.qsf' ! -name '*.qpf' ! -name '*.sdc' -exec rm -rf {} +
