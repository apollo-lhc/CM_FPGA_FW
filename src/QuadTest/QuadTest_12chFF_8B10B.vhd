library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.axiRegPkg.all;
use work.Quad_Test_Ctrl.all;
use work.types.all;
use ieee.std_logic_misc.all;

Library UNISIM;
use UNISIM.vcomponents.all;

use work.FF_K1_PKG.all;
use work.FF_K2_PKG.all;
use work.FF_K3_PKG.all;
use work.FF_K7_PKG.all;

entity QuadTest is
  generic (
    CHANNEL_COUNT : integer := 4
    );
  port (
    clk_axi              : in  std_logic; --50 MHz
    reset_axi_n          : in  std_logic;
    refclk_i_p           : in  std_logic_vector(4 downto 1);
    refclk_i_n           : in  std_logic_vector(4 downto 1);
    tx_n                 : out std_logic_vector(CHANNEL_COUNT downto 1);
    tx_p                 : out std_logic_vector(CHANNEL_COUNT downto 1);
    rx_n                 : in  std_logic_vector(CHANNEL_COUNT downto 1);
    rx_p                 : in  std_logic_vector(CHANNEL_COUNT downto 1);

    readMOSI             : in  AXIreadMOSI;
    readMISO             : out AXIreadMISO;
    writeMOSI            : in  AXIwriteMOSI;
    writeMISO            : out AXIwriteMISO); -- '0' for refclk0, '1' for refclk1

end entity QuadTest;

architecture behavioral of QuadTest is
  
  signal reset             : std_logic;
  signal Mon               : QUAD_TEST_Mon_t;
  signal Ctrl              : QUAD_TEST_Ctrl_t;

--  type pma_reset_t is array (integer range <>) of std_logic_vector(CHANNEL_COUNT downto 1);
--  signal tx_pma_reset : pma_reset_t(1 to 1) := (others => (others => '0'));
--  signal rx_pma_reset : pma_reset_t(1 to 1) := (others => (others => '0'));
  constant REFCLK_COUNT    : integer := 4;
  signal ref_clk           : std_logic_vector(REFCLK_COUNT downto 1);
  signal ref_clk2          : std_logic_vector(REFCLK_COUNT downto 1);
  signal ref_clk_fabric : std_logic_vector(REFCLK_COUNT downto 1) := (others => '0');
  signal ref_clk_freq   : slv32_array_t(REFCLK_COUNT downto 1);
  signal CESYNC         : std_logic_vector(REFCLK_COUNT downto 1);
  signal CLRSYNC        : std_logic_vector(REFCLK_COUNT downto 1);

--  signal hb_gtwiz_reset_all_init_int : std_logic_vector(1 downto 1);
--  signal hb_gtwiz_reset_rx_datapath_init_int  : std_logic_vector(1 downto 1);
--  signal init_done_int  : std_logic_vector(1 downto 1);

  constant FF_K1_CLK_ID : integer := 1;
  constant FF_K1_LINK_START : integer := 1;
  signal FF_K1_common_in   : FF_K1_CommonIn;                        
  signal FF_K1_common_out  : FF_K1_CommonOut;
  signal FF_K1_clocks_in   : FF_K1_ClocksIn;
  signal FF_K1_clocks_OUT  : FF_K1_ClocksOut;                        
  signal FF_K1_channel_in  : FF_K1_ChannelIn_array_t(12 downto 1);  
  signal FF_K1_channel_out : FF_K1_ChannelOut_array_t(12 downto 1);

  constant FF_K2_CLK_ID : integer := 2;
  constant FF_K2_LINK_START : integer := 13;
  signal FF_K2_common_in   : FF_K2_CommonIn;                        
  signal FF_K2_common_out  : FF_K2_CommonOut;
  signal FF_K2_clocks_in   : FF_K2_ClocksIn;
  signal FF_K2_clocks_OUT  : FF_K2_ClocksOut;                        
  signal FF_K2_channel_in  : FF_K2_ChannelIn_array_t(12 downto 1);  
  signal FF_K2_channel_out : FF_K2_ChannelOut_array_t(12 downto 1);

  constant FF_K3_CLK_ID : integer := 3;
  constant FF_K3_LINK_START : integer := 25;
  signal FF_K3_common_in   : FF_K3_CommonIn;                        
  signal FF_K3_common_out  : FF_K3_CommonOut;
  signal FF_K3_clocks_in   : FF_K3_ClocksIn;
  signal FF_K3_clocks_OUT  : FF_K3_ClocksOut;                        
  signal FF_K3_channel_in  : FF_K3_ChannelIn_array_t(12 downto 1);  
  signal FF_K3_channel_out : FF_K3_ChannelOut_array_t(12 downto 1);

  constant FF_K7_CLK_ID : integer := 4;
  constant FF_K7_LINK_START : integer := 37;
  signal FF_K7_common_in   : FF_K7_CommonIn;                        
  signal FF_K7_common_out  : FF_K7_CommonOut;
  signal FF_K7_clocks_in   : FF_K7_ClocksIn;
  signal FF_K7_clocks_OUT  : FF_K7_ClocksOut;                        
  signal FF_K7_channel_in  : FF_K7_ChannelIn_array_t(12 downto 1);  
  signal FF_K7_channel_out : FF_K7_ChannelOut_array_t(12 downto 1);

