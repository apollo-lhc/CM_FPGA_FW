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
set_property INTERNAL_VREF 0.90 [get_iobanks 66]
set_property INTERNAL_VREF 0.90 [get_iobanks 67]
set_property INTERNAL_VREF 0.90 [get_iobanks 72]
#-------------------------------------------------

#-------------------------------------------------
# 200 MHz system clock on bank 72

# 'input' clk_200: 200 MHz clock (schematic name is  "ac_*k_util_clk_chan2")
set_property IOSTANDARD LVDS [get_ports *_clk_200]
set_property DIFF_TERM_ADV TERM_100 [get_ports *_clk_200]
set_property PACKAGE_PIN  G21 [get_ports  n_clk_200 ]
set_property PACKAGE_PIN  G22 [get_ports  p_clk_200 ]
#-------------------------------------------------

#-----------------------------------------------
# CMS clock and timing signals from the service blade
# These are connected to port #3 of GTH quad 224
# This quad can be clocked from:
#  a) 200 MHz 'utl_clk_chan0' (direct)
#  b) 312.5 MHz 'clk0_chan0' (from quad 226 which is 2 quads away)
#  c) programmable 'clk1_chan0' (from quad 226 which is 2 quads away)

# 'input' atca_ttc_in_*: (schematic name is "ac_*v_ttc_in")
set_property IOSTANDARD LVDS [get_ports *_atca_ttc_in]
set_property DIFF_TERM_ADV TERM_100 [get_ports *_atca_ttc_in]
set_property PACKAGE_PIN  AY1 [get_ports  n_atca_ttc_in ]
set_property PACKAGE_PIN  AY2 [get_ports  p_atca_ttc_in ]

# 'output' atca_tts_out_*: (schematic name is "bc_*v_tts_out")
set_property IOSTANDARD LVDS [get_ports *_atca_tts_out]
set_property PACKAGE_PIN  AU7 [get_ports  n_atca_tts_out ]
set_property PACKAGE_PIN  AU8 [get_ports  p_atca_tts_out ]
#-----------------------------------------------

#-----------------------------------------------
# Legacy clock and timing signals from the AMC13 front panel connector
# Jumpers need to be installed to connect these signals to this FPGA

# 'input' amc13_clk40_*: 40 MHz clock (schematic name is "ac_*k_ttc_clk40")
set_property IOSTANDARD LVDS [get_ports *_amc13_clk_40]
set_property DIFF_TERM TRUE [get_ports *_amc13_clk_40]
set_property DIFF_TERM_ADV TERM_100 [get_ports *_amc13_clk_40]
set_property PACKAGE_PIN  J23 [get_ports  n_amc13_clk_40 ]
set_property PACKAGE_PIN  K23 [get_ports  p_amc13_clk_40 ]

# 'input' amc13_cdr_data_*: recovered data (schematic name is "*k_cdr_data")
set_property IOSTANDARD LVDS [get_ports *_amc13_cdr_data]
set_property DIFF_TERM TRUE [get_ports *_amc13_cdr_data]
set_property DIFF_TERM_ADV TERM_100 [get_ports *_amc13_cdr_data]
set_property PACKAGE_PIN  G24 [get_ports  n_amc13_cdr_data ]
set_property PACKAGE_PIN  H24 [get_ports  p_amc13_cdr_data ]

# 'output' amc13_tts_out_*: status (schematic name is *k_tts_out)
set_property IOSTANDARD LVDS [get_ports *_amc13_tts_out]
set_property PACKAGE_PIN  F23 [get_ports  n_amc13_tts_out ]
set_property PACKAGE_PIN  G23 [get_ports  p_amc13_tts_out ]
#-----------------------------------------------

#-----------------------------------------------
# GTH/GTY transceiver clocks
# The prefixes "ac_nk" and "ac_pk" on the schematic change to
# suffixes "_n" and "_p" for the HDL code
# 'input' "util_clk" fixed oscillator source (200 MHz)
# 'input' "clk0" fixed oscillator source (312.5 MHz)
# 'input' "clk1" programmable source

# Quad A (224)
set_property PACKAGE_PIN  AL11 [get_ports  n_util_clk_chan0 ]
set_property PACKAGE_PIN  AL12 [get_ports  p_util_clk_chan0 ]

# Quad C (226)
set_property PACKAGE_PIN  AG11 [get_ports  n_clk0_chan0 ]
set_property PACKAGE_PIN  AG12 [get_ports  p_clk0_chan0 ]
set_property PACKAGE_PIN  AF9  [get_ports  n_clk1_chan0 ]
set_property PACKAGE_PIN  AF10 [get_ports  p_clk1_chan0 ]

# Quad F (229)
set_property PACKAGE_PIN  AA11 [get_ports  n_clk0_chan1 ]
set_property PACKAGE_PIN  AA12 [get_ports  p_clk0_chan1 ]
set_property PACKAGE_PIN  Y9   [get_ports  n_clk1_chan1 ]
set_property PACKAGE_PIN  Y10  [get_ports  p_clk1_chan1 ]

