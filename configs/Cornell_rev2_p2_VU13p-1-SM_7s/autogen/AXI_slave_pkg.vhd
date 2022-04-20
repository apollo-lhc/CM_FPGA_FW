library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package AXISlaveAddrPkg is
constant AXI_ADDR_F2_IO : unsigned(31 downto 0) := x"83002000";
constant AXI_ADDR_F2_SYS_MGMT : unsigned(31 downto 0) := x"83001000";
constant AXI_ADDR_F2_CM_FW_INFO : unsigned(31 downto 0) := x"83003000";
constant AXI_ADDR_F2_IPBUS : unsigned(31 downto 0) := x"82000000";
constant AXI_ADDR_F2_C2C_INTF : unsigned(31 downto 0) := x"83010000";
constant AXI_ADDR_CM1_PB_UART : unsigned(31 downto 0) := x"83008000";
-- ranges
constant AXI_RANGE_F2_IO : unsigned(31 downto 0) :=  x"00001000";
constant AXI_RANGE_F2_SYS_MGMT : unsigned(31 downto 0) :=  x"00001000";
constant AXI_RANGE_F2_CM_FW_INFO : unsigned(31 downto 0) :=  x"00001000";
constant AXI_RANGE_F2_IPBUS : unsigned(31 downto 0) :=  x"01000000";
constant AXI_RANGE_F2_C2C_INTF : unsigned(31 downto 0) :=  x"00010000";
constant AXI_RANGE_CM1_PB_UART : unsigned(31 downto 0) :=  x"00001000";
end package AXISlaveAddrPkg;
