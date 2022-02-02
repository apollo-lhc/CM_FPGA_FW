--This file was auto-generated.
--Modifications might be lost.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AXIRegWidthPkg.all;
use work.AXIRegPkg.all;
use work.types.all;
use work.K_TCDS_Ctrl.all;

entity K_TCDS_map is
  port (
    clk_axi          : in  std_logic;
    reset_axi_n      : in  std_logic;
    slave_readMOSI   : in  AXIReadMOSI;
    slave_readMISO   : out AXIReadMISO  := DefaultAXIReadMISO;
    slave_writeMOSI  : in  AXIWriteMOSI;
    slave_writeMISO  : out AXIWriteMISO := DefaultAXIWriteMISO;
    Mon              : in  K_TCDS_Mon_t;
    Ctrl             : out K_TCDS_Ctrl_t
    );
end entity K_TCDS_map;
architecture behavioral of K_TCDS_map is
  signal localAddress       : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
  signal localRdData        : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData        : slv_32_t;
  signal localWrEn          : std_logic;
  signal localRdReq         : std_logic;
  signal localRdAck         : std_logic;


  signal reg_data :  slv32_array_t(integer range 0 to 2048);
  constant Default_reg_data : slv32_array_t(integer range 0 to 2048) := (others => x"00000000");
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
      case to_integer(unsigned(localAddress(11 downto 0))) is

        when 0 => --0x0
          localRdData( 1)            <=  Mon.CLOCKING.POWER_GOOD;           --
          localRdData( 9)            <=  Mon.CLOCKING.RX_CDR_STABLE;        --
        when 1 => --0x1
          localRdData(31 downto  0)  <=  Mon.CLOCKING.COUNTS_TXOUTCLK;      --
        when 16 => --0x10
          localRdData( 8)            <=  Mon.STATUS.PHY_RESET;              --Aurora phy in reset
          localRdData( 9)            <=  Mon.STATUS.PHY_GT_PLL_LOCK;        --Aurora phy GT PLL locked
          localRdData(10)            <=  Mon.STATUS.PHY_MMCM_LOL;           --Aurora phy mmcm LOL
        when 32 => --0x20
          localRdData(15 downto  0)  <=  Mon.DEBUG.DMONITOR;                --DEBUG d monitor
          localRdData(16)            <=  Mon.DEBUG.QPLL_LOCK;               --DEBUG cplllock
          localRdData(20)            <=  Mon.DEBUG.CPLL_LOCK;               --DEBUG cplllock
          localRdData(21)            <=  Mon.DEBUG.EYESCAN_DATA_ERROR;      --DEBUG eyescan data error
          localRdData(23)            <=  reg_data(32)(23);                  --DEBUG eyescan trigger
        when 33 => --0x21
          localRdData(15 downto  0)  <=  reg_data(33)(15 downto  0);        --bit 2 is DRP uber reset
        when 34 => --0x22
          localRdData( 2 downto  0)  <=  Mon.DEBUG.RX.BUF_STATUS;           --DEBUG rx buf status
          localRdData( 5)            <=  Mon.DEBUG.RX.PMA_RESET_DONE;       --DEBUG rx reset done
          localRdData(10)            <=  Mon.DEBUG.RX.PRBS_ERR;             --DEBUG rx PRBS error
          localRdData(11)            <=  Mon.DEBUG.RX.RESET_DONE;           --DEBUG rx reset done
          localRdData(13)            <=  reg_data(34)(13);                  --DEBUG rx CDR hold
          localRdData(18)            <=  reg_data(34)(18);                  --DEBUG rx LPM ENABLE
          localRdData(25)            <=  reg_data(34)(25);                  --DEBUG rx PRBS counter reset
          localRdData(29 downto 26)  <=  reg_data(34)(29 downto 26);        --DEBUG rx PRBS select
        when 35 => --0x23
          localRdData( 2 downto  0)  <=  reg_data(35)( 2 downto  0);        --DEBUG rx rate
        when 36 => --0x24
          localRdData( 1 downto  0)  <=  Mon.DEBUG.TX.BUF_STATUS;           --DEBUG tx buf status
          localRdData( 2)            <=  Mon.DEBUG.TX.RESET_DONE;           --DEBUG tx reset done
          localRdData( 7)            <=  reg_data(36)( 7);                  --DEBUG tx inhibit
          localRdData(17)            <=  reg_data(36)(17);                  --DEBUG tx polarity
          localRdData(22 downto 18)  <=  reg_data(36)(22 downto 18);        --DEBUG post cursor
          localRdData(23)            <=  reg_data(36)(23);                  --DEBUG force PRBS error
          localRdData(31 downto 27)  <=  reg_data(36)(31 downto 27);        --DEBUG pre cursor
        when 37 => --0x25
          localRdData( 3 downto  0)  <=  reg_data(37)( 3 downto  0);        --DEBUG PRBS select
          localRdData( 8 downto  4)  <=  reg_data(37)( 8 downto  4);        --DEBUG tx diff control
        when 48 => --0x30
          localRdData(15 downto  0)  <=  reg_data(48)(15 downto  0);        --
          localRdData(31 downto 16)  <=  reg_data(48)(31 downto 16);        --
        when 49 => --0x31
          localRdData( 7 downto  0)  <=  reg_data(49)( 7 downto  0);        --
          localRdData( 8)            <=  Mon.TX.ACTIVE;                     --
        when 64 => --0x40
          localRdData(15 downto  0)  <=  Mon.RX.CTRL0;                      --
          localRdData(31 downto 16)  <=  Mon.RX.CTRL1;                      --
        when 65 => --0x41
          localRdData( 7 downto  0)  <=  Mon.RX.CTRL2;                      --
          localRdData( 8)            <=  Mon.RX.ACTIVE;                     --
          localRdData(15 downto  8)  <=  Mon.RX.CTRL3;                      --
        when 82 => --0x52
          localRdData( 3 downto  0)  <=  reg_data(82)( 3 downto  0);        --
        when 84 => --0x54
          localRdData(31 downto  0)  <=  Mon.DATA_CTRL.CAPTURE_D;           --
        when 85 => --0x55
          localRdData( 3 downto  0)  <=  Mon.DATA_CTRL.CAPTURE_K;           --
        when 86 => --0x56
          localRdData(31 downto  0)  <=  reg_data(86)(31 downto  0);        --
        when 87 => --0x57
          localRdData( 3 downto  0)  <=  reg_data(87)( 3 downto  0);        --
        when 96 => --0x60
          localRdData( 0)            <=  reg_data(96)( 0);                  --
          localRdData( 3 downto  1)  <=  reg_data(96)( 3 downto  1);        --


        when others =>
          localRdData <= x"00000000";
      end case;
    end if;
  end process reads;




  -- Register mapping to ctrl structures
  Ctrl.DEBUG.EYESCAN_TRIGGER    <=  reg_data(32)(23);               
  Ctrl.DEBUG.PCS_RSV_DIN        <=  reg_data(33)(15 downto  0);     
  Ctrl.DEBUG.RX.CDR_HOLD        <=  reg_data(34)(13);               
  Ctrl.DEBUG.RX.LPM_EN          <=  reg_data(34)(18);               
  Ctrl.DEBUG.RX.PRBS_CNT_RST    <=  reg_data(34)(25);               
  Ctrl.DEBUG.RX.PRBS_SEL        <=  reg_data(34)(29 downto 26);     
  Ctrl.DEBUG.RX.RATE            <=  reg_data(35)( 2 downto  0);     
  Ctrl.DEBUG.TX.INHIBIT         <=  reg_data(36)( 7);               
  Ctrl.DEBUG.TX.POLARITY        <=  reg_data(36)(17);               
  Ctrl.DEBUG.TX.POST_CURSOR     <=  reg_data(36)(22 downto 18);     
  Ctrl.DEBUG.TX.PRBS_FORCE_ERR  <=  reg_data(36)(23);               
  Ctrl.DEBUG.TX.PRE_CURSOR      <=  reg_data(36)(31 downto 27);     
  Ctrl.DEBUG.TX.PRBS_SEL        <=  reg_data(37)( 3 downto  0);     
  Ctrl.DEBUG.TX.DIFF_CTRL       <=  reg_data(37)( 8 downto  4);     
  Ctrl.TX.CTRL0                 <=  reg_data(48)(15 downto  0);     
  Ctrl.TX.CTRL1                 <=  reg_data(48)(31 downto 16);     
  Ctrl.TX.CTRL2                 <=  reg_data(49)( 7 downto  0);     
  Ctrl.DATA_CTRL.MODE           <=  reg_data(82)( 3 downto  0);     
  Ctrl.DATA_CTRL.FIXED_SEND_D   <=  reg_data(86)(31 downto  0);     
  Ctrl.DATA_CTRL.FIXED_SEND_K   <=  reg_data(87)( 3 downto  0);     
  Ctrl.TXRX_CLK_SEL             <=  reg_data(96)( 0);               
  Ctrl.LOOPBACK                 <=  reg_data(96)( 3 downto  1);     


  reg_writes: process (clk_axi, reset_axi_n) is
  begin  -- process reg_writes
    if reset_axi_n = '0' then                 -- asynchronous reset (active low)
      reg_data( 1)( 0)  <= DEFAULT_K_TCDS_CTRL_t.RESET.RESET_ALL;
      reg_data( 1)( 4)  <= DEFAULT_K_TCDS_CTRL_t.RESET.TX_PLL_AND_DATAPATH;
      reg_data( 1)( 5)  <= DEFAULT_K_TCDS_CTRL_t.RESET.TX_DATAPATH;
      reg_data( 1)( 6)  <= DEFAULT_K_TCDS_CTRL_t.RESET.RX_PLL_AND_DATAPATH;
      reg_data( 1)( 7)  <= DEFAULT_K_TCDS_CTRL_t.RESET.RX_DATAPATH;
      reg_data( 1)( 8)  <= DEFAULT_K_TCDS_CTRL_t.RESET.USERCLK_TX;
      reg_data( 1)( 9)  <= DEFAULT_K_TCDS_CTRL_t.RESET.USERCLK_RX;
      reg_data( 1)(10)  <= DEFAULT_K_TCDS_CTRL_t.RESET.DRP;
      reg_data(32)(22)  <= DEFAULT_K_TCDS_CTRL_t.DEBUG.EYESCAN_RESET;
      reg_data(32)(23)  <= DEFAULT_K_TCDS_CTRL_t.DEBUG.EYESCAN_TRIGGER;
      reg_data(33)(15 downto  0)  <= DEFAULT_K_TCDS_CTRL_t.DEBUG.PCS_RSV_DIN;
      reg_data(34)(12)  <= DEFAULT_K_TCDS_CTRL_t.DEBUG.RX.BUF_RESET;
      reg_data(34)(13)  <= DEFAULT_K_TCDS_CTRL_t.DEBUG.RX.CDR_HOLD;
      reg_data(34)(17)  <= DEFAULT_K_TCDS_CTRL_t.DEBUG.RX.DFE_LPM_RESET;
      reg_data(34)(18)  <= DEFAULT_K_TCDS_CTRL_t.DEBUG.RX.LPM_EN;
      reg_data(34)(23)  <= DEFAULT_K_TCDS_CTRL_t.DEBUG.RX.PCS_RESET;
      reg_data(34)(24)  <= DEFAULT_K_TCDS_CTRL_t.DEBUG.RX.PMA_RESET;
      reg_data(34)(25)  <= DEFAULT_K_TCDS_CTRL_t.DEBUG.RX.PRBS_CNT_RST;
      reg_data(34)(29 downto 26)  <= DEFAULT_K_TCDS_CTRL_t.DEBUG.RX.PRBS_SEL;
      reg_data(35)( 2 downto  0)  <= DEFAULT_K_TCDS_CTRL_t.DEBUG.RX.RATE;
      reg_data(36)( 7)  <= DEFAULT_K_TCDS_CTRL_t.DEBUG.TX.INHIBIT;
      reg_data(36)(15)  <= DEFAULT_K_TCDS_CTRL_t.DEBUG.TX.PCS_RESET;
      reg_data(36)(16)  <= DEFAULT_K_TCDS_CTRL_t.DEBUG.TX.PMA_RESET;
      reg_data(36)(17)  <= DEFAULT_K_TCDS_CTRL_t.DEBUG.TX.POLARITY;
      reg_data(36)(22 downto 18)  <= DEFAULT_K_TCDS_CTRL_t.DEBUG.TX.POST_CURSOR;
      reg_data(36)(23)  <= DEFAULT_K_TCDS_CTRL_t.DEBUG.TX.PRBS_FORCE_ERR;
      reg_data(36)(31 downto 27)  <= DEFAULT_K_TCDS_CTRL_t.DEBUG.TX.PRE_CURSOR;
      reg_data(37)( 3 downto  0)  <= DEFAULT_K_TCDS_CTRL_t.DEBUG.TX.PRBS_SEL;
      reg_data(37)( 8 downto  4)  <= DEFAULT_K_TCDS_CTRL_t.DEBUG.TX.DIFF_CTRL;
      reg_data(48)(15 downto  0)  <= DEFAULT_K_TCDS_CTRL_t.TX.CTRL0;
      reg_data(48)(31 downto 16)  <= DEFAULT_K_TCDS_CTRL_t.TX.CTRL1;
      reg_data(49)( 7 downto  0)  <= DEFAULT_K_TCDS_CTRL_t.TX.CTRL2;
      reg_data(50)( 0)  <= DEFAULT_K_TCDS_CTRL_t.TX.RESET;
      reg_data(66)( 0)  <= DEFAULT_K_TCDS_CTRL_t.RX.RESET;
      reg_data(80)( 0)  <= DEFAULT_K_TCDS_CTRL_t.DATA_CTRL.CAPTURE;
      reg_data(82)( 3 downto  0)  <= DEFAULT_K_TCDS_CTRL_t.DATA_CTRL.MODE;
      reg_data(86)(31 downto  0)  <= DEFAULT_K_TCDS_CTRL_t.DATA_CTRL.FIXED_SEND_D;
      reg_data(87)( 3 downto  0)  <= DEFAULT_K_TCDS_CTRL_t.DATA_CTRL.FIXED_SEND_K;
      reg_data(96)( 0)  <= DEFAULT_K_TCDS_CTRL_t.TXRX_CLK_SEL;
      reg_data(96)( 3 downto  1)  <= DEFAULT_K_TCDS_CTRL_t.LOOPBACK;

    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      Ctrl.RESET.RESET_ALL <= '0';
      Ctrl.RESET.TX_PLL_AND_DATAPATH <= '0';
      Ctrl.RESET.TX_DATAPATH <= '0';
      Ctrl.RESET.RX_PLL_AND_DATAPATH <= '0';
      Ctrl.RESET.RX_DATAPATH <= '0';
      Ctrl.RESET.USERCLK_TX <= '0';
      Ctrl.RESET.USERCLK_RX <= '0';
      Ctrl.RESET.DRP <= '0';
      Ctrl.DEBUG.EYESCAN_RESET <= '0';
      Ctrl.DEBUG.RX.BUF_RESET <= '0';
      Ctrl.DEBUG.RX.DFE_LPM_RESET <= '0';
      Ctrl.DEBUG.RX.PCS_RESET <= '0';
      Ctrl.DEBUG.RX.PMA_RESET <= '0';
      Ctrl.DEBUG.TX.PCS_RESET <= '0';
      Ctrl.DEBUG.TX.PMA_RESET <= '0';
      Ctrl.TX.RESET <= '0';
      Ctrl.RX.RESET <= '0';
      Ctrl.DATA_CTRL.CAPTURE <= '0';
      

      
      if localWrEn = '1' then
        case to_integer(unsigned(localAddress(11 downto 0))) is
        when 1 => --0x1
          Ctrl.RESET.RESET_ALL            <=  localWrData( 0);               
          Ctrl.RESET.TX_PLL_AND_DATAPATH  <=  localWrData( 4);               
          Ctrl.RESET.TX_DATAPATH          <=  localWrData( 5);               
          Ctrl.RESET.RX_PLL_AND_DATAPATH  <=  localWrData( 6);               
          Ctrl.RESET.RX_DATAPATH          <=  localWrData( 7);               
          Ctrl.RESET.USERCLK_TX           <=  localWrData( 8);               
          Ctrl.RESET.USERCLK_RX           <=  localWrData( 9);               
          Ctrl.RESET.DRP                  <=  localWrData(10);               
        when 32 => --0x20
          Ctrl.DEBUG.EYESCAN_RESET        <=  localWrData(22);               
          reg_data(32)(23)                <=  localWrData(23);                --DEBUG eyescan trigger
        when 33 => --0x21
          reg_data(33)(15 downto  0)      <=  localWrData(15 downto  0);      --bit 2 is DRP uber reset
        when 34 => --0x22
          Ctrl.DEBUG.RX.BUF_RESET         <=  localWrData(12);               
          Ctrl.DEBUG.RX.DFE_LPM_RESET     <=  localWrData(17);               
          Ctrl.DEBUG.RX.PCS_RESET         <=  localWrData(23);               
          Ctrl.DEBUG.RX.PMA_RESET         <=  localWrData(24);               
          reg_data(34)(13)                <=  localWrData(13);                --DEBUG rx CDR hold
          reg_data(34)(18)                <=  localWrData(18);                --DEBUG rx LPM ENABLE
          reg_data(34)(25)                <=  localWrData(25);                --DEBUG rx PRBS counter reset
          reg_data(34)(29 downto 26)      <=  localWrData(29 downto 26);      --DEBUG rx PRBS select
        when 35 => --0x23
          reg_data(35)( 2 downto  0)      <=  localWrData( 2 downto  0);      --DEBUG rx rate
        when 36 => --0x24
          Ctrl.DEBUG.TX.PCS_RESET         <=  localWrData(15);               
          Ctrl.DEBUG.TX.PMA_RESET         <=  localWrData(16);               
          reg_data(36)( 7)                <=  localWrData( 7);                --DEBUG tx inhibit
          reg_data(36)(17)                <=  localWrData(17);                --DEBUG tx polarity
          reg_data(36)(22 downto 18)      <=  localWrData(22 downto 18);      --DEBUG post cursor
          reg_data(36)(23)                <=  localWrData(23);                --DEBUG force PRBS error
          reg_data(36)(31 downto 27)      <=  localWrData(31 downto 27);      --DEBUG pre cursor
        when 37 => --0x25
          reg_data(37)( 3 downto  0)      <=  localWrData( 3 downto  0);      --DEBUG PRBS select
          reg_data(37)( 8 downto  4)      <=  localWrData( 8 downto  4);      --DEBUG tx diff control
        when 48 => --0x30
          reg_data(48)(15 downto  0)      <=  localWrData(15 downto  0);      --
          reg_data(48)(31 downto 16)      <=  localWrData(31 downto 16);      --
        when 49 => --0x31
          reg_data(49)( 7 downto  0)      <=  localWrData( 7 downto  0);      --
        when 50 => --0x32
          Ctrl.TX.RESET                   <=  localWrData( 0);               
        when 66 => --0x42
          Ctrl.RX.RESET                   <=  localWrData( 0);               
        when 80 => --0x50
          Ctrl.DATA_CTRL.CAPTURE          <=  localWrData( 0);               
        when 82 => --0x52
          reg_data(82)( 3 downto  0)      <=  localWrData( 3 downto  0);      --
        when 86 => --0x56
          reg_data(86)(31 downto  0)      <=  localWrData(31 downto  0);      --
        when 87 => --0x57
          reg_data(87)( 3 downto  0)      <=  localWrData( 3 downto  0);      --
        when 96 => --0x60
          reg_data(96)( 0)                <=  localWrData( 0);                --
          reg_data(96)( 3 downto  1)      <=  localWrData( 3 downto  1);      --

          when others => null;
        end case;
      end if;
    end if;
  end process reg_writes;


end architecture behavioral;