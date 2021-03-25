# File: top_pins.xdc
# Auth: Dan Gastler, Boston University Physics
# Mod.: M. Fras, Electronics Division, MPI for Physics, Munich
# Date: 18 Dec 2020
# Rev.: 25 Mar 2021
#
# KU15P pin constraint file for the MPI Command Module (CM) demonstrator.
#
# Port prefixes:
# i_    Input port.
# o_    Output port.
# io_   Bi-directional port.
#
# Differential pair names end with '_p' or '_n'.
#
# Except for clock inputs, signals that can be bused together use bracketed,
# numbered suffixes.

# -------------------------------------------------------------------
# Important! Do not remove this constraint!
# This property ensures that all unused pins are set to high impedance.
# If the constraint is removed, all unused pins have to be set to HiZ in the top level file.
set_property BITSTREAM.CONFIG.UNUSEDPIN PULLNONE [ current_design ];
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Turn off on over-temperature.
#set_property BITSTREAM.CONFIG.OVERTEMPPOWERDOWN ENABLE [ current_design ];
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Set internal reference voltages to 0.90 on banks with I/O signals.
# This is required for the HSTL and DIFF_HSTL I/O standards
#set_property INTERNAL_VREF 0.90 [ get_iobanks 66 ];
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Clock pins.

# 100 MHz system clock from crystal oscillator, bank 66.
set_property IOSTANDARD LVDS [ get_ports i_clk_100_* ];
set_property DIFF_TERM_ADV TERM_100 [ get_ports i_clk_100_* ];
set_property PACKAGE_PIN  AY16  [ get_ports { i_clk_100_p } ];          # KUP_100MHZ_AC_P
set_property PACKAGE_PIN  AY15  [ get_ports { i_clk_100_n } ];          # KUP_100MHZ_AC_N

# Clock from clock generator IC54 (SI5341A).
set_property IOSTANDARD LVDS [ get_ports i_clk_gen_* ];
set_property DIFF_TERM_ADV TERM_100 [ get_ports i_clk_gen_* ];
set_property PACKAGE_PIN  AP29  [ get_ports { i_clk_gen_p } ];          # KUP_CLK_GEN_AC_P
set_property PACKAGE_PIN  AP30  [ get_ports { i_clk_gen_n } ];          # KUP_CLK_GEN_AC_N

# LHC clock from jitter cleaner IC56 (Si5345A).
set_property IOSTANDARD LVDS [ get_ports i_clk_lhc_* ];
set_property DIFF_TERM_ADV TERM_100 [ get_ports i_clk_lhc_* ];
set_property PACKAGE_PIN  AT24  [ get_ports { i_clk_lhc_p } ];          # LHC_REF7_AC_P
set_property PACKAGE_PIN  AU24  [ get_ports { i_clk_lhc_n } ];          # LHC_REF7_AC_N

# Recovered LHC clock from clock and data recovery chip IC46 (ADN2814ACPZ).
set_property IOSTANDARD LVDS [ get_ports i_clk_legacy_ttc_* ];
set_property DIFF_TERM_ADV TERM_100 [ get_ports i_clk_legacy_ttc_* ];
set_property PACKAGE_PIN  AV24  [ get_ports { i_clk_legacy_ttc_p } ];   # KUP_TTC_CLK_AC_P
set_property PACKAGE_PIN  AV25  [ get_ports { i_clk_legacy_ttc_n } ];   # KUP_TTC_CLK_AC_N

# Clock from SMA connectors X76 and X78, directly connected.
set_property IOSTANDARD LVDS [ get_ports i_clk_sma_direct_* ];
set_property DIFF_TERM_ADV TERM_100 [ get_ports i_clk_sma_direct_* ];
set_property PACKAGE_PIN  AT25  [ get_ports { i_clk_sma_direct_p } ];   # SMA_KUP_DIRECT_AC_P
set_property PACKAGE_PIN  AT26  [ get_ports { i_clk_sma_direct_n } ];   # SMA_KUP_DIRECT_AC_N

# Clock from SMA connectors X68 and X69, fed through jitter cleaner IC65.
set_property IOSTANDARD LVDS [ get_ports i_clk_sma_jc_* ];
set_property DIFF_TERM_ADV TERM_100 [ get_ports i_clk_sma_jc_* ];
set_property PACKAGE_PIN  AR25  [ get_ports { i_clk_sma_jc_p } ];       # AD_CLK0_JC_KUP_AC_P
set_property PACKAGE_PIN  AR26  [ get_ports { i_clk_sma_jc_n } ];       # AD_CLK0_JC_KUP_AC_N

# Output for recovered LHC clock, fed into jitter cleaner IC56 (Si5345A).
set_property IOSTANDARD LVDS [ get_ports o_clk_lhc_* ];
set_property PACKAGE_PIN  AT23  [ get_ports { o_clk_lhc_p } ];          # KUP_LHC_CLK_P
set_property PACKAGE_PIN  AU23  [ get_ports { o_clk_lhc_n } ];          # KUP_LHC_CLK_N
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Legacy TTC recovered data from clock and data recovery chip IC46 (ADN2814ACPZ), bank 65.

set_property IOSTANDARD LVDS [ get_ports i_legacy_ttc_data_* ];
set_property DIFF_TERM_ADV TERM_100 [ get_ports i_legacy_ttc_data_* ];
set_property PACKAGE_PIN  AU26  [ get_ports { i_legacy_ttc_data_p } ];  # KUP_TTC_DAT_AC_P
set_property PACKAGE_PIN  AU27  [ get_ports { i_legacy_ttc_data_n } ];  # KUP_TTC_DAT_AC_N
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# GTH AXI Chip2Chip transceiver clock.

# Quad A (224)
set_property PACKAGE_PIN  AK10  [ get_ports { i_refclk_axi_c2c_p } ];   # B2B_REF0_AC_P
set_property PACKAGE_PIN  AK9   [ get_ports { i_refclk_axi_c2c_n } ];   # B2B_REF0_AC_N
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# GTH AXI Chip2Chip links to the SM SoC.

# Quad A (224)
set_property PACKAGE_PIN  BB6   [ get_ports { i_mgt_axi_c2c_p[1] } ];   # KUP_B2B_TX_P_0
set_property PACKAGE_PIN  BB5   [ get_ports { i_mgt_axi_c2c_n[1] } ];   # KUP_B2B_TX_N_0
set_property PACKAGE_PIN  BA4   [ get_ports { i_mgt_axi_c2c_p[2] } ];   # KUP_B2B_TX_P_1
set_property PACKAGE_PIN  BA3   [ get_ports { i_mgt_axi_c2c_n[2] } ];   # KUP_B2B_TX_N_1

set_property PACKAGE_PIN  AW8   [ get_ports { o_mgt_axi_c2c_p[1] } ];   # KUP_B2B_RX_P_0
set_property PACKAGE_PIN  AW7   [ get_ports { o_mgt_axi_c2c_n[1] } ];   # KUP_B2B_RX_N_0
set_property PACKAGE_PIN  AV10  [ get_ports { o_mgt_axi_c2c_p[2] } ];   # KUP_B2B_RX_P_1
set_property PACKAGE_PIN  AV9   [ get_ports { o_mgt_axi_c2c_n[2] } ];   # KUP_B2B_RX_N_1
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# GTH ports.

# Do *not* add IO buffers on GTH TX ports.
set_property IO_BUFFER_TYPE NONE [ get_ports o_gth_tx_* ];

# MGT bank 224.
# Hint: The first 2 transceivers (on MGT bank 224) are used for SM SoC AXI
#       Chip2Chip. It utilizes refclk1[0]. The corresponding IO pins are
#       defined in the SM SoC AXI Chip2Chip section.
set_property PACKAGE_PIN  AL12  [ get_ports { i_gth_refclk0_p[0] } ];   # AD_CLK2_KUP_AC_P
set_property PACKAGE_PIN  AL11  [ get_ports { i_gth_refclk0_n[0] } ];   # AD_CLK2_KUP_AC_N
#set_property PACKAGE_PIN  AK10  [ get_ports { i_gth_refclk1_p[0] } ];   # B2B_REF0_AC_P
#set_property PACKAGE_PIN  AK9   [ get_ports { i_gth_refclk1_n[0] } ];   # B2B_REF0_AC_N
#set_property PACKAGE_PIN  BB6   [ get_ports { i_gth_rx_p[0] } ];        # KUP_B2B_TX_P_0
#set_property PACKAGE_PIN  BB5   [ get_ports { i_gth_rx_n[0] } ];        # KUP_B2B_TX_N_0
#set_property PACKAGE_PIN  AW8   [ get_ports { o_gth_tx_p[0] } ];        # KUP_B2B_RX_P_0
#set_property PACKAGE_PIN  AW7   [ get_ports { o_gth_tx_n[0] } ];        # KUP_B2B_RX_N_0
#set_property PACKAGE_PIN  BA4   [ get_ports { i_gth_rx_p[1] } ];        # KUP_B2B_TX_P_1
#set_property PACKAGE_PIN  BA3   [ get_ports { i_gth_rx_n[1] } ];        # KUP_B2B_TX_N_1
#set_property PACKAGE_PIN  AV10  [ get_ports { o_gth_tx_p[1] } ];        # KUP_B2B_RX_P_1
#set_property PACKAGE_PIN  AV9   [ get_ports { o_gth_tx_n[1] } ];        # KUP_B2B_RX_N_1
set_property PACKAGE_PIN  AY6   [ get_ports { i_gth_rx_p[2] } ];        # C2C_ZUP_2_KUP_AC_P_4
set_property PACKAGE_PIN  AY5   [ get_ports { i_gth_rx_n[2] } ];        # C2C_ZUP_2_KUP_AC_N_4
set_property PACKAGE_PIN  AV6   [ get_ports { o_gth_tx_p[2] } ];        # C2C_KUP_2_ZUP_P_4
set_property PACKAGE_PIN  AV5   [ get_ports { o_gth_tx_n[2] } ];        # C2C_KUP_2_ZUP_N_4
set_property PACKAGE_PIN  AY2   [ get_ports { i_gth_rx_p[3] } ];        # C2C_ZUP_2_KUP_AC_P_5
set_property PACKAGE_PIN  AY1   [ get_ports { i_gth_rx_n[3] } ];        # C2C_ZUP_2_KUP_AC_N_5
set_property PACKAGE_PIN  AU8   [ get_ports { o_gth_tx_p[3] } ];        # C2C_KUP_2_ZUP_P_5
set_property PACKAGE_PIN  AU7   [ get_ports { o_gth_tx_n[3] } ];        # C2C_KUP_2_ZUP_N_5

