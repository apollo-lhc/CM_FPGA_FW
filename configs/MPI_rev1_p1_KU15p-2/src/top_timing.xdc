# File: top_timing.xdc
# Auth: Dan Gastler, Boston University Physics
# Mod.: M. Fras, Electronics Division, MPI for Physics, Munich
# Date: 18 Dec 2020
# Rev.: 25 Mar 2021
#
# KU15P timing constraint file for the MPI Command Module (CM) demonstrator.
#



# 100 MHz system clock from crystal oscillator, bank 66.
create_clock -period 10.000 -waveform {0.000 5.000} [get_ports i_clk_100_p];            # 100 MHz.

# Clock from clock generator IC54 (SI5341A).
create_clock -period 3.125 -waveform {0.000 1.563} [get_ports i_clk_gen_p];             # 320 MHz.

# LHC clock from jitter cleaner IC56 (Si5345A).
create_clock -period 25.000 -waveform {0.000 12.500} [get_ports i_clk_lhc_p];           # 40 MHz.

# Recovered LHC clock from clock and data recovery chip IC46 (ADN2814ACPZ).
create_clock -period 12.500 -waveform {0.000 6.250} [get_ports i_clk_legacy_ttc_p];     # 80 MHz.

# Clock from SMA connectors X76 and X78, directly connected.
create_clock -period 3.125 -waveform {0.000 1.563} [get_ports i_clk_sma_direct_p];      # 320 MHz.

# Clock from SMA connectors X68 and X69, fed through jitter cleaner IC65.
create_clock -period 3.125 -waveform {0.000 1.563} [get_ports i_clk_sma_jc_p];          # 320 MHz.