begin  -- architecture QuadTest
  reset <= not reset_axi_n;

  QuadTest_map_1: entity work.Quad_Test_map
    port map (
      clk_axi         => clk_axi,
      reset_axi_n     => reset_axi_n,
      slave_readMOSI  => readMOSI,
      slave_readMISO  => readMISO,
      slave_writeMOSI => writeMOSI,
      slave_writeMISO => writeMISO,
      Mon             => Mon,
      Ctrl            => Ctrl);

  refclk_gen: for iRefClk in ref_clk'range generate
    asdf: if iRefclk /= 5 generate
      refclk_ibufds : ibufds_gte4
        generic map (
          REFCLK_EN_TX_PATH  => '0',
          REFCLK_HROW_CK_SEL => "00",
          REFCLK_ICNTL_RX    => "00")
        port map (
          O     => ref_clk(iRefClk),
          ODIV2 => ref_clk2(iRefClk),
          CEB   => '0',
          I     => refclk_i_p(iRefClk),
          IB    => refclk_i_n(iRefClk)
          );
      BUFG_GT_SYNC_inst : BUFG_GT_SYNC
        port map (
          CESYNC  => CESYNC(iRefClk),
          CLRSYNC => CLRSYNC(iRefClk),
          CE => '1',
          CLK => ref_clk2(iRefClk),
          CLR => '0'
          );
      BUFG_GT_inst : BUFG_GT
        port map (
          O => ref_clk_fabric(iRefClk),
          CE => CESYNC(iRefClk),
          CEMASK => '1',
          CLR => CLRSYNC(iRefClk),
          CLRMASK => '1',
          DIV => "000", 
          I => ref_clk2(iRefClk)
          );
    end generate asdf;

    
    rate_counter_1: entity work.rate_counter
      generic map (
        CLK_A_1_SECOND => 50000000)
      port map (
        clk_A         => clk_axi,
        clk_B         => ref_clk_fabric(iRefClk) ,
        reset_A_async => '0',
        event_b       => '1',
        rate          => ref_clk_freq(iRefClk));    
  end generate refclk_gen;

  
  -------------------------------------------------------------------------------
  -- FF_K1
  -------------------------------------------------------------------------------  
  Mon.FF_K1.COMMON.COUNTERS.REFCLK_FREQ <= ref_clk_freq(FF_K1_CLK_ID);
  FF_K1_wrapper_1: entity work.FF_K1_wrapper
    port map (
      common_in   => FF_K1_common_in,
      common_out  => FF_K1_common_out,
      clocks_in   => FF_K1_clocks_in,
      clocks_out  => FF_K1_clocks_out,
      channel_in  => FF_K1_channel_in,
      channel_out => FF_K1_channel_out);
  FF_K1_rate_counter_1: entity work.rate_counter
    generic map (
      CLK_A_1_SECOND => 50000000)
    port map (
      clk_A         => clk_axi,
      clk_B         => FF_K1_common_out.gtwiz_userclk_rx_usrclk_out,
      reset_A_async => '0',
      event_b       => '1',
      rate          => Mon.FF_K1.COMMON.COUNTERS.RX_USER_FREQ);
  FF_K1_rate_counter_3: entity work.rate_counter
    generic map (
      CLK_A_1_SECOND => 50000000)
    port map (
      clk_A         => clk_axi,
      clk_B         => FF_K1_common_out.gtwiz_userclk_tx_usrclk_out,
      reset_A_async => '0',
      event_b       => '1',
      rate          => Mon.FF_K1.COMMON.COUNTERS.TX_USER_FREQ);


  FF_K1_common_in.gtwiz_reset_rx_done_in <= Ctrl.FF_K1.COMMON.RESETS.RX_DONE;
  FF_K1_common_in.gtwiz_reset_tx_done_in <= Ctrl.FF_K1.COMMON.RESETS.TX_DONE;

  Mon.FF_K1.COMMON.STATUS.RX_ACTIVE                  <= FF_K1_common_out.gtwiz_userclk_rx_active_out;
  Mon.FF_K1.COMMON.STATUS.TX_ACTIVE                  <= FF_K1_common_out.gtwiz_userclk_tx_active_out;


  FF_K1_common_in.gtwiz_userclk_tx_reset_in          <= Ctrl.FF_K1.COMMON.RESETS.TX_USERCLK;
  FF_K1_common_in.gtwiz_userclk_rx_reset_in          <= Ctrl.FF_K1.COMMON.RESETS.RX_USERCLK;
  

  FF_K1_refclocks: for iRefClk in FF_K1_clocks_in.gtrefclk0_in'range generate
    --refclk
    FF_K1_clocks_in.gtrefclk0_in(iRefClk)      <= ref_clk(FF_K1_CLK_ID);    
  end generate FF_K1_refclocks;




  FF_K1: for iChan in FF_K1_channel_in'RANGE  generate    
    
    --DRP interface
    Mon.FF_K1.CHANNEL(iChan).DRP.rd_data         <= FF_K1_channel_out(iChan).drpdo_out;     
    Mon.FF_K1.CHANNEL(iChan).DRP.rd_data_valid   <= FF_K1_channel_out(iChan).drprdy_out;
    FF_K1_channel_in(iChan).drpaddr_in           <= Ctrl.FF_K1.CHANNEL(iChan).DRP.address;
    FF_K1_channel_in(iChan).drpclk_in            <= Ctrl.FF_K1.CHANNEL(iChan).DRP.clk;
    FF_K1_channel_in(iChan).drpdi_in             <= Ctrl.FF_K1.CHANNEL(iChan).DRP.wr_data;
    FF_K1_channel_in(iChan).drpen_in             <= Ctrl.FF_K1.CHANNEL(iChan).DRP.enable or Ctrl.FF_K1.CHANNEL(iChan).DRP.wr_enable;                     
    FF_K1_channel_in(iChan).drprst_in            <= reset;
    FF_K1_channel_in(iChan).drpwe_in             <= Ctrl.FF_K1.CHANNEL(iChan).DRP.wr_enable;
    

    --User
    Mon.FF_K1.CHANNEL(iChan).INFO.TXRX_TYPE          <= FF_K1_channel_out(iChan).TXRX_TYPE;

    
    --Other
    Mon.FF_K1.CHANNEL(iChan).INFO.cpllfbclklost_out     <= FF_K1_channel_out(iChan).cpllfbclklost_out    ;
    Mon.FF_K1.CHANNEL(iChan).INFO.cplllock_out          <= FF_K1_channel_out(iChan).cplllock_out         ;
    Mon.FF_K1.CHANNEL(iChan).INFO.dmonitorout_out       <= FF_K1_channel_out(iChan).dmonitorout_out      ;
    Mon.FF_K1.CHANNEL(iChan).INFO.eyescandataerror_out  <= FF_K1_channel_out(iChan).eyescandataerror_out ;
    Mon.FF_K1.CHANNEL(iChan).INFO.gtpowergood_out       <= FF_K1_channel_out(iChan).gtpowergood_out      ;
    Mon.FF_K1.CHANNEL(iChan).INFO.rxbufstatus_out       <= FF_K1_channel_out(iChan).rxbufstatus_out      ;
    Mon.FF_K1.CHANNEL(iChan).INFO.rxbyteisaligned_out   <= FF_K1_channel_out(iChan).rxbyteisaligned_out      ;
    Mon.FF_K1.CHANNEL(iChan).INFO.rxbyterealign_out     <= FF_K1_channel_out(iChan).rxbyterealign_out      ;
    Mon.FF_K1.CHANNEL(iChan).INFO.rxcdrlock_out         <= FF_K1_channel_out(iChan).rxcdrlock_out        ;
    Mon.FF_K1.CHANNEL(iChan).INFO.rxcommadet_out        <= FF_K1_channel_out(iChan).rxcommadet_out        ;
    Mon.FF_K1.CHANNEL(iChan).INFO.rxctrl0_out           <= FF_K1_channel_out(iChan).rxctrl0_out          ;
    Mon.FF_K1.CHANNEL(iChan).INFO.rxctrl1_out           <= FF_K1_channel_out(iChan).rxctrl1_out          ;
    Mon.FF_K1.CHANNEL(iChan).INFO.rxctrl2_out           <= FF_K1_channel_out(iChan).rxctrl2_out          ;      
    Mon.FF_K1.CHANNEL(iChan).INFO.rxctrl3_out           <= FF_K1_channel_out(iChan).rxctrl3_out          ;
    Mon.FF_K1.CHANNEL(iChan).INFO.rxpmaresetdone_out    <= FF_K1_channel_out(iChan).rxpmaresetdone_out   ;
    Mon.FF_K1.CHANNEL(iChan).INFO.rxprbserr_out         <= FF_K1_channel_out(iChan).rxprbserr_out        ;
    Mon.FF_K1.CHANNEL(iChan).INFO.rxresetdone_out       <= FF_K1_channel_out(iChan).rxresetdone_out      ;
    Mon.FF_K1.CHANNEL(iChan).INFO.txbufstatus_out       <= FF_K1_channel_out(iChan).txbufstatus_out      ;
    Mon.FF_K1.CHANNEL(iChan).INFO.txpmaresetdone_out    <= FF_K1_channel_out(iChan).txpmaresetdone_out   ;
    Mon.FF_K1.CHANNEL(iChan).INFO.txresetdone_out       <= FF_K1_channel_out(iChan).txresetdone_out      ;


    FF_K1_channel_in(iChan).cpllpd_in         <= Ctrl.FF_K1.CHANNEL(iChan).INFO.cpllpd_in        ;
    FF_K1_channel_in(iChan).cpllreset_in      <= Ctrl.FF_K1.CHANNEL(iChan).INFO.cpllreset_in     ;
    FF_K1_channel_in(iChan).eyescanreset_in   <= Ctrl.FF_K1.CHANNEL(iChan).INFO.eyescanreset_in  ;
    FF_K1_channel_in(iChan).eyescantrigger_in <= Ctrl.FF_K1.CHANNEL(iChan).INFO.eyescantrigger_in;
    FF_K1_channel_in(iChan).gtrxreset_in      <= Ctrl.FF_K1.CHANNEL(iChan).INFO.gtrxreset_in     ;
    FF_K1_channel_in(iChan).gttxreset_in      <= Ctrl.FF_K1.CHANNEL(iChan).INFO.gttxreset_in     ;
    FF_K1_channel_in(iChan).loopback_in       <= Ctrl.FF_K1.CHANNEL(iChan).INFO.loopback_in      ;
    FF_K1_channel_in(iChan).pcsrsvdin_in      <= Ctrl.FF_K1.CHANNEL(iChan).INFO.pcsrsvdin_in     ;
    FF_K1_channel_in(iChan).rx8b10ben_in      <= Ctrl.FF_K1.CHANNEL(iChan).INFO.rx8b10ben_in     ;
    FF_K1_channel_in(iChan).rxbufreset_in     <= Ctrl.FF_K1.CHANNEL(iChan).INFO.rxbufreset_in    ;
    FF_K1_channel_in(iChan).rxcdrhold_in      <= Ctrl.FF_K1.CHANNEL(iChan).INFO.rxcdrhold_in     ;
    FF_K1_channel_in(iChan).rxcommadeten_in   <= Ctrl.FF_K1.CHANNEL(iChan).INFO.rxcommadeten_in  ;
    FF_K1_channel_in(iChan).rxdfelpmreset_in  <= Ctrl.FF_K1.CHANNEL(iChan).INFO.rxdfelpmreset_in ;
    FF_K1_channel_in(iChan).rxlpmen_in        <= Ctrl.FF_K1.CHANNEL(iChan).INFO.rxlpmen_in       ;
    FF_K1_channel_in(iChan).rxmcommaalignen_in <= Ctrl.FF_K1.CHANNEL(iChan).INFO.rxmcommaalignen_in  ;
    FF_K1_channel_in(iChan).rxpcommaalignen_in <= Ctrl.FF_K1.CHANNEL(iChan).INFO.rxpcommaalignen_in  ;
    FF_K1_channel_in(iChan).rxpcsreset_in     <= Ctrl.FF_K1.CHANNEL(iChan).INFO.rxpcsreset_in    ;
    FF_K1_channel_in(iChan).rxpmareset_in     <= Ctrl.FF_K1.CHANNEL(iChan).INFO.rxpmareset_in    ;
    FF_K1_channel_in(iChan).rxprbscntreset_in <= Ctrl.FF_K1.CHANNEL(iChan).INFO.rxprbscntreset_in;
    FF_K1_channel_in(iChan).rxprbssel_in      <= Ctrl.FF_K1.CHANNEL(iChan).INFO.rxprbssel_in     ;
    FF_K1_channel_in(iChan).rxprogdivreset_in <= Ctrl.FF_K1.CHANNEL(iChan).INFO.rxprogdivreset_in;
    FF_K1_channel_in(iChan).rxrate_in         <= Ctrl.FF_K1.CHANNEL(iChan).INFO.rxrate_in        ;
    FF_K1_channel_in(iChan).rxuserrdy_in      <= Ctrl.FF_K1.CHANNEL(iChan).INFO.rxuserrdy_in     ;
    FF_K1_channel_in(iChan).tx8b10ben_in      <= Ctrl.FF_K1.CHANNEL(iChan).INFO.tx8b10ben_in     ;
    FF_K1_channel_in(iChan).txctrl0_in        <= Ctrl.FF_K1.CHANNEL(iChan).INFO.txctrl0_in       ;
    FF_K1_channel_in(iChan).txctrl1_in        <= Ctrl.FF_K1.CHANNEL(iChan).INFO.txctrl1_in       ;
