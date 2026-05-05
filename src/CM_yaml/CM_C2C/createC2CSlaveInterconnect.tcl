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

# Some builds intentionally omit the AXI4-domain CM_INTERCONNECT. However, base YAMLs may
# still contain "${::CM_INTERCONNECT}" placeholders and yaml_to_bd will "subst" them.
# Ensure the variable exists so substitution does not error; an empty value means
# no interconnect instance is referenced.
if {![info exists ::CM_INTERCONNECT]} {
	set ::CM_INTERCONNECT ""
}

# emp-fwk's apollo_set_paths.tcl may set autogen_path to an absolute path.
# Some CM BD helper scripts assume autogen_path is repo-relative and build paths as
# "${apollo_root_path}/${autogen_path}". Normalize back to repo-relative when possible.
if {[file pathtype $::autogen_path] eq "absolute"} {
	set _prefix "[file normalize ${::apollo_root_path}]/"
	set _auto_norm [file normalize $::autogen_path]
	if {[string first $_prefix $_auto_norm] == 0} {
		set ::autogen_path [string range $_auto_norm [string length $_prefix] end]
	}
}

proc _abs_path {path_in} {
	# Accept either an absolute path, or a repo-relative path.
	# emp-fwk's apollo_set_paths.tcl sets autogen_path to an absolute path.
	if {[file pathtype $path_in] eq "absolute"} {
		return [file normalize $path_in]
	}
	return [file normalize [file join $::apollo_root_path $path_in]]
}

# Ensure autogen output directory exists for package generation.
set ::autogen_dir [_abs_path $::autogen_path]
file mkdir $::autogen_dir

puts "[info script]: apollo_root_path=${::apollo_root_path}"
puts "[info script]: build_name=${::build_name}"
puts "[info script]: autogen_path=${::autogen_path}"
puts "[info script]: autogen_dir=${::autogen_dir}"

# Print git revision for debugging CI picking the right CM_FPGA_FW commit.
set _git_rev "unknown"
catch {
	set _repo_dir [file normalize $::apollo_root_path]
	set _pwd_save [pwd]
	cd $_repo_dir
	set _git_rev [string trim [exec git rev-parse --short HEAD]]
	cd $_pwd_save
}
puts "[info script]: CM_FPGA_FW git=${_git_rev}"

puts "[info script]: starting BD helper sourcing"

proc _safe_source {path} {
	puts "[info script]: source $path"
	if {[catch {uplevel 1 [list source $path]} err opts]} {
		puts "[info script]: ERROR sourcing $path: $err"
		if {[dict exists $opts -errorinfo]} {
			puts "[info script]: errorinfo: [dict get $opts -errorinfo]"
		}
		error $err
	}
	puts "[info script]: sourced $path"
}

proc _safe_call {label script_body} {
	puts "[info script]: begin $label"
	if {[catch {uplevel 1 $script_body} err opts]} {
		puts "[info script]: ERROR in $label: $err"
		if {[dict exists $opts -errorinfo]} {
			puts "[info script]: errorinfo: [dict get $opts -errorinfo]"
		}
		error $err
	}
	puts "[info script]: end $label"
}

proc _get_target_vhdl_lib {} {
	# In Vivado, VHDL 'work' resolves to the project's default library.
	# Keep generated packages in that same library so 'use work.*' succeeds.
	set lib ""
	if {![catch {set lib [get_property default_lib [current_project]]}]} {
		if {$lib ne ""} {
			return $lib
		}
	}
	return "xil_defaultlib"
}

proc _ensure_vhdl_in_sources_1 {vhd_path} {
	set vhd_path [file normalize $vhd_path]
	if {![file exists $vhd_path]} {
		error "VHDL file does not exist: $vhd_path"
	}

	# Ensure file is part of the synthesis sources fileset.
	if {![llength [get_files -quiet $vhd_path]]} {
		add_files -fileset sources_1 -norecurse $vhd_path
	}

	set target_lib [_get_target_vhdl_lib]
	catch {set_property library $target_lib [get_files $vhd_path]}
	puts "[info script]: ensured source: ${vhd_path} (in_project=[llength [get_files -quiet $vhd_path]] lib=${target_lib})"

	# Refresh compile order so packages are compiled before dependent VHDL.
	catch {update_compile_order -fileset sources_1}
}

