#set the FPGA part number
set FPGA_part xcku15p-ffva1760-2-e
#xc7Z045FFG676I-2

##for c2c
#set C2C K_C2C
#set C2C_PHY ${C2C}_PHY
#set C2CB K_C2CB
#set C2C_PHY ${C2CB}_PHY

#enable remote device tree entries
#also set them to be 64bit values
global REMOTE_C2C
global REMOTE_C2C_64
set REMOTE_C2C 1
set REMOTE_C2C_64 1

set top top

set outputDir ./

