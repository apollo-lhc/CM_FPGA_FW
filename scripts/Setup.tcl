# Non-project mode
# collect files
# run synthesis

source ../scripts/settings.tcl
source ../scripts/FW_info.tcl

#################################################################################
# STEP#0: define output directory area.
#################################################################################
file mkdir $outputDir

set projectDir ../proj/
file mkdir $projectDir
if {[file isfile $projectDir/$top.xpr]} {
    puts "Re-creating project file."
} else {
    puts "Creating project file."
}
create_project -force -part $FPGA_part $top $projectDir
set_property target_language VHDL [current_project]


#################################################################################
# STEP#1: setup design sources and constraints
#################################################################################

#build the build timestamp file
[build_fw_version ../src]

#load list of vhd, xdc, and xci files
source ../files.tcl


#regenerate the block design
#source ../$bd_path/create.tcl
#read_bd [get_files "../$bd_path/$bd_name/$bd_name.bd"]
#open_bd_design [get_files "../$bd_path/$bd_name/$bd_name.bd"]
#make_wrapper -files [get_files $bd_name.bd] -top -import -force
#set bd_wrapper $bd_name
#append bd_wrapper "_wrapper.vhd"
#read_vhdl [get_files $bd_wrapper]

#Add vhdl files
set timestamp_file ../src/fw_version.vhd
read_vhdl ${timestamp_file}
puts "Adding ${timestamp_file}"
for {set j 0} {$j < [llength $vhdl_files ] } {incr j} {
    set filename "../[lindex $vhdl_files $j]"
    read_vhdl $filename
    puts "Adding $filename"
}

#Add xdc files
for {set j 0} {$j < [llength $xdc_files ] } {incr j} {
    set filename "../[lindex $xdc_files $j]"
    read_xdc $filename
    puts "Adding $filename"
}

#Add xci files
for {set j 0} {$j < [llength $xci_files ] } {incr j} {
    set filename "../[lindex $xci_files $j]"
    read_ip $filename
    puts "Adding $filename"
}

check_syntax -fileset sources_1

#Add bd files
for {set j 0} {$j < [llength $bd_files ] } {incr j} {
    set filename "../[lindex $bd_files $j]"
    source $filename
    puts "Running $filename"
    read_bd [get_files "../$bd_path/$bd_name/$bd_name.bd"]
    open_bd_design [get_files "../$bd_path/$bd_name/$bd_name.bd"]
    make_wrapper -files [get_files $bd_name.bd] -top -import -force
    set bd_wrapper $bd_name
    append bd_wrapper "_wrapper.vhd"
    read_vhdl [get_files $bd_wrapper]

}

#################################################################################
# STEP#1: build
#################################################################################
