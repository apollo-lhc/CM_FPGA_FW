#set the FPGA part number
set FPGA_part xcvu13p-flga2577-1-e

##for c2c
set C2C V_C2C
set C2C_PHY ${C2C}_PHY
set C2CB V_C2CB
set C2CB_PHY ${C2CB}_PHY

#enable remote device tree entries
#also set them to be 64bit values
global REMOTE_C2C
global REMOTE_C2C_64
set REMOTE_C2C 1
set REMOTE_C2C_64 1

set top top

set outputDir ./

