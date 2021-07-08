#################################################################################
# make stuff
#################################################################################
#output markup
OUTPUT_MARKUP= 2>&1 | tee ../make_log.txt | ccze -A

#################################################################################
# VIVADO stuff
#################################################################################
#VIVADO_VERSION=2018.2
VIVADO_VERSION=2018.3
#VIVADO_VERSION=2020.1
VIVADO_FLAGS=-notrace -mode batch
VIVADO_SHELL="/opt/Xilinx/Vivado/"$(VIVADO_VERSION)"/settings64.sh"
VIVADO_SETUP=source $(VIVADO_SHELL) && mkdir -p proj && mkdir -p kernel/hw && cd proj


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

.PHONY: clean list bit

all: bit 


#################################################################################
# Git submodules.
#################################################################################

submodules: bd/IP

bd/IP:
	@git submodule update --init --recursive


#################################################################################
# preBuild 
#################################################################################
SLAVE_DEF_FILE=src/slaves.yaml
ADDSLAVE_TCL_PATH=src/c2cSlave/
ADDRESS_TABLE_CREATION_PATH=os/
SLAVE_DTSI_PATH=kernel/

ifneq ("$(wildcard mk/preBuild.mk)","")
  include mk/preBuild.mk
endif


#################################################################################
# Clean
#################################################################################
clean_ip:
	@echo "Cleaning up ip dcps"
	@find ./cores -type f -name '*.dcp' -delete
clean_bd:
	@echo "Cleaning up bd generated files"
	@rm -rf ./bd/zynq_bd
	@rm -rf ./bd/c2cSlave
clean_bit:
	@echo "Cleaning up bit files"
	@rm -rf ./bit/*
clean_os:
	@echo "Clean OS hw files"
	@rm -f kernel/hw/*
clean: clean_bd clean_ip clean_bit clean_os
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
# FPGA building
#################################################################################
bit	: $(BIT)

interactive : submodules
	@$(VIVADO_SETUP) &&\
	vivado -mode tcl
$(BIT) : submodules
	@mkdir -p bit
	@$(VIVADO_SETUP) &&\
	vivado $(VIVADO_FLAGS) -source ../$(SETUP_BUILD_TCL) $(OUTPUT_MARKUP)
SVF	: submodules
	@$(VIVADO_SETUP) &&\
	vivado $(VIVADO_FLAGS) -source ../scripts/Generate_svf.tcl $(OUTPUT_MARKUP)

################################################################################# 
# Generate MAP and PKG files from address table 
################################################################################# 
XML2VHD_PATH=regmap_helper
ifneq ("$(wildcard $(XML2VHD_PATH)/xml_regmap.mk)","")
	include $(XML2VHD_PATH)/xml_regmap.mk
endif



#################################################################################
# Help 
#################################################################################

#list magic: https://stackoverflow.com/questions/4219255/how-do-you-get-the-list-of-targets-in-a-makefile
list:
	@$(MAKE) -pRrq -f $(MAKEFILE_LIST) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | column

init:
	git submodule update --init --recursive
