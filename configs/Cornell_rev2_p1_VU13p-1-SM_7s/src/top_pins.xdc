# pin constraint file for the Apollo 6089-119 board.
# VU13P (or VU9P) in A2577 package 
#
# This board has two A2577 FPGA sites. One is the "primary" site, and the other is the
# "secondary" site. This pin constraint file is usable for both sites. There are some wiring
# differences on the circuit board. Any differences will be noted.
#
# The schematic prefixes of 'f1_' or 'f2_ are dropped from names. They appear on the
# the schematics to differentiate signals, like 'f1_led_red' vs. 'f2_led_red'. In
# the Vivado code, they are just 'led_red' for either of the two FPGA sites.  
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
# Important! Do not remove this constraint!
# Refer to UG580 "SYSMON User Guide" for "Over Temperature Automatic Shutdown"
# shutdown on over-temperature
set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN ENABLE [current_design]
#-------------------------------------------------

#-------------------------------------------------
# Set internal reference voltages to 0.90 on banks with I/O signals.
# This is required for the HSTL and DIFF_HSTL I/O standards (if used)
# ADD VU9P BANKS IF THAT IS THE FPGA BEING USED
#VU13P SLR#0
#set_property INTERNAL_VREF 0.90 [get_iobanks 61]
set_property INTERNAL_VREF 0.90 [get_iobanks 62]
#set_property INTERNAL_VREF 0.90 [get_iobanks 63]
#VU13P SLR#1
set_property INTERNAL_VREF 0.90 [get_iobanks 65]
set_property INTERNAL_VREF 0.90 [get_iobanks 66]
#VU13P SLR#2 
set_property INTERNAL_VREF 0.90 [get_iobanks 70]
set_property INTERNAL_VREF 0.90 [get_iobanks 71]
#VU13P SLR#3 
set_property INTERNAL_VREF 0.90 [get_iobanks 73]
set_property INTERNAL_VREF 0.90 [get_iobanks 74]
set_property INTERNAL_VREF 0.90 [get_iobanks 75]

#-------------------------------------------------

#-------------------------------------------------
# 200 MHz system clock on bank 66
# This is SLR#1 on both VU13P and VU9P

# 'input' clk_200: 200 MHz clock (schematic name is "ac_f*_xtal_200")
set_property IOSTANDARD LVDS   [get_ports *_clk_200]
set_property DIFF_TERM_ADV TERM_100 [get_ports *_clk_200]
set_property PACKAGE_PIN	AT17	[get_ports	p_clk_200	]
set_property PACKAGE_PIN	AU16	[get_ports	n_clk_200	]
#-------------------------------------------------

#-------------------------------------------------
# other clock inputs

# A copy of the RefClk#0 used by the 12-channel FireFlys on the left side of the FPGA.
# This can be the output of either refclk synthesizer R0A or R0B. 
set_property IOSTANDARD LVDS   [get_ports *lf_x12_r0_clk]
set_property DIFF_TERM_ADV TERM_100 [get_ports *lf_x12_r0_clk]
set_property PACKAGE_PIN	P33  [get_ports	p_lf_x12_r0_clk]
set_property PACKAGE_PIN	P34  [get_ports	n_lf_x12_r0_clk]

# A copy of the RefClk#0 used by the 4-channel FireFlys on the left side of the FPGA.
# This can be the output of either refclk synthesizer R0A or R0B. 
set_property IOSTANDARD LVDS   [get_ports *lf_x4_r0_clk]
set_property DIFF_TERM_ADV TERM_100 [get_ports *lf_x4_r0_clk]
set_property PACKAGE_PIN	N32  [get_ports	p_lf_x4_r0_clk]
set_property PACKAGE_PIN	M32  [get_ports	n_lf_x4_r0_clk]

# A copy of the RefClk#0 used by the 12-channel FireFlys on the right side of the FPGA.
# This can be the output of either refclk synthesizer R0A or R0B. 
set_property IOSTANDARD LVDS   [get_ports *rt_x12_r0_clk]
set_property DIFF_TERM_ADV TERM_100 [get_ports *rt_x12_r0_clk]
set_property PACKAGE_PIN	R18  [get_ports	p_rt_x12_r0_clk]
set_property PACKAGE_PIN	R17  [get_ports	n_rt_x12_r0_clk]

# A copy of the RefClk#0 used by the 4-channel FireFlys on the right side of the FPGA.
# This can be the output of either refclk synthesizer R0A or R0B. 
set_property IOSTANDARD LVDS   [get_ports *rt_x4_r0_clk]
set_property DIFF_TERM_ADV TERM_100 [get_ports *rt_x4_r0_clk]
set_property PACKAGE_PIN	N19  [get_ports	p_rt_x4_r0_clk]
set_property PACKAGE_PIN	N18  [get_ports	n_rt_x4_r0_clk]
#-------------------------------------------------

#-----------------------------------------------
# 'input' "fpga_identity" to differentiate FPGA#1 from FPGA#2.
# The signal will be HI in FPGA#1 and LO in FPGA#2.
set_property IOSTANDARD LVCMOS18 [get_ports fpga_identity]
set_property PACKAGE_PIN	B29 [get_ports fpga_identity]
#-----------------------------------------------

#-----------------------------------------------
# 'output' "led": 3 bits to light a tri-color LED
# These use different pins on F1 vs. F2. The pins are unused on the "other" FPGA,
# so each color for both FPGAs can be driven at the same time
set_property IOSTANDARD LVCMOS18 [get_ports led_*]
set_property PACKAGE_PIN	A30 [get_ports led_f1_blue]
set_property PACKAGE_PIN	A29 [get_ports led_f1_green]
set_property PACKAGE_PIN	A28 [get_ports led_f1_red]

set_property PACKAGE_PIN	BL27 [get_ports led_f2_blue]
set_property PACKAGE_PIN	BL28 [get_ports led_f2_green]
set_property PACKAGE_PIN	BL30 [get_ports led_f2_red]
#-----------------------------------------------

#-----------------------------------------------
# 'input' "mcu_to_f": 1 bit trom the MCU
# 'output' "f_to_mcu": 1 bit to the MCU
# There is no currently defined use for these.
set_property IOSTANDARD LVCMOS18 [get_ports mcu_to_f] 
set_property IOSTANDARD LVCMOS18 [get_ports f_to_mcu] 
set_property PACKAGE_PIN	L33 [get_ports mcu_to_f]
set_property PACKAGE_PIN	M36 [get_ports f_to_mcu]
#-----------------------------------------------

#-----------------------------------------------
# 'output' "c2c_ok": 1 bit to the MCU
# The FPGA should set this output HI when the chip-2-chip link is working.
set_property IOSTANDARD LVCMOS18 [get_ports c2c_ok] 
set_property PACKAGE_PIN	L35	[get_ports c2c_ok]
#-----------------------------------------------

#-----------------------------------------------
# I2C pins
# The "sysmon" port can be accessed before the FPGA is configured.
# The "generic" port requires a configured FPGA with an I2C module. The information
# that can be accessed on the generic port is user-defined.
set_property IOSTANDARD LVCMOS18 [get_ports i2c_s*]
set_property PACKAGE_PIN	BB16 [get_ports i2c_scl_f_sysmon]
set_property PACKAGE_PIN	BC16 [get_ports i2c_sda_f_sysmon]
set_property PACKAGE_PIN	V36  [get_ports i2c_scl_f_generic]
set_property PACKAGE_PIN	J32  [get_ports i2c_sda_f_generic]
#-----------------------------------------------

#-----------------------------------------------
# TCDS signals to/from the service blade and to/from the "other" FPGA
#
# There is an asymmetry between FPGA#1 (the "primary") and FPGA#2 (the "secondary"). 
# The TCDS endpoint can be either the Zynq on the SM, or FPGA#1 on the CM.
#
# The primary ones are connected to GTY quad AB (120 on VU13P, 119 on VU9P).
# If, for some reason, the primary quad can't be modified and FPGA#1 is the TCDS
# endpoint, then TCDS signals to the Zynq and FPGA#2 can be connected
# via GTY quad L (220 on VU13P, ??? on VU9P).
#
# If the Zynq on the SM is the TCDS endpoint, then both FPGAs only use port #0 for TCDS
# signals and the two FPGAs are programmed identically.
#
# If FPGA#1 is the TCDS endpoint, then:
#  1) TCDS signals from the ATCA backplane connect to port#0 on FPGA#1
#  2) TCDS information is sent from FPGA#1 to FPGA#2 on port #3
#  3) TCDS information is sent from FPGA#1 to the Zynq on the SM on port #2.

# RefClk#0 for quad AB comes from REFCLK SYNTHESIZER R1A which can be driven by: 
#  a) synth oscillator
#  b) HQ_CLK from the SM
#     b1) 320 MHz if FPGA#1 is the TCDS endpoint
#     b2) 40 MHz if the SM is the TCDS endpoint
#  c) Optional front panel connector for an external LVDS clock
# quad AB
set_property PACKAGE_PIN	BD39	[get_ports p_lf_r0_ab]
set_property PACKAGE_PIN	BD40	[get_ports n_lf_r0_ab]

# RefClk#1 comes from REFCLK SYNTHESIZER R1B which can be driven by: 
#  a) synth oscillator
#  b) an output from EXTERNAL REFCLK SYNTH R1A
#  c) the 40 MHz TCDS RECOVERED CLOCK from FPGA #1 
# RefClk#1 is only connected on FPGA#1, and is only used when FPGA#1 is the TCDS endpoint.
# quad AB
set_property PACKAGE_PIN	BC41	[get_ports p_lf_r1_ab]
set_property PACKAGE_PIN	BC42	[get_ports n_lf_r1_ab]
# quad L
set_property PACKAGE_PIN	BC11	[get_ports p_lf_r1_l]
set_property PACKAGE_PIN	BC10	[get_ports n_lf_r1_l]

# Port #0 is the main TCDS path. Both FPGAs use it when the Zynq on the SM is the
# TCDS endpoint. Only FPGA#1 uses it when FPGA#1 is the TCDS endpoint.
# Port #0 receive (schematic name is "con*_tcds_in")
set_property PACKAGE_PIN	BG32	[get_ports p_tcds_in]
set_property PACKAGE_PIN	BG33	[get_ports n_tcds_in]
# Port #0 transmit (schematic name is "con*_tcds_out")
set_property PACKAGE_PIN	BH39	[get_ports p_tcds_out]
set_property PACKAGE_PIN	BH40	[get_ports n_tcds_out]

