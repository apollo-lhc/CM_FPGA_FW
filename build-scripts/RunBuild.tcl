
#synth design
synth_design -top $top -part $FPGA_part -flatten rebuilt


global post_synth_commands
foreach cmd $post_synth_commands {
    puts $cmd
    $cmd
}

#################################################################################
# STEP#3: run placement and logic optimization, report utilization and timing
# estimates, write checkpoint design
#################################################################################
opt_design
power_opt_design
place_design
phys_opt_design

#################################################################################
# STEP#4: run router, report actual utilization and timing, write checkpoint design,
# run drc, write verilog and xdc out
#################################################################################
route_design -directive Explore


#################################################################################
# STEP#5: Generate files for os build
#################################################################################
source ../build-scripts/Generate_hwInfo.tcl
