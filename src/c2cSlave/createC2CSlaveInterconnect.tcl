source ../bd/axi_slave_helpers.tcl

#create a block design called "c2cSlave"
#directory and name must be the same
set bd_design_name "c2cSlave"
create_bd_design -dir ../bd ${bd_design_name}

set EXT_CLK clk50Mhz
set EXT_RESET reset_n

set AXI_MASTER_CLK AXI_CLK
set AXI_MASTER_RSTN AXI_RST_N
set AXI_MASTER_CLK_MHZ 50

set AXI_INTERCONNECT_NAME slave_interconnect



#================================================================================
#  Setup external clock and reset
#================================================================================
create_bd_port -dir I -type clk $EXT_CLK
set_property CONFIG.FREQ_HZ 50000000 [get_bd_ports ${EXT_CLK}]
create_bd_port -dir I -type rst $EXT_RESET


#================================================================================
#  Add local AXI devices here
#================================================================================
[AXI_DEVICE_ADD myReg0  M00 $AXI_MASTER_CLK $AXI_MASTER_RSTN 50000000 0x43c40000 4K]
[AXI_DEVICE_ADD myReg1  M01 $AXI_MASTER_CLK $AXI_MASTER_RSTN 50000000 0x43c41000 4K]
#[AXI_DEVICE_ADD myReg0  M00 $AXI_MASTER_CLK $AXI_MASTER_RSTN 50000000 0x7AA00000 4K]
#[AXI_DEVICE_ADD myReg1  M01 $AXI_MASTER_CLK $AXI_MASTER_RSTN 50000000 0x7AA01000 4K]

#================================================================================
#  Create an AXI interconnect
#================================================================================
puts "Building AXI C2C slave interconnect"

#startgroup

#create AXI clock & reset ports
create_bd_port -dir I -type clk $AXI_MASTER_CLK
create_bd_port -dir O -type rst $AXI_MASTER_RSTN


#create an axi interconnect 
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 $AXI_INTERCONNECT_NAME
#set_property CONFIG.NUM_SI 1                 [get_bd_cells $AXI_INTERCONNECT_NAME]
set_property CONFIG.NUM_SI 2                 [get_bd_cells $AXI_INTERCONNECT_NAME]
set AXI_DEVICE_COUNT [array size AXI_BUS_M]
puts "Slave count: $AXI_DEVICE_COUNT"
set_property CONFIG.NUM_MI $AXI_DEVICE_COUNT [get_bd_cells $AXI_INTERCONNECT_NAME]

set AXIM_PORT_NAME $AXI_INTERCONNECT_NAME
append AXIM_PORT_NAME "_AXIM"    


#connect the interconnect clock to the AXI master clk
connect_bd_net [get_bd_ports $AXI_MASTER_CLK] [get_bd_pins $AXI_INTERCONNECT_NAME/ACLK]

#create the reset logic
set SYS_RESETER sys_reseter
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 $SYS_RESETER
#connect external reset
connect_bd_net [get_bd_ports $EXT_RESET] [get_bd_pins $SYS_RESETER/ext_reset_in]
#connect clock
connect_bd_net [get_bd_ports $AXI_MASTER_CLK] [get_bd_pins $SYS_RESETER/slowest_sync_clk]


#create the reset to sys reseter and slave interconnect
connect_bd_net [get_bd_ports $AXI_MASTER_RSTN] [get_bd_pins $SYS_RESETER/interconnect_aresetn]
connect_bd_net [get_bd_ports $AXI_MASTER_RSTN] [get_bd_pins $AXI_INTERCONNECT_NAME/ARESETN]

#expose the interconnect's axi slave port for c2c master
connect_bd_net [get_bd_ports $AXI_MASTER_CLK]  [get_bd_pins $AXI_INTERCONNECT_NAME/S00_ACLK]
connect_bd_net [get_bd_ports $AXI_MASTER_RSTN] [get_bd_pins $AXI_INTERCONNECT_NAME/S00_ARESETN]
#same for interconnect axi lite slave
connect_bd_net [get_bd_ports $AXI_MASTER_CLK]  [get_bd_pins $AXI_INTERCONNECT_NAME/S01_ACLK]
connect_bd_net [get_bd_ports $AXI_MASTER_RSTN] [get_bd_pins $AXI_INTERCONNECT_NAME/S01_ARESETN]



#endgroup

#================================================================================
#  Configure chip 2 chip links
#================================================================================
set C2C C2CLink
set C2C_PHY ${C2C}_phy

