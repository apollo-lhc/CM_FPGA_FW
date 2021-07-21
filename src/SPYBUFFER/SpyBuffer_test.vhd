library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.AXIRegPkg.all;

use work.types.all;
use work.SPYBUFFER_CTRL.all;


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
  signal Mon              :  SPYBUFFER_Mon_t;
  signal Ctrl             :  SPYBUFFER_Ctrl_t := DEFAULT_SPYBUFFER_CTRL_t ;
  signal trig_write_data  :  std_logic_vector(31 downto 0) := (others => '0');
  signal trig_en          :  std_logic := '0';
  signal spy_meta_addr    : std_logic_vector(11 downto 0) := (others => '0');
  signal spy_meta_wdata   : std_logic_vector(31 downto 0) := (others => '0');
  signal spy_meta_wen     : std_logic := '0';
begin  -- architecture behavioral

 SPY_MEM_read: process (clk_axi,reset_axi_n) is
    begin  -- process BRAM_reads
      if reset_axi_n = '0' then
        Mon.SPY_MEM.rd_data_valid <= '0';        
      elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
        Mon.SPY_MEM.rd_data_valid  <= '0';
        if Ctrl.SPY_MEM.enable = '1' then
          Mon.SPY_MEM.rd_data_valid <= '1';
        end if;
      end if;
    end process SPY_MEM_read;

 SPY_META_read: process (clk_axi,reset_axi_n) is
    begin  -- process BRAM_reads
      if reset_axi_n = '0' then
        Mon.SPY_META.rd_data_valid <= '0';        
      elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
        Mon.SPY_META.rd_data_valid  <= '0';
        if Ctrl.SPY_META.enable = '1' then
          Mon.SPY_META.rd_data_valid <= '1';
        end if;
      end if;
    end process SPY_META_read;

-------------------------------------------------------------------------------
  -- AXI 
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  SPYBUFFER_interface_inst: entity work.SPYBUFFER_interface
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
        rclock                => clk_axi,
        wclock                => clk_axi,
        rresetbar             => reset_axi_n, 
        wresetbar             => reset_axi_n, 
        write_data            => trig_write_data,
        write_enable          => trig_en,
        read_data             => open,
        read_enable           => open,
        almost_full           => Mon.SPY_STATUS(1 downto 1), 
        empty                 => Mon.SPY_STATUS(0 downto 0),
        freeze                => Ctrl.SPY_CTRL.FREEZE,
        playback              => Ctrl.SPY_CTRL.PLAYBACK,
        spy_clock             => clk_axi,
        spy_addr              => Ctrl.SPY_MEM.address, 
        spy_write_enable      => Ctrl.SPY_MEM.wr_enable,
        spy_write_data        => Ctrl.SPY_MEM.wr_data,
        spy_data              => Mon.SPY_MEM.rd_data, 
        spy_clock_meta        => clk_axi,
        spy_meta_addr         => Ctrl.SPY_META.address,
        spy_meta_read_data    => Mon.SPY_META.rd_data,
        spy_meta_write_data   =>  Ctrl.SPY_META.wr_data,
        spy_meta_wen          =>  Ctrl.SPY_META.wr_enable 
      );

 

end architecture behavioral;
