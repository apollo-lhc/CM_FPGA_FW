#this is an example to build from and only generate_svf.tcl files in the configs/build_name directories will be called


#this has to be called from inside an open session
source ../build-scripts/settings.tcl

#add the device info for the uC
#set device-info-file ../scripts/CM_uC_dev_info.csv

set SVF_TARGET [format "svf_top%06u" [expr {round(1000000 *rand())}]]



#derived from walkthrough https://blog.xjtag.com/2016/07/creating-svf-files-using-xilinx-vivado/
open_hw
if { [string length [get_hw_targets -quiet -regexp .*/${SVF_TARGET}] ]  } {
  delete_hw_target -quiet [get_hw_targets -regexp .*/${SVF_TARGET}]
}
create_hw_target ${SVF_TARGET}
close_hw_target
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

write_cfgmem -force -loadbit "up 0 ../bit/top.bit" -format mcs -size 128 -file "../bit/top.mcs"

delete_hw_target -quiet [get_hw_targets -regexp .*/${SVF_TARGET}]
