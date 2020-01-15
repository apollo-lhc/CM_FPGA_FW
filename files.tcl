set bd_path proj

set bd_name c2cSlave

set bd_files "\
    src/c2cSlave/createC2CSlaveInterconnect.tcl
    "

set vhdl_files "\
     src/top.vhd \
     src/misc/pass_time_domain.vhd \
     src/misc/pacd.vhd \
     src/misc/types.vhd \
     src/misc/capture_CDC.vhd \
     src/axiReg/axiRegPkg.vhd \
     src/axiReg/axiReg.vhd \
     src/BoardIO/BoardIO.vhd \
     src/misc/RGB_PWM.vhd \
     src/misc/LED_PWM.vhd \
     src/CM_K_info/CM_K_info.vhd \
     src/TCDS/TCDS.vhd \
     src/TCDS/TCDS_map.vhd \
     src/TCDS/TCDS_PKG.vhd \
     "
set xdc_files "\
    src/top_pins.xdc \
    src/top_timing.xdc	\
    "	    

set xci_files "\
    	      cores/Local_Clocking/Local_Clocking.xci \
    	      cores/TCDS_TxRx/TCDS_TxRx.xci  \
	      cores/AXI_DRP/AXI_DRP.xci \
    	      "

#DRP ip
set ip_repo_path /opt/Xilinx/IP
set_property  ip_repo_paths ${ip_repo_path}  [current_project]
update_ip_catalog