# Port #2 is used to send TCDS signals between FPGA#1 and the Zynq when
# FPGA#1 is the TCDS endpoint. Port #2 is not used when the Zynq on the SM is the
# TCDS endpoint. Port #2 is not connected to anything on FPGA#2.
# Port #2 receive (schematic name is "tcds_from_zynq")
# quad AB
set_property PACKAGE_PIN	BJ32	[get_ports p_tcds_from_zynq_a]
set_property PACKAGE_PIN	BJ33	[get_ports n_tcds_from_zynq_a]
# quad L
set_property PACKAGE_PIN	BJ20	[get_ports p_tcds_from_zynq_b]
set_property PACKAGE_PIN	BJ19	[get_ports n_tcds_from_zynq_b]
# quad AB
# Port #2 transmit (schematic name is "tcds_to_zynq")
# quad AB
set_property PACKAGE_PIN	BJ37	[get_ports p_tcds_to_zynq_a]
set_property PACKAGE_PIN	BJ38	[get_ports n_tcds_to_zynq_a]
# quad L
set_property PACKAGE_PIN	BJ15	[get_ports p_tcds_to_zynq_b]
set_property PACKAGE_PIN	BJ14	[get_ports n_tcds_to_zynq_b]

# Port #3 is cross-connected between the two FPGAs. It is only used when FPGA#1
# is the TCDS endpoint.
# Port #3 receive
# quad AB
set_property PACKAGE_PIN	BH34	[get_ports p_tcds_cross_recv_a]
set_property PACKAGE_PIN	BH35	[get_ports n_tcds_cross_recv_a]
# quad L
set_property PACKAGE_PIN	BH18	[get_ports p_tcds_cross_recv_b]
set_property PACKAGE_PIN	BH17	[get_ports n_tcds_cross_recv_b]
#Port #3 transmit
# quad AB
set_property PACKAGE_PIN	BG37	[get_ports p_tcds_cross_xmit_a]
set_property PACKAGE_PIN	BG38	[get_ports n_tcds_cross_xmit_a]
# quad L
set_property PACKAGE_PIN	BG15	[get_ports p_tcds_cross_xmit_b]
set_property PACKAGE_PIN	BG14	[get_ports n_tcds_cross_xmit_b]

# Recovered 40 MHz TCDS clock output to feed REFCLK SYNTHESIZER R1B.
# This is only connected on FPGA#1, and is only used when FPGA#1 is the
# TCDS endpoint. On FPGA#2, these signals are not connected, but are reserved.
set_property IOSTANDARD LVDS   [get_ports *_tcds_recov_clk]
set_property PACKAGE_PIN	BJ26	[get_ports p_tcds_recov_clk]
set_property PACKAGE_PIN	BK26	[get_ports n_tcds_recov_clk]

# 40 MHz TCDS clock connected to FPGA logic. This is used in the FPGA for two
# purposes. The first is to generate high-speed processing clocks by multiplying
# in an MMCM. The second is to synchronize processing to the 40 MHz LHC bunch crossing.
set_property IOSTANDARD LVDS   [get_ports *_tcds40_clk]
set_property DIFF_TERM_ADV TERM_100 [get_ports *_tcds40_clk]
set_property PACKAGE_PIN	AR17	[get_ports p_tcds40_clk		]
set_property PACKAGE_PIN	AR16	[get_ports n_tcds40_clk		]
#-----------------------------------------------

#-----------------------------------------------
# AXI C2C signals
# GTY transceiver reference clocks for AXI C2C link to SM.
# Quad L (VU13P=220, VU9P=219)
# RefClk#1 on BC11/BC10 is used for TCDS.
set_property PACKAGE_PIN	BD13 [get_ports	p_rt_r0_l]
set_property PACKAGE_PIN	BD12 [get_ports	n_rt_r0_l]

# GTY AXI C2C links to the SM
# 'input' "SM_TO_F": links from the Zynq on the SM
# 'output' "F_TO_SM": links to the Zynq on the SM
# Quad L (VU13P=220, VU9P=219)
# Port #0 receive
set_property PACKAGE_PIN	BG20 [get_ports p_mgt_sm_to_f_1]
set_property PACKAGE_PIN	BG19 [get_ports n_mgt_sm_to_f_1]
# Port #0 transmit
set_property PACKAGE_PIN	BH13 [get_ports p_mgt_f_to_sm_1]
set_property PACKAGE_PIN	BH12 [get_ports n_mgt_f_to_sm_1]
# Port #1 receive
set_property PACKAGE_PIN	BF18 [get_ports p_mgt_sm_to_f_2]
set_property PACKAGE_PIN	BF17 [get_ports n_mgt_sm_to_f_2]
# Port #1 transmit
set_property PACKAGE_PIN	BF13 [get_ports p_mgt_f_to_sm_2]
set_property PACKAGE_PIN	BF12 [get_ports n_mgt_f_to_sm_2]
#-----------------------------------------------

#-----------------------------------------------

#-----------------------------------------------
# GTY transceiver reference clocks for 12-lane FireFLy #1
# Quad AD (VU13P=122, VU9P=121)
# Use the same clocks for adjacent quads AC and AE (VU13P=121/122/123, VU9P=120/121/122)
set_property PACKAGE_PIN	AY39 [get_ports	p_lf_r0_ad]
set_property PACKAGE_PIN	AY40 [get_ports	n_lf_r0_ad]
set_property PACKAGE_PIN	AW41 [get_ports	p_lf_r1_ad]
set_property PACKAGE_PIN	AW42 [get_ports	n_lf_r1_ad]
#-----------------------------------------------

#-----------------------------------------------
# GTY transceiver reference clocks for 12-lane FireFLy #2
# Quad R (VU13P=126, VU9P=125)
# Use the same clocks for adjacent quads Q and S (VU13P=125/126/127, VU9P=124/125/126)
set_property PACKAGE_PIN	AM39 [get_ports	p_lf_r0_r]
set_property PACKAGE_PIN	AM40 [get_ports	n_lf_r0_r]
set_property PACKAGE_PIN	AL41 [get_ports	p_lf_r1_r]
set_property PACKAGE_PIN	AL42 [get_ports	n_lf_r1_r]
#-----------------------------------------------

#-----------------------------------------------
# GTY transceiver reference clocks for 12-lane FireFLy #3
# Quad Y (VU13P=133, VU9P=132)
# Use the same clocks for adjacent quads X and Z (VU13P=132/133/134, VU9P=131/132/133)
set_property PACKAGE_PIN	N41  [get_ports	p_lf_r0_y]
set_property PACKAGE_PIN	N42  [get_ports	n_lf_r0_y]
set_property PACKAGE_PIN	M39  [get_ports	p_lf_r1_y]
set_property PACKAGE_PIN	M40  [get_ports	n_lf_r1_y]
#-----------------------------------------------

#-----------------------------------------------
# GTY transceiver reference clocks for 4-lane FireFLy #4
# Quad AF (VU13P=124, VU9P=123)
# This clock is not shared with any adjacent quads.
set_property PACKAGE_PIN	AT39 [get_ports	p_lf_r0_af]
set_property PACKAGE_PIN	AT40 [get_ports	n_lf_r0_af]
set_property PACKAGE_PIN	AR41 [get_ports	p_lf_r1_af]
set_property PACKAGE_PIN	AR42 [get_ports	n_lf_r1_af]
#-----------------------------------------------

#-----------------------------------------------
# GTY transceiver reference clocks for 4-lane FireFLy #5,6,7
# Quad U (VU13P=129, VU9P=128)
# Use the same clocks for adjacent quads T and V (VU13P=128/129/130, VU9P=127/128)
# FireFly #7 is in a different SLR on the VU9P, so an additional clock is needed
# for quad V (129) on the VU9P package.
set_property PACKAGE_PIN	AA41 [get_ports	p_lf_r0_u]
set_property PACKAGE_PIN	AA42 [get_ports	n_lf_r0_u]
set_property PACKAGE_PIN	Y39  [get_ports	p_lf_r1_u]
set_property PACKAGE_PIN	Y40  [get_ports	n_lf_r1_u]
# RefClk#1 on quad V is not connected.
# Quad V (VU13P=130, VU9P=129)
set_property PACKAGE_PIN	W41  [get_ports	p_lf_r0_v]
set_property PACKAGE_PIN	W42  [get_ports	n_lf_r0_v]
#-----------------------------------------------

#-----------------------------------------------
# GTY transceiver reference clocks for FPGA-to-FPGA links
# On single-FPGA boards with FPGA#2 jumpers, this will also
# be the secondary 12-lane FireFly#3
# Quad N (VU13P=222, VU9P=221)
# Use the same clocks for adjacent quads M and O (VU13P=221/222/223, VU9P=220/221/222)
set_property PACKAGE_PIN	AY13 [get_ports	p_rt_r0_n]
set_property PACKAGE_PIN	AY12 [get_ports	n_rt_r0_n]
set_property PACKAGE_PIN	AW11 [get_ports	p_rt_r1_n]
set_property PACKAGE_PIN	AW10 [get_ports	n_rt_r1_n]
#-----------------------------------------------

#-----------------------------------------------
# GTY transceiver reference clocks for FPGA-to-FPGA links
# On single-FPGA boards with FPGA#2 jumpers, this will also
# be the secondary 4-lane FireFly#5,6,7
# Quad B (VU13P=226, VU9P=225)
# Use the same clocks for adjacent quads A and C (VU13P=225/226/227, VU9P=224/225/226)
set_property PACKAGE_PIN	AM13 [get_ports	p_rt_r0_b		]
set_property PACKAGE_PIN	AM12 [get_ports	n_rt_r0_b]
set_property PACKAGE_PIN	AL11 [get_ports	p_rt_r1_b]
set_property PACKAGE_PIN	AL10 [get_ports	n_rt_r1_b]
#-----------------------------------------------

