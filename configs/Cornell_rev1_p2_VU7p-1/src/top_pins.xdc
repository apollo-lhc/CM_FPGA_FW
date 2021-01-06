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
set_property INTERNAL_VREF 0.90 [get_iobanks 45]
set_property INTERNAL_VREF 0.90 [get_iobanks 52]
set_property INTERNAL_VREF 0.90 [get_iobanks 72]
#-------------------------------------------------

#-------------------------------------------------
# 200 MHz system clock on banks 45 and 52
# One clock is on each side of the SLR boundary

# 'input' clk_200a: 200 MHz clock (schematic name is "ac_*v_util_clk_chan2")
set_property IOSTANDARD LVDS   [get_ports *_clk_200a]
set_property DIFF_TERM_ADV TERM_100 [get_ports *_clk_200a]
set_property PACKAGE_PIN  BB35 [get_ports  n_clk_200a ]
set_property PACKAGE_PIN  BA35 [get_ports  p_clk_200a ]

# 'input' clk_200b: 200 MHz clock (schematic name is "*util_clk_chan3")
set_property IOSTANDARD LVDS   [get_ports *_clk_200b]
set_property DIFF_TERM_ADV TERM_100 [get_ports *_clk_200b]
set_property PACKAGE_PIN  H28  [get_ports  n_clk_200b ]
set_property PACKAGE_PIN  H27  [get_ports  p_clk_200b ]
#-------------------------------------------------

#-----------------------------------------------
# CMS clock and timing signals from the service blade
# These are connected to port #3 of GTY quad 224
# This quad can be clocked from:
#  a) 200 MHz 'utl_clk_chan0' (direct)
#  b) 312.5 MHz 'clk0_chan0' (from quad 225)
#  c) programmable 'clk1_chan0' (from quad 225)

# 'input' atca_ttc_in_*: (schematic name is "ac_*v_ttc_in")
set_property PACKAGE_PIN  AV1  [get_ports  n_atca_ttc_in ]
set_property PACKAGE_PIN  AV2  [get_ports  p_atca_ttc_in ]

# 'output' atca_tts_out_*: (schematic name is "bc_*v_tts_out")
set_property PACKAGE_PIN  AV6  [get_ports  n_atca_tts_out ]
set_property PACKAGE_PIN  AV7  [get_ports  p_atca_tts_out ]
#-----------------------------------------------

#-----------------------------------------------
# Legacy clock and timing signals from the AMC13 front panel connector
# Jumpers need to be installed to connect these signals to this FPGA

# 'input' amc13_clk40_*: 40 MHz clock (schematic name is "ac_*v_ttc_clk40")
# The legacy 40 MHz clock from the front panel SFP connecter was not routed to "clock capable"
# pins on the VU7P (it is OK on the KU15P). Since this is only 40 MHz, the following Vivado
# constraint will allow the router to internally run the clock to a global clock buffer.
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets amc13_clk_40_buf/O]

set_property IOSTANDARD LVDS   [get_ports *_amc13_clk_40]
set_property DIFF_TERM_ADV TERM_100 [get_ports *_amc13_clk_40]
set_property PACKAGE_PIN  AN33 [get_ports  n_amc13_clk_40 ]
set_property PACKAGE_PIN  AN32 [get_ports  p_amc13_clk_40 ]

# 'input' amc13_cdr_data_*: recovered data (schematic name is "*v_cdr_data")
set_property IOSTANDARD LVDS   [get_ports *_amc13_cdr_data]
set_property DIFF_TERM_ADV TERM_100 [get_ports *_amc13_cdr_data]
set_property PACKAGE_PIN  AP34 [get_ports  n_amc13_cdr_data ]
set_property PACKAGE_PIN  AN34 [get_ports  p_amc13_cdr_data ]

# 'output' amc13_tts_out_*: status (schematic name is *v_tts_out)
set_property IOSTANDARD LVDS   [get_ports *_amc13_tts_out]
set_property PACKAGE_PIN  AR33 [get_ports  n_amc13_tts_out ]
set_property PACKAGE_PIN  AP33 [get_ports  p_amc13_tts_out ]
#-----------------------------------------------

#-----------------------------------------------
# GTY transceiver clocks
# 'input' "util_clk" fixed oscillator source (200 MHz)
# 'input' "clk0" fixed oscillator source (312.5 MHz)
# 'input' "clk1" programmable source

# Quad A (224)
set_property PACKAGE_PIN  AW8  [get_ports  n_util_clk_chan0 ]
set_property PACKAGE_PIN  AW9  [get_ports  p_util_clk_chan0 ]

# Quad B (quad 225)
set_property PACKAGE_PIN  AT10 [get_ports  n_clk0_chan0 ]
set_property PACKAGE_PIN  AT11 [get_ports  p_clk0_chan0 ]
set_property PACKAGE_PIN  AP10 [get_ports  n_clk1_chan0 ]
set_property PACKAGE_PIN  AP11 [get_ports  p_clk1_chan0 ]

# Quad D (quad 227)
set_property PACKAGE_PIN  AH10 [get_ports  n_clk0_chan1 ]
set_property PACKAGE_PIN  AH11 [get_ports  p_clk0_chan1 ]
set_property PACKAGE_PIN  AF10 [get_ports  n_clk1_chan1 ]
set_property PACKAGE_PIN  AF11 [get_ports  p_clk1_chan1 ]

