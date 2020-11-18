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

puts "Using path: ${apollo_root_path}"
puts "Building: ${build_name}"

source ${apollo_root_path}/scripts/Setup.tcl
source ${apollo_root_path}/scripts/Build.tcl
