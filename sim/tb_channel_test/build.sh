#!/bin/bash

rm work-obj93.cf
ghdl -a --ieee=synopsys ../../src/misc/types.vhd
ghdl -a --ieee=synopsys ../../src/QuadTest/ChannelTest.vhd
ghdl -a --ieee=synopsys tb_channel_test.vhd
ghdl -e --ieee=synopsys tb_channel_test
ghdl -r --ieee=synopsys tb_channel_test --stop-time=30000ns --wave=test.ghw 



