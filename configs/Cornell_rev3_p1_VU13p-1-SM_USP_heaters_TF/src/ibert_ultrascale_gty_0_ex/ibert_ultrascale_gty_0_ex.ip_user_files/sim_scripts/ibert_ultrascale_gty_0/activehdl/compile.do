vlib work
vlib activehdl

vlib activehdl/xpm
vlib activehdl/xil_defaultlib

vmap xpm activehdl/xpm
vmap xil_defaultlib activehdl/xil_defaultlib

vlog -work xpm  -sv2k12 "+incdir+../../../../ibert_ultrascale_gty_0_ex.gen/sources_1/ip/ibert_ultrascale_gty_0/hdl/verilog" "+incdir+../../../../ibert_ultrascale_gty_0_ex.gen/sources_1/ip/ibert_ultrascale_gty_0/synth" \
"/nfs/opt/Xilinx/Vivado/2020.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/nfs/opt/Xilinx/Vivado/2020.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"/nfs/opt/Xilinx/Vivado/2020.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../ibert_ultrascale_gty_0_ex.gen/sources_1/ip/ibert_ultrascale_gty_0/hdl/verilog" "+incdir+../../../../ibert_ultrascale_gty_0_ex.gen/sources_1/ip/ibert_ultrascale_gty_0/synth" \
"../../../../ibert_ultrascale_gty_0_ex.gen/sources_1/ip/ibert_ultrascale_gty_0/ibert_ultrascale_gty_0_sim_netlist.v" \

vlog -work xil_defaultlib \
"glbl.v"

