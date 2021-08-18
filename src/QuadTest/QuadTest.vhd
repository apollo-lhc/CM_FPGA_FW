library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.axiRegPkg.all;
use work.QuadTest_Ctrl.all;
use work.types.all;

Library UNISIM;
use UNISIM.vcomponents.all;

use work.FF_K1_PKG.all;

entity QuadTest is
  port (
    clk_axi              : in  std_logic; --50 MHz
    clk_200              : in  std_logic;
    reset_axi_n          : in  std_logic;
    readMOSI             : in  AXIreadMOSI;
    readMISO             : out AXIreadMISO;
    writeMOSI            : in  AXIwriteMOSI;
    writeMISO            : out AXIwriteMISO); -- '0' for refclk0, '1' for refclk1

end entity QuadTest;

architecture behavioral of QuadTest is

  signal FF_K1_common_in : FF_K1_CommonIn;                        
  signal FF_K1_common_out : FF_K1_CommonOut;                       
  signal FF_K1_channel_in : FF_K1_ChannelIn_array_t(12 downto 1);  
  signal FF_K1_channel_out : FF_K1_ChannelOut_array_t(12 downto 1);
begin  -- architecture QuadTest
  reset <= not reset_axi_n;

  QuadTest_interface_1: entity work.QuadTest_interface
    port map (
      clk_axi         => clk_axi,
      reset_axi_n     => reset_axi_n,
      slave_readMOSI  => readMOSI,
      slave_readMISO  => readMISO,
      slave_writeMOSI => writeMOSI,
      slave_writeMISO => writeMISO,
      Mon             => Mon,
      Ctrl            => Ctrl);

  FF_K1_wrapper_1: entity work.FF_K1_wrapper
    port map (
      common_in   => FF_K1_common_in,
      common_out  => FF_K1_common_out,
      channel_in  => FF_K1_channel_in,
      channel_out => FF_K1_channel_out);
  ChannelTest_1: entity work.ChannelTest
    port map (
      clk         => clk,
      clk_axi     => clk_axi,
      reset       => reset,
      rx_data     => rx_data,
      rx_k_data   => rx_k_data,
      rt_data     => rt_data,
      rt_k_data   => rt_k_data,
      error_count => error_count);
  
end architecture behavioral;