# Quad G (quad 230)
set_property PACKAGE_PIN  T10  [get_ports  n_clk0_chan2 ]
set_property PACKAGE_PIN  T11  [get_ports  p_clk0_chan2 ]
set_property PACKAGE_PIN  P10  [get_ports  n_clk1_chan2 ]
set_property PACKAGE_PIN  P11  [get_ports  p_clk1_chan2 ]

# Quad I (quad 232)
set_property PACKAGE_PIN  H10  [get_ports  n_clk0_chan3 ]
set_property PACKAGE_PIN  H11  [get_ports  p_clk0_chan3 ]
set_property PACKAGE_PIN  F10  [get_ports  n_clk1_chan3 ]
set_property PACKAGE_PIN  F11  [get_ports  p_clk1_chan3 ]

# Quad K (quad 125)
set_property PACKAGE_PIN  BA41 [get_ports  n_util_clk_chan1 ]
set_property PACKAGE_PIN  BA40 [get_ports  p_util_clk_chan1 ]

# Quad L (quad 126)
set_property PACKAGE_PIN  AV39 [get_ports  n_clk0_chan4 ]
set_property PACKAGE_PIN  AV38 [get_ports  p_clk0_chan4 ]
set_property PACKAGE_PIN  AU37 [get_ports  n_clk1_chan4 ]
set_property PACKAGE_PIN  AU36 [get_ports  p_clk1_chan4 ]

# Quad N (quad 128)
set_property PACKAGE_PIN  AL37 [get_ports  n_clk0_chan5 ]
set_property PACKAGE_PIN  AL36 [get_ports  p_clk0_chan5 ]
set_property PACKAGE_PIN  AJ37 [get_ports  n_clk1_chan5 ]
set_property PACKAGE_PIN  AJ36 [get_ports  p_clk1_chan5 ]

# Quad P (quad 130)
set_property PACKAGE_PIN  AC37 [get_ports  n_clk0_chan6 ]
set_property PACKAGE_PIN  AC36 [get_ports  p_clk0_chan6 ]
set_property PACKAGE_PIN  AA37 [get_ports  n_clk1_chan6 ]
set_property PACKAGE_PIN  AA36 [get_ports  p_clk1_chan6 ]

# Quad R (quad 132)
set_property PACKAGE_PIN  R37  [get_ports  n_clk0_chan7 ]
set_property PACKAGE_PIN  R36  [get_ports  p_clk0_chan7 ]
set_property PACKAGE_PIN  N37  [get_ports  n_clk1_chan7 ]
set_property PACKAGE_PIN  N36  [get_ports  p_clk1_chan7 ]
#-----------------------------------------------

#-----------------------------------------------
# GTY chip-to-chip links to the KU15P
# These are labeled 'c2c' on the schematic, but 'mgt' in here
# 'input' "k2v": links from the KU15P
# 'output' "v2k": links to the KU15P

# Quad K (125)
set_property PACKAGE_PIN  BC46 [get_ports  {n_mgt_k2v[0]} ]
set_property PACKAGE_PIN  BC45 [get_ports  {p_mgt_k2v[0]} ]
set_property PACKAGE_PIN  BA46 [get_ports  {n_mgt_k2v[1]} ]
set_property PACKAGE_PIN  BA45 [get_ports  {p_mgt_k2v[1]} ]
set_property PACKAGE_PIN  AW46 [get_ports  {n_mgt_k2v[2]} ]
set_property PACKAGE_PIN  AW45 [get_ports  {p_mgt_k2v[2]} ]

set_property PACKAGE_PIN  BF42 [get_ports  {n_mgt_v2k[0]} ]
set_property PACKAGE_PIN  BF43 [get_ports  {p_mgt_v2k[0]} ]
set_property PACKAGE_PIN  BD43 [get_ports  {n_mgt_v2k[1]} ]
set_property PACKAGE_PIN  BD42 [get_ports  {p_mgt_v2k[1]} ]
set_property PACKAGE_PIN  BB43 [get_ports  {n_mgt_v2k[2]} ]
set_property PACKAGE_PIN  BB42 [get_ports  {p_mgt_v2k[2]} ]
#-----------------------------------------------

#-----------------------------------------------
# GTY PCIe or chip-to-chip links to the service board
# 'input' "z2v": links from the Zynq on the service board
# 'output' "v2z": links to the Zynq on the service board

# Quad A (224)
set_property PACKAGE_PIN  BA1  [get_ports  {n_mgt_z2v[1]} ]
set_property PACKAGE_PIN  BA2  [get_ports  {p_mgt_z2v[1]} ]
set_property PACKAGE_PIN  BC1  [get_ports  {n_mgt_z2v[2]} ]
set_property PACKAGE_PIN  BC2  [get_ports  {p_mgt_z2v[2]} ]

set_property PACKAGE_PIN  BD4  [get_ports  {n_mgt_v2z[1]} ]
set_property PACKAGE_PIN  BD5  [get_ports  {p_mgt_v2z[1]} ]
set_property PACKAGE_PIN  BF4  [get_ports  {n_mgt_v2z[2]} ]
set_property PACKAGE_PIN  BF5  [get_ports  {p_mgt_v2z[2]} ]
#-----------------------------------------------

