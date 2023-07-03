--This file was auto-generated.
--Modifications might be lost.
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use work.AXIRegWidthPkg.all;
use work.AXIRegPkg.all;
use work.types.all;

use work.IO_Ctrl.all;



entity IO_map is
  generic (
    READ_TIMEOUT     : integer := 2048;
    ALLOCATED_MEMORY_RANGE : integer
    );
  port (
    clk_axi          : in  std_logic;
    reset_axi_n      : in  std_logic;
    slave_readMOSI   : in  AXIReadMOSI;
    slave_readMISO   : out AXIReadMISO  := DefaultAXIReadMISO;
    slave_writeMOSI  : in  AXIWriteMOSI;
    slave_writeMISO  : out AXIWriteMISO := DefaultAXIWriteMISO;
    slave_rd_ack     : out std_logic;
    
    Mon              : in  IO_Mon_t;
    Ctrl             : out IO_Ctrl_t
        
    );
end entity IO_map;
architecture behavioral of IO_map is
  signal localAddress       : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
  signal localRdData        : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData        : slv_32_t;
  signal localWrEn          : std_logic;
  signal localRdReq         : std_logic;
  signal localRdAck         : std_logic;
  signal regRdAck           : std_logic;
  signal tcram_RdAck        : std_logic;
  signal tcram_regRdAck     : std_logic;

  
  
  signal reg_data :  slv32_array_t(integer range 0 to 809);
  constant Default_reg_data : slv32_array_t(integer range 0 to 809) := (others => x"00000000");
