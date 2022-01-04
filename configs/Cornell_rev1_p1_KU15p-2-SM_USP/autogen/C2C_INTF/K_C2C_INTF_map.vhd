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
use work.K_C2C_INTF_Ctrl.all;

entity K_C2C_INTF_map is
  generic (
    READ_TIMEOUT     : integer := 2048
    );
  port (
    clk_axi          : in  std_logic;
    reset_axi_n      : in  std_logic;
    slave_readMOSI   : in  AXIReadMOSI;
    slave_readMISO   : out AXIReadMISO  := DefaultAXIReadMISO;
    slave_writeMOSI  : in  AXIWriteMOSI;
    slave_writeMISO  : out AXIWriteMISO := DefaultAXIWriteMISO;
    
    Mon              : in  K_C2C_INTF_Mon_t;
    Ctrl             : out K_C2C_INTF_Ctrl_t
        
    );
end entity K_C2C_INTF_map;
architecture behavioral of K_C2C_INTF_map is
  signal localAddress       : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
  signal localRdData        : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData        : slv_32_t;
  signal localWrEn          : std_logic;
  signal localRdReq         : std_logic;
  signal localRdAck         : std_logic;
  signal regRdAck           : std_logic;

  
  constant BRAM_COUNT       : integer := 3;
--  signal latchBRAM          : std_logic_vector(BRAM_COUNT-1 downto 0);
--  signal delayLatchBRAM          : std_logic_vector(BRAM_COUNT-1 downto 0);
  constant BRAM_range       : int_array_t(0 to BRAM_COUNT-1) := (0 => 10
,			1 => 10
,			2 => 11);
  constant BRAM_addr        : slv32_array_t(0 to BRAM_COUNT-1) := (0 => x"00000000"
,			1 => x"00001000"
,			2 => x"00002000");
  signal BRAM_MOSI          : BRAMPortMOSI_array_t(0 to BRAM_COUNT-1);
  signal BRAM_MISO          : BRAMPortMISO_array_t(0 to BRAM_COUNT-1);
  
  
  signal reg_data :  slv32_array_t(integer range 0 to 10241);
  constant Default_reg_data : slv32_array_t(integer range 0 to 10241) := (others => x"00000000");
begin  -- architecture behavioral

  -------------------------------------------------------------------------------
  -- AXI 
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
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
      elsif BRAM_MISO(0).rd_data_valid = '1' then
        localRdAck <= '1';
        localRdData_latch <= BRAM_MISO(0).rd_data;
elsif BRAM_MISO(1).rd_data_valid = '1' then
        localRdAck <= '1';
        localRdData_latch <= BRAM_MISO(1).rd_data;
