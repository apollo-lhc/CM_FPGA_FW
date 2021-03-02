# VU7P constraint file for the Apollo 6089-103 board.
#
# The schematic prefixes of 'k_' or 'v_ are dropped from names. They appear on the
# the schematics to differentiate signals, like 'k_led_red' vs. 'v_led_red'. In
# the Vivado code, they are just 'led_red' in both the KU15P and VU7P files.  
#
# The schematic prefixes of 'bc' and 'ac' are dropped from names. They appear
# on the schematics to differentiate on which side of a coupling capacitor the
# signal appears.
#
# Differential pair names start with 'p_' or 'n_'.
#
# Except for clock inputs, signals that can be bused together use bracketed,
# numbered suffixes.

#-------------------------------------------------
# Important! Do not remove this constraint!
# This property ensures that all unused pins are set to high impedance.
# If the constraint is removed, all unused pins have to be set to HiZ in the top level file.
set_property BITSTREAM.CONFIG.UNUSEDPIN PULLNONE [current_design]
#-------------------------------------------------

#-------------------------------------------------
# turn off on over-temperature
#set_property BITSTREAM.CONFIG.OVERTEMPPOWERDOWN ENABLE [current_design];
#-------------------------------------------------

#-------------------------------------------------
# Set internal reference voltages to 0.90 on banks with I/O signals.
# This is required for the HSTL and DIFF_HSTL I/O standards
#set_property INTERNAL_VREF 0.90 [get_iobanks 66]
#-------------------------------------------------

#-------------------------------------------------
# 100 MHz system clock on bank 66

# 'input' clk_100: 100 MHz clock (schematic name is  "KUP_100MHZ_AC_P/N")
set_property IOSTANDARD LVDS [get_ports i_clk_100_*]
set_property DIFF_TERM_ADV TERM_100 [get_ports i_clk_100_*]
set_property PACKAGE_PIN  AY16  [get_ports i_clk_100_p]
set_property PACKAGE_PIN  AY15  [get_ports i_clk_100_n]
#-------------------------------------------------

#-----------------------------------------------
# GTH/GTY transceiver clocks

# Quad A (224)
set_property PACKAGE_PIN  AK10  [get_ports  i_refclk_axi_c2c_p ]
set_property PACKAGE_PIN  AK9   [get_ports  i_refclk_axi_c2c_n ]
#-----------------------------------------------

#-----------------------------------------------
# GTH AXI chip-to-chip links to the SM SoC.

# Quad A (224)
set_property PACKAGE_PIN  BB6   [get_ports  {i_mgt_axi_c2c_p[1]} ]
set_property PACKAGE_PIN  BB5   [get_ports  {i_mgt_axi_c2c_n[1]} ]
set_property PACKAGE_PIN  BA4   [get_ports  {i_mgt_axi_c2c_p[2]} ]
set_property PACKAGE_PIN  BA3   [get_ports  {i_mgt_axi_c2c_n[2]} ]

set_property PACKAGE_PIN  AW7   [get_ports  {o_mgt_axi_c2c_p[1]} ]
set_property PACKAGE_PIN  AW7   [get_ports  {o_mgt_axi_c2c_n[1]} ]
set_property PACKAGE_PIN  AV10  [get_ports  {o_mgt_axi_c2c_p[2]} ]
set_property PACKAGE_PIN  AV9   [get_ports  {o_mgt_axi_c2c_n[2]} ]
#-----------------------------------------------

#-----------------------------------------------
# Other inputs and outputs.

# 'output' "led": 3 bits to light LEDs
set_property IOSTANDARD LVCMOS33 [get_ports o_led*]
set_property PACKAGE_PIN C12 [get_ports {o_led[0]} ]
set_property PACKAGE_PIN B11 [get_ports {o_led[1]} ]
set_property PACKAGE_PIN B13 [get_ports {o_led[2]} ]
set_property PACKAGE_PIN B12 [get_ports {o_led[3]} ]
set_property PACKAGE_PIN E12 [get_ports {o_led[4]} ]
set_property PACKAGE_PIN D12 [get_ports {o_led[5]} ]
set_property PACKAGE_PIN E13 [get_ports {o_led[6]} ]
set_property PACKAGE_PIN D13 [get_ports {o_led[7]} ]

# WHAT TO DO ABOUT I2C PINS???
set_property IOSTANDARD LVCMOS18 [get_ports io_sysmon_i2c_*] 
set_property PACKAGE_PIN  AL24 [get_ports  io_sysmon_i2c_scl ]
set_property PACKAGE_PIN  AL25 [get_ports  io_sysmon_i2c_sda ]
#-----------------------------------------------