begin  -- architecture behavioral

  -------------------------------------------------------------------------------
  -- AXI 
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  assert ((4*809) <= ALLOCATED_MEMORY_RANGE)
    report "IO: Regmap addressing range " & integer'image(4*809) & " is outside of AXI mapped range " & integer'image(ALLOCATED_MEMORY_RANGE)
  severity ERROR;
  assert ((4*809) > ALLOCATED_MEMORY_RANGE)
    report "IO: Regmap addressing range " & integer'image(4*809) & " is inside of AXI mapped range " & integer'image(ALLOCATED_MEMORY_RANGE)
  severity NOTE;

  AXIRegBridge : entity work.axiLiteRegBlocking
    generic map (
      READ_TIMEOUT => READ_TIMEOUT
      )
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

        slave_rd_ack <= tcram_RdAck;

  -------------------------------------------------------------------------------
  -- Record read decoding
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------

  latch_reads: process (clk_axi,reset_axi_n) is
  begin  -- process latch_reads
    if reset_axi_n = '0' then
      localRdAck <= '0';
      tcram_RdAck <= '0';
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      localRdAck <= '0';
      tcram_RdAck <= '0';
      
      if regRdAck = '1' then
        localRdData_latch <= localRdData;
        localRdAck <= '1';
      
      end if;
 
      if tcram_regRdAck = '1' then
        tcram_RdAck <= '1';
      end if;
    end if;
  end process latch_reads;

  
  reads: process (clk_axi,reset_axi_n) is
  begin  -- process latch_reads
    if reset_axi_n = '0' then
      regRdAck <= '0';
      tcram_regRdAck <= '0';
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      regRdAck  <= '0';
      localRdData <= x"00000000";
      tcram_regRdAck  <= '0';
      if localRdReq = '1' then
        regRdAck  <= '1';
        case to_integer(unsigned(localAddress(9 downto 0))) is
          
        when 16 => --0x10
          localRdData( 0)            <=  Mon.CLK_200_LOCKED;               --
        when 512 => --0x200
          localRdData( 7 downto  0)  <=  reg_data(512)( 7 downto  0);      --
          localRdData(15 downto  8)  <=  reg_data(512)(15 downto  8);      --
          localRdData(23 downto 16)  <=  reg_data(512)(23 downto 16);      --
        when 769 => --0x301
          localRdData(14 downto  0)  <=  reg_data(769)(14 downto  0);      --
        when 770 => --0x302
          localRdData(31 downto  0)  <=  reg_data(770)(31 downto  0);      --
        when 771 => --0x303
          localRdData(31 downto  0)  <=  Mon.BRAM.RD_DATA;                 --
        when 787 => --0x313
          localRdData( 0)            <=  reg_data(787)( 0);                --
          localRdData( 1)            <=  reg_data(787)( 1);                --
          localRdData( 2)            <=  reg_data(787)( 2);                --
        when 788 => --0x314
          localRdData(14 downto  0)  <=  reg_data(788)(14 downto  0);      --
        when 789 => --0x315
          localRdData(14 downto  0)  <=  Mon.TCRAM.ADDR;                   --
        when 790 => --0x316
          localRdData(31 downto  0)  <=  reg_data(790)(31 downto  0);      --
        when 791 => --0x317
          localRdData(31 downto  0)  <=  Mon.TCRAM.RD_L1L2;                --
          tcram_regRdAck <= '1';
        when 792 => --0x318
          localRdData(31 downto  0)  <=  Mon.TCRAM.RD_L2L3;                --
          tcram_regRdAck <= '1';
        when 793 => --0x319
          localRdData(31 downto  0)  <=  Mon.TCRAM.RD_L3L4;                --
          tcram_regRdAck <= '1';
        when 794 => --0x31a
          localRdData(31 downto  0)  <=  Mon.TCRAM.RD_L5L6;                --
          tcram_regRdAck <= '1';
        when 795 => --0x31b
          localRdData(31 downto  0)  <=  Mon.TCRAM.RD_L1L2_L3;             --
          tcram_regRdAck <= '1';
        when 796 => --0x31c
          localRdData(31 downto  0)  <=  Mon.TCRAM.RD_L1L2_L4;             --
          tcram_regRdAck <= '1';
        when 797 => --0x31d
          localRdData(31 downto  0)  <=  Mon.TCRAM.RD_L1L2_L5;             --
          tcram_regRdAck <= '1';
        when 798 => --0x31e
          localRdData(31 downto  0)  <=  Mon.TCRAM.RD_L1L2_L6;             --
          tcram_regRdAck <= '1';
        when 799 => --0x31f
          localRdData(31 downto  0)  <=  Mon.TCRAM.RD_L2L3_L1;             --
          tcram_regRdAck <= '1';
        when 800 => --0x320
          localRdData(31 downto  0)  <=  Mon.TCRAM.RD_L2L3_L4;             --
          tcram_regRdAck <= '1';
        when 801 => --0x321
          localRdData(31 downto  0)  <=  Mon.TCRAM.RD_L2L3_L5;             --
          tcram_regRdAck <= '1';
        when 802 => --0x322
          localRdData(31 downto  0)  <=  Mon.TCRAM.RD_L3L4_L1;             --
          tcram_regRdAck <= '1';
        when 803 => --0x323
          localRdData(31 downto  0)  <=  Mon.TCRAM.RD_L3L4_L2;             --
          tcram_regRdAck <= '1';
        when 804 => --0x324
          localRdData(31 downto  0)  <=  Mon.TCRAM.RD_L3L4_L5;             --
          tcram_regRdAck <= '1';
        when 805 => --0x325
          localRdData(31 downto  0)  <=  Mon.TCRAM.RD_L3L4_L6;             --
          tcram_regRdAck <= '1';
        when 806 => --0x326
          localRdData(31 downto  0)  <=  Mon.TCRAM.RD_L5L6_L1;             --
          tcram_regRdAck <= '1';
        when 807 => --0x327
          localRdData(31 downto  0)  <=  Mon.TCRAM.RD_L5L6_L2;             --
          tcram_regRdAck <= '1';
        when 808 => --0x328
          localRdData(31 downto  0)  <=  Mon.TCRAM.RD_L5L6_L3;             --
          tcram_regRdAck <= '1';
        when 809 => --0x329
          localRdData(31 downto  0)  <=  Mon.TCRAM.RD_L5L6_L4;             --
          tcram_regRdAck <= '1';


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
  Ctrl.RGB.R            <=  reg_data(512)( 7 downto  0);     
  Ctrl.RGB.G            <=  reg_data(512)(15 downto  8);     
  Ctrl.RGB.B            <=  reg_data(512)(23 downto 16);     
  Ctrl.BRAM.ADDR        <=  reg_data(769)(14 downto  0);     
  Ctrl.BRAM.WR_DATA     <=  reg_data(770)(31 downto  0);     
  Ctrl.TCRAM.FF_MODE    <=  reg_data(787)( 0);               
  Ctrl.TCRAM.RST        <=  reg_data(787)( 1);               
  Ctrl.TCRAM.START      <=  reg_data(787)( 2);               
  Ctrl.TCRAM.BASE_ADDR  <=  reg_data(788)(14 downto  0);     
  Ctrl.TCRAM.WR_DATA    <=  reg_data(790)(31 downto  0);     


  reg_writes: process (clk_axi, reset_axi_n) is
  begin  -- process reg_writes
    if reset_axi_n = '0' then                 -- asynchronous reset (active low)
      reg_data(512)( 7 downto  0)  <= DEFAULT_IO_CTRL_t.RGB.R;
      reg_data(512)(15 downto  8)  <= DEFAULT_IO_CTRL_t.RGB.G;
      reg_data(512)(23 downto 16)  <= DEFAULT_IO_CTRL_t.RGB.B;
      reg_data(768)( 0)  <= DEFAULT_IO_CTRL_t.BRAM.WRITE;
      reg_data(769)(14 downto  0)  <= DEFAULT_IO_CTRL_t.BRAM.ADDR;
      reg_data(770)(31 downto  0)  <= DEFAULT_IO_CTRL_t.BRAM.WR_DATA;
      reg_data(784)( 0)  <= DEFAULT_IO_CTRL_t.TCRAM.WRITE;
      reg_data(785)( 0)  <= DEFAULT_IO_CTRL_t.TCRAM.WR_BASE;
      reg_data(786)( 0)  <= DEFAULT_IO_CTRL_t.TCRAM.RST_ADDR;
      reg_data(787)( 0)  <= DEFAULT_IO_CTRL_t.TCRAM.FF_MODE;
      reg_data(787)( 1)  <= DEFAULT_IO_CTRL_t.TCRAM.RST;
      reg_data(787)( 2)  <= DEFAULT_IO_CTRL_t.TCRAM.START;
      reg_data(788)(14 downto  0)  <= DEFAULT_IO_CTRL_t.TCRAM.BASE_ADDR;
      reg_data(790)(31 downto  0)  <= DEFAULT_IO_CTRL_t.TCRAM.WR_DATA;

    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      Ctrl.BRAM.WRITE <= '0';
      Ctrl.TCRAM.WRITE <= '0';
      Ctrl.TCRAM.WR_BASE <= '0';
      Ctrl.TCRAM.RST_ADDR <= '0';
      

      
      if localWrEn = '1' then
        case to_integer(unsigned(localAddress(9 downto 0))) is
        when 512 => --0x200
          reg_data(512)( 7 downto  0)  <=  localWrData( 7 downto  0);      --
          reg_data(512)(15 downto  8)  <=  localWrData(15 downto  8);      --
          reg_data(512)(23 downto 16)  <=  localWrData(23 downto 16);      --
        when 768 => --0x300
          Ctrl.BRAM.WRITE              <=  localWrData( 0);               
        when 769 => --0x301
          reg_data(769)(14 downto  0)  <=  localWrData(14 downto  0);      --
        when 770 => --0x302
          reg_data(770)(31 downto  0)  <=  localWrData(31 downto  0);      --
        when 784 => --0x310
          Ctrl.TCRAM.WRITE             <=  localWrData( 0);     
        when 785 => --0x311
          Ctrl.TCRAM.WR_BASE           <=  localWrData( 0);     
        when 786 => --0x312
          Ctrl.TCRAM.RST_ADDR          <=  localWrData( 0);     
        when 787 => --0x313
          reg_data(787)( 0)            <=  localWrData( 0);                --
          reg_data(787)( 1)            <=  localWrData( 1);                --
          reg_data(787)( 2)            <=  localWrData( 2);                --
        when 788 => --0x314
          reg_data(788)(14 downto  0)  <=  localWrData(14 downto  0);      --
        when 790 => --0x316
          reg_data(790)(31 downto  0)  <=  localWrData(31 downto  0);      --

          when others => null;
        end case;
      end if;
    end if;
  end process reg_writes;







  
end architecture behavioral;