--    FF_K1_channel_in(iChan).txctrl2_in        <= Ctrl.FF_K1.CHANNEL(iChan).INFO.txctrl2_in       ;
    FF_K1_channel_in(iChan).txdiffctrl_in     <= Ctrl.FF_K1.CHANNEL(iChan).INFO.txdiffctrl_in    ;
    FF_K1_channel_in(iChan).txinhibit_in      <= Ctrl.FF_K1.CHANNEL(iChan).INFO.txinhibit_in     ;
    FF_K1_channel_in(iChan).txpcsreset_in     <= Ctrl.FF_K1.CHANNEL(iChan).INFO.txpcsreset_in    ;
    FF_K1_channel_in(iChan).txpmareset_in     <= Ctrl.FF_K1.CHANNEL(iChan).INFO.txpmareset_in    ;
    FF_K1_channel_in(iChan).txpolarity_in     <= Ctrl.FF_K1.CHANNEL(iChan).INFO.txpolarity_in    ;
    FF_K1_channel_in(iChan).txpostcursor_in   <= Ctrl.FF_K1.CHANNEL(iChan).INFO.txpostcursor_in  ;
    FF_K1_channel_in(iChan).txprbsforceerr_in <= Ctrl.FF_K1.CHANNEL(iChan).INFO.txprbsforceerr_in;
    FF_K1_channel_in(iChan).txprbssel_in      <= Ctrl.FF_K1.CHANNEL(iChan).INFO.txprbssel_in     ;
    FF_K1_channel_in(iChan).txprecursor_in    <= Ctrl.FF_K1.CHANNEL(iChan).INFO.txprecursor_in   ;
    FF_K1_channel_in(iChan).txprogdivreset_in <= Ctrl.FF_K1.CHANNEL(iChan).INFO.txprogdivreset_in;
    FF_K1_channel_in(iChan).txuserrdy_in      <= Ctrl.FF_K1.CHANNEL(iChan).INFO.txuserrdy_in     ;


    Mon.FF_K1.CHANNEL(iChan).INFO.RX_DATA.DATA <= FF_K1_channel_out(iChan).gtwiz_userdata_rx_out(31 downto  0);
    Mon.FF_K1.CHANNEL(iChan).INFO.RX_DATA.K    <= FF_K1_channel_out(iChan).rxctrl2_out(3 downto 0);
    Mon.FF_K1.CHANNEL(iChan).INFO.TX_DATA.DATA <= FF_K1_channel_in(iChan).gtwiz_userdata_tx_in(31 downto  0);
    Mon.FF_K1.CHANNEL(iChan).INFO.TX_DATA.K    <= FF_K1_channel_in(iChan).txctrl2_in(3 downto 0);  



    FF_K1_channel_in(iChan).gthrxn_in <= rx_n(FF_K1_LINK_START-1 + iChan);
    FF_K1_channel_in(iChan).gthrxp_in <= rx_p(FF_K1_LINK_START-1 + iChan);
    tx_n(FF_K1_LINK_START-1 + iChan) <= FF_K1_channel_out(iChan).gthtxn_out;
    tx_p(FF_K1_LINK_START-1 + iChan) <= FF_K1_channel_out(iChan).gthtxp_out;
    
    ChannelTest_1: entity work.ChannelTest
      port map (
        clk         => FF_K1_Common_Out.gtwiz_userclk_rx_usrclk_out,
        clk_axi     => clk_axi,
        reset       => reset,
        tx_fixed(31 downto  0) => Ctrl.FF_K1.CHANNEL(iChan).INFO.TX_FIXED,
        tx_fixed(35 downto 32) => Ctrl.FF_K1.CHANNEL(iChan).INFO.TX_FIXED_HEADER,
        tx_fixed_en            => Ctrl.FF_K1.CHANNEL(iChan).INFO.TX_FIXED_EN,
        rx_data     => FF_K1_channel_out(iChan).gtwiz_userdata_rx_out,
        rx_k_data   => FF_K1_channel_out(iChan).rxctrl2_out(3 downto 0),
        tx_data     => FF_K1_channel_in(iChan).gtwiz_userdata_tx_in,
        tx_k_data   => FF_K1_channel_in(iChan).txctrl2_in(3 downto 0),  
        error_rate  => Mon.FF_K1.CHANNEL(iChan).INFO.ERROR_RATE,
        error_count => Mon.FF_K1.CHANNEL(iChan).INFO.ERROR_COUNT);
  end generate FF_K1;

  -------------------------------------------------------------------------------
  -- FF_K2
  -------------------------------------------------------------------------------  
  Mon.FF_K2.COMMON.COUNTERS.REFCLK_FREQ <= ref_clk_freq(FF_K2_CLK_ID);
  FF_K2_wrapper_1: entity work.FF_K2_wrapper
    port map (
      common_in   => FF_K2_common_in,
      common_out  => FF_K2_common_out,
      clocks_in   => FF_K2_clocks_in,
      clocks_out  => FF_K2_clocks_out,
      channel_in  => FF_K2_channel_in,
      channel_out => FF_K2_channel_out);
  FF_K2_rate_counter_1: entity work.rate_counter
    generic map (
      CLK_A_1_SECOND => 50000000)
    port map (
      clk_A         => clk_axi,
      clk_B         => FF_K2_common_out.gtwiz_userclk_rx_usrclk_out,
      reset_A_async => '0',
      event_b       => '1',
      rate          => Mon.FF_K2.COMMON.COUNTERS.RX_USER_FREQ);
  FF_K2_rate_counter_3: entity work.rate_counter
    generic map (
      CLK_A_1_SECOND => 50000000)
    port map (
      clk_A         => clk_axi,
      clk_B         => FF_K2_common_out.gtwiz_userclk_tx_usrclk_out,
      reset_A_async => '0',
      event_b       => '1',
      rate          => Mon.FF_K2.COMMON.COUNTERS.TX_USER_FREQ);


  FF_K2_common_in.gtwiz_reset_rx_done_in <= Ctrl.FF_K2.COMMON.RESETS.RX_DONE;
  FF_K2_common_in.gtwiz_reset_tx_done_in <= Ctrl.FF_K2.COMMON.RESETS.TX_DONE;

  Mon.FF_K2.COMMON.STATUS.RX_ACTIVE                  <= FF_K2_common_out.gtwiz_userclk_rx_active_out;
  Mon.FF_K2.COMMON.STATUS.TX_ACTIVE                  <= FF_K2_common_out.gtwiz_userclk_tx_active_out;


  FF_K2_common_in.gtwiz_userclk_tx_reset_in          <= Ctrl.FF_K2.COMMON.RESETS.TX_USERCLK;
  FF_K2_common_in.gtwiz_userclk_rx_reset_in          <= Ctrl.FF_K2.COMMON.RESETS.RX_USERCLK;
  

  FF_K2_refclocks: for iRefClk in FF_K2_clocks_in.gtrefclk0_in'range generate
    --refclk
    FF_K2_clocks_in.gtrefclk0_in(iRefClk)      <= ref_clk(FF_K2_CLK_ID);    
  end generate FF_K2_refclocks;




  FF_K2: for iChan in FF_K2_channel_in'RANGE  generate    
    
    --DRP interface
    Mon.FF_K2.CHANNEL(iChan).DRP.rd_data         <= FF_K2_channel_out(iChan).drpdo_out;     
    Mon.FF_K2.CHANNEL(iChan).DRP.rd_data_valid   <= FF_K2_channel_out(iChan).drprdy_out;
    FF_K2_channel_in(iChan).drpaddr_in           <= Ctrl.FF_K2.CHANNEL(iChan).DRP.address;
    FF_K2_channel_in(iChan).drpclk_in            <= Ctrl.FF_K2.CHANNEL(iChan).DRP.clk;
    FF_K2_channel_in(iChan).drpdi_in             <= Ctrl.FF_K2.CHANNEL(iChan).DRP.wr_data;
    FF_K2_channel_in(iChan).drpen_in             <= Ctrl.FF_K2.CHANNEL(iChan).DRP.enable or Ctrl.FF_K2.CHANNEL(iChan).DRP.wr_enable;                     
    FF_K2_channel_in(iChan).drprst_in            <= reset;
    FF_K2_channel_in(iChan).drpwe_in             <= Ctrl.FF_K2.CHANNEL(iChan).DRP.wr_enable;
    

    --User
    Mon.FF_K2.CHANNEL(iChan).INFO.TXRX_TYPE          <= FF_K2_channel_out(iChan).TXRX_TYPE;

    
    --Other
    Mon.FF_K2.CHANNEL(iChan).INFO.cpllfbclklost_out     <= FF_K2_channel_out(iChan).cpllfbclklost_out    ;
    Mon.FF_K2.CHANNEL(iChan).INFO.cplllock_out          <= FF_K2_channel_out(iChan).cplllock_out         ;
    Mon.FF_K2.CHANNEL(iChan).INFO.dmonitorout_out       <= FF_K2_channel_out(iChan).dmonitorout_out      ;
    Mon.FF_K2.CHANNEL(iChan).INFO.eyescandataerror_out  <= FF_K2_channel_out(iChan).eyescandataerror_out ;
    Mon.FF_K2.CHANNEL(iChan).INFO.gtpowergood_out       <= FF_K2_channel_out(iChan).gtpowergood_out      ;
    Mon.FF_K2.CHANNEL(iChan).INFO.rxbufstatus_out       <= FF_K2_channel_out(iChan).rxbufstatus_out      ;
    Mon.FF_K2.CHANNEL(iChan).INFO.rxbyteisaligned_out   <= FF_K2_channel_out(iChan).rxbyteisaligned_out      ;
    Mon.FF_K2.CHANNEL(iChan).INFO.rxbyterealign_out     <= FF_K2_channel_out(iChan).rxbyterealign_out      ;
    Mon.FF_K2.CHANNEL(iChan).INFO.rxcdrlock_out         <= FF_K2_channel_out(iChan).rxcdrlock_out        ;
    Mon.FF_K2.CHANNEL(iChan).INFO.rxcommadet_out        <= FF_K2_channel_out(iChan).rxcommadet_out        ;
    Mon.FF_K2.CHANNEL(iChan).INFO.rxctrl0_out           <= FF_K2_channel_out(iChan).rxctrl0_out          ;
    Mon.FF_K2.CHANNEL(iChan).INFO.rxctrl1_out           <= FF_K2_channel_out(iChan).rxctrl1_out          ;
    Mon.FF_K2.CHANNEL(iChan).INFO.rxctrl2_out           <= FF_K2_channel_out(iChan).rxctrl2_out          ;      
    Mon.FF_K2.CHANNEL(iChan).INFO.rxctrl3_out           <= FF_K2_channel_out(iChan).rxctrl3_out          ;
    Mon.FF_K2.CHANNEL(iChan).INFO.rxpmaresetdone_out    <= FF_K2_channel_out(iChan).rxpmaresetdone_out   ;
    Mon.FF_K2.CHANNEL(iChan).INFO.rxprbserr_out         <= FF_K2_channel_out(iChan).rxprbserr_out        ;
    Mon.FF_K2.CHANNEL(iChan).INFO.rxresetdone_out       <= FF_K2_channel_out(iChan).rxresetdone_out      ;
    Mon.FF_K2.CHANNEL(iChan).INFO.txbufstatus_out       <= FF_K2_channel_out(iChan).txbufstatus_out      ;
    Mon.FF_K2.CHANNEL(iChan).INFO.txpmaresetdone_out    <= FF_K2_channel_out(iChan).txpmaresetdone_out   ;
    Mon.FF_K2.CHANNEL(iChan).INFO.txresetdone_out       <= FF_K2_channel_out(iChan).txresetdone_out      ;


    FF_K2_channel_in(iChan).cpllpd_in         <= Ctrl.FF_K2.CHANNEL(iChan).INFO.cpllpd_in        ;
    FF_K2_channel_in(iChan).cpllreset_in      <= Ctrl.FF_K2.CHANNEL(iChan).INFO.cpllreset_in     ;
    FF_K2_channel_in(iChan).eyescanreset_in   <= Ctrl.FF_K2.CHANNEL(iChan).INFO.eyescanreset_in  ;
    FF_K2_channel_in(iChan).eyescantrigger_in <= Ctrl.FF_K2.CHANNEL(iChan).INFO.eyescantrigger_in;
    FF_K2_channel_in(iChan).gtrxreset_in      <= Ctrl.FF_K2.CHANNEL(iChan).INFO.gtrxreset_in     ;
    FF_K2_channel_in(iChan).gttxreset_in      <= Ctrl.FF_K2.CHANNEL(iChan).INFO.gttxreset_in     ;
    FF_K2_channel_in(iChan).loopback_in       <= Ctrl.FF_K2.CHANNEL(iChan).INFO.loopback_in      ;
    FF_K2_channel_in(iChan).pcsrsvdin_in      <= Ctrl.FF_K2.CHANNEL(iChan).INFO.pcsrsvdin_in     ;
    FF_K2_channel_in(iChan).rx8b10ben_in      <= Ctrl.FF_K2.CHANNEL(iChan).INFO.rx8b10ben_in     ;
    FF_K2_channel_in(iChan).rxbufreset_in     <= Ctrl.FF_K2.CHANNEL(iChan).INFO.rxbufreset_in    ;
    FF_K2_channel_in(iChan).rxcdrhold_in      <= Ctrl.FF_K2.CHANNEL(iChan).INFO.rxcdrhold_in     ;
    FF_K2_channel_in(iChan).rxcommadeten_in   <= Ctrl.FF_K2.CHANNEL(iChan).INFO.rxcommadeten_in  ;
    FF_K2_channel_in(iChan).rxdfelpmreset_in  <= Ctrl.FF_K2.CHANNEL(iChan).INFO.rxdfelpmreset_in ;
    FF_K2_channel_in(iChan).rxlpmen_in        <= Ctrl.FF_K2.CHANNEL(iChan).INFO.rxlpmen_in       ;
    FF_K2_channel_in(iChan).rxmcommaalignen_in <= Ctrl.FF_K2.CHANNEL(iChan).INFO.rxmcommaalignen_in  ;
    FF_K2_channel_in(iChan).rxpcommaalignen_in <= Ctrl.FF_K2.CHANNEL(iChan).INFO.rxpcommaalignen_in  ;
    FF_K2_channel_in(iChan).rxpcsreset_in     <= Ctrl.FF_K2.CHANNEL(iChan).INFO.rxpcsreset_in    ;
    FF_K2_channel_in(iChan).rxpmareset_in     <= Ctrl.FF_K2.CHANNEL(iChan).INFO.rxpmareset_in    ;
    FF_K2_channel_in(iChan).rxprbscntreset_in <= Ctrl.FF_K2.CHANNEL(iChan).INFO.rxprbscntreset_in;
    FF_K2_channel_in(iChan).rxprbssel_in      <= Ctrl.FF_K2.CHANNEL(iChan).INFO.rxprbssel_in     ;
    FF_K2_channel_in(iChan).rxprogdivreset_in <= Ctrl.FF_K2.CHANNEL(iChan).INFO.rxprogdivreset_in;
    FF_K2_channel_in(iChan).rxrate_in         <= Ctrl.FF_K2.CHANNEL(iChan).INFO.rxrate_in        ;
    FF_K2_channel_in(iChan).rxuserrdy_in      <= Ctrl.FF_K2.CHANNEL(iChan).INFO.rxuserrdy_in     ;
    FF_K2_channel_in(iChan).tx8b10ben_in      <= Ctrl.FF_K2.CHANNEL(iChan).INFO.tx8b10ben_in     ;
    FF_K2_channel_in(iChan).txctrl0_in        <= Ctrl.FF_K2.CHANNEL(iChan).INFO.txctrl0_in       ;
    FF_K2_channel_in(iChan).txctrl1_in        <= Ctrl.FF_K2.CHANNEL(iChan).INFO.txctrl1_in       ;
