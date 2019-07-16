source ../scripts/settings.tcl

#################################################################################
# STEP#3: run placement and logic optimization, report utilization and timing
# estimates, write checkpoint design
#################################################################################
opt_design
power_opt_design
place_design
phys_opt_design
#write_checkpoint -force $outputDir/post_place
#report_timing_summary -file $outputDir/post_place_timing_summary.rpt

#################################################################################
# STEP#4: run router, report actual utilization and timing, write checkpoint design,
# run drc, write verilog and xdc out
#################################################################################
route_design -directive Explore
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


#################################################################################
# STEP#5: Generate files for os build
#################################################################################
source ../scripts/Generate_hwInfo.tcl
