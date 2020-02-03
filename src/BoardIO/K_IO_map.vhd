--This file was auto-generated.
--Modifications might be lost.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AXIRegPkg.all;
use work.types.all;
use work.K_IO_Ctrl.all;
entity K_IO_interface is
  port (
    clk_axi          : in  std_logic;
    reset_axi_n      : in  std_logic;
    slave_readMOSI   : in  AXIReadMOSI;
    slave_readMISO   : out AXIReadMISO  := DefaultAXIReadMISO;
    slave_writeMOSI  : in  AXIWriteMOSI;
    slave_writeMISO  : out AXIWriteMISO := DefaultAXIWriteMISO;
    Mon              : in  K_IO_Mon_t;
    Ctrl             : out K_IO_Ctrl_t
    );
end entity K_IO_interface;
architecture behavioral of K_IO_interface is
  signal localAddress       : slv_32_t;
  signal localRdData        : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData        : slv_32_t;
  signal localWrEn          : std_logic;
  signal localRdReq         : std_logic;
  signal localRdAck         : std_logic;


  signal reg_data :  slv32_array_t(integer range 0 to 256);
  constant Default_reg_data : slv32_array_t(integer range 0 to 256) := (others => x"00000000");
begin  -- architecture behavioral

  -------------------------------------------------------------------------------
  -- AXI 
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  AXIRegBridge : entity work.axiLiteReg
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
      case to_integer(unsigned(localAddress(8 downto 0))) is
        when 0 => --0x0
          localRdData( 0)            <=  Mon.C2C.SOFT_ERR;                 --
          localRdData( 1)            <=  Mon.C2C.MMCM_NOT_LOCKED;          --
          localRdData( 2)            <=  Mon.C2C.LINK_RESET;               --
          localRdData( 3)            <=  Mon.C2C.LANE_UP;                  --
          localRdData( 4)            <=  Mon.C2C.HARD_ERR;                 --
          localRdData( 5)            <=  Mon.C2C.GT_PLL_LOCK;              --
          localRdData( 6)            <=  Mon.C2C.MULTIBIT_ERR;             --
          localRdData( 7)            <=  Mon.C2C.LINK_STATUS;              --
          localRdData( 8)            <=  Mon.C2C.CONFIG_ERR;               --
          localRdData( 9)            <=  Mon.C2C.DO_CC;                    --
        when 256 => --0x100
          localRdData( 7 downto  0)  <=  reg_data(256)( 7 downto  0);      --
          localRdData(15 downto  8)  <=  reg_data(256)(15 downto  8);      --
          localRdData(23 downto 16)  <=  reg_data(256)(23 downto 16);      --
        when others =>
          localRdData <= x"00000000";
      end case;
    end if;
  end process reads;



  -- Register mapping to ctrl structures
  Ctrl.RGB.R  <=  reg_data(256)( 7 downto  0);     
  Ctrl.RGB.G  <=  reg_data(256)(15 downto  8);     
  Ctrl.RGB.B  <=  reg_data(256)(23 downto 16);     



  reg_writes: process (clk_axi, reset_axi_n) is
  begin  -- process reg_writes
    if reset_axi_n = '0' then                 -- asynchronous reset (active low)
      reg_data <= default_reg_data;
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      
      if localWrEn = '1' then
        case to_integer(unsigned(localAddress(8 downto 0))) is
        when 256 => --0x100
          reg_data(256)( 7 downto  0)  <=  localWrData( 7 downto  0);      --
          reg_data(256)(15 downto  8)  <=  localWrData(15 downto  8);      --
          reg_data(256)(23 downto 16)  <=  localWrData(23 downto 16);      --
          when others => null;
        end case;
      end if;
    end if;
  end process reg_writes;

end architecture behavioral;
