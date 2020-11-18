set bd_path proj/

array set bd_files [list {c2cSlave} {src/c2cSlave/createC2CSlaveInterconnect.tcl} \
			]

set vhdl_files "\
     configs/Cornell_rev1_Kintex/top.vhd \
     src/misc/pass_time_domain.vhd \
     src/misc/pacd.vhd \
     src/misc/types.vhd \
     src/misc/capture_CDC.vhd \
     src/misc/counter.vhd \
     src/misc/counter_clock.vhd \
     src/axiReg/axiRegPkg.vhd \
     src/axiReg/axiReg.vhd \
     src/K_IO/K_IO_PKG.vhd \
     src/K_IO/K_IO_map.vhd \
     src/misc/RGB_PWM.vhd \
     src/misc/LED_PWM.vhd \
     src/CM_K_info/CM_K_info.vhd \
     src/CM_K_info/CM_K_INFO_PKG.vhd \
     src/CM_K_info/CM_K_INFO_map.vhd \
     src/TCDS/TCDS.vhd \
     src/TCDS/KINTEX_TCDS_map.vhd \
     src/TCDS/KINTEX_TCDS_PKG.vhd \
     "
set xdc_files "\
    configs/Cornell_rev1_Kintex/top_pins.xdc \
    configs/Cornell_rev1_Kintex/top_timing.xdc	\
    "	    

set xci_files "\
    	      cores/Local_Clocking/Local_Clocking.xci \
    	      cores/TCDS_TxRx/TCDS_TxRx.xci  \
	      cores/TCDS_DRP/TCDS_DRP.xci \
	      cores/AXI_BRAM/AXI_BRAM.xci \
	      cores/DP_BRAM/DP_BRAM.xci \
    	      "

#DRP ip
#set ip_repo_path ../bd/IP
set ip_repo_path ../bd/IP/packaged_ip/
set_property  ip_repo_paths ${ip_repo_path}  [current_project]
update_ip_catalog
