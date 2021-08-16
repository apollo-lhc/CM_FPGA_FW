library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.AXIRegPkg.all;

use work.types.all;
use work.FW_TIMESTAMP.all;
use work.FW_VERSION.all;
use work.FW_FPGA.all;
use work.MEM_TEST_Ctrl.all;


--Library UNISIM;
--use UNISIM.vcomponents.all;


entity mem_test is
  
  port (
    clk_axi         : in  std_logic;
    reset_axi_n     : in  std_logic;
    readMOSI        : in  AXIReadMOSI;
    readMISO        : out AXIReadMISO := DefaultAXIReadMISO;
    writeMOSI       : in  AXIWriteMOSI;
    writeMISO       : out AXIWriteMISO := DefaultAXIWriteMISO
    );
end entity mem_test;

architecture behavioral of mem_test is
  signal Mon              :  MEM_TEST_Mon_t;
  signal Ctrl             :  MEM_TEST_Ctrl_t;

begin  -- architecture behavioral

  -------------------------------------------------------------------------------
  -- AXI 
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  MEM_TEST_interface_1: entity work.MEM_TEST_interface
    port map (
      clk_axi         => clk_axi,
      reset_axi_n     => reset_axi_n,
      slave_readMOSI  => readMOSI,
      slave_readMISO  => readMISO,
      slave_writeMOSI => writeMOSI,
      slave_writeMISO => writeMISO,
      Mon             => Mon,
      Ctrl            => Ctrl);

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
  Mon.FPGA.WORD_00(31 downto 24)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE( 4)),8));
  Mon.FPGA.WORD_00(23 downto 16)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE( 3)),8));
  Mon.FPGA.WORD_00(15 downto  8)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE( 2)),8));
  Mon.FPGA.WORD_00( 7 downto  0)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE( 1)),8));
  Mon.FPGA.WORD_01(31 downto 24)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE( 8)),8));
  Mon.FPGA.WORD_01(23 downto 16)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE( 7)),8));
  Mon.FPGA.WORD_01(15 downto  8)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE( 6)),8));
  Mon.FPGA.WORD_01( 7 downto  0)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE( 5)),8));
  Mon.FPGA.WORD_02(31 downto 24)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(12)),8)); 
  Mon.FPGA.WORD_02(23 downto 16)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(11)),8)); 
  Mon.FPGA.WORD_02(15 downto  8)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(10)),8)); 
  Mon.FPGA.WORD_02( 7 downto  0)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE( 9)),8));
  Mon.FPGA.WORD_03(31 downto 24)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(16)),8)); 
  Mon.FPGA.WORD_03(23 downto 16)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(15)),8)); 
  Mon.FPGA.WORD_03(15 downto  8)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(14)),8)); 
  Mon.FPGA.WORD_03( 7 downto  0)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(13)),8));
  Mon.FPGA.WORD_04(31 downto 24)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(20)),8)); 
  Mon.FPGA.WORD_04(23 downto 16)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(19)),8)); 
  Mon.FPGA.WORD_04(15 downto  8)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(18)),8)); 
  Mon.FPGA.WORD_04( 7 downto  0)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(17)),8));
  Mon.FPGA.WORD_05(31 downto 24)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(24)),8)); 
  Mon.FPGA.WORD_05(23 downto 16)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(23)),8)); 
  Mon.FPGA.WORD_05(15 downto  8)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(22)),8)); 
  Mon.FPGA.WORD_05( 7 downto  0)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(21)),8));
  Mon.FPGA.WORD_06(31 downto 24)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(28)),8)); 
  Mon.FPGA.WORD_06(23 downto 16)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(27)),8)); 
  Mon.FPGA.WORD_06(15 downto  8)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(26)),8)); 
  Mon.FPGA.WORD_06( 7 downto  0)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(25)),8));
  Mon.FPGA.WORD_07(31 downto 24)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(32)),8)); 
  Mon.FPGA.WORD_07(23 downto 16)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(31)),8)); 
  Mon.FPGA.WORD_07(15 downto  8)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(30)),8)); 
  Mon.FPGA.WORD_07( 7 downto  0)    <= std_logic_vector(to_unsigned(character'pos(FPGA_TYPE(29)),8));

  blockram: entity work.rams_sp_wf
    generic map (
      RAM_WIDTH => 13,
      RAM_DEPTH => 256)
    port map (
      clk   => Ctrl.MEM1.clk,
      we    => Ctrl.MEM1.wr_enable,
      en    => Ctrl.MEM1.enable,
      addr  => Ctrl.MEM1.address,
      di    => Ctrl.MEM1.wr_data,
      do    => Mon.MEM1.rd_data,
      do_valid => Mon.MEM1.rd_data_valid);

  other_blockram: entity work.rams_sp_wf
    generic map (
      RAM_WIDTH => 13,
      RAM_DEPTH => 256)
    port map (
      clk   => Ctrl.LEVEL_TEST.MEM.clk,
      en    => Ctrl.LEVEL_TEST.MEM.enable,
      we    => Ctrl.LEVEL_TEST.MEM.wr_enable,
      addr  => Ctrl.LEVEL_TEST.MEM.address,
      di    => Ctrl.LEVEL_TEST.MEM.wr_data,
      do    => Mon.LEVEL_TEST.MEM.rd_data,
      do_valid => Mon.LEVEL_TEST.MEM.rd_data_valid);

end architecture behavioral;