#Create chip-2-chip ip core
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_chip2chip:5.0 $C2C
#set_property CONFIG.C_NUM_OF_IO {84.0}          [get_bd_cells ${C2C}]
set_property CONFIG.C_NUM_OF_IO {58.0}          [get_bd_cells ${C2C}]
set_property CONFIG.C_INTERFACE_MODE {0}	[get_bd_cells ${C2C}]
set_property CONFIG.C_MASTER_FPGA {0}		[get_bd_cells ${C2C}]
#set_property CONFIG.C_AURORA_WIDTH {2.0}        [get_bd_cells ${C2C}]
set_property CONFIG.C_AURORA_WIDTH {1.0}        [get_bd_cells ${C2C}]
set_property CONFIG.C_EN_AXI_LINK_HNDLR {false} [get_bd_cells ${C2C}]
#set_property CONFIG.C_AXI_STB_WIDTH     {8}     [get_bd_cells ${C2C}]
set_property CONFIG.C_AXI_STB_WIDTH     {4}     [get_bd_cells ${C2C}]
#set_property CONFIG.C_AXI_DATA_WIDTH    {64}    [get_bd_cells ${C2C}]
set_property CONFIG.C_AXI_DATA_WIDTH    {32}    [get_bd_cells ${C2C}]
set_property CONFIG.C_INTERFACE_TYPE {2}	[get_bd_cells ${C2C}]
#set_property CONFIG.C_COMMON_CLK     {1}	[get_bd_cells ${C2C}]
set_property CONFIG.C_INCLUDE_AXILITE {2}	[get_bd_cells ${C2C}]

make_bd_pins_external       -name ${C2C}_aurora_do_cc                [get_bd_pins ${C2C}/aurora_do_cc]
make_bd_pins_external       -name ${C2C}_axi_c2c_config_error_out    [get_bd_pins ${C2C}/axi_c2c_config_error_out   ]  
make_bd_pins_external       -name ${C2C}_axi_c2c_link_status_out     [get_bd_pins ${C2C}/axi_c2c_link_status_out    ]  
make_bd_pins_external       -name ${C2C}_axi_c2c_multi_bit_error_out [get_bd_pins ${C2C}/axi_c2c_multi_bit_error_out]  
make_bd_pins_external       -name ${C2C}_axi_c2c_link_error_out      [get_bd_pins ${C2C}/axi_c2c_link_error_out     ] 


endgroup

#create chip-2-chip aurora 
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:aurora_64b66b:11.2 ${C2C_PHY}
set_property CONFIG.C_INIT_CLK.VALUE_SRC PROPAGATED   [get_bd_cells ${C2C_PHY}]
set_property CONFIG.CHANNEL_ENABLE       {X0Y0}       [get_bd_cells ${C2C_PHY}]
set_property CONFIG.C_AURORA_LANES       {1}	      [get_bd_cells ${C2C_PHY}]
set_property CONFIG.C_LINE_RATE          {5}	      [get_bd_cells ${C2C_PHY}]
set_property CONFIG.C_REFCLK_FREQUENCY   {200}	      [get_bd_cells ${C2C_PHY}]
set_property CONFIG.C_GT_LOC_2           {X} 	      [get_bd_cells ${C2C_PHY}]
set_property CONFIG.interface_mode       {Streaming}  [get_bd_cells ${C2C_PHY}]
set_property CONFIG.SupportLevel         {1}          [get_bd_cells ${C2C_PHY}]



make_bd_pins_external       -name ${C2C_PHY}_power_down     [get_bd_pins ${C2C_PHY}/power_down]
make_bd_pins_external       -name ${C2C_PHY}_gt_pll_lock    [get_bd_pins ${C2C_PHY}/gt_pll_lock]       
make_bd_pins_external       -name ${C2C_PHY}_hard_err       [get_bd_pins ${C2C_PHY}/hard_err]  
make_bd_pins_external       -name ${C2C_PHY}_soft_err       [get_bd_pins ${C2C_PHY}/soft_err]  
make_bd_pins_external       -name ${C2C_PHY}_lane_up        [get_bd_pins ${C2C_PHY}/lane_up]   
make_bd_pins_external       -name ${C2C_PHY}_mmcm_not_locked_out  [get_bd_pins ${C2C_PHY}/mmcm_not_locked_out] 
make_bd_pins_external       -name ${C2C_PHY}_link_reset_out [get_bd_pins ${C2C_PHY}/link_reset_out]      

