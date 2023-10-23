# 200 MHz oscillator
#create_clock -period 5.000 -waveform {0.000 2.5000} [get_nets clk_200]

# 40 MHz extracted clock
#create_clock -period 25.000 -waveform {0.000 12.5000} [get_nets amc13_clk_40]

set_clock_groups -asynchronous \
		 -group [get_clocks p_clk_200      -include_generated_clocks] \
		 -group [get_clocks TCDS_BP_clk_p  -include_generated_clocks]

#set_clock_groups -asynchronous
#		 -group [get_clocks p_clk_200 -include_generated_clocks] \
#		 -group [get_clocks c2csslave_wrapper_1/c2cSlave_i/F1_C2C_PHY/inst/c2cSlave_F1_C2C_PHY_0_core_i/c2cSlave_F1_C2C_PHY_0_wrapper_i/c2cSlave_F1_C2C_PHY_0_multi_gt_i/c2cSlave_F1_C2C_PHY_0_gt_i/inst/gen_gtwizard_gtye4_top.c2cSlave_F1_C2C_PHY_0_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_cpll_cal_gtye4.gen_cpll_cal_inst[0].gen_inst_cpll_cal.gtwizard_ultrascale_v1_7_9_gtye4_cpll_cal_inst/gtwizard_ultrascale_v1_7_9_gtye4_cpll_cal_tx_i/bufg_gt_txoutclkmon_inst/O -include_generated_clocks] \
#		 -asynchronous -group [get_clocks c2csslave_wrapper_1/c2cSlave_i/F1_C2CB_PHY/inst/c2cSlave_F1_C2CB_PHY_0_core_i/c2cSlave_F1_C2CB_PHY_0_wrapper_i/c2cSlave_F1_C2CB_PHY_0_multi_gt_i/c2cSlave_F1_C2CB_PHY_0_gt_i/inst/gen_gtwizard_gtye4_top.c2cSlave_F1_C2CB_PHY_0_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_cpll_cal_gtye4.gen_cpll_cal_inst[0].gen_inst_cpll_cal.gtwizard_ultrascale_v1_7_9_gtye4_cpll_cal_inst/gtwizard_ultrascale_v1_7_9_gtye4_cpll_cal_tx_i/bufg_gt_txoutclkmon_inst/O -include_generated_clocks] \
#		 -group [get_clocks TCDS_BP_clk_p      -include_generated_clocks]
#
#