# MGT bank 225.
set_property PACKAGE_PIN  AJ12  [ get_ports { i_gth_refclk0_p[1] } ];   # AD_CLK3_KUP_AC_P
set_property PACKAGE_PIN  AJ11  [ get_ports { i_gth_refclk0_n[1] } ];   # AD_CLK3_KUP_AC_N
set_property PACKAGE_PIN  AH10  [ get_ports { i_gth_refclk1_p[1] } ];   # C2C_REF2_AC_P
set_property PACKAGE_PIN  AH9   [ get_ports { i_gth_refclk1_n[1] } ];   # C2C_REF2_AC_N
set_property PACKAGE_PIN  AW4   [ get_ports { i_gth_rx_p[4] } ];        # C2C_ZUP_2_KUP_AC_P
set_property PACKAGE_PIN  AW3   [ get_ports { i_gth_rx_n[4] } ];        # C2C_ZUP_2_KUP_AC_N
set_property PACKAGE_PIN  AT10  [ get_ports { o_gth_tx_p[4] } ];        # C2C_KUP_2_ZUP_P
set_property PACKAGE_PIN  AT9   [ get_ports { o_gth_tx_n[4] } ];        # C2C_KUP_2_ZUP_N
set_property PACKAGE_PIN  AV2   [ get_ports { i_gth_rx_p[5] } ];        # LEGACY_TTC_RX_P
set_property PACKAGE_PIN  AV1   [ get_ports { i_gth_rx_n[5] } ];        # LEGACY_TTC_RX_N
set_property PACKAGE_PIN  AT6   [ get_ports { o_gth_tx_p[5] } ];        # LEGACY_TTC_TX_P
set_property PACKAGE_PIN  AT5   [ get_ports { o_gth_tx_n[5] } ];        # LEGACY_TTC_TX_N
set_property PACKAGE_PIN  AU4   [ get_ports { i_gth_rx_p[6] } ];        # KUP_MGTH_RX_SPARE_P_0
set_property PACKAGE_PIN  AU3   [ get_ports { i_gth_rx_n[6] } ];        # KUP_MGTH_RX_SPARE_N_0
set_property PACKAGE_PIN  AR8   [ get_ports { o_gth_tx_p[6] } ];        # KUP_MGTH_TX_SPARE_P_0
set_property PACKAGE_PIN  AR7   [ get_ports { o_gth_tx_n[6] } ];        # KUP_MGTH_TX_SPARE_N_0
set_property PACKAGE_PIN  AT2   [ get_ports { i_gth_rx_p[7] } ];        # KUP_MGTH_RX_SPARE_P_1
set_property PACKAGE_PIN  AT1   [ get_ports { i_gth_rx_n[7] } ];        # KUP_MGTH_RX_SPARE_N_1
set_property PACKAGE_PIN  AP10  [ get_ports { o_gth_tx_p[7] } ];        # KUP_MGTH_TX_SPARE_P_1
set_property PACKAGE_PIN  AP9   [ get_ports { o_gth_tx_n[7] } ];        # KUP_MGTH_TX_SPARE_N_1

# MGT bank 226.
set_property PACKAGE_PIN  AG12  [ get_ports { i_gth_refclk0_p[2] } ];   # FE_REF0_AC_P
set_property PACKAGE_PIN  AG11  [ get_ports { i_gth_refclk0_n[2] } ];   # FE_REF0_AC_N
set_property PACKAGE_PIN  AF10  [ get_ports { i_gth_refclk1_p[2] } ];   # open
set_property PACKAGE_PIN  AF9   [ get_ports { i_gth_refclk1_n[2] } ];   # open
set_property PACKAGE_PIN  AR4   [ get_ports { i_gth_rx_p[8]  } ];       # BM0_FF3_RX_P_0
set_property PACKAGE_PIN  AR3   [ get_ports { i_gth_rx_n[8]  } ];       # BM0_FF3_RX_N_0
set_property PACKAGE_PIN  AP6   [ get_ports { o_gth_tx_p[8]  } ];       # BM0_FF3_TX_P_0
set_property PACKAGE_PIN  AP5   [ get_ports { o_gth_tx_n[8]  } ];       # BM0_FF3_TX_N_0
set_property PACKAGE_PIN  AP2   [ get_ports { i_gth_rx_p[9]  } ];       # BM1_FF3_RX_P_1
set_property PACKAGE_PIN  AP1   [ get_ports { i_gth_rx_n[9]  } ];       # BM1_FF3_RX_N_1
set_property PACKAGE_PIN  AN8   [ get_ports { o_gth_tx_p[9]  } ];       # FF3_TX_P_1
set_property PACKAGE_PIN  AN7   [ get_ports { o_gth_tx_n[9]  } ];       # FF3_TX_N_1
set_property PACKAGE_PIN  AN4   [ get_ports { i_gth_rx_p[10] } ];       # BM2_FF3_RX_P_2
set_property PACKAGE_PIN  AN3   [ get_ports { i_gth_rx_n[10] } ];       # BM2_FF3_RX_N_2
set_property PACKAGE_PIN  AM10  [ get_ports { o_gth_tx_p[10] } ];       # BM2_FF3_TX_P_2
set_property PACKAGE_PIN  AM9   [ get_ports { o_gth_tx_n[10] } ];       # BM2_FF3_TX_N_2
set_property PACKAGE_PIN  AM2   [ get_ports { i_gth_rx_p[11] } ];       # BM3_FF3_RX_P_3
set_property PACKAGE_PIN  AM1   [ get_ports { i_gth_rx_n[11] } ];       # BM3_FF3_RX_N_3
set_property PACKAGE_PIN  AM6   [ get_ports { o_gth_tx_p[11] } ];       # FF3_TX_P_3
set_property PACKAGE_PIN  AM5   [ get_ports { o_gth_tx_n[11] } ];       # FF3_TX_N_3

# MGT bank 227.
set_property PACKAGE_PIN  AE12  [ get_ports { i_gth_refclk0_p[3] } ];   # FE_REF1_AC_P
set_property PACKAGE_PIN  AE11  [ get_ports { i_gth_refclk0_n[3] } ];   # FE_REF1_AC_N
set_property PACKAGE_PIN  AD10  [ get_ports { i_gth_refclk1_p[3] } ];   # open
set_property PACKAGE_PIN  AD9   [ get_ports { i_gth_refclk1_n[3] } ];   # open
set_property PACKAGE_PIN  AL4   [ get_ports { i_gth_rx_p[12] } ];       # BM4_FF3_RX_P_4
set_property PACKAGE_PIN  AL3   [ get_ports { i_gth_rx_n[12] } ];       # BM4_FF3_RX_N_4
set_property PACKAGE_PIN  AL8   [ get_ports { o_gth_tx_p[12] } ];       # BM2_FF3_TX_P_4
set_property PACKAGE_PIN  AL7   [ get_ports { o_gth_tx_n[12] } ];       # BM2_FF3_TX_N_4
set_property PACKAGE_PIN  AK2   [ get_ports { i_gth_rx_p[13] } ];       # BM5_FF3_RX_P_5
set_property PACKAGE_PIN  AK1   [ get_ports { i_gth_rx_n[13] } ];       # BM5_FF3_RX_N_5
set_property PACKAGE_PIN  AK6   [ get_ports { o_gth_tx_p[13] } ];       # FF3_TX_P_5
set_property PACKAGE_PIN  AK5   [ get_ports { o_gth_tx_n[13] } ];       # FF3_TX_N_5
set_property PACKAGE_PIN  AJ4   [ get_ports { i_gth_rx_p[14] } ];       # BM6_FF3_RX_P_6
set_property PACKAGE_PIN  AJ3   [ get_ports { i_gth_rx_n[14] } ];       # BM6_FF3_RX_N_6
set_property PACKAGE_PIN  AJ8   [ get_ports { o_gth_tx_p[14] } ];       # BM3_FF3_TX_P_6
set_property PACKAGE_PIN  AJ7   [ get_ports { o_gth_tx_n[14] } ];       # BM3_FF3_TX_N_6
set_property PACKAGE_PIN  AH2   [ get_ports { i_gth_rx_p[15] } ];       # BM7_FF3_RX_P_7
set_property PACKAGE_PIN  AH1   [ get_ports { i_gth_rx_n[15] } ];       # BM7_FF3_RX_N_7
set_property PACKAGE_PIN  AH6   [ get_ports { o_gth_tx_p[15] } ];       # FF3_TX_P_7
set_property PACKAGE_PIN  AH5   [ get_ports { o_gth_tx_n[15] } ];       # FF3_TX_N_7

