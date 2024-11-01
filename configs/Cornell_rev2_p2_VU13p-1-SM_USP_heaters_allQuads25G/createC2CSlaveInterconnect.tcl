source ${apollo_root_path}/bd/axi_helpers.tcl
source ${apollo_root_path}/bd/Xilinx_AXI_slaves.tcl
source ${apollo_root_path}/bd/Xilinx_Cores.tcl

#create a block design called "c2cSlave"
#directory and name must be the same
set bd_design_name "c2cSlave"
create_bd_design -dir ./ ${bd_design_name}

set EXT_CLK clk50Mhz
set EXT_RESET reset_n
set EXT_CLK_FREQ 50000000

set AXI_MASTER_CLK AXI_CLK
set AXI_MASTER_RSTN AXI_RST_N
set AXI_MASTER_CLK_FREQ 50000000

set AXI_INTERCONNECT_NAME slave_interconnect



#================================================================================
#  Setup external clock and reset
#================================================================================
create_bd_port -dir I -type clk $EXT_CLK
set_property CONFIG.FREQ_HZ ${EXT_CLK_FREQ} [get_bd_ports ${EXT_CLK}]
create_bd_port -dir I -type rst $EXT_RESET



#================================================================================
#  Create an AXI interconnect
#================================================================================
puts "Building AXI C2C slave interconnect"

#create AXI clock & reset ports
create_bd_port -dir I -type clk $AXI_MASTER_CLK
set_property CONFIG.FREQ_HZ ${AXI_MASTER_CLK_FREQ} [get_bd_ports ${AXI_MASTER_CLK}]
create_bd_port -dir O -type rst $AXI_MASTER_RSTN

#create the reset logic
set SYS_RESETER sys_reseter
create_bd_cell -type ip -vlnv [get_ipdefs -filter {NAME == proc_sys_reset}] $SYS_RESETER
#connect external reset
connect_bd_net [get_bd_ports $EXT_RESET] [get_bd_pins $SYS_RESETER/ext_reset_in]
#connect clock
connect_bd_net [get_bd_ports $AXI_MASTER_CLK] [get_bd_pins $SYS_RESETER/slowest_sync_clk]


set SYS_RESETER_AXI_RSTN $SYS_RESETER/interconnect_aresetn
#create the reset to sys reseter and slave interconnect
connect_bd_net [get_bd_ports $AXI_MASTER_RSTN] [get_bd_pins $SYS_RESETER_AXI_RSTN]

AXI_C2C_MASTER [dict create device_name ${C2C} \
		    axi_control [dict create axi_clk $AXI_MASTER_CLK \
				     axi_rstn $AXI_MASTER_RSTN\
				     axi_freq $AXI_MASTER_CLK_FREQ] \
		    primary_serdes 1 \
		    init_clk $EXT_CLK \
		    refclk_freq 200 \
		    c2c_master false \
		    speed 5 \
		   ]
if { [info exists C2CB] } {
    AXI_C2C_MASTER [dict create device_name ${C2CB} \
			axi_control [dict create axi_clk $AXI_MASTER_CLK \
					 axi_rstn $AXI_MASTER_RSTN\
					 axi_freq $AXI_MASTER_CLK_FREQ] \
			primary_serdes ${C2C}_PHY \
			init_clk $EXT_CLK \
			refclk_freq 200 \
			c2c_master false \
			speed 5 \
		       ]
}


#================================================================================
#  Create JTAG AXI Master
#================================================================================
set JTAG_AXI_MASTER JTAG_AXI_Master
BUILD_JTAG_AXI_MASTER [dict create device_name ${JTAG_AXI_MASTER} axi_clk ${AXI_MASTER_CLK} axi_rstn ${AXI_MASTER_RSTN}]

#================================================================================
#  Connect C2C master port to interconnect slave port
#================================================================================
set mAXI [list ${C2C}/m_axi ${C2CB}/m_axi_lite ${JTAG_AXI_MASTER}/M_AXI]
set mCLK [list ${AXI_MASTER_CLK}  ${AXI_MASTER_CLK}  ${AXI_MASTER_CLK} ]
set mRST [list ${AXI_MASTER_RSTN} ${AXI_MASTER_RSTN} ${AXI_MASTER_RSTN}] 
[BUILD_AXI_INTERCONNECT $AXI_INTERCONNECT_NAME ${AXI_MASTER_CLK} $AXI_MASTER_RSTN $mAXI $mCLK $mRST]



#================================================================================
#  Configure and add AXI slaves
#================================================================================
source -quiet ${apollo_root_path}/bd/add_slaves_from_yaml.tcl
yaml_to_bd "${apollo_root_path}/configs/${build_name}/config.yaml"

GENERATE_AXI_ADDR_MAP_C "${apollo_root_path}/configs/${build_name}/autogen/AXI_slave_addrs.h"                                                                                                 
GENERATE_AXI_ADDR_MAP_VHDL "${apollo_root_path}/configs/${build_name}/autogen/AXI_slave_pkg.vhd"                                                                                              
read_vhdl "${apollo_root_path}/configs/${build_name}/autogen/AXI_slave_pkg.vhd"      

#=================================================
#  Configure SYS MGMT to have all SLRs enabled
#=================================================

set_property -dict [list CONFIG.CHANNEL_ENABLE_VUSER0_SLAVE0_SSIT {true} CONFIG.CHANNEL_ENABLE_VUSER0_SLAVE1_SSIT {true} CONFIG.CHANNEL_ENABLE_VUSER0_SLAVE2_SSIT {true} CONFIG.Enable_Slave0 {true} CONFIG.Enable_Slave1 {true} CONFIG.Enable_Slave2 {true}] [get_bd_cells F2_SYS_MGMT]

#========================================
#  Finish up
#========================================
validate_bd_design

make_wrapper -files [get_files ${bd_design_name}.bd] -top -import -force
save_bd_design

close_bd_design ${bd_design_name}

