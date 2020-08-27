library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.FW_INFO_Ctrl.all;
use work.AXIRegPkg.all;

use work.types.all;
use work.FW_TIMESTAMP.all;
use work.FW_VERSION.all;



Library UNISIM;
use UNISIM.vcomponents.all;


entity CM_K_info is
  
  port (
    clk_axi         : in  std_logic;
    reset_axi_n     : in  std_logic;
    readMOSI        : in  AXIReadMOSI;
    readMISO        : out AXIReadMISO := DefaultAXIReadMISO;
    writeMOSI       : in  AXIWriteMOSI;
    writeMISO       : out AXIWriteMISO := DefaultAXIWriteMISO
    );
end entity CM_K_info;

architecture behavioral of CM_K_info is
  signal Mon              :  FW_INFO_Mon_t;

begin  -- architecture behavioral

  -------------------------------------------------------------------------------
  -- AXI 
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  FW_INFO_interface_1: entity work.FW_INFO_interface
    port map (
      clk_axi         => clk_axi,
      reset_axi_n     => reset_axi_n,
      slave_readMOSI  => readMOSI,
      slave_readMISO  => readMISO,
      slave_writeMOSI => writeMOSI,
      slave_writeMISO => writeMISO,
      Mon             => Mon);

  Mon.GIT_VALID                     <= FW_HASH_VALID;
  Mon.GIT_HASH_1                    <= FW_HASH_1;
  Mon.GIT_HASH_2                    <= FW_HASH_2;
  Mon.GIT_HASH_3                    <= FW_HASH_3;
  Mon.GIT_HASH_4                    <= FW_HASH_4;
  Mon.GIT_HASH_5                    <= FW_HASH_5;
  Mon.BUILD_DATE.DAY                <= TS_DAY;
  Mon.BUILD_DATE.MONTH              <= TS_MONTH;
  Mon.BUILD_DATE.YEAR( 7 downto  0) <= TS_YEAR;
  Mon.BUILD_DATE.YEAR(15 downto  8) <= TS_CENT;
  Mon.BUILD_TIME.SEC                <= TS_SEC;
  Mon.BUILD_TIME.MIN                <= TS_MIN;
  Mon.BUILD_TIME.HOUR               <= TS_HOUR;
  

  
end architecture behavioral;
