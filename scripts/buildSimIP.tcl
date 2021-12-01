set GCC_PATH /usr/bin
set QUESTASIM_PATH /work/Questa/2020.2_2/questasim/bin/
set DEST /work/Questa/2020.2_2/Xilinx/2020.2/


#compile_simlib -simulator questa -simulator_exec_path $QUESTASIM_PATH -gcc_exec_path $GCC_PATH -family all -language all -library all -dir $DEST
#compile_simlib -simulator questa -simulator_exec_path /work/Questa/2020.2_2/questasim/bin/ -gcc_exec_path /usr/bin -family all -language all -library all -dir {/work/dan/Apollo/CM_FPGA_FW/sim}
compile_simlib -simulator questa -simulator_exec_path /work/Questa/2020.2_2/questasim/bin/ -gcc_exec_path /usr/bin -family all -language all -library all -dir /work/Questa/2020.2_2/Xilinx/2020.2/
