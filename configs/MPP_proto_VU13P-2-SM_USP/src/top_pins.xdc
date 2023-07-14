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
# set_property INTERNAL_VREF 0.90 [get_iobanks 66]
# set_property INTERNAL_VREF 0.90 [get_iobanks 67]
# set_property INTERNAL_VREF 0.90 [get_iobanks 72]
#-------------------------------------------------

# 200M Oscillator
set_property -quiet PACKAGE_PIN AT17 [get_ports p_clk_200] ; # IN: oscillator clock
set_property -quiet PACKAGE_PIN AU16 [get_ports n_clk_200] ; # IN: oscillator clock
create_clock -period 5.00 -name clock_async [get_ports p_clk_200]
set_property DIFF_TERM_ADV TERM_100 [get_ports *_clk_200]

#-------------------------------------------------


set_property PACKAGE_PIN  BD12 [get_ports  n_util_clk_chan0 ]
set_property PACKAGE_PIN  BD13 [get_ports  p_util_clk_chan0 ]


set_property PACKAGE_PIN  BG19  [get_ports  {n_mgt_z2k[1]} ]
set_property PACKAGE_PIN  BG20  [get_ports  {p_mgt_z2k[1]} ]
set_property PACKAGE_PIN  BH12  [get_ports  {n_mgt_z2k[2]} ]
set_property PACKAGE_PIN  BH13  [get_ports  {p_mgt_z2k[2]} ]

set_property PACKAGE_PIN  BF17  [get_ports  {n_mgt_k2z[1]} ]
set_property PACKAGE_PIN  BF18 [get_ports  {p_mgt_k2z[1]} ]
set_property PACKAGE_PIN  BF12  [get_ports  {n_mgt_k2z[2]} ]
set_property PACKAGE_PIN  BF13  [get_ports  {p_mgt_k2z[2]} ]
#-----------------------------------------------


#-----------------------------------------------
# Pins AP14 and AP15 are fanned out to vias, but then go nowhere.
# They could be used in an emergency as I/Os to bank 66
#set_property PACKAGE_PIN  AP15 [get_ports  _d_18df08e0 ]
#set_property PACKAGE_PIN  AP14 [get_ports  _d_18df15b0 ]
#-----------------------------------------------












