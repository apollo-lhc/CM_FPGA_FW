source ${apollo_root_path}/bd/axi_helpers.tcl
source ${apollo_root_path}/bd/AXI_Cores/Xilinx_AXI_Endpoints.tcl 
source ${apollo_root_path}/bd/Cores/Xilinx_Cores.tcl
source ${apollo_root_path}/bd/HAL/HAL.tcl
source ${apollo_root_path}/bd/utils/add_slaves_from_yaml.tcl
source ${apollo_root_path}/bd/utils/Global_Constants.tcl


#create a block design called "c2cSlave"
#directory and name must be the same
set bd_design_name "c2cSlave"
create_bd_design -dir ./ ${bd_design_name}


#================================================================================
#  Configure and add AXI slaves
#================================================================================
source -quiet ${apollo_root_path}/bd/add_slaves_from_yaml.tcl
yaml_to_bd "${apollo_root_path}/configs/${build_name}/config.yaml"

GENERATE_AXI_ADDR_MAP_C "${apollo_root_path}/configs/${build_name}/autogen/AXI_slave_addrs.h"                                                                                                 
GENERATE_AXI_ADDR_MAP_VHDL "${apollo_root_path}/configs/${build_name}/autogen/AXI_slave_pkg.vhd"                                                                                              
read_vhdl "${apollo_root_path}/configs/${build_name}/autogen/AXI_slave_pkg.vhd"      

#========================================
#  Finish up
#========================================


validate_bd_design

make_wrapper -files [get_files ${bd_design_name}.bd] -top -import -force
set wrapper_file [make_wrapper -files [get_files $bd_design_name.bd] -top -force]
set wrapper_file_sane [string map {_wrapper.vhd _sane_wrapper.vhd} $wrapper_file]
puts "Modifying ${bd_design_name} wrapper file ${wrapper_file}"
set output_text [exec ${apollo_root_path}/build-scripts/update_bd_wrapper.py -i $wrapper_file -o $wrapper_file_sane]
puts "Adding ${wrapper_file_sane}"
read_vhdl $wrapper_file_sane



save_bd_design

close_bd_design ${bd_design_name}




Generate_Global_package
