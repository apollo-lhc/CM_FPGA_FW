
#set the FPGA part number
set FPGA_part xcvu13p-flga2577-2-e

##for c2c
set C2C F1_C2C
set C2C_PHY ${C2C}_PHY
set C2CB F1_C2CB
set C2CB_PHY ${C2CB}_PHY

#create remote device tree entries, 64 bit
global REMOTE_C2C_64
set REMOTE_C2C_64 1


set top top

set outputDir ./

#set paths to track trigger sources
set TT_LUT_PATH ../src/tt_combined/emData/LUTsBarrel
set TT_IP_REPO_PATH ../src/tt_combined/IntegrationTests/ReducedCombinedConfig/script
