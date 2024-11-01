#this has to be called from inside an open session
source ${apollo_root_path}/configs/${build_name}/settings.tcl

set SVF_TARGET [format "svf_top%06u" [expr {round(1000000 *rand())}]]



#derived from walkthrough https://blog.xjtag.com/2016/07/creating-svf-files-using-xilinx-vivado/
open_hw
if { [string length [get_hw_targets -quiet -regexp .*/${SVF_TARGET}] ]  } {
  delete_hw_target -quiet [get_hw_targets -regexp .*/${SVF_TARGET}]
}
create_hw_target ${SVF_TARGET}
close_hw_target
open_hw_target [get_hw_targets -regexp .*/${SVF_TARGET}]


#1st in chain, no need to add another FPGA to the chain

#add the virtex to the chain
set DEVICE [create_hw_device -part ${FPGA_part}]
set_property PROGRAM.FILE ${apollo_root_path}/bit/top_${build_name}.bit $DEVICE
set_param xicom.config_chunk_size 0
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.Config.SPI_BUSWIDTH 4 [current_design]

#2nd chain
create_hw_device -part xcvu13p-flga2577-1-e

program_hw_devices -force -svf_file ${apollo_root_path}/bit/top_${build_name}.svf ${DEVICE}

write_cfgmem -force -interface spix4 -loadbit "up 0 ${apollo_root_path}/bit/top_${build_name}.bit" -format mcs -size 128 -file "${apollo_root_path}/bit/top_${build_name}.mcs"

delete_hw_target -quiet [get_hw_targets -regexp .*/${SVF_TARGET}]