# MGT bank 228.
set_property PACKAGE_PIN  AC12  [ get_ports { i_gth_refclk0_p[4] } ];   # FE_REF2_AC_P
set_property PACKAGE_PIN  AC11  [ get_ports { i_gth_refclk0_n[4] } ];   # FE_REF2_AC_N
set_property PACKAGE_PIN  AB10  [ get_ports { i_gth_refclk1_p[4] } ];   # open
set_property PACKAGE_PIN  AB9   [ get_ports { i_gth_refclk1_n[4] } ];   # open
set_property PACKAGE_PIN  AG4   [ get_ports { i_gth_rx_p[16] } ];       # BM8_FF3_RX_P_8
set_property PACKAGE_PIN  AG3   [ get_ports { i_gth_rx_n[16] } ];       # BM8_FF3_RX_N_8
set_property PACKAGE_PIN  AG8   [ get_ports { o_gth_tx_p[16] } ];       # BM4_FF3_TX_P_8
set_property PACKAGE_PIN  AG7   [ get_ports { o_gth_tx_n[16] } ];       # BM4_FF3_TX_N_8
set_property PACKAGE_PIN  AF2   [ get_ports { i_gth_rx_p[17] } ];       # BM9_FF3_RX_P_9
set_property PACKAGE_PIN  AF1   [ get_ports { i_gth_rx_n[17] } ];       # BM9_FF3_RX_N_9
set_property PACKAGE_PIN  AF6   [ get_ports { o_gth_tx_p[17] } ];       # FF3_TX_P_9
set_property PACKAGE_PIN  AF5   [ get_ports { o_gth_tx_n[17] } ];       # FF3_TX_N_9
set_property PACKAGE_PIN  AE4   [ get_ports { i_gth_rx_p[18] } ];       # BM10_FF3_RX_P_10
set_property PACKAGE_PIN  AE3   [ get_ports { i_gth_rx_n[18] } ];       # BM10_FF3_RX_N_10
set_property PACKAGE_PIN  AE8   [ get_ports { o_gth_tx_p[18] } ];       # BM5_FF3_TX_P_10
set_property PACKAGE_PIN  AE7   [ get_ports { o_gth_tx_n[18] } ];       # BM5_FF3_TX_N_10
set_property PACKAGE_PIN  AD2   [ get_ports { i_gth_rx_p[19] } ];       # BM11_FF3_RX_P_11
set_property PACKAGE_PIN  AD1   [ get_ports { i_gth_rx_n[19] } ];       # BM11_FF3_RX_N_11
set_property PACKAGE_PIN  AD6   [ get_ports { o_gth_tx_p[19] } ];       # FF3_TX_P_11
set_property PACKAGE_PIN  AD5   [ get_ports { o_gth_tx_n[19] } ];       # FF3_TX_N_11

# MGT bank 229.
set_property PACKAGE_PIN  AA12  [ get_ports { i_gth_refclk0_p[5] } ];   # SPARE_REF1_AC_P
set_property PACKAGE_PIN  AA11  [ get_ports { i_gth_refclk0_n[5] } ];   # SPARE_REF1_AC_N
set_property PACKAGE_PIN  Y10   [ get_ports { i_gth_refclk1_p[5] } ];   # open
set_property PACKAGE_PIN  Y9    [ get_ports { i_gth_refclk1_n[5] } ];   # open
set_property PACKAGE_PIN  AC4   [ get_ports { i_gth_rx_p[20] } ];       # FF4_RX_P_0
set_property PACKAGE_PIN  AC3   [ get_ports { i_gth_rx_n[20] } ];       # FF4_RX_N_0
set_property PACKAGE_PIN  AC8   [ get_ports { o_gth_tx_p[20] } ];       # FF4_TX_P_0
set_property PACKAGE_PIN  AC7   [ get_ports { o_gth_tx_n[20] } ];       # FF4_TX_N_0
set_property PACKAGE_PIN  AB2   [ get_ports { i_gth_rx_p[21] } ];       # FF4_RX_P_1
set_property PACKAGE_PIN  AB1   [ get_ports { i_gth_rx_n[21] } ];       # FF4_RX_N_1
set_property PACKAGE_PIN  AB6   [ get_ports { o_gth_tx_p[21] } ];       # FF4_TX_P_1
set_property PACKAGE_PIN  AB5   [ get_ports { o_gth_tx_n[21] } ];       # FF4_TX_N_1
set_property PACKAGE_PIN  AA4   [ get_ports { i_gth_rx_p[22] } ];       # FF4_RX_P_2
set_property PACKAGE_PIN  AA3   [ get_ports { i_gth_rx_n[22] } ];       # FF4_RX_N_2
set_property PACKAGE_PIN  AA8   [ get_ports { o_gth_tx_p[22] } ];       # FF4_TX_P_2
set_property PACKAGE_PIN  AA7   [ get_ports { o_gth_tx_n[22] } ];       # FF4_TX_N_2
set_property PACKAGE_PIN  Y2    [ get_ports { i_gth_rx_p[23] } ];       # FF4_RX_P_3
set_property PACKAGE_PIN  Y1    [ get_ports { i_gth_rx_n[23] } ];       # FF4_RX_N_3
set_property PACKAGE_PIN  Y6    [ get_ports { o_gth_tx_p[23] } ];       # FF4_TX_P_3
set_property PACKAGE_PIN  Y5    [ get_ports { o_gth_tx_n[23] } ];       # FF4_TX_N_3

# MGT bank 230.
set_property PACKAGE_PIN  W12   [ get_ports { i_gth_refclk0_p[6] } ];   # FE_REF3_AC_P
set_property PACKAGE_PIN  W11   [ get_ports { i_gth_refclk0_n[6] } ];   # FE_REF3_AC_N
set_property PACKAGE_PIN  V10   [ get_ports { i_gth_refclk1_p[6] } ];   # SPARE_REF2_AC_P
set_property PACKAGE_PIN  V9    [ get_ports { i_gth_refclk1_n[6] } ];   # SPARE_REF2_AC_N
set_property PACKAGE_PIN  W4    [ get_ports { i_gth_rx_p[24] } ];       # FF4_RX_P_4
set_property PACKAGE_PIN  W3    [ get_ports { i_gth_rx_n[24] } ];       # FF4_RX_N_4
set_property PACKAGE_PIN  W8    [ get_ports { o_gth_tx_p[24] } ];       # FF4_TX_P_4
set_property PACKAGE_PIN  W7    [ get_ports { o_gth_tx_n[24] } ];       # FF4_TX_N_4
set_property PACKAGE_PIN  V2    [ get_ports { i_gth_rx_p[25] } ];       # FF4_RX_P_5
set_property PACKAGE_PIN  V1    [ get_ports { i_gth_rx_n[25] } ];       # FF4_RX_N_5
set_property PACKAGE_PIN  V6    [ get_ports { o_gth_tx_p[25] } ];       # FF4_TX_P_5
set_property PACKAGE_PIN  V5    [ get_ports { o_gth_tx_n[25] } ];       # FF4_TX_N_5
set_property PACKAGE_PIN  U4    [ get_ports { i_gth_rx_p[26] } ];       # BO17_FF4_RX_P_6
set_property PACKAGE_PIN  U3    [ get_ports { i_gth_rx_n[26] } ];       # BO17_FF4_RX_N_6
set_property PACKAGE_PIN  U8    [ get_ports { o_gth_tx_p[26] } ];       # FF4_TX_P_6
set_property PACKAGE_PIN  U7    [ get_ports { o_gth_tx_n[26] } ];       # FF4_TX_N_6
set_property PACKAGE_PIN  T2    [ get_ports { i_gth_rx_p[27] } ];       # BO16_FF4_RX_P_7
set_property PACKAGE_PIN  T1    [ get_ports { i_gth_rx_n[27] } ];       # BO16_FF4_RX_N_7
set_property PACKAGE_PIN  T6    [ get_ports { o_gth_tx_p[27] } ];       # BO8_FF4_TX_P_7
set_property PACKAGE_PIN  T5    [ get_ports { o_gth_tx_n[27] } ];       # BO8_FF4_TX_N_7

# MGT bank 231.
set_property PACKAGE_PIN  U12   [ get_ports { i_gth_refclk0_p[7] } ];   # FE_REF4_AC_P
set_property PACKAGE_PIN  U11   [ get_ports { i_gth_refclk0_n[7] } ];   # FE_REF4_AC_N
set_property PACKAGE_PIN  T10   [ get_ports { i_gth_refclk1_p[7] } ];   # open
set_property PACKAGE_PIN  T9    [ get_ports { i_gth_refclk1_n[7] } ];   # open
set_property PACKAGE_PIN  R4    [ get_ports { i_gth_rx_p[28] } ];       # BO15_FF4_RX_P_8
set_property PACKAGE_PIN  R3    [ get_ports { i_gth_rx_n[28] } ];       # BO15_FF4_RX_N_8
set_property PACKAGE_PIN  R8    [ get_ports { o_gth_tx_p[28] } ];       # FF4_TX_P_8
set_property PACKAGE_PIN  R7    [ get_ports { o_gth_tx_n[28] } ];       # FF4_TX_N_8
set_property PACKAGE_PIN  P2    [ get_ports { i_gth_rx_p[29] } ];       # BO14_FF4_RX_P_9
set_property PACKAGE_PIN  P1    [ get_ports { i_gth_rx_n[29] } ];       # BO14_FF4_RX_N_9
set_property PACKAGE_PIN  P6    [ get_ports { o_gth_tx_p[29] } ];       # BO7_FF4_TX_P_9
set_property PACKAGE_PIN  P5    [ get_ports { o_gth_tx_n[29] } ];       # BO7_FF4_TX_N_9
set_property PACKAGE_PIN  N4    [ get_ports { i_gth_rx_p[30] } ];       # BO13_FF4_RX_P_10
set_property PACKAGE_PIN  N3    [ get_ports { i_gth_rx_n[30] } ];       # BO13_FF4_RX_N_10
set_property PACKAGE_PIN  N8    [ get_ports { o_gth_tx_p[30] } ];       # FF4_TX_P_10
set_property PACKAGE_PIN  N7    [ get_ports { o_gth_tx_n[30] } ];       # FF4_TX_N_10
set_property PACKAGE_PIN  M2    [ get_ports { i_gth_rx_p[31] } ];       # BO12_FF4_RX_P_11
set_property PACKAGE_PIN  M1    [ get_ports { i_gth_rx_n[31] } ];       # BO12_FF4_RX_N_11
set_property PACKAGE_PIN  M6    [ get_ports { o_gth_tx_p[31] } ];       # BO6_FF4_TX_P_11
set_property PACKAGE_PIN  M5    [ get_ports { o_gth_tx_n[31] } ];       # BO6_FF4_TX_N_11

