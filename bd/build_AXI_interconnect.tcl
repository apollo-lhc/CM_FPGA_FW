proc BUILD_AXI_INTERCONNECT {name clk reset master_connections master_clocks master_resets} {
    global AXI_BUS_M

    #create an axi interconnect 
    set AXI_INTERCONNECT_NAME $name

    #assert master_connections and master_clocks are the same size
    if {[llength master_connections] != [llength master_clocks] || [llength master_connections] != [llength master_resets]} then {
	error "master size mismatch"
    }
    
    startgroup
    #================================================================================
    #  Create an AXI interconnect
    #================================================================================    
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 $AXI_INTERCONNECT_NAME

    #create a slave for each AXI_BUS master to the interconnect
    set AXI_MASTER_COUNT [llength $master_connections]
    set_property CONFIG.NUM_SI $AXI_MASTER_COUNT  [get_bd_cells $AXI_INTERCONNECT_NAME]
    
    #create a master for each AXI_BUS device on the interconnect
    set AXI_DEVICE_COUNT [array size AXI_BUS_M]
    set_property CONFIG.NUM_MI $AXI_DEVICE_COUNT  [get_bd_cells $AXI_INTERCONNECT_NAME]

    
    
    #loop
    #connect this interconnect interaces' clock to the AXI master clk
    connect_bd_net -q [get_bd_pins $clk] [get_bd_pins $AXI_INTERCONNECT_NAME/ACLK]
    connect_bd_net -q [get_bd_ports $clk] [get_bd_pins $AXI_INTERCONNECT_NAME/ACLK]
    connect_bd_net [get_bd_pins $reset] [get_bd_pins $AXI_INTERCONNECT_NAME/ARESETN]

    for {set iSlave 0} {$iSlave < ${AXI_MASTER_COUNT}} {incr iSlave} {
	startgroup
	#build this interface's slave interface label
	set slaveID [format "%02d" ${iSlave}]
	set slaveM [lindex $master_connections ${iSlave}]
	set slaveC [lindex $master_clocks ${iSlave}]
	set slaveR [lindex $master_resets ${iSlave}]
	
	

	# Connect the interconnect's slave and master clocks to the processor system's axi master clock (FCLK_CLK0)
	connect_bd_net [get_bd_pins $slaveC] [get_bd_pins $AXI_INTERCONNECT_NAME/S${slaveID}_ACLK]

	# Connect resets
	connect_bd_net [get_bd_pins $slaveR] [get_bd_pins $AXI_INTERCONNECT_NAME/S${slaveID}_ARESETN]

	#connect up this interconnect's slave interface to the master $iSlave driving it
	connect_bd_intf_net [get_bd_intf_pins $slaveM] -boundary_type upper [get_bd_intf_pins $AXI_INTERCONNECT_NAME/S${slaveID}_AXI]
	endgroup
  }
    
    endgroup
}