--    FF_K2_channel_in(iChan).txctrl2_in        <= Ctrl.FF_K2.CHANNEL(iChan).INFO.txctrl2_in       ;
    FF_K2_channel_in(iChan).txdiffctrl_in     <= Ctrl.FF_K2.CHANNEL(iChan).INFO.txdiffctrl_in    ;
    FF_K2_channel_in(iChan).txinhibit_in      <= Ctrl.FF_K2.CHANNEL(iChan).INFO.txinhibit_in     ;
    FF_K2_channel_in(iChan).txpcsreset_in     <= Ctrl.FF_K2.CHANNEL(iChan).INFO.txpcsreset_in    ;
    FF_K2_channel_in(iChan).txpmareset_in     <= Ctrl.FF_K2.CHANNEL(iChan).INFO.txpmareset_in    ;
    FF_K2_channel_in(iChan).txpolarity_in     <= Ctrl.FF_K2.CHANNEL(iChan).INFO.txpolarity_in    ;
    FF_K2_channel_in(iChan).txpostcursor_in   <= Ctrl.FF_K2.CHANNEL(iChan).INFO.txpostcursor_in  ;
    FF_K2_channel_in(iChan).txprbsforceerr_in <= Ctrl.FF_K2.CHANNEL(iChan).INFO.txprbsforceerr_in;
    FF_K2_channel_in(iChan).txprbssel_in      <= Ctrl.FF_K2.CHANNEL(iChan).INFO.txprbssel_in     ;
    FF_K2_channel_in(iChan).txprecursor_in    <= Ctrl.FF_K2.CHANNEL(iChan).INFO.txprecursor_in   ;
    FF_K2_channel_in(iChan).txprogdivreset_in <= Ctrl.FF_K2.CHANNEL(iChan).INFO.txprogdivreset_in;
    FF_K2_channel_in(iChan).txuserrdy_in      <= Ctrl.FF_K2.CHANNEL(iChan).INFO.txuserrdy_in     ;


    Mon.FF_K2.CHANNEL(iChan).INFO.RX_DATA.DATA <= FF_K2_channel_out(iChan).gtwiz_userdata_rx_out(31 downto  0);
    Mon.FF_K2.CHANNEL(iChan).INFO.RX_DATA.K    <= FF_K2_channel_out(iChan).rxctrl2_out(3 downto 0);
    Mon.FF_K2.CHANNEL(iChan).INFO.TX_DATA.DATA <= FF_K2_channel_in(iChan).gtwiz_userdata_tx_in(31 downto  0);
    Mon.FF_K2.CHANNEL(iChan).INFO.TX_DATA.K    <= FF_K2_channel_in(iChan).txctrl2_in(3 downto 0);  



    FF_K2_channel_in(iChan).gthrxn_in <= rx_n(FF_K2_LINK_START-1 + iChan);
    FF_K2_channel_in(iChan).gthrxp_in <= rx_p(FF_K2_LINK_START-1 + iChan);
    tx_n(FF_K2_LINK_START-1 + iChan) <= FF_K2_channel_out(iChan).gthtxn_out;
    tx_p(FF_K2_LINK_START-1 + iChan) <= FF_K2_channel_out(iChan).gthtxp_out;
    
    ChannelTest_1: entity work.ChannelTest
      port map (
        clk         => FF_K2_Common_Out.gtwiz_userclk_rx_usrclk_out,
        clk_axi     => clk_axi,
        reset       => reset,
        tx_fixed(31 downto  0) => Ctrl.FF_K2.CHANNEL(iChan).INFO.TX_FIXED,
        tx_fixed(35 downto 32) => Ctrl.FF_K2.CHANNEL(iChan).INFO.TX_FIXED_HEADER,
        tx_fixed_en            => Ctrl.FF_K2.CHANNEL(iChan).INFO.TX_FIXED_EN,
        rx_data     => FF_K2_channel_out(iChan).gtwiz_userdata_rx_out,
        rx_k_data   => FF_K2_channel_out(iChan).rxctrl2_out(3 downto 0),
        tx_data     => FF_K2_channel_in(iChan).gtwiz_userdata_tx_in,
        tx_k_data   => FF_K2_channel_in(iChan).txctrl2_in(3 downto 0),  
        error_rate  => Mon.FF_K2.CHANNEL(iChan).INFO.ERROR_RATE,
        error_count => Mon.FF_K2.CHANNEL(iChan).INFO.ERROR_COUNT);
  end generate FF_K2;
  -------------------------------------------------------------------------------
  -- FF_K3
  -------------------------------------------------------------------------------  
  Mon.FF_K3.COMMON.COUNTERS.REFCLK_FREQ <= ref_clk_freq(FF_K3_CLK_ID);
  FF_K3_wrapper_1: entity work.FF_K3_wrapper
    port map (
      common_in   => FF_K3_common_in,
      common_out  => FF_K3_common_out,
      clocks_in   => FF_K3_clocks_in,
      clocks_out  => FF_K3_clocks_out,
      channel_in  => FF_K3_channel_in,
      channel_out => FF_K3_channel_out);
  FF_K3_rate_counter_1: entity work.rate_counter
    generic map (
      CLK_A_1_SECOND => 50000000)
    port map (
      clk_A         => clk_axi,
      clk_B         => FF_K3_common_out.gtwiz_userclk_rx_usrclk_out,
      reset_A_async => '0',
      event_b       => '1',
      rate          => Mon.FF_K3.COMMON.COUNTERS.RX_USER_FREQ);
  FF_K3_rate_counter_3: entity work.rate_counter
    generic map (
      CLK_A_1_SECOND => 50000000)
    port map (
      clk_A         => clk_axi,
      clk_B         => FF_K3_common_out.gtwiz_userclk_tx_usrclk_out,
      reset_A_async => '0',
      event_b       => '1',
      rate          => Mon.FF_K3.COMMON.COUNTERS.TX_USER_FREQ);


  FF_K3_common_in.gtwiz_reset_rx_done_in <= Ctrl.FF_K3.COMMON.RESETS.RX_DONE;
  FF_K3_common_in.gtwiz_reset_tx_done_in <= Ctrl.FF_K3.COMMON.RESETS.TX_DONE;

  Mon.FF_K3.COMMON.STATUS.RX_ACTIVE                  <= FF_K3_common_out.gtwiz_userclk_rx_active_out;
  Mon.FF_K3.COMMON.STATUS.TX_ACTIVE                  <= FF_K3_common_out.gtwiz_userclk_tx_active_out;


  FF_K3_common_in.gtwiz_userclk_tx_reset_in          <= Ctrl.FF_K3.COMMON.RESETS.TX_USERCLK;
  FF_K3_common_in.gtwiz_userclk_rx_reset_in          <= Ctrl.FF_K3.COMMON.RESETS.RX_USERCLK;
  

  FF_K3_refclocks: for iRefClk in FF_K3_clocks_in.gtrefclk0_in'range generate
    --refclk
    FF_K3_clocks_in.gtrefclk0_in(iRefClk)      <= ref_clk(FF_K3_CLK_ID);    
  end generate FF_K3_refclocks;




  FF_K3: for iChan in FF_K3_channel_in'RANGE  generate    
    
    --DRP interface
    Mon.FF_K3.CHANNEL(iChan).DRP.rd_data         <= FF_K3_channel_out(iChan).drpdo_out;     
    Mon.FF_K3.CHANNEL(iChan).DRP.rd_data_valid   <= FF_K3_channel_out(iChan).drprdy_out;
    FF_K3_channel_in(iChan).drpaddr_in           <= Ctrl.FF_K3.CHANNEL(iChan).DRP.address;
    FF_K3_channel_in(iChan).drpclk_in            <= Ctrl.FF_K3.CHANNEL(iChan).DRP.clk;
    FF_K3_channel_in(iChan).drpdi_in             <= Ctrl.FF_K3.CHANNEL(iChan).DRP.wr_data;
    FF_K3_channel_in(iChan).drpen_in             <= Ctrl.FF_K3.CHANNEL(iChan).DRP.enable or Ctrl.FF_K3.CHANNEL(iChan).DRP.wr_enable;                     
    FF_K3_channel_in(iChan).drprst_in            <= reset;
    FF_K3_channel_in(iChan).drpwe_in             <= Ctrl.FF_K3.CHANNEL(iChan).DRP.wr_enable;
    

    --User
    Mon.FF_K3.CHANNEL(iChan).INFO.TXRX_TYPE          <= FF_K3_channel_out(iChan).TXRX_TYPE;

    
    --Other
    Mon.FF_K3.CHANNEL(iChan).INFO.cpllfbclklost_out     <= FF_K3_channel_out(iChan).cpllfbclklost_out    ;
    Mon.FF_K3.CHANNEL(iChan).INFO.cplllock_out          <= FF_K3_channel_out(iChan).cplllock_out         ;
    Mon.FF_K3.CHANNEL(iChan).INFO.dmonitorout_out       <= FF_K3_channel_out(iChan).dmonitorout_out      ;
    Mon.FF_K3.CHANNEL(iChan).INFO.eyescandataerror_out  <= FF_K3_channel_out(iChan).eyescandataerror_out ;
    Mon.FF_K3.CHANNEL(iChan).INFO.gtpowergood_out       <= FF_K3_channel_out(iChan).gtpowergood_out      ;
    Mon.FF_K3.CHANNEL(iChan).INFO.rxbufstatus_out       <= FF_K3_channel_out(iChan).rxbufstatus_out      ;
    Mon.FF_K3.CHANNEL(iChan).INFO.rxbyteisaligned_out   <= FF_K3_channel_out(iChan).rxbyteisaligned_out      ;
    Mon.FF_K3.CHANNEL(iChan).INFO.rxbyterealign_out     <= FF_K3_channel_out(iChan).rxbyterealign_out      ;
    Mon.FF_K3.CHANNEL(iChan).INFO.rxcdrlock_out         <= FF_K3_channel_out(iChan).rxcdrlock_out        ;
    Mon.FF_K3.CHANNEL(iChan).INFO.rxcommadet_out        <= FF_K3_channel_out(iChan).rxcommadet_out        ;
    Mon.FF_K3.CHANNEL(iChan).INFO.rxctrl0_out           <= FF_K3_channel_out(iChan).rxctrl0_out          ;
    Mon.FF_K3.CHANNEL(iChan).INFO.rxctrl1_out           <= FF_K3_channel_out(iChan).rxctrl1_out          ;
    Mon.FF_K3.CHANNEL(iChan).INFO.rxctrl2_out           <= FF_K3_channel_out(iChan).rxctrl2_out          ;      
    Mon.FF_K3.CHANNEL(iChan).INFO.rxctrl3_out           <= FF_K3_channel_out(iChan).rxctrl3_out          ;
    Mon.FF_K3.CHANNEL(iChan).INFO.rxpmaresetdone_out    <= FF_K3_channel_out(iChan).rxpmaresetdone_out   ;
    Mon.FF_K3.CHANNEL(iChan).INFO.rxprbserr_out         <= FF_K3_channel_out(iChan).rxprbserr_out        ;
    Mon.FF_K3.CHANNEL(iChan).INFO.rxresetdone_out       <= FF_K3_channel_out(iChan).rxresetdone_out      ;
    Mon.FF_K3.CHANNEL(iChan).INFO.txbufstatus_out       <= FF_K3_channel_out(iChan).txbufstatus_out      ;
    Mon.FF_K3.CHANNEL(iChan).INFO.txpmaresetdone_out    <= FF_K3_channel_out(iChan).txpmaresetdone_out   ;
    Mon.FF_K3.CHANNEL(iChan).INFO.txresetdone_out       <= FF_K3_channel_out(iChan).txresetdone_out      ;


    FF_K3_channel_in(iChan).cpllpd_in         <= Ctrl.FF_K3.CHANNEL(iChan).INFO.cpllpd_in        ;
    FF_K3_channel_in(iChan).cpllreset_in      <= Ctrl.FF_K3.CHANNEL(iChan).INFO.cpllreset_in     ;
    FF_K3_channel_in(iChan).eyescanreset_in   <= Ctrl.FF_K3.CHANNEL(iChan).INFO.eyescanreset_in  ;
    FF_K3_channel_in(iChan).eyescantrigger_in <= Ctrl.FF_K3.CHANNEL(iChan).INFO.eyescantrigger_in;
    FF_K3_channel_in(iChan).gtrxreset_in      <= Ctrl.FF_K3.CHANNEL(iChan).INFO.gtrxreset_in     ;
    FF_K3_channel_in(iChan).gttxreset_in      <= Ctrl.FF_K3.CHANNEL(iChan).INFO.gttxreset_in     ;
    FF_K3_channel_in(iChan).loopback_in       <= Ctrl.FF_K3.CHANNEL(iChan).INFO.loopback_in      ;
    FF_K3_channel_in(iChan).pcsrsvdin_in      <= Ctrl.FF_K3.CHANNEL(iChan).INFO.pcsrsvdin_in     ;
    FF_K3_channel_in(iChan).rx8b10ben_in      <= Ctrl.FF_K3.CHANNEL(iChan).INFO.rx8b10ben_in     ;
    FF_K3_channel_in(iChan).rxbufreset_in     <= Ctrl.FF_K3.CHANNEL(iChan).INFO.rxbufreset_in    ;
    FF_K3_channel_in(iChan).rxcdrhold_in      <= Ctrl.FF_K3.CHANNEL(iChan).INFO.rxcdrhold_in     ;
    FF_K3_channel_in(iChan).rxcommadeten_in   <= Ctrl.FF_K3.CHANNEL(iChan).INFO.rxcommadeten_in  ;
    FF_K3_channel_in(iChan).rxdfelpmreset_in  <= Ctrl.FF_K3.CHANNEL(iChan).INFO.rxdfelpmreset_in ;
    FF_K3_channel_in(iChan).rxlpmen_in        <= Ctrl.FF_K3.CHANNEL(iChan).INFO.rxlpmen_in       ;
    FF_K3_channel_in(iChan).rxmcommaalignen_in <= Ctrl.FF_K3.CHANNEL(iChan).INFO.rxmcommaalignen_in  ;
    FF_K3_channel_in(iChan).rxpcommaalignen_in <= Ctrl.FF_K3.CHANNEL(iChan).INFO.rxpcommaalignen_in  ;
    FF_K3_channel_in(iChan).rxpcsreset_in     <= Ctrl.FF_K3.CHANNEL(iChan).INFO.rxpcsreset_in    ;
    FF_K3_channel_in(iChan).rxpmareset_in     <= Ctrl.FF_K3.CHANNEL(iChan).INFO.rxpmareset_in    ;
    FF_K3_channel_in(iChan).rxprbscntreset_in <= Ctrl.FF_K3.CHANNEL(iChan).INFO.rxprbscntreset_in;
    FF_K3_channel_in(iChan).rxprbssel_in      <= Ctrl.FF_K3.CHANNEL(iChan).INFO.rxprbssel_in     ;
    FF_K3_channel_in(iChan).rxprogdivreset_in <= Ctrl.FF_K3.CHANNEL(iChan).INFO.rxprogdivreset_in;
    FF_K3_channel_in(iChan).rxrate_in         <= Ctrl.FF_K3.CHANNEL(iChan).INFO.rxrate_in        ;
    FF_K3_channel_in(iChan).rxuserrdy_in      <= Ctrl.FF_K3.CHANNEL(iChan).INFO.rxuserrdy_in     ;
    FF_K3_channel_in(iChan).tx8b10ben_in      <= Ctrl.FF_K3.CHANNEL(iChan).INFO.tx8b10ben_in     ;
    FF_K3_channel_in(iChan).txctrl0_in        <= Ctrl.FF_K3.CHANNEL(iChan).INFO.txctrl0_in       ;
    FF_K3_channel_in(iChan).txctrl1_in        <= Ctrl.FF_K3.CHANNEL(iChan).INFO.txctrl1_in       ;
