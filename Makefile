include mk/helpers.mk

#################################################################################
# VIVADO stuff
#################################################################################
VIVADO_VERSION=2018.2
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
PL_PATH=${MAKE_PATH}/src
BD_PATH=${MAKE_PATH}/bd
CORES_PATH=${MAKE_PATH}/cores
ADDRESS_TABLE = ${MAKE_PATH}/os/address_table/address_apollo.xml

################################################################################
# Short build names
#################################################################################

BIT_BASE=${MAKE_PATH}/bit/top_

.SECONDARY:

.PHONY: clean list bit NOTIFY_DAN_BAD NOTIFY_DAN_GOOD init

#################################################################################
# preBuild 
#################################################################################
SLAVE_DEF_FILE_BASE=${MAKE_PATH}/configs/
ADDSLAVE_TCL_PATH=src/c2cSlave/
ADDRESS_TABLE_CREATION_PATH=${MAKE_PATH}/os/
SLAVE_DTSI_PATH=${MAKE_PATH}/kernel/

ifneq ("$(wildcard ${MAKE_PATH}/mk/preBuild.mk)","")
  include ${MAKE_PATH}/mk/preBuild.mk
endif

#################################################################################
# address tables
#################################################################################
ifneq ("$(wildcard ${MAKE_PATH}/mk/addrTable.mk)","")
  include ${MAKE_PATH}/mk/addrTable.mk
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
Cornell_rev1_Kintex	: 
	time $(MAKE) $(BIT_BASE)$@.bit || $(MAKE) NOTIFY_DAN_BAD

interactive : 
	source $(BUILD_VIVADO_SHELL) &&\
	mkdir -p ${MAKE_PATH}/proj &&\
	cd proj &&\
	vivado -mode tcl

$(BIT_BASE)%.bit	: $(ADDSLAVE_TCL_PATH)/AddSlaves_%.tcl 
	source $(BUILD_VIVADO_SHELL) &&\
	mkdir -p ${MAKE_PATH}/kernel/hw &&\
	mkdir -p ${MAKE_PATH}/proj &&\
	mkdir -p ${MAKE_PATH}/bit &&\
	cd proj &&\
	vivado $(VIVADO_FLAGS) -source $(SETUP_BUILD_TCL) -tclargs ${MAKE_PATH} $(subst .bit,,$(subst ${BIT_BASE},,$@)) $(OUTPUT_MARKUP)
	$(MAKE) NOTIFY_DAN_GOOD
bit	: $(BIT)

SVF	:
	@$(VIVADO_SETUP) &&\
	vivado $(VIVADO_FLAGS) -source ../scripts/Generate_svf.tcl $(OUTPUT_MARKUP)


init:
	git submodule update --init --recursive
