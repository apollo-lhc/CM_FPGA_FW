source ${apollo_root_path}/bd/axi_helpers.tcl
source ${apollo_root_path}/bd/Xilinx_AXI_slaves.tcl

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

#================================================================================
#  Configure chip 2 chip links
#================================================================================
#required to be set by this point
#C2C
#C2C_PHY

#Create chip-2-chip ip core
startgroup
create_bd_cell -type ip -vlnv [get_ipdefs -filter {NAME == axi_chip2chip}] $C2C
set_property CONFIG.C_NUM_OF_IO {58.0}          [get_bd_cells ${C2C}]
set_property CONFIG.C_INTERFACE_MODE {0}	[get_bd_cells ${C2C}]
set_property CONFIG.C_MASTER_FPGA {0}		[get_bd_cells ${C2C}]
set_property CONFIG.C_AURORA_WIDTH {1.0}        [get_bd_cells ${C2C}]
set_property CONFIG.C_EN_AXI_LINK_HNDLR {false} [get_bd_cells ${C2C}]
set_property CONFIG.C_AXI_STB_WIDTH     {4}     [get_bd_cells ${C2C}]
set_property CONFIG.C_AXI_DATA_WIDTH    {32}    [get_bd_cells ${C2C}]
set_property CONFIG.C_INTERFACE_TYPE {2}	[get_bd_cells ${C2C}]
set_property CONFIG.C_INCLUDE_AXILITE {2}	[get_bd_cells ${C2C}]
set_property CONFIG.C_M_AXI_WUSER_WIDTH {0}     [get_bd_cells ${C2C}]
set_property CONFIG.C_M_AXI_ID_WIDTH {0}        [get_bd_cells ${C2C}]


make_bd_pins_external       -name ${C2C}_aurora_do_cc                [get_bd_pins ${C2C}/aurora_do_cc]
make_bd_pins_external       -name ${C2C}_axi_c2c_config_error_out    [get_bd_pins ${C2C}/axi_c2c_config_error_out   ]  
make_bd_pins_external       -name ${C2C}_axi_c2c_link_status_out     [get_bd_pins ${C2C}/axi_c2c_link_status_out    ]  
make_bd_pins_external       -name ${C2C}_axi_c2c_multi_bit_error_out [get_bd_pins ${C2C}/axi_c2c_multi_bit_error_out]  
make_bd_pins_external       -name ${C2C}_axi_c2c_link_error_out      [get_bd_pins ${C2C}/axi_c2c_link_error_out     ] 


endgroup

#create chip-2-chip aurora 
startgroup
create_bd_cell -type ip -vlnv [get_ipdefs -filter {NAME == aurora_64b66b}] ${C2C_PHY}
set_property CONFIG.C_INIT_CLK.VALUE_SRC PROPAGATED   [get_bd_cells ${C2C_PHY}]
#set_property CONFIG.CHANNEL_ENABLE       {X0Y0}       [get_bd_cells ${C2C_PHY}]
set_property CONFIG.C_AURORA_LANES       {1}	      [get_bd_cells ${C2C_PHY}]
#set_property CONFIG.C_LINE_RATE          {10}	      [get_bd_cells ${C2C_PHY}]
set_property CONFIG.C_LINE_RATE          {5}	      [get_bd_cells ${C2C_PHY}]
set_property CONFIG.C_REFCLK_FREQUENCY   {200}	      [get_bd_cells ${C2C_PHY}]
set_property CONFIG.C_GT_LOC_2           {X} 	      [get_bd_cells ${C2C_PHY}]
set_property CONFIG.interface_mode       {Streaming}  [get_bd_cells ${C2C_PHY}]
set_property CONFIG.SupportLevel         {1}          [get_bd_cells ${C2C_PHY}]
set_property CONFIG.C_USE_CHIPSCOPE      {true}       [get_bd_cells ${C2C_PHY}]
set_property CONFIG.drp_mode             {AXI4_LITE}  [get_bd_cells ${C2C_PHY}]
set_property CONFIG.TransceiverControl   {true}       [get_bd_cells ${C2C_PHY}]