#connect C2C core with the C2C-mode Auroroa core
connect_bd_intf_net [get_bd_intf_pins ${C2C}/AXIS_TX] [get_bd_intf_pins ${C2C_PHY}/USER_DATA_S_AXIS_TX]
connect_bd_intf_net [get_bd_intf_pins ${C2C_PHY}/USER_DATA_M_AXIS_RX] [get_bd_intf_pins ${C2C}/AXIS_RX]
connect_bd_net [get_bd_pins ${C2C_PHY}/user_clk_out]        [get_bd_pins ${C2C}/axi_c2c_phy_clk]
connect_bd_net [get_bd_pins ${C2C_PHY}/channel_up]          [get_bd_pins ${C2C}/axi_c2c_aurora_channel_up]
#connect_bd_net [get_bd_pins ${C2C_PHY}/init_clk]            [get_bd_pins ${C2C}/aurora_init_clk]
connect_bd_net [get_bd_pins ${C2C_PHY}/mmcm_not_locked_out] [get_bd_pins ${C2C}/aurora_mmcm_not_locked]
connect_bd_net [get_bd_pins ${C2C}/aurora_pma_init_out]     [get_bd_pins ${C2C_PHY}/pma_init]
connect_bd_net [get_bd_pins ${C2C}/aurora_reset_pb]         [get_bd_pins ${C2C_PHY}/reset_pb]

#expose the Aurora core signals to top
make_bd_intf_pins_external  -name ${C2C_PHY}_refclk [get_bd_intf_pins ${C2C_PHY}/GT_DIFF_REFCLK1]
make_bd_intf_pins_external  -name ${C2C_PHY}_Rx     [get_bd_intf_pins ${C2C_PHY}/GT_SERIAL_RX]
make_bd_intf_pins_external  -name ${C2C_PHY}_Tx     [get_bd_intf_pins ${C2C_PHY}/GT_SERIAL_TX]


#connect external 200Mhz clock to init clocks
connect_bd_net [get_bd_ports $EXT_CLK]   [get_bd_pins ${C2C_PHY}/init_clk]  
connect_bd_net [get_bd_ports $EXT_CLK]   [get_bd_pins ${C2C}/aurora_init_clk]


endgroup


#================================================================================
#  Connect C2C master port to interconnect slave port
#================================================================================
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins ${AXI_INTERCONNECT_NAME}/S00_AXI] [get_bd_intf_pins ${C2C}/m_axi]
connect_bd_net [get_bd_pins ${C2C}/m_aresetn] [get_bd_pins sys_reseter/interconnect_aresetn]
connect_bd_net [get_bd_ports ${AXI_MASTER_CLK}] [get_bd_pins ${C2C}/m_aclk]

connect_bd_intf_net -boundary_type upper [get_bd_intf_pins ${AXI_INTERCONNECT_NAME}/S01_AXI] [get_bd_intf_pins ${C2C}/m_axi_lite]
connect_bd_net [get_bd_ports ${AXI_MASTER_CLK}] [get_bd_pins ${C2C}/m_axi_lite_aclk]

#global AXI_BUS_FREQ
#set_property CONFIG.FREQ_HZ [get_property CONFIG.FREQ_HZ [get_bd_intf_pins /${C2C}/m_axi]] [get_bd_ports ${AXI_MASTER_CLK}]
global AXI_BUS_FREQ
puts $AXI_BUS_FREQ(myReg0)
puts [get_property CONFIG.FREQ_HZ [get_bd_intf_pins /${C2C}/m_axi]]
set AXI_BUS_FREQ(myReg0) [get_property CONFIG.FREQ_HZ [get_bd_intf_pins /${C2C}/m_axi]]
set AXI_BUS_FREQ(myReg1) [get_property CONFIG.FREQ_HZ [get_bd_intf_pins /${C2C}/m_axi]]
puts $AXI_BUS_FREQ(myReg0)


#================================================================================
#  Configure and add AXI slaves
#================================================================================

#expose the interconnect's axi master port for an axi slave
puts "Adding user slaves"
#AXI_PL_CONNECT creates all the PL slaves in the list passed to it.
[AXI_PL_CONNECT "myReg0 myReg1"]                                                      

#========================================
#  Finish up
#========================================
validate_bd_design

make_wrapper -files [get_files ${bd_design_name}.bd] -top -import -force
save_bd_design

close_bd_design ${bd_design_name}

