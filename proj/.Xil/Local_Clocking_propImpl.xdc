set_property SRC_FILE_INFO {cfile:/home/dan/work/CMS/APOLLO/CU_PCB_6089-103/dan/cores/Local_Clocking/Local_Clocking.xdc rfile:../../cores/Local_Clocking/Local_Clocking.xdc id:1 order:EARLY scoped_inst:inst} [current_design]
set_property src_info {type:SCOPED_XDC file:1 line:57 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports clk_in1_p]] 0.05
