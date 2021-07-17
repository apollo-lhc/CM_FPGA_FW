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
  signal Ctrl             :  SPYBUFFER_TEST_Ctrl_t := DEFAULT_SPYBUFFER_TEST_CTRL_t ;
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

 

 spybuffer_inst : entity work.spybuffer
      generic map (
        DATA_WIDTH_A    => 32,
        DATA_WIDTH_B    => 32,
        SPY_MEM_WIDTH_A => 8,
        SPY_MEM_WIDTH_B => 8,
        FC_FIFO_WIDTH   => 4,
        EL_MEM_SIZE     => 16,
        EL_MEM_WIDTH    => 8,
        PASSTHROUGH     => 1,
        SPY_META_DATA_WIDTH => 32
      )
      port map (
        rclock                => Ctrl.MEM1.clk, 
        wclock                => Ctrl.MEM1.clk, 
        rresetbar             => reset_axi_n, 
        wresetbar             => reset_axi_n, 
        write_data            => trig_write_data,
        write_enable          => trig_en,
        read_data             => open,
        read_enable           => open,
        almost_full           => Mon.STATUS_FLAG(1 downto 1), 
        empty                 => Mon.STATUS_FLAG(0 downto 0),
        freeze                => Ctrl.FREEZE,
        playback              => Ctrl.PLAYBACK,
        spy_clock             => Ctrl.MEM1.clk, 
        spy_addr              => Ctrl.MEM1.address, 
        spy_write_enable      => Ctrl.MEM1.wr_enable,
        spy_write_data        => Ctrl.MEM1.wr_data,
        spy_data              => Mon.MEM1.rd_data, 
        spy_clock_meta        => Ctrl.LEVEL_TEST.MEM.clk,
        spy_meta_addr         => Ctrl.LEVEL_TEST.MEM.address,
        spy_meta_read_data    => Mon.LEVEL_TEST.MEM.rd_data,
        spy_meta_write_data   =>  Ctrl.LEVEL_TEST.MEM.wr_data,
        spy_meta_wen          =>  Ctrl.LEVEL_TEST.MEM.wr_enable 
      );

 

end architecture behavioral;
