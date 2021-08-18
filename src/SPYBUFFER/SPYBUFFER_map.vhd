--This file was auto-generated.
--Modifications might be lost.
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use work.AXIRegWidthPkg.all;
use work.AXIRegPkg.all;
use work.types.all;
use work.BRAMPortPkg.all;
use work.SPYBUFFER_Ctrl.all;

entity SPYBUFFER_map is
  port (
    clk_axi          : in  std_logic;
    reset_axi_n      : in  std_logic;
    slave_readMOSI   : in  AXIReadMOSI;
    slave_readMISO   : out AXIReadMISO  := DefaultAXIReadMISO;
    slave_writeMOSI  : in  AXIWriteMOSI;
    slave_writeMISO  : out AXIWriteMISO := DefaultAXIWriteMISO;
    
    Mon              : in  SPYBUFFER_Mon_t;
    Ctrl             : out SPYBUFFER_Ctrl_t
        
    );
end entity SPYBUFFER_map;
architecture behavioral of SPYBUFFER_map is
  signal localAddress       : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
  signal localRdData        : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData        : slv_32_t;
  signal localWrEn          : std_logic;
  signal localRdReq         : std_logic;
  signal localRdAck         : std_logic;
  signal regRdAck           : std_logic;

  
  constant BRAM_COUNT       : integer := 2;
  signal latchBRAM          : std_logic_vector(BRAM_COUNT-1 downto 0);
  signal delayLatchBRAM          : std_logic_vector(BRAM_COUNT-1 downto 0);
  constant BRAM_range       : int_array_t(0 to BRAM_COUNT-1) := (0 => 8
,			1 => 8);
  constant BRAM_addr        : slv32_array_t(0 to BRAM_COUNT-1) := (0 => x"00000100"
,			1 => x"00000200");
  signal BRAM_MOSI          : BRAMPortMOSI_array_t(0 to BRAM_COUNT-1);
  signal BRAM_MISO          : BRAMPortMISO_array_t(0 to BRAM_COUNT-1);
  
  
  signal reg_data :  slv32_array_t(integer range 0 to 768);
  constant Default_reg_data : slv32_array_t(integer range 0 to 768) := (others => x"00000000");
begin  -- architecture behavioral

  -------------------------------------------------------------------------------
  -- AXI 
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  AXIRegBridge : entity work.axiLiteRegBlocking
    port map (
      clk_axi     => clk_axi,
      reset_axi_n => reset_axi_n,
      readMOSI    => slave_readMOSI,
      readMISO    => slave_readMISO,
      writeMOSI   => slave_writeMOSI,
      writeMISO   => slave_writeMISO,
      address     => localAddress,
      rd_data     => localRdData_latch,
      wr_data     => localWrData,
      write_en    => localWrEn,
      read_req    => localRdReq,
      read_ack    => localRdAck);

  -------------------------------------------------------------------------------
  -- Record read decoding
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------

  latch_reads: process (clk_axi,reset_axi_n) is
  begin  -- process latch_reads
    if reset_axi_n = '0' then
      localRdAck <= '0';
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      localRdAck <= '0';
      
      if regRdAck = '1' then
        localRdData_latch <= localRdData;
        localRdAck <= '1';
      elsif BRAM_MISO(0).rd_data_valid = '1' then
        localRdAck <= '1';
        localRdData_latch <= BRAM_MISO(0).rd_data;
