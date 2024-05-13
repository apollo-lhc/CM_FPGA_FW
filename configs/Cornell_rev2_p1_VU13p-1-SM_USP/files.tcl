set bd_path proj

array set bd_files [list {c2cSlave} {src/CM_yaml/CM_C2C/createC2CSlaveInterconnect.tcl} \
			]

set vhdl_files "\
     src/misc/DC_data_CDC.vhd \
     src/misc/pacd.vhd \
     src/misc/types.vhd \
     src/misc/capture_CDC.vhd \
     src/misc/counter.vhd \
     src/misc/counter_CDC.vhd \
     regmap_helper/axiReg/axiRegWidthPkg_32.vhd \
     regmap_helper/axiReg/axiRegPkg_d64.vhd \
     regmap_helper/axiReg/axiRegPkg.vhd \
     regmap_helper/axiReg/axiRegMaster.vhd \
     regmap_helper/axiReg/axiReg.vhd \
     regmap_helper/axiReg/bramPortPkg.vhd \
     regmap_helper/axiReg/axiRegBlocking.vhd \
     src/C2C_INTF/C2C_Intf.vhd \
     src/C2C_INTF/CM_phy_lane_control.vhd \
     src/RGB_PWM.vhd \
     src/LED_PWM.vhd \
     src/misc/rate_counter.vhd \
     src/CM_FW_info/CM_FW_info.vhd \
     ${autogen_path}/IO/IO_PKG.vhd \
     src/custom/IO_map_custom_at_0x310.vhd \
     ${autogen_path}/C2C_INTF/C2C_INTF_map.vhd \
     ${autogen_path}/C2C_INTF/C2C_INTF_PKG.vhd \
     ${autogen_path}/CM_FW_INFO/CM_FW_INFO_PKG.vhd \
     ${autogen_path}/CM_FW_INFO/CM_FW_INFO_map.vhd \
     src/C2C_INTF/picoblaze/picoblaze/kcpsm6.vhd \
     src/C2C_INTF/picoblaze/uart_rx6.vhd \
     src/C2C_INTF/picoblaze/uart_tx6.vhd \
     src/C2C_INTF/picoblaze/uC.vhd \
     src/C2C_INTF/picoblaze/picoblaze/cli.vhd \
     src/tt_combined/IntegrationTests/common/hdl/CreateStartSignal.vhd \
     "
set vhdl_2008_files "\
     configs/${build_name}/src/top.vhd \
     src/tt_combined/IntegrationTests/ReducedCombinedConfig/hdl/SectorProcessor.vhd \
     src/tt_combined/IntegrationTests/ReducedCombinedConfig/hdl/memUtil_pkg.vhd \
     src/tt_combined/IntegrationTests/common/hdl/tf_pkg.vhd \
     src/tt_combined/IntegrationTests/common/hdl/tf_lut.vhd \
     src/tt_combined/IntegrationTests/common/hdl/tf_mem.vhd \
     src/tt_combined/IntegrationTests/common/hdl/tf_mem_format.vhd \
     src/tt_combined/IntegrationTests/common/hdl/tf_mem_bin.vhd \
     src/tt_combined/IntegrationTests/common/hdl/tf_pipe_delay.vhd \
     src/tt_combined/IntegrationTests/common/hdl/emp/memUtil_aux_pkg.vhd \
     "

set xdc_files "\
    configs/${build_name}/src/top_pins.xdc \
    configs/${build_name}/src/top_timing.xdc	\
    configs/${build_name}/src/tt_placement.xdc	\
    "	    

#add_files "/mnt/scratch1/byates/apollo/CM_FPGA_FW_apollo-lhc/src/tt_combined/IntegrationTests/ReducedCombinedConfig/script/Work/Work.srcs/sources_1/ip/*/*.vhdl"