# Quad I (232)
set_property PACKAGE_PIN  R11  [get_ports  n_clk0_chan2 ]
set_property PACKAGE_PIN  R12  [get_ports  p_clk0_chan2 ]
set_property PACKAGE_PIN  P9   [get_ports  n_clk1_chan2 ]
set_property PACKAGE_PIN  P10  [get_ports  p_clk1_chan2 ]

# Quad M (128)
set_property PACKAGE_PIN  AD33 [get_ports  n_clk0_chan4 ]
set_property PACKAGE_PIN  AD32 [get_ports  p_clk0_chan4 ]
set_property PACKAGE_PIN  AC31 [get_ports  n_clk1_chan4 ]
set_property PACKAGE_PIN  AC30 [get_ports  p_clk1_chan4 ]

# Quad P (131)
set_property PACKAGE_PIN  V33  [get_ports  n_clk0_chan5 ]
set_property PACKAGE_PIN  V32  [get_ports  p_clk0_chan5 ]
set_property PACKAGE_PIN  U31  [get_ports  n_clk1_chan5 ]
set_property PACKAGE_PIN  U30  [get_ports  p_clk1_chan5 ]

# Quad R (133)
set_property PACKAGE_PIN  P33  [get_ports  n_clk0_chan6 ]
set_property PACKAGE_PIN  P32  [get_ports  p_clk0_chan6 ]
set_property PACKAGE_PIN  N31  [get_ports  n_clk1_chan6 ]
set_property PACKAGE_PIN  N30  [get_ports  p_clk1_chan6 ]

# Quad S (134)
set_property PACKAGE_PIN  M33  [get_ports  n_util_clk_chan1 ]
set_property PACKAGE_PIN  M32  [get_ports  p_util_clk_chan1 ]
#-----------------------------------------------

#-----------------------------------------------
# GTY chip-to-chip links to the VU7P
# These are labeled 'c2c' on the schematic, but 'mgt' in here
# 'input' "v2k": links from the VU7P
# 'output' "k2v": links to the VU7P

# Quad S (134)
set_property PACKAGE_PIN  D42  [get_ports  {n_mgt_v2k[0]} ]
set_property PACKAGE_PIN  D41  [get_ports  {p_mgt_v2k[0]} ]
set_property PACKAGE_PIN  C40  [get_ports  {n_mgt_v2k[1]} ]
set_property PACKAGE_PIN  C39  [get_ports  {p_mgt_v2k[1]} ]
set_property PACKAGE_PIN  B42  [get_ports  {n_mgt_v2k[2]} ]
set_property PACKAGE_PIN  B41  [get_ports  {p_mgt_v2k[2]} ]

set_property PACKAGE_PIN  K37  [get_ports  {n_mgt_k2v[0]} ]
set_property PACKAGE_PIN  K36  [get_ports  {p_mgt_k2v[0]} ]
set_property PACKAGE_PIN  K33  [get_ports  {n_mgt_k2v[1]} ]
set_property PACKAGE_PIN  K32  [get_ports  {p_mgt_k2v[1]} ]
set_property PACKAGE_PIN  J35  [get_ports  {n_mgt_k2v[2]} ]
set_property PACKAGE_PIN  J34  [get_ports  {p_mgt_k2v[2]} ]
#-----------------------------------------------

#-----------------------------------------------
# GTH PCIe or chip-to-chip links to the service board
# 'input' "z2k": links from the Zynq on the service board
# 'output' "k2z": links to the Zynq on the service board

# Quad A (224)
set_property PACKAGE_PIN  BA3  [get_ports  {n_mgt_z2k[1]} ]
set_property PACKAGE_PIN  BA4  [get_ports  {p_mgt_z2k[1]} ]
set_property PACKAGE_PIN  BB5  [get_ports  {n_mgt_z2k[2]} ]
set_property PACKAGE_PIN  BB6  [get_ports  {p_mgt_z2k[2]} ]

set_property PACKAGE_PIN  AV9  [get_ports  {n_mgt_k2z[1]} ]
set_property PACKAGE_PIN  AV10 [get_ports  {p_mgt_k2z[1]} ]
set_property PACKAGE_PIN  AW7  [get_ports  {n_mgt_k2z[2]} ]
set_property PACKAGE_PIN  AW8  [get_ports  {p_mgt_k2z[2]} ]
#-----------------------------------------------

#-----------------------------------------------
# other inputs and outputs

# 'input' "dip_sw": 2 bits from a DIP switch
set_property IOSTANDARD LVCMOS18 [get_ports dip_sw*]
set_property PACKAGE_PIN  AV32 [get_ports  {dip_sw[2]} ]
set_property PACKAGE_PIN  AU32 [get_ports  {dip_sw[3]} ]

