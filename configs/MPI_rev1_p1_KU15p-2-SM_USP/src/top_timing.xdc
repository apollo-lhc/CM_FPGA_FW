# 200 MHz oscillator
create_clock -period 10.000 -waveform {0.000 5.000} [get_nets p_clk_100]

# 40 MHz extracted clock
#create_clock -period 25.000 -waveform {0.000 12.5000} [get_nets amc13_clk_40]
