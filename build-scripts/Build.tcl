source ${build_scripts_path}/helpers/printQuads.tcl

#################################################################################
# STEP#2: run synthesis, report utilization and timing estimates, write checkpoint design
#################################################################################
set_param general.maxThreads 10

set_property synth_checkpoint_mode None [get_files $bd_name.bd]
generate_target all [get_files "[get_bd_designs].bd"]

set_property source_mgmt_mode All [current_project]
update_compile_order -fileset sources_1

#check for syntax errors
synth_design -rtl

#synth design
synth_design -top $top -part $FPGA_part -flatten rebuilt

#Do any post synth commands
global post_synth_commands 
foreach cmd $post_synth_commands {
    puts $cmd
    eval $cmd
}   

write_checkpoint -force $outputDir/post_synth


#################################################################################
# STEP#3: run placement and logic optimization, report utilization and timing
# estimates, write checkpoint design
#################################################################################
opt_design
#power_opt_design
place_design
#phys_opt_design
#write_checkpoint -force $outputDir/post_place
#report_timing_summary -file $outputDir/post_place_timing_summary.rpt

#################################################################################
# STEP#4: run router, report actual utilization and timing, write checkpoint design,
# run drc, write verilog and xdc out
#################################################################################
#route_design -directive Explore
#route_design -directive Default
route_design -directive RuntimeOptimized
report_timing_summary -file $outputDir/post_route_timing_summary.rpt
report_timing -sort_by group -max_paths 100 -path_type summary -file $outputDir/post_route_timing.rpt
report_clock_utilization -file $outputDir/clock_util.rpt
report_utilization -file $outputDir/post_route_util.rpt
report_power -file $outputDir/post_route_power.rpt
report_drc -file $outputDir/post_imp_drc.rpt
write_verilog -force $outputDir/bft_impl_netlist.v
write_xdc -no_fixed_only -force $outputDir/bft_impl.xdc
#write_checkpoint -force $outputDir/post_route
#set pass [expr {[get_property SLACK [get_timing_paths]] >= 0}]
write_checkpoint -force $outputDir/post_route

#stolen from https://hwjedi.wordpress.com/2017/01/29/vivado-non-project-mode-part-ii-building-off-a-solid-foundation/
set WNS [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]]
puts "Post Route WNS = $WNS"


set quad_file [open "Quads.txt" "w+"]
print_QUADs ${quad_file} 0
close ${quad_file}
set quad_file [open "Quads_all.txt" "w+"]
print_QUADs ${quad_file} 1
close ${quad_file}

#################################################################################
# STEP#5: Generate files for os build
#################################################################################
source ${build_scripts_path}/Generate_hwInfo.tcl