# 'output' "led": 3 bits to light LEDs
set_property IOSTANDARD LVCMOS18 [get_ports led_*] 
set_property PACKAGE_PIN  BA29 [get_ports  led_blue ]
set_property PACKAGE_PIN  AY28 [get_ports  led_green ]
set_property PACKAGE_PIN  AW28 [get_ports  led_red ]

# 'input' "from_tm4c": 1 bit trom the TM4C
# 'output' "to_tm4c": 1 bit to the TM4C
set_property IOSTANDARD LVCMOS18 [get_ports *_tm4c] 
set_property PACKAGE_PIN  D22 [get_ports  from_tm4c ]
set_property PACKAGE_PIN  H22 [get_ports  to_tm4c ]

# WHAT TO DO ABOUT I2C PINS???
set_property IOSTANDARD LVCMOS18 [get_ports k_fpga_i2c_*] 
set_property PACKAGE_PIN  AL24 [get_ports  k_fpga_i2c_scl ]
set_property PACKAGE_PIN  AL25 [get_ports  k_fpga_i2c_sda ]
#-----------------------------------------------

#-----------------------------------------------
# spare pairs between the KU15P and VU7P
# These should be set up as inputs on both FPGAs until an actual
# use is determined
set_property IOSTANDARD LVDS [get_ports *_kv_spare*]
set_property PACKAGE_PIN  B22  [get_ports  {n_kv_spare[0]} ]
set_property PACKAGE_PIN  A23  [get_ports  {n_kv_spare[1]} ]
set_property PACKAGE_PIN  B24  [get_ports  {n_kv_spare[2]} ]
set_property PACKAGE_PIN  C21  [get_ports  {n_kv_spare[3]} ]
set_property PACKAGE_PIN  D23  [get_ports  {n_kv_spare[4]} ]
set_property PACKAGE_PIN  E21  [get_ports  {n_kv_spare[5]} ]
set_property PACKAGE_PIN  J22  [get_ports  {n_kv_spare[6]} ]
set_property PACKAGE_PIN  F20  [get_ports  {n_kv_spare[7]} ]
set_property PACKAGE_PIN  E23  [get_ports  {n_kv_spare[8]} ]
set_property PACKAGE_PIN  H20  [get_ports  {n_kv_spare[9]} ]
set_property PACKAGE_PIN  L23  [get_ports  {n_kv_spare[10]} ]
set_property PACKAGE_PIN  J20  [get_ports  {n_kv_spare[11]} ]
set_property PACKAGE_PIN  K21  [get_ports  {n_kv_spare[12]} ]
set_property PACKAGE_PIN  B23  [get_ports  {p_kv_spare[0]} ]
set_property PACKAGE_PIN  A24  [get_ports  {p_kv_spare[1]} ]
set_property PACKAGE_PIN  C24  [get_ports  {p_kv_spare[2]} ]
set_property PACKAGE_PIN  C22  [get_ports  {p_kv_spare[3]} ]
set_property PACKAGE_PIN  D24  [get_ports  {p_kv_spare[4]} ]
set_property PACKAGE_PIN  E22  [get_ports  {p_kv_spare[5]} ]
set_property PACKAGE_PIN  K22  [get_ports  {p_kv_spare[6]} ]
set_property PACKAGE_PIN  F21  [get_ports  {p_kv_spare[7]} ]
set_property PACKAGE_PIN  F24  [get_ports  {p_kv_spare[8]} ]
set_property PACKAGE_PIN  H21  [get_ports  {p_kv_spare[9]} ]
set_property PACKAGE_PIN  L24  [get_ports  {p_kv_spare[10]} ]
set_property PACKAGE_PIN  K20  [get_ports  {p_kv_spare[11]} ]
set_property PACKAGE_PIN  L21  [get_ports  {p_kv_spare[12]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#1 receivers
set_property PACKAGE_PIN  R3   [get_ports  {n_ff1_recv[0]} ]
set_property PACKAGE_PIN  P1   [get_ports  {n_ff1_recv[1]} ]
set_property PACKAGE_PIN  N3   [get_ports  {n_ff1_recv[2]} ]
set_property PACKAGE_PIN  M1   [get_ports  {n_ff1_recv[3]} ]
set_property PACKAGE_PIN  L3   [get_ports  {n_ff1_recv[4]} ]
set_property PACKAGE_PIN  K1   [get_ports  {n_ff1_recv[5]} ]
set_property PACKAGE_PIN  J3   [get_ports  {n_ff1_recv[6]} ]
set_property PACKAGE_PIN  H1   [get_ports  {n_ff1_recv[7]} ]
set_property PACKAGE_PIN  G3   [get_ports  {n_ff1_recv[8]} ]
set_property PACKAGE_PIN  F1   [get_ports  {n_ff1_recv[9]} ]
set_property PACKAGE_PIN  E3   [get_ports  {n_ff1_recv[10]} ]
set_property PACKAGE_PIN  D1   [get_ports  {n_ff1_recv[11]} ]
set_property PACKAGE_PIN  R4   [get_ports  {p_ff1_recv[0]} ]
set_property PACKAGE_PIN  P2   [get_ports  {p_ff1_recv[1]} ]
set_property PACKAGE_PIN  N4   [get_ports  {p_ff1_recv[2]} ]
set_property PACKAGE_PIN  M2   [get_ports  {p_ff1_recv[3]} ]
set_property PACKAGE_PIN  L4   [get_ports  {p_ff1_recv[4]} ]
set_property PACKAGE_PIN  K2   [get_ports  {p_ff1_recv[5]} ]
set_property PACKAGE_PIN  J4   [get_ports  {p_ff1_recv[6]} ]
set_property PACKAGE_PIN  H2   [get_ports  {p_ff1_recv[7]} ]
set_property PACKAGE_PIN  G4   [get_ports  {p_ff1_recv[8]} ]
set_property PACKAGE_PIN  F2   [get_ports  {p_ff1_recv[9]} ]
set_property PACKAGE_PIN  E4   [get_ports  {p_ff1_recv[10]} ]
set_property PACKAGE_PIN  D2   [get_ports  {p_ff1_recv[11]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#1 transmitters
set_property PACKAGE_PIN  R7   [get_ports  {n_ff1_xmit[0]} ]
set_property PACKAGE_PIN  P5   [get_ports  {n_ff1_xmit[1]} ]
set_property PACKAGE_PIN  N7   [get_ports  {n_ff1_xmit[2]} ]
set_property PACKAGE_PIN  M5   [get_ports  {n_ff1_xmit[3]} ]
set_property PACKAGE_PIN  L7   [get_ports  {n_ff1_xmit[4]} ]
set_property PACKAGE_PIN  K5   [get_ports  {n_ff1_xmit[5]} ]
set_property PACKAGE_PIN  J7   [get_ports  {n_ff1_xmit[6]} ]
set_property PACKAGE_PIN  H5   [get_ports  {n_ff1_xmit[7]} ]
set_property PACKAGE_PIN  H9   [get_ports  {n_ff1_xmit[8]} ]
set_property PACKAGE_PIN  G7   [get_ports  {n_ff1_xmit[9]} ]
set_property PACKAGE_PIN  F5   [get_ports  {n_ff1_xmit[10]} ]
set_property PACKAGE_PIN  F9   [get_ports  {n_ff1_xmit[11]} ]
set_property PACKAGE_PIN  R8   [get_ports  {p_ff1_xmit[0]} ]
set_property PACKAGE_PIN  P6   [get_ports  {p_ff1_xmit[1]} ]
set_property PACKAGE_PIN  N8   [get_ports  {p_ff1_xmit[2]} ]
set_property PACKAGE_PIN  M6   [get_ports  {p_ff1_xmit[3]} ]
set_property PACKAGE_PIN  L8   [get_ports  {p_ff1_xmit[4]} ]
set_property PACKAGE_PIN  K6   [get_ports  {p_ff1_xmit[5]} ]
set_property PACKAGE_PIN  J8   [get_ports  {p_ff1_xmit[6]} ]
set_property PACKAGE_PIN  H6   [get_ports  {p_ff1_xmit[7]} ]
set_property PACKAGE_PIN  H10  [get_ports  {p_ff1_xmit[8]} ]
set_property PACKAGE_PIN  G8   [get_ports  {p_ff1_xmit[9]} ]
set_property PACKAGE_PIN  F6   [get_ports  {p_ff1_xmit[10]} ]
set_property PACKAGE_PIN  F10  [get_ports  {p_ff1_xmit[11]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#2 receivers
set_property PACKAGE_PIN  AG3  [get_ports  {n_ff2_recv[0]} ]
set_property PACKAGE_PIN  AF1  [get_ports  {n_ff2_recv[1]} ]
set_property PACKAGE_PIN  AE3  [get_ports  {n_ff2_recv[2]} ]
set_property PACKAGE_PIN  AD1  [get_ports  {n_ff2_recv[3]} ]
set_property PACKAGE_PIN  AC3  [get_ports  {n_ff2_recv[4]} ]
set_property PACKAGE_PIN  AB1  [get_ports  {n_ff2_recv[5]} ]
set_property PACKAGE_PIN  AA3  [get_ports  {n_ff2_recv[6]} ]
set_property PACKAGE_PIN  Y1   [get_ports  {n_ff2_recv[7]} ]
set_property PACKAGE_PIN  W3   [get_ports  {n_ff2_recv[8]} ]
set_property PACKAGE_PIN  V1   [get_ports  {n_ff2_recv[9]} ]
set_property PACKAGE_PIN  U3   [get_ports  {n_ff2_recv[10]} ]
set_property PACKAGE_PIN  T1   [get_ports  {n_ff2_recv[11]} ]
set_property PACKAGE_PIN  AG4  [get_ports  {p_ff2_recv[0]} ]
set_property PACKAGE_PIN  AF2  [get_ports  {p_ff2_recv[1]} ]
set_property PACKAGE_PIN  AE4  [get_ports  {p_ff2_recv[2]} ]
set_property PACKAGE_PIN  AD2  [get_ports  {p_ff2_recv[3]} ]
set_property PACKAGE_PIN  AC4  [get_ports  {p_ff2_recv[4]} ]
set_property PACKAGE_PIN  AB2  [get_ports  {p_ff2_recv[5]} ]
set_property PACKAGE_PIN  AA4  [get_ports  {p_ff2_recv[6]} ]
set_property PACKAGE_PIN  Y2   [get_ports  {p_ff2_recv[7]} ]
set_property PACKAGE_PIN  W4   [get_ports  {p_ff2_recv[8]} ]
set_property PACKAGE_PIN  V2   [get_ports  {p_ff2_recv[9]} ]
set_property PACKAGE_PIN  U4   [get_ports  {p_ff2_recv[10]} ]
set_property PACKAGE_PIN  T2   [get_ports  {p_ff2_recv[11]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#2 transmitters
set_property PACKAGE_PIN  AG7  [get_ports  {n_ff2_xmit[0]} ]
set_property PACKAGE_PIN  AF5  [get_ports  {n_ff2_xmit[1]} ]
set_property PACKAGE_PIN  AE7  [get_ports  {n_ff2_xmit[2]} ]
set_property PACKAGE_PIN  AD5  [get_ports  {n_ff2_xmit[3]} ]
set_property PACKAGE_PIN  AC7  [get_ports  {n_ff2_xmit[4]} ]
set_property PACKAGE_PIN  AB5  [get_ports  {n_ff2_xmit[5]} ]
set_property PACKAGE_PIN  AA7  [get_ports  {n_ff2_xmit[6]} ]
set_property PACKAGE_PIN  Y5   [get_ports  {n_ff2_xmit[7]} ]
set_property PACKAGE_PIN  W7   [get_ports  {n_ff2_xmit[8]} ]
set_property PACKAGE_PIN  V5   [get_ports  {n_ff2_xmit[9]} ]
set_property PACKAGE_PIN  U7   [get_ports  {n_ff2_xmit[10]} ]
set_property PACKAGE_PIN  T5   [get_ports  {n_ff2_xmit[11]} ]
set_property PACKAGE_PIN  AG8  [get_ports  {p_ff2_xmit[0]} ]
set_property PACKAGE_PIN  AF6  [get_ports  {p_ff2_xmit[1]} ]
set_property PACKAGE_PIN  AE8  [get_ports  {p_ff2_xmit[2]} ]
set_property PACKAGE_PIN  AD6  [get_ports  {p_ff2_xmit[3]} ]
set_property PACKAGE_PIN  AC8  [get_ports  {p_ff2_xmit[4]} ]
set_property PACKAGE_PIN  AB6  [get_ports  {p_ff2_xmit[5]} ]
set_property PACKAGE_PIN  AA8  [get_ports  {p_ff2_xmit[6]} ]
set_property PACKAGE_PIN  Y6   [get_ports  {p_ff2_xmit[7]} ]
set_property PACKAGE_PIN  W8   [get_ports  {p_ff2_xmit[8]} ]
set_property PACKAGE_PIN  V6   [get_ports  {p_ff2_xmit[9]} ]
set_property PACKAGE_PIN  U8   [get_ports  {p_ff2_xmit[10]} ]
set_property PACKAGE_PIN  T6   [get_ports  {p_ff2_xmit[11]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#3 receivers
set_property PACKAGE_PIN  AW3  [get_ports  {n_ff3_recv[0]} ]
set_property PACKAGE_PIN  AV1  [get_ports  {n_ff3_recv[1]} ]
set_property PACKAGE_PIN  AU3  [get_ports  {n_ff3_recv[2]} ]
set_property PACKAGE_PIN  AT1  [get_ports  {n_ff3_recv[3]} ]
set_property PACKAGE_PIN  AR3  [get_ports  {n_ff3_recv[4]} ]
set_property PACKAGE_PIN  AP1  [get_ports  {n_ff3_recv[5]} ]
set_property PACKAGE_PIN  AN3  [get_ports  {n_ff3_recv[6]} ]
set_property PACKAGE_PIN  AM1  [get_ports  {n_ff3_recv[7]} ]
set_property PACKAGE_PIN  AL3  [get_ports  {n_ff3_recv[8]} ]
set_property PACKAGE_PIN  AK1  [get_ports  {n_ff3_recv[9]} ]
set_property PACKAGE_PIN  AJ3  [get_ports  {n_ff3_recv[10]} ]
set_property PACKAGE_PIN  AH1  [get_ports  {n_ff3_recv[11]} ]
set_property PACKAGE_PIN  AW4  [get_ports  {p_ff3_recv[0]} ]
set_property PACKAGE_PIN  AV2  [get_ports  {p_ff3_recv[1]} ]
set_property PACKAGE_PIN  AU4  [get_ports  {p_ff3_recv[2]} ]
set_property PACKAGE_PIN  AT2  [get_ports  {p_ff3_recv[3]} ]
set_property PACKAGE_PIN  AR4  [get_ports  {p_ff3_recv[4]} ]
set_property PACKAGE_PIN  AP2  [get_ports  {p_ff3_recv[5]} ]
set_property PACKAGE_PIN  AN4  [get_ports  {p_ff3_recv[6]} ]
set_property PACKAGE_PIN  AM2  [get_ports  {p_ff3_recv[7]} ]
set_property PACKAGE_PIN  AL4  [get_ports  {p_ff3_recv[8]} ]
set_property PACKAGE_PIN  AK2  [get_ports  {p_ff3_recv[9]} ]
set_property PACKAGE_PIN  AJ4  [get_ports  {p_ff3_recv[10]} ]
set_property PACKAGE_PIN  AH2  [get_ports  {p_ff3_recv[11]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#3 transmitters
set_property PACKAGE_PIN  AT9  [get_ports  {n_ff3_xmit[0]} ]
set_property PACKAGE_PIN  AT5  [get_ports  {n_ff3_xmit[1]} ]
set_property PACKAGE_PIN  AR7  [get_ports  {n_ff3_xmit[2]} ]
set_property PACKAGE_PIN  AP9  [get_ports  {n_ff3_xmit[3]} ]
set_property PACKAGE_PIN  AP5  [get_ports  {n_ff3_xmit[4]} ]
set_property PACKAGE_PIN  AN7  [get_ports  {n_ff3_xmit[5]} ]
set_property PACKAGE_PIN  AM9  [get_ports  {n_ff3_xmit[6]} ]
set_property PACKAGE_PIN  AM5  [get_ports  {n_ff3_xmit[7]} ]
set_property PACKAGE_PIN  AL7  [get_ports  {n_ff3_xmit[8]} ]
set_property PACKAGE_PIN  AK5  [get_ports  {n_ff3_xmit[9]} ]
set_property PACKAGE_PIN  AJ7  [get_ports  {n_ff3_xmit[10]} ]
set_property PACKAGE_PIN  AH5  [get_ports  {n_ff3_xmit[11]} ]
set_property PACKAGE_PIN  AT10 [get_ports  {p_ff3_xmit[0]} ]
set_property PACKAGE_PIN  AT6  [get_ports  {p_ff3_xmit[1]} ]
set_property PACKAGE_PIN  AR8  [get_ports  {p_ff3_xmit[2]} ]
set_property PACKAGE_PIN  AP10 [get_ports  {p_ff3_xmit[3]} ]
set_property PACKAGE_PIN  AP6  [get_ports  {p_ff3_xmit[4]} ]
set_property PACKAGE_PIN  AN8  [get_ports  {p_ff3_xmit[5]} ]
set_property PACKAGE_PIN  AM10 [get_ports  {p_ff3_xmit[6]} ]
set_property PACKAGE_PIN  AM6  [get_ports  {p_ff3_xmit[7]} ]
set_property PACKAGE_PIN  AL8  [get_ports  {p_ff3_xmit[8]} ]
set_property PACKAGE_PIN  AK6  [get_ports  {p_ff3_xmit[9]} ]
set_property PACKAGE_PIN  AJ8  [get_ports  {p_ff3_xmit[10]} ]
set_property PACKAGE_PIN  AH6  [get_ports  {p_ff3_xmit[11]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#4 receivers
set_property PACKAGE_PIN  H42  [get_ports  {n_ff4_recv[0]} ]
set_property PACKAGE_PIN  G40  [get_ports  {n_ff4_recv[1]} ]
set_property PACKAGE_PIN  F42  [get_ports  {n_ff4_recv[2]} ]
set_property PACKAGE_PIN  E40  [get_ports  {n_ff4_recv[3]} ]
set_property PACKAGE_PIN  H41  [get_ports  {p_ff4_recv[0]} ]
set_property PACKAGE_PIN  G39  [get_ports  {p_ff4_recv[1]} ]
set_property PACKAGE_PIN  F41  [get_ports  {p_ff4_recv[2]} ]
set_property PACKAGE_PIN  E39  [get_ports  {p_ff4_recv[3]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#4 transmitters
set_property PACKAGE_PIN  P37  [get_ports  {n_ff4_xmit[0]} ]
set_property PACKAGE_PIN  N35  [get_ports  {n_ff4_xmit[1]} ]
set_property PACKAGE_PIN  M37  [get_ports  {n_ff4_xmit[2]} ]
set_property PACKAGE_PIN  L35  [get_ports  {n_ff4_xmit[3]} ]
set_property PACKAGE_PIN  P36  [get_ports  {p_ff4_xmit[0]} ]
set_property PACKAGE_PIN  N34  [get_ports  {p_ff4_xmit[1]} ]
set_property PACKAGE_PIN  M36  [get_ports  {p_ff4_xmit[2]} ]
set_property PACKAGE_PIN  L34  [get_ports  {p_ff4_xmit[3]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#5 receivers
set_property PACKAGE_PIN  M42  [get_ports  {n_ff5_recv[0]} ]
set_property PACKAGE_PIN  L40  [get_ports  {n_ff5_recv[1]} ]
set_property PACKAGE_PIN  K42  [get_ports  {n_ff5_recv[2]} ]
set_property PACKAGE_PIN  J40  [get_ports  {n_ff5_recv[3]} ]
set_property PACKAGE_PIN  M41  [get_ports  {p_ff5_recv[0]} ]
set_property PACKAGE_PIN  L39  [get_ports  {p_ff5_recv[1]} ]
set_property PACKAGE_PIN  K41  [get_ports  {p_ff5_recv[2]} ]
set_property PACKAGE_PIN  J39  [get_ports  {p_ff5_recv[3]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#5 transmitters
set_property PACKAGE_PIN  U35  [get_ports  nk_ff5_xmit0 ]
set_property PACKAGE_PIN  T37  [get_ports  {n_ff5_xmit[1]} ]
set_property PACKAGE_PIN  R39  [get_ports  {n_ff5_xmit[2]} ]
set_property PACKAGE_PIN  R35  [get_ports  {n_ff5_xmit[3]} ]
set_property PACKAGE_PIN  U34  [get_ports  {p_ff5_xmit[0]} ]
set_property PACKAGE_PIN  T36  [get_ports  {p_ff5_xmit[1]} ]
set_property PACKAGE_PIN  R38  [get_ports  {p_ff5_xmit[2]} ]
set_property PACKAGE_PIN  R34  [get_ports  {p_ff5_xmit[3]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#6 receivers
set_property PACKAGE_PIN  V42  [get_ports  {n_ff6_recv[0]} ]
set_property PACKAGE_PIN  T42  [get_ports  {n_ff6_recv[1]} ]
set_property PACKAGE_PIN  P42  [get_ports  {n_ff6_recv[2]} ]
set_property PACKAGE_PIN  N40  [get_ports  {n_ff6_recv[3]} ]
set_property PACKAGE_PIN  V41  [get_ports  {p_ff6_recv[0]} ]
set_property PACKAGE_PIN  T41  [get_ports  {p_ff6_recv[1]} ]
set_property PACKAGE_PIN  P41  [get_ports  {p_ff6_recv[2]} ]
set_property PACKAGE_PIN  N39  [get_ports  {p_ff6_recv[3]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#6 transmitters
set_property PACKAGE_PIN  W39  [get_ports  {n_ff6_xmit[0]} ]
set_property PACKAGE_PIN  W35  [get_ports  {n_ff6_xmit[1]} ]
set_property PACKAGE_PIN  V37  [get_ports  {n_ff6_xmit[2]} ]
set_property PACKAGE_PIN  U39  [get_ports  {n_ff6_xmit[3]} ]
set_property PACKAGE_PIN  W38  [get_ports  {p_ff6_xmit[0]} ]
set_property PACKAGE_PIN  W34  [get_ports  {p_ff6_xmit[1]} ]
set_property PACKAGE_PIN  V36  [get_ports  {p_ff6_xmit[2]} ]
set_property PACKAGE_PIN  U38  [get_ports  {p_ff6_xmit[3]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#7 receivers
set_property PACKAGE_PIN  AE40 [get_ports  {n_ff7_recv[0]} ]
set_property PACKAGE_PIN  AF42 [get_ports  {n_ff7_recv[1]} ]
set_property PACKAGE_PIN  AG40 [get_ports  {n_ff7_recv[2]} ]
set_property PACKAGE_PIN  AH42 [get_ports  {n_ff7_recv[3]} ]
set_property PACKAGE_PIN  AJ40 [get_ports  {n_ff7_recv[4]} ]
set_property PACKAGE_PIN  AK42 [get_ports  {n_ff7_recv[5]} ]
set_property PACKAGE_PIN  AL40 [get_ports  {n_ff7_recv[6]} ]
set_property PACKAGE_PIN  AM42 [get_ports  {n_ff7_recv[7]} ]
set_property PACKAGE_PIN  AN40 [get_ports  {n_ff7_recv[8]} ]
set_property PACKAGE_PIN  AP42 [get_ports  {n_ff7_recv[9]} ]
set_property PACKAGE_PIN  AR40 [get_ports  {n_ff7_recv[10]} ]
set_property PACKAGE_PIN  AT42 [get_ports  {n_ff7_recv[11]} ]
set_property PACKAGE_PIN  AE39 [get_ports  {p_ff7_recv[0]} ]
set_property PACKAGE_PIN  AF41 [get_ports  {p_ff7_recv[1]} ]
set_property PACKAGE_PIN  AG39 [get_ports  {p_ff7_recv[2]} ]
set_property PACKAGE_PIN  AH41 [get_ports  {p_ff7_recv[3]} ]
set_property PACKAGE_PIN  AJ39 [get_ports  {p_ff7_recv[4]} ]
set_property PACKAGE_PIN  AK41 [get_ports  {p_ff7_recv[5]} ]
set_property PACKAGE_PIN  AL39 [get_ports  {p_ff7_recv[6]} ]
set_property PACKAGE_PIN  AM41 [get_ports  {p_ff7_recv[7]} ]
set_property PACKAGE_PIN  AN39 [get_ports  {p_ff7_recv[8]} ]
set_property PACKAGE_PIN  AP41 [get_ports  {p_ff7_recv[9]} ]
set_property PACKAGE_PIN  AR39 [get_ports  {p_ff7_recv[10]} ]
set_property PACKAGE_PIN  AT41 [get_ports  {p_ff7_recv[11]} ]
#-----------------------------------------------

#-----------------------------------------------
# firefly#7 transmitters
set_property PACKAGE_PIN  AC35 [get_ports  {n_ff7_xmit[0]} ]
set_property PACKAGE_PIN  AD37 [get_ports  {n_ff7_xmit[1]} ]
set_property PACKAGE_PIN  AE35 [get_ports  {n_ff7_xmit[2]} ]
set_property PACKAGE_PIN  AF37 [get_ports  {n_ff7_xmit[3]} ]
set_property PACKAGE_PIN  AF33 [get_ports  {n_ff7_xmit[4]} ]
set_property PACKAGE_PIN  AG35 [get_ports  {n_ff7_xmit[5]} ]
set_property PACKAGE_PIN  AH37 [get_ports  {n_ff7_xmit[6]} ]
set_property PACKAGE_PIN  AH33 [get_ports  {n_ff7_xmit[7]} ]
set_property PACKAGE_PIN  AJ35 [get_ports  {n_ff7_xmit[8]} ]
set_property PACKAGE_PIN  AK37 [get_ports  {n_ff7_xmit[9]} ]
set_property PACKAGE_PIN  AL35 [get_ports  {n_ff7_xmit[10]} ]
set_property PACKAGE_PIN  AM37 [get_ports  {n_ff7_xmit[11]} ]
set_property PACKAGE_PIN  AC34 [get_ports  {p_ff7_xmit[0]} ]
set_property PACKAGE_PIN  AD36 [get_ports  {p_ff7_xmit[1]} ]
set_property PACKAGE_PIN  AE34 [get_ports  {p_ff7_xmit[2]} ]
set_property PACKAGE_PIN  AF36 [get_ports  {p_ff7_xmit[3]} ]
set_property PACKAGE_PIN  AF32 [get_ports  {p_ff7_xmit[4]} ]
set_property PACKAGE_PIN  AG34 [get_ports  {p_ff7_xmit[5]} ]
set_property PACKAGE_PIN  AH36 [get_ports  {p_ff7_xmit[6]} ]
set_property PACKAGE_PIN  AH32 [get_ports  {p_ff7_xmit[7]} ]
set_property PACKAGE_PIN  AJ34 [get_ports  {p_ff7_xmit[8]} ]
set_property PACKAGE_PIN  AK36 [get_ports  {p_ff7_xmit[9]} ]
set_property PACKAGE_PIN  AL34 [get_ports  {p_ff7_xmit[10]} ]
set_property PACKAGE_PIN  AM36 [get_ports  {p_ff7_xmit[11]} ]
#-----------------------------------------------

#-----------------------------------------------
# test connector on bottom of board
# These should be set up as inputs until an actual
# use is determined
set_property IOSTANDARD LVDS [get_ports *_test_conn*]
set_property PACKAGE_PIN  BB16 [get_ports  {n_test_conn[0]} ]
set_property PACKAGE_PIN  BB14 [get_ports  {n_test_conn[1]} ]
set_property PACKAGE_PIN  AY15 [get_ports  {n_test_conn[2]} ]
set_property PACKAGE_PIN  AV14 [get_ports  {n_test_conn[3]} ]
set_property PACKAGE_PIN  AR12 [get_ports  {n_test_conn[4]} ]
set_property PACKAGE_PIN  AP12 [get_ports  {n_test_conn[5]} ]
set_property PACKAGE_PIN  BB17 [get_ports  {p_test_conn[0]} ]
set_property PACKAGE_PIN  BA14 [get_ports  {p_test_conn[1]} ]
set_property PACKAGE_PIN  AY16 [get_ports  {p_test_conn[2]} ]
set_property PACKAGE_PIN  AU14 [get_ports  {p_test_conn[3]} ]
set_property PACKAGE_PIN  AR13 [get_ports  {p_test_conn[4]} ]
set_property PACKAGE_PIN  AP13 [get_ports  {p_test_conn[5]} ]
#-----------------------------------------------

#-----------------------------------------------
# Pins AP14 and AP15 are fanned out to vias, but then go nowhere.
# They could be used in an emergency as I/Os to bank 66
#set_property PACKAGE_PIN  AP15 [get_ports  _d_18df08e0 ]
#set_property PACKAGE_PIN  AP14 [get_ports  _d_18df15b0 ]
#-----------------------------------------------












