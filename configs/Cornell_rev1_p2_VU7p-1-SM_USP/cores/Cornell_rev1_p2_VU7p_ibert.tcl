set name Cornell_rev1_p2_VU7p_ibert

set output_path ${apollo_root_path}/configs/${build_name}/cores/

file mkdir ${output_path}

file delete -force ${apollo_root_path}/configs/${build_name}/cores/${name}

#create the gtwizard_ultrascale ip
create_ip -vlnv [get_ipdefs -filter {NAME == ibert_ultrascale_gty}] -module_name ${name} -dir ${output_path}

set_property -dict [list \
			CONFIG.C_RXOUTCLK_GT_LOCATION {QUAD224_0} \
			CONFIG.C_REFCLK_SOURCE_QUAD_10 {MGTREFCLK0_225} \
			CONFIG.C_REFCLK_SOURCE_QUAD_1 {None} \
			CONFIG.C_PROTOCOL_QUAD10 {Custom_1_/_10.260224_Gbps} \
			CONFIG.C_PROTOCOL_QUAD1 {None} \
			CONFIG.C_GT_CORRECT {true} \
			CONFIG.C_PROTOCOL_REFCLK_FREQUENCY_1 {320.632} \
			CONFIG.C_PROTOCOL_MAXLINERATE_1 {10.260224} \
			CONFIG.C_SYSCLK_FREQUENCY {200} \
			CONFIG.C_SYSCLK_IO_PIN_LOC_P {BA35} \
			CONFIG.C_SYSCLK_IO_PIN_STD {LVDS} \
			CONFIG.C_REFCLK_SOURCE_QUAD_11 {MGTREFCLK0_225} \
			CONFIG.C_PROTOCOL_QUAD11 {Custom_1_/_10.260224_Gbps} \
			CONFIG.C_GT_CORRECT {true} \
			CONFIG.C_PROTOCOL_QUAD_COUNT_1 {2} \
		       ] [get_ips ${name}]

#global post_synth_commands
#lappend post_synth_commands "set_property CLOCK_DEDICATED_ROUTE FALSE \[get_nets gty_qrefclk0_i\]"
#lappend post_synth_commands "set_property CLOCK_DEDICATED_ROUTE FALSE \[get_nets gty_qrefclk1_i\]"
