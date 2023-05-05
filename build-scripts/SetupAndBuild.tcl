#################################################################################
## Figure out build options and paths
#################################################################################

puts $argc
puts $argv

if { $argc == 3 } {
    set build_name       [lindex $argv 2]
    set build_scripts_path [lindex $argv 1]
    set apollo_root_path [lindex $argv 0]
} elseif {$argc == 2} {
    set build_name "xc7z035"
    set build_scripts_path [lindex $argv 1]
    set apollo_root_path [lindex $argv 0]
} elseif {$argc == 1} {
    set build_name "xc7z035"
    set apollo_root_path [lindex $argv 0]
    set build_scripts_path ${apollo_root_path}/build-scripts
} else {
    set build_name "xc7z035"
    set apollo_root_path ".."
    set build_scripts_path ${apollo_root_path}/build-scripts
}

set autogen_path configs/${build_name}/autogen
file mkdir ${apollo_root_path}/$autogen_path

set BD_PATH ${apollo_root_path}/bd

puts "Using path: ${apollo_root_path}"
puts "Build scripts path: ${build_scripts_path}"
puts "Building: ${build_name}"
puts "Autogen path: ${autogen_path}"
puts "BD_PATH: ${BD_PATH}"

#################################################################################
## Run & time process
#################################################################################

set start_time [clock seconds]
source ${build_scripts_path}/Setup.tcl
set setup_end_time [clock seconds]
source ${build_scripts_path}/Build.tcl
set build_end_time [clock seconds]

puts -nonewline "Setup time: " 
puts -nonewline [format {%.2f} [expr (${setup_end_time} - ${start_time})/60.0]]
puts " minutes"

puts -nonewline "Build time: " 
puts -nonewline [format {%.2f} [expr (${build_end_time} - ${setup_end_time})/60.0]]
puts " minutes"