#-----------------------------------------------
# GTY transceiver reference clocks for FPGA-to-FPGA links
# On single-FPGA boards with FPGA#2 jumpers, this will also
# be the secondary 12-lane FireFly#2
# Quad E (VU13P=229, VU9P=228)
# Use the same clocks for adjacent quads D and F (VU13P=228/229/230, VU9P=227/228)
# FireFly #2 is split between different SLRs on the VU9P, so an additional clock is needed
# for quad F (229) on the VU9P package. However, there are not enough sources for RefClk#1,
# so if Quad F on the VU9P package needs a RefClk#1, it will have to use the clock
# from the adjacent quad G.
set_property PACKAGE_PIN	AA11 [get_ports	p_rt_r0_e]
set_property PACKAGE_PIN	AA10 [get_ports	n_rt_r0_e]
set_property PACKAGE_PIN	Y13  [get_ports	p_rt_r1_e]
set_property PACKAGE_PIN	Y12  [get_ports	n_rt_r1_e]
# Quad F (VU13P=230, VU9P=229)
set_property PACKAGE_PIN	W10  [get_ports	n_rt_r0_f]
set_property PACKAGE_PIN	W11  [get_ports	p_rt_r0_f]
#-----------------------------------------------

#-----------------------------------------------
# GTY transceiver reference clocks for FPGA-to-FPGA links
# On single-FPGA boards with FPGA#2 jumpers, this will also
# be the secondary 4-lane FireFly#4
# Quad G (VU13P=231, VU9P=230)
# This quad is not used on FPGA#2. 
# It is used on FPGA#1 to connect to quad P on FPGA#2
set_property PACKAGE_PIN	U11  [get_ports	p_rt_r0_g]
set_property PACKAGE_PIN	U10  [get_ports	n_rt_r0_g]
set_property PACKAGE_PIN	T13  [get_ports	p_rt_r1_g]
set_property PACKAGE_PIN	T12  [get_ports	n_rt_r1_g]
#-----------------------------------------------

#-----------------------------------------------
# GTY transceiver reference clocks for FPGA-to-FPGA links
# Quad P (VU13P=224, VU9P=223)
# This quad is not used on FPGA#1.
# It is used on FPGA#2 to connect to quad G on FPGA#1
set_property PACKAGE_PIN	AT13 [get_ports	p_rt_r0_p]
set_property PACKAGE_PIN	AT12 [get_ports	n_rt_r0_p]
set_property PACKAGE_PIN	AR11 [get_ports	p_rt_r1_p]
set_property PACKAGE_PIN	AR10 [get_ports	n_rt_r1_p]
#-----------------------------------------------

#-----------------------------------------------
# GTY transceiver reference clocks for FPGA-to-FPGA links
# On single-FPGA boards with FPGA#2 jumpers, this will also
# be the secondary 12-lane FireFly#1
# Quad I (VU13P=233, VU9P=232)
# Use the same clocks for adjacent quads H and J (VU13P=232/233/234, VU9P=231/232/233)
set_property PACKAGE_PIN	N11  [get_ports	p_rt_r0_i]
set_property PACKAGE_PIN	N10  [get_ports	n_rt_r0_i]
set_property PACKAGE_PIN	M13  [get_ports	p_rt_r1_i]
set_property PACKAGE_PIN	M12  [get_ports	n_rt_r1_i]
#-----------------------------------------------



#-----------------------------------------------
# firefly#1 receivers
# Uses quads AC, AD, AE (VU13P=121/122/123, VU9P=120/121/122)
# Clocked from quad AD (VU13P=122, VU9P=121)
set_property PACKAGE_PIN	BK34	[get_ports	{	p_ff1_recv[0]	}	]
set_property PACKAGE_PIN	BK35	[get_ports	{	n_ff1_recv[0]	}	]
set_property PACKAGE_PIN	BL32	[get_ports	{	p_ff1_recv[1]	}	]
set_property PACKAGE_PIN	BL33	[get_ports	{	n_ff1_recv[1]	}	]
set_property PACKAGE_PIN	BC50	[get_ports	{	p_ff1_recv[10]	}	]
set_property PACKAGE_PIN	BC51	[get_ports	{	n_ff1_recv[10]	}	]
set_property PACKAGE_PIN	BB48	[get_ports	{	p_ff1_recv[11]	}	]
set_property PACKAGE_PIN	BB49	[get_ports	{	n_ff1_recv[11]	}	]
set_property PACKAGE_PIN	BL46	[get_ports	{	p_ff1_recv[2]	}	]
set_property PACKAGE_PIN	BL47	[get_ports	{	n_ff1_recv[2]	}	]
set_property PACKAGE_PIN	BJ46	[get_ports	{	p_ff1_recv[3]	}	]
set_property PACKAGE_PIN	BJ47	[get_ports	{	n_ff1_recv[3]	}	]
set_property PACKAGE_PIN	BH48	[get_ports	{	p_ff1_recv[4]	}	]
set_property PACKAGE_PIN	BH49	[get_ports	{	n_ff1_recv[4]	}	]
set_property PACKAGE_PIN	BG50	[get_ports	{	p_ff1_recv[5]	}	]
set_property PACKAGE_PIN	BG51	[get_ports	{	n_ff1_recv[5]	}	]
set_property PACKAGE_PIN	BG46	[get_ports	{	p_ff1_recv[6]	}	]
set_property PACKAGE_PIN	BG47	[get_ports	{	n_ff1_recv[6]	}	]
set_property PACKAGE_PIN	BF48	[get_ports	{	p_ff1_recv[7]	}	]
set_property PACKAGE_PIN	BF49	[get_ports	{	n_ff1_recv[7]	}	]
set_property PACKAGE_PIN	BE50	[get_ports	{	p_ff1_recv[8]	}	]
set_property PACKAGE_PIN	BE51	[get_ports	{	n_ff1_recv[8]	}	]
set_property PACKAGE_PIN	BD48	[get_ports	{	p_ff1_recv[9]	}	]
set_property PACKAGE_PIN	BD49	[get_ports	{	n_ff1_recv[9]	}	]
#-----------------------------------------------

#-----------------------------------------------
# firefly#1 transmitters
# Uses quads AC, AD, AE (VU13P=121/122/123, VU9P=120/121/122)
# Clocked from quad AD (VU13P=122, VU9P=121)
set_property PACKAGE_PIN	BL37	[get_ports	{	p_ff1_xmit[0]	}	]
set_property PACKAGE_PIN	BL38	[get_ports	{	n_ff1_xmit[0]	}	]
set_property PACKAGE_PIN	BK39	[get_ports	{	p_ff1_xmit[1]	}	]
set_property PACKAGE_PIN	BK40	[get_ports	{	n_ff1_xmit[1]	}	]
set_property PACKAGE_PIN	BC45	[get_ports	{	p_ff1_xmit[10]	}	]
set_property PACKAGE_PIN	BC46	[get_ports	{	n_ff1_xmit[10]	}	]
set_property PACKAGE_PIN	BB43	[get_ports	{	p_ff1_xmit[11]	}	]
set_property PACKAGE_PIN	BB44	[get_ports	{	n_ff1_xmit[11]	}	]
set_property PACKAGE_PIN	BL41	[get_ports	{	p_ff1_xmit[2]	}	]
set_property PACKAGE_PIN	BL42	[get_ports	{	n_ff1_xmit[2]	}	]
set_property PACKAGE_PIN	BK43	[get_ports	{	p_ff1_xmit[3]	}	]
set_property PACKAGE_PIN	BK44	[get_ports	{	n_ff1_xmit[3]	}	]
set_property PACKAGE_PIN	BG41	[get_ports	{	p_ff1_xmit[4]	}	]
set_property PACKAGE_PIN	BG42	[get_ports	{	n_ff1_xmit[4]	}	]
set_property PACKAGE_PIN	BJ41	[get_ports	{	p_ff1_xmit[5]	}	]
set_property PACKAGE_PIN	BJ42	[get_ports	{	n_ff1_xmit[5]	}	]
set_property PACKAGE_PIN	BH43	[get_ports	{	p_ff1_xmit[6]	}	]
set_property PACKAGE_PIN	BH44	[get_ports	{	n_ff1_xmit[6]	}	]
set_property PACKAGE_PIN	BF43	[get_ports	{	p_ff1_xmit[7]	}	]
set_property PACKAGE_PIN	BF44	[get_ports	{	n_ff1_xmit[7]	}	]
set_property PACKAGE_PIN	BE45	[get_ports	{	p_ff1_xmit[8]	}	]
set_property PACKAGE_PIN	BE46	[get_ports	{	n_ff1_xmit[8]	}	]
set_property PACKAGE_PIN	BD43	[get_ports	{	p_ff1_xmit[9]	}	]
set_property PACKAGE_PIN	BD44	[get_ports	{	n_ff1_xmit[9]	}	]
#-----------------------------------------------

#-----------------------------------------------
# firefly#2 receivers
# Uses quads Q, R, S (VU13P=125/126/127, VU9P=124/125/126)
# Clocked from quad R (VU13P=126, VU9P=125)
set_property PACKAGE_PIN	AU50	[get_ports	{	p_ff2_recv[0]	}	]
set_property PACKAGE_PIN	AU51	[get_ports	{	n_ff2_recv[0]	}	]
set_property PACKAGE_PIN	AT48	[get_ports	{	p_ff2_recv[1]	}	]
set_property PACKAGE_PIN	AT49	[get_ports	{	n_ff2_recv[1]	}	]
set_property PACKAGE_PIN	AG50	[get_ports	{	p_ff2_recv[10]	}	]
set_property PACKAGE_PIN	AG51	[get_ports	{	n_ff2_recv[10]	}	]
set_property PACKAGE_PIN	AF48	[get_ports	{	p_ff2_recv[11]	}	]
set_property PACKAGE_PIN	AF49	[get_ports	{	n_ff2_recv[11]	}	]
set_property PACKAGE_PIN	AR50	[get_ports	{	p_ff2_recv[2]	}	]
set_property PACKAGE_PIN	AR51	[get_ports	{	n_ff2_recv[2]	}	]
set_property PACKAGE_PIN	AP48	[get_ports	{	p_ff2_recv[3]	}	]
set_property PACKAGE_PIN	AP49	[get_ports	{	n_ff2_recv[3]	}	]
set_property PACKAGE_PIN	AN50	[get_ports	{	p_ff2_recv[4]	}	]
set_property PACKAGE_PIN	AN51	[get_ports	{	n_ff2_recv[4]	}	]
set_property PACKAGE_PIN	AM48	[get_ports	{	p_ff2_recv[5]	}	]
set_property PACKAGE_PIN	AM49	[get_ports	{	n_ff2_recv[5]	}	]
set_property PACKAGE_PIN	AL50	[get_ports	{	p_ff2_recv[6]	}	]
set_property PACKAGE_PIN	AL51	[get_ports	{	n_ff2_recv[6]	}	]
set_property PACKAGE_PIN	AK48	[get_ports	{	p_ff2_recv[7]	}	]
set_property PACKAGE_PIN	AK49	[get_ports	{	n_ff2_recv[7]	}	]
set_property PACKAGE_PIN	AJ50	[get_ports	{	p_ff2_recv[8]	}	]
set_property PACKAGE_PIN	AJ51	[get_ports	{	n_ff2_recv[8]	}	]
set_property PACKAGE_PIN	AH48	[get_ports	{	p_ff2_recv[9]	}	]
set_property PACKAGE_PIN	AH49	[get_ports	{	n_ff2_recv[9]	}	]
#-----------------------------------------------

