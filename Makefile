#################################################################################
# make stuff
#################################################################################
#output markup
OUTPUT_MARKUP= 2>&1 | tee ../make_log.txt | ccze -A

#################################################################################
# VIVADO stuff
#################################################################################
VIVADO_VERSION=2018.2
VIVADO_FLAGS=-notrace -mode batch
VIVADO_SHELL="/opt/Xilinx/Vivado/"$(VIVADO_VERSION)"/settings64.sh"
VIVADO_SETUP=source $(VIVADO_SHELL) && mkdir -p proj && mkdir -p os/hw && cd proj

#################################################################################
# TCL scripts
#################################################################################
SETUP_TCL=scripts/Setup.tcl
BUILD_TCL=scripts/Build.tcl
SETUP_BUILD_TCL=scripts/SetupAndBuild.tcl
HW_TCL=scripts/Run_hw.tcl

#################################################################################
# Source files
#################################################################################
PL_PATH=../src
BD_PATH=../bd
CORES_PATH=../cores

SYM_LNK_XMLS = $(shell find ./ -type l)
MAP_OBJS = $(patsubst %.xml, %_map.vhd, $(SYM_LNK_XMLS))
PKG_OBJS = $(patsubst %.xml, %_PKG.vhd, $(SYM_LNK_XMLS))


#################################################################################
# Short build names
#################################################################################

BIT=./bit/top.bit

.SECONDARY:

.PHONY: clean list bit automap

all: automap bit 


#################################################################################
# Clean
#################################################################################
clean_vhd:
#	@echo "Cleaning up generated vhd files"
#	@rm -rf $(MAP_OBJS)
#	@rm -rf $(PKG_OBJS)
clean_ip:
	@echo "Cleaning up ip dcps"
	@find ./cores -type f -name '*.dcp' -delete
clean_bd:
	@echo "Cleaning up bd generated files"
	@rm -rf ./bd/zynq_bd
	@rm -rf ./bd/c2cSlave
clean_bit:
	@echo "Cleaning up bit files"
	@rm -rf $(BIT)
clean_os:
	@echo "Clean OS hw files"
	@rm -f os/hw/*
clean: clean_bd clean_ip clean_bit clean_os clean_vhd
	@rm -rf ./proj/*
	@echo "Cleaning up"


#################################################################################
# Open vivado
#################################################################################

open_project : 
	@$(VIVADO_SETUP) &&\
	vivado top.xpr
open_synth :
	@$(VIVADO_SETUP) &&\
	vivado post_synth.dcp
open_impl :
	@$(VIVADO_SETUP) &&\
	vivado post_route.dcp
open_hw :
	@$(VIVADO_SETUP) &&\
	vivado -source ../$(HW_TCL)


#################################################################################
# Generate MAP and PKG files automatically
#################################################################################
export LD_LIBRARY_PATH=/opt/cactus/lib
SRC_PATH=src
ADDR_PATH=address_tables

automap : $(MAP_OBJS)
# need to extract dir name and path name here

%_map.vhd %_PKG.vhd : %.xml
	cd $(dir $<) &&\
	../../$(ADDR_PATH)/generate_test_xml $(basename $(notdir $<)) &&\
	../../$(ADDR_PATH)/build_vhdl_packages test.xml


#################################################################################
# FPGA building
#################################################################################
bit	: $(BIT)

interactive : 
	@$(VIVADO_SETUP) &&\
	vivado -mode tcl
$(BIT)	:
	@mkdir -p bit
	@$(VIVADO_SETUP) &&\
	vivado $(VIVADO_FLAGS) -source ../$(SETUP_BUILD_TCL) $(OUTPUT_MARKUP)
SVF	:
	@$(VIVADO_SETUP) &&\
	vivado $(VIVADO_FLAGS) -source ../scripts/Generate_svf.tcl $(OUTPUT_MARKUP)

#################################################################################
# Help 
#################################################################################

#list magic: https://stackoverflow.com/questions/4219255/how-do-you-get-the-list-of-targets-in-a-makefile
list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | column