# MGT bank 232.
set_property PACKAGE_PIN  R12   [ get_ports { i_gth_refclk0_p[8] } ];   # FE_REF5_AC_P
set_property PACKAGE_PIN  R11   [ get_ports { i_gth_refclk0_n[8] } ];   # FE_REF5_AC_N
set_property PACKAGE_PIN  P10   [ get_ports { i_gth_refclk1_p[8] } ];   # open
set_property PACKAGE_PIN  P9    [ get_ports { i_gth_refclk1_n[8] } ];   # open
set_property PACKAGE_PIN  L4    [ get_ports { i_gth_rx_p[32] } ];       # BO11_FF5_RX_P_0
set_property PACKAGE_PIN  L3    [ get_ports { i_gth_rx_n[32] } ];       # BO11_FF5_RX_N_0
set_property PACKAGE_PIN  L8    [ get_ports { o_gth_tx_p[32] } ];       # FF5_TX_P_0
set_property PACKAGE_PIN  L7    [ get_ports { o_gth_tx_n[32] } ];       # FF5_TX_N_0
set_property PACKAGE_PIN  K2    [ get_ports { i_gth_rx_p[33] } ];       # BO10_FF5_RX_P_1
set_property PACKAGE_PIN  K1    [ get_ports { i_gth_rx_n[33] } ];       # BO10_FF5_RX_N_1
set_property PACKAGE_PIN  K6    [ get_ports { o_gth_tx_p[33] } ];       # BO5_FF5_TX_P_1
set_property PACKAGE_PIN  K5    [ get_ports { o_gth_tx_n[33] } ];       # BO5_FF5_TX_N_1
set_property PACKAGE_PIN  J4    [ get_ports { i_gth_rx_p[34] } ];       # BO9_FF5_RX_P_2
set_property PACKAGE_PIN  J3    [ get_ports { i_gth_rx_n[34] } ];       # BO9_FF5_RX_N_2
set_property PACKAGE_PIN  J8    [ get_ports { o_gth_tx_p[34] } ];       # FF5_TX_P_2
set_property PACKAGE_PIN  J7    [ get_ports { o_gth_tx_n[34] } ];       # FF5_TX_N_2
set_property PACKAGE_PIN  H2    [ get_ports { i_gth_rx_p[35] } ];       # BO8_FF5_RX_P_3
set_property PACKAGE_PIN  H1    [ get_ports { i_gth_rx_n[35] } ];       # BO8_FF5_RX_N_3
set_property PACKAGE_PIN  H6    [ get_ports { o_gth_tx_p[35] } ];       # BO4_FF5_TX_P_3
set_property PACKAGE_PIN  H5    [ get_ports { o_gth_tx_n[35] } ];       # BO4_FF5_TX_N_3

# MGT bank 233.
set_property PACKAGE_PIN  N12   [ get_ports { i_gth_refclk0_p[9] } ];   # FE_REF6_AC_P
set_property PACKAGE_PIN  N11   [ get_ports { i_gth_refclk0_n[9] } ];   # FE_REF6_AC_N
set_property PACKAGE_PIN  M10   [ get_ports { i_gth_refclk1_p[9] } ];   # open
set_property PACKAGE_PIN  M9    [ get_ports { i_gth_refclk1_n[9] } ];   # open
set_property PACKAGE_PIN  G4    [ get_ports { i_gth_rx_p[36] } ];       # BO7_FF5_RX_P_4
set_property PACKAGE_PIN  G3    [ get_ports { i_gth_rx_n[36] } ];       # BO7_FF5_RX_N_4
set_property PACKAGE_PIN  H10   [ get_ports { o_gth_tx_p[36] } ];       # FF5_TX_P_4
set_property PACKAGE_PIN  H9    [ get_ports { o_gth_tx_n[36] } ];       # FF5_TX_N_4
set_property PACKAGE_PIN  F2    [ get_ports { i_gth_rx_p[37] } ];       # BO6_FF5_RX_P_5
set_property PACKAGE_PIN  F1    [ get_ports { i_gth_rx_n[37] } ];       # BO6_FF5_RX_N_5
set_property PACKAGE_PIN  G8    [ get_ports { o_gth_tx_p[37] } ];       # BO3_FF5_TX_P_5
set_property PACKAGE_PIN  G7    [ get_ports { o_gth_tx_n[37] } ];       # BO3_FF5_TX_N_5
set_property PACKAGE_PIN  E4    [ get_ports { i_gth_rx_p[38] } ];       # BO5_FF5_RX_P_6
set_property PACKAGE_PIN  E3    [ get_ports { i_gth_rx_n[38] } ];       # BO5_FF5_RX_N_6
set_property PACKAGE_PIN  F6    [ get_ports { o_gth_tx_p[38] } ];       # FF5_TX_P_6
set_property PACKAGE_PIN  F5    [ get_ports { o_gth_tx_n[38] } ];       # FF5_TX_N_6
set_property PACKAGE_PIN  D2    [ get_ports { i_gth_rx_p[39] } ];       # BO4_FF5_RX_P_7
set_property PACKAGE_PIN  D1    [ get_ports { i_gth_rx_n[39] } ];       # BO4_FF5_RX_N_7
set_property PACKAGE_PIN  F10   [ get_ports { o_gth_tx_p[39] } ];       # BO2_FF5_TX_P_7
set_property PACKAGE_PIN  F9    [ get_ports { o_gth_tx_n[39] } ];       # BO2_FF5_TX_N_7

# MGT bank 234.
set_property PACKAGE_PIN  L12   [ get_ports { i_gth_refclk0_p[10] } ];  # FE_REF7_AC_P
set_property PACKAGE_PIN  L11   [ get_ports { i_gth_refclk0_n[10] } ];  # FE_REF7_AC_N
set_property PACKAGE_PIN  K10   [ get_ports { i_gth_refclk1_p[10] } ];  # open
set_property PACKAGE_PIN  K9    [ get_ports { i_gth_refclk1_n[10] } ];  # open
set_property PACKAGE_PIN  C4    [ get_ports { i_gth_rx_p[40] } ];       # BO3_FF5_RX_P_8
set_property PACKAGE_PIN  C3    [ get_ports { i_gth_rx_n[40] } ];       # BO3_FF5_RX_N_8
set_property PACKAGE_PIN  E8    [ get_ports { o_gth_tx_p[40] } ];       # FF5_TX_P_8
set_property PACKAGE_PIN  E7    [ get_ports { o_gth_tx_n[40] } ];       # FF5_TX_N_8
set_property PACKAGE_PIN  B2    [ get_ports { i_gth_rx_p[41] } ];       # BO2_FF5_RX_P_9
set_property PACKAGE_PIN  B1    [ get_ports { i_gth_rx_n[41] } ];       # BO2_FF5_RX_N_9
set_property PACKAGE_PIN  D6    [ get_ports { o_gth_tx_p[41] } ];       # BO1_FF5_TX_P_9
set_property PACKAGE_PIN  D5    [ get_ports { o_gth_tx_n[41] } ];       # BO1_FF5_TX_N_9
set_property PACKAGE_PIN  B6    [ get_ports { i_gth_rx_p[42] } ];       # BO1_FF5_RX_P_10
set_property PACKAGE_PIN  B5    [ get_ports { i_gth_rx_n[42] } ];       # BO1_FF5_RX_N_10
set_property PACKAGE_PIN  D10   [ get_ports { o_gth_tx_p[42] } ];       # FF5_TX_P_10
set_property PACKAGE_PIN  D9    [ get_ports { o_gth_tx_n[42] } ];       # FF5_TX_N_10
set_property PACKAGE_PIN  A4    [ get_ports { i_gth_rx_p[43] } ];       # BO0_FF5_RX_P_11
set_property PACKAGE_PIN  A3    [ get_ports { i_gth_rx_n[43] } ];       # BO0_FF5_RX_N_11
set_property PACKAGE_PIN  C8    [ get_ports { o_gth_tx_p[43] } ];       # BO0_FF5_TX_P_11
set_property PACKAGE_PIN  C7    [ get_ports { o_gth_tx_n[43] } ];       # BO0_FF5_TX_N_11
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# GTY ports.

# Do *not* add IO buffers on GTY TX ports.
set_property IO_BUFFER_TYPE NONE [ get_ports o_gty_tx_* ];

# MGT bank 127.
set_property PACKAGE_PIN  AG30  [ get_ports { i_gty_refclk0_p[0] } ];   # C2C_REF0_AC_P
set_property PACKAGE_PIN  AG31  [ get_ports { i_gty_refclk0_n[0] } ];   # C2C_REF0_AC_N
set_property PACKAGE_PIN  AE30  [ get_ports { i_gty_refclk1_p[0] } ];   # open
set_property PACKAGE_PIN  AE31  [ get_ports { i_gty_refclk1_n[0] } ];   # open
set_property PACKAGE_PIN  AT41  [ get_ports { i_gty_rx_p[0] } ];        # C2C_ZUP_2_KUP_AC_P_0
set_property PACKAGE_PIN  AT42  [ get_ports { i_gty_rx_n[0] } ];        # C2C_ZUP_2_KUP_AC_N_0
set_property PACKAGE_PIN  AM36  [ get_ports { o_gty_tx_p[0] } ];        # C2C_KUP_2_ZUP_P_0
set_property PACKAGE_PIN  AM37  [ get_ports { o_gty_tx_n[0] } ];        # C2C_KUP_2_ZUP_N_0
set_property PACKAGE_PIN  AR39  [ get_ports { i_gty_rx_p[1] } ];        # C2C_ZUP_2_KUP_AC_P_1
set_property PACKAGE_PIN  AR40  [ get_ports { i_gty_rx_n[1] } ];        # C2C_ZUP_2_KUP_AC_N_1
set_property PACKAGE_PIN  AL34  [ get_ports { o_gty_tx_p[1] } ];        # C2C_KUP_2_ZUP_P_1
set_property PACKAGE_PIN  AL35  [ get_ports { o_gty_tx_n[1] } ];        # C2C_KUP_2_ZUP_N_1
set_property PACKAGE_PIN  AP41  [ get_ports { i_gty_rx_p[2] } ];        # C2C_ZUP_2_KUP_AC_P_2
set_property PACKAGE_PIN  AP42  [ get_ports { i_gty_rx_n[2] } ];        # C2C_ZUP_2_KUP_AC_N_2
set_property PACKAGE_PIN  AK36  [ get_ports { o_gty_tx_p[2] } ];        # C2C_KUP_2_ZUP_P_2
set_property PACKAGE_PIN  AK37  [ get_ports { o_gty_tx_n[2] } ];        # C2C_KUP_2_ZUP_N_2
set_property PACKAGE_PIN  AN39  [ get_ports { i_gty_rx_p[3] } ];        # C2C_ZUP_2_KUP_AC_P_3
set_property PACKAGE_PIN  AN40  [ get_ports { i_gty_rx_n[3] } ];        # C2C_ZUP_2_KUP_AC_N_3
set_property PACKAGE_PIN  AJ34  [ get_ports { o_gty_tx_p[3] } ];        # C2C_KUP_2_ZUP_P_3
set_property PACKAGE_PIN  AJ35  [ get_ports { o_gty_tx_n[3] } ];        # C2C_KUP_2_ZUP_N_3