#-----------------------------------------------
# firefly#2 transmitters
# Uses quads Q, R, S (VU13P=125/126/127, VU9P=124/125/126)
# Clocked from quad R (VU13P=126, VU9P=125)
set_property PACKAGE_PIN	AU45	[get_ports	{	p_ff2_xmit[0]	}	]
set_property PACKAGE_PIN	AU46	[get_ports	{	n_ff2_xmit[0]	}	]
set_property PACKAGE_PIN	AT43	[get_ports	{	p_ff2_xmit[1]	}	]
set_property PACKAGE_PIN	AT44	[get_ports	{	n_ff2_xmit[1]	}	]
set_property PACKAGE_PIN	AG45	[get_ports	{	p_ff2_xmit[10]	}	]
set_property PACKAGE_PIN	AG46	[get_ports	{	n_ff2_xmit[10]	}	]
set_property PACKAGE_PIN	AF43	[get_ports	{	p_ff2_xmit[11]	}	]
set_property PACKAGE_PIN	AF44	[get_ports	{	n_ff2_xmit[11]	}	]
set_property PACKAGE_PIN	AR45	[get_ports	{	p_ff2_xmit[2]	}	]
set_property PACKAGE_PIN	AR46	[get_ports	{	n_ff2_xmit[2]	}	]
set_property PACKAGE_PIN	AP43	[get_ports	{	p_ff2_xmit[3]	}	]
set_property PACKAGE_PIN	AP44	[get_ports	{	n_ff2_xmit[3]	}	]
set_property PACKAGE_PIN	AN45	[get_ports	{	p_ff2_xmit[4]	}	]
set_property PACKAGE_PIN	AN46	[get_ports	{	n_ff2_xmit[4]	}	]
set_property PACKAGE_PIN	AM43	[get_ports	{	p_ff2_xmit[5]	}	]
set_property PACKAGE_PIN	AM44	[get_ports	{	n_ff2_xmit[5]	}	]
set_property PACKAGE_PIN	AL45	[get_ports	{	p_ff2_xmit[6]	}	]
set_property PACKAGE_PIN	AL46	[get_ports	{	n_ff2_xmit[6]	}	]
set_property PACKAGE_PIN	AK43	[get_ports	{	p_ff2_xmit[7]	}	]
set_property PACKAGE_PIN	AK44	[get_ports	{	n_ff2_xmit[7]	}	]
set_property PACKAGE_PIN	AJ45	[get_ports	{	p_ff2_xmit[8]	}	]
set_property PACKAGE_PIN	AJ46	[get_ports	{	n_ff2_xmit[8]	}	]
set_property PACKAGE_PIN	AH43	[get_ports	{	p_ff2_xmit[9]	}	]
set_property PACKAGE_PIN	AH44	[get_ports	{	n_ff2_xmit[9]	}	]
#-----------------------------------------------

#-----------------------------------------------
# firefly#3 receivers
# Uses quads X, Y, Z (VU13P=132/133/134, VU9P=131/132/133)
# Clocked from quad Y (VU13P=133, VU9P=132)
set_property PACKAGE_PIN	J50	[get_ports	{	p_ff3_recv[0]	}	]
set_property PACKAGE_PIN	J51	[get_ports	{	n_ff3_recv[0]	}	]
set_property PACKAGE_PIN	H48	[get_ports	{	p_ff3_recv[1]	}	]
set_property PACKAGE_PIN	H49	[get_ports	{	n_ff3_recv[1]	}	]
set_property PACKAGE_PIN	B34	[get_ports	{	p_ff3_recv[10]	}	]
set_property PACKAGE_PIN	B35	[get_ports	{	n_ff3_recv[10]	}	]
set_property PACKAGE_PIN	C32	[get_ports	{	p_ff3_recv[11]	}	]
set_property PACKAGE_PIN	C33	[get_ports	{	n_ff3_recv[11]	}	]
set_property PACKAGE_PIN	G50	[get_ports	{	p_ff3_recv[2]	}	]
set_property PACKAGE_PIN	G51	[get_ports	{	n_ff3_recv[2]	}	]
set_property PACKAGE_PIN	F48	[get_ports	{	p_ff3_recv[3]	}	]
set_property PACKAGE_PIN	F49	[get_ports	{	n_ff3_recv[3]	}	]
set_property PACKAGE_PIN	E50	[get_ports	{	p_ff3_recv[4]	}	]
set_property PACKAGE_PIN	E51	[get_ports	{	n_ff3_recv[4]	}	]
set_property PACKAGE_PIN	D48	[get_ports	{	p_ff3_recv[5]	}	]
set_property PACKAGE_PIN	D49	[get_ports	{	n_ff3_recv[5]	}	]
set_property PACKAGE_PIN	E46	[get_ports	{	p_ff3_recv[6]	}	]
set_property PACKAGE_PIN	E47	[get_ports	{	n_ff3_recv[6]	}	]
set_property PACKAGE_PIN	C46	[get_ports	{	p_ff3_recv[7]	}	]
set_property PACKAGE_PIN	C47	[get_ports	{	n_ff3_recv[7]	}	]
set_property PACKAGE_PIN	A46	[get_ports	{	p_ff3_recv[8]	}	]
set_property PACKAGE_PIN	A47	[get_ports	{	n_ff3_recv[8]	}	]
set_property PACKAGE_PIN	A32	[get_ports	{	p_ff3_recv[9]	}	]
set_property PACKAGE_PIN	A33	[get_ports	{	n_ff3_recv[9]	}	]
#-----------------------------------------------

#-----------------------------------------------
# firefly#3 transmitters
# Uses quads X, Y, Z (VU13P=132/133/134, VU9P=131/132/133)
# Clocked from quad Y (VU13P=133, VU9P=132)
set_property PACKAGE_PIN	J45	[get_ports	{	p_ff3_xmit[0]	}	]
set_property PACKAGE_PIN	J46	[get_ports	{	n_ff3_xmit[0]	}	]
set_property PACKAGE_PIN	H43	[get_ports	{	p_ff3_xmit[1]	}	]
set_property PACKAGE_PIN	H44	[get_ports	{	n_ff3_xmit[1]	}	]
set_property PACKAGE_PIN	A37	[get_ports	{	p_ff3_xmit[10]	}	]
set_property PACKAGE_PIN	A38	[get_ports	{	n_ff3_xmit[10]	}	]
set_property PACKAGE_PIN	C37	[get_ports	{	p_ff3_xmit[11]	}	]
set_property PACKAGE_PIN	C38	[get_ports	{	n_ff3_xmit[11]	}	]
set_property PACKAGE_PIN	G45	[get_ports	{	p_ff3_xmit[2]	}	]
set_property PACKAGE_PIN	G46	[get_ports	{	n_ff3_xmit[2]	}	]
set_property PACKAGE_PIN	F43	[get_ports	{	p_ff3_xmit[3]	}	]
set_property PACKAGE_PIN	F44	[get_ports	{	n_ff3_xmit[3]	}	]
set_property PACKAGE_PIN	D43	[get_ports	{	p_ff3_xmit[4]	}	]
set_property PACKAGE_PIN	D44	[get_ports	{	n_ff3_xmit[4]	}	]
set_property PACKAGE_PIN	B43	[get_ports	{	p_ff3_xmit[5]	}	]
set_property PACKAGE_PIN	B44	[get_ports	{	n_ff3_xmit[5]	}	]
set_property PACKAGE_PIN	C41	[get_ports	{	p_ff3_xmit[6]	}	]
set_property PACKAGE_PIN	C42	[get_ports	{	n_ff3_xmit[6]	}	]
set_property PACKAGE_PIN	E41	[get_ports	{	p_ff3_xmit[7]	}	]
set_property PACKAGE_PIN	E42	[get_ports	{	n_ff3_xmit[7]	}	]
set_property PACKAGE_PIN	A41	[get_ports	{	p_ff3_xmit[8]	}	]
set_property PACKAGE_PIN	A42	[get_ports	{	n_ff3_xmit[8]	}	]
set_property PACKAGE_PIN	B39	[get_ports	{	p_ff3_xmit[9]	}	]
set_property PACKAGE_PIN	B40	[get_ports	{	n_ff3_xmit[9]	}	]
#-----------------------------------------------

#-----------------------------------------------
# firefly#4 receivers
# Uses quad AF (VU13P=124, VU9P=123)
# Clocked from quad AF (VU13P=124, VU9P=123)
set_property PACKAGE_PIN	BA50	[get_ports	{	p_ff4_recv[0]	}	]
set_property PACKAGE_PIN	BA51	[get_ports	{	n_ff4_recv[0]	}	]
set_property PACKAGE_PIN	AY48	[get_ports	{	p_ff4_recv[1]	}	]
set_property PACKAGE_PIN	AY49	[get_ports	{	n_ff4_recv[1]	}	]
set_property PACKAGE_PIN	AW50	[get_ports	{	p_ff4_recv[2]	}	]
set_property PACKAGE_PIN	AW51	[get_ports	{	n_ff4_recv[2]	}	]
set_property PACKAGE_PIN	AV48	[get_ports	{	p_ff4_recv[3]	}	]
set_property PACKAGE_PIN	AV49	[get_ports	{	n_ff4_recv[3]	}	]
#-----------------------------------------------

