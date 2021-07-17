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
use work.SPYBUFFER_TEST_Ctrl.all;
entity SPYBUFFER_TEST_interface is
  port (
    clk_axi          : in  std_logic;
    reset_axi_n      : in  std_logic;
    slave_readMOSI   : in  AXIReadMOSI;
    slave_readMISO   : out AXIReadMISO  := DefaultAXIReadMISO;
    slave_writeMOSI  : in  AXIWriteMOSI;
    slave_writeMISO  : out AXIWriteMISO := DefaultAXIWriteMISO;
    
    Mon              : in  SPYBUFFER_TEST_Mon_t;
    Ctrl             : out SPYBUFFER_TEST_Ctrl_t := DEFAULT_SPYBUFFER_TEST_CTRL_t 
        
    );
end entity SPYBUFFER_TEST_interface;
architecture behavioral of SPYBUFFER_TEST_interface is
  signal localAddress       : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
  signal localRdData        : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData        : slv_32_t;
  signal localWrEn          : std_logic;
  signal localRdReq         : std_logic;
  signal
    localRdAck         : std_logic;
  signal regRdAck           : std_logic;

  
  constant BRAM_COUNT       : integer := 2;
  signal latchBRAM          : std_logic_vector(BRAM_COUNT-1 downto 0);
  signal delayLatchBRAM          : std_logic_vector(BRAM_COUNT-1 downto 0);
  constant BRAM_range       : int_array_t(0 to BRAM_COUNT-1) := (0 => 8
,			1 => 8);
  constant BRAM_addr        : slv32_array_t(0 to BRAM_COUNT-1) := (0 => x"00000100"
,			1 => x"00000400");
  signal BRAM_MOSI          : BRAMPortMOSI_array_t(0 to BRAM_COUNT-1);
  signal BRAM_MISO          : BRAMPortMISO_array_t(0 to BRAM_COUNT-1);
  
  
  signal reg_data :  slv32_array_t(integer range 0 to 1280);
  constant Default_reg_data : slv32_array_t(integer range 0 to 1280) := (others => x"00000000");
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
        case to_integer(unsigned(localAddress(10 downto 0))) is                                 --
        when 33 => --0x20
          localRdData(31 downto  0)  <=  Mon.STATUS_FLAG;        -- STATUS       
        when 768 => --0x300
          localRdData(31 downto  0)  <=  reg_data(768)(31 downto  0);      --


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
  Ctrl.FREEZE             <=  reg_data(32)(0 downto  0);
  Ctrl.PLAYBACK           <=  reg_data(32)(2 downto  1);        
  Ctrl.LEVEL_TEST.THING  <=  reg_data(768)(31 downto  0);     


  reg_writes: process (clk_axi, reset_axi_n) is
  begin  -- process reg_writes
    if reset_axi_n = '0' then                 -- asynchronous reset (active low)
      reg_data(32)(31 downto 3)   <= (others => '0');
      reg_data(32)(2 downto  0)   <=  DEFAULT_SPYBUFFER_TEST_CTRL_t.PLAYBACK & DEFAULT_SPYBUFFER_TEST_CTRL_t.FREEZE ;     
      reg_data(768)(31 downto  0)  <= DEFAULT_SPYBUFFER_TEST_CTRL_t.LEVEL_TEST.THING;

    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      

      
      if localWrEn = '1' then
        case to_integer(unsigned(localAddress(10 downto 0))) is
        when 32 => --0x20
          reg_data(32)(31 downto  0)   <=  localWrData(31 downto  0);      --      
        when 768 => --0x300
          reg_data(768)(31 downto  0)  <=  localWrData(31 downto  0);      --

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
        latchBRAM(iBRAM)               <= '0';
        BRAM_MOSI(iBRAM).enable        <= '0';
        BRAM_MISO(iBRAM).rd_data_valid <= '0';
      elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
        BRAM_MOSI(iBRAM).address <= localAddress;
        latchBRAM(iBRAM) <= '0';
        BRAM_MOSI(iBRAM).enable  <= '0';
        BRAM_MISO(iBRAM).rd_data_valid <= '0';
        if localAddress(10 downto BRAM_range(iBRAM)) = BRAM_addr(iBRAM)(10 downto BRAM_range(iBRAM)) then
          latchBRAM(iBRAM)         <= localRdReq;
          BRAM_MOSI(iBRAM).enable  <= '1';
        end if;
        if(latchBRAM(iBRAM) = '1') then
          BRAM_MISO(iBRAM).rd_data_valid <= '1';
        end if;
      end if;
    end process BRAM_read;
  end generate BRAM_reads;



  BRAM_asyncs: for iBRAM in 0 to BRAM_COUNT-1 generate
    BRAM_MOSI(iBRAM).clk     <= clk_axi;
    BRAM_MOSI(iBRAM).wr_data <= localWrData;
  end generate BRAM_asyncs;
  
  Ctrl.MEM1.clk       <=  BRAM_MOSI(0).clk;
  Ctrl.MEM1.enable    <=  BRAM_MOSI(0).enable;
  Ctrl.MEM1.wr_enable <=  BRAM_MOSI(0).wr_enable;
  Ctrl.MEM1.address   <=  BRAM_MOSI(0).address(8-1 downto 0);
  Ctrl.MEM1.wr_data   <=  BRAM_MOSI(0).wr_data(31 downto 0);

  Ctrl.LEVEL_TEST.MEM.clk       <=  BRAM_MOSI(1).clk;
  Ctrl.LEVEL_TEST.MEM.enable    <=  BRAM_MOSI(1).enable;
  Ctrl.LEVEL_TEST.MEM.wr_enable <=  BRAM_MOSI(1).wr_enable;
  Ctrl.LEVEL_TEST.MEM.address   <=  BRAM_MOSI(1).address(8-1 downto 0);
  Ctrl.LEVEL_TEST.MEM.wr_data   <=  BRAM_MOSI(1).wr_data(31 downto 0);


  BRAM_MISO(0).rd_data(31 downto 0) <= Mon.MEM1.rd_data;

  --BRAM_MISO(0).rd_data_valid <= Mon.MEM1.rd_data_valid;

  BRAM_MISO(1).rd_data(31 downto 0) <= Mon.LEVEL_TEST.MEM.rd_data;
 
  --BRAM_MISO(1).rd_data_valid <= Mon.LEVEL_TEST.MEM.rd_data_valid;



    

  BRAM_writes: for iBRAM in 0 to BRAM_COUNT-1 generate
    BRAM_write: process (clk_axi,reset_axi_n) is    
    begin  -- process BRAM_reads
      if reset_axi_n = '0' then
        BRAM_MOSI(iBRAM).wr_enable   <= '0';
      elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
        BRAM_MOSI(iBRAM).wr_enable   <= '0';
        if localAddress(10 downto BRAM_range(iBRAM)) = BRAM_addr(iBRAM)(10 downto BRAM_range(iBRAM)) then
          BRAM_MOSI(iBRAM).wr_enable   <= localWrEn;
        end if;
      end if;
    end process BRAM_write;
  end generate BRAM_writes;
  
 


  
end architecture behavioral;
