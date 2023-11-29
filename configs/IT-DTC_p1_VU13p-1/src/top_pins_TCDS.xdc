#TCDS ref clocks
set_property PACKAGE_PIN  BD40  [get_ports  TCDS_BP_clk_n ]
set_property PACKAGE_PIN  BD39  [get_ports  TCDS_BP_clk_p ]
set_property PACKAGE_PIN  BC42  [get_ports  n_TCDS_refclk[1] ]
set_property PACKAGE_PIN  BC41  [get_ports  p_TCDS_refclk[1] ]
create_clock -period 3.11884262 -waveform {0.000 1.55942131} [get_nets TCDS_BP_clk_p]

#TCDS recovered clock to Si cleaner/fanout
set_property -dict {PACKAGE_PIN  BK26  IOSTANDARD LVDS}  [get_ports  n_TCDS_REC_out ]
set_property -dict {PACKAGE_PIN  BJ26  IOSTANDARD LVDS}  [get_ports  p_TCDS_REC_out ]

