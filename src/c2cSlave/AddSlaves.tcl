#================================================================================
#  Configure and add AXI slaves
#================================================================================


#expose the interconnect's axi master port for an axi slave
puts "Adding user slaves"


[AXI_PL_DEV_CONNECT CM_K_INFO            ${AXI_INTERCONNECT_NAME} ${AXI_MASTER_CLK} ${AXI_MASTER_RSTN} 50000000 0x83c43000 4K]
[AXI_PL_DEV_CONNECT KINTEX_TCDS          ${AXI_INTERCONNECT_NAME} ${AXI_MASTER_CLK} ${AXI_MASTER_RSTN} 50000000 0x83c46000 4K]
[AXI_PL_DEV_CONNECT KINTEX_TCDS_DRP      ${AXI_INTERCONNECT_NAME} ${AXI_MASTER_CLK} ${AXI_MASTER_RSTN} 50000000 0x83c47000 4K]
[AXI_PL_DEV_CONNECT IPBUS_KINTEX         ${AXI_INTERCONNECT_NAME} ${AXI_MASTER_CLK} ${AXI_MASTER_RSTN} 50000000 0x8a000000 32M AXI4]
