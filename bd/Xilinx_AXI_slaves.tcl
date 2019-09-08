source ../bd/axi_slave_helpers.tcl
proc AXI_IP_I2C {device_name  {local 1}} {
    global AXI_BUS_M
    global AXI_BUS_RST
    global AXI_BUS_CLK
    global AXI_MASTER_CLK
    global AXI_SLAVE_RSTN
    global AXI_INTERCONNECT_NAME
    
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic:2.0 $device_name

    #create external pins
    make_bd_pins_external  -name ${device_name}_scl_i [get_bd_pins $device_name/scl_i]
    make_bd_pins_external  -name ${device_name}_sda_i [get_bd_pins $device_name/sda_i]
    make_bd_pins_external  -name ${device_name}_sda_o [get_bd_pins $device_name/sda_o]
    make_bd_pins_external  -name ${device_name}_scl_o [get_bd_pins $device_name/scl_o]
    make_bd_pins_external  -name ${device_name}_scl_t [get_bd_pins $device_name/scl_t]
    make_bd_pins_external  -name ${device_name}_sda_t [get_bd_pins $device_name/sda_t]
    #connect to AXI, clk, and reset between slave and mastre
    [AXI_DEV_CONNECT $device_name $AXI_BUS_M($device_name) $AXI_BUS_CLK($device_name) $AXI_BUS_RST($device_name) $local]
    connect_bd_net [get_bd_pins $AXI_MASTER_CLK] [get_bd_pins $AXI_BUS_CLK($device_name)]
    connect_bd_net [get_bd_pins $AXI_SLAVE_RSTN] [get_bd_pins $AXI_BUS_RST($device_name)]
    puts "Added Xilinx I2C AXI Slave: $device_name"
}

proc AXI_IP_XVC {device_name  {local 1}} {
    global AXI_BUS_M
    global AXI_BUS_RST
    global AXI_BUS_CLK
    global AXI_MASTER_CLK
    global AXI_SLAVE_RSTN
    global AXI_INTERCONNECT_NAME
    
    #Create a xilinx axi debug bridge
    create_bd_cell -type ip -vlnv xilinx.com:ip:debug_bridge:3.0 $device_name
    #configure the debug bridge to be 
    set_property CONFIG.C_DEBUG_MODE  {3} [get_bd_cells $device_name]
    set_property CONFIG.C_DESIGN_TYPE {0} [get_bd_cells $device_name]

    #connect to AXI, clk, and reset between slave and mastre
    [AXI_DEV_CONNECT $device_name $AXI_BUS_M($device_name) $AXI_BUS_CLK($device_name) $AXI_BUS_RST($device_name) $local]
    connect_bd_net [get_bd_pins $AXI_MASTER_CLK] [get_bd_pins $AXI_BUS_CLK($device_name)]
    connect_bd_net [get_bd_pins $AXI_SLAVE_RSTN] [get_bd_pins $AXI_BUS_RST($device_name)]

    
    #generate ports for the JTAG signals
    make_bd_pins_external       [get_bd_cells $device_name]
    make_bd_intf_pins_external  [get_bd_cells $device_name]
    puts "Added Xilinx XVC AXI Slave: $device_name"
}

proc AXI_IP_LOCAL_XVC {device_name } {
    global AXI_BUS_M
    global AXI_BUS_RST
    global AXI_BUS_CLK
    global AXI_MASTER_CLK
    global AXI_SLAVE_RSTN
    #Create a xilinx axi debug bridge
    create_bd_cell -type ip -vlnv xilinx.com:ip:debug_bridge:3.0 $device_name
    #configure the debug bridge to be 
    set_property CONFIG.C_DEBUG_MODE  {2}   [get_bd_cells $device_name]
#    set_property CONFIG.C_NUM_BS_MASTER {4} [get_bd_cells $device_name]

    
    #connect to AXI, clk, and reset between slave and mastre
    [AXI_DEV_CONNECT $device_name $AXI_BUS_M($device_name) $AXI_BUS_CLK($device_name) $AXI_BUS_RST($device_name)]
    connect_bd_net [get_bd_pins $AXI_MASTER_CLK] [get_bd_pins $AXI_BUS_CLK($device_name)]
    connect_bd_net [get_bd_pins $AXI_SLAVE_RSTN] [get_bd_pins $AXI_BUS_RST($device_name)]

    puts "Added Xilinx Local XVC AXI Slave: $device_name"
}