# MGT bank 128
set_property PACKAGE_PIN  AD32  [ get_ports { i_gty_refclk0_p[1] } ];   # CM2CM_REF0_AC_P
set_property PACKAGE_PIN  AD33  [ get_ports { i_gty_refclk0_n[1] } ];   # CM2CM_REF0_AC_N
set_property PACKAGE_PIN  AC30  [ get_ports { i_gty_refclk1_p[1] } ];   # open
set_property PACKAGE_PIN  AC31  [ get_ports { i_gty_refclk1_n[1] } ];   # open
set_property PACKAGE_PIN  AM41  [ get_ports { i_gty_rx_p[4] } ];        # CM2CM3_FF1_RX_P_11
set_property PACKAGE_PIN  AM42  [ get_ports { i_gty_rx_n[4] } ];        # CM2CM3_FF1_RX_N_11
set_property PACKAGE_PIN  AH32  [ get_ports { o_gty_tx_p[4] } ];        # CM2CM3_FF2_TX_P_11
set_property PACKAGE_PIN  AH33  [ get_ports { o_gty_tx_n[4] } ];        # CM2CM3_FF2_TX_N_11
set_property PACKAGE_PIN  AL39  [ get_ports { i_gty_rx_p[5] } ];        # CM2CM2_FF1_RX_P_10
set_property PACKAGE_PIN  AL40  [ get_ports { i_gty_rx_n[5] } ];        # CM2CM2_FF1_RX_N_10
set_property PACKAGE_PIN  AH36  [ get_ports { o_gty_tx_p[5] } ];        # CM2CM2_FF2_TX_P_10
set_property PACKAGE_PIN  AH37  [ get_ports { o_gty_tx_n[5] } ];        # CM2CM2_FF2_TX_N_10
set_property PACKAGE_PIN  AK41  [ get_ports { i_gty_rx_p[6] } ];        # CM2CM1_FF1_RX_P_9
set_property PACKAGE_PIN  AK42  [ get_ports { i_gty_rx_n[6] } ];        # CM2CM1_FF1_RX_N_9
set_property PACKAGE_PIN  AG34  [ get_ports { o_gty_tx_p[6] } ];        # CM2CM1_FF2_TX_P_9
set_property PACKAGE_PIN  AG35  [ get_ports { o_gty_tx_n[6] } ];        # CM2CM1_FF2_TX_N_9
set_property PACKAGE_PIN  AJ39  [ get_ports { i_gty_rx_p[7] } ];        # CM2CM0_FF1_RX_P_8
set_property PACKAGE_PIN  AJ40  [ get_ports { i_gty_rx_n[7] } ];        # CM2CM0_FF1_RX_N_8
set_property PACKAGE_PIN  AF32  [ get_ports { o_gty_tx_p[7] } ];        # CM2CM0_FF2_TX_P_8
set_property PACKAGE_PIN  AF33  [ get_ports { o_gty_tx_n[7] } ];        # CM2CM0_FF2_TX_N_8

# MGT bank 129
set_property PACKAGE_PIN  AB32  [ get_ports { i_gty_refclk0_p[2] } ];   # SL_REF0_AC_P
set_property PACKAGE_PIN  AB33  [ get_ports { i_gty_refclk0_n[2] } ];   # SL_REF0_AC_N
set_property PACKAGE_PIN  AA30  [ get_ports { i_gty_refclk1_p[2] } ];   # open
set_property PACKAGE_PIN  AA31  [ get_ports { i_gty_refclk1_n[2] } ];   # open
set_property PACKAGE_PIN  AH41  [ get_ports { i_gty_rx_p[8]  } ];       # SL11_FF2_RX_P_11
set_property PACKAGE_PIN  AH42  [ get_ports { i_gty_rx_n[8]  } ];       # SL11_FF2_RX_n_11
set_property PACKAGE_PIN  AF36  [ get_ports { o_gty_tx_p[8]  } ];       # open
set_property PACKAGE_PIN  AF37  [ get_ports { o_gty_tx_n[8]  } ];       # open
set_property PACKAGE_PIN  AG39  [ get_ports { i_gty_rx_p[9]  } ];       # SL10_FF2_RX_P_10
set_property PACKAGE_PIN  AG40  [ get_ports { i_gty_rx_n[9]  } ];       # SL10_FF2_RX_n_10
set_property PACKAGE_PIN  AE34  [ get_ports { o_gty_tx_p[9]  } ];       # open
set_property PACKAGE_PIN  AE35  [ get_ports { o_gty_tx_n[9]  } ];       # open
set_property PACKAGE_PIN  AF41  [ get_ports { i_gty_rx_p[10] } ];       # SL9_FF2_RX_P_9
set_property PACKAGE_PIN  AF42  [ get_ports { i_gty_rx_n[10] } ];       # SL9_FF2_RX_n_9
set_property PACKAGE_PIN  AD36  [ get_ports { o_gty_tx_p[10] } ];       # open
set_property PACKAGE_PIN  AD37  [ get_ports { o_gty_tx_n[10] } ];       # open
set_property PACKAGE_PIN  AE39  [ get_ports { i_gty_rx_p[11] } ];       # SL8_FF2_RX_P_8
set_property PACKAGE_PIN  AE40  [ get_ports { i_gty_rx_n[11] } ];       # SL8_FF2_RX_n_8
set_property PACKAGE_PIN  AC34  [ get_ports { o_gty_tx_p[11] } ];       # open
set_property PACKAGE_PIN  AC35  [ get_ports { o_gty_tx_n[11] } ];       # open

# MGT bank 130
set_property PACKAGE_PIN  Y32   [ get_ports { i_gty_refclk0_p[3] } ];   # SL_REF1_AC_P
set_property PACKAGE_PIN  Y33   [ get_ports { i_gty_refclk0_n[3] } ];   # SL_REF1_AC_N
set_property PACKAGE_PIN  W30   [ get_ports { i_gty_refclk1_p[3] } ];   # open
set_property PACKAGE_PIN  W31   [ get_ports { i_gty_refclk1_n[3] } ];   # open
set_property PACKAGE_PIN  AD41  [ get_ports { i_gty_rx_p[12] } ];       # SL7_FF2_RX_P_7
set_property PACKAGE_PIN  AD42  [ get_ports { i_gty_rx_n[12] } ];       # SL7_FF2_RX_N_7
set_property PACKAGE_PIN  AB36  [ get_ports { o_gty_tx_p[12] } ];       # FF2_TX_P_7
set_property PACKAGE_PIN  AB37  [ get_ports { o_gty_tx_n[12] } ];       # FF2_TX_N_7
set_property PACKAGE_PIN  AC39  [ get_ports { i_gty_rx_p[13] } ];       # SL6_FF2_RX_P_6
set_property PACKAGE_PIN  AC40  [ get_ports { i_gty_rx_n[13] } ];       # SL6_FF2_RX_N_6
set_property PACKAGE_PIN  AA38  [ get_ports { o_gty_tx_p[13] } ];       # FF2_TX_P_6
set_property PACKAGE_PIN  AA39  [ get_ports { o_gty_tx_n[13] } ];       # FF2_TX_N_6
set_property PACKAGE_PIN  AB41  [ get_ports { i_gty_rx_p[14] } ];       # SL5_FF2_RX_P_5
set_property PACKAGE_PIN  AB42  [ get_ports { i_gty_rx_n[14] } ];       # SL5_FF2_RX_N_5
set_property PACKAGE_PIN  AA34  [ get_ports { o_gty_tx_p[14] } ];       # FF2_TX_P_5
set_property PACKAGE_PIN  AA35  [ get_ports { o_gty_tx_n[14] } ];       # FF2_TX_N_5
set_property PACKAGE_PIN  Y41   [ get_ports { i_gty_rx_p[15] } ];       # SL4_FF2_RX_P_4
set_property PACKAGE_PIN  Y42   [ get_ports { i_gty_rx_n[15] } ];       # SL4_FF2_RX_N_4
set_property PACKAGE_PIN  Y36   [ get_ports { o_gty_tx_p[15] } ];       # FF2_TX_P_4
set_property PACKAGE_PIN  Y37   [ get_ports { o_gty_tx_n[15] } ];       # FF2_TX_N_4

