set bd_path proj

array set bd_files [list {c2cSlave} {src/c2cBD/createC2CSlaveInterconnect.tcl} \
			]

set vhdl_files "\
     configs/${build_name}/src/top.vhd \
     src/misc/DC_data_CDC.vhd \
     src/misc/pacd.vhd \
     src/misc/types.vhd \
     src/misc/capture_CDC.vhd \
     src/misc/counter.vhd \
     src/misc/counter_CDC.vhd \
     regmap_helper/axiReg/axiRegWidthPkg_32.vhd \
     regmap_helper/axiReg/axiRegPkg_d64.vhd \
     regmap_helper/axiReg/axiRegPkg.vhd \
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
     src/tt_skinny_chain/IntegrationTests/ReducedConfig/hdl/SectorProcessor.vhd \
     src/tt_skinny_chain/IntegrationTests/ReducedConfig/hdl/memUtil_pkg.vhd \
     src/tt_skinny_chain/IntegrationTests/common/hdl/CreateStartSignal.vhd \
     src/tt_skinny_chain/IntegrationTests/common/hdl/tf_pkg.vhd \
     "
set vhdl_2008_files "\
     src/tt_skinny_chain/IntegrationTests/common/hdl/tf_lut.vhd \
     src/tt_skinny_chain/IntegrationTests/common/hdl/tf_mem.vhd \
     src/tt_skinny_chain/IntegrationTests/common/hdl/tf_mem_bin.vhd \
     "

set xdc_files "\
    configs/${build_name}/src/top_pins.xdc \
    configs/${build_name}/src/top_timing.xdc	\
    "	    

set xci_files "\
	      cores/AXI_BRAM/AXI_BRAM.xci \
	      cores/DP_BRAM/DP_BRAM.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/IR_2S_1_A/IR_2S_1_A.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/IR_2S_1_B/IR_2S_1_B.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/IR_2S_2_A/IR_2S_2_A.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/IR_2S_2_B/IR_2S_2_B.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/IR_2S_3_A/IR_2S_3_A.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/IR_2S_3_B/IR_2S_3_B.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/IR_2S_4_A/IR_2S_4_A.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/IR_2S_4_B/IR_2S_4_B.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/IR_PS10G_1_A/IR_PS10G_1_A.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/IR_PS10G_2_A/IR_PS10G_2_A.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/IR_PS10G_2_B/IR_PS10G_2_B.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/IR_PS10G_3_A/IR_PS10G_3_A.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/IR_PS10G_3_B/IR_PS10G_3_B.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/IR_PS_1_A/IR_PS_1_A.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/IR_PS_1_B/IR_PS_1_B.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/IR_PS_2_A/IR_PS_2_A.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/IR_PS_2_B/IR_PS_2_B.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/VMR_L1PHID/VMR_L1PHID.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/VMR_L2PHIB/VMR_L2PHIB.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/VMR_L3PHIB/VMR_L3PHIB.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/VMR_L4PHIB/VMR_L4PHIB.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/VMR_L5PHIB/VMR_L5PHIB.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/VMR_L6PHIB/VMR_L6PHIB.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/TE_L1L2/TE_L1L2.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/TC_L1L2F/TC_L1L2F.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/PR_L3PHIB/PR_L3PHIB.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/PR_L4PHIB/PR_L4PHIB.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/PR_L5PHIB/PR_L5PHIB.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/PR_L6PHIB/PR_L6PHIB.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/ME_L3PHIB/ME_L3PHIB.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/ME_L4PHIB/ME_L4PHIB.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/ME_L5PHIB/ME_L5PHIB.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/ME_L6PHIB/ME_L6PHIB.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/MC_L3PHIB/MC_L3PHIB.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/MC_L4PHIB/MC_L4PHIB.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/MC_L5PHIB/MC_L5PHIB.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/MC_L6PHIB/MC_L6PHIB.xci \
              src/tt_skinny_chain/IntegrationTests/ReducedConfig/script/Work/Work.srcs/sources_1/ip/FT_L1L2/FT_L1L2.xci \
    	      cores/TC_BRAM/Test_Chain_Mem_1/Test_Chain_Mem_1.xci \
    	      cores/TC_BRAM/Test_Chain_512_Mem/Test_Chain_512_Mem.xci \
    	      cores/TC_BRAM/SummerChain_vio/SummerChain_vio.xci \
    	      cores/TC_BRAM/SummerChain_debug/SummerChain_debug.xci \
    	      cores/TC_BRAM/ROM_DL_2S_1_A_04/ROM_DL_2S_1_A_04.xci \
    	      cores/TC_BRAM/ROM_DL_2S_1_B_04/ROM_DL_2S_1_B_04.xci \
    	      cores/TC_BRAM/ROM_DL_2S_2_A_04/ROM_DL_2S_2_A_04.xci \
    	      cores/TC_BRAM/ROM_DL_2S_2_B_04/ROM_DL_2S_2_B_04.xci \
    	      cores/TC_BRAM/ROM_DL_2S_3_A_04/ROM_DL_2S_3_A_04.xci \
    	      cores/TC_BRAM/ROM_DL_2S_3_B_04/ROM_DL_2S_3_B_04.xci \
    	      cores/TC_BRAM/ROM_DL_2S_4_A_04/ROM_DL_2S_4_A_04.xci \
    	      cores/TC_BRAM/ROM_DL_2S_4_B_04/ROM_DL_2S_4_B_04.xci \
    	      cores/TC_BRAM/ROM_DL_PS10G_1_A_04/ROM_DL_PS10G_1_A_04.xci \
    	      cores/TC_BRAM/ROM_DL_PS10G_2_A_04/ROM_DL_PS10G_2_A_04.xci \
    	      cores/TC_BRAM/ROM_DL_PS10G_2_B_04/ROM_DL_PS10G_2_B_04.xci \
    	      cores/TC_BRAM/ROM_DL_PS10G_3_A_04/ROM_DL_PS10G_3_A_04.xci \
    	      cores/TC_BRAM/ROM_DL_PS10G_3_B_04/ROM_DL_PS10G_3_B_04.xci \
    	      cores/TC_BRAM/ROM_DL_PS_1_A_04/ROM_DL_PS_1_A_04.xci \
    	      cores/TC_BRAM/ROM_DL_PS_1_B_04/ROM_DL_PS_1_B_04.xci \
    	      cores/TC_BRAM/ROM_DL_PS_2_A_04/ROM_DL_PS_2_A_04.xci \
    	      cores/TC_BRAM/ROM_DL_PS_2_B_04/ROM_DL_PS_2_B_04.xci \
    	      cores/TC_BRAM/ROM_TF_L1L2/ROM_TF_L1L2.xci \
    	      "
#    	      cores/TC_BRAM/SectorProcessor_ila/SectorProcessor_ila.xci \
