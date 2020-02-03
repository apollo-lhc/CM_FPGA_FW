library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.AXIRegPkg.all;

use work.types.all;
use work.K_IO_Ctrl.all;

entity BoardIO is
  generic (
    REG_COUNT_PWR_OF_2 : integer := 4;
    REG_OUT_DEFAULTS   : slv32_array_t);
  port (
    clk_axi     : in  std_logic;
    reset_axi_n : in  std_logic;
    readMOSI    : in  AXIReadMOSI;
    readMISO    : out AXIReadMISO := DefaultAXIReadMISO;
    writeMOSI   : in  AXIWriteMOSI;
    writeMISO   : out AXIWriteMISO := DefaultAXIWriteMISO;
    reg_out     : out slv32_array_t((2**REG_COUNT_PWR_OF_2)-1 downto 0);
    reg_in      : in  slv32_array_t((2**REG_COUNT_PWR_OF_2)-1 downto 0) := (others => x"00000000")
    );
end entity BoardIO;

architecture behavioral of BoardIO is
  signal Mon              :  K_IO_Mon_t;
  signal Ctrl             :  K_IO_Ctrl_t;

begin  -- architecture behavioral

  K_IO_interface_1: entity work.K_IO_interface
    port map (
      clk_axi         => clk_axi,
      reset_axi_n     => reset_axi_n,
      slave_readMOSI  => readMOSI,
      slave_readMISO  => readMISO,
      slave_writeMOSI => writeMOSI,
      slave_writeMISO => writeMISO,
      Mon             => Mon,
      Ctrl            => Ctrl);
  
  Mon.C2C.CONFIG_ERR      <= reg_in(0)(8);
  Mon.C2C.DO_CC           <= reg_in(0)(9);
  Mon.C2C.GT_PLL_LOCK     <= reg_in(0)(5);
  Mon.C2C.HARD_ERR        <= reg_in(0)(4);
  Mon.C2C.LANE_UP         <= reg_in(0)(3);
  Mon.C2C.LINK_RESET      <= reg_in(0)(2);
  Mon.C2C.LINK_STATUS     <= reg_in(0)(7);
  Mon.C2C.MMCM_NOT_LOCKED <= reg_in(0)(1);
  Mon.C2C.MULTIBIT_ERR    <= reg_in(0)(6);
  Mon.C2C.SOFT_ERR        <= reg_in(0)(0);

  reg_out(0)( 7 downto  0)  <= Ctrl.RGB.R;
  reg_out(0)(15 downto  8)  <= Ctrl.RGB.G;
  reg_out(0)(23 downto 16)  <= Ctrl.RGB.B;
  reg_out(0)(31 downto 24)  <= x"00";
  
  

  
end architecture behavioral;