# MGT bank 131
set_property PACKAGE_PIN  V32   [ get_ports { i_gty_refclk0_p[4] } ];   # SL_REF2_AC_P
set_property PACKAGE_PIN  V33   [ get_ports { i_gty_refclk0_n[4] } ];   # SL_REF2_AC_N
set_property PACKAGE_PIN  U30   [ get_ports { i_gty_refclk1_p[4] } ];   # open
set_property PACKAGE_PIN  U31   [ get_ports { i_gty_refclk1_n[4] } ];   # open
set_property PACKAGE_PIN  V41   [ get_ports { i_gty_rx_p[16] } ];       # SL3_FF2_RX_P_3
set_property PACKAGE_PIN  V42   [ get_ports { i_gty_rx_n[16] } ];       # SL3_FF2_RX_N_3
set_property PACKAGE_PIN  W38   [ get_ports { o_gty_tx_p[16] } ];       # FF2_TX_P_3
set_property PACKAGE_PIN  W39   [ get_ports { o_gty_tx_n[16] } ];       # FF2_TX_N_3
set_property PACKAGE_PIN  T41   [ get_ports { i_gty_rx_p[17] } ];       # SL2_FF2_RX_P_2
set_property PACKAGE_PIN  T42   [ get_ports { i_gty_rx_n[17] } ];       # SL2_FF2_RX_N_2
set_property PACKAGE_PIN  W34   [ get_ports { o_gty_tx_p[17] } ];       # FF2_TX_P_2
set_property PACKAGE_PIN  W35   [ get_ports { o_gty_tx_n[17] } ];       # FF2_TX_N_2
set_property PACKAGE_PIN  P41   [ get_ports { i_gty_rx_p[18] } ];       # SL1_FF2_RX_P_1
set_property PACKAGE_PIN  P42   [ get_ports { i_gty_rx_n[18] } ];       # SL1_FF2_RX_N_1
set_property PACKAGE_PIN  V36   [ get_ports { o_gty_tx_p[18] } ];       # FF2_TX_P_1
set_property PACKAGE_PIN  V37   [ get_ports { o_gty_tx_n[18] } ];       # FF2_TX_N_1
set_property PACKAGE_PIN  N39   [ get_ports { i_gty_rx_p[19] } ];       # SL0_FF2_RX_P_0
set_property PACKAGE_PIN  N40   [ get_ports { i_gty_rx_n[19] } ];       # SL0_FF2_RX_N_0
set_property PACKAGE_PIN  U38   [ get_ports { o_gty_tx_p[19] } ];       # FF2_TX_P_0
set_property PACKAGE_PIN  U39   [ get_ports { o_gty_tx_n[19] } ];       # FF2_TX_N_0

# MGT bank 132
set_property PACKAGE_PIN  T32   [ get_ports { i_gty_refclk0_p[5] } ];   # FELIX_REF0_AC_P
set_property PACKAGE_PIN  T33   [ get_ports { i_gty_refclk0_n[5] } ];   # FELIX_REF0_AC_N
set_property PACKAGE_PIN  R30   [ get_ports { i_gty_refclk1_p[5] } ];   # open
set_property PACKAGE_PIN  R31   [ get_ports { i_gty_refclk1_n[5] } ];   # open
set_property PACKAGE_PIN  M41   [ get_ports { i_gty_rx_p[20] } ];       # GND
set_property PACKAGE_PIN  M42   [ get_ports { i_gty_rx_n[20] } ];       # GND
set_property PACKAGE_PIN  U34   [ get_ports { o_gty_tx_p[20] } ];       # FELIX11_FF1_TX_P_11
set_property PACKAGE_PIN  U35   [ get_ports { o_gty_tx_n[20] } ];       # FELIX11_FF1_TX_N_11
set_property PACKAGE_PIN  L39   [ get_ports { i_gty_rx_p[21] } ];       # GND
set_property PACKAGE_PIN  L40   [ get_ports { i_gty_rx_n[21] } ];       # GND
set_property PACKAGE_PIN  T36   [ get_ports { o_gty_tx_p[21] } ];       # FELIX10_FF1_TX_P_10
set_property PACKAGE_PIN  T37   [ get_ports { o_gty_tx_n[21] } ];       # FELIX10_FF1_TX_N_10
set_property PACKAGE_PIN  K41   [ get_ports { i_gty_rx_p[22] } ];       # GND
set_property PACKAGE_PIN  K42   [ get_ports { i_gty_rx_n[22] } ];       # GND
set_property PACKAGE_PIN  R38   [ get_ports { o_gty_tx_p[22] } ];       # FELIX9_FF1_TX_P_9
set_property PACKAGE_PIN  R39   [ get_ports { o_gty_tx_n[22] } ];       # FELIX9_FF1_TX_N_9
set_property PACKAGE_PIN  J39   [ get_ports { i_gty_rx_p[23] } ];       # GND
set_property PACKAGE_PIN  J40   [ get_ports { i_gty_rx_n[23] } ];       # GND
set_property PACKAGE_PIN  R34   [ get_ports { o_gty_tx_p[23] } ];       # FELIX8_FF1_TX_P_8
set_property PACKAGE_PIN  R35   [ get_ports { o_gty_tx_n[23] } ];       # FELIX8_FF1_TX_N_8

# MGT bank 133
set_property PACKAGE_PIN  P32   [ get_ports { i_gty_refclk0_p[6] } ];   # FELIX_REF1_AC_P
set_property PACKAGE_PIN  P33   [ get_ports { i_gty_refclk0_n[6] } ];   # FELIX_REF1_AC_N
set_property PACKAGE_PIN  N30   [ get_ports { i_gty_refclk1_p[6] } ];   # open
set_property PACKAGE_PIN  N31   [ get_ports { i_gty_refclk1_n[6] } ];   # open
set_property PACKAGE_PIN  H41   [ get_ports { i_gty_rx_p[24] } ];       # FF1_RX_P_7
set_property PACKAGE_PIN  H42   [ get_ports { i_gty_rx_n[24] } ];       # FF1_RX_N_7
set_property PACKAGE_PIN  P36   [ get_ports { o_gty_tx_p[24] } ];       # FELIX7_FF1_TX_P_7
set_property PACKAGE_PIN  P37   [ get_ports { o_gty_tx_n[24] } ];       # FELIX7_FF1_TX_N_7
set_property PACKAGE_PIN  G39   [ get_ports { i_gty_rx_p[25] } ];       # FF1_RX_P_6
set_property PACKAGE_PIN  G40   [ get_ports { i_gty_rx_n[25] } ];       # FF1_RX_N_6
set_property PACKAGE_PIN  N34   [ get_ports { o_gty_tx_p[25] } ];       # FELIX6_FF1_TX_P_6
set_property PACKAGE_PIN  N35   [ get_ports { o_gty_tx_n[25] } ];       # FELIX6_FF1_TX_N_6
set_property PACKAGE_PIN  F41   [ get_ports { i_gty_rx_p[26] } ];       # FF1_RX_P_5
set_property PACKAGE_PIN  F42   [ get_ports { i_gty_rx_n[26] } ];       # FF1_RX_N_5
set_property PACKAGE_PIN  M36   [ get_ports { o_gty_tx_p[26] } ];       # FELIX5_FF1_TX_P_5
set_property PACKAGE_PIN  M37   [ get_ports { o_gty_tx_n[26] } ];       # FELIX5_FF1_TX_N_5
set_property PACKAGE_PIN  E39   [ get_ports { i_gty_rx_p[27] } ];       # FF1_RX_P_4
set_property PACKAGE_PIN  E40   [ get_ports { i_gty_rx_n[27] } ];       # FF1_RX_N_4
set_property PACKAGE_PIN  L34   [ get_ports { o_gty_tx_p[27] } ];       # FELIX4_FF1_TX_P_4
set_property PACKAGE_PIN  L35   [ get_ports { o_gty_tx_n[27] } ];       # FELIX4_FF1_TX_N_4

# MGT bank 134
set_property PACKAGE_PIN  M32   [ get_ports { i_gty_refclk0_p[7] } ];   # FELIX_REF2_AC_P
set_property PACKAGE_PIN  M33   [ get_ports { i_gty_refclk0_n[7] } ];   # FELIX_REF2_AC_N
set_property PACKAGE_PIN  L30   [ get_ports { i_gty_refclk1_p[7] } ];   # open
set_property PACKAGE_PIN  L31   [ get_ports { i_gty_refclk1_n[7] } ];   # open
set_property PACKAGE_PIN  D41   [ get_ports { i_gty_rx_p[28] } ];       # FF1_RX_P_3
set_property PACKAGE_PIN  D42   [ get_ports { i_gty_rx_n[28] } ];       # FF1_RX_N_3
set_property PACKAGE_PIN  K36   [ get_ports { o_gty_tx_p[28] } ];       # FELIX3_FF1_TX_P_3
set_property PACKAGE_PIN  K37   [ get_ports { o_gty_tx_n[28] } ];       # FELIX3_FF1_TX_N_3
set_property PACKAGE_PIN  C39   [ get_ports { i_gty_rx_p[29] } ];       # FF1_RX_P_2
set_property PACKAGE_PIN  C40   [ get_ports { i_gty_rx_n[29] } ];       # FF1_RX_N_2
set_property PACKAGE_PIN  K32   [ get_ports { o_gty_tx_p[29] } ];       # FELIX2_FF1_TX_P_2
set_property PACKAGE_PIN  K33   [ get_ports { o_gty_tx_n[29] } ];       # FELIX2_FF1_TX_N_2
set_property PACKAGE_PIN  B41   [ get_ports { i_gty_rx_p[30] } ];       # FF1_RX_P_1
set_property PACKAGE_PIN  B42   [ get_ports { i_gty_rx_n[30] } ];       # FF1_RX_N_1
set_property PACKAGE_PIN  J34   [ get_ports { o_gty_tx_p[30] } ];       # FELIX1_FF1_TX_P_1
set_property PACKAGE_PIN  J35   [ get_ports { o_gty_tx_n[30] } ];       # FELIX1_FF1_TX_N_1
set_property PACKAGE_PIN  A39   [ get_ports { i_gty_rx_p[31] } ];       # FELIX0_FF1_RX_P_0
set_property PACKAGE_PIN  A40   [ get_ports { i_gty_rx_n[31] } ];       # FELIX0_FF1_RX_N_0
set_property PACKAGE_PIN  H36   [ get_ports { o_gty_tx_p[31] } ];       # FELIX0_FF1_TX_P_0
set_property PACKAGE_PIN  H37   [ get_ports { o_gty_tx_n[31] } ];       # FELIX0_FF1_TX_N_0
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Spare MCU connections, bank 94.

set_property IOSTANDARD LVCMOS33 [ get_ports io_mcu_se* ];
set_property PACKAGE_PIN  B10   [ get_ports { io_mcu_se[0] } ];         # MCU_2_KUP_SE0
set_property PACKAGE_PIN  A9    [ get_ports { io_mcu_se[1] } ];         # MCU_2_KUP_SE1
set_property PACKAGE_PIN  A11   [ get_ports { io_mcu_se[2] } ];         # MCU_2_KUP_SE2
set_property PACKAGE_PIN  A10   [ get_ports { io_mcu_se[3] } ];         # MCU_2_KUP_SE3
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Spare SM-CM connections.
set_property IOSTANDARD LVCMOS33 [ get_ports io_sm_gpio* ];
set_property PACKAGE_PIN  A15   [ get_ports { io_sm_gpio[1] } ];        # SM_GPIO1
set_property PACKAGE_PIN  A13   [ get_ports { io_sm_gpio[2] } ];        # SM_GPIO2
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Spare I2C bus, bank 94.