elsif BRAM_MISO(2).rd_data_valid = '1' then
        localRdAck <= '1';
        localRdData_latch <= BRAM_MISO(2).rd_data;

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
        case to_integer(unsigned(localAddress(13 downto 0))) is
          
        when 1024 => --0x400
          localRdData( 0)            <=  Mon.C2C(1).STATUS.CONFIG_ERROR;                    --C2C config error
          localRdData( 1)            <=  Mon.C2C(1).STATUS.LINK_ERROR;                      --C2C link error
          localRdData( 2)            <=  Mon.C2C(1).STATUS.LINK_GOOD;                       --C2C link FSM in SYNC
          localRdData( 3)            <=  Mon.C2C(1).STATUS.MB_ERROR;                        --C2C multi-bit error
          localRdData( 4)            <=  Mon.C2C(1).STATUS.DO_CC;                           --Aurora do CC
          localRdData( 5)            <=  reg_data(1024)( 5);                                --C2C initialize
          localRdData( 8)            <=  Mon.C2C(1).STATUS.PHY_RESET;                       --Aurora phy in reset
          localRdData( 9)            <=  Mon.C2C(1).STATUS.PHY_GT_PLL_LOCK;                 --Aurora phy GT PLL locked
          localRdData(10)            <=  Mon.C2C(1).STATUS.PHY_MMCM_LOL;                    --Aurora phy mmcm LOL
          localRdData(13 downto 12)  <=  Mon.C2C(1).STATUS.PHY_LANE_UP;                     --Aurora phy lanes up
          localRdData(16)            <=  Mon.C2C(1).STATUS.PHY_HARD_ERR;                    --Aurora phy hard error
          localRdData(17)            <=  Mon.C2C(1).STATUS.PHY_SOFT_ERR;                    --Aurora phy soft error
          localRdData(18)            <=  Mon.C2C(1).STATUS.CHANNEL_UP;                      --Channel up
          localRdData(31)            <=  Mon.C2C(1).STATUS.LINK_IN_FW;                      --FW includes this link
        when 1028 => --0x404
          localRdData(15 downto  0)  <=  Mon.C2C(1).DEBUG.DMONITOR;                         --DEBUG d monitor
          localRdData(16)            <=  Mon.C2C(1).DEBUG.QPLL_LOCK;                        --DEBUG cplllock
          localRdData(20)            <=  Mon.C2C(1).DEBUG.CPLL_LOCK;                        --DEBUG cplllock
          localRdData(21)            <=  Mon.C2C(1).DEBUG.EYESCAN_DATA_ERROR;               --DEBUG eyescan data error
          localRdData(23)            <=  reg_data(1028)(23);                                --DEBUG eyescan trigger
        when 1029 => --0x405
          localRdData(15 downto  0)  <=  reg_data(1029)(15 downto  0);                      --bit 2 is DRP uber reset
        when 1030 => --0x406
          localRdData( 2 downto  0)  <=  Mon.C2C(1).DEBUG.RX.BUF_STATUS;                    --DEBUG rx buf status
          localRdData( 5)            <=  Mon.C2C(1).DEBUG.RX.PMA_RESET_DONE;                --DEBUG rx reset done
          localRdData(10)            <=  Mon.C2C(1).DEBUG.RX.PRBS_ERR;                      --DEBUG rx PRBS error
          localRdData(11)            <=  Mon.C2C(1).DEBUG.RX.RESET_DONE;                    --DEBUG rx reset done
          localRdData(13)            <=  reg_data(1030)(13);                                --DEBUG rx CDR hold
          localRdData(18)            <=  reg_data(1030)(18);                                --DEBUG rx LPM ENABLE
          localRdData(25)            <=  reg_data(1030)(25);                                --DEBUG rx PRBS counter reset
          localRdData(29 downto 26)  <=  reg_data(1030)(29 downto 26);                      --DEBUG rx PRBS select
        when 1031 => --0x407
          localRdData( 2 downto  0)  <=  reg_data(1031)( 2 downto  0);                      --DEBUG rx rate
        when 1032 => --0x408
          localRdData( 1 downto  0)  <=  Mon.C2C(1).DEBUG.TX.BUF_STATUS;                    --DEBUG tx buf status
          localRdData( 2)            <=  Mon.C2C(1).DEBUG.TX.RESET_DONE;                    --DEBUG tx reset done
          localRdData( 7)            <=  reg_data(1032)( 7);                                --DEBUG tx inhibit
          localRdData(17)            <=  reg_data(1032)(17);                                --DEBUG tx polarity
          localRdData(22 downto 18)  <=  reg_data(1032)(22 downto 18);                      --DEBUG post cursor
          localRdData(23)            <=  reg_data(1032)(23);                                --DEBUG force PRBS error
          localRdData(31 downto 27)  <=  reg_data(1032)(31 downto 27);                      --DEBUG pre cursor
        when 1033 => --0x409
          localRdData( 3 downto  0)  <=  reg_data(1033)( 3 downto  0);                      --DEBUG PRBS select
          localRdData( 8 downto  4)  <=  reg_data(1033)( 8 downto  4);                      --DEBUG tx diff control
        when 1040 => --0x410
          localRdData(31 downto  0)  <=  Mon.C2C(1).COUNTERS.ERRORS_ALL_TIME;               --Counter for all errors while locked
        when 1041 => --0x411
          localRdData(31 downto  0)  <=  Mon.C2C(1).COUNTERS.ERRORS_SINCE_LOCKED;           --Counter for errors since locked
        when 1042 => --0x412
          localRdData(31 downto  0)  <=  Mon.C2C(1).COUNTERS.CONFIG_ERROR_COUNT;            --Counter for CONFIG_ERROR
        when 1043 => --0x413
          localRdData(31 downto  0)  <=  Mon.C2C(1).COUNTERS.LINK_ERROR_COUNT;              --Counter for LINK_ERROR
        when 1044 => --0x414
          localRdData(31 downto  0)  <=  Mon.C2C(1).COUNTERS.MB_ERROR_COUNT;                --Counter for MB_ERROR
        when 1045 => --0x415
          localRdData(31 downto  0)  <=  Mon.C2C(1).COUNTERS.PHY_HARD_ERROR_COUNT;          --Counter for PHY_HARD_ERROR
        when 1046 => --0x416
          localRdData(31 downto  0)  <=  Mon.C2C(1).COUNTERS.PHY_SOFT_ERROR_COUNT;          --Counter for PHY_SOFT_ERROR
        when 1047 => --0x417
          localRdData( 2 downto  0)  <=  Mon.C2C(1).COUNTERS.PHYLANE_STATE;                 --Current state of phy_lane_control module
        when 1049 => --0x419
          localRdData(31 downto  0)  <=  Mon.C2C(1).COUNTERS.ERROR_WAITS_SINCE_LOCKED;      --Count for phylane in error state
        when 1050 => --0x41a
          localRdData(31 downto  0)  <=  Mon.C2C(1).COUNTERS.USER_CLK_FREQ;                 --Frequency of the user C2C clk
        when 1051 => --0x41b
          localRdData(31 downto  0)  <=  Mon.C2C(1).COUNTERS.XCVR_RESETS;                   --Count for phylane in error state
        when 1052 => --0x41c
          localRdData(31 downto  0)  <=  Mon.C2C(1).COUNTERS.WAITING_TIMEOUTS;              --Count of initialize cycles
        when 1053 => --0x41d
          localRdData(31 downto  0)  <=  Mon.C2C(1).COUNTERS.SB_ERROR_RATE;                 --single bit error rate
        when 1054 => --0x41e
          localRdData(31 downto  0)  <=  Mon.C2C(1).COUNTERS.MB_ERROR_RATE;                 --multi bit error rate
        when 1056 => --0x420
          localRdData(31 downto  0)  <=  Mon.C2C(1).USER_FREQ;                              --Measured Freq of clock
        when 1057 => --0x421
          localRdData(23 downto  0)  <=  reg_data(1057)(23 downto  0);                      --Time spent waiting for phylane to stabilize
          localRdData(24)            <=  reg_data(1057)(24);                                --phy_lane_control is enabled
        when 1058 => --0x422
          localRdData(19 downto  0)  <=  reg_data(1058)(19 downto  0);                      --Contious phy_lane_up signals required to lock phylane control
        when 1059 => --0x423
          localRdData( 7 downto  0)  <=  reg_data(1059)( 7 downto  0);                      --Number of failures before we reset the pma
        when 1060 => --0x424
          localRdData(31 downto  0)  <=  reg_data(1060)(31 downto  0);                      --Max single bit error rate
        when 1061 => --0x425
          localRdData(31 downto  0)  <=  reg_data(1061)(31 downto  0);                      --Max multi bit error rate
        when 5120 => --0x1400
          localRdData( 0)            <=  Mon.C2C(2).STATUS.CONFIG_ERROR;                    --C2C config error
          localRdData( 1)            <=  Mon.C2C(2).STATUS.LINK_ERROR;                      --C2C link error
          localRdData( 2)            <=  Mon.C2C(2).STATUS.LINK_GOOD;                       --C2C link FSM in SYNC
          localRdData( 3)            <=  Mon.C2C(2).STATUS.MB_ERROR;                        --C2C multi-bit error
          localRdData( 4)            <=  Mon.C2C(2).STATUS.DO_CC;                           --Aurora do CC
          localRdData( 5)            <=  reg_data(5120)( 5);                                --C2C initialize
          localRdData( 8)            <=  Mon.C2C(2).STATUS.PHY_RESET;                       --Aurora phy in reset
          localRdData( 9)            <=  Mon.C2C(2).STATUS.PHY_GT_PLL_LOCK;                 --Aurora phy GT PLL locked
          localRdData(10)            <=  Mon.C2C(2).STATUS.PHY_MMCM_LOL;                    --Aurora phy mmcm LOL
          localRdData(13 downto 12)  <=  Mon.C2C(2).STATUS.PHY_LANE_UP;                     --Aurora phy lanes up
          localRdData(16)            <=  Mon.C2C(2).STATUS.PHY_HARD_ERR;                    --Aurora phy hard error
          localRdData(17)            <=  Mon.C2C(2).STATUS.PHY_SOFT_ERR;                    --Aurora phy soft error
          localRdData(18)            <=  Mon.C2C(2).STATUS.CHANNEL_UP;                      --Channel up
          localRdData(31)            <=  Mon.C2C(2).STATUS.LINK_IN_FW;                      --FW includes this link
        when 5124 => --0x1404
          localRdData(15 downto  0)  <=  Mon.C2C(2).DEBUG.DMONITOR;                         --DEBUG d monitor
          localRdData(16)            <=  Mon.C2C(2).DEBUG.QPLL_LOCK;                        --DEBUG cplllock
          localRdData(20)            <=  Mon.C2C(2).DEBUG.CPLL_LOCK;                        --DEBUG cplllock
          localRdData(21)            <=  Mon.C2C(2).DEBUG.EYESCAN_DATA_ERROR;               --DEBUG eyescan data error
          localRdData(23)            <=  reg_data(5124)(23);                                --DEBUG eyescan trigger
        when 5125 => --0x1405
          localRdData(15 downto  0)  <=  reg_data(5125)(15 downto  0);                      --bit 2 is DRP uber reset
        when 5126 => --0x1406
          localRdData( 2 downto  0)  <=  Mon.C2C(2).DEBUG.RX.BUF_STATUS;                    --DEBUG rx buf status
          localRdData( 5)            <=  Mon.C2C(2).DEBUG.RX.PMA_RESET_DONE;                --DEBUG rx reset done
          localRdData(10)            <=  Mon.C2C(2).DEBUG.RX.PRBS_ERR;                      --DEBUG rx PRBS error
          localRdData(11)            <=  Mon.C2C(2).DEBUG.RX.RESET_DONE;                    --DEBUG rx reset done
          localRdData(13)            <=  reg_data(5126)(13);                                --DEBUG rx CDR hold
          localRdData(18)            <=  reg_data(5126)(18);                                --DEBUG rx LPM ENABLE
          localRdData(25)            <=  reg_data(5126)(25);                                --DEBUG rx PRBS counter reset
          localRdData(29 downto 26)  <=  reg_data(5126)(29 downto 26);                      --DEBUG rx PRBS select
        when 5127 => --0x1407
          localRdData( 2 downto  0)  <=  reg_data(5127)( 2 downto  0);                      --DEBUG rx rate
        when 5128 => --0x1408
          localRdData( 1 downto  0)  <=  Mon.C2C(2).DEBUG.TX.BUF_STATUS;                    --DEBUG tx buf status
          localRdData( 2)            <=  Mon.C2C(2).DEBUG.TX.RESET_DONE;                    --DEBUG tx reset done
          localRdData( 7)            <=  reg_data(5128)( 7);                                --DEBUG tx inhibit
          localRdData(17)            <=  reg_data(5128)(17);                                --DEBUG tx polarity
          localRdData(22 downto 18)  <=  reg_data(5128)(22 downto 18);                      --DEBUG post cursor
          localRdData(23)            <=  reg_data(5128)(23);                                --DEBUG force PRBS error
          localRdData(31 downto 27)  <=  reg_data(5128)(31 downto 27);                      --DEBUG pre cursor
        when 5129 => --0x1409
          localRdData( 3 downto  0)  <=  reg_data(5129)( 3 downto  0);                      --DEBUG PRBS select
          localRdData( 8 downto  4)  <=  reg_data(5129)( 8 downto  4);                      --DEBUG tx diff control
        when 5136 => --0x1410
          localRdData(31 downto  0)  <=  Mon.C2C(2).COUNTERS.ERRORS_ALL_TIME;               --Counter for all errors while locked
        when 5137 => --0x1411
          localRdData(31 downto  0)  <=  Mon.C2C(2).COUNTERS.ERRORS_SINCE_LOCKED;           --Counter for errors since locked
        when 5138 => --0x1412
          localRdData(31 downto  0)  <=  Mon.C2C(2).COUNTERS.CONFIG_ERROR_COUNT;            --Counter for CONFIG_ERROR
        when 5139 => --0x1413
          localRdData(31 downto  0)  <=  Mon.C2C(2).COUNTERS.LINK_ERROR_COUNT;              --Counter for LINK_ERROR
        when 5140 => --0x1414
          localRdData(31 downto  0)  <=  Mon.C2C(2).COUNTERS.MB_ERROR_COUNT;                --Counter for MB_ERROR
        when 5141 => --0x1415
          localRdData(31 downto  0)  <=  Mon.C2C(2).COUNTERS.PHY_HARD_ERROR_COUNT;          --Counter for PHY_HARD_ERROR
        when 5142 => --0x1416
          localRdData(31 downto  0)  <=  Mon.C2C(2).COUNTERS.PHY_SOFT_ERROR_COUNT;          --Counter for PHY_SOFT_ERROR
        when 5143 => --0x1417
          localRdData( 2 downto  0)  <=  Mon.C2C(2).COUNTERS.PHYLANE_STATE;                 --Current state of phy_lane_control module
        when 5145 => --0x1419
          localRdData(31 downto  0)  <=  Mon.C2C(2).COUNTERS.ERROR_WAITS_SINCE_LOCKED;      --Count for phylane in error state
        when 5146 => --0x141a
          localRdData(31 downto  0)  <=  Mon.C2C(2).COUNTERS.USER_CLK_FREQ;                 --Frequency of the user C2C clk
        when 5147 => --0x141b
          localRdData(31 downto  0)  <=  Mon.C2C(2).COUNTERS.XCVR_RESETS;                   --Count for phylane in error state
        when 5148 => --0x141c
          localRdData(31 downto  0)  <=  Mon.C2C(2).COUNTERS.WAITING_TIMEOUTS;              --Count of initialize cycles
        when 5149 => --0x141d
          localRdData(31 downto  0)  <=  Mon.C2C(2).COUNTERS.SB_ERROR_RATE;                 --single bit error rate
        when 5150 => --0x141e
          localRdData(31 downto  0)  <=  Mon.C2C(2).COUNTERS.MB_ERROR_RATE;                 --multi bit error rate
        when 5152 => --0x1420
          localRdData(31 downto  0)  <=  Mon.C2C(2).USER_FREQ;                              --Measured Freq of clock
        when 5153 => --0x1421
          localRdData(23 downto  0)  <=  reg_data(5153)(23 downto  0);                      --Time spent waiting for phylane to stabilize
          localRdData(24)            <=  reg_data(5153)(24);                                --phy_lane_control is enabled
        when 5154 => --0x1422
          localRdData(19 downto  0)  <=  reg_data(5154)(19 downto  0);                      --Contious phy_lane_up signals required to lock phylane control
        when 5155 => --0x1423
          localRdData( 7 downto  0)  <=  reg_data(5155)( 7 downto  0);                      --Number of failures before we reset the pma
        when 5156 => --0x1424
          localRdData(31 downto  0)  <=  reg_data(5156)(31 downto  0);                      --Max single bit error rate
        when 5157 => --0x1425
          localRdData(31 downto  0)  <=  reg_data(5157)(31 downto  0);                      --Max multi bit error rate
        when 10240 => --0x2800
          localRdData( 0)            <=  reg_data(10240)( 0);                               --
        when 10241 => --0x2801
          localRdData(31 downto  0)  <=  reg_data(10241)(31 downto  0);                     --


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
  Ctrl.C2C(1).STATUS.INITIALIZE              <=  reg_data(1024)( 5);                
  Ctrl.C2C(1).DEBUG.EYESCAN_TRIGGER          <=  reg_data(1028)(23);                
  Ctrl.C2C(1).DEBUG.PCS_RSV_DIN              <=  reg_data(1029)(15 downto  0);      
  Ctrl.C2C(1).DEBUG.RX.CDR_HOLD              <=  reg_data(1030)(13);                
  Ctrl.C2C(1).DEBUG.RX.LPM_EN                <=  reg_data(1030)(18);                
  Ctrl.C2C(1).DEBUG.RX.PRBS_CNT_RST          <=  reg_data(1030)(25);                
  Ctrl.C2C(1).DEBUG.RX.PRBS_SEL              <=  reg_data(1030)(29 downto 26);      
  Ctrl.C2C(1).DEBUG.RX.RATE                  <=  reg_data(1031)( 2 downto  0);      
  Ctrl.C2C(1).DEBUG.TX.INHIBIT               <=  reg_data(1032)( 7);                
  Ctrl.C2C(1).DEBUG.TX.POLARITY              <=  reg_data(1032)(17);                
  Ctrl.C2C(1).DEBUG.TX.POST_CURSOR           <=  reg_data(1032)(22 downto 18);      
  Ctrl.C2C(1).DEBUG.TX.PRBS_FORCE_ERR        <=  reg_data(1032)(23);                
  Ctrl.C2C(1).DEBUG.TX.PRE_CURSOR            <=  reg_data(1032)(31 downto 27);      
  Ctrl.C2C(1).DEBUG.TX.PRBS_SEL              <=  reg_data(1033)( 3 downto  0);      
  Ctrl.C2C(1).DEBUG.TX.DIFF_CTRL             <=  reg_data(1033)( 8 downto  4);      
  Ctrl.C2C(1).PHY_READ_TIME                  <=  reg_data(1057)(23 downto  0);      
  Ctrl.C2C(1).ENABLE_PHY_CTRL                <=  reg_data(1057)(24);                
  Ctrl.C2C(1).PHY_LANE_STABLE                <=  reg_data(1058)(19 downto  0);      
  Ctrl.C2C(1).PHY_LANE_ERRORS_TO_RESET       <=  reg_data(1059)( 7 downto  0);      
  Ctrl.C2C(1).PHY_MAX_SINGLE_BIT_ERROR_RATE  <=  reg_data(1060)(31 downto  0);      
  Ctrl.C2C(1).PHY_MAX_MULTI_BIT_ERROR_RATE   <=  reg_data(1061)(31 downto  0);      
  Ctrl.C2C(2).STATUS.INITIALIZE              <=  reg_data(5120)( 5);                
  Ctrl.C2C(2).DEBUG.EYESCAN_TRIGGER          <=  reg_data(5124)(23);                
  Ctrl.C2C(2).DEBUG.PCS_RSV_DIN              <=  reg_data(5125)(15 downto  0);      
  Ctrl.C2C(2).DEBUG.RX.CDR_HOLD              <=  reg_data(5126)(13);                
  Ctrl.C2C(2).DEBUG.RX.LPM_EN                <=  reg_data(5126)(18);                
  Ctrl.C2C(2).DEBUG.RX.PRBS_CNT_RST          <=  reg_data(5126)(25);                
  Ctrl.C2C(2).DEBUG.RX.PRBS_SEL              <=  reg_data(5126)(29 downto 26);      
  Ctrl.C2C(2).DEBUG.RX.RATE                  <=  reg_data(5127)( 2 downto  0);      
  Ctrl.C2C(2).DEBUG.TX.INHIBIT               <=  reg_data(5128)( 7);                
  Ctrl.C2C(2).DEBUG.TX.POLARITY              <=  reg_data(5128)(17);                
  Ctrl.C2C(2).DEBUG.TX.POST_CURSOR           <=  reg_data(5128)(22 downto 18);      
  Ctrl.C2C(2).DEBUG.TX.PRBS_FORCE_ERR        <=  reg_data(5128)(23);                
  Ctrl.C2C(2).DEBUG.TX.PRE_CURSOR            <=  reg_data(5128)(31 downto 27);      
  Ctrl.C2C(2).DEBUG.TX.PRBS_SEL              <=  reg_data(5129)( 3 downto  0);      
  Ctrl.C2C(2).DEBUG.TX.DIFF_CTRL             <=  reg_data(5129)( 8 downto  4);      
  Ctrl.C2C(2).PHY_READ_TIME                  <=  reg_data(5153)(23 downto  0);      
  Ctrl.C2C(2).ENABLE_PHY_CTRL                <=  reg_data(5153)(24);                
  Ctrl.C2C(2).PHY_LANE_STABLE                <=  reg_data(5154)(19 downto  0);      
  Ctrl.C2C(2).PHY_LANE_ERRORS_TO_RESET       <=  reg_data(5155)( 7 downto  0);      
  Ctrl.C2C(2).PHY_MAX_SINGLE_BIT_ERROR_RATE  <=  reg_data(5156)(31 downto  0);      
  Ctrl.C2C(2).PHY_MAX_MULTI_BIT_ERROR_RATE   <=  reg_data(5157)(31 downto  0);      
  Ctrl.PB.RESET                              <=  reg_data(10240)( 0);               
  Ctrl.PB.IRQ_COUNT                          <=  reg_data(10241)(31 downto  0);     


  reg_writes: process (clk_axi, reset_axi_n) is
  begin  -- process reg_writes
    if reset_axi_n = '0' then                 -- asynchronous reset (active low)
      reg_data(1024)( 5)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(1).STATUS.INITIALIZE;
      reg_data(1028)(22)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(1).DEBUG.EYESCAN_RESET;
      reg_data(1028)(23)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(1).DEBUG.EYESCAN_TRIGGER;
      reg_data(1029)(15 downto  0)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(1).DEBUG.PCS_RSV_DIN;
      reg_data(1030)(12)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(1).DEBUG.RX.BUF_RESET;
      reg_data(1030)(13)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(1).DEBUG.RX.CDR_HOLD;
      reg_data(1030)(17)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(1).DEBUG.RX.DFE_LPM_RESET;
      reg_data(1030)(18)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(1).DEBUG.RX.LPM_EN;
      reg_data(1030)(23)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(1).DEBUG.RX.PCS_RESET;
      reg_data(1030)(24)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(1).DEBUG.RX.PMA_RESET;
      reg_data(1030)(25)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(1).DEBUG.RX.PRBS_CNT_RST;
      reg_data(1030)(29 downto 26)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(1).DEBUG.RX.PRBS_SEL;
      reg_data(1031)( 2 downto  0)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(1).DEBUG.RX.RATE;
      reg_data(1032)( 7)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(1).DEBUG.TX.INHIBIT;
      reg_data(1032)(15)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(1).DEBUG.TX.PCS_RESET;
      reg_data(1032)(16)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(1).DEBUG.TX.PMA_RESET;
      reg_data(1032)(17)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(1).DEBUG.TX.POLARITY;
      reg_data(1032)(22 downto 18)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(1).DEBUG.TX.POST_CURSOR;
      reg_data(1032)(23)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(1).DEBUG.TX.PRBS_FORCE_ERR;
      reg_data(1032)(31 downto 27)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(1).DEBUG.TX.PRE_CURSOR;
      reg_data(1033)( 3 downto  0)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(1).DEBUG.TX.PRBS_SEL;
      reg_data(1033)( 8 downto  4)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(1).DEBUG.TX.DIFF_CTRL;
      reg_data(1048)( 0)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(1).COUNTERS.RESET_COUNTERS;
      reg_data(1057)(23 downto  0)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(1).PHY_READ_TIME;
      reg_data(1057)(24)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(1).ENABLE_PHY_CTRL;
      reg_data(1058)(19 downto  0)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(1).PHY_LANE_STABLE;
      reg_data(1059)( 7 downto  0)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(1).PHY_LANE_ERRORS_TO_RESET;
      reg_data(1060)(31 downto  0)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(1).PHY_MAX_SINGLE_BIT_ERROR_RATE;
      reg_data(1061)(31 downto  0)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(1).PHY_MAX_MULTI_BIT_ERROR_RATE;
      reg_data(5120)( 5)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(2).STATUS.INITIALIZE;
      reg_data(5124)(22)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(2).DEBUG.EYESCAN_RESET;
      reg_data(5124)(23)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(2).DEBUG.EYESCAN_TRIGGER;
      reg_data(5125)(15 downto  0)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(2).DEBUG.PCS_RSV_DIN;
      reg_data(5126)(12)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(2).DEBUG.RX.BUF_RESET;
      reg_data(5126)(13)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(2).DEBUG.RX.CDR_HOLD;
      reg_data(5126)(17)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(2).DEBUG.RX.DFE_LPM_RESET;
      reg_data(5126)(18)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(2).DEBUG.RX.LPM_EN;
      reg_data(5126)(23)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(2).DEBUG.RX.PCS_RESET;
      reg_data(5126)(24)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(2).DEBUG.RX.PMA_RESET;
      reg_data(5126)(25)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(2).DEBUG.RX.PRBS_CNT_RST;
      reg_data(5126)(29 downto 26)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(2).DEBUG.RX.PRBS_SEL;
      reg_data(5127)( 2 downto  0)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(2).DEBUG.RX.RATE;
      reg_data(5128)( 7)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(2).DEBUG.TX.INHIBIT;
      reg_data(5128)(15)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(2).DEBUG.TX.PCS_RESET;
      reg_data(5128)(16)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(2).DEBUG.TX.PMA_RESET;
      reg_data(5128)(17)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(2).DEBUG.TX.POLARITY;
      reg_data(5128)(22 downto 18)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(2).DEBUG.TX.POST_CURSOR;
      reg_data(5128)(23)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(2).DEBUG.TX.PRBS_FORCE_ERR;
      reg_data(5128)(31 downto 27)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(2).DEBUG.TX.PRE_CURSOR;
      reg_data(5129)( 3 downto  0)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(2).DEBUG.TX.PRBS_SEL;
      reg_data(5129)( 8 downto  4)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(2).DEBUG.TX.DIFF_CTRL;
      reg_data(5144)( 0)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(2).COUNTERS.RESET_COUNTERS;
      reg_data(5153)(23 downto  0)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(2).PHY_READ_TIME;
      reg_data(5153)(24)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(2).ENABLE_PHY_CTRL;
      reg_data(5154)(19 downto  0)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(2).PHY_LANE_STABLE;
      reg_data(5155)( 7 downto  0)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(2).PHY_LANE_ERRORS_TO_RESET;
      reg_data(5156)(31 downto  0)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(2).PHY_MAX_SINGLE_BIT_ERROR_RATE;
      reg_data(5157)(31 downto  0)  <= DEFAULT_K_C2C_INTF_CTRL_t.C2C(2).PHY_MAX_MULTI_BIT_ERROR_RATE;
      reg_data(10240)( 0)  <= DEFAULT_K_C2C_INTF_CTRL_t.PB.RESET;
      reg_data(10241)(31 downto  0)  <= DEFAULT_K_C2C_INTF_CTRL_t.PB.IRQ_COUNT;

    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      Ctrl.C2C(1).DEBUG.EYESCAN_RESET <= '0';
      Ctrl.C2C(1).DEBUG.RX.BUF_RESET <= '0';
      Ctrl.C2C(1).DEBUG.RX.DFE_LPM_RESET <= '0';
      Ctrl.C2C(1).DEBUG.RX.PCS_RESET <= '0';
      Ctrl.C2C(1).DEBUG.RX.PMA_RESET <= '0';
      Ctrl.C2C(1).DEBUG.TX.PCS_RESET <= '0';
      Ctrl.C2C(1).DEBUG.TX.PMA_RESET <= '0';
      Ctrl.C2C(1).COUNTERS.RESET_COUNTERS <= '0';
      Ctrl.C2C(2).DEBUG.EYESCAN_RESET <= '0';
      Ctrl.C2C(2).DEBUG.RX.BUF_RESET <= '0';
      Ctrl.C2C(2).DEBUG.RX.DFE_LPM_RESET <= '0';
      Ctrl.C2C(2).DEBUG.RX.PCS_RESET <= '0';
      Ctrl.C2C(2).DEBUG.RX.PMA_RESET <= '0';
      Ctrl.C2C(2).DEBUG.TX.PCS_RESET <= '0';
      Ctrl.C2C(2).DEBUG.TX.PMA_RESET <= '0';
      Ctrl.C2C(2).COUNTERS.RESET_COUNTERS <= '0';
      

      
      if localWrEn = '1' then
        case to_integer(unsigned(localAddress(13 downto 0))) is
        when 1024 => --0x400
          reg_data(1024)( 5)                   <=  localWrData( 5);                --C2C initialize
        when 1028 => --0x404
          Ctrl.C2C(1).DEBUG.EYESCAN_RESET      <=  localWrData(22);               
          reg_data(1028)(23)                   <=  localWrData(23);                --DEBUG eyescan trigger
        when 1029 => --0x405
          reg_data(1029)(15 downto  0)         <=  localWrData(15 downto  0);      --bit 2 is DRP uber reset
        when 1030 => --0x406
          Ctrl.C2C(1).DEBUG.RX.BUF_RESET       <=  localWrData(12);               
          Ctrl.C2C(1).DEBUG.RX.DFE_LPM_RESET   <=  localWrData(17);               
          Ctrl.C2C(1).DEBUG.RX.PCS_RESET       <=  localWrData(23);               
          Ctrl.C2C(1).DEBUG.RX.PMA_RESET       <=  localWrData(24);               
          reg_data(1030)(13)                   <=  localWrData(13);                --DEBUG rx CDR hold
          reg_data(1030)(18)                   <=  localWrData(18);                --DEBUG rx LPM ENABLE
          reg_data(1030)(25)                   <=  localWrData(25);                --DEBUG rx PRBS counter reset
          reg_data(1030)(29 downto 26)         <=  localWrData(29 downto 26);      --DEBUG rx PRBS select
        when 1031 => --0x407
          reg_data(1031)( 2 downto  0)         <=  localWrData( 2 downto  0);      --DEBUG rx rate
        when 1032 => --0x408
          Ctrl.C2C(1).DEBUG.TX.PCS_RESET       <=  localWrData(15);               
          Ctrl.C2C(1).DEBUG.TX.PMA_RESET       <=  localWrData(16);               
          reg_data(1032)( 7)                   <=  localWrData( 7);                --DEBUG tx inhibit
          reg_data(1032)(17)                   <=  localWrData(17);                --DEBUG tx polarity
          reg_data(1032)(22 downto 18)         <=  localWrData(22 downto 18);      --DEBUG post cursor
          reg_data(1032)(23)                   <=  localWrData(23);                --DEBUG force PRBS error
          reg_data(1032)(31 downto 27)         <=  localWrData(31 downto 27);      --DEBUG pre cursor
        when 1033 => --0x409
          reg_data(1033)( 3 downto  0)         <=  localWrData( 3 downto  0);      --DEBUG PRBS select
          reg_data(1033)( 8 downto  4)         <=  localWrData( 8 downto  4);      --DEBUG tx diff control
        when 1048 => --0x418
          Ctrl.C2C(1).COUNTERS.RESET_COUNTERS  <=  localWrData( 0);               
        when 1057 => --0x421
          reg_data(1057)(23 downto  0)         <=  localWrData(23 downto  0);      --Time spent waiting for phylane to stabilize
          reg_data(1057)(24)                   <=  localWrData(24);                --phy_lane_control is enabled
        when 1058 => --0x422
          reg_data(1058)(19 downto  0)         <=  localWrData(19 downto  0);      --Contious phy_lane_up signals required to lock phylane control
        when 1059 => --0x423
          reg_data(1059)( 7 downto  0)         <=  localWrData( 7 downto  0);      --Number of failures before we reset the pma
        when 1060 => --0x424
          reg_data(1060)(31 downto  0)         <=  localWrData(31 downto  0);      --Max single bit error rate
        when 1061 => --0x425
          reg_data(1061)(31 downto  0)         <=  localWrData(31 downto  0);      --Max multi bit error rate
        when 5120 => --0x1400
          reg_data(5120)( 5)                   <=  localWrData( 5);                --C2C initialize
        when 5124 => --0x1404
          Ctrl.C2C(2).DEBUG.EYESCAN_RESET      <=  localWrData(22);               
          reg_data(5124)(23)                   <=  localWrData(23);                --DEBUG eyescan trigger
        when 5125 => --0x1405
          reg_data(5125)(15 downto  0)         <=  localWrData(15 downto  0);      --bit 2 is DRP uber reset
        when 5126 => --0x1406
          Ctrl.C2C(2).DEBUG.RX.BUF_RESET       <=  localWrData(12);               
          Ctrl.C2C(2).DEBUG.RX.DFE_LPM_RESET   <=  localWrData(17);               
          Ctrl.C2C(2).DEBUG.RX.PCS_RESET       <=  localWrData(23);               
          Ctrl.C2C(2).DEBUG.RX.PMA_RESET       <=  localWrData(24);               
          reg_data(5126)(13)                   <=  localWrData(13);                --DEBUG rx CDR hold
          reg_data(5126)(18)                   <=  localWrData(18);                --DEBUG rx LPM ENABLE
          reg_data(5126)(25)                   <=  localWrData(25);                --DEBUG rx PRBS counter reset
          reg_data(5126)(29 downto 26)         <=  localWrData(29 downto 26);      --DEBUG rx PRBS select
        when 5127 => --0x1407
          reg_data(5127)( 2 downto  0)         <=  localWrData( 2 downto  0);      --DEBUG rx rate
        when 5128 => --0x1408
          Ctrl.C2C(2).DEBUG.TX.PCS_RESET       <=  localWrData(15);               
          Ctrl.C2C(2).DEBUG.TX.PMA_RESET       <=  localWrData(16);               
          reg_data(5128)( 7)                   <=  localWrData( 7);                --DEBUG tx inhibit
          reg_data(5128)(17)                   <=  localWrData(17);                --DEBUG tx polarity
          reg_data(5128)(22 downto 18)         <=  localWrData(22 downto 18);      --DEBUG post cursor
          reg_data(5128)(23)                   <=  localWrData(23);                --DEBUG force PRBS error
          reg_data(5128)(31 downto 27)         <=  localWrData(31 downto 27);      --DEBUG pre cursor
        when 5129 => --0x1409
          reg_data(5129)( 3 downto  0)         <=  localWrData( 3 downto  0);      --DEBUG PRBS select
          reg_data(5129)( 8 downto  4)         <=  localWrData( 8 downto  4);      --DEBUG tx diff control
        when 5144 => --0x1418
          Ctrl.C2C(2).COUNTERS.RESET_COUNTERS  <=  localWrData( 0);               
        when 5153 => --0x1421
          reg_data(5153)(23 downto  0)         <=  localWrData(23 downto  0);      --Time spent waiting for phylane to stabilize
          reg_data(5153)(24)                   <=  localWrData(24);                --phy_lane_control is enabled
        when 5154 => --0x1422
          reg_data(5154)(19 downto  0)         <=  localWrData(19 downto  0);      --Contious phy_lane_up signals required to lock phylane control
        when 5155 => --0x1423
          reg_data(5155)( 7 downto  0)         <=  localWrData( 7 downto  0);      --Number of failures before we reset the pma
        when 5156 => --0x1424
          reg_data(5156)(31 downto  0)         <=  localWrData(31 downto  0);      --Max single bit error rate
        when 5157 => --0x1425
          reg_data(5157)(31 downto  0)         <=  localWrData(31 downto  0);      --Max multi bit error rate
        when 10240 => --0x2800
          reg_data(10240)( 0)                  <=  localWrData( 0);                --
        when 10241 => --0x2801
          reg_data(10241)(31 downto  0)        <=  localWrData(31 downto  0);      --

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
--        latchBRAM(iBRAM) <= '0';
        BRAM_MOSI(iBRAM).enable  <= '0';
      elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
        BRAM_MOSI(iBRAM).address <= localAddress;
