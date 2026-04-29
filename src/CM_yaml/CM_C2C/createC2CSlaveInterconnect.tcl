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

#================================================================================
#  Export internal fabric clock for external AXI ports
#================================================================================
# After moving the AXI fabric clock behind a clk_wiz (e.g. c2c_clk_wiz_100to200/clk_out1),
# Vivado validate_bd_design expects an *external clock port* with CONFIG.ASSOCIATED_BUSIF
# listing any external AXI interface ports (e.g. /F1_IPBUS, /F1_IO, ...).
#
# Export clk_out1 as an output port and associate all AXI* interface ports to it.
_safe_call "export AXI fabric clock port" {
	set _clk_wiz_name "c2c_clk_wiz_100to200"
	set _clk_pin [get_bd_pins -quiet ${_clk_wiz_name}/clk_out1]
	if {[llength $_clk_pin] == 0} {
		puts "[info script]: INFO: no ${_clk_wiz_name}/clk_out1 pin found; skipping export"
	} else {
		set _clk_port_name "AXI_MASTER_CLK_OUT"
		set _clk_port [get_bd_ports -quiet $_clk_port_name]
		if {![llength $_clk_port]} {
			# Prefer make_bd_pins_external (Vivado sets up port metadata), but in some
			# Vivado versions/contexts it can return an empty list without raising.
			set _created_ports [list]
			if {[catch {
				set _created_ports [make_bd_pins_external -name $_clk_port_name $_clk_pin]
			} _mbpe_err]} {
				puts "[info script]: WARNING: make_bd_pins_external failed for ${_clk_port_name}: ${_mbpe_err}"
				set _created_ports [list]
			}
			set _clk_port [lindex $_created_ports 0]
			if {![llength $_clk_port]} {
				# Fallback: explicitly create a clock port and connect it to the net.
				# This mirrors how other exported pins (e.g. SYS_RESET_bus_rst_n) are ultimately represented.
				puts "[info script]: WARNING: make_bd_pins_external produced no port for ${_clk_port_name}; using create_bd_port fallback"
				set _clk_port [create_bd_port -dir O -type clk $_clk_port_name]
				catch {connect_bd_net -quiet $_clk_pin $_clk_port}
				# Best-effort: propagate frequency metadata from source pin onto the port.
				set _freq_hz ""
				catch {set _freq_hz [get_property -quiet CONFIG.FREQ_HZ $_clk_pin]}
				if {$_freq_hz eq ""} {
					catch {set _freq_hz [get_property -quiet FREQ_HZ $_clk_pin]}
				}
				if {$_freq_hz ne ""} {
					catch {set_property CONFIG.FREQ_HZ $_freq_hz $_clk_port}
				}
			}
		}
		if {![llength $_clk_port]} {
			puts "[info script]: WARNING: failed to export fabric clock port ${_clk_port_name}; skipping ASSOCIATED_BUSIF"
		} else {
			# Build ASSOCIATED_BUSIF list from top-level AXI interface ports.
			# Note: some interface ports don't populate CONFIG.PROTOCOL reliably across Vivado/IP versions,
			# so also fall back to VLNV-based detection.
			set _busifs [list]
			foreach _p [get_bd_intf_ports -quiet] {
				set _name [get_property -quiet NAME $_p]
				set _prot [get_property -quiet CONFIG.PROTOCOL $_p]
				set _vlnv [string tolower [get_property -quiet VLNV $_p]]
				set _mode [string tolower [get_property -quiet MODE $_p]]

				set _is_axi 0
				if {$_prot ne "" && [string match "AXI*" $_prot]} {
					set _is_axi 1
				} elseif {$_vlnv ne ""} {
					# Common Vivado interface VLNVs:
					# - xilinx.com:interface:aximm_rtl:1.0
					# - xilinx.com:interface:aximm:1.0
					# - xilinx.com:interface:axilite_rtl:1.0
					# - xilinx.com:interface:axilite:1.0
					if {[string match "*:aximm*" $_vlnv] || [string match "*:axilite*" $_vlnv]} {
						set _is_axi 1
					}
				}

				# As a last resort, include unknown-protocol MASTER/SLAVE ports; this is safe and
				# avoids BD 41-2559 when Vivado doesn't tag the interface as AXI.
				if {!$_is_axi && ($_mode eq "master" || $_mode eq "slave") && $_name ne ""} {
					set _is_axi 1
				}

				if {$_is_axi} {
					lappend _busifs $_name
				}
			}
			# If detection failed entirely, associate everything so validation passes.
			if {[llength $_busifs] == 0} {
				foreach _p [get_bd_intf_ports -quiet] {
					set _name [get_property -quiet NAME $_p]
					if {$_name ne ""} { lappend _busifs $_name }
				}
			}
			if {[llength $_busifs] > 0} {
				set _assoc [join $_busifs ":"]
				if {[catch {set_property CONFIG.ASSOCIATED_BUSIF $_assoc $_clk_port} _err]} {
					puts "[info script]: WARNING: could not set ASSOCIATED_BUSIF on ${_clk_port_name}: ${_err}"
				} else {
					puts "[info script]: exported $_clk_port_name and set ASSOCIATED_BUSIF=$_assoc"
				}
			} else {
				puts "[info script]: INFO: no AXI* bd interface ports found; skipping ASSOCIATED_BUSIF"
			}
		}
	}
}

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
_ensure_vhdl_in_sources_1 $wrapper_file_sane



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

# Refresh compile order once a top module exists in sources_1.
# Doing this earlier (before wrapper import) can trigger filemgmt 20-730.
catch {update_compile_order -fileset sources_1}

# Ensure the updated sources list is persisted for later synth steps.
catch {save_project}