set_property IOSTANDARD LVCMOS33 [ get_ports io_reserved_i2c_* ];
set_property PACKAGE_PIN  F14   [ get_ports { io_reserved_i2c_scl } ];  # KUP_RESERVED_SCL
set_property PACKAGE_PIN  F13   [ get_ports { io_reserved_i2c_sda } ];  # KUP_RESERVED_SDA
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Expansion header.

# LVDS signals, bank 66.
set_property IOSTANDARD LVDS        [ get_ports io_exp_lvds_* ];
#set_property DIFF_TERM_ADV TERM_100 [ get_ports io_exp_lvds_* ];
set_property PACKAGE_PIN  AT16  [ get_ports { io_exp_lvds_p[0]  } ];    # KUP_EXP_LVDS_P_0
set_property PACKAGE_PIN  AU16  [ get_ports { io_exp_lvds_n[0]  } ];    # KUP_EXP_LVDS_P_0
set_property PACKAGE_PIN  AV16  [ get_ports { io_exp_lvds_p[1]  } ];    # KUP_EXP_LVDS_P_1
set_property PACKAGE_PIN  AV15  [ get_ports { io_exp_lvds_n[1]  } ];    # KUP_EXP_LVDS_P_1
set_property PACKAGE_PIN  AP17  [ get_ports { io_exp_lvds_p[2]  } ];    # KUP_EXP_LVDS_P_2
set_property PACKAGE_PIN  AR17  [ get_ports { io_exp_lvds_n[2]  } ];    # KUP_EXP_LVDS_P_2
set_property PACKAGE_PIN  AU17  [ get_ports { io_exp_lvds_p[3]  } ];    # KUP_EXP_LVDS_P_3
set_property PACKAGE_PIN  AV17  [ get_ports { io_exp_lvds_n[3]  } ];    # KUP_EXP_LVDS_P_3
set_property PACKAGE_PIN  AR16  [ get_ports { io_exp_lvds_p[4]  } ];    # KUP_EXP_LVDS_P_4
set_property PACKAGE_PIN  AR15  [ get_ports { io_exp_lvds_n[4]  } ];    # KUP_EXP_LVDS_P_4
set_property PACKAGE_PIN  AP18  [ get_ports { io_exp_lvds_p[5]  } ];    # KUP_EXP_LVDS_P_5
set_property PACKAGE_PIN  AR18  [ get_ports { io_exp_lvds_n[5]  } ];    # KUP_EXP_LVDS_P_5
set_property PACKAGE_PIN  AR13  [ get_ports { io_exp_lvds_p[6]  } ];    # KUP_EXP_LVDS_P_6
set_property PACKAGE_PIN  AR12  [ get_ports { io_exp_lvds_n[6]  } ];    # KUP_EXP_LVDS_P_6
set_property PACKAGE_PIN  AU14  [ get_ports { io_exp_lvds_p[7]  } ];    # KUP_EXP_LVDS_P_7
set_property PACKAGE_PIN  AV14  [ get_ports { io_exp_lvds_n[7]  } ];    # KUP_EXP_LVDS_P_7
set_property PACKAGE_PIN  AP15  [ get_ports { io_exp_lvds_p[8]  } ];    # KUP_EXP_LVDS_P_8
set_property PACKAGE_PIN  AP14  [ get_ports { io_exp_lvds_n[8]  } ];    # KUP_EXP_LVDS_P_8
set_property PACKAGE_PIN  AU13  [ get_ports { io_exp_lvds_p[9]  } ];    # KUP_EXP_LVDS_P_9
set_property PACKAGE_PIN  AV12  [ get_ports { io_exp_lvds_n[9]  } ];    # KUP_EXP_LVDS_P_9
set_property PACKAGE_PIN  AP13  [ get_ports { io_exp_lvds_p[10] } ];    # KUP_EXP_LVDS_P_10
set_property PACKAGE_PIN  AP12  [ get_ports { io_exp_lvds_n[10] } ];    # KUP_EXP_LVDS_P_10

# Single-ended signals, bank 66.
set_property IOSTANDARD LVCMOS18 [ get_ports io_exp_se* ];
set_property PACKAGE_PIN  BA9   [ get_ports { io_exp_se[0]  } ];        # KUP_EXP_SE0
set_property PACKAGE_PIN  BB9   [ get_ports { io_exp_se[1]  } ];        # KUP_EXP_SE1
set_property PACKAGE_PIN  BA11  [ get_ports { io_exp_se[2]  } ];        # KUP_EXP_SE2
set_property PACKAGE_PIN  BA10  [ get_ports { io_exp_se[3]  } ];        # KUP_EXP_SE3
set_property PACKAGE_PIN  BB12  [ get_ports { io_exp_se[4]  } ];        # KUP_EXP_SE4
set_property PACKAGE_PIN  BB11  [ get_ports { io_exp_se[5]  } ];        # KUP_EXP_SE5
set_property PACKAGE_PIN  AY11  [ get_ports { io_exp_se[6]  } ];        # KUP_EXP_SE6
set_property PACKAGE_PIN  AY10  [ get_ports { io_exp_se[7]  } ];        # KUP_EXP_SE7
set_property PACKAGE_PIN  BA13  [ get_ports { io_exp_se[8]  } ];        # KUP_EXP_SE8
set_property PACKAGE_PIN  BB13  [ get_ports { io_exp_se[9]  } ];        # KUP_EXP_SE9
set_property PACKAGE_PIN  AY13  [ get_ports { io_exp_se[10] } ];        # KUP_EXP_SE10
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Debug header.

# LVDS signals, bank 66.
set_property IOSTANDARD LVDS        [ get_ports io_dbg_lvds_* ];
#set_property DIFF_TERM_ADV TERM_100 [ get_ports io_dbg_lvds_* ];
set_property PACKAGE_PIN  AW17  [ get_ports { io_dbg_lvds_p[0] } ];     # KUP_DBG_LVDS_P_0
set_property PACKAGE_PIN  AY17  [ get_ports { io_dbg_lvds_n[0] } ];     # KUP_DBG_LVDS_N_0
set_property PACKAGE_PIN  AW15  [ get_ports { io_dbg_lvds_p[1] } ];     # KUP_DBG_LVDS_P_1
set_property PACKAGE_PIN  AW14  [ get_ports { io_dbg_lvds_n[1] } ];     # KUP_DBG_LVDS_N_1

# Single-ended signals, bank 66.
set_property IOSTANDARD LVCMOS18 [ get_ports io_dbg_se* ];
set_property PACKAGE_PIN  AY12  [ get_ports { io_dbg_se[0] } ];         # KUP_DBG_SE0
set_property PACKAGE_PIN  BB17  [ get_ports { io_dbg_se[1] } ];         # KUP_DBG_SE1
set_property PACKAGE_PIN  BB16  [ get_ports { io_dbg_se[2] } ];         # KUP_DBG_SE2
set_property PACKAGE_PIN  BA16  [ get_ports { io_dbg_se[3] } ];         # KUP_DBG_SE3
set_property PACKAGE_PIN  BA15  [ get_ports { io_dbg_se[4] } ];         # KUP_DBG_SE4
set_property PACKAGE_PIN  BA14  [ get_ports { io_dbg_se[5] } ];         # KUP_DBG_SE5
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Inter-FPGA connections (KU15P - ZU11EG).