#-----------------------------------------------
# firefly#4 transmitters
# Uses quad AF (VU13P=124, VU9P=123)
# Clocked from quad AF (VU13P=124, VU9P=123)
set_property PACKAGE_PIN	BA45	[get_ports	{	p_ff4_xmit[0]	}	]
set_property PACKAGE_PIN	BA46	[get_ports	{	n_ff4_xmit[0]	}	]
set_property PACKAGE_PIN	AY43	[get_ports	{	p_ff4_xmit[1]	}	]
set_property PACKAGE_PIN	AY44	[get_ports	{	n_ff4_xmit[1]	}	]
set_property PACKAGE_PIN	AW45	[get_ports	{	p_ff4_xmit[2]	}	]
set_property PACKAGE_PIN	AW46	[get_ports	{	n_ff4_xmit[2]	}	]
set_property PACKAGE_PIN	AV43	[get_ports	{	p_ff4_xmit[3]	}	]
set_property PACKAGE_PIN	AV44	[get_ports	{	n_ff4_xmit[3]	}	]
#-----------------------------------------------

#-----------------------------------------------
# firefly#5 receivers
# Uses quad T (VU13P=128, VU9P=127)
# Clocked from quad U (VU13P=129, VU9P=128)
set_property PACKAGE_PIN	AE50	[get_ports	{	p_ff5_recv[0]	}	]
set_property PACKAGE_PIN	AE51	[get_ports	{	n_ff5_recv[0]	}	]
set_property PACKAGE_PIN	AD48	[get_ports	{	p_ff5_recv[1]	}	]
set_property PACKAGE_PIN	AD49	[get_ports	{	n_ff5_recv[1]	}	]
set_property PACKAGE_PIN	AC50	[get_ports	{	p_ff5_recv[2]	}	]
set_property PACKAGE_PIN	AC51	[get_ports	{	n_ff5_recv[2]	}	]
set_property PACKAGE_PIN	AB48	[get_ports	{	p_ff5_recv[3]	}	]
set_property PACKAGE_PIN	AB49	[get_ports	{	n_ff5_recv[3]	}	]
#-----------------------------------------------

#-----------------------------------------------
# firefly#5 transmitters
# Uses quad T (VU13P=128, VU9P=127)
# Clocked from quad U (VU13P=129, VU9P=128)
set_property PACKAGE_PIN	AE45	[get_ports	{	p_ff5_xmit[0]	}	]
set_property PACKAGE_PIN	AE46	[get_ports	{	n_ff5_xmit[0]	}	]
set_property PACKAGE_PIN	AD43	[get_ports	{	p_ff5_xmit[1]	}	]
set_property PACKAGE_PIN	AD44	[get_ports	{	n_ff5_xmit[1]	}	]
set_property PACKAGE_PIN	AC45	[get_ports	{	p_ff5_xmit[2]	}	]
set_property PACKAGE_PIN	AC46	[get_ports	{	n_ff5_xmit[2]	}	]
set_property PACKAGE_PIN	AB43	[get_ports	{	p_ff5_xmit[3]	}	]
set_property PACKAGE_PIN	AB44	[get_ports	{	n_ff5_xmit[3]	}	]
#-----------------------------------------------

#-----------------------------------------------
# firefly#6 receivers
# Uses quad U (VU13P=129, VU9P=128)
# Clocked from quad U (VU13P=129, VU9P=128)
set_property PACKAGE_PIN	AA50	[get_ports	{	p_ff6_recv[0]	}	]
set_property PACKAGE_PIN	AA51	[get_ports	{	n_ff6_recv[0]	}	]
set_property PACKAGE_PIN	Y48	[get_ports	{	p_ff6_recv[1]	}	]
set_property PACKAGE_PIN	Y49	[get_ports	{	n_ff6_recv[1]	}	]
set_property PACKAGE_PIN	W50	[get_ports	{	p_ff6_recv[2]	}	]
set_property PACKAGE_PIN	W51	[get_ports	{	n_ff6_recv[2]	}	]
set_property PACKAGE_PIN	V48	[get_ports	{	p_ff6_recv[3]	}	]
set_property PACKAGE_PIN	V49	[get_ports	{	n_ff6_recv[3]	}	]
#-----------------------------------------------

#-----------------------------------------------
# firefly#6 transmitters
# Uses quad U (VU13P=129, VU9P=128)
# Clocked from quad U (VU13P=129, VU9P=128)
set_property PACKAGE_PIN	AA45	[get_ports	{	p_ff6_xmit[0]	}	]
set_property PACKAGE_PIN	AA46	[get_ports	{	n_ff6_xmit[0]	}	]
set_property PACKAGE_PIN	Y43	[get_ports	{	p_ff6_xmit[1]	}	]
set_property PACKAGE_PIN	Y44	[get_ports	{	n_ff6_xmit[1]	}	]
set_property PACKAGE_PIN	W45	[get_ports	{	p_ff6_xmit[2]	}	]
set_property PACKAGE_PIN	W46	[get_ports	{	n_ff6_xmit[2]	}	]
set_property PACKAGE_PIN	V43	[get_ports	{	p_ff6_xmit[3]	}	]
set_property PACKAGE_PIN	V44	[get_ports	{	n_ff6_xmit[3]	}	]
#-----------------------------------------------

#-----------------------------------------------
# firefly#7 receivers
# Uses quad V (VU13P=130, VU9P=129)
# In the VU9P, this is in a different SLR than FireFly#5,6
# Clocked from quad U on VU13P (VU13P=129)
# Clocked from quad V on VU9P (VU9P=129)
set_property PACKAGE_PIN	U50	[get_ports	{	p_ff7_recv[0]	}	]
set_property PACKAGE_PIN	U51	[get_ports	{	n_ff7_recv[0]	}	]
set_property PACKAGE_PIN	T48	[get_ports	{	p_ff7_recv[1]	}	]
set_property PACKAGE_PIN	T49	[get_ports	{	n_ff7_recv[1]	}	]
set_property PACKAGE_PIN	R50	[get_ports	{	p_ff7_recv[2]	}	]
set_property PACKAGE_PIN	R51	[get_ports	{	n_ff7_recv[2]	}	]
set_property PACKAGE_PIN	P48	[get_ports	{	p_ff7_recv[3]	}	]
set_property PACKAGE_PIN	P49	[get_ports	{	n_ff7_recv[3]	}	]
#-----------------------------------------------

#-----------------------------------------------
# firefly#7 transmitters
# Uses quad V (VU13P=130, VU9P=129)
# In the VU9P, this is in a different SLR than FireFly#5,6
# Clocked from quad U on VU13P (VU13P=129)
# Clocked from quad V on VU9P (VU9P=129)
set_property PACKAGE_PIN	U45	[get_ports	{	p_ff7_xmit[0]	}	]
set_property PACKAGE_PIN	U46	[get_ports	{	n_ff7_xmit[0]	}	]
set_property PACKAGE_PIN	T43	[get_ports	{	p_ff7_xmit[1]	}	]
set_property PACKAGE_PIN	T44	[get_ports	{	n_ff7_xmit[1]	}	]
set_property PACKAGE_PIN	R45	[get_ports	{	p_ff7_xmit[2]	}	]
set_property PACKAGE_PIN	R46	[get_ports	{	n_ff7_xmit[2]	}	]
set_property PACKAGE_PIN	P43	[get_ports	{	p_ff7_xmit[3]	}	]
set_property PACKAGE_PIN	P44	[get_ports	{	n_ff7_xmit[3]	}	]
#-----------------------------------------------

#-----------------------------------------------
# GTY transceiver for FPGA-to-FPGA links
# FPGA#1 quad A connects to FPGA#2 quad F
# FPGA#1 quad F connects to FPGA#2 quad A
# Quad A (VU13P=225, VU9P=224)
# Quad F (VU13P=230, VU9P=229)
# On single-FPGA boards with FPGA#2 jumpers, FPGA#1 quad A will also
# connect to the secondary 4-lane FireFly#7
# On single-FPGA boards with FPGA#2 jumpers, FPGA#1 quad F will also
# connect to the secondary 12-lane FireFly#2
# FPGA#1 and FPGA#2 quad A are clocked from quad B (VU13P=226, VU9P=225)
# FPGA#1 and FPGA#2 quad F is clocked from quad F (VU13P=230, VU9P=229)
# 
# Quad A receivers
set_property PACKAGE_PIN	AU2	[get_ports	{	p_a_recv[0]	}	]
set_property PACKAGE_PIN	AU1	[get_ports	{	n_a_recv[0]	}	]
set_property PACKAGE_PIN	AT4	[get_ports	{	p_a_recv[1]	}	]
set_property PACKAGE_PIN	AT3	[get_ports	{	n_a_recv[1]	}	]
set_property PACKAGE_PIN	AR2	[get_ports	{	p_a_recv[2]	}	]
set_property PACKAGE_PIN	AR1	[get_ports	{	n_a_recv[2]	}	]
set_property PACKAGE_PIN	AP4	[get_ports	{	p_a_recv[3]	}	]
set_property PACKAGE_PIN	AP3	[get_ports	{	n_a_recv[3]	}	]

# Quad A transmitters
set_property PACKAGE_PIN	AU7	[get_ports	{	p_a_xmit[0]	}	]
set_property PACKAGE_PIN	AU6	[get_ports	{	n_a_xmit[0]	}	]
set_property PACKAGE_PIN	AT9	[get_ports	{	p_a_xmit[1]	}	]
set_property PACKAGE_PIN	AT8	[get_ports	{	n_a_xmit[1]	}	]
set_property PACKAGE_PIN	AR7	[get_ports	{	p_a_xmit[2]	}	]
set_property PACKAGE_PIN	AR6	[get_ports	{	n_a_xmit[2]	}	]
set_property PACKAGE_PIN	AP9	[get_ports	{	p_a_xmit[3]	}	]
set_property PACKAGE_PIN	AP8	[get_ports	{	n_a_xmit[3]	}	]

# Quad F receivers 
set_property PACKAGE_PIN	U2	[get_ports	{	p_f_recv[0]	}	]
set_property PACKAGE_PIN	U1	[get_ports	{	n_f_recv[0]	}	]
set_property PACKAGE_PIN	T4	[get_ports	{	p_f_recv[1]	}	]
set_property PACKAGE_PIN	T3	[get_ports	{	n_f_recv[1]	}	]
set_property PACKAGE_PIN	R2	[get_ports	{	p_f_recv[2]	}	]
set_property PACKAGE_PIN	R1	[get_ports	{	n_f_recv[2]	}	]
set_property PACKAGE_PIN	P4	[get_ports	{	p_f_recv[3]	}	]
set_property PACKAGE_PIN	P3	[get_ports	{	n_f_recv[3]	}	]