elsif BRAM_MISO(1).rd_data_valid = '1' then
        localRdAck <= '1';
        localRdData_latch <= BRAM_MISO(1).rd_data;

      end if;
    end if;
  end process latch_reads;

  
  reads: process (clk_axi,reset_axi_n) is
  begin  -- process latch_reads
    if reset_axi_n = '0' then
      regRdAck <= '0';
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      regRdAck  <= '0';
      localRdData <= x"00000000";
      if localRdReq = '1' then
        regRdAck  <= '1';
        case to_integer(unsigned(localAddress(9 downto 0))) is
          
        when 1 => --0x1
          localRdData(31 downto  0)  <=  Mon.SPY_STATUS;      --


          when others =>
            regRdAck <= '0';
            localRdData <= x"00000000";
        end case;
      end if;
    end if;
  end process reads;


  -------------------------------------------------------------------------------
  -- Record write decoding
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------

  -- Register mapping to ctrl structures


  reg_writes: process (clk_axi, reset_axi_n) is
  begin  -- process reg_writes
    if reset_axi_n = '0' then                 -- asynchronous reset (active low)

    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      Ctrl.SPY_CTRL.FREEZE <= '0';
      Ctrl.SPY_CTRL.PLAYBACK <= (others => '0');
      

      
      if localWrEn = '1' then
        case to_integer(unsigned(localAddress(9 downto 0))) is
        when 0 => --0x0
          Ctrl.SPY_CTRL.FREEZE    <=  localWrData( 0);               
          Ctrl.SPY_CTRL.PLAYBACK  <=  localWrData( 2 downto  1);     

          when others => null;
        end case;
      end if;
    end if;
  end process reg_writes;



  
  -------------------------------------------------------------------------------
  -- BRAM decoding
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------

  BRAM_reads: for iBRAM in 0 to BRAM_COUNT-1 generate
    BRAM_read: process (clk_axi,reset_axi_n) is
    begin  -- process BRAM_reads
      if reset_axi_n = '0' then
        latchBRAM(iBRAM) <= '0';
        BRAM_MOSI(iBRAM).enable  <= '0';
      elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
        BRAM_MOSI(iBRAM).address <= localAddress;
        latchBRAM(iBRAM) <= '0';
        BRAM_MOSI(iBRAM).enable  <= '0';
        if localAddress(9 downto BRAM_range(iBRAM)) = BRAM_addr(iBRAM)(9 downto BRAM_range(iBRAM)) then
          latchBRAM(iBRAM) <= localRdReq;
          BRAM_MOSI(iBRAM).enable  <= '1';
        end if;
      end if;
    end process BRAM_read;
  end generate BRAM_reads;



  BRAM_asyncs: for iBRAM in 0 to BRAM_COUNT-1 generate
    BRAM_MOSI(iBRAM).clk     <= clk_axi;
    BRAM_MOSI(iBRAM).wr_data <= localWrData;
  end generate BRAM_asyncs;
  
  Ctrl.SPY_MEM.clk       <=  BRAM_MOSI(0).clk;
  Ctrl.SPY_MEM.enable    <=  BRAM_MOSI(0).enable;
  Ctrl.SPY_MEM.wr_enable <=  BRAM_MOSI(0).wr_enable;
  Ctrl.SPY_MEM.address   <=  BRAM_MOSI(0).address(8-1 downto 0);
  Ctrl.SPY_MEM.wr_data   <=  BRAM_MOSI(0).wr_data(32-1 downto 0);

  Ctrl.SPY_META.clk       <=  BRAM_MOSI(1).clk;
  Ctrl.SPY_META.enable    <=  BRAM_MOSI(1).enable;
  Ctrl.SPY_META.wr_enable <=  BRAM_MOSI(1).wr_enable;
  Ctrl.SPY_META.address   <=  BRAM_MOSI(1).address(8-1 downto 0);
  Ctrl.SPY_META.wr_data   <=  BRAM_MOSI(1).wr_data(32-1 downto 0);


  BRAM_MISO(0).rd_data(32-1 downto 0) <= Mon.SPY_MEM.rd_data;
  BRAM_MISO(0).rd_data(31 downto 32) <= (others => '0');
  BRAM_MISO(0).rd_data_valid <= Mon.SPY_MEM.rd_data_valid;

  BRAM_MISO(1).rd_data(32-1 downto 0) <= Mon.SPY_META.rd_data;
  BRAM_MISO(1).rd_data(31 downto 32) <= (others => '0');
  BRAM_MISO(1).rd_data_valid <= Mon.SPY_META.rd_data_valid;

    

  BRAM_writes: for iBRAM in 0 to BRAM_COUNT-1 generate
    BRAM_write: process (clk_axi,reset_axi_n) is    
    begin  -- process BRAM_reads
      if reset_axi_n = '0' then
        BRAM_MOSI(iBRAM).wr_enable   <= '0';
      elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
        BRAM_MOSI(iBRAM).wr_enable   <= '0';
        if localAddress(9 downto BRAM_range(iBRAM)) = BRAM_addr(iBRAM)(9 downto BRAM_range(iBRAM)) then
          BRAM_MOSI(iBRAM).wr_enable   <= localWrEn;
        end if;
      end if;
    end process BRAM_write;
  end generate BRAM_writes;


  
end architecture behavioral;