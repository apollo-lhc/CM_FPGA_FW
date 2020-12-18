set bd_path proj

array set bd_files [list {c2cSlave} {configs/Cornell_rev1_p2_VU7p-1/src/createC2CSlaveInterconnect.tcl} \
			]

set vhdl_files "\
     configs/Cornell_rev1_p2_VU7p-1/src/top.vhd \
     src/misc/pass_time_domain.vhd \
     src/misc/pacd.vhd \
     src/misc/types.vhd \
     src/misc/capture_CDC.vhd \
     src/misc/counter.vhd \
     src/misc/counter_clock.vhd \
     src/misc/asym_dualport_ram.vhd \
     src/axiReg/axiRegWidthPkg_32.vhd \
     src/axiReg/axiRegPkg.vhd \
     src/axiReg/axiReg.vhd \
     src/CM_IO/V_IO_PKG.vhd \
     src/CM_IO/V_IO_map.vhd \
     src/misc/RGB_PWM.vhd \
     src/misc/LED_PWM.vhd \
     src/CM_FW_info/CM_V_info.vhd \
     src/CM_FW_info/CM_V_INFO_PKG.vhd \
     src/CM_FW_info/CM_V_INFO_map.vhd \          
     src/misc/axi_bram_controller.vhd \
     src/misc/axi_bram_ctrl_v4_1_rfs.vhd \
     "
set xdc_files "\
    configs/Cornell_rev1_p2_VU7p-1/src/top_pins.xdc \
    configs/Cornell_rev1_p2_VU7p-1/src/top_timing.xdc	\
    "	    

set xci_files "\
    	      cores/Local_Clocking/Local_Clocking.xci \
    	      "