set xci_files "\
	      cores/AXI_BRAM/AXI_BRAM.xci \
	      cores/DP_BRAM/DP_BRAM.xci \
              src/tt_combined/IntegrationTests/ReducedCombinedConfig/script/Work/Work.srcs/sources_1/ip/IR_PS10G_1_A/IR_PS10G_1_A.xci \
              src/tt_combined/IntegrationTests/ReducedCombinedConfig/script/Work/Work.srcs/sources_1/ip/IR_PS10G_2_A/IR_PS10G_2_A.xci \
              src/tt_combined/IntegrationTests/ReducedCombinedConfig/script/Work/Work.srcs/sources_1/ip/IR_PS10G_3_A/IR_PS10G_3_A.xci \
              src/tt_combined/IntegrationTests/ReducedCombinedConfig/script/Work/Work.srcs/sources_1/ip/IR_PS_1_A/IR_PS_1_A.xci \
              src/tt_combined/IntegrationTests/ReducedCombinedConfig/script/Work/Work.srcs/sources_1/ip/IR_PS_2_A/IR_PS_2_A.xci \
              src/tt_combined/IntegrationTests/ReducedCombinedConfig/script/Work/Work.srcs/sources_1/ip/IR_2S_1_A/IR_2S_1_A.xci \
              src/tt_combined/IntegrationTests/ReducedCombinedConfig/script/Work/Work.srcs/sources_1/ip/IR_2S_2_A/IR_2S_2_A.xci \
              src/tt_combined/IntegrationTests/ReducedCombinedConfig/script/Work/Work.srcs/sources_1/ip/IR_2S_3_A/IR_2S_3_A.xci \
              src/tt_combined/IntegrationTests/ReducedCombinedConfig/script/Work/Work.srcs/sources_1/ip/IR_2S_4_A/IR_2S_4_A.xci \
              src/tt_combined/IntegrationTests/ReducedCombinedConfig/script/Work/Work.srcs/sources_1/ip/VMR_L1PHIB/VMR_L1PHIB.xci \
              src/tt_combined/IntegrationTests/ReducedCombinedConfig/script/Work/Work.srcs/sources_1/ip/VMR_L2PHIA/VMR_L2PHIA.xci \
              src/tt_combined/IntegrationTests/ReducedCombinedConfig/script/Work/Work.srcs/sources_1/ip/VMR_L3PHIA/VMR_L3PHIA.xci \
              src/tt_combined/IntegrationTests/ReducedCombinedConfig/script/Work/Work.srcs/sources_1/ip/VMR_L4PHIA/VMR_L4PHIA.xci \
              src/tt_combined/IntegrationTests/ReducedCombinedConfig/script/Work/Work.srcs/sources_1/ip/VMR_L5PHIA/VMR_L5PHIA.xci \
              src/tt_combined/IntegrationTests/ReducedCombinedConfig/script/Work/Work.srcs/sources_1/ip/VMR_L6PHIA/VMR_L6PHIA.xci \
              src/tt_combined/IntegrationTests/ReducedCombinedConfig/script/Work/Work.srcs/sources_1/ip/TP_L1L2C/TP_L1L2C.xci \
              src/tt_combined/IntegrationTests/ReducedCombinedConfig/script/Work/Work.srcs/sources_1/ip/MP_L3PHIA/MP_L3PHIA.xci \
              src/tt_combined/IntegrationTests/ReducedCombinedConfig/script/Work/Work.srcs/sources_1/ip/MP_L4PHIA/MP_L4PHIA.xci \
              src/tt_combined/IntegrationTests/ReducedCombinedConfig/script/Work/Work.srcs/sources_1/ip/MP_L5PHIA/MP_L5PHIA.xci \
              src/tt_combined/IntegrationTests/ReducedCombinedConfig/script/Work/Work.srcs/sources_1/ip/MP_L6PHIA/MP_L6PHIA.xci \
              src/tt_combined/IntegrationTests/ReducedCombinedConfig/script/Work/Work.srcs/sources_1/ip/FT_L1L2/FT_L1L2.xci \
    	      cores/TC_BRAM/ROM_DL_2S_1_A_04/ROM_DL_2S_1_A_04.xci \
    	      cores/TC_BRAM/ROM_DL_2S_1_B_04/ROM_DL_2S_1_B_04.xci \
    	      cores/TC_BRAM/ROM_DL_2S_2_A_04/ROM_DL_2S_2_A_04.xci \
    	      cores/TC_BRAM/ROM_DL_2S_2_B_04/ROM_DL_2S_2_B_04.xci \
    	      cores/TC_BRAM/ROM_DL_2S_3_A_04/ROM_DL_2S_3_A_04.xci \
    	      cores/TC_BRAM/ROM_DL_2S_3_B_04/ROM_DL_2S_3_B_04.xci \
    	      cores/TC_BRAM/ROM_DL_2S_4_A_04/ROM_DL_2S_4_A_04.xci \
    	      cores/TC_BRAM/ROM_DL_2S_4_B_04/ROM_DL_2S_4_B_04.xci \
    	      cores/TC_BRAM/ROM_DL_neg2S_1_A_04/ROM_DL_neg2S_1_A_04.xci \
    	      cores/TC_BRAM/ROM_DL_neg2S_1_B_04/ROM_DL_neg2S_1_B_04.xci \
    	      cores/TC_BRAM/ROM_DL_neg2S_2_A_04/ROM_DL_neg2S_2_A_04.xci \
    	      cores/TC_BRAM/ROM_DL_neg2S_2_B_04/ROM_DL_neg2S_2_B_04.xci \
    	      cores/TC_BRAM/ROM_DL_neg2S_3_A_04/ROM_DL_neg2S_3_A_04.xci \
    	      cores/TC_BRAM/ROM_DL_neg2S_3_B_04/ROM_DL_neg2S_3_B_04.xci \
    	      cores/TC_BRAM/ROM_DL_neg2S_4_A_04/ROM_DL_neg2S_4_A_04.xci \
    	      cores/TC_BRAM/ROM_DL_neg2S_4_B_04/ROM_DL_neg2S_4_B_04.xci \
    	      cores/TC_BRAM/ROM_DL_negPS10G_1_A_04/ROM_DL_negPS10G_1_A_04.xci \
    	      cores/TC_BRAM/ROM_DL_negPS10G_1_B_04/ROM_DL_negPS10G_1_B_04.xci \
    	      cores/TC_BRAM/ROM_DL_negPS10G_2_A_04/ROM_DL_negPS10G_2_A_04.xci \
    	      cores/TC_BRAM/ROM_DL_negPS10G_2_B_04/ROM_DL_negPS10G_2_B_04.xci \
    	      cores/TC_BRAM/ROM_DL_negPS10G_3_A_04/ROM_DL_negPS10G_3_A_04.xci \
    	      cores/TC_BRAM/ROM_DL_negPS10G_3_B_04/ROM_DL_negPS10G_3_B_04.xci \
    	      cores/TC_BRAM/ROM_DL_negPS_1_A_04/ROM_DL_negPS_1_A_04.xci \
    	      cores/TC_BRAM/ROM_DL_negPS_1_B_04/ROM_DL_negPS_1_B_04.xci \
    	      cores/TC_BRAM/ROM_DL_negPS_2_A_04/ROM_DL_negPS_2_A_04.xci \
    	      cores/TC_BRAM/ROM_DL_negPS_2_B_04/ROM_DL_negPS_2_B_04.xci \
    	      cores/TC_BRAM/ROM_DL_PS10G_1_A_04/ROM_DL_PS10G_1_A_04.xci \
    	      cores/TC_BRAM/ROM_DL_PS10G_1_B_04/ROM_DL_PS10G_1_B_04.xci \
    	      cores/TC_BRAM/ROM_DL_PS10G_2_A_04/ROM_DL_PS10G_2_A_04.xci \
    	      cores/TC_BRAM/ROM_DL_PS10G_2_B_04/ROM_DL_PS10G_2_B_04.xci \
    	      cores/TC_BRAM/ROM_DL_PS10G_3_A_04/ROM_DL_PS10G_3_A_04.xci \
    	      cores/TC_BRAM/ROM_DL_PS10G_3_B_04/ROM_DL_PS10G_3_B_04.xci \
    	      cores/TC_BRAM/ROM_DL_PS_1_A_04/ROM_DL_PS_1_A_04.xci \
    	      cores/TC_BRAM/ROM_DL_PS_1_B_04/ROM_DL_PS_1_B_04.xci \
    	      cores/TC_BRAM/ROM_DL_PS_2_A_04/ROM_DL_PS_2_A_04.xci \
    	      cores/TC_BRAM/ROM_DL_PS_2_B_04/ROM_DL_PS_2_B_04.xci \
    	      cores/TC_BRAM/bar_only_vio_0/bar_only_vio_0.xci \
    	      cores/TC_BRAM/baronly_no_comp_ila/baronly_no_comp_ila.xci \
    	      cores/TC_BRAM/BarOnly_Mem_1/BarOnly_Mem_1.xci \
    	      "

set include_files "\
    		  src/i2cAXIMaster/files.tcl	\
                 "
#    	      cores/TC_BRAM/ROM_TF_L1L2/ROM_TF_L1L2.xci \
#    	      cores/TC_BRAM/ROM_TF_L2L3/ROM_TF_L2L3.xci \
#    	      cores/TC_BRAM/ROM_TF_L3L4/ROM_TF_L3L4.xci \
#    	      cores/TC_BRAM/ROM_TF_L5L6/ROM_TF_L5L6.xci \
#    	      cores/TC_BRAM/BarOnly_512_Mem/BarOnly_512_Mem.xci \
#             cores/TC_BRAM/ROM_TF_L1L2/ROM_TF_L1L2.xci \
#             cores/TC_BRAM/ROM_TF_L2L3/ROM_TF_L2L3.xci \
#             cores/TC_BRAM/ROM_TF_L3L4/ROM_TF_L3L4.xci \
#             cores/TC_BRAM/ROM_TF_L5L6/ROM_TF_L5L6.xci \
#             cores/TC_BRAM/BarOnly_512_Mem/BarOnly_512_Mem.xci \

