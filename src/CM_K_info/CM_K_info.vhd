library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
  signal localAddress : slv_32_t;
  signal localRdData  : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData  : slv_32_t;
  signal localWrEn    : std_logic;
  signal localRdReq   : std_logic;
  signal localRdAck   : std_logic;
  

  signal reg_data :  slv32_array_t(integer range 0 to 64);
  constant Default_reg_data : slv32_array_t(integer range 0 to 64) := (0 => x"00000000",
                                                                       1 => x"00000000",
                                                                       others => x"00000000");

begin  -- architecture behavioral

  -------------------------------------------------------------------------------
  -- AXI 
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  AXIRegBridge : entity work.axiLiteReg
    port map (
      clk_axi     => clk_axi,
      reset_axi_n => reset_axi_n,
      readMOSI    => readMOSI,
      readMISO    => readMISO,
      writeMOSI   => writeMOSI,
      writeMISO   => writeMISO,
      address     => localAddress,
      rd_data     => localRdData_latch,
      wr_data     => localWrData,
      write_en    => localWrEn,
      read_req    => localRdReq,
      read_ack    => localRdAck);

  latch_reads: process (clk_axi) is
  begin  -- process latch_reads
    if clk_axi'event and clk_axi = '1' then  -- rising clock edge
      if localRdReq = '1' then
        localRdData_latch <= localRdData;        
      end if;
    end if;
  end process latch_reads;
  reads: process (localRdReq,localAddress,reg_data) is
  begin  -- process reads
    localRdAck  <= '0';
    localRdData <= x"00000000";
    if localRdReq = '1' then
      localRdAck  <= '1';
      case localAddress(7 downto 0) is
        --update regs 0 to 5 when I figure out how to add them
        when x"0" =>          
          localRdData(31 downto  1) <= (others => '0');
          --valid git hash
          localRdData( 1)           <= FW_HASH_VALID;
        when x"1" =>
          --git hash bits  31 downto   0
          localRdData(31 downto  0) <= FW_HASH_1;
        when x"2" =>
          --git hash bits  63 downto  32
          localRdData(31 downto  0) <= FW_HASH_2;
        when x"3" =>
          --git hash bits  95 downto  64
          localRdData(31 downto  0) <= FW_HASH_3;
        when x"4" =>
          --git hash bits 127 downto  96
          localRdData(31 downto  0) <= FW_HASH_4;
        when x"5" =>
          --git hash bits 160 downto 128
          localRdData(31 downto  0) <= FW_HASH_5;

        when x"10" =>
          localRdData( 7 downto  0) <= TS_DAY;
          localRdData(15 downto  8) <= TS_MONTH;
          localRdData(23 downto 16) <= TS_YEAR;
          localRdData(31 downto 24) <= TS_CENT;
        when x"11" =>
          localRdData( 7 downto  0) <= TS_SEC;
          localRdData(15 downto  8) <= TS_MIN;
          localRdData(23 downto 16) <= TS_HOUR;
          localRdData(31 downto 24) <= x"00";
        when others =>
          localRdData <= x"00000000";
      end case;
    end if;
  end process reads;
  reg_writes: process (clk_axi, reset_axi_n) is
  begin  -- process reg_writes
    if reset_axi_n = '0' then                 -- asynchronous reset (active high)
      reg_data <= default_reg_data;
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      if localWrEn = '1' then
        case localAddress(7 downto 0) is
          when others => null;
        end case;
      end if;
    end if;
  end process reg_writes;
  -------------------------------------------------------------------------------


  

  
end architecture behavioral;
