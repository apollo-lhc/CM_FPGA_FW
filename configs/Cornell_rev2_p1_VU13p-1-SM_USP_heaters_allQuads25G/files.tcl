set bd_path proj

array set bd_files [list {c2cSlave} {configs/${build_name}/createC2CSlaveInterconnect.tcl} \
			]

set vhdl_files "\
     configs/${build_name}/src/top.vhd \
     configs/${build_name}/FPGA_heater/heater.vhd \
     configs/${build_name}/FPGA_heater/lut_oscillator.vhd \
     configs/${build_name}/src/ibert_ultrascale_gty_l.vhd \
     configs/${build_name}/src/ibert_ultrascale_gty_r.vhd \
     configs/${build_name}/src/VIRTEX_TCDS_map.vhd \
     configs/${build_name}/src/VIRTEX_TCDS_PKG.vhd \
     configs/${build_name}/src/TCDS.vhd \
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
     ${autogen_path}/IO/IO_map.vhd \
     ${autogen_path}/C2C_INTF/C2C_INTF_map.vhd \
     ${autogen_path}/C2C_INTF/C2C_INTF_PKG.vhd \
     ${autogen_path}/CM_FW_INFO/CM_FW_INFO_PKG.vhd \
     ${autogen_path}/CM_FW_INFO/CM_FW_INFO_map.vhd \
     src/C2C_INTF/picoblaze/picoblaze/kcpsm6.vhd \
     src/C2C_INTF/picoblaze/uart_rx6.vhd \
     src/C2C_INTF/picoblaze/uart_tx6.vhd \
     src/C2C_INTF/picoblaze/uC.vhd \
     src/C2C_INTF/picoblaze/picoblaze/cli.vhd \
     "
set xdc_files "\
    configs/${build_name}/src/top_pins.xdc \
    configs/${build_name}/src/top_timing.xdc \
    configs/${build_name}/src/top_heaters.xdc \
    configs/${build_name}/src/ibert_ultrascale_gty_l.xdc \
    configs/${build_name}/src/ibert_ultrascale_gty_l_clockgroups.xdc \
    configs/${build_name}/src/ibert_ultrascale_gty_r.xdc \
    configs/${build_name}/src/ibert_ultrascale_gty_r_clockgroups.xdc \
    "	    

set xci_files "\
	      cores/AXI_BRAM/AXI_BRAM.xci \
	      cores/DP_BRAM/DP_BRAM.xci \
              configs/${build_name}/src/ibert_ultrascale_gty_core_l/ibert_ultrascale_gty_core_l.xci \
              configs/${build_name}/src/ibert_ultrascale_gty_core_r/ibert_ultrascale_gty_core_r.xci \
    	      "