--    FF_K3_channel_in(iChan).txctrl2_in        <= Ctrl.FF_K3.CHANNEL(iChan).INFO.txctrl2_in       ;
    FF_K3_channel_in(iChan).txdiffctrl_in     <= Ctrl.FF_K3.CHANNEL(iChan).INFO.txdiffctrl_in    ;
    FF_K3_channel_in(iChan).txinhibit_in      <= Ctrl.FF_K3.CHANNEL(iChan).INFO.txinhibit_in     ;
    FF_K3_channel_in(iChan).txpcsreset_in     <= Ctrl.FF_K3.CHANNEL(iChan).INFO.txpcsreset_in    ;
    FF_K3_channel_in(iChan).txpmareset_in     <= Ctrl.FF_K3.CHANNEL(iChan).INFO.txpmareset_in    ;
    FF_K3_channel_in(iChan).txpolarity_in     <= Ctrl.FF_K3.CHANNEL(iChan).INFO.txpolarity_in    ;
    FF_K3_channel_in(iChan).txpostcursor_in   <= Ctrl.FF_K3.CHANNEL(iChan).INFO.txpostcursor_in  ;
    FF_K3_channel_in(iChan).txprbsforceerr_in <= Ctrl.FF_K3.CHANNEL(iChan).INFO.txprbsforceerr_in;
    FF_K3_channel_in(iChan).txprbssel_in      <= Ctrl.FF_K3.CHANNEL(iChan).INFO.txprbssel_in     ;
    FF_K3_channel_in(iChan).txprecursor_in    <= Ctrl.FF_K3.CHANNEL(iChan).INFO.txprecursor_in   ;
    FF_K3_channel_in(iChan).txprogdivreset_in <= Ctrl.FF_K3.CHANNEL(iChan).INFO.txprogdivreset_in;
    FF_K3_channel_in(iChan).txuserrdy_in      <= Ctrl.FF_K3.CHANNEL(iChan).INFO.txuserrdy_in     ;


    Mon.FF_K3.CHANNEL(iChan).INFO.RX_DATA.DATA <= FF_K3_channel_out(iChan).gtwiz_userdata_rx_out(31 downto  0);
    Mon.FF_K3.CHANNEL(iChan).INFO.RX_DATA.K    <= FF_K3_channel_out(iChan).rxctrl2_out(3 downto 0);
    Mon.FF_K3.CHANNEL(iChan).INFO.TX_DATA.DATA <= FF_K3_channel_in(iChan).gtwiz_userdata_tx_in(31 downto  0);
    Mon.FF_K3.CHANNEL(iChan).INFO.TX_DATA.K    <= FF_K3_channel_in(iChan).txctrl2_in(3 downto 0);  



    FF_K3_channel_in(iChan).gthrxn_in <= rx_n(FF_K3_LINK_START-1 + iChan);
    FF_K3_channel_in(iChan).gthrxp_in <= rx_p(FF_K3_LINK_START-1 + iChan);
    tx_n(FF_K3_LINK_START-1 + iChan) <= FF_K3_channel_out(iChan).gthtxn_out;
    tx_p(FF_K3_LINK_START-1 + iChan) <= FF_K3_channel_out(iChan).gthtxp_out;
    
    ChannelTest_1: entity work.ChannelTest
      port map (
        clk         => FF_K3_Common_Out.gtwiz_userclk_rx_usrclk_out,
        clk_axi     => clk_axi,
        reset       => reset,
        tx_fixed(31 downto  0) => Ctrl.FF_K3.CHANNEL(iChan).INFO.TX_FIXED,
        tx_fixed(35 downto 32) => Ctrl.FF_K3.CHANNEL(iChan).INFO.TX_FIXED_HEADER,
        tx_fixed_en            => Ctrl.FF_K3.CHANNEL(iChan).INFO.TX_FIXED_EN,
        rx_data     => FF_K3_channel_out(iChan).gtwiz_userdata_rx_out,
        rx_k_data   => FF_K3_channel_out(iChan).rxctrl2_out(3 downto 0),
        tx_data     => FF_K3_channel_in(iChan).gtwiz_userdata_tx_in,
        tx_k_data   => FF_K3_channel_in(iChan).txctrl2_in(3 downto 0),  
        error_rate  => Mon.FF_K3.CHANNEL(iChan).INFO.ERROR_RATE,
        error_count => Mon.FF_K3.CHANNEL(iChan).INFO.ERROR_COUNT);
  end generate FF_K3;
  -------------------------------------------------------------------------------
  -- FF_K7
  -------------------------------------------------------------------------------  
  Mon.FF_K7.COMMON.COUNTERS.REFCLK_FREQ <= ref_clk_freq(FF_K7_CLK_ID);
  FF_K7_wrapper_1: entity work.FF_K7_wrapper
    port map (
      common_in   => FF_K7_common_in,
      common_out  => FF_K7_common_out,
      clocks_in   => FF_K7_clocks_in,
      clocks_out  => FF_K7_clocks_out,
      channel_in  => FF_K7_channel_in,
      channel_out => FF_K7_channel_out);
  FF_K7_rate_counter_1: entity work.rate_counter
    generic map (
      CLK_A_1_SECOND => 50000000)
    port map (
      clk_A         => clk_axi,
      clk_B         => FF_K7_common_out.gtwiz_userclk_rx_usrclk_out,
      reset_A_async => '0',
      event_b       => '1',
      rate          => Mon.FF_K7.COMMON.COUNTERS.RX_USER_FREQ);
  FF_K7_rate_counter_3: entity work.rate_counter
    generic map (
      CLK_A_1_SECOND => 50000000)
    port map (
      clk_A         => clk_axi,
      clk_B         => FF_K7_common_out.gtwiz_userclk_tx_usrclk_out,
      reset_A_async => '0',
      event_b       => '1',
      rate          => Mon.FF_K7.COMMON.COUNTERS.TX_USER_FREQ);


  FF_K7_common_in.gtwiz_reset_rx_done_in <= Ctrl.FF_K7.COMMON.RESETS.RX_DONE;
  FF_K7_common_in.gtwiz_reset_tx_done_in <= Ctrl.FF_K7.COMMON.RESETS.TX_DONE;

  Mon.FF_K7.COMMON.STATUS.RX_ACTIVE                  <= FF_K7_common_out.gtwiz_userclk_rx_active_out;
  Mon.FF_K7.COMMON.STATUS.TX_ACTIVE                  <= FF_K7_common_out.gtwiz_userclk_tx_active_out;


  FF_K7_common_in.gtwiz_userclk_tx_reset_in          <= Ctrl.FF_K7.COMMON.RESETS.TX_USERCLK;
  FF_K7_common_in.gtwiz_userclk_rx_reset_in          <= Ctrl.FF_K7.COMMON.RESETS.RX_USERCLK;
  

  FF_K7_refclocks: for iRefClk in FF_K7_clocks_in.gtrefclk0_in'range generate
    --refclk
    FF_K7_clocks_in.gtrefclk0_in(iRefClk)      <= ref_clk(FF_K7_CLK_ID);    
  end generate FF_K7_refclocks;




  FF_K7: for iChan in FF_K7_channel_in'RANGE  generate    
    
    --DRP interface
    Mon.FF_K7.CHANNEL(iChan).DRP.rd_data         <= FF_K7_channel_out(iChan).drpdo_out;     
    Mon.FF_K7.CHANNEL(iChan).DRP.rd_data_valid   <= FF_K7_channel_out(iChan).drprdy_out;
    FF_K7_channel_in(iChan).drpaddr_in           <= Ctrl.FF_K7.CHANNEL(iChan).DRP.address;
    FF_K7_channel_in(iChan).drpclk_in            <= Ctrl.FF_K7.CHANNEL(iChan).DRP.clk;
    FF_K7_channel_in(iChan).drpdi_in             <= Ctrl.FF_K7.CHANNEL(iChan).DRP.wr_data;
    FF_K7_channel_in(iChan).drpen_in             <= Ctrl.FF_K7.CHANNEL(iChan).DRP.enable or Ctrl.FF_K7.CHANNEL(iChan).DRP.wr_enable;                     
    FF_K7_channel_in(iChan).drprst_in            <= reset;
    FF_K7_channel_in(iChan).drpwe_in             <= Ctrl.FF_K7.CHANNEL(iChan).DRP.wr_enable;
    

    --User
    Mon.FF_K7.CHANNEL(iChan).INFO.TXRX_TYPE          <= FF_K7_channel_out(iChan).TXRX_TYPE;

    
    --Other
    Mon.FF_K7.CHANNEL(iChan).INFO.cpllfbclklost_out     <= FF_K7_channel_out(iChan).cpllfbclklost_out    ;
    Mon.FF_K7.CHANNEL(iChan).INFO.cplllock_out          <= FF_K7_channel_out(iChan).cplllock_out         ;
    Mon.FF_K7.CHANNEL(iChan).INFO.dmonitorout_out       <= FF_K7_channel_out(iChan).dmonitorout_out      ;
    Mon.FF_K7.CHANNEL(iChan).INFO.eyescandataerror_out  <= FF_K7_channel_out(iChan).eyescandataerror_out ;
    Mon.FF_K7.CHANNEL(iChan).INFO.gtpowergood_out       <= FF_K7_channel_out(iChan).gtpowergood_out      ;
    Mon.FF_K7.CHANNEL(iChan).INFO.rxbufstatus_out       <= FF_K7_channel_out(iChan).rxbufstatus_out      ;
    Mon.FF_K7.CHANNEL(iChan).INFO.rxbyteisaligned_out   <= FF_K7_channel_out(iChan).rxbyteisaligned_out      ;
    Mon.FF_K7.CHANNEL(iChan).INFO.rxbyterealign_out     <= FF_K7_channel_out(iChan).rxbyterealign_out      ;
    Mon.FF_K7.CHANNEL(iChan).INFO.rxcdrlock_out         <= FF_K7_channel_out(iChan).rxcdrlock_out        ;
    Mon.FF_K7.CHANNEL(iChan).INFO.rxcommadet_out        <= FF_K7_channel_out(iChan).rxcommadet_out        ;
    Mon.FF_K7.CHANNEL(iChan).INFO.rxctrl0_out           <= FF_K7_channel_out(iChan).rxctrl0_out          ;
    Mon.FF_K7.CHANNEL(iChan).INFO.rxctrl1_out           <= FF_K7_channel_out(iChan).rxctrl1_out          ;
    Mon.FF_K7.CHANNEL(iChan).INFO.rxctrl2_out           <= FF_K7_channel_out(iChan).rxctrl2_out          ;      
    Mon.FF_K7.CHANNEL(iChan).INFO.rxctrl3_out           <= FF_K7_channel_out(iChan).rxctrl3_out          ;
    Mon.FF_K7.CHANNEL(iChan).INFO.rxpmaresetdone_out    <= FF_K7_channel_out(iChan).rxpmaresetdone_out   ;
    Mon.FF_K7.CHANNEL(iChan).INFO.rxprbserr_out         <= FF_K7_channel_out(iChan).rxprbserr_out        ;
    Mon.FF_K7.CHANNEL(iChan).INFO.rxresetdone_out       <= FF_K7_channel_out(iChan).rxresetdone_out      ;
    Mon.FF_K7.CHANNEL(iChan).INFO.txbufstatus_out       <= FF_K7_channel_out(iChan).txbufstatus_out      ;
    Mon.FF_K7.CHANNEL(iChan).INFO.txpmaresetdone_out    <= FF_K7_channel_out(iChan).txpmaresetdone_out   ;
    Mon.FF_K7.CHANNEL(iChan).INFO.txresetdone_out       <= FF_K7_channel_out(iChan).txresetdone_out      ;


    FF_K7_channel_in(iChan).cpllpd_in         <= Ctrl.FF_K7.CHANNEL(iChan).INFO.cpllpd_in        ;
    FF_K7_channel_in(iChan).cpllreset_in      <= Ctrl.FF_K7.CHANNEL(iChan).INFO.cpllreset_in     ;
    FF_K7_channel_in(iChan).eyescanreset_in   <= Ctrl.FF_K7.CHANNEL(iChan).INFO.eyescanreset_in  ;
    FF_K7_channel_in(iChan).eyescantrigger_in <= Ctrl.FF_K7.CHANNEL(iChan).INFO.eyescantrigger_in;
    FF_K7_channel_in(iChan).gtrxreset_in      <= Ctrl.FF_K7.CHANNEL(iChan).INFO.gtrxreset_in     ;
    FF_K7_channel_in(iChan).gttxreset_in      <= Ctrl.FF_K7.CHANNEL(iChan).INFO.gttxreset_in     ;
    FF_K7_channel_in(iChan).loopback_in       <= Ctrl.FF_K7.CHANNEL(iChan).INFO.loopback_in      ;
    FF_K7_channel_in(iChan).pcsrsvdin_in      <= Ctrl.FF_K7.CHANNEL(iChan).INFO.pcsrsvdin_in     ;
    FF_K7_channel_in(iChan).rx8b10ben_in      <= Ctrl.FF_K7.CHANNEL(iChan).INFO.rx8b10ben_in     ;
    FF_K7_channel_in(iChan).rxbufreset_in     <= Ctrl.FF_K7.CHANNEL(iChan).INFO.rxbufreset_in    ;
    FF_K7_channel_in(iChan).rxcdrhold_in      <= Ctrl.FF_K7.CHANNEL(iChan).INFO.rxcdrhold_in     ;
    FF_K7_channel_in(iChan).rxcommadeten_in   <= Ctrl.FF_K7.CHANNEL(iChan).INFO.rxcommadeten_in  ;
    FF_K7_channel_in(iChan).rxdfelpmreset_in  <= Ctrl.FF_K7.CHANNEL(iChan).INFO.rxdfelpmreset_in ;
    FF_K7_channel_in(iChan).rxlpmen_in        <= Ctrl.FF_K7.CHANNEL(iChan).INFO.rxlpmen_in       ;
    FF_K7_channel_in(iChan).rxmcommaalignen_in <= Ctrl.FF_K7.CHANNEL(iChan).INFO.rxmcommaalignen_in  ;
    FF_K7_channel_in(iChan).rxpcommaalignen_in <= Ctrl.FF_K7.CHANNEL(iChan).INFO.rxpcommaalignen_in  ;
    FF_K7_channel_in(iChan).rxpcsreset_in     <= Ctrl.FF_K7.CHANNEL(iChan).INFO.rxpcsreset_in    ;
    FF_K7_channel_in(iChan).rxpmareset_in     <= Ctrl.FF_K7.CHANNEL(iChan).INFO.rxpmareset_in    ;
    FF_K7_channel_in(iChan).rxprbscntreset_in <= Ctrl.FF_K7.CHANNEL(iChan).INFO.rxprbscntreset_in;
    FF_K7_channel_in(iChan).rxprbssel_in      <= Ctrl.FF_K7.CHANNEL(iChan).INFO.rxprbssel_in     ;
    FF_K7_channel_in(iChan).rxprogdivreset_in <= Ctrl.FF_K7.CHANNEL(iChan).INFO.rxprogdivreset_in;
    FF_K7_channel_in(iChan).rxrate_in         <= Ctrl.FF_K7.CHANNEL(iChan).INFO.rxrate_in        ;
    FF_K7_channel_in(iChan).rxuserrdy_in      <= Ctrl.FF_K7.CHANNEL(iChan).INFO.rxuserrdy_in     ;
    FF_K7_channel_in(iChan).tx8b10ben_in      <= Ctrl.FF_K7.CHANNEL(iChan).INFO.tx8b10ben_in     ;
    FF_K7_channel_in(iChan).txctrl0_in        <= Ctrl.FF_K7.CHANNEL(iChan).INFO.txctrl0_in       ;
    FF_K7_channel_in(iChan).txctrl1_in        <= Ctrl.FF_K7.CHANNEL(iChan).INFO.txctrl1_in       ;
