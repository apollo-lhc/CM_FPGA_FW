library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.AXIRegPkg.all;

use work.types.all;

entity BoardIO is
  generic (
    REG_COUNT_PWR_OF_2 : integer := 4;
    REG_OUT_DEFAULTS   : slv32_array_t);
  port (
    clk_axi     : in  std_logic;
    reset_axi_n : in  std_logic;
    readMOSI    : in  AXIReadMOSI;
    readMISO    : out AXIReadMISO := DefaultAXIReadMISO;
    writeMOSI   : in  AXIWriteMOSI;
    writeMISO   : out AXIWriteMISO := DefaultAXIWriteMISO;
    reg_out     : out slv32_array_t((2**REG_COUNT_PWR_OF_2)-1 downto 0);
    reg_in      : in  slv32_array_t((2**REG_COUNT_PWR_OF_2)-1 downto 0) := (others => x"00000000")
    );
end entity BoardIO;

architecture behavioral of BoardIO is
  signal localAddress : slv_32_t;
  signal localRdData  : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData  : slv_32_t;
  signal localWrEn    : std_logic;
  signal localRdReq   : std_logic;
  signal localRdAck   : std_logic;
  

  signal reg_data :  slv32_array_t(integer range 0 to (2**REG_COUNT_PWR_OF_2) -1);

begin  -- architecture behavioral
  
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
      if localAddress(REG_COUNT_PWR_OF_2) = '0' then
        localRdData <= reg_in(to_integer(unsigned(localAddress(REG_COUNT_PWR_OF_2-1 downto 0))));
      else
        localRdData <= reg_data(to_integer(unsigned(localAddress(REG_COUNT_PWR_OF_2-1 downto 0))));
      end if;
    end if;
  end process reads;

  reg_out <= reg_data;
  reg_writes: process (clk_axi, reset_axi_n) is
  begin  -- process reg_writes
    if reset_axi_n = '0' then                 -- asynchronous reset (active high)
      reg_data <= REG_OUT_DEFAULTS;
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      if localWrEn = '1' then
        if localAddress(REG_COUNT_PWR_OF_2) = '1' then
          reg_data(to_integer(unsigned(localAddress(REG_COUNT_PWR_OF_2-1 downto 0)))) <= localWrData;
        end if;
      end if;
    end if;
  end process reg_writes;


  

  
end architecture behavioral;