#Quad F transmitters
set_property PACKAGE_PIN	U7	[get_ports	{	p_f_xmit[0]	}	]
set_property PACKAGE_PIN	U6	[get_ports	{	n_f_xmit[0]	}	]
set_property PACKAGE_PIN	T9	[get_ports	{	p_f_xmit[1]	}	]
set_property PACKAGE_PIN	T8	[get_ports	{	n_f_xmit[1]	}	]
set_property PACKAGE_PIN	R7	[get_ports	{	p_f_xmit[2]	}	]
set_property PACKAGE_PIN	R6	[get_ports	{	n_f_xmit[2]	}	]
set_property PACKAGE_PIN	P9	[get_ports	{	p_f_xmit[3]	}	]
set_property PACKAGE_PIN	P8	[get_ports	{	n_f_xmit[3]	}	]
#-----------------------------------------------

#-----------------------------------------------
# GTY transceiver for FPGA-to-FPGA links
# FPGA#1 quad B connects to FPGA#2 quad E
# FPGA#1 quad E connects to FPGA#2 quad B
# Quad B (VU13P=226, VU9P=225)
# Quad E (VU13P=229, VU9P=228)
# On single-FPGA boards with FPGA#2 jumpers, FPGA#1 quad B will also
# connect to the secondary 4-lane FireFly#6
# On single-FPGA boards with FPGA#2 jumpers, FPGA#1 quad E will also
# connect to the secondary 12-lane FireFly#2
# FPGA#1 and FPGA#2 quad B are clocked from quad B (VU13P=226, VU9P=225)
# FPGA#1 and FPGA#2 quad E is clocked from quad E (VU13P=229, VU9P=228)
# 
# Quad B receivers
set_property PACKAGE_PIN	AN2	[get_ports	{	p_b_recv[0]	}	]
set_property PACKAGE_PIN	AN1	[get_ports	{	n_b_recv[0]	}	]
set_property PACKAGE_PIN	AM4	[get_ports	{	p_b_recv[1]	}	]
set_property PACKAGE_PIN	AM3	[get_ports	{	n_b_recv[1]	}	]
set_property PACKAGE_PIN	AL2	[get_ports	{	p_b_recv[2]	}	]
set_property PACKAGE_PIN	AL1	[get_ports	{	n_b_recv[2]	}	]
set_property PACKAGE_PIN	AK4	[get_ports	{	p_b_recv[3]	}	]
set_property PACKAGE_PIN	AK3	[get_ports	{	n_b_recv[3]	}	]

# Quad B transmitters
set_property PACKAGE_PIN	AN7	[get_ports	{	p_b_xmit[0]	}	]
set_property PACKAGE_PIN	AN6	[get_ports	{	n_b_xmit[0]	}	]
set_property PACKAGE_PIN	AM9	[get_ports	{	p_b_xmit[1]	}	]
set_property PACKAGE_PIN	AM8	[get_ports	{	n_b_xmit[1]	}	]
set_property PACKAGE_PIN	AL7	[get_ports	{	p_b_xmit[2]	}	]
set_property PACKAGE_PIN	AL6	[get_ports	{	n_b_xmit[2]	}	]
set_property PACKAGE_PIN	AK9	[get_ports	{	p_b_xmit[3]	}	]
set_property PACKAGE_PIN	AK8	[get_ports	{	n_b_xmit[3]	}	]

# Quad E receivers
set_property PACKAGE_PIN	AA2	[get_ports	{	p_e_recv[0]	}	]
set_property PACKAGE_PIN	AA1	[get_ports	{	n_e_recv[0]	}	]
set_property PACKAGE_PIN	Y4	[get_ports	{	p_e_recv[1]	}	]
set_property PACKAGE_PIN	Y3	[get_ports	{	n_e_recv[1]	}	]
set_property PACKAGE_PIN	W2	[get_ports	{	p_e_recv[2]	}	]
set_property PACKAGE_PIN	W1	[get_ports	{	n_e_recv[2]	}	]
set_property PACKAGE_PIN	V4	[get_ports	{	p_e_recv[3]	}	]
set_property PACKAGE_PIN	V3	[get_ports	{	n_e_recv[3]	}	]

# Quad E transmitters 
set_property PACKAGE_PIN	AA7	[get_ports	{	p_e_xmit[0]	}	]
set_property PACKAGE_PIN	AA6	[get_ports	{	n_e_xmit[0]	}	]
set_property PACKAGE_PIN	Y9	[get_ports	{	p_e_xmit[1]	}	]
set_property PACKAGE_PIN	Y8	[get_ports	{	n_e_xmit[1]	}	]
set_property PACKAGE_PIN	W7	[get_ports	{	p_e_xmit[2]	}	]
set_property PACKAGE_PIN	W6	[get_ports	{	n_e_xmit[2]	}	]
set_property PACKAGE_PIN	V9	[get_ports	{	p_e_xmit[3]	}	]
set_property PACKAGE_PIN	V8	[get_ports	{	n_e_xmit[3]	}	]
#-----------------------------------------------

#-----------------------------------------------
# GTY transceiver for FPGA-to-FPGA links
# FPGA#1 quad C connects to FPGA#2 quad D
# FPGA#1 quad D connects to FPGA#2 quad C
# Quad C (VU13P=227, VU9P=226)
# Quad D (VU13P=228, VU9P=227)
# On single-FPGA boards with FPGA#2 jumpers, FPGA#1 quad C will also
# connect to the secondary 4-lane FireFly#5
# On single-FPGA boards with FPGA#2 jumpers, FPGA#1 quad D will also
# connect to the secondary 12-lane FireFly#2
# FPGA#1 and FPGA#2 quad C are clocked from quad B (VU13P=226, VU9P=225)
# FPGA#1 and FPGA#2 quad D are clocked from quad E (VU13P=229, VU9P=228)
# 
# Quad C receivers
set_property PACKAGE_PIN	AJ2	[get_ports	{	p_c_recv[0]	}	]
set_property PACKAGE_PIN	AJ1	[get_ports	{	n_c_recv[0]	}	]
set_property PACKAGE_PIN	AH4	[get_ports	{	p_c_recv[1]	}	]
set_property PACKAGE_PIN	AH3	[get_ports	{	n_c_recv[1]	}	]
set_property PACKAGE_PIN	AG2	[get_ports	{	p_c_recv[2]	}	]
set_property PACKAGE_PIN	AG1	[get_ports	{	n_c_recv[2]	}	]
set_property PACKAGE_PIN	AF4	[get_ports	{	p_c_recv[3]	}	]
set_property PACKAGE_PIN	AF3	[get_ports	{	n_c_recv[3]	}	]

# Quad C transmitters
set_property PACKAGE_PIN	AJ7	[get_ports	{	p_c_xmit[0]	}	]
set_property PACKAGE_PIN	AJ6	[get_ports	{	n_c_xmit[0]	}	]
set_property PACKAGE_PIN	AH9	[get_ports	{	p_c_xmit[1]	}	]
set_property PACKAGE_PIN	AH8	[get_ports	{	n_c_xmit[1]	}	]
set_property PACKAGE_PIN	AG7	[get_ports	{	p_c_xmit[2]	}	]
set_property PACKAGE_PIN	AG6	[get_ports	{	n_c_xmit[2]	}	]
set_property PACKAGE_PIN	AF9	[get_ports	{	p_c_xmit[3]	}	]
set_property PACKAGE_PIN	AF8	[get_ports	{	n_c_xmit[3]	}	]

# Quad D receivers
set_property PACKAGE_PIN	AE2	[get_ports	{	p_d_recv[0]	}	]
set_property PACKAGE_PIN	AE1	[get_ports	{	n_d_recv[0]	}	]
set_property PACKAGE_PIN	AD4	[get_ports	{	p_d_recv[1]	}	]
set_property PACKAGE_PIN	AD3	[get_ports	{	n_d_recv[1]	}	]
set_property PACKAGE_PIN	AC2	[get_ports	{	p_d_recv[2]	}	]
set_property PACKAGE_PIN	AC1	[get_ports	{	n_d_recv[2]	}	]
set_property PACKAGE_PIN	AB4	[get_ports	{	p_d_recv[3]	}	]
set_property PACKAGE_PIN	AB3	[get_ports	{	n_d_recv[3]	}	]

# Quad D transmitters
set_property PACKAGE_PIN	AE7	[get_ports	{	p_d_xmit[0]	}	]
set_property PACKAGE_PIN	AE6	[get_ports	{	n_d_xmit[0]	}	]
set_property PACKAGE_PIN	AD9	[get_ports	{	p_d_xmit[1]	}	]
set_property PACKAGE_PIN	AD8	[get_ports	{	n_d_xmit[1]	}	]
set_property PACKAGE_PIN	AC7	[get_ports	{	p_d_xmit[2]	}	]
set_property PACKAGE_PIN	AC6	[get_ports	{	n_d_xmit[2]	}	]
set_property PACKAGE_PIN	AB9	[get_ports	{	p_d_xmit[3]	}	]
set_property PACKAGE_PIN	AB8	[get_ports	{	n_d_xmit[3]	}	]
#-----------------------------------------------

#-----------------------------------------------
# GTY transceiver for FPGA-to-FPGA links
# FPGA#1 quad G connects to FPGA#2 quad P
# FPGA#1 quad P and FPGA#2 quad G are not used
# Quad G (VU13P=231, VU9P=230)
# Quad P (VU13P=224, VU9P=223)
# On single-FPGA boards with FPGA#2 jumpers, FPGA#1 quad G will also
# connect to the secondary 4-lane FireFly#4
# FPGA#1 quad G clocked from quad G (VU13P=231, VU9P=230)
# FPGA#2 quad P is clocked from quad P (VU13P=224, VU9P=223)
# 
# Quad G receivers
set_property PACKAGE_PIN	N2	[get_ports	{	p_g_recv[0]	}	]
set_property PACKAGE_PIN	N1	[get_ports	{	n_g_recv[0]	}	]
set_property PACKAGE_PIN	M4	[get_ports	{	p_g_recv[1]	}	]
set_property PACKAGE_PIN	M3	[get_ports	{	n_g_recv[1]	}	]
set_property PACKAGE_PIN	L2	[get_ports	{	p_g_recv[2]	}	]
set_property PACKAGE_PIN	L1	[get_ports	{	n_g_recv[2]	}	]
set_property PACKAGE_PIN	K4	[get_ports	{	p_g_recv[3]	}	]
set_property PACKAGE_PIN	K3	[get_ports	{	n_g_recv[3]	}	]