#-----------------------------------------------
# 'input' "dip_sw": 2 bits from a DIP switch
set_property IOSTANDARD LVCMOS18 [get_ports dip_sw*] 
set_property PACKAGE_PIN  A28  [get_ports {dip_sw[2]} ]
set_property PACKAGE_PIN  A27  [get_ports {dip_sw[3]} ]
#-----------------------------------------------

#-----------------------------------------------
# 'output' "led": 3 bits to light LEDs
set_property IOSTANDARD LVCMOS18 [get_ports led_*] 
set_property PACKAGE_PIN  C27  [get_ports led_blue]
set_property PACKAGE_PIN  B30  [get_ports led_green]
set_property PACKAGE_PIN  B29  [get_ports led_red]
#-----------------------------------------------

#-----------------------------------------------
# 'input' "from_tm4c": 1 bit trom the TM4C
# 'output' "to_tm4c": 1 bit to the TM4C
set_property IOSTANDARD LVCMOS18 [get_ports *_tm4c] 
set_property PACKAGE_PIN  AL33 [get_ports from_tm4c ]
set_property PACKAGE_PIN  AU34 [get_ports to_tm4c]
#-----------------------------------------------

#-----------------------------------------------
# WHAT TO DO ABOUT I2C PINS???
set_property IOSTANDARD LVCMOS18 [get_ports v_fpga_i2c_*] 
set_property PACKAGE_PIN  AM27 [get_ports v_fpga_i2c_scl]
set_property PACKAGE_PIN  AN27 [get_ports v_fpga_i2c_sda]
#-----------------------------------------------

#-----------------------------------------------
# spare pairs between the KU15P and VU7P
# These should be set up as inputs on both FPGAs until an actual
# use is determined

