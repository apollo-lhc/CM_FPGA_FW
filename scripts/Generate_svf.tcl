#this has to be called from inside an open session
source ../scripts/settings.tcl

set SVF_TARGET svf_top


#derived from walkthrough https://blog.xjtag.com/2016/07/creating-svf-files-using-xilinx-vivado/
open_hw
create_hw_target ${SVF_TARGET}
open_hw_target [get_hw_targets -regexp .*/${SVF_TARGET}]
set DEVICE [create_hw_device -part ${FPGA_part}]

set_property PROGRAM.FILE {../bit/top.bit} $DEVICE
set_param xicom.config_chunk_size 0
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

program_hw_devices -force -svf_file {../bit/top.svf} ${DEVICE}