--        latchBRAM(iBRAM) <= '0';
        BRAM_MOSI(iBRAM).enable  <= '0';
        if localAddress(13 downto BRAM_range(iBRAM)) = BRAM_addr(iBRAM)(13 downto BRAM_range(iBRAM)) then
--          latchBRAM(iBRAM) <= localRdReq;
--          BRAM_MOSI(iBRAM).enable  <= '1';
          BRAM_MOSI(iBRAM).enable  <= localRdReq;
        end if;
      end if;
    end process BRAM_read;
  end generate BRAM_reads;



  BRAM_asyncs: for iBRAM in 0 to BRAM_COUNT-1 generate
    BRAM_MOSI(iBRAM).clk     <= clk_axi;
    BRAM_MOSI(iBRAM).wr_data <= localWrData;
  end generate BRAM_asyncs;
  
  Ctrl.C2C(1).DRP.clk       <=  BRAM_MOSI(0).clk;
  Ctrl.C2C(1).DRP.enable    <=  BRAM_MOSI(0).enable;
  Ctrl.C2C(1).DRP.wr_enable <=  BRAM_MOSI(0).wr_enable;
  Ctrl.C2C(1).DRP.address   <=  BRAM_MOSI(0).address(10-1 downto 0);
  Ctrl.C2C(1).DRP.wr_data   <=  BRAM_MOSI(0).wr_data(16-1 downto 0);

  Ctrl.C2C(2).DRP.clk       <=  BRAM_MOSI(1).clk;
  Ctrl.C2C(2).DRP.enable    <=  BRAM_MOSI(1).enable;
  Ctrl.C2C(2).DRP.wr_enable <=  BRAM_MOSI(1).wr_enable;
  Ctrl.C2C(2).DRP.address   <=  BRAM_MOSI(1).address(10-1 downto 0);
  Ctrl.C2C(2).DRP.wr_data   <=  BRAM_MOSI(1).wr_data(16-1 downto 0);

  Ctrl.PB.MEM.clk       <=  BRAM_MOSI(2).clk;
  Ctrl.PB.MEM.enable    <=  BRAM_MOSI(2).enable;
  Ctrl.PB.MEM.wr_enable <=  BRAM_MOSI(2).wr_enable;
  Ctrl.PB.MEM.address   <=  BRAM_MOSI(2).address(11-1 downto 0);
  Ctrl.PB.MEM.wr_data   <=  BRAM_MOSI(2).wr_data(18-1 downto 0);


  BRAM_MISO(0).rd_data(16-1 downto 0) <= Mon.C2C(1).DRP.rd_data;
  BRAM_MISO(0).rd_data(31 downto 16) <= (others => '0');
  BRAM_MISO(0).rd_data_valid <= Mon.C2C(1).DRP.rd_data_valid;

  BRAM_MISO(1).rd_data(16-1 downto 0) <= Mon.C2C(2).DRP.rd_data;
  BRAM_MISO(1).rd_data(31 downto 16) <= (others => '0');
  BRAM_MISO(1).rd_data_valid <= Mon.C2C(2).DRP.rd_data_valid;

  BRAM_MISO(2).rd_data(18-1 downto 0) <= Mon.PB.MEM.rd_data;
  BRAM_MISO(2).rd_data(31 downto 18) <= (others => '0');
  BRAM_MISO(2).rd_data_valid <= Mon.PB.MEM.rd_data_valid;

    

  BRAM_writes: for iBRAM in 0 to BRAM_COUNT-1 generate
    BRAM_write: process (clk_axi,reset_axi_n) is    
    begin  -- process BRAM_reads
      if reset_axi_n = '0' then
        BRAM_MOSI(iBRAM).wr_enable   <= '0';
      elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
        BRAM_MOSI(iBRAM).wr_enable   <= '0';
        if localAddress(13 downto BRAM_range(iBRAM)) = BRAM_addr(iBRAM)(13 downto BRAM_range(iBRAM)) then
          BRAM_MOSI(iBRAM).wr_enable   <= localWrEn;
        end if;
      end if;
    end process BRAM_write;
  end generate BRAM_writes;


  
end architecture behavioral;