--    FF_K7_channel_in(iChan).txctrl2_in        <= Ctrl.FF_K7.CHANNEL(iChan).INFO.txctrl2_in       ;
    FF_K7_channel_in(iChan).txdiffctrl_in     <= Ctrl.FF_K7.CHANNEL(iChan).INFO.txdiffctrl_in    ;
    FF_K7_channel_in(iChan).txinhibit_in      <= Ctrl.FF_K7.CHANNEL(iChan).INFO.txinhibit_in     ;
    FF_K7_channel_in(iChan).txpcsreset_in     <= Ctrl.FF_K7.CHANNEL(iChan).INFO.txpcsreset_in    ;
    FF_K7_channel_in(iChan).txpmareset_in     <= Ctrl.FF_K7.CHANNEL(iChan).INFO.txpmareset_in    ;
    FF_K7_channel_in(iChan).txpolarity_in     <= Ctrl.FF_K7.CHANNEL(iChan).INFO.txpolarity_in    ;
    FF_K7_channel_in(iChan).txpostcursor_in   <= Ctrl.FF_K7.CHANNEL(iChan).INFO.txpostcursor_in  ;
    FF_K7_channel_in(iChan).txprbsforceerr_in <= Ctrl.FF_K7.CHANNEL(iChan).INFO.txprbsforceerr_in;
    FF_K7_channel_in(iChan).txprbssel_in      <= Ctrl.FF_K7.CHANNEL(iChan).INFO.txprbssel_in     ;
    FF_K7_channel_in(iChan).txprecursor_in    <= Ctrl.FF_K7.CHANNEL(iChan).INFO.txprecursor_in   ;
    FF_K7_channel_in(iChan).txprogdivreset_in <= Ctrl.FF_K7.CHANNEL(iChan).INFO.txprogdivreset_in;
    FF_K7_channel_in(iChan).txuserrdy_in      <= Ctrl.FF_K7.CHANNEL(iChan).INFO.txuserrdy_in     ;


    Mon.FF_K7.CHANNEL(iChan).INFO.RX_DATA.DATA <= FF_K7_channel_out(iChan).gtwiz_userdata_rx_out(31 downto  0);
    Mon.FF_K7.CHANNEL(iChan).INFO.RX_DATA.K    <= FF_K7_channel_out(iChan).rxctrl2_out(3 downto 0);
    Mon.FF_K7.CHANNEL(iChan).INFO.TX_DATA.DATA <= FF_K7_channel_in(iChan).gtwiz_userdata_tx_in(31 downto  0);
    Mon.FF_K7.CHANNEL(iChan).INFO.TX_DATA.K    <= FF_K7_channel_in(iChan).txctrl2_in(3 downto 0);  



    FF_K7_channel_in(iChan).gtyrxn_in <= rx_n(FF_K7_LINK_START-1 + iChan);
    FF_K7_channel_in(iChan).gtyrxp_in <= rx_p(FF_K7_LINK_START-1 + iChan);
    tx_n(FF_K7_LINK_START-1 + iChan) <= FF_K7_channel_out(iChan).gtytxn_out;
    tx_p(FF_K7_LINK_START-1 + iChan) <= FF_K7_channel_out(iChan).gtytxp_out;
    
    ChannelTest_1: entity work.ChannelTest
      port map (
        clk         => FF_K7_Common_Out.gtwiz_userclk_rx_usrclk_out,
        clk_axi     => clk_axi,
        reset       => reset,
        tx_fixed(31 downto  0) => Ctrl.FF_K7.CHANNEL(iChan).INFO.TX_FIXED,
        tx_fixed(35 downto 32) => Ctrl.FF_K7.CHANNEL(iChan).INFO.TX_FIXED_HEADER,
        tx_fixed_en            => Ctrl.FF_K7.CHANNEL(iChan).INFO.TX_FIXED_EN,
        rx_data     => FF_K7_channel_out(iChan).gtwiz_userdata_rx_out,
        rx_k_data   => FF_K7_channel_out(iChan).rxctrl2_out(3 downto 0),
        tx_data     => FF_K7_channel_in(iChan).gtwiz_userdata_tx_in,
        tx_k_data   => FF_K7_channel_in(iChan).txctrl2_in(3 downto 0),  
        error_rate  => Mon.FF_K7.CHANNEL(iChan).INFO.ERROR_RATE,
        error_count => Mon.FF_K7.CHANNEL(iChan).INFO.ERROR_COUNT);
  end generate FF_K7;



end architecture behavioral;