# LVDS connections, bank 64.
set_property IOSTANDARD LVDS        [ get_ports io_k2z_lvds_* ];
set_property DIFF_TERM_ADV TERM_100 [ get_ports io_k2z_lvds_* ];
set_property PACKAGE_PIN  BB22  [ get_ports { io_k2z_lvds_p[0]  } ];    # INTER_FPGA_LVDS_P_0
set_property PACKAGE_PIN  BB21  [ get_ports { io_k2z_lvds_n[0]  } ];    # INTER_FPGA_LVDS_N_0
set_property PACKAGE_PIN  AW22  [ get_ports { io_k2z_lvds_p[1]  } ];    # INTER_FPGA_LVDS_P_1
set_property PACKAGE_PIN  AY22  [ get_ports { io_k2z_lvds_n[1]  } ];    # INTER_FPGA_LVDS_N_1
set_property PACKAGE_PIN  BB19  [ get_ports { io_k2z_lvds_p[2]  } ];    # INTER_FPGA_LVDS_P_2
set_property PACKAGE_PIN  BB18  [ get_ports { io_k2z_lvds_n[2]  } ];    # INTER_FPGA_LVDS_N_2
set_property PACKAGE_PIN  AY21  [ get_ports { io_k2z_lvds_p[3]  } ];    # INTER_FPGA_LVDS_P_3
set_property PACKAGE_PIN  AY20  [ get_ports { io_k2z_lvds_n[3]  } ];    # INTER_FPGA_LVDS_N_3
set_property PACKAGE_PIN  BA21  [ get_ports { io_k2z_lvds_p[4]  } ];    # INTER_FPGA_LVDS_P_4
set_property PACKAGE_PIN  BA20  [ get_ports { io_k2z_lvds_n[4]  } ];    # INTER_FPGA_LVDS_N_4
set_property PACKAGE_PIN  BA19  [ get_ports { io_k2z_lvds_p[5]  } ];    # INTER_FPGA_LVDS_P_5
set_property PACKAGE_PIN  BA18  [ get_ports { io_k2z_lvds_n[5]  } ];    # INTER_FPGA_LVDS_N_5
set_property PACKAGE_PIN  AU22  [ get_ports { io_k2z_lvds_p[6]  } ];    # INTER_FPGA_LVDS_P_6
set_property PACKAGE_PIN  AV21  [ get_ports { io_k2z_lvds_n[6]  } ];    # INTER_FPGA_LVDS_N_6
set_property PACKAGE_PIN  AV19  [ get_ports { io_k2z_lvds_p[7]  } ];    # INTER_FPGA_LVDS_P_7
set_property PACKAGE_PIN  AW18  [ get_ports { io_k2z_lvds_n[7]  } ];    # INTER_FPGA_LVDS_N_7
set_property PACKAGE_PIN  AW20  [ get_ports { io_k2z_lvds_p[8]  } ];    # INTER_FPGA_LVDS_P_8
set_property PACKAGE_PIN  AW19  [ get_ports { io_k2z_lvds_n[8]  } ];    # INTER_FPGA_LVDS_N_8
set_property PACKAGE_PIN  AT18  [ get_ports { io_k2z_lvds_p[9]  } ];    # INTER_FPGA_LVDS_P_9
set_property PACKAGE_PIN  AU18  [ get_ports { io_k2z_lvds_n[9]  } ];    # INTER_FPGA_LVDS_N_9
set_property PACKAGE_PIN  AU21  [ get_ports { io_k2z_lvds_p[10] } ];    # INTER_FPGA_LVDS_P_10
set_property PACKAGE_PIN  AV20  [ get_ports { io_k2z_lvds_n[10] } ];    # INTER_FPGA_LVDS_N_10
set_property PACKAGE_PIN  AT19  [ get_ports { io_k2z_lvds_p[11] } ];    # INTER_FPGA_LVDS_P_11
set_property PACKAGE_PIN  AU19  [ get_ports { io_k2z_lvds_n[11] } ];    # INTER_FPGA_LVDS_N_11
set_property PACKAGE_PIN  AR21  [ get_ports { io_k2z_lvds_p[12] } ];    # INTER_FPGA_LVDS_P_12
set_property PACKAGE_PIN  AT21  [ get_ports { io_k2z_lvds_n[12] } ];    # INTER_FPGA_LVDS_N_12
set_property PACKAGE_PIN  AR20  [ get_ports { io_k2z_lvds_p[13] } ];    # INTER_FPGA_LVDS_P_13
set_property PACKAGE_PIN  AT20  [ get_ports { io_k2z_lvds_n[13] } ];    # INTER_FPGA_LVDS_N_13
set_property PACKAGE_PIN  AM22  [ get_ports { io_k2z_lvds_p[14] } ];    # INTER_FPGA_LVDS_P_14
set_property PACKAGE_PIN  AN22  [ get_ports { io_k2z_lvds_n[14] } ];    # INTER_FPGA_LVDS_N_14
set_property PACKAGE_PIN  AP22  [ get_ports { io_k2z_lvds_p[15] } ];    # INTER_FPGA_LVDS_P_15
set_property PACKAGE_PIN  AR22  [ get_ports { io_k2z_lvds_n[15] } ];    # INTER_FPGA_LVDS_N_15
set_property PACKAGE_PIN  AN21  [ get_ports { io_k2z_lvds_p[16] } ];    # INTER_FPGA_LVDS_P_16
set_property PACKAGE_PIN  AN20  [ get_ports { io_k2z_lvds_n[16] } ];    # INTER_FPGA_LVDS_N_16
set_property PACKAGE_PIN  AP20  [ get_ports { io_k2z_lvds_p[17] } ];    # INTER_FPGA_LVDS_P_17
set_property PACKAGE_PIN  AP19  [ get_ports { io_k2z_lvds_n[17] } ];    # INTER_FPGA_LVDS_N_17
set_property PACKAGE_PIN  AK21  [ get_ports { io_k2z_lvds_p[18] } ];    # INTER_FPGA_LVDS_P_18
set_property PACKAGE_PIN  AL21  [ get_ports { io_k2z_lvds_n[18] } ];    # INTER_FPGA_LVDS_N_18
set_property PACKAGE_PIN  AL19  [ get_ports { io_k2z_lvds_p[19] } ];    # INTER_FPGA_LVDS_P_19
set_property PACKAGE_PIN  AM19  [ get_ports { io_k2z_lvds_n[19] } ];    # INTER_FPGA_LVDS_N_19
set_property PACKAGE_PIN  AJ22  [ get_ports { io_k2z_lvds_p[20] } ];    # INTER_FPGA_LVDS_P_20
set_property PACKAGE_PIN  AK22  [ get_ports { io_k2z_lvds_n[20] } ];    # INTER_FPGA_LVDS_N_20
set_property PACKAGE_PIN  AK20  [ get_ports { io_k2z_lvds_p[21] } ];    # INTER_FPGA_LVDS_P_21
set_property PACKAGE_PIN  AL20  [ get_ports { io_k2z_lvds_n[21] } ];    # INTER_FPGA_LVDS_N_21
set_property PACKAGE_PIN  AJ23  [ get_ports { io_k2z_lvds_p[22] } ];    # INTER_FPGA_LVDS_P_22
set_property PACKAGE_PIN  AK23  [ get_ports { io_k2z_lvds_n[22] } ];    # INTER_FPGA_LVDS_N_22
set_property PACKAGE_PIN  AJ20  [ get_ports { io_k2z_lvds_p[23] } ];    # INTER_FPGA_LVDS_P_23
set_property PACKAGE_PIN  AJ19  [ get_ports { io_k2z_lvds_n[23] } ];    # INTER_FPGA_LVDS_N_23

# Single-ended connections, bank 67.
set_property IOSTANDARD LVCMOS18 [ get_ports io_k2z_se* ];
set_property PACKAGE_PIN  BB28  [ get_ports { io_k2z_se[0]  } ];        # INTER_FPGA_SE0
set_property PACKAGE_PIN  BB29  [ get_ports { io_k2z_se[1]  } ];        # INTER_FPGA_SE1
set_property PACKAGE_PIN  AY28  [ get_ports { io_k2z_se[2]  } ];        # INTER_FPGA_SE2
set_property PACKAGE_PIN  BA28  [ get_ports { io_k2z_se[3]  } ];        # INTER_FPGA_SE3
set_property PACKAGE_PIN  BA29  [ get_ports { io_k2z_se[4]  } ];        # INTER_FPGA_SE4
set_property PACKAGE_PIN  BA30  [ get_ports { io_k2z_se[5]  } ];        # INTER_FPGA_SE5
set_property PACKAGE_PIN  AW28  [ get_ports { io_k2z_se[6]  } ];        # INTER_FPGA_SE6
set_property PACKAGE_PIN  AW29  [ get_ports { io_k2z_se[7]  } ];        # INTER_FPGA_SE7
set_property PACKAGE_PIN  BA31  [ get_ports { io_k2z_se[8]  } ];        # INTER_FPGA_SE8
set_property PACKAGE_PIN  BB31  [ get_ports { io_k2z_se[9]  } ];        # INTER_FPGA_SE9
set_property PACKAGE_PIN  AY30  [ get_ports { io_k2z_se[10] } ];        # INTER_FPGA_SE10
set_property PACKAGE_PIN  AY31  [ get_ports { io_k2z_se[11] } ];        # INTER_FPGA_SE11
set_property PACKAGE_PIN  AV30  [ get_ports { io_k2z_se[12] } ];        # INTER_FPGA_SE12
set_property PACKAGE_PIN  AV31  [ get_ports { io_k2z_se[13] } ];        # INTER_FPGA_SE13
set_property PACKAGE_PIN  AT28  [ get_ports { io_k2z_se[14] } ];        # INTER_FPGA_SE14
set_property PACKAGE_PIN  AU28  [ get_ports { io_k2z_se[15] } ];        # INTER_FPGA_SE15
set_property PACKAGE_PIN  AU32  [ get_ports { io_k2z_se[16] } ];        # INTER_FPGA_SE16
set_property PACKAGE_PIN  AV32  [ get_ports { io_k2z_se[17] } ];        # INTER_FPGA_SE17
set_property PACKAGE_PIN  AU29  [ get_ports { io_k2z_se[18] } ];        # INTER_FPGA_SE18
set_property PACKAGE_PIN  AV29  [ get_ports { io_k2z_se[19] } ];        # INTER_FPGA_SE19
set_property PACKAGE_PIN  AT31  [ get_ports { io_k2z_se[20] } ];        # INTER_FPGA_SE20
set_property PACKAGE_PIN  AU31  [ get_ports { io_k2z_se[21] } ];        # INTER_FPGA_SE21
set_property PACKAGE_PIN  AT29  [ get_ports { io_k2z_se[22] } ];        # INTER_FPGA_SE22
set_property PACKAGE_PIN  AT30  [ get_ports { io_k2z_se[23] } ];        # INTER_FPGA_SE23
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Other inputs and outputs.

# KU15P user LEDs on the front panel of the Command Module.
set_property IOSTANDARD LVCMOS33 [ get_ports o_led* ];
set_property PACKAGE_PIN  C12   [ get_ports { o_led[0] } ];             # KUP_USER_LED0
set_property PACKAGE_PIN  B11   [ get_ports { o_led[1] } ];             # KUP_USER_LED1
set_property PACKAGE_PIN  B13   [ get_ports { o_led[2] } ];             # KUP_USER_LED2
set_property PACKAGE_PIN  B12   [ get_ports { o_led[3] } ];             # KUP_USER_LED3
set_property PACKAGE_PIN  E12   [ get_ports { o_led[4] } ];             # KUP_USER_LED4
set_property PACKAGE_PIN  D12   [ get_ports { o_led[5] } ];             # KUP_USER_LED5
set_property PACKAGE_PIN  E13   [ get_ports { o_led[6] } ];             # KUP_USER_LED6
set_property PACKAGE_PIN  D13   [ get_ports { o_led[7] } ];             # KUP_USER_LED7

# What to do about the Xilinx system monitor I2C pins???
set_property IOSTANDARD LVCMOS18 [ get_ports io_sysmon_i2c_* ];
set_property PACKAGE_PIN  AL24  [ get_ports { io_sysmon_i2c_scl } ];    # KUP_SYSMON_SCL_1V8
set_property PACKAGE_PIN  AL25  [ get_ports { io_sysmon_i2c_sda } ];    # KUP_SYSMON_SDA_1V8
# -------------------------------------------------------------------

