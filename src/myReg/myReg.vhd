library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.AXIRegPkg.all;

use work.types.all;

entity myReg is
  
  port (
    clk_axi     : in  std_logic;
    reset_axi_n : in  std_logic;
    readMOSI    : in  AXIReadMOSI;
    readMISO    : out AXIReadMISO := DefaultAXIReadMISO;
    writeMOSI   : in  AXIWriteMOSI;
    writeMISO   : out AXIWriteMISO := DefaultAXIWriteMISO;
    test        : out std_logic_vector(31 downto 0)
    );
end entity myReg;

architecture behavioral of myReg is
  signal localAddress : slv_32_t;
  signal localRdData  : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData  : slv_32_t;
  signal localWrEn    : std_logic;
  signal localRdReq   : std_logic;
  signal localRdAck   : std_logic;
  

  signal reg_data :  slv32_array_t(integer range 0 to 3);
  constant Default_reg_data : slv32_array_t(integer range 0 to 3) := (x"FFFF0000",x"FFFE0001",x"FFFE0002",x"FFFD0003");

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
      if localAddress(2) = '1' then
        localRdData <= reg_data(to_integer(unsigned(localAddress(1 downto 0))));
      else             
        case localAddress(1 downto 0) is
          when "00" => localRdData <= x"12345678";
          when "01" => localRdData <= localAddress;
          when "10" =>
            localRdData <= x"DEADBEEF";
            localRdAck  <= '0';
          when "11" => localRdData <= x"ABADCAFE";
          when others => null;
        end case;
      end if;
    end if;
  end process reads;

  test <= reg_data(0);
  reg_writes: process (clk_axi, reset_axi_n) is
  begin  -- process reg_writes
    if reset_axi_n = '0' then                 -- asynchronous reset (active high)
      reg_data <= default_reg_data;
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      if localWrEn = '1' then
        if localAddress(2) = '1' then
          reg_data(to_integer(unsigned(localAddress(1 downto 0)))) <= localWrData;
        else
          case localAddress(1 downto 0) is
            when "00" =>
              if localWrData(0) = '1' then
                reg_data <= default_reg_data;
              end if;
            when others => null;
          end case;          
        end if;
      end if;
    end if;
  end process reg_writes;


  

  
end architecture behavioral;
