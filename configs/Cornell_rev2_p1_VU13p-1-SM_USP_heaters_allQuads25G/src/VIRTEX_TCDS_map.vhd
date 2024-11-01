--This file was auto-generated.
--Modifications might be lost.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AXIRegPkg.all;
use work.types.all;
use work.VIRTEX_TCDS_Ctrl.all;
entity VIRTEX_TCDS_interface is
  port (
    clk_axi          : in  std_logic;
    reset_axi_n      : in  std_logic;
    slave_readMOSI   : in  AXIReadMOSI;
    slave_readMISO   : out AXIReadMISO  := DefaultAXIReadMISO;
    slave_writeMOSI  : in  AXIWriteMOSI;
    slave_writeMISO  : out AXIWriteMISO := DefaultAXIWriteMISO;
    Mon              : in  VIRTEX_TCDS_Mon_t;
    Ctrl             : out VIRTEX_TCDS_Ctrl_t
    );
end entity VIRTEX_TCDS_interface;
architecture behavioral of VIRTEX_TCDS_interface is
  signal localAddress       : slv_32_t;
  signal localRdData        : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData        : slv_32_t;
  signal localWrEn          : std_logic;
  signal localRdReq         : std_logic;
  signal localRdAck         : std_logic;


  signal reg_data :  slv32_array_t(integer range 0 to 83);
  constant Default_reg_data : slv32_array_t(integer range 0 to 83) := (others => x"00000000");
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
      case to_integer(unsigned(localAddress(6 downto 0))) is
        when 0 => --0x0
          localRdData( 1)            <=  Mon.CLOCKING.POWER_GOOD;            --
          localRdData( 9)            <=  Mon.CLOCKING.RX_CDR_STABLE;         --
        when 1 => --0x1
          localRdData(31 downto  0)  <=  Mon.CLOCKING.COUNTS_TXOUTCLK;       --
        when 2 => --0x2
          localRdData(31 downto  0)  <=  Mon.CLOCKING.COUNTS_REFCLK0;        --
        when 3 => --0x3
          localRdData( 0)            <=  Mon.CLOCKING.QPLL0_LOCK;            --
          localRdData( 1)            <=  Mon.CLOCKING.QPLL0_FBCLKLOST;       --
          localRdData( 2)            <=  Mon.CLOCKING.QPLL0_REFCLKLOST;      --
        when 68 => --0x44
          localRdData(31 downto  0)  <=  Mon.DEBUG.CAPTURE_D;                --
        when 5 => --0x5
          localRdData( 0)            <=  reg_data( 5)( 0);                   --
          localRdData( 4)            <=  reg_data( 5)( 4);                   --
          localRdData( 5)            <=  reg_data( 5)( 5);                   --
          localRdData( 8)            <=  reg_data( 5)( 8);                   --
          localRdData( 9)            <=  reg_data( 5)( 9);                   --
        when 6 => --0x6
          localRdData( 6)            <=  Mon.RESETS.TX_RESET_DONE;           --
          localRdData( 7)            <=  Mon.RESETS.TX_PMA_RESET_DONE;       --
          localRdData(10)            <=  Mon.RESETS.RX_RESET_DONE;           --
          localRdData(11)            <=  Mon.RESETS.RX_PMA_RESET_DONE;       --
        when 32 => --0x20
          localRdData( 1)            <=  Mon.TX.PMA_RESET_DONE;              --
          localRdData( 4)            <=  Mon.TX.PWR_GOOD;                    --
        when 8 => --0x8
          localRdData( 2 downto  0)  <=  reg_data( 8)( 2 downto  0);         --
        when 80 => --0x50
          localRdData( 0)            <=  reg_data(80)( 0);                   --
        when 71 => --0x47
          localRdData( 3 downto  0)  <=  reg_data(71)( 3 downto  0);         --
        when 66 => --0x42
          localRdData( 3 downto  0)  <=  reg_data(66)( 3 downto  0);         --
        when 16 => --0x10
          localRdData( 1)            <=  Mon.RX.PMA_RESET_DONE;              --
          localRdData( 7 downto  4)  <=  Mon.RX.BAD_CHAR;                    --
          localRdData(11 downto  8)  <=  Mon.RX.DISP_ERROR;                  --
        when 17 => --0x11
          localRdData( 3 downto  0)  <=  reg_data(17)( 3 downto  0);         --
          localRdData( 5)            <=  reg_data(17)( 5);                   --
        when 82 => --0x52
          localRdData(31 downto  0)  <=  reg_data(82)(31 downto  0);         --
        when 83 => --0x53
          localRdData(31 downto  0)  <=  Mon.Heater.Output;                  --
        when 49 => --0x31
          localRdData( 0)            <=  reg_data(49)( 0);                   --
        when 81 => --0x51
          localRdData(31 downto  0)  <=  reg_data(81)(31 downto  0);         --
        when 33 => --0x21
          localRdData( 3 downto  0)  <=  reg_data(33)( 3 downto  0);         --
          localRdData( 5)            <=  reg_data(33)( 5);                   --
          localRdData( 6)            <=  reg_data(33)( 6);                   --
        when 70 => --0x46
          localRdData(31 downto  0)  <=  reg_data(70)(31 downto  0);         --
        when 69 => --0x45
          localRdData( 3 downto  0)  <=  Mon.DEBUG.CAPTURE_K;                --
        when others =>
          localRdData <= x"00000000";
      end case;
    end if;
  end process reads;



  -- Register mapping to ctrl structures
  Ctrl.RESETS.RESET_ALL        <=  reg_data( 5)( 0);               
  Ctrl.RESETS.TX_PLL_DATAPATH  <=  reg_data( 5)( 4);               
  Ctrl.RESETS.TX_DATAPATH      <=  reg_data( 5)( 5);               
  Ctrl.RESETS.RX_PLL_DATAPATH  <=  reg_data( 5)( 8);               
  Ctrl.RESETS.RX_DATAPATH      <=  reg_data( 5)( 9);               
  Ctrl.LOOPBACK                <=  reg_data( 8)( 2 downto  0);     
  Ctrl.RX.PRBS_SEL             <=  reg_data(17)( 3 downto  0);     
  Ctrl.RX.USER_CLK_READY       <=  reg_data(17)( 5);               
  Ctrl.TX.PRBS_SEL             <=  reg_data(33)( 3 downto  0);     
  Ctrl.TX.INHIBIT              <=  reg_data(33)( 5);               
  Ctrl.TX.USER_CLK_READY       <=  reg_data(33)( 6);               
  Ctrl.EYESCAN.RESET           <=  reg_data(49)( 0);               
  Ctrl.DEBUG.MODE              <=  reg_data(66)( 3 downto  0);     
  Ctrl.DEBUG.FIXED_SEND_D      <=  reg_data(70)(31 downto  0);     
  Ctrl.DEBUG.FIXED_SEND_K      <=  reg_data(71)( 3 downto  0);     
  Ctrl.Heater.Enable           <=  reg_data(80)( 0);               
  Ctrl.Heater.Adjust           <=  reg_data(81)(31 downto  0);     
  Ctrl.Heater.SelectHeater     <=  reg_data(82)(31 downto  0);     



  reg_writes: process (clk_axi, reset_axi_n) is
  begin  -- process reg_writes
    if reset_axi_n = '0' then                 -- asynchronous reset (active low)
      reg_data <= default_reg_data;
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      Ctrl.RX.PRBS_RESET <= '0';
      Ctrl.TX.PRBS_FORCE_ERROR <= '0';
      Ctrl.EYESCAN.TRIGGER <= '0';
      Ctrl.DEBUG.CAPTURE <= '0';
      
      if localWrEn = '1' then
        case to_integer(unsigned(localAddress(6 downto 0))) is
        when 64 => --0x40
          Ctrl.DEBUG.CAPTURE          <=  localWrData( 0);               
        when 33 => --0x21
          Ctrl.TX.PRBS_FORCE_ERROR    <=  localWrData( 4);               
          reg_data(33)( 3 downto  0)  <=  localWrData( 3 downto  0);      --
          reg_data(33)( 5)            <=  localWrData( 5);                --
          reg_data(33)( 6)            <=  localWrData( 6);                --
        when 66 => --0x42
          reg_data(66)( 3 downto  0)  <=  localWrData( 3 downto  0);      --
        when 5 => --0x5
          reg_data( 5)( 0)            <=  localWrData( 0);                --
          reg_data( 5)( 4)            <=  localWrData( 4);                --
          reg_data( 5)( 5)            <=  localWrData( 5);                --
          reg_data( 5)( 8)            <=  localWrData( 8);                --
          reg_data( 5)( 9)            <=  localWrData( 9);                --
        when 70 => --0x46
          reg_data(70)(31 downto  0)  <=  localWrData(31 downto  0);      --
        when 49 => --0x31
          reg_data(49)( 0)            <=  localWrData( 0);                --
          Ctrl.EYESCAN.TRIGGER        <=  localWrData( 4);               
        when 8 => --0x8
          reg_data( 8)( 2 downto  0)  <=  localWrData( 2 downto  0);      --
        when 71 => --0x47
          reg_data(71)( 3 downto  0)  <=  localWrData( 3 downto  0);      --
        when 80 => --0x50
          reg_data(80)( 0)            <=  localWrData( 0);                --
        when 17 => --0x11
          Ctrl.RX.PRBS_RESET          <=  localWrData( 4);               
          reg_data(17)( 3 downto  0)  <=  localWrData( 3 downto  0);      --
          reg_data(17)( 5)            <=  localWrData( 5);                --
        when 82 => --0x52
          reg_data(82)(31 downto  0)  <=  localWrData(31 downto  0);      --
        when 81 => --0x51
          reg_data(81)(31 downto  0)  <=  localWrData(31 downto  0);      --
          when others => null;
        end case;
      end if;
    end if;
  end process reg_writes;

end architecture behavioral;
