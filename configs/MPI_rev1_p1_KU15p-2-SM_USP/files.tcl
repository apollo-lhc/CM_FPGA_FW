set bd_path proj/

array set bd_files [list {c2cSlave} {src/c2cBD/createC2CSlaveInterconnect.tcl} \
			]

set vhdl_files "\
     configs/MPI_rev1_p1_KU15p-2-SM_USP/src/top.vhd \
     src/misc/pass_time_domain.vhd \
     src/misc/pacd.vhd \
     src/misc/types.vhd \
     src/misc/Xilinx/rams_sp_wf.vhd \
     regmap_helper/axiReg/axiRegWidthPkg_32.vhd \
     regmap_helper/axiReg/axiRegPkg_d64.vhd \
     regmap_helper/axiReg/axiRegPkg.vhd \
     regmap_helper/axiReg/axiReg.vhd \
     configs/MPI_rev1_p1_KU15p-2-SM_USP/autogen/CM_IO/K_IO_PKG.vhd \
     configs/MPI_rev1_p1_KU15p-2-SM_USP/autogen/CM_IO/K_IO_map.vhd \
     regmap_helper/axiReg/axiRegBlocking.vhd \
     regmap_helper/axiReg/bramPortPkg.vhd \   
     src/misc/RGB_PWM.vhd \
     src/misc/LED_PWM.vhd \
     configs/MPI_rev1_p1_KU15p-2-SM_USP/autogen/CM_FW_info/CM_K_INFO_PKG.vhd \
     configs/MPI_rev1_p1_KU15p-2-SM_USP/autogen/CM_FW_info/CM_K_INFO_map.vhd \
     src/CM_FW_info/CM_K_info.vhd \
     src/misc/axi_bram_ctrl_v4_1_rfs.vhd \
     src/MEM_TEST/Mem_test.vhd \
     src/MEM_TEST/MEM_TEST_map.vhd \
     src/MEM_TEST/MEM_TEST_PKG.vhd \
     src/SPYBUFFER/SpyBuffer_test.vhd \
     src/SPYBUFFER/SPYBUFFER_map.vhd \
     src/SPYBUFFER/SPYBUFFER_PKG.vhd \
"

set verilog_files "\
     src/SPYBUFFER/SpyBuffer/src/SpyProtocol.vh  \
     src/SPYBUFFER/SpyBuffer/src/aFifo/wptr_full.v \
     src/SPYBUFFER/SpyBuffer/src/aFifo/sync_w2r.v \
     src/SPYBUFFER/SpyBuffer/src/aFifo/sync_r2w.v \
     src/SPYBUFFER/SpyBuffer/src/aFifo/fifomem.v \
     src/SPYBUFFER/SpyBuffer/src/aFifo/aFifo.v \ 
     src/SPYBUFFER/SpyBuffer/src/SpyPlayback.v \
     src/SPYBUFFER/SpyBuffer/src/aFifo/rptr_empty.v \
     src/SPYBUFFER/SpyBuffer/src/asym_ram_tdp_read_first.v \
     src/SPYBUFFER/SpyBuffer/src/SpyController.v \ 
     src/SPYBUFFER/SpyBuffer/src/SpyBuffer.v \

     "
set xdc_files "\
    configs/MPI_rev1_p1_KU15p-2-SM_USP/src/top_pins.xdc \
    configs/MPI_rev1_p1_KU15p-2-SM_USP/src/top_timing.xdc	\
    "	    

set xci_files "\
    	      configs/MPI_rev1_p1_KU15p-2-SM_USP/cores/Local_Clocking/Local_Clocking.xci \
    	      "

