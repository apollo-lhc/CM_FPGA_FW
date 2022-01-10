include build-scripts/mk/helpers.mk

#################################################################################
# VIVADO stuff
#################################################################################
VIVADO_FLAGS=-notrace -mode batch
BUILD_VIVADO_VERSION?=2020.2
BUILD_VIVADO_BASE?="/work/Xilinx/Vivado"
BUILD_VIVADO_SHELL=${BUILD_VIVADO_BASE}"/"$(BUILD_VIVADO_VERSION)"/settings64.sh"


#################################################################################
# TCL scripts
#################################################################################
BUILD_SCRIPTS_PATH=${MAKE_PATH}/build-scripts
SETUP_TCL=${BUILD_SCRIPTS_PATH}/Setup.tcl
BUILD_TCL=${BUILD_SCRIPTS_PATH}/Build.tcl
SETUP_BUILD_TCL=${BUILD_SCRIPTS_PATH}/SetupAndBuild.tcl
HW_TCL=${BUILD_SCRIPTS_PATH}/Run_hw.tcl

#################################################################################
# Source files
#################################################################################
PL_PATH=${MAKE_PATH}/src
BD_PATH=${MAKE_PATH}/bd
CORES_PATH=${MAKE_PATH}/cores
ADDRESS_TABLE = ${MAKE_PATH}/os/address_table/address_CM.xml

################################################################################
# Configs
#################################################################################
CONFIGS_BASE_PATH=configs/
#get a list of the subdirs in configs.  These are our FPGA builds
CONFIGS=$(patsubst ${CONFIGS_BASE_PATH}%/,%,$(dir $(wildcard ${CONFIGS_BASE_PATH}*/)))

define CONFIGS_template =
 $(1): clean autogen_clean_$(1)
	time $(MAKE) $(BIT_BASE)$$(@).bit || $(MAKE) NOTIFY_DAN_BAD