set_property IOSTANDARD LVDS [get_ports *_kv_spare*]
set_property PACKAGE_PIN  BB34 [get_ports  {n_kv_spare[0]} ]
set_property PACKAGE_PIN  BC38 [get_ports  {n_kv_spare[1]} ]
set_property PACKAGE_PIN  AY36 [get_ports  {n_kv_spare[2]} ]
set_property PACKAGE_PIN  BD39 [get_ports  {n_kv_spare[3]} ]
set_property PACKAGE_PIN  AW33 [get_ports  {n_kv_spare[4]} ]
set_property PACKAGE_PIN  AW36 [get_ports  {n_kv_spare[5]} ]
set_property PACKAGE_PIN  BE36 [get_ports  {n_kv_spare[6]} ]
set_property PACKAGE_PIN  BE40 [get_ports  {n_kv_spare[7]} ]
set_property PACKAGE_PIN  AT34 [get_ports  {n_kv_spare[8]} ]
set_property PACKAGE_PIN  BF40 [get_ports  {n_kv_spare[9]} ]
set_property PACKAGE_PIN  BD34 [get_ports  {n_kv_spare[10]} ]
set_property PACKAGE_PIN  BF38 [get_ports  {n_kv_spare[11]} ]
set_property PACKAGE_PIN  BF37 [get_ports  {n_kv_spare[12]} ]
set_property PACKAGE_PIN  BA34 [get_ports  {p_kv_spare[0]} ]
set_property PACKAGE_PIN  BB38 [get_ports  {p_kv_spare[1]} ]
set_property PACKAGE_PIN  AY35 [get_ports  {p_kv_spare[2]} ]
set_property PACKAGE_PIN  BC39 [get_ports  {p_kv_spare[3]} ]
set_property PACKAGE_PIN  AV33 [get_ports  {p_kv_spare[4]} ]
set_property PACKAGE_PIN  AW35 [get_ports  {p_kv_spare[5]} ]
set_property PACKAGE_PIN  BD36 [get_ports  {p_kv_spare[6]} ]
set_property PACKAGE_PIN  BD40 [get_ports  {p_kv_spare[7]} ]
set_property PACKAGE_PIN  AT33 [get_ports  {p_kv_spare[8]} ]
set_property PACKAGE_PIN  BF39 [get_ports  {p_kv_spare[9]} ]
set_property PACKAGE_PIN  BC34 [get_ports  {p_kv_spare[10]} ]
set_property PACKAGE_PIN  BE38 [get_ports  {p_kv_spare[11]} ]
set_property PACKAGE_PIN  BE37 [get_ports  {p_kv_spare[12]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#1 receivers
set_property PACKAGE_PIN  AP1  [get_ports  {n_ff1_recv[0]} ]
set_property PACKAGE_PIN  AR3  [get_ports  {n_ff1_recv[1]} ]
set_property PACKAGE_PIN  AT1  [get_ports  {n_ff1_recv[2]} ]
set_property PACKAGE_PIN  AU3  [get_ports  {n_ff1_recv[3]} ]
set_property PACKAGE_PIN  AP2  [get_ports  {p_ff1_recv[0]} ]
set_property PACKAGE_PIN  AR4  [get_ports  {p_ff1_recv[1]} ]
set_property PACKAGE_PIN  AT2  [get_ports  {p_ff1_recv[2]} ]
set_property PACKAGE_PIN  AU4  [get_ports  {p_ff1_recv[3]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#1 transmitters
set_property PACKAGE_PIN  AP6  [get_ports  {n_ff1_xmit[0]} ]
set_property PACKAGE_PIN  AR8  [get_ports  {n_ff1_xmit[1]} ]
set_property PACKAGE_PIN  AT6  [get_ports  {n_ff1_xmit[2]} ]
set_property PACKAGE_PIN  AU8  [get_ports  {n_ff1_xmit[3]} ]
set_property PACKAGE_PIN  AP7  [get_ports  {p_ff1_xmit[0]} ]
set_property PACKAGE_PIN  AR9  [get_ports  {p_ff1_xmit[1]} ]
set_property PACKAGE_PIN  AT7  [get_ports  {p_ff1_xmit[2]} ]
set_property PACKAGE_PIN  AU9  [get_ports  {p_ff1_xmit[3]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#2 receivers
set_property PACKAGE_PIN  AK1  [get_ports  {n_ff2_recv[0]} ]
set_property PACKAGE_PIN  AL3  [get_ports  {n_ff2_recv[1]} ]
set_property PACKAGE_PIN  AM1  [get_ports  {n_ff2_recv[2]} ]
set_property PACKAGE_PIN  AN3  [get_ports  {n_ff2_recv[3]} ]
set_property PACKAGE_PIN  AK2  [get_ports  {p_ff2_recv[0]} ]
set_property PACKAGE_PIN  AL4  [get_ports  {p_ff2_recv[1]} ]
set_property PACKAGE_PIN  AM2  [get_ports  {p_ff2_recv[2]} ]
set_property PACKAGE_PIN  AN4  [get_ports  {p_ff2_recv[3]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#2 transmitters
set_property PACKAGE_PIN  AK6  [get_ports  {n_ff2_xmit[0]} ]
set_property PACKAGE_PIN  AL8  [get_ports  {n_ff2_xmit[1]} ]
set_property PACKAGE_PIN  AM6  [get_ports  {n_ff2_xmit[2]} ]
set_property PACKAGE_PIN  AN8  [get_ports  {n_ff2_xmit[3]} ]
set_property PACKAGE_PIN  AK7  [get_ports  {p_ff2_xmit[0]} ]
set_property PACKAGE_PIN  AL9  [get_ports  {p_ff2_xmit[1]} ]
set_property PACKAGE_PIN  AM7  [get_ports  {p_ff2_xmit[2]} ]
set_property PACKAGE_PIN  AN9  [get_ports  {p_ff2_xmit[3]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#3 receivers
set_property PACKAGE_PIN  AF1  [get_ports  {n_ff3_recv[0]} ]
set_property PACKAGE_PIN  AG3  [get_ports  {n_ff3_recv[1]} ]
set_property PACKAGE_PIN  AH1  [get_ports  {n_ff3_recv[2]} ]
set_property PACKAGE_PIN  AJ3  [get_ports  {n_ff3_recv[3]} ]
set_property PACKAGE_PIN  AF2  [get_ports  {p_ff3_recv[0]} ]
set_property PACKAGE_PIN  AG4  [get_ports  {p_ff3_recv[1]} ]
set_property PACKAGE_PIN  AH2  [get_ports  {p_ff3_recv[2]} ]
set_property PACKAGE_PIN  AJ4  [get_ports  {p_ff3_recv[3]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#3 transmitters
set_property PACKAGE_PIN  AF6  [get_ports  {n_ff3_xmit[0]} ]
set_property PACKAGE_PIN  AG8  [get_ports  {n_ff3_xmit[1]} ]
set_property PACKAGE_PIN  AH6  [get_ports  {n_ff3_xmit[2]} ]
set_property PACKAGE_PIN  AJ8  [get_ports  {n_ff3_xmit[3]} ]
set_property PACKAGE_PIN  AF7  [get_ports  {p_ff3_xmit[0]} ]
set_property PACKAGE_PIN  AG9  [get_ports  {p_ff3_xmit[1]} ]
set_property PACKAGE_PIN  AH7  [get_ports  {p_ff3_xmit[2]} ]
set_property PACKAGE_PIN  AJ9  [get_ports  {p_ff3_xmit[3]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#4 receivers
set_property PACKAGE_PIN  AB1  [get_ports  {n_ff4_recv[0]} ]
set_property PACKAGE_PIN  AC3  [get_ports  {n_ff4_recv[1]} ]
set_property PACKAGE_PIN  AD1  [get_ports  {n_ff4_recv[2]} ]
set_property PACKAGE_PIN  AE3  [get_ports  {n_ff4_recv[3]} ]
set_property PACKAGE_PIN  AB2  [get_ports  {p_ff4_recv[0]} ]
set_property PACKAGE_PIN  AC4  [get_ports  {p_ff4_recv[1]} ]
set_property PACKAGE_PIN  AD2  [get_ports  {p_ff4_recv[2]} ]
set_property PACKAGE_PIN  AE4  [get_ports  {p_ff4_recv[3]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#4 transmitters
set_property PACKAGE_PIN  AB6  [get_ports  {n_ff4_xmit[0]} ]
set_property PACKAGE_PIN  AC8  [get_ports  {n_ff4_xmit[1]} ]
set_property PACKAGE_PIN  AD6  [get_ports  {n_ff4_xmit[2]} ]
set_property PACKAGE_PIN  AE8  [get_ports  {n_ff4_xmit[3]} ]
set_property PACKAGE_PIN  AB7  [get_ports  {p_ff4_xmit[0]} ]
set_property PACKAGE_PIN  AC9  [get_ports  {p_ff4_xmit[1]} ]
set_property PACKAGE_PIN  AD7  [get_ports  {p_ff4_xmit[2]} ]
set_property PACKAGE_PIN  AE9  [get_ports  {p_ff4_xmit[3]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#5 receivers
set_property PACKAGE_PIN  V1   [get_ports  {n_ff5_recv[0]} ]
set_property PACKAGE_PIN  W3   [get_ports  {n_ff5_recv[1]} ]
set_property PACKAGE_PIN  Y1   [get_ports  {n_ff5_recv[2]} ]
set_property PACKAGE_PIN  AA3  [get_ports  {n_ff5_recv[3]} ]
set_property PACKAGE_PIN  V2   [get_ports  {p_ff5_recv[0]} ]
set_property PACKAGE_PIN  W4   [get_ports  {p_ff5_recv[1]} ]
set_property PACKAGE_PIN  Y2   [get_ports  {p_ff5_recv[2]} ]
set_property PACKAGE_PIN  AA4  [get_ports  {p_ff5_recv[3]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#5 transmitters
set_property PACKAGE_PIN  V6   [get_ports  {n_ff5_xmit[0]} ]
set_property PACKAGE_PIN  W8   [get_ports  {n_ff5_xmit[1]} ]
set_property PACKAGE_PIN  Y6   [get_ports  {n_ff5_xmit[2]} ]
set_property PACKAGE_PIN  AA8  [get_ports  {n_ff5_xmit[3]} ]
set_property PACKAGE_PIN  V7   [get_ports  {p_ff5_xmit[0]} ]
set_property PACKAGE_PIN  W9   [get_ports  {p_ff5_xmit[1]} ]
set_property PACKAGE_PIN  Y7   [get_ports  {p_ff5_xmit[2]} ]
set_property PACKAGE_PIN  AA9  [get_ports  {p_ff5_xmit[3]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#6 receivers
set_property PACKAGE_PIN  P1   [get_ports  {n_ff6_recv[0]} ]
set_property PACKAGE_PIN  R3   [get_ports  {n_ff6_recv[1]} ]
set_property PACKAGE_PIN  T1   [get_ports  {n_ff6_recv[2]} ]
set_property PACKAGE_PIN  U3   [get_ports  {n_ff6_recv[3]} ]
set_property PACKAGE_PIN  P2   [get_ports  {p_ff6_recv[0]} ]
set_property PACKAGE_PIN  R4   [get_ports  {p_ff6_recv[1]} ]
set_property PACKAGE_PIN  T2   [get_ports  {p_ff6_recv[2]} ]
set_property PACKAGE_PIN  U4   [get_ports  {p_ff6_recv[3]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#6 transmitters
set_property PACKAGE_PIN  P6   [get_ports  {n_ff6_xmit[0]} ]
set_property PACKAGE_PIN  R8   [get_ports  {n_ff6_xmit[1]} ]
set_property PACKAGE_PIN  T6   [get_ports  {n_ff6_xmit[2]} ]
set_property PACKAGE_PIN  U8   [get_ports  {n_ff6_xmit[3]} ]
set_property PACKAGE_PIN  P7   [get_ports  {p_ff6_xmit[0]} ]
set_property PACKAGE_PIN  R9   [get_ports  {p_ff6_xmit[1]} ]
set_property PACKAGE_PIN  T7   [get_ports  {p_ff6_xmit[2]} ]
set_property PACKAGE_PIN  U9   [get_ports  {p_ff6_xmit[3]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#7 receivers
set_property PACKAGE_PIN  AU46 [get_ports  {n_ff7_recv[0]} ]
set_property PACKAGE_PIN  AT44 [get_ports  {n_ff7_recv[1]} ]
set_property PACKAGE_PIN  AR46 [get_ports  {n_ff7_recv[2]} ]
set_property PACKAGE_PIN  AP44 [get_ports  {n_ff7_recv[3]} ]
set_property PACKAGE_PIN  AU45 [get_ports  {p_ff7_recv[0]} ]
set_property PACKAGE_PIN  AT43 [get_ports  {p_ff7_recv[1]} ]
set_property PACKAGE_PIN  AR45 [get_ports  {p_ff7_recv[2]} ]
set_property PACKAGE_PIN  AP43 [get_ports  {p_ff7_recv[3]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#7 transmitters
set_property PACKAGE_PIN  AU41 [get_ports  {n_ff7_xmit[0]} ]
set_property PACKAGE_PIN  AT39 [get_ports  {n_ff7_xmit[1]} ]
set_property PACKAGE_PIN  AR41 [get_ports  {n_ff7_xmit[2]} ]
set_property PACKAGE_PIN  AP39 [get_ports  {n_ff7_xmit[3]} ]
set_property PACKAGE_PIN  AU40 [get_ports  {p_ff7_xmit[0]} ]
set_property PACKAGE_PIN  AT38 [get_ports  {p_ff7_xmit[1]} ]
set_property PACKAGE_PIN  AR40 [get_ports  {p_ff7_xmit[2]} ]
set_property PACKAGE_PIN  AP38 [get_ports  {p_ff7_xmit[3]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#8 receivers
set_property PACKAGE_PIN  AN46 [get_ports  {n_ff8_recv[0]} ]
set_property PACKAGE_PIN  AM44 [get_ports  {n_ff8_recv[1]} ]
set_property PACKAGE_PIN  AL46 [get_ports  {n_ff8_recv[2]} ]
set_property PACKAGE_PIN  AK44 [get_ports  {n_ff8_recv[3]} ]
set_property PACKAGE_PIN  AN45 [get_ports  {p_ff8_recv[0]} ]
set_property PACKAGE_PIN  AM43 [get_ports  {p_ff8_recv[1]} ]
set_property PACKAGE_PIN  AL45 [get_ports  {p_ff8_recv[2]} ]
set_property PACKAGE_PIN  AK43 [get_ports  {p_ff8_recv[3]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#8 transmitters
set_property PACKAGE_PIN  AN41 [get_ports  {n_ff8_xmit[0]} ]
set_property PACKAGE_PIN  AM39 [get_ports  {n_ff8_xmit[1]} ]
set_property PACKAGE_PIN  AL41 [get_ports  {n_ff8_xmit[2]} ]
set_property PACKAGE_PIN  AK39 [get_ports  {n_ff8_xmit[3]} ]
set_property PACKAGE_PIN  AN40 [get_ports  {p_ff8_xmit[0]} ]
set_property PACKAGE_PIN  AM38 [get_ports  {p_ff8_xmit[1]} ]
set_property PACKAGE_PIN  AL40 [get_ports  {p_ff8_xmit[2]} ]
set_property PACKAGE_PIN  AK38 [get_ports  {p_ff8_xmit[3]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#9 receivers
set_property PACKAGE_PIN  AJ46 [get_ports  {n_ff9_recv[0]} ]
set_property PACKAGE_PIN  AH44 [get_ports  {n_ff9_recv[1]} ]
set_property PACKAGE_PIN  AG46 [get_ports  {n_ff9_recv[2]} ]
set_property PACKAGE_PIN  AF44 [get_ports  {n_ff9_recv[3]} ]
set_property PACKAGE_PIN  AJ45 [get_ports  {p_ff9_recv[0]} ]
set_property PACKAGE_PIN  AH43 [get_ports  {p_ff9_recv[1]} ]
set_property PACKAGE_PIN  AG45 [get_ports  {p_ff9_recv[2]} ]
set_property PACKAGE_PIN  AF43 [get_ports  {p_ff9_recv[3]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#9 transmitters
set_property PACKAGE_PIN  AJ41 [get_ports  {n_ff9_xmit[0]} ]
set_property PACKAGE_PIN  AH39 [get_ports  {n_ff9_xmit[1]} ]
set_property PACKAGE_PIN  AG41 [get_ports  {n_ff9_xmit[2]} ]
set_property PACKAGE_PIN  AF39 [get_ports  {n_ff9_xmit[3]} ]
set_property PACKAGE_PIN  AJ40 [get_ports  {p_ff9_xmit[0]} ]
set_property PACKAGE_PIN  AH38 [get_ports  {p_ff9_xmit[1]} ]
set_property PACKAGE_PIN  AG40 [get_ports  {p_ff9_xmit[2]} ]
set_property PACKAGE_PIN  AF38 [get_ports  {p_ff9_xmit[3]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#10 receivers
set_property PACKAGE_PIN  AA46 [get_ports  {n_ff10_recv[0]} ]
set_property PACKAGE_PIN  Y44  [get_ports  {n_ff10_recv[1]} ]
set_property PACKAGE_PIN  W46  [get_ports  {n_ff10_recv[2]} ]
set_property PACKAGE_PIN  V44  [get_ports  {n_ff10_recv[3]} ]
set_property PACKAGE_PIN  AA45 [get_ports  {p_ff10_recv[0]} ]
set_property PACKAGE_PIN  Y43  [get_ports  {p_ff10_recv[1]} ]
set_property PACKAGE_PIN  W45  [get_ports  {p_ff10_recv[2]} ]
set_property PACKAGE_PIN  V43  [get_ports  {p_ff10_recv[3]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#10 transmitters
set_property PACKAGE_PIN  AA41 [get_ports  {n_ff10_xmit[0]} ]
set_property PACKAGE_PIN  Y39  [get_ports  {n_ff10_xmit[1]} ]
set_property PACKAGE_PIN  W41  [get_ports  {n_ff10_xmit[2]} ]
set_property PACKAGE_PIN  V39  [get_ports  {n_ff10_xmit[3]} ]
set_property PACKAGE_PIN  AA40 [get_ports  {p_ff10_xmit[0]} ]
set_property PACKAGE_PIN  Y38  [get_ports  {p_ff10_xmit[1]} ]
set_property PACKAGE_PIN  W40  [get_ports  {p_ff10_xmit[2]} ]
set_property PACKAGE_PIN  V38  [get_ports  {p_ff10_xmit[3]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#11 receivers
set_property PACKAGE_PIN  N3   [get_ports  {n_ff11_recv[0]} ]
set_property PACKAGE_PIN  M1   [get_ports  {n_ff11_recv[1]} ]
set_property PACKAGE_PIN  L3   [get_ports  {n_ff11_recv[2]} ]
set_property PACKAGE_PIN  K1   [get_ports  {n_ff11_recv[3]} ]
set_property PACKAGE_PIN  J3   [get_ports  {n_ff11_recv[4]} ]
set_property PACKAGE_PIN  H1   [get_ports  {n_ff11_recv[5]} ]
set_property PACKAGE_PIN  G3   [get_ports  {n_ff11_recv[6]} ]
set_property PACKAGE_PIN  F1   [get_ports  {n_ff11_recv[7]} ]
set_property PACKAGE_PIN  E3   [get_ports  {n_ff11_recv[8]} ]
set_property PACKAGE_PIN  D1   [get_ports  {n_ff11_recv[9]} ]
set_property PACKAGE_PIN  C3   [get_ports  {n_ff11_recv[10]} ]
set_property PACKAGE_PIN  A4   [get_ports  {n_ff11_recv[11]} ]
set_property PACKAGE_PIN  N4   [get_ports  {p_ff11_recv[0]} ]
set_property PACKAGE_PIN  M2   [get_ports  {p_ff11_recv[1]} ]
set_property PACKAGE_PIN  L4   [get_ports  {p_ff11_recv[2]} ]
set_property PACKAGE_PIN  K2   [get_ports  {p_ff11_recv[3]} ]
set_property PACKAGE_PIN  J4   [get_ports  {p_ff11_recv[4]} ]
set_property PACKAGE_PIN  H2   [get_ports  {p_ff11_recv[5]} ]
set_property PACKAGE_PIN  G4   [get_ports  {p_ff11_recv[6]} ]
set_property PACKAGE_PIN  F2   [get_ports  {p_ff11_recv[7]} ]
set_property PACKAGE_PIN  E4   [get_ports  {p_ff11_recv[8]} ]
set_property PACKAGE_PIN  D2   [get_ports  {p_ff11_recv[9]} ]
set_property PACKAGE_PIN  C4   [get_ports  {p_ff11_recv[10]} ]
set_property PACKAGE_PIN  A5   [get_ports  {p_ff11_recv[11]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#11 transmitters
set_property PACKAGE_PIN  N8   [get_ports  {n_ff11_xmit[0]} ]
set_property PACKAGE_PIN  M6   [get_ports  {n_ff11_xmit[1]} ]
set_property PACKAGE_PIN  L8   [get_ports  {n_ff11_xmit[2]} ]
set_property PACKAGE_PIN  K6   [get_ports  {n_ff11_xmit[3]} ]
set_property PACKAGE_PIN  J8   [get_ports  {n_ff11_xmit[4]} ]
set_property PACKAGE_PIN  H6   [get_ports  {n_ff11_xmit[5]} ]
set_property PACKAGE_PIN  G8   [get_ports  {n_ff11_xmit[6]} ]
set_property PACKAGE_PIN  F6   [get_ports  {n_ff11_xmit[7]} ]
set_property PACKAGE_PIN  E8   [get_ports  {n_ff11_xmit[8]} ]
set_property PACKAGE_PIN  D6   [get_ports  {n_ff11_xmit[9]} ]
set_property PACKAGE_PIN  C8   [get_ports  {n_ff11_xmit[10]} ]
set_property PACKAGE_PIN  A8   [get_ports  {n_ff11_xmit[11]} ]
set_property PACKAGE_PIN  N9   [get_ports  {p_ff11_xmit[0]} ]
set_property PACKAGE_PIN  M7   [get_ports  {p_ff11_xmit[1]} ]
set_property PACKAGE_PIN  L9   [get_ports  {p_ff11_xmit[2]} ]
set_property PACKAGE_PIN  K7   [get_ports  {p_ff11_xmit[3]} ]
set_property PACKAGE_PIN  J9   [get_ports  {p_ff11_xmit[4]} ]
set_property PACKAGE_PIN  H7   [get_ports  {p_ff11_xmit[5]} ]
set_property PACKAGE_PIN  G9   [get_ports  {p_ff11_xmit[6]} ]
set_property PACKAGE_PIN  F7   [get_ports  {p_ff11_xmit[7]} ]
set_property PACKAGE_PIN  E9   [get_ports  {p_ff11_xmit[8]} ]
set_property PACKAGE_PIN  D7   [get_ports  {p_ff11_xmit[9]} ]
set_property PACKAGE_PIN  C9   [get_ports  {p_ff11_xmit[10]} ]
set_property PACKAGE_PIN  A9   [get_ports  {p_ff11_xmit[11]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#12 receivers
set_property PACKAGE_PIN  D46  [get_ports  {n_ff12_recv[0]} ]
set_property PACKAGE_PIN  F46  [get_ports  {n_ff12_recv[1]} ]
set_property PACKAGE_PIN  H44  [get_ports  {n_ff12_recv[2]} ]
set_property PACKAGE_PIN  J46  [get_ports  {n_ff12_recv[3]} ]
set_property PACKAGE_PIN  K44  [get_ports  {n_ff12_recv[4]} ]
set_property PACKAGE_PIN  L46  [get_ports  {n_ff12_recv[5]} ]
set_property PACKAGE_PIN  M44  [get_ports  {n_ff12_recv[6]} ]
set_property PACKAGE_PIN  N46  [get_ports  {n_ff12_recv[7]} ]
set_property PACKAGE_PIN  P44  [get_ports  {n_ff12_recv[8]} ]
set_property PACKAGE_PIN  R46  [get_ports  {n_ff12_recv[9]} ]
set_property PACKAGE_PIN  T44  [get_ports  {n_ff12_recv[10]} ]
set_property PACKAGE_PIN  U46  [get_ports  {n_ff12_recv[11]} ]
set_property PACKAGE_PIN  D45  [get_ports  {p_ff12_recv[0]} ]
set_property PACKAGE_PIN  F45  [get_ports  {p_ff12_recv[1]} ]
set_property PACKAGE_PIN  H43  [get_ports  {p_ff12_recv[2]} ]
set_property PACKAGE_PIN  J45  [get_ports  {p_ff12_recv[3]} ]
set_property PACKAGE_PIN  K43  [get_ports  {p_ff12_recv[4]} ]
set_property PACKAGE_PIN  L45  [get_ports  {p_ff12_recv[5]} ]
set_property PACKAGE_PIN  M43  [get_ports  {p_ff12_recv[6]} ]
set_property PACKAGE_PIN  N45  [get_ports  {p_ff12_recv[7]} ]
set_property PACKAGE_PIN  P43  [get_ports  {p_ff12_recv[8]} ]
set_property PACKAGE_PIN  R45  [get_ports  {p_ff12_recv[9]} ]
set_property PACKAGE_PIN  T43  [get_ports  {p_ff12_recv[10]} ]
set_property PACKAGE_PIN  U45  [get_ports  {p_ff12_recv[11]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#12 transmitters
set_property PACKAGE_PIN  A43  [get_ports  {n_ff12_xmit0]} ]
set_property PACKAGE_PIN  C43  [get_ports  {n_ff12_xmit1]} ]
set_property PACKAGE_PIN  E43  [get_ports  {n_ff12_xmit2]} ]
set_property PACKAGE_PIN  G41  [get_ports  {n_ff12_xmit3]} ]
set_property PACKAGE_PIN  J41  [get_ports  {n_ff12_xmit4]} ]
set_property PACKAGE_PIN  L41  [get_ports  {n_ff12_xmit5]} ]
set_property PACKAGE_PIN  M39  [get_ports  {n_ff12_xmit6]} ]
set_property PACKAGE_PIN  N41  [get_ports  {n_ff12_xmit7]} ]
set_property PACKAGE_PIN  P39  [get_ports  {n_ff12_xmit8]} ]
set_property PACKAGE_PIN  R41  [get_ports  {n_ff12_xmit9]} ]
set_property PACKAGE_PIN  T39  [get_ports  {n_ff12_xmit10]} ]
set_property PACKAGE_PIN  U41  [get_ports  {n_ff12_xmit11]} ]
set_property PACKAGE_PIN  A42  [get_ports  {p_ff12_xmit0]} ]
set_property PACKAGE_PIN  C42  [get_ports  {p_ff12_xmit1]} ]
set_property PACKAGE_PIN  E42  [get_ports  {p_ff12_xmit2]} ]
set_property PACKAGE_PIN  G40  [get_ports  {p_ff12_xmit3]} ]
set_property PACKAGE_PIN  J40  [get_ports  {p_ff12_xmit4]} ]
set_property PACKAGE_PIN  L40  [get_ports  {p_ff12_xmit5]} ]
set_property PACKAGE_PIN  M38  [get_ports  {p_ff12_xmit6]} ]
set_property PACKAGE_PIN  N40  [get_ports  {p_ff12_xmit7]} ]
set_property PACKAGE_PIN  P38  [get_ports  {p_ff12_xmit8]} ]
set_property PACKAGE_PIN  R40  [get_ports  {p_ff12_xmit9]} ]
set_property PACKAGE_PIN  T38  [get_ports  {p_ff12_xmit10]} ]
set_property PACKAGE_PIN  U40  [get_ports  {p_ff12_xmit11]} ]
#-----------------------------------------------

#-----------------------------------------------
# test connector on bottom of board
set_property IOSTANDARD LVDS [get_ports *_test_conn*]
set_property PACKAGE_PIN  B26  [get_ports  {n_test_conn[0]} ]
set_property PACKAGE_PIN  A25  [get_ports  {n_test_conn[1]} ]
set_property PACKAGE_PIN  A24  [get_ports  {n_test_conn[2]} ]
set_property PACKAGE_PIN  A22  [get_ports  {n_test_conn[3]} ]
set_property PACKAGE_PIN  B22  [get_ports  {n_test_conn[4]} ]
set_property PACKAGE_PIN  F23  [get_ports  {n_test_conn[5]} ]
set_property PACKAGE_PIN  C26  [get_ports  {p_test_conn[0]} ]
set_property PACKAGE_PIN  B25  [get_ports  {p_test_conn[1]} ]
set_property PACKAGE_PIN  B24  [get_ports  {p_test_conn[2]} ]
set_property PACKAGE_PIN  A23  [get_ports  {p_test_conn[3]} ]
set_property PACKAGE_PIN  C22  [get_ports  {p_test_conn[4]} ]
set_property PACKAGE_PIN  F24  [get_ports  {p_test_conn[5]} ]
#-----------------------------------------------

#-----------------------------------------------
# Pins AT24 and BC19 are fanned out to vias, but then go nowhere.
# They could be used in an emergency as I/Os
#set_property PACKAGE_PIN  BC19 [get_ports  _d_18d451f8 ]
#set_property PACKAGE_PIN  AT24 [get_ports  _d_18d94f08 ]
#-----------------------------------------------

