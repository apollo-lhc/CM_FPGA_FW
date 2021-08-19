
GHDL_FLAGS=--ieee=synopsys

WORK_FILES=../../src/misc/types.vhd ../../src/misc/pacd.vhd ../../src/misc/capture_CDC.vhd ../../src/misc/counter.vhd ../../src/misc/rate_counter.vhd ../../src/QuadTest/ChannelTest.vhd tb_channel_test.vhd

clean:
	@rm -f work-obj93.cf >& /dev/null
	@rm -f test.ghw >& /dev/null

work-obj93.cf : $(WORK_FILES)
	ghdl -a $(GHDL_FLAGS) $(WORK_FILES)
	ghdl -e $(GHDL_FLAGS) tb_channel_test

run : work-obj93.cf 	
	ghdl -r --ieee=synopsys tb_channel_test --stop-time=30000ns --wave=test.ghw

view : test.ghw
	gtkwave -W test.ghw 