#expose debugging signals to top
make_bd_pins_external       -name ${C2C_PHY}_STATUS_channel_up         [get_bd_pins ${C2C_PHY}/channel_up     ]
make_bd_pins_external       -name ${C2C_PHY}_STATUS_gt_pll_lock        [get_bd_pins ${C2C_PHY}/gt_pll_lock    ]
make_bd_pins_external       -name ${C2C_PHY}_STATUS_hard_err           [get_bd_pins ${C2C_PHY}/hard_err       ]
make_bd_pins_external       -name ${C2C_PHY}_STATUS_lane_up            [get_bd_pins ${C2C_PHY}/lane_up        ]
make_bd_pins_external       -name ${C2C_PHY}_STATUS_mmcm_not_locked    [get_bd_pins ${C2C_PHY}/mmcm_not_locked_out]
make_bd_pins_external       -name ${C2C_PHY}_STATUS_soft_err           [get_bd_pins ${C2C_PHY}/soft_err       ]

make_bd_intf_pins_external  -name ${C2C_PHY}_DEBUG          [get_bd_intf_pins ${C2C_PHY}/TRANSCEIVER_DEBUG]
make_bd_pins_external       -name ${C2C_PHY}_power_down     [get_bd_pins ${C2C_PHY}/power_down]
make_bd_pins_external       -name ${C2C_PHY}_link_reset_out [get_bd_pins ${C2C_PHY}/link_reset_out]      
make_bd_pins_external       -name ${C2C_PHY}_user_clk_out   [get_bd_pins ${C2C_PHY}/user_clk_out]



#connect C2C core with the C2C-mode Auroroa core
connect_bd_intf_net [get_bd_intf_pins ${C2C}/AXIS_TX] [get_bd_intf_pins ${C2C_PHY}/USER_DATA_S_AXIS_TX]
connect_bd_intf_net [get_bd_intf_pins ${C2C_PHY}/USER_DATA_M_AXIS_RX] [get_bd_intf_pins ${C2C}/AXIS_RX]
connect_bd_net [get_bd_pins ${C2C_PHY}/user_clk_out]        [get_bd_pins ${C2C}/axi_c2c_phy_clk]
connect_bd_net [get_bd_pins ${C2C_PHY}/channel_up]          [get_bd_pins ${C2C}/axi_c2c_aurora_channel_up]
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


#connect resets
#connect_bd_net [get_bd_pins   ${C2C}/m_aresetn] [get_bd_pins sys_reseter/interconnect_aresetn]
connect_bd_net [get_bd_pins   ${C2C}/m_aresetn] [get_bd_pins ${AXI_MASTER_RSTN}]
connect_bd_net [get_bd_ports ${AXI_MASTER_CLK}] [get_bd_pins ${C2C}/m_aclk]
connect_bd_net [get_bd_ports ${AXI_MASTER_CLK}] [get_bd_pins ${C2C}/m_axi_lite_aclk]

endgroup

#================================================================================
#  Create JTAG AXI Master
#================================================================================
set JTAG_AXI_MASTER JTAG_AXI_Master
BUILD_JTAG_AXI_MASTER [dict create device_name ${JTAG_AXI_MASTER} axi_clk ${AXI_MASTER_CLK} axi_rstn ${AXI_MASTER_RSTN}]

#================================================================================
#  Connect C2C master port to interconnect slave port
#================================================================================
set mAXI [list ${C2C}/m_axi ${C2C}/m_axi_lite ${JTAG_AXI_MASTER}/M_AXI]
set mCLK [list ${AXI_MASTER_CLK}  ${AXI_MASTER_CLK}  ${AXI_MASTER_CLK} ]
set mRST [list ${AXI_MASTER_RSTN} ${AXI_MASTER_RSTN} ${AXI_MASTER_RSTN}] 
[BUILD_AXI_INTERCONNECT $AXI_INTERCONNECT_NAME ${AXI_MASTER_CLK} $AXI_MASTER_RSTN $mAXI $mCLK $mRST]



#================================================================================
#  Configure and add AXI slaves
#================================================================================
#source ../configs/${build_name}/autogen/AddSlaves_${build_name}.tcl
source -quiet ${apollo_root_path}/bd/add_slaves_from_yaml.tcl
yaml_to_bd "${apollo_root_path}/configs/${build_name}/slaves.yaml"

set_property -dict [list CONFIG.CHANNEL_ENABLE_VUSER0_SLAVE0_SSIT {true} CONFIG.CHANNEL_ENABLE_VUSER0_SLAVE1_SSIT {true} CONFIG.CHANNEL_ENABLE_VUSER0_SLAVE2_SSIT {true} CONFIG.Enable_Slave0 {true} CONFIG.Enable_Slave1 {true} CONFIG.Enable_Slave2 {true}] [get_bd_cells VIRTEX_SYS_MGMT]

#========================================
#  Finish up
#========================================
validate_bd_design

make_wrapper -files [get_files ${bd_design_name}.bd] -top -import -force
save_bd_design

close_bd_design ${bd_design_name}

