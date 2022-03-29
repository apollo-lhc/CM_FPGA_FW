set bd_path proj/

#array set bd_files [list {c2cSlave} {src/c2cBD/createC2CSlaveInterconnect.tcl} \
			]

set vhdl_files "\
     configs/${build_name}/src/ibert/example_Cornell_rev1_p1_KU15p_ibert.v \
     "





#     ${autogen_path}/Quad_Test/QUAD_TEST_PKG.vhd \
#     ${autogen_path}/Quad_Test/QUAD_TEST_map.vhd \
#     src/QuadTest/ChannelTest_64B66B.vhd \
#     src/QuadTest/QuadTest_4chFF.vhd \

#     src/QuadTest/QuadTest.vhd \
#     src/QuadTest/ChannelTest_64B66B.vhd \
#     src/QuadTest/FF_K1_example_init.v \
#     src/QuadTest/FF_K1_example_reset_sync.v \
#     src/QuadTest/FF_K1_example_bit_sync.v \
#     src/QuadTest/ChannelTest_8B10B.vhd \
#     src/QuadTest/QuadTest_4chFF.vhd \


set xdc_files "\
    configs/${build_name}/src/ibert/example_Cornell_rev1_p1_KU15p_ibert.xdc \
    configs/${build_name}/src/ibert/ibert_ultrascale_gth_ip_example.xdc \
    "	    

set xci_files "\
	      ${autogen_path}/../cores/Cornell_rev1_p1_KU15p_ibert.tcl \
    	      "
#    	      cores/Local_Clocking/Local_Clocking.xci \
#              configs/${build_name}/cores/localTCDS.tcl \
#              ${autogen_path}/../cores/my_ila.tcl \
#              ${autogen_path}/../cores/map_withbram_ila.tcl \