proc AXI_IP_UART {device_name baud_rate  {local 1}} {
    global AXI_BUS_M
    global AXI_BUS_RST
    global AXI_BUS_CLK
    global AXI_MASTER_CLK
    global AXI_SLAVE_RSTN
    global AXI_INTERCONNECT_NAME
    
    #Create a xilinx UART
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 $device_name
    #configure the debug bridge to be
    set_property CONFIG.C_BAUDRATE $baud_rate [get_bd_cells $device_name]

    #connect to AXI, clk, and reset between slave and mastre
    [AXI_DEV_CONNECT $device_name $AXI_BUS_M($device_name) $AXI_BUS_CLK($device_name) $AXI_BUS_RST($device_name) $local]
    connect_bd_net [get_bd_pins $AXI_MASTER_CLK] [get_bd_pins $AXI_BUS_CLK($device_name)]
    connect_bd_net [get_bd_pins $AXI_SLAVE_RSTN] [get_bd_pins $AXI_BUS_RST($device_name)]

    
    #generate ports for the JTAG signals
    make_bd_intf_pins_external  -name ${device_name} [get_bd_intf_pins $device_name/UART]

    
    puts "Added Xilinx UART AXI Slave: $device_name"
}

proc C2C_AURORA {device_name INIT_CLK} {

    set C2C ${device_name}
    set C2C_PHY ${C2C}_phy    
    #create chip-2-chip aurora     
    startgroup 
    create_bd_cell -type ip -vlnv xilinx.com:ip:aurora_64b66b:11.2 ${C2C_PHY}        
    set_property CONFIG.C_INIT_CLK.VALUE_SRC PROPAGATED   [get_bd_cells ${C2C_PHY}]  
    set_property CONFIG.C_AURORA_LANES       {1}          [get_bd_cells ${C2C_PHY}]
    #set_property CONFIG.C_AURORA_LANES       {2}          [get_bd_cells ${C2C_PHY}]  
    set_property CONFIG.C_LINE_RATE          {5}          [get_bd_cells ${C2C_PHY}]
#    set_property CONFIG.C_LINE_RATE          {10}          [get_bd_cells ${C2C_PHY}]  
    set_property CONFIG.C_REFCLK_FREQUENCY   {100.000}    [get_bd_cells ${C2C_PHY}]  
    set_property CONFIG.interface_mode       {Streaming}  [get_bd_cells ${C2C_PHY}]  
    set_property CONFIG.SupportLevel         {1}          [get_bd_cells ${C2C_PHY}]  
    set_property CONFIG.SINGLEEND_INITCLK    {true}       [get_bd_cells ${C2C_PHY}]  
    set_property CONFIG.C_INCLUDE_AXILITE    {1}          [get_bd_cells ${C2C_PHY}]


    set_property -dict [list CONFIG.C_GT_CLOCK_1 {GTXQ3} CONFIG.C_GT_LOC_9 {X} CONFIG.C_GT_LOC_15 {1}]          [get_bd_cells ${C2C_PHY}]


    #expose the Aurora core signals to top   
    make_bd_intf_pins_external  -name ${C2C_PHY}_refclk         [get_bd_intf_pins ${C2C_PHY}/GT_DIFF_REFCLK1]    
    make_bd_intf_pins_external  -name ${C2C_PHY}_Rx             [get_bd_intf_pins ${C2C_PHY}/GT_SERIAL_RX]       
    make_bd_intf_pins_external  -name ${C2C_PHY}_Tx             [get_bd_intf_pins ${C2C_PHY}/GT_SERIAL_TX]
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
#    connect_bd_net [get_bd_pins ${C2C_PHY}/init_clk]            [get_bd_pins ${C2C}/aurora_init_clk]    
    connect_bd_net [get_bd_pins ${C2C_PHY}/mmcm_not_locked_out] [get_bd_pins ${C2C}/aurora_mmcm_not_locked]        
    connect_bd_net [get_bd_pins ${C2C}/aurora_pma_init_out]     [get_bd_pins ${C2C_PHY}/pma_init]        
    connect_bd_net [get_bd_pins ${C2C}/aurora_reset_pb]         [get_bd_pins ${C2C_PHY}/reset_pb]        
    
    
    #connect external 200Mhz clock to init clocks      
    connect_bd_net [get_bd_ports ${INIT_CLK}]   [get_bd_pins ${C2C_PHY}/init_clk]       
    connect_bd_net [get_bd_ports ${INIT_CLK}]   [get_bd_pins ${C2C}/aurora_init_clk]
    connect_bd_net [get_bd_ports ${INIT_CLK}]   [get_bd_pins ${C2C_PHY}/drp_clk_in]    


    #############################################################################
    ### ibert testing
    set ibert_name ${C2C_PHY}_ibert
    create_bd_cell -type ip -vlnv xilinx.com:ip:in_system_ibert:1.0 ${ibert_name}
    set_property -dict [list CONFIG.C_GTS_USED { X0Y0} CONFIG.C_ENABLE_INPUT_PORTS {false}] [get_bd_cells ${ibert_name}]
    #modify ${C2C_PHY}
    set_property -dict [list CONFIG.drp_mode {Native}] [get_bd_cells ${C2C_PHY}]
    set_property -dict [list CONFIG.TransceiverControl {true}] [get_bd_cells ${C2C_PHY}]

    #connect up the ibert
    connect_bd_net [get_bd_ports clk50Mhz] [get_bd_pins ${ibert_name}/clk]
    connect_bd_intf_net [get_bd_intf_pins ${ibert_name}/GT0_DRP] [get_bd_intf_pins ${C2C_PHY}/GT0_DRP]
    connect_bd_net [get_bd_pins ${ibert_name}/eyescanreset_o] [get_bd_pins ${C2C_PHY}/gt_eyescanreset]
    connect_bd_net [get_bd_pins ${ibert_name}/rxrate_o] [get_bd_pins ${C2C_PHY}/gt_rxrate]
    connect_bd_net [get_bd_pins ${ibert_name}/txdiffctrl_o] [get_bd_pins ${C2C_PHY}/gt_txdiffctrl]
    connect_bd_net [get_bd_pins ${ibert_name}/txprecursor_o] [get_bd_pins ${C2C_PHY}/gt_txprecursor]
    connect_bd_net [get_bd_pins ${ibert_name}/txpostcursor_o] [get_bd_pins ${C2C_PHY}/gt_txpostcursor]
    connect_bd_net [get_bd_pins ${ibert_name}/rxlpmen_o] [get_bd_pins ${C2C_PHY}/gt_rxlpmen]
    connect_bd_net [get_bd_pins ${C2C_PHY}/user_clk_out] [get_bd_pins ${ibert_name}/rxoutclk_i]
    #############################################################################
    
    endgroup      
}

