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

  
  
  signal reg_data :  slv32_array_t(integer range 0 to 2141);
  constant Default_reg_data : slv32_array_t(integer range 0 to 2141) := (others => x"00000000");
begin  -- architecture behavioral

  -------------------------------------------------------------------------------
  -- AXI 
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  assert ((4*2141) <= ALLOCATED_MEMORY_RANGE)
    report "IO: Regmap addressing range " & integer'image(4*2141) & " is outside of AXI mapped range " & integer'image(ALLOCATED_MEMORY_RANGE)
  severity ERROR;
  assert ((4*2141) > ALLOCATED_MEMORY_RANGE)
    report "IO: Regmap addressing range " & integer'image(4*2141) & " is inside of AXI mapped range " & integer'image(ALLOCATED_MEMORY_RANGE)
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
        case to_integer(unsigned(localAddress(11 downto 0))) is
          
        when 16 => --0x10
          localRdData( 0)            <=  Mon.CLK_200_LOCKED;                                   --
        when 512 => --0x200
          localRdData( 7 downto  0)  <=  reg_data(512)( 7 downto  0);                          --
          localRdData(15 downto  8)  <=  reg_data(512)(15 downto  8);                          --
          localRdData(23 downto 16)  <=  reg_data(512)(23 downto 16);                          --
        when 769 => --0x301
          localRdData(14 downto  0)  <=  reg_data(769)(14 downto  0);                          --
        when 770 => --0x302
          localRdData(31 downto  0)  <=  reg_data(770)(31 downto  0);                          --
        when 771 => --0x303
          localRdData(31 downto  0)  <=  Mon.BRAM.RD_DATA;                                     --
        when 1025 => --0x401
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(0).RX.USRCLK_FREQ;        --
        when 1026 => --0x402
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(0).RX.USRCLK2_FREQ;       --
        when 1028 => --0x404
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(0).TX.USRCLK_FREQ;        --
        when 1029 => --0x405
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(0).TX.USRCLK2_FREQ;       --
        when 1033 => --0x409
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(1).RX.USRCLK_FREQ;        --
        when 1034 => --0x40a
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(1).RX.USRCLK2_FREQ;       --
        when 1036 => --0x40c
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(1).TX.USRCLK_FREQ;        --
        when 1037 => --0x40d
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(1).TX.USRCLK2_FREQ;       --
        when 1041 => --0x411
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(2).RX.USRCLK_FREQ;        --
        when 1042 => --0x412
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(2).RX.USRCLK2_FREQ;       --
        when 1044 => --0x414
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(2).TX.USRCLK_FREQ;        --
        when 1045 => --0x415
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(2).TX.USRCLK2_FREQ;       --
        when 1049 => --0x419
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(3).RX.USRCLK_FREQ;        --
        when 1050 => --0x41a
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(3).RX.USRCLK2_FREQ;       --
        when 1052 => --0x41c
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(3).TX.USRCLK_FREQ;        --
        when 1053 => --0x41d
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(3).TX.USRCLK2_FREQ;       --
        when 1057 => --0x421
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(4).RX.USRCLK_FREQ;        --
        when 1058 => --0x422
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(4).RX.USRCLK2_FREQ;       --
        when 1060 => --0x424
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(4).TX.USRCLK_FREQ;        --
        when 1061 => --0x425
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(4).TX.USRCLK2_FREQ;       --
        when 1065 => --0x429
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(5).RX.USRCLK_FREQ;        --
        when 1066 => --0x42a
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(5).RX.USRCLK2_FREQ;       --
        when 1068 => --0x42c
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(5).TX.USRCLK_FREQ;        --
        when 1069 => --0x42d
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(5).TX.USRCLK2_FREQ;       --
        when 1073 => --0x431
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(6).RX.USRCLK_FREQ;        --
        when 1074 => --0x432
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(6).RX.USRCLK2_FREQ;       --
        when 1076 => --0x434
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(6).TX.USRCLK_FREQ;        --
        when 1077 => --0x435
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(6).TX.USRCLK2_FREQ;       --
        when 1081 => --0x439
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(7).RX.USRCLK_FREQ;        --
        when 1082 => --0x43a
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(7).RX.USRCLK2_FREQ;       --
        when 1084 => --0x43c
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(7).TX.USRCLK_FREQ;        --
        when 1085 => --0x43d
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(7).TX.USRCLK2_FREQ;       --
        when 1089 => --0x441
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(8).RX.USRCLK_FREQ;        --
        when 1090 => --0x442
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(8).RX.USRCLK2_FREQ;       --
        when 1092 => --0x444
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(8).TX.USRCLK_FREQ;        --
        when 1093 => --0x445
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(8).TX.USRCLK2_FREQ;       --
        when 1097 => --0x449
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(9).RX.USRCLK_FREQ;        --
        when 1098 => --0x44a
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(9).RX.USRCLK2_FREQ;       --
        when 1100 => --0x44c
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(9).TX.USRCLK_FREQ;        --
        when 1101 => --0x44d
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(9).TX.USRCLK2_FREQ;       --
        when 1105 => --0x451
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(10).RX.USRCLK_FREQ;       --
        when 1106 => --0x452
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(10).RX.USRCLK2_FREQ;      --
        when 1108 => --0x454
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(10).TX.USRCLK_FREQ;       --
        when 1109 => --0x455
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(10).TX.USRCLK2_FREQ;      --
        when 1113 => --0x459
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(11).RX.USRCLK_FREQ;       --
        when 1114 => --0x45a
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(11).RX.USRCLK2_FREQ;      --
        when 1116 => --0x45c
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(11).TX.USRCLK_FREQ;       --
        when 1117 => --0x45d
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(11).TX.USRCLK2_FREQ;      --
        when 2048 => --0x800
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B.CHANNEL(0).RX.DATA;                   --
        when 2049 => --0x801
          localRdData( 3 downto  0)  <=  Mon.DEBUG_8B10B.CHANNEL(0).RX.KDATA;                  --
          localRdData(11 downto  8)  <=  Mon.DEBUG_8B10B.CHANNEL(0).RX.VALID;                  --
          localRdData(16)            <=  Mon.DEBUG_8B10B.CHANNEL(0).RX.COMMA;                  --
          localRdData(27 downto 24)  <=  Mon.DEBUG_8B10B.CHANNEL(0).RX.DISP_ERR;               --
        when 2050 => --0x802
          localRdData( 0)            <=  reg_data(2050)( 0);                                   --
          localRdData( 1)            <=  reg_data(2050)( 1);                                   --
        when 2051 => --0x803
          localRdData(31 downto  0)  <=  reg_data(2051)(31 downto  0);                         --
        when 2052 => --0x804
          localRdData( 3 downto  0)  <=  reg_data(2052)( 3 downto  0);                         --
        when 2053 => --0x805
          localRdData( 0)            <=  reg_data(2053)( 0);                                   --
        when 2056 => --0x808
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B.CHANNEL(1).RX.DATA;                   --
        when 2057 => --0x809
          localRdData( 3 downto  0)  <=  Mon.DEBUG_8B10B.CHANNEL(1).RX.KDATA;                  --
          localRdData(11 downto  8)  <=  Mon.DEBUG_8B10B.CHANNEL(1).RX.VALID;                  --
          localRdData(16)            <=  Mon.DEBUG_8B10B.CHANNEL(1).RX.COMMA;                  --
          localRdData(27 downto 24)  <=  Mon.DEBUG_8B10B.CHANNEL(1).RX.DISP_ERR;               --
        when 2058 => --0x80a
          localRdData( 0)            <=  reg_data(2058)( 0);                                   --
          localRdData( 1)            <=  reg_data(2058)( 1);                                   --
        when 2059 => --0x80b
          localRdData(31 downto  0)  <=  reg_data(2059)(31 downto  0);                         --
        when 2060 => --0x80c
          localRdData( 3 downto  0)  <=  reg_data(2060)( 3 downto  0);                         --
        when 2061 => --0x80d
          localRdData( 0)            <=  reg_data(2061)( 0);                                   --
        when 2064 => --0x810
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B.CHANNEL(2).RX.DATA;                   --
        when 2065 => --0x811
          localRdData( 3 downto  0)  <=  Mon.DEBUG_8B10B.CHANNEL(2).RX.KDATA;                  --
          localRdData(11 downto  8)  <=  Mon.DEBUG_8B10B.CHANNEL(2).RX.VALID;                  --
          localRdData(16)            <=  Mon.DEBUG_8B10B.CHANNEL(2).RX.COMMA;                  --
          localRdData(27 downto 24)  <=  Mon.DEBUG_8B10B.CHANNEL(2).RX.DISP_ERR;               --
        when 2066 => --0x812
          localRdData( 0)            <=  reg_data(2066)( 0);                                   --
          localRdData( 1)            <=  reg_data(2066)( 1);                                   --
        when 2067 => --0x813
          localRdData(31 downto  0)  <=  reg_data(2067)(31 downto  0);                         --
        when 2068 => --0x814
          localRdData( 3 downto  0)  <=  reg_data(2068)( 3 downto  0);                         --
        when 2069 => --0x815
          localRdData( 0)            <=  reg_data(2069)( 0);                                   --
        when 2072 => --0x818
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B.CHANNEL(3).RX.DATA;                   --
        when 2073 => --0x819
          localRdData( 3 downto  0)  <=  Mon.DEBUG_8B10B.CHANNEL(3).RX.KDATA;                  --
          localRdData(11 downto  8)  <=  Mon.DEBUG_8B10B.CHANNEL(3).RX.VALID;                  --
          localRdData(16)            <=  Mon.DEBUG_8B10B.CHANNEL(3).RX.COMMA;                  --
          localRdData(27 downto 24)  <=  Mon.DEBUG_8B10B.CHANNEL(3).RX.DISP_ERR;               --
        when 2074 => --0x81a
          localRdData( 0)            <=  reg_data(2074)( 0);                                   --
          localRdData( 1)            <=  reg_data(2074)( 1);                                   --
        when 2075 => --0x81b
          localRdData(31 downto  0)  <=  reg_data(2075)(31 downto  0);                         --
        when 2076 => --0x81c
          localRdData( 3 downto  0)  <=  reg_data(2076)( 3 downto  0);                         --
        when 2077 => --0x81d
          localRdData( 0)            <=  reg_data(2077)( 0);                                   --
        when 2080 => --0x820
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B.CHANNEL(4).RX.DATA;                   --
        when 2081 => --0x821
          localRdData( 3 downto  0)  <=  Mon.DEBUG_8B10B.CHANNEL(4).RX.KDATA;                  --
          localRdData(11 downto  8)  <=  Mon.DEBUG_8B10B.CHANNEL(4).RX.VALID;                  --
          localRdData(16)            <=  Mon.DEBUG_8B10B.CHANNEL(4).RX.COMMA;                  --
          localRdData(27 downto 24)  <=  Mon.DEBUG_8B10B.CHANNEL(4).RX.DISP_ERR;               --
        when 2082 => --0x822
          localRdData( 0)            <=  reg_data(2082)( 0);                                   --
          localRdData( 1)            <=  reg_data(2082)( 1);                                   --
        when 2083 => --0x823
          localRdData(31 downto  0)  <=  reg_data(2083)(31 downto  0);                         --
        when 2084 => --0x824
          localRdData( 3 downto  0)  <=  reg_data(2084)( 3 downto  0);                         --
        when 2085 => --0x825
          localRdData( 0)            <=  reg_data(2085)( 0);                                   --
        when 2088 => --0x828
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B.CHANNEL(5).RX.DATA;                   --
        when 2089 => --0x829
          localRdData( 3 downto  0)  <=  Mon.DEBUG_8B10B.CHANNEL(5).RX.KDATA;                  --
          localRdData(11 downto  8)  <=  Mon.DEBUG_8B10B.CHANNEL(5).RX.VALID;                  --
          localRdData(16)            <=  Mon.DEBUG_8B10B.CHANNEL(5).RX.COMMA;                  --
          localRdData(27 downto 24)  <=  Mon.DEBUG_8B10B.CHANNEL(5).RX.DISP_ERR;               --
        when 2090 => --0x82a
          localRdData( 0)            <=  reg_data(2090)( 0);                                   --
          localRdData( 1)            <=  reg_data(2090)( 1);                                   --
        when 2091 => --0x82b
          localRdData(31 downto  0)  <=  reg_data(2091)(31 downto  0);                         --
        when 2092 => --0x82c
          localRdData( 3 downto  0)  <=  reg_data(2092)( 3 downto  0);                         --
        when 2093 => --0x82d
          localRdData( 0)            <=  reg_data(2093)( 0);                                   --
        when 2096 => --0x830
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B.CHANNEL(6).RX.DATA;                   --
        when 2097 => --0x831
          localRdData( 3 downto  0)  <=  Mon.DEBUG_8B10B.CHANNEL(6).RX.KDATA;                  --
          localRdData(11 downto  8)  <=  Mon.DEBUG_8B10B.CHANNEL(6).RX.VALID;                  --
          localRdData(16)            <=  Mon.DEBUG_8B10B.CHANNEL(6).RX.COMMA;                  --
          localRdData(27 downto 24)  <=  Mon.DEBUG_8B10B.CHANNEL(6).RX.DISP_ERR;               --
        when 2098 => --0x832
          localRdData( 0)            <=  reg_data(2098)( 0);                                   --
          localRdData( 1)            <=  reg_data(2098)( 1);                                   --
        when 2099 => --0x833
          localRdData(31 downto  0)  <=  reg_data(2099)(31 downto  0);                         --
        when 2100 => --0x834
          localRdData( 3 downto  0)  <=  reg_data(2100)( 3 downto  0);                         --
        when 2101 => --0x835
          localRdData( 0)            <=  reg_data(2101)( 0);                                   --
        when 2104 => --0x838
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B.CHANNEL(7).RX.DATA;                   --
        when 2105 => --0x839
          localRdData( 3 downto  0)  <=  Mon.DEBUG_8B10B.CHANNEL(7).RX.KDATA;                  --
          localRdData(11 downto  8)  <=  Mon.DEBUG_8B10B.CHANNEL(7).RX.VALID;                  --
          localRdData(16)            <=  Mon.DEBUG_8B10B.CHANNEL(7).RX.COMMA;                  --
          localRdData(27 downto 24)  <=  Mon.DEBUG_8B10B.CHANNEL(7).RX.DISP_ERR;               --
        when 2106 => --0x83a
          localRdData( 0)            <=  reg_data(2106)( 0);                                   --
          localRdData( 1)            <=  reg_data(2106)( 1);                                   --
        when 2107 => --0x83b
          localRdData(31 downto  0)  <=  reg_data(2107)(31 downto  0);                         --
        when 2108 => --0x83c
          localRdData( 3 downto  0)  <=  reg_data(2108)( 3 downto  0);                         --
        when 2109 => --0x83d
          localRdData( 0)            <=  reg_data(2109)( 0);                                   --
        when 2112 => --0x840
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B.CHANNEL(8).RX.DATA;                   --
        when 2113 => --0x841
          localRdData( 3 downto  0)  <=  Mon.DEBUG_8B10B.CHANNEL(8).RX.KDATA;                  --
          localRdData(11 downto  8)  <=  Mon.DEBUG_8B10B.CHANNEL(8).RX.VALID;                  --
          localRdData(16)            <=  Mon.DEBUG_8B10B.CHANNEL(8).RX.COMMA;                  --
          localRdData(27 downto 24)  <=  Mon.DEBUG_8B10B.CHANNEL(8).RX.DISP_ERR;               --
        when 2114 => --0x842
          localRdData( 0)            <=  reg_data(2114)( 0);                                   --
          localRdData( 1)            <=  reg_data(2114)( 1);                                   --
        when 2115 => --0x843
          localRdData(31 downto  0)  <=  reg_data(2115)(31 downto  0);                         --
        when 2116 => --0x844
          localRdData( 3 downto  0)  <=  reg_data(2116)( 3 downto  0);                         --
        when 2117 => --0x845
          localRdData( 0)            <=  reg_data(2117)( 0);                                   --
        when 2120 => --0x848
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B.CHANNEL(9).RX.DATA;                   --
        when 2121 => --0x849
          localRdData( 3 downto  0)  <=  Mon.DEBUG_8B10B.CHANNEL(9).RX.KDATA;                  --
          localRdData(11 downto  8)  <=  Mon.DEBUG_8B10B.CHANNEL(9).RX.VALID;                  --
          localRdData(16)            <=  Mon.DEBUG_8B10B.CHANNEL(9).RX.COMMA;                  --
          localRdData(27 downto 24)  <=  Mon.DEBUG_8B10B.CHANNEL(9).RX.DISP_ERR;               --
        when 2122 => --0x84a
          localRdData( 0)            <=  reg_data(2122)( 0);                                   --
          localRdData( 1)            <=  reg_data(2122)( 1);                                   --
        when 2123 => --0x84b
          localRdData(31 downto  0)  <=  reg_data(2123)(31 downto  0);                         --
        when 2124 => --0x84c
          localRdData( 3 downto  0)  <=  reg_data(2124)( 3 downto  0);                         --
        when 2125 => --0x84d
          localRdData( 0)            <=  reg_data(2125)( 0);                                   --
        when 2128 => --0x850
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B.CHANNEL(10).RX.DATA;                  --
        when 2129 => --0x851
          localRdData( 3 downto  0)  <=  Mon.DEBUG_8B10B.CHANNEL(10).RX.KDATA;                 --
          localRdData(11 downto  8)  <=  Mon.DEBUG_8B10B.CHANNEL(10).RX.VALID;                 --
          localRdData(16)            <=  Mon.DEBUG_8B10B.CHANNEL(10).RX.COMMA;                 --
          localRdData(27 downto 24)  <=  Mon.DEBUG_8B10B.CHANNEL(10).RX.DISP_ERR;              --
        when 2130 => --0x852
          localRdData( 0)            <=  reg_data(2130)( 0);                                   --
          localRdData( 1)            <=  reg_data(2130)( 1);                                   --
        when 2131 => --0x853
          localRdData(31 downto  0)  <=  reg_data(2131)(31 downto  0);                         --
        when 2132 => --0x854
          localRdData( 3 downto  0)  <=  reg_data(2132)( 3 downto  0);                         --
        when 2133 => --0x855
          localRdData( 0)            <=  reg_data(2133)( 0);                                   --
        when 2136 => --0x858
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B.CHANNEL(11).RX.DATA;                  --
        when 2137 => --0x859
          localRdData( 3 downto  0)  <=  Mon.DEBUG_8B10B.CHANNEL(11).RX.KDATA;                 --
          localRdData(11 downto  8)  <=  Mon.DEBUG_8B10B.CHANNEL(11).RX.VALID;                 --
          localRdData(16)            <=  Mon.DEBUG_8B10B.CHANNEL(11).RX.COMMA;                 --
          localRdData(27 downto 24)  <=  Mon.DEBUG_8B10B.CHANNEL(11).RX.DISP_ERR;              --
        when 2138 => --0x85a
          localRdData( 0)            <=  reg_data(2138)( 0);                                   --
          localRdData( 1)            <=  reg_data(2138)( 1);                                   --
        when 2139 => --0x85b
          localRdData(31 downto  0)  <=  reg_data(2139)(31 downto  0);                         --
        when 2140 => --0x85c
          localRdData( 3 downto  0)  <=  reg_data(2140)( 3 downto  0);                         --
        when 2141 => --0x85d
          localRdData( 0)            <=  reg_data(2141)( 0);                                   --


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
  Ctrl.RGB.R                                    <=  reg_data(512)( 7 downto  0);      
  Ctrl.RGB.G                                    <=  reg_data(512)(15 downto  8);      
  Ctrl.RGB.B                                    <=  reg_data(512)(23 downto 16);      
  Ctrl.BRAM.ADDR                                <=  reg_data(769)(14 downto  0);      
  Ctrl.BRAM.WR_DATA                             <=  reg_data(770)(31 downto  0);      
  Ctrl.DEBUG_8B10B.CHANNEL(0).RX.ENABLE         <=  reg_data(2050)( 0);               
  Ctrl.DEBUG_8B10B.CHANNEL(0).RX.EN_COMMA_DET   <=  reg_data(2050)( 1);               
  Ctrl.DEBUG_8B10B.CHANNEL(0).TX.DATA           <=  reg_data(2051)(31 downto  0);     
  Ctrl.DEBUG_8B10B.CHANNEL(0).TX.KDATA          <=  reg_data(2052)( 3 downto  0);     
  Ctrl.DEBUG_8B10B.CHANNEL(0).TX.ENABLE         <=  reg_data(2053)( 0);               
  Ctrl.DEBUG_8B10B.CHANNEL(1).RX.ENABLE         <=  reg_data(2058)( 0);               
  Ctrl.DEBUG_8B10B.CHANNEL(1).RX.EN_COMMA_DET   <=  reg_data(2058)( 1);               
  Ctrl.DEBUG_8B10B.CHANNEL(1).TX.DATA           <=  reg_data(2059)(31 downto  0);     
  Ctrl.DEBUG_8B10B.CHANNEL(1).TX.KDATA          <=  reg_data(2060)( 3 downto  0);     
  Ctrl.DEBUG_8B10B.CHANNEL(1).TX.ENABLE         <=  reg_data(2061)( 0);               
  Ctrl.DEBUG_8B10B.CHANNEL(2).RX.ENABLE         <=  reg_data(2066)( 0);               
  Ctrl.DEBUG_8B10B.CHANNEL(2).RX.EN_COMMA_DET   <=  reg_data(2066)( 1);               
  Ctrl.DEBUG_8B10B.CHANNEL(2).TX.DATA           <=  reg_data(2067)(31 downto  0);     
  Ctrl.DEBUG_8B10B.CHANNEL(2).TX.KDATA          <=  reg_data(2068)( 3 downto  0);     
  Ctrl.DEBUG_8B10B.CHANNEL(2).TX.ENABLE         <=  reg_data(2069)( 0);               
  Ctrl.DEBUG_8B10B.CHANNEL(3).RX.ENABLE         <=  reg_data(2074)( 0);               
  Ctrl.DEBUG_8B10B.CHANNEL(3).RX.EN_COMMA_DET   <=  reg_data(2074)( 1);               
  Ctrl.DEBUG_8B10B.CHANNEL(3).TX.DATA           <=  reg_data(2075)(31 downto  0);     
  Ctrl.DEBUG_8B10B.CHANNEL(3).TX.KDATA          <=  reg_data(2076)( 3 downto  0);     
  Ctrl.DEBUG_8B10B.CHANNEL(3).TX.ENABLE         <=  reg_data(2077)( 0);               
  Ctrl.DEBUG_8B10B.CHANNEL(4).RX.ENABLE         <=  reg_data(2082)( 0);               
  Ctrl.DEBUG_8B10B.CHANNEL(4).RX.EN_COMMA_DET   <=  reg_data(2082)( 1);               
  Ctrl.DEBUG_8B10B.CHANNEL(4).TX.DATA           <=  reg_data(2083)(31 downto  0);     
  Ctrl.DEBUG_8B10B.CHANNEL(4).TX.KDATA          <=  reg_data(2084)( 3 downto  0);     
  Ctrl.DEBUG_8B10B.CHANNEL(4).TX.ENABLE         <=  reg_data(2085)( 0);               
  Ctrl.DEBUG_8B10B.CHANNEL(5).RX.ENABLE         <=  reg_data(2090)( 0);               
  Ctrl.DEBUG_8B10B.CHANNEL(5).RX.EN_COMMA_DET   <=  reg_data(2090)( 1);               
  Ctrl.DEBUG_8B10B.CHANNEL(5).TX.DATA           <=  reg_data(2091)(31 downto  0);     
  Ctrl.DEBUG_8B10B.CHANNEL(5).TX.KDATA          <=  reg_data(2092)( 3 downto  0);     
  Ctrl.DEBUG_8B10B.CHANNEL(5).TX.ENABLE         <=  reg_data(2093)( 0);               
  Ctrl.DEBUG_8B10B.CHANNEL(6).RX.ENABLE         <=  reg_data(2098)( 0);               
  Ctrl.DEBUG_8B10B.CHANNEL(6).RX.EN_COMMA_DET   <=  reg_data(2098)( 1);               
  Ctrl.DEBUG_8B10B.CHANNEL(6).TX.DATA           <=  reg_data(2099)(31 downto  0);     
  Ctrl.DEBUG_8B10B.CHANNEL(6).TX.KDATA          <=  reg_data(2100)( 3 downto  0);     
  Ctrl.DEBUG_8B10B.CHANNEL(6).TX.ENABLE         <=  reg_data(2101)( 0);               
  Ctrl.DEBUG_8B10B.CHANNEL(7).RX.ENABLE         <=  reg_data(2106)( 0);               
  Ctrl.DEBUG_8B10B.CHANNEL(7).RX.EN_COMMA_DET   <=  reg_data(2106)( 1);               
  Ctrl.DEBUG_8B10B.CHANNEL(7).TX.DATA           <=  reg_data(2107)(31 downto  0);     
  Ctrl.DEBUG_8B10B.CHANNEL(7).TX.KDATA          <=  reg_data(2108)( 3 downto  0);     
  Ctrl.DEBUG_8B10B.CHANNEL(7).TX.ENABLE         <=  reg_data(2109)( 0);               
  Ctrl.DEBUG_8B10B.CHANNEL(8).RX.ENABLE         <=  reg_data(2114)( 0);               
  Ctrl.DEBUG_8B10B.CHANNEL(8).RX.EN_COMMA_DET   <=  reg_data(2114)( 1);               
  Ctrl.DEBUG_8B10B.CHANNEL(8).TX.DATA           <=  reg_data(2115)(31 downto  0);     
  Ctrl.DEBUG_8B10B.CHANNEL(8).TX.KDATA          <=  reg_data(2116)( 3 downto  0);     
  Ctrl.DEBUG_8B10B.CHANNEL(8).TX.ENABLE         <=  reg_data(2117)( 0);               
  Ctrl.DEBUG_8B10B.CHANNEL(9).RX.ENABLE         <=  reg_data(2122)( 0);               
  Ctrl.DEBUG_8B10B.CHANNEL(9).RX.EN_COMMA_DET   <=  reg_data(2122)( 1);               
  Ctrl.DEBUG_8B10B.CHANNEL(9).TX.DATA           <=  reg_data(2123)(31 downto  0);     
  Ctrl.DEBUG_8B10B.CHANNEL(9).TX.KDATA          <=  reg_data(2124)( 3 downto  0);     
  Ctrl.DEBUG_8B10B.CHANNEL(9).TX.ENABLE         <=  reg_data(2125)( 0);               
  Ctrl.DEBUG_8B10B.CHANNEL(10).RX.ENABLE        <=  reg_data(2130)( 0);               
  Ctrl.DEBUG_8B10B.CHANNEL(10).RX.EN_COMMA_DET  <=  reg_data(2130)( 1);               
  Ctrl.DEBUG_8B10B.CHANNEL(10).TX.DATA          <=  reg_data(2131)(31 downto  0);     
  Ctrl.DEBUG_8B10B.CHANNEL(10).TX.KDATA         <=  reg_data(2132)( 3 downto  0);     
  Ctrl.DEBUG_8B10B.CHANNEL(10).TX.ENABLE        <=  reg_data(2133)( 0);               
  Ctrl.DEBUG_8B10B.CHANNEL(11).RX.ENABLE        <=  reg_data(2138)( 0);               
  Ctrl.DEBUG_8B10B.CHANNEL(11).RX.EN_COMMA_DET  <=  reg_data(2138)( 1);               
  Ctrl.DEBUG_8B10B.CHANNEL(11).TX.DATA          <=  reg_data(2139)(31 downto  0);     
  Ctrl.DEBUG_8B10B.CHANNEL(11).TX.KDATA         <=  reg_data(2140)( 3 downto  0);     
  Ctrl.DEBUG_8B10B.CHANNEL(11).TX.ENABLE        <=  reg_data(2141)( 0);               


  reg_writes: process (clk_axi, reset_axi_n) is
  begin  -- process reg_writes
    if reset_axi_n = '0' then                 -- asynchronous reset (active low)
      reg_data(512)( 7 downto  0)  <= DEFAULT_IO_CTRL_t.RGB.R;
      reg_data(512)(15 downto  8)  <= DEFAULT_IO_CTRL_t.RGB.G;
      reg_data(512)(23 downto 16)  <= DEFAULT_IO_CTRL_t.RGB.B;
      reg_data(768)( 0)  <= DEFAULT_IO_CTRL_t.BRAM.WRITE;
      reg_data(769)(14 downto  0)  <= DEFAULT_IO_CTRL_t.BRAM.ADDR;
      reg_data(770)(31 downto  0)  <= DEFAULT_IO_CTRL_t.BRAM.WR_DATA;
      reg_data(2050)( 0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(0).RX.ENABLE;
      reg_data(2050)( 1)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(0).RX.EN_COMMA_DET;
      reg_data(2051)(31 downto  0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(0).TX.DATA;
      reg_data(2052)( 3 downto  0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(0).TX.KDATA;
      reg_data(2053)( 0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(0).TX.ENABLE;
      reg_data(2058)( 0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(1).RX.ENABLE;
      reg_data(2058)( 1)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(1).RX.EN_COMMA_DET;
      reg_data(2059)(31 downto  0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(1).TX.DATA;
      reg_data(2060)( 3 downto  0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(1).TX.KDATA;
      reg_data(2061)( 0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(1).TX.ENABLE;
      reg_data(2066)( 0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(2).RX.ENABLE;
      reg_data(2066)( 1)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(2).RX.EN_COMMA_DET;
      reg_data(2067)(31 downto  0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(2).TX.DATA;
      reg_data(2068)( 3 downto  0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(2).TX.KDATA;
      reg_data(2069)( 0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(2).TX.ENABLE;
      reg_data(2074)( 0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(3).RX.ENABLE;
      reg_data(2074)( 1)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(3).RX.EN_COMMA_DET;
      reg_data(2075)(31 downto  0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(3).TX.DATA;
      reg_data(2076)( 3 downto  0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(3).TX.KDATA;
      reg_data(2077)( 0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(3).TX.ENABLE;
      reg_data(2082)( 0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(4).RX.ENABLE;
      reg_data(2082)( 1)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(4).RX.EN_COMMA_DET;
      reg_data(2083)(31 downto  0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(4).TX.DATA;
      reg_data(2084)( 3 downto  0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(4).TX.KDATA;
      reg_data(2085)( 0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(4).TX.ENABLE;
      reg_data(2090)( 0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(5).RX.ENABLE;
      reg_data(2090)( 1)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(5).RX.EN_COMMA_DET;
      reg_data(2091)(31 downto  0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(5).TX.DATA;
      reg_data(2092)( 3 downto  0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(5).TX.KDATA;
      reg_data(2093)( 0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(5).TX.ENABLE;
      reg_data(2098)( 0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(6).RX.ENABLE;
      reg_data(2098)( 1)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(6).RX.EN_COMMA_DET;
      reg_data(2099)(31 downto  0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(6).TX.DATA;
      reg_data(2100)( 3 downto  0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(6).TX.KDATA;
      reg_data(2101)( 0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(6).TX.ENABLE;
      reg_data(2106)( 0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(7).RX.ENABLE;
      reg_data(2106)( 1)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(7).RX.EN_COMMA_DET;
      reg_data(2107)(31 downto  0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(7).TX.DATA;
      reg_data(2108)( 3 downto  0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(7).TX.KDATA;
      reg_data(2109)( 0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(7).TX.ENABLE;
      reg_data(2114)( 0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(8).RX.ENABLE;
      reg_data(2114)( 1)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(8).RX.EN_COMMA_DET;
      reg_data(2115)(31 downto  0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(8).TX.DATA;
      reg_data(2116)( 3 downto  0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(8).TX.KDATA;
      reg_data(2117)( 0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(8).TX.ENABLE;
      reg_data(2122)( 0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(9).RX.ENABLE;
      reg_data(2122)( 1)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(9).RX.EN_COMMA_DET;
      reg_data(2123)(31 downto  0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(9).TX.DATA;
      reg_data(2124)( 3 downto  0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(9).TX.KDATA;
      reg_data(2125)( 0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(9).TX.ENABLE;
      reg_data(2130)( 0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(10).RX.ENABLE;
      reg_data(2130)( 1)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(10).RX.EN_COMMA_DET;
      reg_data(2131)(31 downto  0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(10).TX.DATA;
      reg_data(2132)( 3 downto  0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(10).TX.KDATA;
      reg_data(2133)( 0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(10).TX.ENABLE;
      reg_data(2138)( 0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(11).RX.ENABLE;
      reg_data(2138)( 1)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(11).RX.EN_COMMA_DET;
      reg_data(2139)(31 downto  0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(11).TX.DATA;
      reg_data(2140)( 3 downto  0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(11).TX.KDATA;
      reg_data(2141)( 0)  <= DEFAULT_IO_CTRL_t.DEBUG_8B10B.CHANNEL(11).TX.ENABLE;

    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      Ctrl.BRAM.WRITE <= '0';
      

      
      if localWrEn = '1' then
        case to_integer(unsigned(localAddress(11 downto 0))) is
        when 512 => --0x200
          reg_data(512)( 7 downto  0)   <=  localWrData( 7 downto  0);      --
          reg_data(512)(15 downto  8)   <=  localWrData(15 downto  8);      --
          reg_data(512)(23 downto 16)   <=  localWrData(23 downto 16);      --
        when 768 => --0x300
          Ctrl.BRAM.WRITE               <=  localWrData( 0);               
        when 769 => --0x301
          reg_data(769)(14 downto  0)   <=  localWrData(14 downto  0);      --
        when 770 => --0x302
          reg_data(770)(31 downto  0)   <=  localWrData(31 downto  0);      --
        when 2050 => --0x802
          reg_data(2050)( 0)            <=  localWrData( 0);                --
          reg_data(2050)( 1)            <=  localWrData( 1);                --
        when 2051 => --0x803
          reg_data(2051)(31 downto  0)  <=  localWrData(31 downto  0);      --
        when 2052 => --0x804
          reg_data(2052)( 3 downto  0)  <=  localWrData( 3 downto  0);      --
        when 2053 => --0x805
          reg_data(2053)( 0)            <=  localWrData( 0);                --
        when 2058 => --0x80a
          reg_data(2058)( 0)            <=  localWrData( 0);                --
          reg_data(2058)( 1)            <=  localWrData( 1);                --
        when 2059 => --0x80b
          reg_data(2059)(31 downto  0)  <=  localWrData(31 downto  0);      --
        when 2060 => --0x80c
          reg_data(2060)( 3 downto  0)  <=  localWrData( 3 downto  0);      --
        when 2061 => --0x80d
          reg_data(2061)( 0)            <=  localWrData( 0);                --
        when 2066 => --0x812
          reg_data(2066)( 0)            <=  localWrData( 0);                --
          reg_data(2066)( 1)            <=  localWrData( 1);                --
        when 2067 => --0x813
          reg_data(2067)(31 downto  0)  <=  localWrData(31 downto  0);      --
        when 2068 => --0x814
          reg_data(2068)( 3 downto  0)  <=  localWrData( 3 downto  0);      --
        when 2069 => --0x815
          reg_data(2069)( 0)            <=  localWrData( 0);                --
        when 2074 => --0x81a
          reg_data(2074)( 0)            <=  localWrData( 0);                --
          reg_data(2074)( 1)            <=  localWrData( 1);                --
        when 2075 => --0x81b
          reg_data(2075)(31 downto  0)  <=  localWrData(31 downto  0);      --
        when 2076 => --0x81c
          reg_data(2076)( 3 downto  0)  <=  localWrData( 3 downto  0);      --
        when 2077 => --0x81d
          reg_data(2077)( 0)            <=  localWrData( 0);                --
        when 2082 => --0x822
          reg_data(2082)( 0)            <=  localWrData( 0);                --
          reg_data(2082)( 1)            <=  localWrData( 1);                --
        when 2083 => --0x823
          reg_data(2083)(31 downto  0)  <=  localWrData(31 downto  0);      --
        when 2084 => --0x824
          reg_data(2084)( 3 downto  0)  <=  localWrData( 3 downto  0);      --
        when 2085 => --0x825
          reg_data(2085)( 0)            <=  localWrData( 0);                --
        when 2090 => --0x82a
          reg_data(2090)( 0)            <=  localWrData( 0);                --
          reg_data(2090)( 1)            <=  localWrData( 1);                --
        when 2091 => --0x82b
          reg_data(2091)(31 downto  0)  <=  localWrData(31 downto  0);      --
        when 2092 => --0x82c
          reg_data(2092)( 3 downto  0)  <=  localWrData( 3 downto  0);      --
        when 2093 => --0x82d
          reg_data(2093)( 0)            <=  localWrData( 0);                --
        when 2098 => --0x832
          reg_data(2098)( 0)            <=  localWrData( 0);                --
          reg_data(2098)( 1)            <=  localWrData( 1);                --
        when 2099 => --0x833
          reg_data(2099)(31 downto  0)  <=  localWrData(31 downto  0);      --
        when 2100 => --0x834
          reg_data(2100)( 3 downto  0)  <=  localWrData( 3 downto  0);      --
        when 2101 => --0x835
          reg_data(2101)( 0)            <=  localWrData( 0);                --
        when 2106 => --0x83a
          reg_data(2106)( 0)            <=  localWrData( 0);                --
          reg_data(2106)( 1)            <=  localWrData( 1);                --
        when 2107 => --0x83b
          reg_data(2107)(31 downto  0)  <=  localWrData(31 downto  0);      --
        when 2108 => --0x83c
          reg_data(2108)( 3 downto  0)  <=  localWrData( 3 downto  0);      --
        when 2109 => --0x83d
          reg_data(2109)( 0)            <=  localWrData( 0);                --
        when 2114 => --0x842
          reg_data(2114)( 0)            <=  localWrData( 0);                --
          reg_data(2114)( 1)            <=  localWrData( 1);                --
        when 2115 => --0x843
          reg_data(2115)(31 downto  0)  <=  localWrData(31 downto  0);      --
        when 2116 => --0x844
          reg_data(2116)( 3 downto  0)  <=  localWrData( 3 downto  0);      --
        when 2117 => --0x845
          reg_data(2117)( 0)            <=  localWrData( 0);                --
        when 2122 => --0x84a
          reg_data(2122)( 0)            <=  localWrData( 0);                --
          reg_data(2122)( 1)            <=  localWrData( 1);                --
        when 2123 => --0x84b
          reg_data(2123)(31 downto  0)  <=  localWrData(31 downto  0);      --
        when 2124 => --0x84c
          reg_data(2124)( 3 downto  0)  <=  localWrData( 3 downto  0);      --
        when 2125 => --0x84d
          reg_data(2125)( 0)            <=  localWrData( 0);                --
        when 2130 => --0x852
          reg_data(2130)( 0)            <=  localWrData( 0);                --
          reg_data(2130)( 1)            <=  localWrData( 1);                --
        when 2131 => --0x853
          reg_data(2131)(31 downto  0)  <=  localWrData(31 downto  0);      --
        when 2132 => --0x854
          reg_data(2132)( 3 downto  0)  <=  localWrData( 3 downto  0);      --
        when 2133 => --0x855
          reg_data(2133)( 0)            <=  localWrData( 0);                --
        when 2138 => --0x85a
          reg_data(2138)( 0)            <=  localWrData( 0);                --
          reg_data(2138)( 1)            <=  localWrData( 1);                --
        when 2139 => --0x85b
          reg_data(2139)(31 downto  0)  <=  localWrData(31 downto  0);      --
        when 2140 => --0x85c
          reg_data(2140)( 3 downto  0)  <=  localWrData( 3 downto  0);      --
        when 2141 => --0x85d
          reg_data(2141)( 0)            <=  localWrData( 0);                --

          when others => null;
        end case;
      end if;
    end if;
  end process reg_writes;







  
end architecture behavioral;