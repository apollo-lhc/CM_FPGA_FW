###
# EMP/ipbb note:
# In CI the emp-fwk "setup -c ... apollo_set_paths.tcl" step can run *after* this script,
# so we must be able to derive the key path globals ourselves when they are not set yet.
###

if {![info exists ::apollo_root_path]} {
	# This file lives at: <repo>/src/CM_yaml/CM_C2C/createC2CSlaveInterconnect.tcl
	# Go up 3 levels from CM_C2C/ to reach the repo root.
	set ::apollo_root_path [file normalize [file join [file dirname [info script]] .. .. ..]]
}

if {![info exists ::BD_PATH]} {
	set ::BD_PATH "${::apollo_root_path}/bd"
}

if {![info exists ::build_name]} {
	# EMP builds normally set this in the board cfg (e.g. v2_p1.tcl). If not, fall back to cwd name.
	set ::build_name [file tail [pwd]]
}

if {![info exists ::autogen_path]} {
	set ::autogen_path "configs/${::build_name}/autogen"
}

# Ensure autogen output directory exists for package generation.
file mkdir "${::apollo_root_path}/configs/${::build_name}/autogen"

puts "[info script]: apollo_root_path=${::apollo_root_path}"
puts "[info script]: build_name=${::build_name}"
puts "[info script]: autogen_path=${::autogen_path}"

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
set axi_slave_pkg_vhd "${apollo_root_path}/configs/${build_name}/autogen/AXI_slave_pkg.vhd"
if {![file exists $axi_slave_pkg_vhd]} {
	error "AXI slave package VHDL was not generated: $axi_slave_pkg_vhd"
}
read_vhdl $axi_slave_pkg_vhd

# Some emp-fwk flows may source this script in a context where read_vhdl doesn't persist into sources_1.
# Ensure the generated package is present in the project sources.
if {![llength [get_files -quiet $axi_slave_pkg_vhd]]} {
	add_files -fileset sources_1 -norecurse $axi_slave_pkg_vhd
}

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

set global_pkg_vhd "${apollo_root_path}/${autogen_path}/Global_PKG.vhd"
if {![file exists $global_pkg_vhd]} {
	error "Global package VHDL was not generated: $global_pkg_vhd (autogen_path=${autogen_path})"
}
if {![llength [get_files -quiet $global_pkg_vhd]]} {
	# Force-add to sources_1 for synthesis.
	add_files -fileset sources_1 -norecurse $global_pkg_vhd
}
