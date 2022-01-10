puts $argc
puts $argv

if { $argc == 2 } {
    set build_name       [lindex $argv 1]
    set apollo_root_path [lindex $argv 0]
} elseif {$argc == 1} {
    set build_name "xc7z035"
    set apollo_root_path [lindex $argv 0]
} else {
    set build_name "xc7z035"
    set apollo_root_path ".."
}

set autogen_path configs/${build_name}/autogen
file mkdir ${apollo_root_path}/$autogen_path

set BD_PATH ${apollo_root_path}/bd

puts "Using path: ${apollo_root_path}"
puts "Building: ${build_name}"
puts "Autogen path: ${autogen_path}"
puts "BD_PATH: ${BD_PATH}"


source ${apollo_root_path}/build-scripts/Setup.tcl
source ${apollo_root_path}/build-scripts/Build.tcl
