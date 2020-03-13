#this has to be called from inside an open session
source ../scripts/settings.tcl

#add the device info for the uC
#set device-info-file ../scripts/CM_uC_dev_info.csv

set SVF_TARGET svf_top



#derived from walkthrough https://blog.xjtag.com/2016/07/creating-svf-files-using-xilinx-vivado/
open_hw
delete_hw_target -quiet ${SVF_TARGET}
create_hw_target ${SVF_TARGET}
open_hw_target [get_hw_targets -regexp .*/${SVF_TARGET}]

#add the uC to the chain
#create_hw_device -idcode 4BA00477

#add the kintex to the chain
set DEVICE [create_hw_device -part ${FPGA_part}]
set_property PROGRAM.FILE {../bit/top.bit} $DEVICE
set_param xicom.config_chunk_size 0
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

#add the virtex to the chain
create_hw_device -part xcvu7p-flvb2104-1-e

program_hw_devices -force -svf_file {../bit/top.svf} ${DEVICE}