_safe_source ${apollo_root_path}/bd/axi_helpers.tcl
_safe_source ${apollo_root_path}/bd/AXI_Cores/Xilinx_AXI_Endpoints.tcl
_safe_source ${apollo_root_path}/bd/Cores/Xilinx_Cores.tcl
_safe_source ${apollo_root_path}/bd/HAL/HAL.tcl
_safe_source ${apollo_root_path}/bd/utils/add_slaves_from_yaml.tcl
_safe_source ${apollo_root_path}/bd/utils/Global_Constants.tcl


#create a block design called "c2cSlave"
#directory and name must be the same
set bd_design_name "c2cSlave"
_safe_call "create_bd_design ${bd_design_name}" [list create_bd_design -dir ./ ${bd_design_name}]


#================================================================================
#  Configure and add AXI slaves
#================================================================================
_safe_call "source add_slaves_from_yaml.tcl" [list source -quiet ${apollo_root_path}/bd/add_slaves_from_yaml.tcl]
_safe_call "yaml_to_bd config.yaml" [list yaml_to_bd "${apollo_root_path}/configs/${build_name}/config.yaml"]

puts "[info script]: generating AXI slave address-map packages"
_safe_call "GENERATE_AXI_ADDR_MAP_C" [list GENERATE_AXI_ADDR_MAP_C "${::autogen_dir}/AXI_slave_addrs.h"]
_safe_call "GENERATE_AXI_ADDR_MAP_VHDL" [list GENERATE_AXI_ADDR_MAP_VHDL "${::autogen_dir}/AXI_slave_pkg.vhd"]
set axi_slave_pkg_vhd "${::autogen_dir}/AXI_slave_pkg.vhd"
if {![file exists $axi_slave_pkg_vhd]} {
	error "AXI slave package VHDL was not generated: $axi_slave_pkg_vhd"
}
_safe_call "read_vhdl AXI_slave_pkg" [list read_vhdl -library [_get_target_vhdl_lib] $axi_slave_pkg_vhd]
_ensure_vhdl_in_sources_1 $axi_slave_pkg_vhd

#========================================
#  Finish up
#========================================


_safe_call "validate_bd_design" {validate_bd_design}

_safe_call "make_wrapper import" [list make_wrapper -files [get_files ${bd_design_name}.bd] -top -import -force]
set wrapper_file [make_wrapper -files [get_files $bd_design_name.bd] -top -force]
set wrapper_file_sane [string map {_wrapper.vhd _sane_wrapper.vhd} $wrapper_file]
puts "Modifying ${bd_design_name} wrapper file ${wrapper_file}"
set output_text [exec ${apollo_root_path}/build-scripts/update_bd_wrapper.py -i $wrapper_file -o $wrapper_file_sane]
puts "Adding ${wrapper_file_sane}"
read_vhdl $wrapper_file_sane



_safe_call "save_bd_design" {save_bd_design}
_safe_call "close_bd_design" [list close_bd_design ${bd_design_name}]




puts "[info script]: generating Global_PKG"
_safe_call "Generate_Global_package" {Generate_Global_package}

set global_pkg_vhd "${::autogen_dir}/Global_PKG.vhd"
if {![file exists $global_pkg_vhd]} {
	error "Global package VHDL was not generated: $global_pkg_vhd (autogen_path=${autogen_path})"
}
_safe_call "read_vhdl Global_PKG" [list read_vhdl -library [_get_target_vhdl_lib] $global_pkg_vhd]
_ensure_vhdl_in_sources_1 $global_pkg_vhd

# Ensure the updated sources list is persisted for later synth steps.
catch {save_project}