# Quad G transmitters
set_property PACKAGE_PIN	N7	[get_ports	{	p_g_xmit[0]	}	]
set_property PACKAGE_PIN	N6	[get_ports	{	n_g_xmit[0]	}	]
set_property PACKAGE_PIN	M9	[get_ports	{	p_g_xmit[1]	}	]
set_property PACKAGE_PIN	M8	[get_ports	{	n_g_xmit[1]	}	]
set_property PACKAGE_PIN	L7	[get_ports	{	p_g_xmit[2]	}	]
set_property PACKAGE_PIN	L6	[get_ports	{	n_g_xmit[2]	}	]
set_property PACKAGE_PIN	K9	[get_ports	{	p_g_xmit[3]	}	]
set_property PACKAGE_PIN	K8	[get_ports	{	n_g_xmit[3]	}	]

# Quad P receivers
set_property PACKAGE_PIN	BA2	[get_ports	{	p_p_recv[0]	}	]
set_property PACKAGE_PIN	BA1	[get_ports	{	n_p_recv[0]	}	]
set_property PACKAGE_PIN	AY4	[get_ports	{	p_p_recv[1]	}	]
set_property PACKAGE_PIN	AY3	[get_ports	{	n_p_recv[1]	}	]
set_property PACKAGE_PIN	AW2	[get_ports	{	p_p_recv[2]	}	]
set_property PACKAGE_PIN	AW1	[get_ports	{	n_p_recv[2]	}	]
set_property PACKAGE_PIN	AV4	[get_ports	{	p_p_recv[3]	}	]
set_property PACKAGE_PIN	AV3	[get_ports	{	n_p_recv[3]	}	]

# Quad P transmitters
set_property PACKAGE_PIN	BA7	[get_ports	{	p_p_xmit[0]	}	]
set_property PACKAGE_PIN	BA6	[get_ports	{	n_p_xmit[0]	}	]
set_property PACKAGE_PIN	AY9	[get_ports	{	p_p_xmit[1]	}	]
set_property PACKAGE_PIN	AY8	[get_ports	{	n_p_xmit[1]	}	]
set_property PACKAGE_PIN	AW7	[get_ports	{	p_p_xmit[2]	}	]
set_property PACKAGE_PIN	AW6	[get_ports	{	n_p_xmit[2]	}	]
set_property PACKAGE_PIN	AV9	[get_ports	{	p_p_xmit[3]	}	]
set_property PACKAGE_PIN	AV8	[get_ports	{	n_p_xmit[3]	}	]
#-----------------------------------------------

#-----------------------------------------------
# GTY transceiver for FPGA-to-FPGA links
# FPGA#1 quad H connects to FPGA#2 quad O
# FPGA#1 quad O connects to FPGA#2 quad H
# Quad H (VU13P=232, VU9P=231)
# Quad O (VU13P=223, VU9P=222)
# On single-FPGA boards with FPGA#2 jumpers, FPGA#1 quad H will also
# connect to the secondary 12-lane FireFly#1
# On single-FPGA boards with FPGA#2 jumpers, FPGA#1 quad O will also
# connect to the secondary 12-lane FireFly#3
# FPGA#1 and FPGA#2 quad H are clocked from quad I (VU13P=233, VU9P=232)
# FPGA#1 and FPGA#2 quad O are clocked from quad N (VU13P=222, VU9P=221)
# 
# Quad H receivers
set_property PACKAGE_PIN	J2	[get_ports	{	p_h_recv[0]	}	]
set_property PACKAGE_PIN	J1	[get_ports	{	n_h_recv[0]	}	]
set_property PACKAGE_PIN	H4	[get_ports	{	p_h_recv[1]	}	]
set_property PACKAGE_PIN	H3	[get_ports	{	n_h_recv[1]	}	]
set_property PACKAGE_PIN	G2	[get_ports	{	p_h_recv[2]	}	]
set_property PACKAGE_PIN	G1	[get_ports	{	n_h_recv[2]	}	]
set_property PACKAGE_PIN	F4	[get_ports	{	p_h_recv[3]	}	]
set_property PACKAGE_PIN	F3	[get_ports	{	n_h_recv[3]	}	]

# Quad H transmitters
set_property PACKAGE_PIN	J7	[get_ports	{	p_h_xmit[0]	}	]
set_property PACKAGE_PIN	J6	[get_ports	{	n_h_xmit[0]	}	]
set_property PACKAGE_PIN	H9	[get_ports	{	p_h_xmit[1]	}	]
set_property PACKAGE_PIN	H8	[get_ports	{	n_h_xmit[1]	}	]
set_property PACKAGE_PIN	G7	[get_ports	{	p_h_xmit[2]	}	]
set_property PACKAGE_PIN	G6	[get_ports	{	n_h_xmit[2]	}	]
set_property PACKAGE_PIN	F9	[get_ports	{	p_h_xmit[3]	}	]
set_property PACKAGE_PIN	F8	[get_ports	{	n_h_xmit[3]	}	]

# Quad O receivers
set_property PACKAGE_PIN	BE2	[get_ports	{	p_o_recv[0]	}	]
set_property PACKAGE_PIN	BE1	[get_ports	{	n_o_recv[0]	}	]
set_property PACKAGE_PIN	BD4	[get_ports	{	p_o_recv[1]	}	]
set_property PACKAGE_PIN	BD3	[get_ports	{	n_o_recv[1]	}	]
set_property PACKAGE_PIN	BC2	[get_ports	{	p_o_recv[2]	}	]
set_property PACKAGE_PIN	BC1	[get_ports	{	n_o_recv[2]	}	]
set_property PACKAGE_PIN	BB4	[get_ports	{	p_o_recv[3]	}	]
set_property PACKAGE_PIN	BB3	[get_ports	{	n_o_recv[3]	}	]

# Quad O transmitters
set_property PACKAGE_PIN	BE7	[get_ports	{	p_o_xmit[0]	}	]
set_property PACKAGE_PIN	BE6	[get_ports	{	n_o_xmit[0]	}	]
set_property PACKAGE_PIN	BD9	[get_ports	{	p_o_xmit[1]	}	]
set_property PACKAGE_PIN	BD8	[get_ports	{	n_o_xmit[1]	}	]
set_property PACKAGE_PIN	BC7	[get_ports	{	p_o_xmit[2]	}	]
set_property PACKAGE_PIN	BC6	[get_ports	{	n_o_xmit[2]	}	]
set_property PACKAGE_PIN	BB9	[get_ports	{	p_o_xmit[3]	}	]
set_property PACKAGE_PIN	BB8	[get_ports	{	n_o_xmit[3]	}	]
#-----------------------------------------------

#-----------------------------------------------
# GTY transceiver for FPGA-to-FPGA links
# FPGA#1 quad I connects to FPGA#2 quad N
# FPGA#1 quad N connects to FPGA#2 quad I
# Quad I (VU13P=233, VU9P=232)
# Quad N (VU13P=222, VU9P=221)
# On single-FPGA boards with FPGA#2 jumpers, FPGA#1 quad I will also
# connect to the secondary 12-lane FireFly#1
# On single-FPGA boards with FPGA#2 jumpers, FPGA#1 quad N will also
# connect to the secondary 12-lane FireFly#3
# FPGA#1 and FPGA#2 quad I are clocked from quad I (VU13P=233, VU9P=232)
# FPGA#1 and FPGA#2 quad N are clocked from quad N (VU13P=222, VU9P=221)
# 
# Quad I receivers
set_property PACKAGE_PIN	E2	[get_ports	{	p_i_recv[0]	}	]
set_property PACKAGE_PIN	E1	[get_ports	{	n_i_recv[0]	}	]
set_property PACKAGE_PIN	D4	[get_ports	{	p_i_recv[1]	}	]
set_property PACKAGE_PIN	D3	[get_ports	{	n_i_recv[1]	}	]
set_property PACKAGE_PIN	E6	[get_ports	{	p_i_recv[2]	}	]
set_property PACKAGE_PIN	E5	[get_ports	{	n_i_recv[2]	}	]
set_property PACKAGE_PIN	C6	[get_ports	{	p_i_recv[3]	}	]
set_property PACKAGE_PIN	C5	[get_ports	{	n_i_recv[3]	}	]

# Quad I transmitters
set_property PACKAGE_PIN	D9	[get_ports	{	p_i_xmit[0]	}	]
set_property PACKAGE_PIN	D8	[get_ports	{	n_i_xmit[0]	}	]
set_property PACKAGE_PIN	B9	[get_ports	{	p_i_xmit[1]	}	]
set_property PACKAGE_PIN	B8	[get_ports	{	n_i_xmit[1]	}	]
set_property PACKAGE_PIN	C11	[get_ports	{	p_i_xmit[2]	}	]
set_property PACKAGE_PIN	C10	[get_ports	{	n_i_xmit[2]	}	]
set_property PACKAGE_PIN	E11	[get_ports	{	p_i_xmit[3]	}	]
set_property PACKAGE_PIN	E10	[get_ports	{	n_i_xmit[3]	}	]

# Quad N receivers
set_property PACKAGE_PIN	BH4	[get_ports	{	p_n_recv[0]	}	]
set_property PACKAGE_PIN	BH3	[get_ports	{	n_n_recv[0]	}	]
set_property PACKAGE_PIN	BG2	[get_ports	{	p_n_recv[1]	}	]
set_property PACKAGE_PIN	BG1	[get_ports	{	n_n_recv[1]	}	]
set_property PACKAGE_PIN	BG6	[get_ports	{	p_n_recv[2]	}	]
set_property PACKAGE_PIN	BG5	[get_ports	{	n_n_recv[2]	}	]
set_property PACKAGE_PIN	BF4	[get_ports	{	p_n_recv[3]	}	]
set_property PACKAGE_PIN	BF3	[get_ports	{	n_n_recv[3]	}	]