endef
define CONFIGS_autoclean_template =
 autogen_clean_$(1): 
	@rm -rf ${CONFIGS_BASE_PATH}$(1)/autogen/*
endef

################################################################################
# Short build names
#################################################################################
BIT_BASE=${MAKE_PATH}/bit/top_

#################################################################################
# preBuild 
#################################################################################
SLAVE_DEF_FILE_BASE=${MAKE_PATH}/${CONFIGS_BASE_PATH}
ADDSLAVE_TCL_PATH=${MAKE_PATH}/src/ZynqPS/
ADDRESS_TABLE_CREATION_PATH=${MAKE_PATH}/os/
SLAVE_DTSI_PATH=${MAKE_PATH}/kernel/
MAP_TEMPLATE_FILE=${MAKE_PATH}/regmap_helper/templates/axi_generic/template_map.vhd

ifneq ("$(wildcard ${BUILD_SCRIPTS_PATH}/mk/preBuild.mk)","")
  include ${BUILD_SCRIPTS_PATH}/mk/preBuild.mk
endif



#################################################################################
# CM Address tables
#################################################################################
include build-scripts/mk/addrTable.mk

#################################################################################
# Device tree overlays
#################################################################################
DTSI_PATH=${SLAVE_DTSI_PATH}/hw/
include build-scripts/mk/deviceTreeOverlays.mk


.SECONDARY:

.PHONY: clean list bit NOTIFY_DAN_BAD NOTIFY_DAN_GOOD init $(CONFIGS) $(PREBUILDS)

#################################################################################
# Clean
#################################################################################
clean_ip:
	@echo "Cleaning up ip dcps"
	@find ${MAKE_PATH}/cores -type f -name '*.dcp' -delete
clean_bd:
	@echo "Cleaning up bd generated files"
	@rm -rf ${MAKE_PATH}/bd/zynq_bd
	@rm -rf ${MAKE_PATH}/bd/c2cSlave
clean_bit:
	@echo "Cleaning up bit files"
	@rm -rf ${MAKE_PATH}/bit/*
clean_kernel:
	@echo "Clean hw files"
	@rm -rf ${MAKE_PATH}/kernel/hw/*
clean: clean_bd clean_ip clean_bit clean_kernel clean_prebuild 
	@rm -rf ${MAKE_PATH}/proj/*
	@rm -f make_log.txt
	@echo "Cleaning up"
clean_ip_%:
	source $(BUILD_VIVADO_SHELL) &&\
	cd ${MAKE_PATH}/proj &&\
	vivado $(VIVADO_FLAGS) -source ${BUILD_SCRIPTS_PATH}/CleanIPs.tcl -tclargs ${MAKE_PATH} $(subst .bit,,$(subst clean_ip_,,$@))
clean_autogen:
	rm -rf ${CONFIGS_BASE_PATH}*/autogen/*

clean_everything: clean clean_prebuild

#generate autogen cleanup for this config
$(foreach config,$(CONFIGS),$(eval $(call CONFIGS_autoclean_template,$(config))))

#################################################################################
# Open vivado
#################################################################################

open_project : 
	source $(BUILD_VIVADO_SHELL) &&\
	cd ${MAKE_PATH}/proj &&\
	vivado top.xpr -source ../build-scripts/OpenProject.tcl
open_synth :
	source $(BUILD_VIVADO_SHELL) &&\
	cd ${MAKE_PATH}/proj &&\
	vivado post_synth.dcp
open_impl :
	source $(BUILD_VIVADO_SHELL) &&\
	cd ${MAKE_PATH}/proj &&\
	vivado post_route.dcp
open_hw :
	source $(BUILD_VIVADO_SHELL) &&\
	cd ${MAKE_PATH}/proj &&\
	vivado -source $(HW_TCL)


#################################################################################
# FPGA building
#################################################################################
#generate a build rule for each FPGA in the configs dir ($CONFIGS)c
$(foreach config,$(CONFIGS),$(eval $(call CONFIGS_template,$(config))))

interactive : 
	source $(BUILD_VIVADO_SHELL) &&\
	mkdir -p ${MAKE_PATH}/proj &&\
	cd proj &&\
	vivado -mode tcl

$(BIT_BASE)%.bit $(BIT_BASE)%.svf	: $(SLAVE_DTSI_PATH)/slaves_%.yaml $(ADDRESS_TABLE_CREATION_PATH)/slaves_%.yaml
	source $(BUILD_VIVADO_SHELL) &&\
	mkdir -p ${MAKE_PATH}/kernel/hw &&\
	mkdir -p ${MAKE_PATH}/proj &&\
	mkdir -p ${MAKE_PATH}/bit &&\
	cd proj &&\
	vivado $(VIVADO_FLAGS) -source $(SETUP_BUILD_TCL) -tclargs ${MAKE_PATH} ${BUILD_SCRIPTS_PATH} $(subst .bit,,$(subst ${BIT_BASE},,$@)) $(OUTPUT_MARKUP)
	$(MAKE) NOTIFY_DAN_GOOD
	$(MAKE) overlays
	$(MAKE) ${MAKE_PATH}/os/address_table/address_$*.xml
	@echo 	$(MAKE) $*.tar.gz
	$(MAKE) $*.tar.gz

SVF	:
	@$(VIVADO_SETUP) &&\
	vivado $(VIVADO_FLAGS) -source ${BUILD_SCRIPTS_PATH}/Generate_svf.tcl $(OUTPUT_MARKUP)


#convert all push urls to ssh
init:
	git submodule update --init --recursive
	@git submodule foreach 'git remote -v | grep http |  grep \(push\) | sed -e "i\git remote set-url --push " -e "s/http.*\/\//git\@/" -e "s/\//:/" -e"s/(push)//" | xargs | bash'





make test :
	@echo $(CONFIGS)

%.tar.gz : bit/top_%.svf kernel/hw/dtbo/*.dtbo os/address_table/
	@tar -zcf $@ $< -C kernel/hw/ dtbo -C ../../os/ address_table
