# Non-project mode
# re-generat the fw_version.vhd file

puts $argc
puts $argv

if {$argc == 1} {
    set apollo_root_path [lindex $argv 0]
} else {
    set apollo_root_path ".."
}

puts "Using path: ${apollo_root_path}"
puts $argc
puts $argv

if { $argc == 2 } {
    set build_name       [lindex $argv 1]
    set apollo_root_path [lindex $argv 0]
} elseif {$argc == 1} {
    set build_name "xc7z035"
    set apollo_root_path [lindex $argv 0]
} else {
    set build_name "Cornell_rev1_p2_VU7p-1-SM_7s"
    set apollo_root_path ".."
}

puts "Using path: ${apollo_root_path}"
puts "Building: ${build_name}"

source ${apollo_root_path}/configs/${build_name}/settings.tcl
source ${apollo_root_path}/scripts/FW_info.tcl

[build_fw_version ${apollo_root_path}/src $FPGA_part]