# Quad N transmitters
set_property PACKAGE_PIN	BG11	[get_ports	{	p_n_xmit[0]	}	]
set_property PACKAGE_PIN	BG10	[get_ports	{	n_n_xmit[0]	}	]
set_property PACKAGE_PIN	BJ11	[get_ports	{	p_n_xmit[1]	}	]
set_property PACKAGE_PIN	BJ10	[get_ports	{	n_n_xmit[1]	}	]
set_property PACKAGE_PIN	BH9	[get_ports	{	p_n_xmit[2]	}	]
set_property PACKAGE_PIN	BH8	[get_ports	{	n_n_xmit[2]	}	]
set_property PACKAGE_PIN	BF9	[get_ports	{	p_n_xmit[3]	}	]
set_property PACKAGE_PIN	BF8	[get_ports	{	n_n_xmit[3]	}	]
#-----------------------------------------------

#-----------------------------------------------
# GTY transceiver for FPGA-to-FPGA links
# FPGA#1 quad J connects to FPGA#2 quad M
# FPGA#1 quad M connects to FPGA#2 quad J
# Quad J (VU13P=234, VU9P=233)
# Quad M (VU13P=221, VU9P=220)
# On single-FPGA boards with FPGA#2 jumpers, FPGA#1 quad J will also
# connect to the secondary 12-lane FireFly#1
# On single-FPGA boards with FPGA#2 jumpers, FPGA#1 quad M will also
# connect to the secondary 12-lane FireFly#3
# FPGA#1 and FPGA#2 quad J are clocked from quad I (VU13P=233, VU9P=232)
# FPGA#1 and FPGA#2 quad M are clocked from quad N (VU13P=222, VU9P=221)
# 
# Quad J receivers
set_property PACKAGE_PIN	A6	[get_ports	{	p_j_recv[0]	}	]
set_property PACKAGE_PIN	A5	[get_ports	{	n_j_recv[0]	}	]
set_property PACKAGE_PIN	A20	[get_ports	{	p_j_recv[1]	}	]
set_property PACKAGE_PIN	A19	[get_ports	{	n_j_recv[1]	}	]
set_property PACKAGE_PIN	B18	[get_ports	{	p_j_recv[2]	}	]
set_property PACKAGE_PIN	B17	[get_ports	{	n_j_recv[2]	}	]
set_property PACKAGE_PIN	C20	[get_ports	{	p_j_recv[3]	}	]
set_property PACKAGE_PIN	C19	[get_ports	{	n_j_recv[3]	}	]

# Quad J transmitters
set_property PACKAGE_PIN	A11	[get_ports	{	p_j_xmit[0]	}	]
set_property PACKAGE_PIN	A10	[get_ports	{	n_j_xmit[0]	}	]
set_property PACKAGE_PIN	B13	[get_ports	{	p_j_xmit[1]	}	]
set_property PACKAGE_PIN	B12	[get_ports	{	n_j_xmit[1]	}	]
set_property PACKAGE_PIN	A15	[get_ports	{	p_j_xmit[2]	}	]
set_property PACKAGE_PIN	A14	[get_ports	{	n_j_xmit[2]	}	]
set_property PACKAGE_PIN	C15	[get_ports	{	p_j_xmit[3]	}	]
set_property PACKAGE_PIN	C14	[get_ports	{	n_j_xmit[3]	}	]

# Quad M receivers
set_property PACKAGE_PIN	BK18	[get_ports	{	p_m_recv[0]	}	]
set_property PACKAGE_PIN	BK17	[get_ports	{	n_m_recv[0]	}	]
set_property PACKAGE_PIN	BL20	[get_ports	{	p_m_recv[1]	}	]
set_property PACKAGE_PIN	BL19	[get_ports	{	n_m_recv[1]	}	]
set_property PACKAGE_PIN	BL6	[get_ports	{	p_m_recv[2]	}	]
set_property PACKAGE_PIN	BL5	[get_ports	{	n_m_recv[2]	}	]
set_property PACKAGE_PIN	BJ6	[get_ports	{	p_m_recv[3]	}	]
set_property PACKAGE_PIN	BJ5	[get_ports	{	n_m_recv[3]	}	]

# Quad M transmitters
set_property PACKAGE_PIN	BL15	[get_ports	{	p_m_xmit[0]	}	]
set_property PACKAGE_PIN	BL14	[get_ports	{	n_m_xmit[0]	}	]
set_property PACKAGE_PIN	BK13	[get_ports	{	p_m_xmit[1]	}	]
set_property PACKAGE_PIN	BK12	[get_ports	{	n_m_xmit[1]	}	]
set_property PACKAGE_PIN	BL11	[get_ports	{	p_m_xmit[2]	}	]
set_property PACKAGE_PIN	BL10	[get_ports	{	n_m_xmit[2]	}	]
set_property PACKAGE_PIN	BK9	[get_ports	{	p_m_xmit[3]	}	]
set_property PACKAGE_PIN	BK8	[get_ports	{	n_m_xmit[3]	}	]
#-----------------------------------------------


#-----------------------------------------------
# Front panel HDMI-sytle test connector
# 'test_conn_0' connects to global clock-capable input pins
set_property IOSTANDARD LVDS   [get_ports p_test_conn*]
set_property IOSTANDARD LVDS   [get_ports n_test_conn*]
# Enable the DIFF_TERM_ADV property for any ports used as inputs
#set_property DIFF_TERM_ADV TERM_100 [get_ports p_test_conn*]
#set_property DIFF_TERM_ADV TERM_100 [get_ports n_test_conn*]
set_property PACKAGE_PIN	BD28	[get_ports		p_test_conn_0		]
set_property PACKAGE_PIN	BE28	[get_ports		n_test_conn_0		]
set_property PACKAGE_PIN	AW31	[get_ports		p_test_conn_1		]
set_property PACKAGE_PIN	AY31	[get_ports		n_test_conn_1		]
set_property PACKAGE_PIN	AV29	[get_ports		p_test_conn_2		]
set_property PACKAGE_PIN	AW29	[get_ports		n_test_conn_2		]
set_property PACKAGE_PIN	AU31	[get_ports		p_test_conn_3		]
set_property PACKAGE_PIN	AV31	[get_ports		n_test_conn_3		]
set_property PACKAGE_PIN	AY30	[get_ports		p_test_conn_4		]
set_property PACKAGE_PIN	BA30	[get_ports		n_test_conn_4		]

set_property IOSTANDARD LVCMOS18 [get_ports test_conn_5]
set_property IOSTANDARD LVCMOS18 [get_ports test_conn_6]
set_property PACKAGE_PIN	BA29	[get_ports		test_conn_5		]
set_property PACKAGE_PIN	BA28	[get_ports		test_conn_6		]
#-----------------------------------------------


#-----------------------------------------------
# Spare input signals from the "other" FPGA.
# These cross-connect to the spare output signals on the other FPGA
# 'in_spare[2]' is connected to global glock-capable input pins
set_property IOSTANDARD LVDS   [get_ports *_in_spare*]
set_property DIFF_TERM_ADV TERM_100 [get_ports *_in_spare*]
set_property PACKAGE_PIN	E30	[get_ports	{	p_in_spare[0]	}	]
set_property PACKAGE_PIN	D30	[get_ports	{	n_in_spare[0]	}	]
set_property PACKAGE_PIN	D28	[get_ports	{	p_in_spare[1]	}	]
set_property PACKAGE_PIN	D29	[get_ports	{	n_in_spare[1]	}	]
set_property PACKAGE_PIN	C29	[get_ports	{	p_in_spare[2]	}	]
set_property PACKAGE_PIN	C30	[get_ports	{	n_in_spare[2]	}	]
#-----------------------------------------------

#-----------------------------------------------
# Spare output signals to the "other" FPGA.
# These cross-connect to the spare input signals on the other FPGA
set_property IOSTANDARD LVDS   [get_ports *_out_spare*]
set_property PACKAGE_PIN	BG29	[get_ports	{	p_out_spare[0]	}	]
set_property PACKAGE_PIN	BH29	[get_ports	{	n_out_spare[0]	}	]
set_property PACKAGE_PIN	BF29	[get_ports	{	p_out_spare[1]	}	]
set_property PACKAGE_PIN	BG30	[get_ports	{	n_out_spare[1]	}	]
set_property PACKAGE_PIN	BG26	[get_ports	{	p_out_spare[2]	}	]
set_property PACKAGE_PIN	BG27	[get_ports	{	n_out_spare[2]	}	]
#-----------------------------------------------

#-----------------------------------------------
# Spare pins to 1mm x 1mm headers on the bottom of the board
# They could be used in an emergency as I/Os, or for debugging
# hdr1 and hdr2 are on global clock-capable pins
set_property IOSTANDARD LVDS   [get_ports hdr1]
set_property IOSTANDARD LVDS   [get_ports hdr2]
set_property IOSTANDARD LVCMOS18   [get_ports hdr3]
set_property IOSTANDARD LVCMOS18   [get_ports hdr4]
set_property IOSTANDARD LVCMOS18   [get_ports hdr5]
set_property IOSTANDARD LVCMOS18   [get_ports hdr6]
set_property IOSTANDARD LVCMOS18   [get_ports hdr7]
set_property IOSTANDARD LVCMOS18   [get_ports hdr8]
set_property IOSTANDARD LVCMOS18   [get_ports hdr9]
set_property IOSTANDARD LVCMOS18   [get_ports hdr10]
set_property PACKAGE_PIN  L28 [get_ports  hdr1 ]
set_property PACKAGE_PIN  L29 [get_ports  hdr2 ]
set_property PACKAGE_PIN  C26 [get_ports  hdr3 ]
set_property PACKAGE_PIN  B26 [get_ports  hdr4 ]
set_property PACKAGE_PIN  A25 [get_ports  hdr5 ]
set_property PACKAGE_PIN  B25 [get_ports  hdr6 ]
set_property PACKAGE_PIN  A24 [get_ports  hdr7 ]
set_property PACKAGE_PIN  B24 [get_ports  hdr8 ]
set_property PACKAGE_PIN  A23 [get_ports  hdr9 ]
set_property PACKAGE_PIN  A22 [get_ports  hdr10 ]

#-----------------------------------------------

