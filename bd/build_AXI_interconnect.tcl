#================================================================================
#  Create an AXI interconnect
#================================================================================
startgroup
#create an axi interconnect 
set AXI_INTERCONNECT_NAME axi_interconnect_0
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 $AXI_INTERCONNECT_NAME
#create a master for each AXI_BUS device on the interconnect
set AXI_DEVICE_COUNT [array size AXI_BUS_M]
set_property CONFIG.NUM_MI $AXI_DEVICE_COUNT  [get_bd_cells $AXI_INTERCONNECT_NAME]


#connect the interconnect clock to the FCLK_CLK0 of the zynq processing system
#this will create a processor system reset to handle resetting the interconnect
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config {Clk "/processing_system7_0/FCLK_CLK0 (50 MHz)" }  [get_bd_pins $AXI_INTERCONNECT_NAME/ACLK]

#connect zynq processing system's master AXI port to the interconnect's slave AXI port
connect_bd_intf_net [get_bd_intf_pins processing_system7_0/M_AXI_GP0] -boundary_type upper [get_bd_intf_pins $AXI_INTERCONNECT_NAME/S00_AXI]

# Connect the interconnect's slave and master resets to the processor system reset's peripheral reset
set AXI_MASTER_RST [get_bd_pins rst_ps7_0_50M/peripheral_aresetn]
connect_bd_net [get_bd_pins $AXI_MASTER_RST] [get_bd_pins $AXI_INTERCONNECT_NAME/S00_ARESETN]

# Connect the interconnect's slave and master clocks to the processor system's axi master clock (FCLK_CLK0)
connect_bd_net $AXI_MASTER_CLK [get_bd_pins $AXI_INTERCONNECT_NAME/S00_ACLK]

#create AXI output pins (reset)
create_bd_port -dir O -type rst AXI_RST_N
connect_bd_net [get_bd_pins $AXI_MASTER_RST] [get_bd_ports AXI_RST_N]

#create AXI output pins (clk)
create_bd_port -dir O -type clk AXI_CLK
connect_bd_net [get_bd_pins $AXI_MASTER_CLK] [get_bd_ports AXI_CLK]


endgroup
