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

  
  
  signal reg_data :  slv32_array_t(integer range 0 to 2077);
  constant Default_reg_data : slv32_array_t(integer range 0 to 2077) := (others => x"00000000");
begin  -- architecture behavioral

  -------------------------------------------------------------------------------
  -- AXI 
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  assert ((4*2077) <= ALLOCATED_MEMORY_RANGE)
    report "IO: Regmap addressing range " & integer'image(4*2077) & " is outside of AXI mapped range " & integer'image(ALLOCATED_MEMORY_RANGE)
  severity ERROR;
  assert ((4*2077) > ALLOCATED_MEMORY_RANGE)
    report "IO: Regmap addressing range " & integer'image(4*2077) & " is inside of AXI mapped range " & integer'image(ALLOCATED_MEMORY_RANGE)
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
          localRdData( 0)            <=  Mon.CLK_200_LOCKED;                                  --
        when 512 => --0x200
          localRdData( 7 downto  0)  <=  reg_data(512)( 7 downto  0);                         --
          localRdData(15 downto  8)  <=  reg_data(512)(15 downto  8);                         --
          localRdData(23 downto 16)  <=  reg_data(512)(23 downto 16);                         --
        when 769 => --0x301
          localRdData(14 downto  0)  <=  reg_data(769)(14 downto  0);                         --
        when 770 => --0x302
          localRdData(31 downto  0)  <=  reg_data(770)(31 downto  0);                         --
        when 771 => --0x303
          localRdData(31 downto  0)  <=  Mon.BRAM.RD_DATA;                                    --
        when 1025 => --0x401
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(0).RX.USRCLK_FREQ;       --
        when 1026 => --0x402
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(0).RX.USRCLK2_FREQ;      --
        when 1028 => --0x404
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(0).TX.USRCLK_FREQ;       --
        when 1029 => --0x405
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(0).TX.USRCLK2_FREQ;      --
        when 1033 => --0x409
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(1).RX.USRCLK_FREQ;       --
        when 1034 => --0x40a
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(1).RX.USRCLK2_FREQ;      --
        when 1036 => --0x40c
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(1).TX.USRCLK_FREQ;       --
        when 1037 => --0x40d
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(1).TX.USRCLK2_FREQ;      --
        when 1041 => --0x411
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(2).RX.USRCLK_FREQ;       --
        when 1042 => --0x412
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(2).RX.USRCLK2_FREQ;      --
        when 1044 => --0x414
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(2).TX.USRCLK_FREQ;       --
        when 1045 => --0x415
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(2).TX.USRCLK2_FREQ;      --
        when 1049 => --0x419
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(3).RX.USRCLK_FREQ;       --
        when 1050 => --0x41a
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(3).RX.USRCLK2_FREQ;      --
        when 1052 => --0x41c
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(3).TX.USRCLK_FREQ;       --
        when 1053 => --0x41d
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B_CLK.CHANNEL(3).TX.USRCLK2_FREQ;      --
        when 2048 => --0x800
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B.CHANNEL(0).RX.DATA;                  --
        when 2049 => --0x801
          localRdData( 3 downto  0)  <=  Mon.DEBUG_8B10B.CHANNEL(0).RX.KDATA;                 --
          localRdData(11 downto  8)  <=  Mon.DEBUG_8B10B.CHANNEL(0).RX.VALID;                 --
          localRdData(16)            <=  Mon.DEBUG_8B10B.CHANNEL(0).RX.COMMA;                 --
          localRdData(27 downto 24)  <=  Mon.DEBUG_8B10B.CHANNEL(0).RX.DISP_ERR;              --
        when 2050 => --0x802
          localRdData( 0)            <=  reg_data(2050)( 0);                                  --
          localRdData( 1)            <=  reg_data(2050)( 1);                                  --
        when 2051 => --0x803
          localRdData(31 downto  0)  <=  reg_data(2051)(31 downto  0);                        --
        when 2052 => --0x804
          localRdData( 3 downto  0)  <=  reg_data(2052)( 3 downto  0);                        --
        when 2053 => --0x805
          localRdData( 0)            <=  reg_data(2053)( 0);                                  --
        when 2056 => --0x808
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B.CHANNEL(1).RX.DATA;                  --
        when 2057 => --0x809
          localRdData( 3 downto  0)  <=  Mon.DEBUG_8B10B.CHANNEL(1).RX.KDATA;                 --
          localRdData(11 downto  8)  <=  Mon.DEBUG_8B10B.CHANNEL(1).RX.VALID;                 --
          localRdData(16)            <=  Mon.DEBUG_8B10B.CHANNEL(1).RX.COMMA;                 --
          localRdData(27 downto 24)  <=  Mon.DEBUG_8B10B.CHANNEL(1).RX.DISP_ERR;              --
        when 2058 => --0x80a
          localRdData( 0)            <=  reg_data(2058)( 0);                                  --
          localRdData( 1)            <=  reg_data(2058)( 1);                                  --
        when 2059 => --0x80b
          localRdData(31 downto  0)  <=  reg_data(2059)(31 downto  0);                        --
        when 2060 => --0x80c
          localRdData( 3 downto  0)  <=  reg_data(2060)( 3 downto  0);                        --
        when 2061 => --0x80d
          localRdData( 0)            <=  reg_data(2061)( 0);                                  --
        when 2064 => --0x810
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B.CHANNEL(2).RX.DATA;                  --
        when 2065 => --0x811
          localRdData( 3 downto  0)  <=  Mon.DEBUG_8B10B.CHANNEL(2).RX.KDATA;                 --
          localRdData(11 downto  8)  <=  Mon.DEBUG_8B10B.CHANNEL(2).RX.VALID;                 --
          localRdData(16)            <=  Mon.DEBUG_8B10B.CHANNEL(2).RX.COMMA;                 --
          localRdData(27 downto 24)  <=  Mon.DEBUG_8B10B.CHANNEL(2).RX.DISP_ERR;              --
        when 2066 => --0x812
          localRdData( 0)            <=  reg_data(2066)( 0);                                  --
          localRdData( 1)            <=  reg_data(2066)( 1);                                  --
        when 2067 => --0x813
          localRdData(31 downto  0)  <=  reg_data(2067)(31 downto  0);                        --
        when 2068 => --0x814
          localRdData( 3 downto  0)  <=  reg_data(2068)( 3 downto  0);                        --
        when 2069 => --0x815
          localRdData( 0)            <=  reg_data(2069)( 0);                                  --
        when 2072 => --0x818
          localRdData(31 downto  0)  <=  Mon.DEBUG_8B10B.CHANNEL(3).RX.DATA;                  --
        when 2073 => --0x819
          localRdData( 3 downto  0)  <=  Mon.DEBUG_8B10B.CHANNEL(3).RX.KDATA;                 --
          localRdData(11 downto  8)  <=  Mon.DEBUG_8B10B.CHANNEL(3).RX.VALID;                 --
          localRdData(16)            <=  Mon.DEBUG_8B10B.CHANNEL(3).RX.COMMA;                 --
          localRdData(27 downto 24)  <=  Mon.DEBUG_8B10B.CHANNEL(3).RX.DISP_ERR;              --
        when 2074 => --0x81a
          localRdData( 0)            <=  reg_data(2074)( 0);                                  --
          localRdData( 1)            <=  reg_data(2074)( 1);                                  --
        when 2075 => --0x81b
          localRdData(31 downto  0)  <=  reg_data(2075)(31 downto  0);                        --
        when 2076 => --0x81c
          localRdData( 3 downto  0)  <=  reg_data(2076)( 3 downto  0);                        --
        when 2077 => --0x81d
          localRdData( 0)            <=  reg_data(2077)( 0);                                  --


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
  Ctrl.RGB.R                                   <=  reg_data(512)( 7 downto  0);      
  Ctrl.RGB.G                                   <=  reg_data(512)(15 downto  8);      
  Ctrl.RGB.B                                   <=  reg_data(512)(23 downto 16);      
  Ctrl.BRAM.ADDR                               <=  reg_data(769)(14 downto  0);      
  Ctrl.BRAM.WR_DATA                            <=  reg_data(770)(31 downto  0);      
  Ctrl.DEBUG_8B10B.CHANNEL(0).RX.ENABLE        <=  reg_data(2050)( 0);               
  Ctrl.DEBUG_8B10B.CHANNEL(0).RX.EN_COMMA_DET  <=  reg_data(2050)( 1);               
  Ctrl.DEBUG_8B10B.CHANNEL(0).TX.DATA          <=  reg_data(2051)(31 downto  0);     
  Ctrl.DEBUG_8B10B.CHANNEL(0).TX.KDATA         <=  reg_data(2052)( 3 downto  0);     
  Ctrl.DEBUG_8B10B.CHANNEL(0).TX.ENABLE        <=  reg_data(2053)( 0);               
  Ctrl.DEBUG_8B10B.CHANNEL(1).RX.ENABLE        <=  reg_data(2058)( 0);               
  Ctrl.DEBUG_8B10B.CHANNEL(1).RX.EN_COMMA_DET  <=  reg_data(2058)( 1);               
  Ctrl.DEBUG_8B10B.CHANNEL(1).TX.DATA          <=  reg_data(2059)(31 downto  0);     
  Ctrl.DEBUG_8B10B.CHANNEL(1).TX.KDATA         <=  reg_data(2060)( 3 downto  0);     
  Ctrl.DEBUG_8B10B.CHANNEL(1).TX.ENABLE        <=  reg_data(2061)( 0);               
  Ctrl.DEBUG_8B10B.CHANNEL(2).RX.ENABLE        <=  reg_data(2066)( 0);               
  Ctrl.DEBUG_8B10B.CHANNEL(2).RX.EN_COMMA_DET  <=  reg_data(2066)( 1);               
  Ctrl.DEBUG_8B10B.CHANNEL(2).TX.DATA          <=  reg_data(2067)(31 downto  0);     
  Ctrl.DEBUG_8B10B.CHANNEL(2).TX.KDATA         <=  reg_data(2068)( 3 downto  0);     
  Ctrl.DEBUG_8B10B.CHANNEL(2).TX.ENABLE        <=  reg_data(2069)( 0);               
  Ctrl.DEBUG_8B10B.CHANNEL(3).RX.ENABLE        <=  reg_data(2074)( 0);               
  Ctrl.DEBUG_8B10B.CHANNEL(3).RX.EN_COMMA_DET  <=  reg_data(2074)( 1);               
  Ctrl.DEBUG_8B10B.CHANNEL(3).TX.DATA          <=  reg_data(2075)(31 downto  0);     
  Ctrl.DEBUG_8B10B.CHANNEL(3).TX.KDATA         <=  reg_data(2076)( 3 downto  0);     
  Ctrl.DEBUG_8B10B.CHANNEL(3).TX.ENABLE        <=  reg_data(2077)( 0);               


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

          when others => null;
        end case;
      end if;
    end if;
  end process reg_writes;







  
end architecture behavioral;