proc AXI_C2C_MASTER {device_name} {
    global AXI_BUS_M
    global AXI_BUS_RST
    global AXI_BUS_CLK
    global AXI_MASTER_CLK
    global AXI_SLAVE_RSTN

    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_chip2chip:5.0 $device_name
    set_property CONFIG.C_AXI_STB_WIDTH {4}         [get_bd_cells $device_name]
    set_property CONFIG.C_AXI_DATA_WIDTH {32}	    [get_bd_cells $device_name]
    set_property CONFIG.C_NUM_OF_IO {58.0}	    [get_bd_cells $device_name]
    set_property CONFIG.C_INTERFACE_MODE {1}	    [get_bd_cells $device_name]
    set_property CONFIG.C_INTERFACE_TYPE {2}	    [get_bd_cells $device_name]
    set_property CONFIG.C_AURORA_WIDTH {1.0}        [get_bd_cells $device_name]
    set_property CONFIG.C_EN_AXI_LINK_HNDLR {false} [get_bd_cells $device_name]

    #axi interface
    [AXI_DEV_CONNECT ${device_name} $AXI_BUS_M(${device_name}) $AXI_BUS_CLK(${device_name}) $AXI_BUS_RST(${device_name}) -1]
    connect_bd_net [get_bd_pins $AXI_MASTER_CLK] [get_bd_pins $AXI_BUS_CLK($device_name)]
    connect_bd_net [get_bd_pins $AXI_SLAVE_RSTN] [get_bd_pins $AXI_BUS_RST($device_name)]

    #axi lite interface
    [AXI_LITE_DEV_CONNECT ${device_name} $AXI_BUS_M(${device_name}_LITE) $AXI_BUS_CLK(${device_name}_LITE) $AXI_BUS_RST(${device_name}_LITE)]
    connect_bd_net [get_bd_pins $AXI_MASTER_CLK] [get_bd_pins $AXI_BUS_CLK(${device_name}_LITE)]

    make_bd_pins_external       -name ${device_name}_aurora_pma_init_in [get_bd_pins ${device_name}/aurora_pma_init_in]
    #expose debugging signals
    make_bd_pins_external       -name ${device_name}_aurora_do_cc [get_bd_pins ${device_name}/aurora_do_cc]
    make_bd_pins_external       -name ${device_name}_axi_c2c_config_error_out    [get_bd_pins ${device_name}/axi_c2c_config_error_out   ]
    make_bd_pins_external       -name ${device_name}_axi_c2c_link_status_out     [get_bd_pins ${device_name}/axi_c2c_link_status_out    ]
    make_bd_pins_external       -name ${device_name}_axi_c2c_multi_bit_error_out [get_bd_pins ${device_name}/axi_c2c_multi_bit_error_out]
    make_bd_pins_external       -name ${device_name}_axi_c2c_link_error_out      [get_bd_pins ${device_name}/axi_c2c_link_error_out     ]
    

    [C2C_AURORA ${device_name} init_clk]
    
    assign_bd_address [get_bd_addr_segs {$device_name/S_AXI/Mem }]
    puts "Added C2C master: $device_name"
}

