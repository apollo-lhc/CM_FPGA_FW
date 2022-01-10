#build dtbo files from dtsi files
DTSI_PATH ?= kernel/hw
DTSI_FILES_FULL_PATH = $(wildcard ${DTSI_PATH}/*.dtsi)
DTSI_FILES = $(notdir ${DTSI_FILES_FULL_PATH})

#place dtbo files in a subdirectory of the dtsi path
DTBO_PATH ?= ${DTSI_PATH}/dtbo
DTBO_FILES = $(patsubst %.dtsi,${DTBO_PATH}/%.dtbo,${DTSI_FILES})

overlays: ${DTBO_FILES}

${DTBO_PATH}/%.dtbo:${DTSI_PATH}/%.dtsi
	mkdir -p ${DTBO_PATH} >& /dev/null
	dtc -O dtb -o $@ -b 0 -@ $<
