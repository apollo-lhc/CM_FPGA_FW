--This file was auto-generated.
--Modifications might be lost.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AXIRegWidthPkg.all;
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
  signal localAddress       : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
  signal localRdData        : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData        : slv_32_t;
  signal localWrEn          : std_logic;
  signal localRdReq         : std_logic;
  signal localRdAck         : std_logic;


  signal reg_data :  slv32_array_t(integer range 0 to 515);
  constant Default_reg_data : slv32_array_t(integer range 0 to 515) := (others => x"00000000");
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
      case to_integer(unsigned(localAddress(9 downto 0))) is

        when 0 => --0x0
          localRdData( 0)            <=  Mon.C2C.STATUS.CONFIG_ERROR;           --C2C config error
          localRdData( 1)            <=  Mon.C2C.STATUS.LINK_ERROR;             --C2C link error
          localRdData( 2)            <=  Mon.C2C.STATUS.LINK_GOOD;              --C2C link FSM in SYNC
          localRdData( 3)            <=  Mon.C2C.STATUS.MB_ERROR;               --C2C multi-bit error
          localRdData( 4)            <=  Mon.C2C.STATUS.DO_CC;                  --Aurora do CC
          localRdData( 5)            <=  reg_data( 0)( 5);                      --C2C initialize
          localRdData( 8)            <=  Mon.C2C.STATUS.PHY_RESET;              --Aurora phy in reset
          localRdData( 9)            <=  Mon.C2C.STATUS.PHY_GT_PLL_LOCK;        --Aurora phy GT PLL locked
          localRdData(10)            <=  Mon.C2C.STATUS.PHY_MMCM_LOL;           --Aurora phy mmcm LOL
          localRdData(13 downto 12)  <=  Mon.C2C.STATUS.PHY_LANE_UP;            --Aurora phy lanes up
          localRdData(16)            <=  Mon.C2C.STATUS.PHY_HARD_ERR;           --Aurora phy hard error
          localRdData(17)            <=  Mon.C2C.STATUS.PHY_SOFT_ERR;           --Aurora phy soft error
          localRdData(18)            <=  Mon.C2C.STATUS.CHANNEL_UP;             --Channel up
          localRdData(31)            <=  Mon.C2C.STATUS.LINK_IN_FW;             --FW includes this link
        when 256 => --0x100
          localRdData( 7 downto  0)  <=  reg_data(256)( 7 downto  0);           --
          localRdData(15 downto  8)  <=  reg_data(256)(15 downto  8);           --
          localRdData(23 downto 16)  <=  reg_data(256)(23 downto 16);           --
        when 514 => --0x202
          localRdData(31 downto  0)  <=  reg_data(514)(31 downto  0);           --
        when 515 => --0x203
          localRdData(31 downto  0)  <=  Mon.BRAM.RD_DATA;                      --
        when 4 => --0x4
          localRdData(15 downto  0)  <=  Mon.C2C.DEBUG.DMONITOR;                --DEBUG d monitor
          localRdData(16)            <=  Mon.C2C.DEBUG.QPLL_LOCK;               --DEBUG cplllock
          localRdData(20)            <=  Mon.C2C.DEBUG.CPLL_LOCK;               --DEBUG cplllock
          localRdData(21)            <=  Mon.C2C.DEBUG.EYESCAN_DATA_ERROR;      --DEBUG eyescan data error
          localRdData(22)            <=  reg_data( 4)(22);                      --DEBUG eyescan reset
          localRdData(23)            <=  reg_data( 4)(23);                      --DEBUG eyescan trigger
        when 5 => --0x5
          localRdData(15 downto  0)  <=  reg_data( 5)(15 downto  0);            --bit 2 is DRP uber reset
        when 6 => --0x6
          localRdData( 2 downto  0)  <=  Mon.C2C.DEBUG.RX.BUF_STATUS;           --DEBUG rx buf status
          localRdData(10)            <=  Mon.C2C.DEBUG.RX.PRBS_ERR;             --DEBUG rx PRBS error
          localRdData(11)            <=  Mon.C2C.DEBUG.RX.RESET_DONE;           --DEBUG rx reset done
          localRdData(12)            <=  reg_data( 6)(12);                      --DEBUG rx buf reset
          localRdData(13)            <=  reg_data( 6)(13);                      --DEBUG rx CDR hold
          localRdData(17)            <=  reg_data( 6)(17);                      --DEBUG rx DFE LPM RESET
          localRdData(18)            <=  reg_data( 6)(18);                      --DEBUG rx LPM ENABLE
          localRdData(23)            <=  reg_data( 6)(23);                      --DEBUG rx pcs reset
          localRdData(24)            <=  reg_data( 6)(24);                      --DEBUG rx pma reset
          localRdData(25)            <=  reg_data( 6)(25);                      --DEBUG rx PRBS counter reset
          localRdData(29 downto 26)  <=  reg_data( 6)(29 downto 26);            --DEBUG rx PRBS select
        when 7 => --0x7
          localRdData( 2 downto  0)  <=  reg_data( 7)( 2 downto  0);            --DEBUG rx rate
        when 8 => --0x8
          localRdData( 1 downto  0)  <=  Mon.C2C.DEBUG.TX.BUF_STATUS;           --DEBUG tx buf status
          localRdData( 2)            <=  Mon.C2C.DEBUG.TX.RESET_DONE;           --DEBUG tx reset done
          localRdData( 7)            <=  reg_data( 8)( 7);                      --DEBUG tx inhibit
          localRdData(15)            <=  reg_data( 8)(15);                      --DEBUG tx pcs reset
          localRdData(16)            <=  reg_data( 8)(16);                      --DEBUG tx pma reset
          localRdData(17)            <=  reg_data( 8)(17);                      --DEBUG tx polarity
          localRdData(22 downto 18)  <=  reg_data( 8)(22 downto 18);            --DEBUG post cursor
          localRdData(23)            <=  reg_data( 8)(23);                      --DEBUG force PRBS error
          localRdData(31 downto 27)  <=  reg_data( 8)(31 downto 27);            --DEBUG pre cursor
        when 9 => --0x9
          localRdData( 3 downto  0)  <=  reg_data( 9)( 3 downto  0);            --DEBUG PRBS select
          localRdData( 8 downto  4)  <=  reg_data( 9)( 8 downto  4);            --DEBUG tx diff control
          localRdData(31 downto  0)  <=  Mon.C2C.USER_FREQ;                     --Measured Freq of clock
        when 16 => --0x10
          localRdData( 0)            <=  Mon.CLK_200_LOCKED;                    --
        when 513 => --0x201
          localRdData(14 downto  0)  <=  reg_data(513)(14 downto  0);           --


        when others =>
          localRdData <= x"00000000";
      end case;
    end if;
  end process reads;




  -- Register mapping to ctrl structures
  Ctrl.C2C.STATUS.INITIALIZE        <=  reg_data( 0)( 5);                
  Ctrl.C2C.DEBUG.EYESCAN_RESET      <=  reg_data( 4)(22);                
  Ctrl.C2C.DEBUG.EYESCAN_TRIGGER    <=  reg_data( 4)(23);                
  Ctrl.C2C.DEBUG.PCS_RSV_DIN        <=  reg_data( 5)(15 downto  0);      
  Ctrl.C2C.DEBUG.RX.BUF_RESET       <=  reg_data( 6)(12);                
  Ctrl.C2C.DEBUG.RX.CDR_HOLD        <=  reg_data( 6)(13);                
  Ctrl.C2C.DEBUG.RX.DFE_LPM_RESET   <=  reg_data( 6)(17);                
  Ctrl.C2C.DEBUG.RX.LPM_EN          <=  reg_data( 6)(18);                
  Ctrl.C2C.DEBUG.RX.PCS_RESET       <=  reg_data( 6)(23);                
  Ctrl.C2C.DEBUG.RX.PMA_RESET       <=  reg_data( 6)(24);                
  Ctrl.C2C.DEBUG.RX.PRBS_CNT_RST    <=  reg_data( 6)(25);                
  Ctrl.C2C.DEBUG.RX.PRBS_SEL        <=  reg_data( 6)(29 downto 26);      
  Ctrl.C2C.DEBUG.RX.RATE            <=  reg_data( 7)( 2 downto  0);      
  Ctrl.C2C.DEBUG.TX.INHIBIT         <=  reg_data( 8)( 7);                
  Ctrl.C2C.DEBUG.TX.PCS_RESET       <=  reg_data( 8)(15);                
  Ctrl.C2C.DEBUG.TX.PMA_RESET       <=  reg_data( 8)(16);                
  Ctrl.C2C.DEBUG.TX.POLARITY        <=  reg_data( 8)(17);                
  Ctrl.C2C.DEBUG.TX.POST_CURSOR     <=  reg_data( 8)(22 downto 18);      
  Ctrl.C2C.DEBUG.TX.PRBS_FORCE_ERR  <=  reg_data( 8)(23);                
  Ctrl.C2C.DEBUG.TX.PRE_CURSOR      <=  reg_data( 8)(31 downto 27);      
  Ctrl.C2C.DEBUG.TX.PRBS_SEL        <=  reg_data( 9)( 3 downto  0);      
  Ctrl.C2C.DEBUG.TX.DIFF_CTRL       <=  reg_data( 9)( 8 downto  4);      
  Ctrl.RGB.R                        <=  reg_data(256)( 7 downto  0);     
  Ctrl.RGB.G                        <=  reg_data(256)(15 downto  8);     
  Ctrl.RGB.B                        <=  reg_data(256)(23 downto 16);     
  Ctrl.BRAM.ADDR                    <=  reg_data(513)(14 downto  0);     
  Ctrl.BRAM.WR_DATA                 <=  reg_data(514)(31 downto  0);     


  reg_writes: process (clk_axi, reset_axi_n) is
  begin  -- process reg_writes
    if reset_axi_n = '0' then                 -- asynchronous reset (active low)
      reg_data( 0)( 5)  <= DEFAULT_K_IO_CTRL_t.C2C.STATUS.INITIALIZE;
      reg_data( 4)(22)  <= DEFAULT_K_IO_CTRL_t.C2C.DEBUG.EYESCAN_RESET;
      reg_data( 4)(23)  <= DEFAULT_K_IO_CTRL_t.C2C.DEBUG.EYESCAN_TRIGGER;
      reg_data( 5)(15 downto  0)  <= DEFAULT_K_IO_CTRL_t.C2C.DEBUG.PCS_RSV_DIN;
      reg_data( 6)(12)  <= DEFAULT_K_IO_CTRL_t.C2C.DEBUG.RX.BUF_RESET;
      reg_data( 6)(13)  <= DEFAULT_K_IO_CTRL_t.C2C.DEBUG.RX.CDR_HOLD;
      reg_data( 6)(17)  <= DEFAULT_K_IO_CTRL_t.C2C.DEBUG.RX.DFE_LPM_RESET;
      reg_data( 6)(18)  <= DEFAULT_K_IO_CTRL_t.C2C.DEBUG.RX.LPM_EN;
      reg_data( 6)(23)  <= DEFAULT_K_IO_CTRL_t.C2C.DEBUG.RX.PCS_RESET;
      reg_data( 6)(24)  <= DEFAULT_K_IO_CTRL_t.C2C.DEBUG.RX.PMA_RESET;
      reg_data( 6)(25)  <= DEFAULT_K_IO_CTRL_t.C2C.DEBUG.RX.PRBS_CNT_RST;
      reg_data( 6)(29 downto 26)  <= DEFAULT_K_IO_CTRL_t.C2C.DEBUG.RX.PRBS_SEL;
      reg_data( 7)( 2 downto  0)  <= DEFAULT_K_IO_CTRL_t.C2C.DEBUG.RX.RATE;
      reg_data( 8)( 7)  <= DEFAULT_K_IO_CTRL_t.C2C.DEBUG.TX.INHIBIT;
      reg_data( 8)(15)  <= DEFAULT_K_IO_CTRL_t.C2C.DEBUG.TX.PCS_RESET;
      reg_data( 8)(16)  <= DEFAULT_K_IO_CTRL_t.C2C.DEBUG.TX.PMA_RESET;
      reg_data( 8)(17)  <= DEFAULT_K_IO_CTRL_t.C2C.DEBUG.TX.POLARITY;
      reg_data( 8)(22 downto 18)  <= DEFAULT_K_IO_CTRL_t.C2C.DEBUG.TX.POST_CURSOR;
      reg_data( 8)(23)  <= DEFAULT_K_IO_CTRL_t.C2C.DEBUG.TX.PRBS_FORCE_ERR;
      reg_data( 8)(31 downto 27)  <= DEFAULT_K_IO_CTRL_t.C2C.DEBUG.TX.PRE_CURSOR;
      reg_data( 9)( 3 downto  0)  <= DEFAULT_K_IO_CTRL_t.C2C.DEBUG.TX.PRBS_SEL;
      reg_data( 9)( 8 downto  4)  <= DEFAULT_K_IO_CTRL_t.C2C.DEBUG.TX.DIFF_CTRL;
      reg_data(256)( 7 downto  0)  <= DEFAULT_K_IO_CTRL_t.RGB.R;
      reg_data(256)(15 downto  8)  <= DEFAULT_K_IO_CTRL_t.RGB.G;
      reg_data(256)(23 downto 16)  <= DEFAULT_K_IO_CTRL_t.RGB.B;
      reg_data(513)(14 downto  0)  <= DEFAULT_K_IO_CTRL_t.BRAM.ADDR;
      reg_data(514)(31 downto  0)  <= DEFAULT_K_IO_CTRL_t.BRAM.WR_DATA;

    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      Ctrl.BRAM.WRITE <= '0';
      

      
      if localWrEn = '1' then
        case to_integer(unsigned(localAddress(9 downto 0))) is
        when 0 => --0x0
          reg_data( 0)( 5)             <=  localWrData( 5);                --C2C initialize
        when 256 => --0x100
          reg_data(256)( 7 downto  0)  <=  localWrData( 7 downto  0);      --
          reg_data(256)(15 downto  8)  <=  localWrData(15 downto  8);      --
          reg_data(256)(23 downto 16)  <=  localWrData(23 downto 16);      --
        when 514 => --0x202
          reg_data(514)(31 downto  0)  <=  localWrData(31 downto  0);      --
        when 4 => --0x4
          reg_data( 4)(22)             <=  localWrData(22);                --DEBUG eyescan reset
          reg_data( 4)(23)             <=  localWrData(23);                --DEBUG eyescan trigger
        when 5 => --0x5
          reg_data( 5)(15 downto  0)   <=  localWrData(15 downto  0);      --bit 2 is DRP uber reset
        when 6 => --0x6
          reg_data( 6)(12)             <=  localWrData(12);                --DEBUG rx buf reset
          reg_data( 6)(13)             <=  localWrData(13);                --DEBUG rx CDR hold
          reg_data( 6)(17)             <=  localWrData(17);                --DEBUG rx DFE LPM RESET
          reg_data( 6)(18)             <=  localWrData(18);                --DEBUG rx LPM ENABLE
          reg_data( 6)(23)             <=  localWrData(23);                --DEBUG rx pcs reset
          reg_data( 6)(24)             <=  localWrData(24);                --DEBUG rx pma reset
          reg_data( 6)(25)             <=  localWrData(25);                --DEBUG rx PRBS counter reset
          reg_data( 6)(29 downto 26)   <=  localWrData(29 downto 26);      --DEBUG rx PRBS select
        when 7 => --0x7
          reg_data( 7)( 2 downto  0)   <=  localWrData( 2 downto  0);      --DEBUG rx rate
        when 8 => --0x8
          reg_data( 8)( 7)             <=  localWrData( 7);                --DEBUG tx inhibit
          reg_data( 8)(15)             <=  localWrData(15);                --DEBUG tx pcs reset
          reg_data( 8)(16)             <=  localWrData(16);                --DEBUG tx pma reset
          reg_data( 8)(17)             <=  localWrData(17);                --DEBUG tx polarity
          reg_data( 8)(22 downto 18)   <=  localWrData(22 downto 18);      --DEBUG post cursor
          reg_data( 8)(23)             <=  localWrData(23);                --DEBUG force PRBS error
          reg_data( 8)(31 downto 27)   <=  localWrData(31 downto 27);      --DEBUG pre cursor
        when 9 => --0x9
          reg_data( 9)( 3 downto  0)   <=  localWrData( 3 downto  0);      --DEBUG PRBS select
          reg_data( 9)( 8 downto  4)   <=  localWrData( 8 downto  4);      --DEBUG tx diff control
        when 513 => --0x201
          reg_data(513)(14 downto  0)  <=  localWrData(14 downto  0);      --
        when 512 => --0x200
          Ctrl.BRAM.WRITE              <=  localWrData( 0);               

          when others => null;
        end case;
      end if;
    end if;
  end process reg_writes;


end architecture behavioral;