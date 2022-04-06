set bd_path proj

#array set bd_files [list {c2cSlave} {src/c2cBD/createC2CSlaveInterconnect.tcl} \
			]

set vhdl_files "\
     configs/${build_name}/src/iBert/example_Cornell_rev1_p2_VU7p_ibert.v \
     "

set xdc_files "\
    configs/${build_name}/src/iBert/example_Cornell_rev1_p2_VU7p_ibert.xdc \    
    configs/${build_name}/src/iBert/ibert_ultrascale_gty_ip_example.xdc \    
    "


set xci_files "\
	      configs/${build_name}/cores/Cornell_rev1_p2_VU7p_ibert.tcl \
    	      "
