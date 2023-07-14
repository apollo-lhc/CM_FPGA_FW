# 200 MHz oscillator
create_clock -period 5.00 -name clock_async [get_ports clock_async_i_p]

# 40 MHz extracted clock
# create_clock -period 25.000 -waveform {0.000 12.5000} [get_nets amc13_clk_40]