proc AXI_IP_XADC {device_name {local 1}} {
    global AXI_BUS_M
    global AXI_BUS_RST
    global AXI_BUS_CLK
    global AXI_MASTER_CLK
    global AXI_SLAVE_RSTN
    global AXI_INTERCONNECT_NAME

    #create XADC AXI slave 
    create_bd_cell -type ip -vlnv xilinx.com:ip:xadc_wiz:3.3 ${device_name}

    #disable default user temp monitoring
    set_property CONFIG.USER_TEMP_ALARM {false} [get_bd_cells ${device_name}]

    
    #connect to interconnect
    [AXI_DEV_CONNECT $device_name $AXI_BUS_M($device_name) $AXI_BUS_CLK($device_name) $AXI_BUS_RST($device_name) $local]
    connect_bd_net [get_bd_pins $AXI_MASTER_CLK] [get_bd_pins $AXI_BUS_CLK($device_name)]
    connect_bd_net [get_bd_pins $AXI_SLAVE_RSTN] [get_bd_pins $AXI_BUS_RST($device_name)]

    
    #expose alarms
    make_bd_pins_external   -name ${device_name}_alarm             [get_bd_pins ${device_name}/alarm_out]
    make_bd_pins_external   -name ${device_name}_vccint_alarm      [get_bd_pins ${device_name}/vccint_alarm_out]
    make_bd_pins_external   -name ${device_name}_vccaux_alarm      [get_bd_pins ${device_name}/vccaux_alarm_out]
    make_bd_pins_external   -name ${device_name}_vccpint_alarm     [get_bd_pins ${device_name}/vccpint_alarm_out]
    make_bd_pins_external   -name ${device_name}_vccpaux_alarm     [get_bd_pins ${device_name}/vccpaux_alarm_out]
    make_bd_pins_external   -name ${device_name}_vccddro_alarm     [get_bd_pins ${device_name}/vccddro_alarm_out]
    make_bd_pins_external   -name ${device_name}_overtemp_alarm    [get_bd_pins ${device_name}/ot_alarm_out]

    puts "Added Xilinx XADC AXI Slave: $device_name"

}


proc AXI_IP_SYS_MGMT {device_name {local 1}} {
    global AXI_BUS_M
    global AXI_BUS_RST
    global AXI_BUS_CLK
    global AXI_MASTER_CLK
    global AXI_SLAVE_RSTN
    global AXI_INTERCONNECT_NAME

    
    #create system management AXIL lite slave
    create_bd_cell -type ip -vlnv xilinx.com:ip:system_management_wiz:1.3 ${device_name}

    #disable default user temp monitoring
    set_property CONFIG.USER_TEMP_ALARM {false}        [get_bd_cells ${device_name}]
    #add i2c interface
    set_property CONFIG.SERIAL_INTERFACE {Enable_I2C}  [get_bd_cells ${device_name}]
    set_property CONFIG.I2C_ADDRESS_OVERRIDE {false}   [get_bd_cells ${device_name}]
    
    #connect to interconnect
    [AXI_DEV_CONNECT $device_name $AXI_BUS_M($device_name) $AXI_BUS_CLK($device_name) $AXI_BUS_RST($device_name) $local]

    
    #expose alarms
    make_bd_pins_external   -name ${device_name}_alarm             [get_bd_pins ${device_name}/alarm_out]
    make_bd_pins_external   -name ${device_name}_vccint_alarm      [get_bd_pins ${device_name}/vccint_alarm_out]
    make_bd_pins_external   -name ${device_name}_vccaux_alarm      [get_bd_pins ${device_name}/vccaux_alarm_out]
    make_bd_pins_external   -name ${device_name}_overtemp_alarm    [get_bd_pins ${device_name}/ot_out]

    #expose i2c interface
    make_bd_pins_external  -name ${device_name}_sda [get_bd_pins KINTEX_SYS_MGMT/i2c_sda]
    make_bd_pins_external  -name ${device_name}_scl [get_bd_pins KINTEX_SYS_MGMT/i2c_sclk]
    
    puts "Added Xilinx XADC AXI Slave: $device_name"

}


proc AXI_IP_BRAM {device_name {local 1}} {
    global AXI_BUS_M
    global AXI_BUS_RST
    global AXI_BUS_CLK
    global AXI_MASTER_CLK
    global AXI_SLAVE_RSTN
    global AXI_INTERCONNECT_NAME

    #create XADC AXI slave 
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 ${device_name}

    set_property CONFIG.SINGLE_PORT_BRAM {1} [get_bd_cells ${device_name}]

    
    #connect to interconnect
    [AXI_DEV_CONNECT $device_name $AXI_BUS_M($device_name) $AXI_BUS_CLK($device_name) $AXI_BUS_RST($device_name) $local]
   
    puts "Added Xilinx blockram: $device_name"
}


