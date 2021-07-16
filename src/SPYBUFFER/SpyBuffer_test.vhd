library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.AXIRegPkg.all;

use work.types.all;
use work.SPYBUFFER_TEST_Ctrl.all;


--Library UNISIM;
--use UNISIM.vcomponents.all;


entity spybuffer_test is
  
  port (
    clk_axi         : in  std_logic;
    reset_axi_n     : in  std_logic;
    readMOSI        : in  AXIReadMOSI;
    readMISO        : out AXIReadMISO := DefaultAXIReadMISO;
    writeMOSI       : in  AXIWriteMOSI;
    writeMISO       : out AXIWriteMISO := DefaultAXIWriteMISO
    );
end entity spybuffer_test;

architecture behavioral of spybuffer_test is
  signal Mon              :  SPYBUFFER_TEST_Mon_t;
  signal Ctrl             :  SPYBUFFER_TEST_Ctrl_t;
  signal trig_write_data  :  std_logic_vector(31 downto 0) := (others => '0');
  signal trig_en          :  std_logic := '0';
  signal spy_meta_addr    : std_logic_vector(11 downto 0) := (others => '0');
  signal spy_meta_wdata   : std_logic_vector(31 downto 0) := (others => '0');
  signal spy_meta_wen     : std_logic := '0';
begin  -- architecture behavioral

  -------------------------------------------------------------------------------
  -- AXI 
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  SPYBUFFER_TEST_interface_1: entity work.SPYBUFFER_TEST_interface
    port map (
      clk_axi         => clk_axi,
      reset_axi_n     => reset_axi_n,
      slave_readMOSI  => readMOSI,
      slave_readMISO  => readMISO,
      slave_writeMOSI => writeMOSI,
      slave_writeMISO => writeMISO,
      Mon             => Mon,
      Ctrl            => Ctrl);

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

slc_spybuffer : entity work.spybuffer
      generic map (
        DATA_WIDTH_A    => 32,
        DATA_WIDTH_B    => 32,
        SPY_MEM_WIDTH_A => 12,
        SPY_MEM_WIDTH_B => 12,
        FC_FIFO_WIDTH   => 4,
        EL_MEM_SIZE     => 16,
        EL_MEM_WIDTH_A  => 8,
        EL_MEM_WIDTH_B  => 8,
        PASSTHROUGH     => 1
      )
      port map (
        rclock                => Ctrl.MEM1.clk, --clk,
        wclock                => Ctrl.MEM1.clk, --clk,
        rresetbar             => reset_axi_n, 
        wresetbar             => reset_axi_n, 
        write_data            => trig_write_data,
        write_enable          => trig_en,
        read_data             => open, --csf_seed,
        read_enable           => open, --trig_en,
        almost_full           => open, --o_spyslc_af,
        empty                 => open, --o_spyslc_empty,
        freeze                => open, --i_spyslc_freeze,
        playback              => open, --i_spyslc_playback,
        spy_clock             => Ctrl.MEM1.clk, --spy_clock,
        spy_addr              => Ctrl.MEM1.address, --i_spyslc_addr,
        spy_write_enable      => Ctrl.MEM1.wr_enable, --i_spyslc_pb_we,
        spy_write_data        => Ctrl.MEM1.wr_data, --_spyslc_pb_wdata,
       -- spy_read_enable       => i_spyslc_re,
        spy_data              => Mon.MEM1.rd_data, --o_spyslc_data,
        spy_clock_meta        => Ctrl.MEM1.clk, --spy_clock,
        spy_meta_addr         => spy_meta_addr,
        spy_meta_read_data    => open, --o_spyslc_meta_rdata,
        spy_meta_write_data   => spy_meta_wdata,
        spy_meta_wen          => spy_meta_wen


      );

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
