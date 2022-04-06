set name Cornell_rev1_p1_KU15p_ibert

set output_path ${apollo_root_path}/configs/${build_name}/cores/

file mkdir ${output_path}

file delete -force ${apollo_root_path}/configs/${build_name}/cores/${name}

#create the gtwizard_ultrascale ip
create_ip -vlnv [get_ipdefs -filter {NAME == ibert_ultrascale_gth}] -module_name ${name} -dir ${output_path}

set_property -dict [list \
			CONFIG.C_ENABLE_DIFF_TERM {true} \
			CONFIG.C_SYSCLK_FREQUENCY {200} \
			CONFIG.C_SYSCLK_IO_PIN_LOC_P {G22} \
			CONFIG.C_SYSCLK_IO_PIN_STD {LVDS} \
			CONFIG.C_RXOUTCLK_FREQUENCY {256.5056} \
			CONFIG.C_REFCLK_SOURCE_QUAD_0 {MGTREFCLK0_226} \
			CONFIG.C_PROTOCOL_QUAD0 {Custom_1_/_10.260224_Gbps} \
			CONFIG.C_PROTOCOL_REFCLK_FREQUENCY_1 {320.632} \
			CONFIG.C_PROTOCOL_MAXLINERATE_1 {10.260224} \
		       ] [get_ips ${name}]

