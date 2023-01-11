library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package AXISlaveAddrPkg is
constant AXI_ADDR_DEBUG_8B10B : unsigned(31 downto 0) := x"B1100000";
constant AXI_ADDR_F1_IO : unsigned(31 downto 0) := x"B1020000";
constant AXI_ADDR_F1_SYS_MGMT : unsigned(31 downto 0) := x"B1001000";
constant AXI_ADDR_F1_CM_FW_INFO : unsigned(31 downto 0) := x"B1002000";
constant AXI_ADDR_F1_IPBUS : unsigned(31 downto 0) := x"B0000000";
constant AXI_ADDR_F1_C2C_INTF : unsigned(31 downto 0) := x"B1010000";
constant AXI_ADDR_CM1_PB_UART : unsigned(31 downto 0) := x"B1008000";
-- ranges
constant AXI_RANGE_DEBUG_8B10B : unsigned(31 downto 0) :=  x"00040000";
constant AXI_RANGE_F1_IO : unsigned(31 downto 0) :=  x"00004000";
constant AXI_RANGE_F1_SYS_MGMT : unsigned(31 downto 0) :=  x"00001000";
constant AXI_RANGE_F1_CM_FW_INFO : unsigned(31 downto 0) :=  x"00001000";
constant AXI_RANGE_F1_IPBUS : unsigned(31 downto 0) :=  x"01000000";
constant AXI_RANGE_F1_C2C_INTF : unsigned(31 downto 0) :=  x"00010000";
constant AXI_RANGE_CM1_PB_UART : unsigned(31 downto 0) :=  x"00001000";
end package AXISlaveAddrPkg;
