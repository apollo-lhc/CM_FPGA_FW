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
use work.FF_K4_PKG.all;
use work.FF_K5_PKG.all;
use work.FF_K6_PKG.all;
use work.FF_K7_PKG.all;

entity QuadTest is
  port (
    clk_axi              : in  std_logic; --50 MHz
    reset_axi_n          : in  std_logic;
    refclk_i_p           : in  std_logic_vector(7 downto 1);
    refclk_i_n           : in  std_logic_vector(7 downto 1);
    tx_n                 : out std_logic_vector(7*12 downto 1);
    tx_p                 : out std_logic_vector(7*12 downto 1);
    rx_n                 : in  std_logic_vector(7*12 downto 1);
    rx_p                 : in  std_logic_vector(7*12 downto 1);

    readMOSI             : in  AXIreadMOSI;
    readMISO             : out AXIreadMISO;
    writeMOSI            : in  AXIwriteMOSI;
    writeMISO            : out AXIwriteMISO); -- '0' for refclk0, '1' for refclk1

end entity QuadTest;

architecture behavioral of QuadTest is

  signal FF_K1_common_in   : FF_K1_CommonIn;                        
  signal FF_K1_common_out  : FF_K1_CommonOut;                       
  signal FF_K1_channel_in  : FF_K1_ChannelIn_array_t(12 downto 1);  
  signal FF_K1_channel_out : FF_K1_ChannelOut_array_t(12 downto 1);
  signal FF_K2_common_in   : FF_K2_CommonIn;                        
  signal FF_K2_common_out  : FF_K2_CommonOut;                       
  signal FF_K2_channel_in  : FF_K2_ChannelIn_array_t(12 downto 1);  
  signal FF_K2_channel_out : FF_K2_ChannelOut_array_t(12 downto 1);
  signal FF_K3_common_in   : FF_K3_CommonIn;                        
  signal FF_K3_common_out  : FF_K3_CommonOut;                       
  signal FF_K3_channel_in  : FF_K3_ChannelIn_array_t(12 downto 1);  
  signal FF_K3_channel_out : FF_K3_ChannelOut_array_t(12 downto 1);
  signal FF_K4_common_in   : FF_K4_CommonIn;                        
  signal FF_K4_common_out  : FF_K4_CommonOut;                       
  signal FF_K4_channel_in  : FF_K4_ChannelIn_array_t(4 downto 1);  
  signal FF_K4_channel_out : FF_K4_ChannelOut_array_t(4 downto 1);
  signal FF_K5_common_in   : FF_K5_CommonIn;                        
  signal FF_K5_common_out  : FF_K5_CommonOut;                       
  signal FF_K5_channel_in  : FF_K5_ChannelIn_array_t(4 downto 1);  
  signal FF_K5_channel_out : FF_K5_ChannelOut_array_t(4 downto 1);
  signal FF_K6_common_in   : FF_K6_CommonIn;                        
  signal FF_K6_common_out  : FF_K6_CommonOut;                       
  signal FF_K6_channel_in  : FF_K6_ChannelIn_array_t(4 downto 1);  
  signal FF_K6_channel_out : FF_K6_ChannelOut_array_t(4 downto 1);
  signal FF_K7_common_in   : FF_K7_CommonIn;                        
  signal FF_K7_common_out  : FF_K7_CommonOut;                       
  signal FF_K7_channel_in  : FF_K7_ChannelIn_array_t(12 downto 1);  
  signal FF_K7_channel_out : FF_K7_ChannelOut_array_t(12 downto 1);
  signal reset             : std_logic;
  signal Mon               : QUAD_TEST_Mon_t;
  signal Ctrl              : QUAD_TEST_Ctrl_t;
  signal ref_clk           : std_logic_vector(7 downto 1);
  signal ref_clk2          : std_logic_vector(7 downto 1);

  type pma_reset_t is array (integer range <>) of std_logic_vector(12 downto 1);
  signal tx_pma_reset : pma_reset_t(1 to 7) := (others => x"000");
  signal rx_pma_reset : pma_reset_t(1 to 7) := (others => x"000");
  signal ref_clk_fabric : std_logic_vector(7 downto 1) := (others => '0');
  signal ref_clk_freq   : slv32_array_t(7 downto 1);
  signal CESYNC         : std_logic_vector(7 downto 1);
  signal CLRSYNC        : std_logic_vector(7 downto 1);

  signal hb_gtwiz_reset_all_init_int : std_logic_vector(7 downto 1);
  signal hb_gtwiz_reset_rx_datapath_init_int  : std_logic_vector(7 downto 1);
  signal init_done_int  : std_logic_vector(7 downto 1);
  
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
        CLK_A_1_SECOND => 500000000)
      port map (
        clk_A         => clk_axi,
        clk_B         => ref_clk_fabric(iRefClk) ,
        reset_A_async => '0',
        event_b       => '1',
        rate          => ref_clk_freq(iRefClk));    
  end generate refclk_gen;






  
  --FF_K1

  your_instance_name : entity work.FF_K1_ILA
    PORT MAP (
      clk => clk_axi,
      probe0(0) => Ctrl.FF_K1.COMMON.RESETS.FULL,
      probe0(1) => FF_K1_common_out.gtwiz_reset_tx_done_out,        
      probe0(2) => FF_K1_common_out.gtwiz_reset_rx_done_out,        
      probe0(3) => FF_K1_common_out.gtwiz_reset_rx_cdr_stable_out,  
      probe0(4) => hb_gtwiz_reset_all_init_int(1),                  
      probe0(5) => hb_gtwiz_reset_rx_datapath_init_int(1),          
      probe0(6) => init_done_int(1),
      probe0(7) => '0',
      probe1(0) => FF_K1_Common_in.gtwiz_userclk_tx_reset_in,      
      probe1(1) => FF_K1_Common_in.gtwiz_userclk_rx_reset_in,     
      probe1(2) => FF_K1_Common_in.gtwiz_reset_clk_freerun_in,    
      probe1(3) => FF_K1_Common_in.gtwiz_reset_all_in,            
      probe1(4) => FF_K1_Common_in.gtwiz_reset_tx_pll_and_datapath_in,
      probe1(5) => FF_K1_Common_in.gtwiz_reset_tx_datapath_in,    
      probe1(6) => FF_K1_Common_in.gtwiz_reset_rx_pll_and_datapath_in,
      probe1(7) => FF_K1_Common_in.gtwiz_reset_rx_datapath_in,    
      probe2(0) => FF_K1_Common_out.gtwiz_userclk_tx_active_out,    
      probe2(1) => FF_K1_Common_out.gtwiz_userclk_rx_active_out,    
      probe2(2) => FF_K1_Common_out.gtwiz_reset_rx_cdr_stable_out,  
      probe2(3) => FF_K1_Common_out.gtwiz_reset_tx_done_out,        
      probe2(4) => FF_K1_Common_out.gtwiz_reset_rx_done_out,        
      probe2(5) => FF_K1_Channel_out(1).cplllock_out,
      probe2(6) => FF_K1_Channel_out(1).rxpmaresetdone_out,
      probe2(7) => FF_K1_Channel_out(1).rxresetdone_out,
      probe2(8) => FF_K1_Channel_out(1).txpmaresetdone_out,
      probe2(9) => FF_K1_Channel_out(1).txresetdone_out, 
      probe2(10)=> FF_K1_Channel_in(1).rxbufreset_in,                 
      probe2(11)=> FF_K1_Channel_in(1).rxcdrhold_in,                 
      probe2(12) => FF_K1_Channel_in(1).rxdfelpmreset_in,             
      probe2(13) => FF_K1_Channel_in(1).rxlpmen_in,                   
      probe2(14) => FF_K1_Channel_in(1).rxpcsreset_in,                
      probe2(15) => FF_K1_Channel_in(1).rxpmareset_in);

  
  example_init_inst_FF_K1: entity work.FF_K1_example_init
    port map(
    clk_freerun_in   => clk_axi,
    reset_all_in     => Ctrl.FF_K1.COMMON.RESETS.FULL,
    tx_init_done_in  => FF_K1_common_out.gtwiz_reset_tx_done_out,
    rx_init_done_in  => FF_K1_common_out.gtwiz_reset_rx_done_out,
    rx_data_good_in  => FF_K1_common_out.gtwiz_reset_rx_cdr_stable_out,
    reset_all_out    => hb_gtwiz_reset_all_init_int(1),
    reset_rx_out     => hb_gtwiz_reset_rx_datapath_init_int(1),
    init_done_out    => init_done_int(1),                                
    retry_ctr_out    => open
  );
  Mon.FF_K1.COMMON.COUNTERS.REFCLK_FREQ <= ref_clk_freq(1);
  Mon.FF_K1.COMMON.STATUS.INIT_DONE <= init_done_int(1);
  FF_K1_wrapper_1: entity work.FF_K1_wrapper
    port map (
      common_in   => FF_K1_common_in,
      common_out  => FF_K1_common_out,
      channel_in  => FF_K1_channel_in,
      channel_out => FF_K1_channel_out);
  rate_counter_1: entity work.rate_counter
    generic map (
      CLK_A_1_SECOND => 50000000)
    port map (
      clk_A         => clk_axi,
      clk_B         => FF_K1_common_out.gtwiz_userclk_rx_usrclk_out,
      reset_A_async => Ctrl.FF_K1.COMMON.RESETS.FULL or Ctrl.FF_K1.COMMON.RESETS.RX_PLL_DATAPATH,
      event_b       => '1',
      rate          => Mon.FF_K1.COMMON.COUNTERS.RX_USER_FREQ);
  rate_counter_3: entity work.rate_counter
    generic map (
      CLK_A_1_SECOND => 50000000)
    port map (
      clk_A         => clk_axi,
      clk_B         => FF_K1_common_out.gtwiz_userclk_tx_usrclk_out,
      reset_A_async => Ctrl.FF_K1.COMMON.RESETS.FULL or Ctrl.FF_K1.COMMON.RESETS.TX_PLL_DATAPATH,
      event_b       => '1',
      rate          => Mon.FF_K1.COMMON.COUNTERS.TX_USER_FREQ);
  Mon.FF_K1.COMMON.RESETS.RX_DONE                    <= FF_K1_common_out.gtwiz_reset_rx_done_out;
  Mon.FF_K1.COMMON.RESETS.TX_DONE                    <= FF_K1_common_out.gtwiz_reset_tx_done_out;
  Mon.FF_K1.COMMON.STATUS.RX_ACTIVE                  <= FF_K1_common_out.gtwiz_userclk_rx_active_out;
  Mon.FF_K1.COMMON.STATUS.RX_CDR_STABLE              <= FF_K1_common_out.gtwiz_reset_rx_cdr_stable_out;
  Mon.FF_K1.COMMON.STATUS.TX_ACTIVE                  <= FF_K1_common_out.gtwiz_userclk_tx_active_out;   
  FF_K1_common_in.gtwiz_userclk_tx_reset_in          <= (not or_reduce(tx_pma_reset(1))) or Ctrl.FF_K1.COMMON.RESETS.TX_USERCLK;
  FF_K1_common_in.gtwiz_userclk_rx_reset_in          <= (not or_reduce(rx_pma_reset(1))) or Ctrl.FF_K1.COMMON.RESETS.RX_USERCLK;
  FF_K1_common_in.gtwiz_reset_clk_freerun_in         <= Ctrl.FF_K1.COMMON.RESETS.FREERUN;
  FF_K1_common_in.gtwiz_reset_all_in                 <= Ctrl.FF_K1.COMMON.RESETS.FULL or hb_gtwiz_reset_all_init_int(1);
  FF_K1_common_in.gtwiz_reset_tx_pll_and_datapath_in <= Ctrl.FF_K1.COMMON.RESETS.TX_PLL_DATAPATH;
  FF_K1_common_in.gtwiz_reset_tx_datapath_in         <= Ctrl.FF_K1.COMMON.RESETS.TX_DATAPATH or  hb_gtwiz_reset_rx_datapath_init_int(1);
  FF_K1_common_in.gtwiz_reset_rx_pll_and_datapath_in <= Ctrl.FF_K1.COMMON.RESETS.RX_PLL_DATAPATH;
  FF_K1_common_in.gtwiz_reset_rx_datapath_in         <= Ctrl.FF_K1.COMMON.RESETS.RX_DATAPATH;  
--  FF_K1: for iChan in FF_K1_channel_in'low to FF_K1_channel_in'high  generate
--    FF_K1: for iChan in 1 to 12  generate
  FF_K1: for iChan in FF_K1_channel_in'RANGE  generate    
    
    --DRP interface
    Mon.FF_K1.CHANNEL(iChan).DRP.rd_data        <= FF_K1_channel_out(iChan).drpdo_out;     
    Mon.FF_K1.CHANNEL(iChan).DRP.rd_data_valid  <= FF_K1_channel_out(iChan).drprdy_out;
    FF_K1_channel_in(iChan).drpaddr_in           <= Ctrl.FF_K1.CHANNEL(iChan).DRP.address;
    FF_K1_channel_in(iChan).drpclk_in            <= Ctrl.FF_K1.CHANNEL(iChan).DRP.clk;
    FF_K1_channel_in(iChan).drpdi_in             <= Ctrl.FF_K1.CHANNEL(iChan).DRP.wr_data;
    FF_K1_channel_in(iChan).drpen_in             <= Ctrl.FF_K1.CHANNEL(iChan).DRP.enable or Ctrl.FF_K1.CHANNEL(iChan).DRP.wr_enable;                     
    FF_K1_channel_in(iChan).drprst_in            <= reset;
    FF_K1_channel_in(iChan).drpwe_in             <= Ctrl.FF_K1.CHANNEL(iChan).DRP.wr_enable;
    
    --User
    Mon.FF_K1.CHANNEL(iChan).INFO.TXRX_TYPE          <= FF_K1_channel_out(iChan).TXRX_TYPE;

    --refclk
    FF_K1_channel_in(iChan).gtrefclk0_in      <= ref_clk(1);
    
    --Other    
    Mon.FF_K1.CHANNEL(iChan).INFO.DEBUG.CPLL_LOCK           <= FF_K1_channel_out(iChan).cplllock_out;             
    Mon.FF_K1.CHANNEL(iChan).INFO.DEBUG.DMONITOR            <= FF_K1_channel_out(iChan).dmonitorout_out;          
    Mon.FF_K1.CHANNEL(iChan).INFO.DEBUG.EYESCAN_DATA_ERROR  <= FF_K1_channel_out(iChan).eyescandataerror_out;     
    tx_n(iChan + (12 *0))                                   <= FF_K1_channel_out(iChan).gthtxn_out;               
    tx_p(iChan + (12 *0))                                   <= FF_K1_channel_out(iChan).gthtxp_out;               
    Mon.FF_K1.CHANNEL(iChan).INFO.GT_PWR_GOOD               <= FF_K1_channel_out(iChan).gtpowergood_out;         
    Mon.FF_K1.CHANNEL(iChan).INFO.DEBUG.RX.BUF_STATUS       <= FF_K1_channel_out(iChan).rxbufstatus_out;          
    Mon.FF_K1.CHANNEL(iChan).INFO.RX_BYTE_ALIGNED           <= FF_K1_channel_out(iChan).rxbyteisaligned_out;     
    Mon.FF_K1.CHANNEL(iChan).INFO.RX_BYTE_REALIGN           <= FF_K1_channel_out(iChan).rxbyterealign_out;       
    Mon.FF_K1.CHANNEL(iChan).INFO.RX_COMMA_DET              <= FF_K1_channel_out(iChan).rxcommadet_out;          
    Mon.FF_K1.CHANNEL(iChan).INFO.RX_PMA_RESET_DONE         <= rx_pma_reset(1)(iChan);
    rx_pma_reset(1)(iChan)                                  <= FF_K1_channel_out(iChan).rxpmaresetdone_out;          
    Mon.FF_K1.CHANNEL(iChan).INFO.DEBUG.RX.PRBS_ERR         <= FF_K1_channel_out(iChan).rxprbserr_out;            
    Mon.FF_K1.CHANNEL(iChan).INFO.DEBUG.RX.RESET_DONE       <= FF_K1_channel_out(iChan).rxresetdone_out;          
    Mon.FF_K1.CHANNEL(iChan).INFO.DEBUG.TX.BUF_STATUS       <= FF_K1_channel_out(iChan).txbufstatus_out;         
    Mon.FF_K1.CHANNEL(iChan).INFO.TX_PMA_RESET_DONE         <= tx_pma_reset(1)(iChan);
    tx_pma_reset(1)(iChan)                                  <= FF_K1_channel_out(iChan).txpmaresetdone_out;      
    Mon.FF_K1.CHANNEL(iChan).INFO.DEBUG.TX.RESET_DONE       <= FF_K1_channel_out(iChan).txresetdone_out;          


    FF_K1_channel_in(iChan).loopback_in          <= Ctrl.FF_K1.CHANNEL(iChan).INFO.LOOPBACK;


    FF_K1_channel_in(iChan).eyescanreset_in      <= Ctrl.FF_K1.CHANNEL(iChan).INFO.DEBUG.EYESCAN_RESET;
    FF_K1_channel_in(iChan).eyescantrigger_in    <= Ctrl.FF_K1.CHANNEL(iChan).INFO.DEBUG.EYESCAN_TRIGGER;   
    FF_K1_channel_in(iChan).gthrxn_in            <= rx_n(iChan + (12 *0));
    FF_K1_channel_in(iChan).gthrxp_in            <= rx_p(iChan + (12 *0));
    FF_K1_channel_in(iChan).pcsrsvdin_in         <= Ctrl.FF_K1.CHANNEL(iChan).INFO.DEBUG.PCS_RSV_DIN;  
    FF_K1_channel_in(iChan).rxbufreset_in        <= Ctrl.FF_K1.CHANNEL(iChan).INFO.DEBUG.RX.BUF_RESET;
    FF_K1_channel_in(iChan).rxcdrhold_in         <= Ctrl.FF_K1.CHANNEL(iChan).INFO.DEBUG.RX.CDR_HOLD;
--  FF_K1_channel_in(iChan).rxcommadeten_in      <= Ctrl.FF_K1.CHANNEL(iChan).;
    FF_K1_channel_in(iChan).rxdfelpmreset_in     <= Ctrl.FF_K1.CHANNEL(iChan).INFO.DEBUG.RX.DFE_LPM_RESET;
    FF_K1_channel_in(iChan).rxlpmen_in           <= Ctrl.FF_K1.CHANNEL(iChan).INFO.DEBUG.RX.LPM_EN;
--  FF_K1_channel_in(iChan).rxmcommaalignen_in   <= Ctrl.FF_K1.CHANNEL(iChan).;
--  FF_K1_channel_in(iChan).rxpcommaalignen_in   <= Ctrl.FF_K1.CHANNEL(iChan).;
    FF_K1_channel_in(iChan).rxpcsreset_in        <= Ctrl.FF_K1.CHANNEL(iChan).INFO.DEBUG.RX.PCS_RESET;
    FF_K1_channel_in(iChan).rxpmareset_in        <= Ctrl.FF_K1.CHANNEL(iChan).INFO.DEBUG.RX.PMA_RESET;
    FF_K1_channel_in(iChan).rxprbscntreset_in    <= Ctrl.FF_K1.CHANNEL(iChan).INFO.DEBUG.RX.PRBS_CNT_RST;
    FF_K1_channel_in(iChan).rxprbssel_in         <= Ctrl.FF_K1.CHANNEL(iChan).INFO.DEBUG.RX.PRBS_SEL;
    FF_K1_channel_in(iChan).rxrate_in            <= Ctrl.FF_K1.CHANNEL(iChan).INFO.DEBUG.RX.RATE;
    FF_K1_channel_in(iChan).txdiffctrl_in        <= Ctrl.FF_K1.CHANNEL(iChan).INFO.DEBUG.TX.DIFF_CTRL;
    FF_K1_channel_in(iChan).txinhibit_in         <= Ctrl.FF_K1.CHANNEL(iChan).INFO.DEBUG.TX.INHIBIT;
    FF_K1_channel_in(iChan).txpcsreset_in        <= Ctrl.FF_K1.CHANNEL(iChan).INFO.DEBUG.TX.PCS_RESET;
    FF_K1_channel_in(iChan).txpmareset_in        <= Ctrl.FF_K1.CHANNEL(iChan).INFO.DEBUG.TX.PMA_RESET;
    FF_K1_channel_in(iChan).txpolarity_in        <= Ctrl.FF_K1.CHANNEL(iChan).INFO.DEBUG.TX.POLARITY;
    FF_K1_channel_in(iChan).txpostcursor_in      <= Ctrl.FF_K1.CHANNEL(iChan).INFO.DEBUG.TX.POST_CURSOR;
    FF_K1_channel_in(iChan).txprbsforceerr_in    <= Ctrl.FF_K1.CHANNEL(iChan).INFO.DEBUG.TX.PRBS_FORCE_ERR;
    FF_K1_channel_in(iChan).txprbssel_in         <= Ctrl.FF_K1.CHANNEL(iChan).INFO.DEBUG.TX.PRBS_SEL;  
    FF_K1_channel_in(iChan).txprecursor_in       <= Ctrl.FF_K1.CHANNEL(iChan).INFO.DEBUG.TX.PRE_CURSOR;



    Mon.FF_K1.CHANNEL(iChan).INFO.RX_DATA.DATA <= FF_K1_channel_out(iChan).gtwiz_userdata_rx_out;
    Mon.FF_K1.CHANNEL(iChan).INFO.RX_DATA.K <= FF_K1_channel_out(iChan).rxctrl2_out(3 downto 0);
    Mon.FF_K1.CHANNEL(iChan).INFO.TX_DATA.DATA <= FF_K1_channel_in(iChan).gtwiz_userdata_tx_in;    
    Mon.FF_K1.CHANNEL(iChan).INFO.TX_DATA.K <= FF_K1_channel_in(iChan).txctrl2_in(3 downto 0);  
    
    ChannelTest_1: entity work.ChannelTest
      port map (
        clk         => FF_K1_Common_Out.gtwiz_userclk_rx_usrclk_out,
        clk_axi     => clk_axi,
        reset       => reset,
        rx_data     => FF_K1_channel_out(iChan).gtwiz_userdata_rx_out,
        rx_k_data   => FF_K1_channel_out(iChan).rxctrl2_out(3 downto 0),
        tx_data     => FF_K1_channel_in(iChan).gtwiz_userdata_tx_in,
        tx_k_data   => FF_K1_channel_in(iChan).txctrl2_in(3 downto 0),  
        error_rate  => Mon.FF_K1.CHANNEL(iChan).INFO.ERROR_RATE,
        error_count => Mon.FF_K1.CHANNEL(iChan).INFO.ERROR_COUNT);
  end generate FF_K1;





    --FF_K2
  Mon.FF_K2.COMMON.COUNTERS.REFCLK_FREQ <= ref_clk_freq(2);
  FF_K2_wrapper_1: entity work.FF_K2_wrapper
    port map (
      common_in   => FF_K2_common_in,
      common_out  => FF_K2_common_out,
      channel_in  => FF_K2_channel_in,
      channel_out => FF_K2_channel_out);
  rate_counter_4: entity work.rate_counter
    generic map (
      CLK_A_1_SECOND => 50000000)
    port map (
      clk_A         => clk_axi,
      clk_B         => FF_K2_common_out.gtwiz_userclk_rx_usrclk_out,
      reset_A_async => Ctrl.FF_K2.COMMON.RESETS.FULL or Ctrl.FF_K2.COMMON.RESETS.RX_PLL_DATAPATH,
      event_b       => '1',
      rate          => Mon.FF_K2.COMMON.COUNTERS.RX_USER_FREQ);
  rate_counter_5: entity work.rate_counter
    generic map (
      CLK_A_1_SECOND => 50000000)
    port map (
      clk_A         => clk_axi,
      clk_B         => FF_K2_common_out.gtwiz_userclk_tx_usrclk_out,
      reset_A_async => Ctrl.FF_K2.COMMON.RESETS.FULL or Ctrl.FF_K2.COMMON.RESETS.TX_PLL_DATAPATH,
      event_b       => '1',
      rate          => Mon.FF_K2.COMMON.COUNTERS.TX_USER_FREQ);
  FF_K2_common_in.gtwiz_userclk_tx_reset_in      <= (not or_reduce(tx_pma_reset(2))) or Ctrl.FF_K2.COMMON.RESETS.TX_USERCLK;
  FF_K2_common_in.gtwiz_userclk_rx_reset_in      <= (not or_reduce(rx_pma_reset(2))) or Ctrl.FF_K2.COMMON.RESETS.RX_USERCLK;
  FF_K2_common_in.gtwiz_reset_clk_freerun_in     <= Ctrl.FF_K2.COMMON.RESETS.FREERUN;
  FF_K2_common_in.gtwiz_reset_all_in             <= Ctrl.FF_K2.COMMON.RESETS.FULL;
  FF_K2_common_in.gtwiz_reset_tx_pll_and_datapath_in  <= Ctrl.FF_K2.COMMON.RESETS.TX_PLL_DATAPATH;
  FF_K2_common_in.gtwiz_reset_tx_datapath_in      <= Ctrl.FF_K2.COMMON.RESETS.TX_DATAPATH;
  FF_K2_common_in.gtwiz_reset_rx_pll_and_datapath_in <= Ctrl.FF_K2.COMMON.RESETS.RX_PLL_DATAPATH;
  FF_K2_common_in.gtwiz_reset_rx_datapath_in     <= Ctrl.FF_K2.COMMON.RESETS.RX_DATAPATH;  
--  FF_K2: for iChan in FF_K2_channel_in'low to FF_K2_channel_in'high  generate
--    FF_K2: for iChan in 1 to 12  generate
  FF_K2: for iChan in FF_K2_channel_in'RANGE  generate
    
    --DRP interface
    Mon.FF_K2.CHANNEL(iChan).DRP.rd_data        <= FF_K2_channel_out(iChan).drpdo_out;     
    Mon.FF_K2.CHANNEL(iChan).DRP.rd_data_valid  <= FF_K2_channel_out(iChan).drprdy_out;
    FF_K2_channel_in(iChan).drpaddr_in           <= Ctrl.FF_K2.CHANNEL(iChan).DRP.address;
    FF_K2_channel_in(iChan).drpclk_in            <= Ctrl.FF_K2.CHANNEL(iChan).DRP.clk;
    FF_K2_channel_in(iChan).drpdi_in             <= Ctrl.FF_K2.CHANNEL(iChan).DRP.wr_data;
    FF_K2_channel_in(iChan).drpen_in             <= Ctrl.FF_K2.CHANNEL(iChan).DRP.enable or Ctrl.FF_K2.CHANNEL(iChan).DRP.wr_enable;                     
    FF_K2_channel_in(iChan).drprst_in            <= reset;
    FF_K2_channel_in(iChan).drpwe_in             <= Ctrl.FF_K2.CHANNEL(iChan).DRP.wr_enable;
    
    --User
    Mon.FF_K2.CHANNEL(iChan).INFO.TXRX_TYPE          <= FF_K2_channel_out(iChan).TXRX_TYPE;

    --refclk
    FF_K2_channel_in(iChan).gtrefclk0_in      <= ref_clk(2);

    --Other
    Mon.FF_K2.CHANNEL(iChan).INFO.DEBUG.CPLL_LOCK    <= FF_K2_channel_out(iChan).cplllock_out;             
    Mon.FF_K2.CHANNEL(iChan).INFO.DEBUG.DMONITOR     <= FF_K2_channel_out(iChan).dmonitorout_out;          
    Mon.FF_K2.CHANNEL(iChan).INFO.DEBUG.EYESCAN_DATA_ERROR  <= FF_K2_channel_out(iChan).eyescandataerror_out;     
    tx_n(iChan + (12 *1))  <= FF_K2_channel_out(iChan).gthtxn_out;               
    tx_p(iChan + (12 *1))  <= FF_K2_channel_out(iChan).gthtxp_out;               
    Mon.FF_K2.CHANNEL(iChan).INFO.GT_PWR_GOOD  <= FF_K2_channel_out(iChan).gtpowergood_out;         
    Mon.FF_K2.CHANNEL(iChan).INFO.DEBUG.RX.BUF_STATUS  <= FF_K2_channel_out(iChan).rxbufstatus_out;          
    Mon.FF_K2.CHANNEL(iChan).INFO.RX_BYTE_ALIGNED  <= FF_K2_channel_out(iChan).rxbyteisaligned_out;     
    Mon.FF_K2.CHANNEL(iChan).INFO.RX_BYTE_REALIGN  <= FF_K2_channel_out(iChan).rxbyterealign_out;       
    Mon.FF_K2.CHANNEL(iChan).INFO.RX_COMMA_DET  <= FF_K2_channel_out(iChan).rxcommadet_out;          
    Mon.FF_K2.CHANNEL(iChan).INFO.RX_PMA_RESET_DONE <= rx_pma_reset(2)(iChan);
rx_pma_reset(2)(iChan)   <= FF_K2_channel_out(iChan).rxpmaresetdone_out;          
    Mon.FF_K2.CHANNEL(iChan).INFO.DEBUG.RX.PRBS_ERR  <= FF_K2_channel_out(iChan).rxprbserr_out;            
    Mon.FF_K2.CHANNEL(iChan).INFO.DEBUG.RX.RESET_DONE  <= FF_K2_channel_out(iChan).rxresetdone_out;          
    Mon.FF_K2.CHANNEL(iChan).INFO.DEBUG.TX.BUF_STATUS  <= FF_K2_channel_out(iChan).txbufstatus_out;         
    Mon.FF_K2.CHANNEL(iChan).INFO.TX_PMA_RESET_DONE <= tx_pma_reset(2)(iChan);
tx_pma_reset(2)(iChan)   <= FF_K2_channel_out(iChan).txpmaresetdone_out;      
    Mon.FF_K2.CHANNEL(iChan).INFO.DEBUG.TX.RESET_DONE  <= FF_K2_channel_out(iChan).txresetdone_out;          


    FF_K2_channel_in(iChan).loopback_in          <= Ctrl.FF_K2.CHANNEL(iChan).INFO.LOOPBACK;


    FF_K2_channel_in(iChan).eyescanreset_in      <= Ctrl.FF_K2.CHANNEL(iChan).INFO.DEBUG.EYESCAN_RESET;
    FF_K2_channel_in(iChan).eyescantrigger_in    <= Ctrl.FF_K2.CHANNEL(iChan).INFO.DEBUG.EYESCAN_TRIGGER;   
    FF_K2_channel_in(iChan).gthrxn_in            <= rx_n(iChan + (12 *1));
    FF_K2_channel_in(iChan).gthrxp_in            <= rx_p(iChan + (12 *1));
    FF_K2_channel_in(iChan).pcsrsvdin_in         <= Ctrl.FF_K2.CHANNEL(iChan).INFO.DEBUG.PCS_RSV_DIN;  
    FF_K2_channel_in(iChan).rxbufreset_in        <= Ctrl.FF_K2.CHANNEL(iChan).INFO.DEBUG.RX.BUF_RESET;
    FF_K2_channel_in(iChan).rxcdrhold_in         <= Ctrl.FF_K2.CHANNEL(iChan).INFO.DEBUG.RX.CDR_HOLD;
--  FF_K2_channel_in(iChan).rxcommadeten_in      <= Ctrl.FF_K2.CHANNEL(iChan).;
    FF_K2_channel_in(iChan).rxdfelpmreset_in     <= Ctrl.FF_K2.CHANNEL(iChan).INFO.DEBUG.RX.DFE_LPM_RESET;
    FF_K2_channel_in(iChan).rxlpmen_in           <= Ctrl.FF_K2.CHANNEL(iChan).INFO.DEBUG.RX.LPM_EN;
--  FF_K2_channel_in(iChan).rxmcommaalignen_in   <= Ctrl.FF_K2.CHANNEL(iChan).;
--  FF_K2_channel_in(iChan).rxpcommaalignen_in   <= Ctrl.FF_K2.CHANNEL(iChan).;
    FF_K2_channel_in(iChan).rxpcsreset_in        <= Ctrl.FF_K2.CHANNEL(iChan).INFO.DEBUG.RX.PCS_RESET;
    FF_K2_channel_in(iChan).rxpmareset_in        <= Ctrl.FF_K2.CHANNEL(iChan).INFO.DEBUG.RX.PMA_RESET;
    FF_K2_channel_in(iChan).rxprbscntreset_in    <= Ctrl.FF_K2.CHANNEL(iChan).INFO.DEBUG.RX.PRBS_CNT_RST;
    FF_K2_channel_in(iChan).rxprbssel_in         <= Ctrl.FF_K2.CHANNEL(iChan).INFO.DEBUG.RX.PRBS_SEL;
    FF_K2_channel_in(iChan).rxrate_in            <= Ctrl.FF_K2.CHANNEL(iChan).INFO.DEBUG.RX.RATE;
    FF_K2_channel_in(iChan).txdiffctrl_in        <= Ctrl.FF_K2.CHANNEL(iChan).INFO.DEBUG.TX.DIFF_CTRL;
    FF_K2_channel_in(iChan).txinhibit_in         <= Ctrl.FF_K2.CHANNEL(iChan).INFO.DEBUG.TX.INHIBIT;
    FF_K2_channel_in(iChan).txpcsreset_in        <= Ctrl.FF_K2.CHANNEL(iChan).INFO.DEBUG.TX.PCS_RESET;
    FF_K2_channel_in(iChan).txpmareset_in        <= Ctrl.FF_K2.CHANNEL(iChan).INFO.DEBUG.TX.PMA_RESET;
    FF_K2_channel_in(iChan).txpolarity_in        <= Ctrl.FF_K2.CHANNEL(iChan).INFO.DEBUG.TX.POLARITY;
    FF_K2_channel_in(iChan).txpostcursor_in      <= Ctrl.FF_K2.CHANNEL(iChan).INFO.DEBUG.TX.POST_CURSOR;
    FF_K2_channel_in(iChan).txprbsforceerr_in    <= Ctrl.FF_K2.CHANNEL(iChan).INFO.DEBUG.TX.PRBS_FORCE_ERR;
    FF_K2_channel_in(iChan).txprbssel_in         <= Ctrl.FF_K2.CHANNEL(iChan).INFO.DEBUG.TX.PRBS_SEL;  
    FF_K2_channel_in(iChan).txprecursor_in       <= Ctrl.FF_K2.CHANNEL(iChan).INFO.DEBUG.TX.PRE_CURSOR;



    Mon.FF_K2.CHANNEL(iChan).INFO.RX_DATA.DATA <= FF_K2_channel_out(iChan).gtwiz_userdata_rx_out;
    Mon.FF_K2.CHANNEL(iChan).INFO.RX_DATA.K <= FF_K2_channel_out(iChan).rxctrl2_out(3 downto 0);
    Mon.FF_K2.CHANNEL(iChan).INFO.TX_DATA.DATA <= FF_K2_channel_in(iChan).gtwiz_userdata_tx_in;    
    Mon.FF_K2.CHANNEL(iChan).INFO.TX_DATA.K <= FF_K2_channel_in(iChan).txctrl2_in(3 downto 0);  
    
    ChannelTest_1: entity work.ChannelTest
      port map (
        clk         => FF_K2_Common_Out.gtwiz_userclk_rx_usrclk_out,
        clk_axi     => clk_axi,
        reset       => reset,
        rx_data     => FF_K2_channel_out(iChan).gtwiz_userdata_rx_out,
        rx_k_data   => FF_K2_channel_out(iChan).rxctrl2_out(3 downto 0),
        tx_data     => FF_K2_channel_in(iChan).gtwiz_userdata_tx_in,
        tx_k_data   => FF_K2_channel_in(iChan).txctrl2_in(3 downto 0),  
        error_rate  => Mon.FF_K2.CHANNEL(iChan).INFO.ERROR_RATE,
        error_count => Mon.FF_K2.CHANNEL(iChan).INFO.ERROR_COUNT);
  end generate FF_K2;


    --FF_K3
  Mon.FF_K3.COMMON.COUNTERS.REFCLK_FREQ <= ref_clk_freq(3);
  FF_K3_wrapper_1: entity work.FF_K3_wrapper
    port map (
      common_in   => FF_K3_common_in,
      common_out  => FF_K3_common_out,
      channel_in  => FF_K3_channel_in,
      channel_out => FF_K3_channel_out);
  rate_counter_6: entity work.rate_counter
    generic map (
      CLK_A_1_SECOND => 50000000)
    port map (
      clk_A         => clk_axi,
      clk_B         => FF_K3_common_out.gtwiz_userclk_rx_usrclk_out,
      reset_A_async => Ctrl.FF_K3.COMMON.RESETS.FULL or Ctrl.FF_K3.COMMON.RESETS.RX_PLL_DATAPATH,
      event_b       => '1',
      rate          => Mon.FF_K3.COMMON.COUNTERS.RX_USER_FREQ);
  rate_counter_7: entity work.rate_counter
    generic map (
      CLK_A_1_SECOND => 50000000)
    port map (
      clk_A         => clk_axi,
      clk_B         => FF_K3_common_out.gtwiz_userclk_tx_usrclk_out,
      reset_A_async => Ctrl.FF_K3.COMMON.RESETS.FULL or Ctrl.FF_K3.COMMON.RESETS.TX_PLL_DATAPATH,
      event_b       => '1',
      rate          => Mon.FF_K3.COMMON.COUNTERS.TX_USER_FREQ);
  FF_K3_common_in.gtwiz_userclk_tx_reset_in      <= (not or_reduce(tx_pma_reset(3))) or Ctrl.FF_K3.COMMON.RESETS.TX_USERCLK;
  FF_K3_common_in.gtwiz_userclk_rx_reset_in      <= (not or_reduce(rx_pma_reset(3))) or Ctrl.FF_K3.COMMON.RESETS.RX_USERCLK;
  FF_K3_common_in.gtwiz_reset_clk_freerun_in     <= Ctrl.FF_K3.COMMON.RESETS.FREERUN;
  FF_K3_common_in.gtwiz_reset_all_in             <= Ctrl.FF_K3.COMMON.RESETS.FULL;
  FF_K3_common_in.gtwiz_reset_tx_pll_and_datapath_in  <= Ctrl.FF_K3.COMMON.RESETS.TX_PLL_DATAPATH;
  FF_K3_common_in.gtwiz_reset_tx_datapath_in      <= Ctrl.FF_K3.COMMON.RESETS.TX_DATAPATH;
  FF_K3_common_in.gtwiz_reset_rx_pll_and_datapath_in <= Ctrl.FF_K3.COMMON.RESETS.RX_PLL_DATAPATH;
  FF_K3_common_in.gtwiz_reset_rx_datapath_in     <= Ctrl.FF_K3.COMMON.RESETS.RX_DATAPATH;  
--  FF_K3: for iChan in FF_K3_channel_in'low to FF_K3_channel_in'high  generate
--    FF_K3: for iChan in 1 to 12  generate
  FF_K3: for iChan in FF_K3_channel_in'RANGE  generate
    
    --DRP interface
    Mon.FF_K3.CHANNEL(iChan).DRP.rd_data        <= FF_K3_channel_out(iChan).drpdo_out;     
    Mon.FF_K3.CHANNEL(iChan).DRP.rd_data_valid  <= FF_K3_channel_out(iChan).drprdy_out;
    FF_K3_channel_in(iChan).drpaddr_in           <= Ctrl.FF_K3.CHANNEL(iChan).DRP.address;
    FF_K3_channel_in(iChan).drpclk_in            <= Ctrl.FF_K3.CHANNEL(iChan).DRP.clk;
    FF_K3_channel_in(iChan).drpdi_in             <= Ctrl.FF_K3.CHANNEL(iChan).DRP.wr_data;
    FF_K3_channel_in(iChan).drpen_in             <= Ctrl.FF_K3.CHANNEL(iChan).DRP.enable or Ctrl.FF_K3.CHANNEL(iChan).DRP.wr_enable;                     
    FF_K3_channel_in(iChan).drprst_in            <= reset;
    FF_K3_channel_in(iChan).drpwe_in             <= Ctrl.FF_K3.CHANNEL(iChan).DRP.wr_enable;
    
    --User
    Mon.FF_K3.CHANNEL(iChan).INFO.TXRX_TYPE          <= FF_K3_channel_out(iChan).TXRX_TYPE;

    --refclk
    FF_K3_channel_in(iChan).gtrefclk0_in      <= ref_clk(3);

    --Other
    Mon.FF_K3.CHANNEL(iChan).INFO.DEBUG.CPLL_LOCK    <= FF_K3_channel_out(iChan).cplllock_out;             
    Mon.FF_K3.CHANNEL(iChan).INFO.DEBUG.DMONITOR     <= FF_K3_channel_out(iChan).dmonitorout_out;          
    Mon.FF_K3.CHANNEL(iChan).INFO.DEBUG.EYESCAN_DATA_ERROR  <= FF_K3_channel_out(iChan).eyescandataerror_out;     
    tx_n(iChan + (12 *2))  <= FF_K3_channel_out(iChan).gthtxn_out;               
    tx_p(iChan + (12 *2))  <= FF_K3_channel_out(iChan).gthtxp_out;               
    Mon.FF_K3.CHANNEL(iChan).INFO.GT_PWR_GOOD  <= FF_K3_channel_out(iChan).gtpowergood_out;         
    Mon.FF_K3.CHANNEL(iChan).INFO.DEBUG.RX.BUF_STATUS  <= FF_K3_channel_out(iChan).rxbufstatus_out;          
    Mon.FF_K3.CHANNEL(iChan).INFO.RX_BYTE_ALIGNED  <= FF_K3_channel_out(iChan).rxbyteisaligned_out;     
    Mon.FF_K3.CHANNEL(iChan).INFO.RX_BYTE_REALIGN  <= FF_K3_channel_out(iChan).rxbyterealign_out;       
    Mon.FF_K3.CHANNEL(iChan).INFO.RX_COMMA_DET  <= FF_K3_channel_out(iChan).rxcommadet_out;          
    Mon.FF_K3.CHANNEL(iChan).INFO.RX_PMA_RESET_DONE <= rx_pma_reset(3)(iChan);
rx_pma_reset(3)(iChan)   <= FF_K3_channel_out(iChan).rxpmaresetdone_out;          
    Mon.FF_K3.CHANNEL(iChan).INFO.DEBUG.RX.PRBS_ERR  <= FF_K3_channel_out(iChan).rxprbserr_out;            
    Mon.FF_K3.CHANNEL(iChan).INFO.DEBUG.RX.RESET_DONE  <= FF_K3_channel_out(iChan).rxresetdone_out;          
    Mon.FF_K3.CHANNEL(iChan).INFO.DEBUG.TX.BUF_STATUS  <= FF_K3_channel_out(iChan).txbufstatus_out;         
    Mon.FF_K3.CHANNEL(iChan).INFO.TX_PMA_RESET_DONE <= tx_pma_reset(3)(iChan);
tx_pma_reset(3)(iChan)   <= FF_K3_channel_out(iChan).txpmaresetdone_out;      
    Mon.FF_K3.CHANNEL(iChan).INFO.DEBUG.TX.RESET_DONE  <= FF_K3_channel_out(iChan).txresetdone_out;          


    FF_K3_channel_in(iChan).loopback_in          <= Ctrl.FF_K3.CHANNEL(iChan).INFO.LOOPBACK;


    FF_K3_channel_in(iChan).eyescanreset_in      <= Ctrl.FF_K3.CHANNEL(iChan).INFO.DEBUG.EYESCAN_RESET;
    FF_K3_channel_in(iChan).eyescantrigger_in    <= Ctrl.FF_K3.CHANNEL(iChan).INFO.DEBUG.EYESCAN_TRIGGER;   
    FF_K3_channel_in(iChan).gthrxn_in            <= rx_n(iChan + (12 *2));
    FF_K3_channel_in(iChan).gthrxp_in            <= rx_p(iChan + (12 *2));
    FF_K3_channel_in(iChan).pcsrsvdin_in         <= Ctrl.FF_K3.CHANNEL(iChan).INFO.DEBUG.PCS_RSV_DIN;  
    FF_K3_channel_in(iChan).rxbufreset_in        <= Ctrl.FF_K3.CHANNEL(iChan).INFO.DEBUG.RX.BUF_RESET;
    FF_K3_channel_in(iChan).rxcdrhold_in         <= Ctrl.FF_K3.CHANNEL(iChan).INFO.DEBUG.RX.CDR_HOLD;
--  FF_K3_channel_in(iChan).rxcommadeten_in      <= Ctrl.FF_K3.CHANNEL(iChan).;
    FF_K3_channel_in(iChan).rxdfelpmreset_in     <= Ctrl.FF_K3.CHANNEL(iChan).INFO.DEBUG.RX.DFE_LPM_RESET;
    FF_K3_channel_in(iChan).rxlpmen_in           <= Ctrl.FF_K3.CHANNEL(iChan).INFO.DEBUG.RX.LPM_EN;
--  FF_K3_channel_in(iChan).rxmcommaalignen_in   <= Ctrl.FF_K3.CHANNEL(iChan).;
--  FF_K3_channel_in(iChan).rxpcommaalignen_in   <= Ctrl.FF_K3.CHANNEL(iChan).;
    FF_K3_channel_in(iChan).rxpcsreset_in        <= Ctrl.FF_K3.CHANNEL(iChan).INFO.DEBUG.RX.PCS_RESET;
    FF_K3_channel_in(iChan).rxpmareset_in        <= Ctrl.FF_K3.CHANNEL(iChan).INFO.DEBUG.RX.PMA_RESET;
    FF_K3_channel_in(iChan).rxprbscntreset_in    <= Ctrl.FF_K3.CHANNEL(iChan).INFO.DEBUG.RX.PRBS_CNT_RST;
    FF_K3_channel_in(iChan).rxprbssel_in         <= Ctrl.FF_K3.CHANNEL(iChan).INFO.DEBUG.RX.PRBS_SEL;
    FF_K3_channel_in(iChan).rxrate_in            <= Ctrl.FF_K3.CHANNEL(iChan).INFO.DEBUG.RX.RATE;
    FF_K3_channel_in(iChan).txdiffctrl_in        <= Ctrl.FF_K3.CHANNEL(iChan).INFO.DEBUG.TX.DIFF_CTRL;
    FF_K3_channel_in(iChan).txinhibit_in         <= Ctrl.FF_K3.CHANNEL(iChan).INFO.DEBUG.TX.INHIBIT;
    FF_K3_channel_in(iChan).txpcsreset_in        <= Ctrl.FF_K3.CHANNEL(iChan).INFO.DEBUG.TX.PCS_RESET;
    FF_K3_channel_in(iChan).txpmareset_in        <= Ctrl.FF_K3.CHANNEL(iChan).INFO.DEBUG.TX.PMA_RESET;
    FF_K3_channel_in(iChan).txpolarity_in        <= Ctrl.FF_K3.CHANNEL(iChan).INFO.DEBUG.TX.POLARITY;
    FF_K3_channel_in(iChan).txpostcursor_in      <= Ctrl.FF_K3.CHANNEL(iChan).INFO.DEBUG.TX.POST_CURSOR;
    FF_K3_channel_in(iChan).txprbsforceerr_in    <= Ctrl.FF_K3.CHANNEL(iChan).INFO.DEBUG.TX.PRBS_FORCE_ERR;
    FF_K3_channel_in(iChan).txprbssel_in         <= Ctrl.FF_K3.CHANNEL(iChan).INFO.DEBUG.TX.PRBS_SEL;  
    FF_K3_channel_in(iChan).txprecursor_in       <= Ctrl.FF_K3.CHANNEL(iChan).INFO.DEBUG.TX.PRE_CURSOR;



    Mon.FF_K3.CHANNEL(iChan).INFO.RX_DATA.DATA <= FF_K3_channel_out(iChan).gtwiz_userdata_rx_out;
    Mon.FF_K3.CHANNEL(iChan).INFO.RX_DATA.K <= FF_K3_channel_out(iChan).rxctrl2_out(3 downto 0);
    Mon.FF_K3.CHANNEL(iChan).INFO.TX_DATA.DATA <= FF_K3_channel_in(iChan).gtwiz_userdata_tx_in;    
    Mon.FF_K3.CHANNEL(iChan).INFO.TX_DATA.K <= FF_K3_channel_in(iChan).txctrl2_in(3 downto 0);  
    
    ChannelTest_1: entity work.ChannelTest
      port map (
        clk         => FF_K3_Common_Out.gtwiz_userclk_rx_usrclk_out,
        clk_axi     => clk_axi,
        reset       => reset,
        rx_data     => FF_K3_channel_out(iChan).gtwiz_userdata_rx_out,
        rx_k_data   => FF_K3_channel_out(iChan).rxctrl2_out(3 downto 0),
        tx_data     => FF_K3_channel_in(iChan).gtwiz_userdata_tx_in,
        tx_k_data   => FF_K3_channel_in(iChan).txctrl2_in(3 downto 0),  
        error_rate  => Mon.FF_K3.CHANNEL(iChan).INFO.ERROR_RATE,
        error_count => Mon.FF_K3.CHANNEL(iChan).INFO.ERROR_COUNT);
  end generate FF_K3;


    --FF_K4
  Mon.FF_K4.COMMON.COUNTERS.REFCLK_FREQ <= ref_clk_freq(4);
  FF_K4_wrapper_1: entity work.FF_K4_wrapper
    port map (
      common_in   => FF_K4_common_in,
      common_out  => FF_K4_common_out,
      channel_in  => FF_K4_channel_in,
      channel_out => FF_K4_channel_out);
  rate_counter_8: entity work.rate_counter
    generic map (
      CLK_A_1_SECOND => 50000000)
    port map (
      clk_A         => clk_axi,
      clk_B         => FF_K4_common_out.gtwiz_userclk_rx_usrclk_out,
      reset_A_async => Ctrl.FF_K4.COMMON.RESETS.FULL or Ctrl.FF_K4.COMMON.RESETS.RX_PLL_DATAPATH,
      event_b       => '1',
      rate          => Mon.FF_K4.COMMON.COUNTERS.RX_USER_FREQ);
  rate_counter_9: entity work.rate_counter
    generic map (
      CLK_A_1_SECOND => 50000000)
    port map (
      clk_A         => clk_axi,
      clk_B         => FF_K4_common_out.gtwiz_userclk_tx_usrclk_out,
      reset_A_async => Ctrl.FF_K4.COMMON.RESETS.FULL or Ctrl.FF_K4.COMMON.RESETS.TX_PLL_DATAPATH,
      event_b       => '1',
      rate          => Mon.FF_K4.COMMON.COUNTERS.TX_USER_FREQ);
  FF_K4_common_in.gtwiz_userclk_tx_reset_in      <= (not or_reduce(tx_pma_reset(4))) or Ctrl.FF_K4.COMMON.RESETS.TX_USERCLK;
  FF_K4_common_in.gtwiz_userclk_rx_reset_in      <= (not or_reduce(rx_pma_reset(4))) or Ctrl.FF_K4.COMMON.RESETS.RX_USERCLK;
  FF_K4_common_in.gtwiz_reset_clk_freerun_in     <= Ctrl.FF_K4.COMMON.RESETS.FREERUN;
  FF_K4_common_in.gtwiz_reset_all_in             <= Ctrl.FF_K4.COMMON.RESETS.FULL;
  FF_K4_common_in.gtwiz_reset_tx_pll_and_datapath_in  <= Ctrl.FF_K4.COMMON.RESETS.TX_PLL_DATAPATH;
  FF_K4_common_in.gtwiz_reset_tx_datapath_in      <= Ctrl.FF_K4.COMMON.RESETS.TX_DATAPATH;
  FF_K4_common_in.gtwiz_reset_rx_pll_and_datapath_in <= Ctrl.FF_K4.COMMON.RESETS.RX_PLL_DATAPATH;
  FF_K4_common_in.gtwiz_reset_rx_datapath_in     <= Ctrl.FF_K4.COMMON.RESETS.RX_DATAPATH;  
--  FF_K4: for iChan in FF_K4_channel_in'low to FF_K4_channel_in'high  generate
--    FF_K4: for iChan in 1 to 12  generate
  FF_K4: for iChan in FF_K4_channel_in'RANGE  generate
    
    --DRP interface
    Mon.FF_K4.CHANNEL(iChan).DRP.rd_data        <= FF_K4_channel_out(iChan).drpdo_out;     
    Mon.FF_K4.CHANNEL(iChan).DRP.rd_data_valid  <= FF_K4_channel_out(iChan).drprdy_out;
    FF_K4_channel_in(iChan).drpaddr_in           <= Ctrl.FF_K4.CHANNEL(iChan).DRP.address;
    FF_K4_channel_in(iChan).drpclk_in            <= Ctrl.FF_K4.CHANNEL(iChan).DRP.clk;
    FF_K4_channel_in(iChan).drpdi_in             <= Ctrl.FF_K4.CHANNEL(iChan).DRP.wr_data;
    FF_K4_channel_in(iChan).drpen_in             <= Ctrl.FF_K4.CHANNEL(iChan).DRP.enable or Ctrl.FF_K4.CHANNEL(iChan).DRP.wr_enable;                     
    FF_K4_channel_in(iChan).drprst_in            <= reset;
    FF_K4_channel_in(iChan).drpwe_in             <= Ctrl.FF_K4.CHANNEL(iChan).DRP.wr_enable;
    
    --User
    Mon.FF_K4.CHANNEL(iChan).INFO.TXRX_TYPE          <= FF_K4_channel_out(iChan).TXRX_TYPE;

    --refclk
    FF_K4_channel_in(iChan).gtrefclk0_in      <= ref_clk(4);

    --Other
    Mon.FF_K4.CHANNEL(iChan).INFO.DEBUG.CPLL_LOCK    <= FF_K4_channel_out(iChan).cplllock_out;             
    Mon.FF_K4.CHANNEL(iChan).INFO.DEBUG.DMONITOR     <= FF_K4_channel_out(iChan).dmonitorout_out;          
    Mon.FF_K4.CHANNEL(iChan).INFO.DEBUG.EYESCAN_DATA_ERROR  <= FF_K4_channel_out(iChan).eyescandataerror_out;     
    tx_n(iChan + (12 *3))  <= FF_K4_channel_out(iChan).gtytxn_out;               
    tx_p(iChan + (12 *3))  <= FF_K4_channel_out(iChan).gtytxp_out;               
    Mon.FF_K4.CHANNEL(iChan).INFO.GT_PWR_GOOD  <= FF_K4_channel_out(iChan).gtpowergood_out;         
    Mon.FF_K4.CHANNEL(iChan).INFO.DEBUG.RX.BUF_STATUS  <= FF_K4_channel_out(iChan).rxbufstatus_out;          
    Mon.FF_K4.CHANNEL(iChan).INFO.RX_BYTE_ALIGNED  <= FF_K4_channel_out(iChan).rxbyteisaligned_out;     
    Mon.FF_K4.CHANNEL(iChan).INFO.RX_BYTE_REALIGN  <= FF_K4_channel_out(iChan).rxbyterealign_out;       
    Mon.FF_K4.CHANNEL(iChan).INFO.RX_COMMA_DET  <= FF_K4_channel_out(iChan).rxcommadet_out;          
    Mon.FF_K4.CHANNEL(iChan).INFO.RX_PMA_RESET_DONE <= rx_pma_reset(4)(iChan);
rx_pma_reset(4)(iChan)   <= FF_K4_channel_out(iChan).rxpmaresetdone_out;          
    Mon.FF_K4.CHANNEL(iChan).INFO.DEBUG.RX.PRBS_ERR  <= FF_K4_channel_out(iChan).rxprbserr_out;            
    Mon.FF_K4.CHANNEL(iChan).INFO.DEBUG.RX.RESET_DONE  <= FF_K4_channel_out(iChan).rxresetdone_out;          
    Mon.FF_K4.CHANNEL(iChan).INFO.DEBUG.TX.BUF_STATUS  <= FF_K4_channel_out(iChan).txbufstatus_out;         
    Mon.FF_K4.CHANNEL(iChan).INFO.TX_PMA_RESET_DONE <= tx_pma_reset(4)(iChan);
tx_pma_reset(4)(iChan)   <= FF_K4_channel_out(iChan).txpmaresetdone_out;      
    Mon.FF_K4.CHANNEL(iChan).INFO.DEBUG.TX.RESET_DONE  <= FF_K4_channel_out(iChan).txresetdone_out;          


    FF_K4_channel_in(iChan).loopback_in          <= Ctrl.FF_K4.CHANNEL(iChan).INFO.LOOPBACK;


    FF_K4_channel_in(iChan).eyescanreset_in      <= Ctrl.FF_K4.CHANNEL(iChan).INFO.DEBUG.EYESCAN_RESET;
    FF_K4_channel_in(iChan).eyescantrigger_in    <= Ctrl.FF_K4.CHANNEL(iChan).INFO.DEBUG.EYESCAN_TRIGGER;   
    FF_K4_channel_in(iChan).gtyrxn_in            <= rx_n(iChan + (12 *3));
    FF_K4_channel_in(iChan).gtyrxp_in            <= rx_p(iChan + (12 *3));
    FF_K4_channel_in(iChan).pcsrsvdin_in         <= Ctrl.FF_K4.CHANNEL(iChan).INFO.DEBUG.PCS_RSV_DIN;  
    FF_K4_channel_in(iChan).rxbufreset_in        <= Ctrl.FF_K4.CHANNEL(iChan).INFO.DEBUG.RX.BUF_RESET;
    FF_K4_channel_in(iChan).rxcdrhold_in         <= Ctrl.FF_K4.CHANNEL(iChan).INFO.DEBUG.RX.CDR_HOLD;
--  FF_K4_channel_in(iChan).rxcommadeten_in      <= Ctrl.FF_K4.CHANNEL(iChan).;
    FF_K4_channel_in(iChan).rxdfelpmreset_in     <= Ctrl.FF_K4.CHANNEL(iChan).INFO.DEBUG.RX.DFE_LPM_RESET;
    FF_K4_channel_in(iChan).rxlpmen_in           <= Ctrl.FF_K4.CHANNEL(iChan).INFO.DEBUG.RX.LPM_EN;
--  FF_K4_channel_in(iChan).rxmcommaalignen_in   <= Ctrl.FF_K4.CHANNEL(iChan).;
--  FF_K4_channel_in(iChan).rxpcommaalignen_in   <= Ctrl.FF_K4.CHANNEL(iChan).;
    FF_K4_channel_in(iChan).rxpcsreset_in        <= Ctrl.FF_K4.CHANNEL(iChan).INFO.DEBUG.RX.PCS_RESET;
    FF_K4_channel_in(iChan).rxpmareset_in        <= Ctrl.FF_K4.CHANNEL(iChan).INFO.DEBUG.RX.PMA_RESET;
    FF_K4_channel_in(iChan).rxprbscntreset_in    <= Ctrl.FF_K4.CHANNEL(iChan).INFO.DEBUG.RX.PRBS_CNT_RST;
    FF_K4_channel_in(iChan).rxprbssel_in         <= Ctrl.FF_K4.CHANNEL(iChan).INFO.DEBUG.RX.PRBS_SEL;
    FF_K4_channel_in(iChan).rxrate_in            <= Ctrl.FF_K4.CHANNEL(iChan).INFO.DEBUG.RX.RATE;
    FF_K4_channel_in(iChan).txdiffctrl_in        <= Ctrl.FF_K4.CHANNEL(iChan).INFO.DEBUG.TX.DIFF_CTRL;
    FF_K4_channel_in(iChan).txinhibit_in         <= Ctrl.FF_K4.CHANNEL(iChan).INFO.DEBUG.TX.INHIBIT;
    FF_K4_channel_in(iChan).txpcsreset_in        <= Ctrl.FF_K4.CHANNEL(iChan).INFO.DEBUG.TX.PCS_RESET;
    FF_K4_channel_in(iChan).txpmareset_in        <= Ctrl.FF_K4.CHANNEL(iChan).INFO.DEBUG.TX.PMA_RESET;
    FF_K4_channel_in(iChan).txpolarity_in        <= Ctrl.FF_K4.CHANNEL(iChan).INFO.DEBUG.TX.POLARITY;
    FF_K4_channel_in(iChan).txpostcursor_in      <= Ctrl.FF_K4.CHANNEL(iChan).INFO.DEBUG.TX.POST_CURSOR;
    FF_K4_channel_in(iChan).txprbsforceerr_in    <= Ctrl.FF_K4.CHANNEL(iChan).INFO.DEBUG.TX.PRBS_FORCE_ERR;
    FF_K4_channel_in(iChan).txprbssel_in         <= Ctrl.FF_K4.CHANNEL(iChan).INFO.DEBUG.TX.PRBS_SEL;  
    FF_K4_channel_in(iChan).txprecursor_in       <= Ctrl.FF_K4.CHANNEL(iChan).INFO.DEBUG.TX.PRE_CURSOR;



    Mon.FF_K4.CHANNEL(iChan).INFO.RX_DATA.DATA <= FF_K4_channel_out(iChan).gtwiz_userdata_rx_out;
    Mon.FF_K4.CHANNEL(iChan).INFO.RX_DATA.K <= FF_K4_channel_out(iChan).rxctrl2_out(3 downto 0);
    Mon.FF_K4.CHANNEL(iChan).INFO.TX_DATA.DATA <= FF_K4_channel_in(iChan).gtwiz_userdata_tx_in;    
    Mon.FF_K4.CHANNEL(iChan).INFO.TX_DATA.K <= FF_K4_channel_in(iChan).txctrl2_in(3 downto 0);  
    
    ChannelTest_1: entity work.ChannelTest
      port map (
        clk         => FF_K4_Common_Out.gtwiz_userclk_rx_usrclk_out,
        clk_axi     => clk_axi,
        reset       => reset,
        rx_data     => FF_K4_channel_out(iChan).gtwiz_userdata_rx_out,
        rx_k_data   => FF_K4_channel_out(iChan).rxctrl2_out(3 downto 0),
        tx_data     => FF_K4_channel_in(iChan).gtwiz_userdata_tx_in,
        tx_k_data   => FF_K4_channel_in(iChan).txctrl2_in(3 downto 0),  
        error_rate  => Mon.FF_K4.CHANNEL(iChan).INFO.ERROR_RATE,
        error_count => Mon.FF_K4.CHANNEL(iChan).INFO.ERROR_COUNT);
  end generate FF_K4;


    --FF_K5
  Mon.FF_K5.COMMON.COUNTERS.REFCLK_FREQ <= ref_clk_freq(5);
  FF_K5_wrapper_1: entity work.FF_K5_wrapper
    port map (
      common_in   => FF_K5_common_in,
      common_out  => FF_K5_common_out,
      channel_in  => FF_K5_channel_in,
      channel_out => FF_K5_channel_out);
  rate_counter_10: entity work.rate_counter
    generic map (
      CLK_A_1_SECOND => 50000000)
    port map (
      clk_A         => clk_axi,
      clk_B         => FF_K5_common_out.gtwiz_userclk_rx_usrclk_out,
      reset_A_async => Ctrl.FF_K5.COMMON.RESETS.FULL or Ctrl.FF_K5.COMMON.RESETS.RX_PLL_DATAPATH,
      event_b       => '1',
      rate          => Mon.FF_K5.COMMON.COUNTERS.RX_USER_FREQ);
  rate_counter_11: entity work.rate_counter
    generic map (
      CLK_A_1_SECOND => 50000000)
    port map (
      clk_A         => clk_axi,
      clk_B         => FF_K5_common_out.gtwiz_userclk_tx_usrclk_out,
      reset_A_async => Ctrl.FF_K5.COMMON.RESETS.FULL or Ctrl.FF_K5.COMMON.RESETS.TX_PLL_DATAPATH,
      event_b       => '1',
      rate          => Mon.FF_K5.COMMON.COUNTERS.TX_USER_FREQ);
  FF_K5_common_in.gtwiz_userclk_tx_reset_in      <= (not or_reduce(tx_pma_reset(5))) or Ctrl.FF_K5.COMMON.RESETS.TX_USERCLK;
  FF_K5_common_in.gtwiz_userclk_rx_reset_in      <= (not or_reduce(rx_pma_reset(5))) or Ctrl.FF_K5.COMMON.RESETS.RX_USERCLK;
  FF_K5_common_in.gtwiz_reset_clk_freerun_in     <= Ctrl.FF_K5.COMMON.RESETS.FREERUN;
  FF_K5_common_in.gtwiz_reset_all_in             <= Ctrl.FF_K5.COMMON.RESETS.FULL;
  FF_K5_common_in.gtwiz_reset_tx_pll_and_datapath_in  <= Ctrl.FF_K5.COMMON.RESETS.TX_PLL_DATAPATH;
  FF_K5_common_in.gtwiz_reset_tx_datapath_in      <= Ctrl.FF_K5.COMMON.RESETS.TX_DATAPATH;
  FF_K5_common_in.gtwiz_reset_rx_pll_and_datapath_in <= Ctrl.FF_K5.COMMON.RESETS.RX_PLL_DATAPATH;
  FF_K5_common_in.gtwiz_reset_rx_datapath_in     <= Ctrl.FF_K5.COMMON.RESETS.RX_DATAPATH;  
--  FF_K5: for iChan in FF_K5_channel_in'low to FF_K5_channel_in'high  generate
--    FF_K5: for iChan in 1 to 12  generate
  FF_K5: for iChan in FF_K5_channel_in'RANGE  generate
    
    --DRP interface
    Mon.FF_K5.CHANNEL(iChan).DRP.rd_data        <= FF_K5_channel_out(iChan).drpdo_out;     
    Mon.FF_K5.CHANNEL(iChan).DRP.rd_data_valid  <= FF_K5_channel_out(iChan).drprdy_out;
    FF_K5_channel_in(iChan).drpaddr_in           <= Ctrl.FF_K5.CHANNEL(iChan).DRP.address;
    FF_K5_channel_in(iChan).drpclk_in            <= Ctrl.FF_K5.CHANNEL(iChan).DRP.clk;
    FF_K5_channel_in(iChan).drpdi_in             <= Ctrl.FF_K5.CHANNEL(iChan).DRP.wr_data;
    FF_K5_channel_in(iChan).drpen_in             <= Ctrl.FF_K5.CHANNEL(iChan).DRP.enable or Ctrl.FF_K5.CHANNEL(iChan).DRP.wr_enable;                     
    FF_K5_channel_in(iChan).drprst_in            <= reset;
    FF_K5_channel_in(iChan).drpwe_in             <= Ctrl.FF_K5.CHANNEL(iChan).DRP.wr_enable;
    
    --User
    Mon.FF_K5.CHANNEL(iChan).INFO.TXRX_TYPE          <= FF_K5_channel_out(iChan).TXRX_TYPE;

    --refclk
    FF_K5_channel_in(iChan).gtrefclk0_in      <= ref_clk(6); --dont' use
                                                                    --5

    --Other
    Mon.FF_K5.CHANNEL(iChan).INFO.DEBUG.CPLL_LOCK    <= FF_K5_channel_out(iChan).cplllock_out;             
    Mon.FF_K5.CHANNEL(iChan).INFO.DEBUG.DMONITOR     <= FF_K5_channel_out(iChan).dmonitorout_out;          
    Mon.FF_K5.CHANNEL(iChan).INFO.DEBUG.EYESCAN_DATA_ERROR  <= FF_K5_channel_out(iChan).eyescandataerror_out;     
    tx_n(iChan + (12 *4))  <= FF_K5_channel_out(iChan).gtytxn_out;               
    tx_p(iChan + (12 *4))  <= FF_K5_channel_out(iChan).gtytxp_out;               
    Mon.FF_K5.CHANNEL(iChan).INFO.GT_PWR_GOOD  <= FF_K5_channel_out(iChan).gtpowergood_out;         
    Mon.FF_K5.CHANNEL(iChan).INFO.DEBUG.RX.BUF_STATUS  <= FF_K5_channel_out(iChan).rxbufstatus_out;          
    Mon.FF_K5.CHANNEL(iChan).INFO.RX_BYTE_ALIGNED  <= FF_K5_channel_out(iChan).rxbyteisaligned_out;     
    Mon.FF_K5.CHANNEL(iChan).INFO.RX_BYTE_REALIGN  <= FF_K5_channel_out(iChan).rxbyterealign_out;       
    Mon.FF_K5.CHANNEL(iChan).INFO.RX_COMMA_DET  <= FF_K5_channel_out(iChan).rxcommadet_out;          
    Mon.FF_K5.CHANNEL(iChan).INFO.RX_PMA_RESET_DONE <= rx_pma_reset(5)(iChan);
rx_pma_reset(5)(iChan)   <= FF_K5_channel_out(iChan).rxpmaresetdone_out;          
    Mon.FF_K5.CHANNEL(iChan).INFO.DEBUG.RX.PRBS_ERR  <= FF_K5_channel_out(iChan).rxprbserr_out;            
    Mon.FF_K5.CHANNEL(iChan).INFO.DEBUG.RX.RESET_DONE  <= FF_K5_channel_out(iChan).rxresetdone_out;          
    Mon.FF_K5.CHANNEL(iChan).INFO.DEBUG.TX.BUF_STATUS  <= FF_K5_channel_out(iChan).txbufstatus_out;         
    Mon.FF_K5.CHANNEL(iChan).INFO.TX_PMA_RESET_DONE <= tx_pma_reset(5)(iChan);
tx_pma_reset(5)(iChan)   <= FF_K5_channel_out(iChan).txpmaresetdone_out;      
    Mon.FF_K5.CHANNEL(iChan).INFO.DEBUG.TX.RESET_DONE  <= FF_K5_channel_out(iChan).txresetdone_out;          


    FF_K5_channel_in(iChan).loopback_in          <= Ctrl.FF_K5.CHANNEL(iChan).INFO.LOOPBACK;


    FF_K5_channel_in(iChan).eyescanreset_in      <= Ctrl.FF_K5.CHANNEL(iChan).INFO.DEBUG.EYESCAN_RESET;
    FF_K5_channel_in(iChan).eyescantrigger_in    <= Ctrl.FF_K5.CHANNEL(iChan).INFO.DEBUG.EYESCAN_TRIGGER;   
    FF_K5_channel_in(iChan).gtyrxn_in            <= rx_n(iChan + (12 *4));
    FF_K5_channel_in(iChan).gtyrxp_in            <= rx_p(iChan + (12 *4));
    FF_K5_channel_in(iChan).pcsrsvdin_in         <= Ctrl.FF_K5.CHANNEL(iChan).INFO.DEBUG.PCS_RSV_DIN;  
    FF_K5_channel_in(iChan).rxbufreset_in        <= Ctrl.FF_K5.CHANNEL(iChan).INFO.DEBUG.RX.BUF_RESET;
    FF_K5_channel_in(iChan).rxcdrhold_in         <= Ctrl.FF_K5.CHANNEL(iChan).INFO.DEBUG.RX.CDR_HOLD;
--  FF_K5_channel_in(iChan).rxcommadeten_in      <= Ctrl.FF_K5.CHANNEL(iChan).;
    FF_K5_channel_in(iChan).rxdfelpmreset_in     <= Ctrl.FF_K5.CHANNEL(iChan).INFO.DEBUG.RX.DFE_LPM_RESET;
    FF_K5_channel_in(iChan).rxlpmen_in           <= Ctrl.FF_K5.CHANNEL(iChan).INFO.DEBUG.RX.LPM_EN;
--  FF_K5_channel_in(iChan).rxmcommaalignen_in   <= Ctrl.FF_K5.CHANNEL(iChan).;
--  FF_K5_channel_in(iChan).rxpcommaalignen_in   <= Ctrl.FF_K5.CHANNEL(iChan).;
    FF_K5_channel_in(iChan).rxpcsreset_in        <= Ctrl.FF_K5.CHANNEL(iChan).INFO.DEBUG.RX.PCS_RESET;
    FF_K5_channel_in(iChan).rxpmareset_in        <= Ctrl.FF_K5.CHANNEL(iChan).INFO.DEBUG.RX.PMA_RESET;
    FF_K5_channel_in(iChan).rxprbscntreset_in    <= Ctrl.FF_K5.CHANNEL(iChan).INFO.DEBUG.RX.PRBS_CNT_RST;
    FF_K5_channel_in(iChan).rxprbssel_in         <= Ctrl.FF_K5.CHANNEL(iChan).INFO.DEBUG.RX.PRBS_SEL;
    FF_K5_channel_in(iChan).rxrate_in            <= Ctrl.FF_K5.CHANNEL(iChan).INFO.DEBUG.RX.RATE;
    FF_K5_channel_in(iChan).txdiffctrl_in        <= Ctrl.FF_K5.CHANNEL(iChan).INFO.DEBUG.TX.DIFF_CTRL;
    FF_K5_channel_in(iChan).txinhibit_in         <= Ctrl.FF_K5.CHANNEL(iChan).INFO.DEBUG.TX.INHIBIT;
    FF_K5_channel_in(iChan).txpcsreset_in        <= Ctrl.FF_K5.CHANNEL(iChan).INFO.DEBUG.TX.PCS_RESET;
    FF_K5_channel_in(iChan).txpmareset_in        <= Ctrl.FF_K5.CHANNEL(iChan).INFO.DEBUG.TX.PMA_RESET;
    FF_K5_channel_in(iChan).txpolarity_in        <= Ctrl.FF_K5.CHANNEL(iChan).INFO.DEBUG.TX.POLARITY;
    FF_K5_channel_in(iChan).txpostcursor_in      <= Ctrl.FF_K5.CHANNEL(iChan).INFO.DEBUG.TX.POST_CURSOR;
    FF_K5_channel_in(iChan).txprbsforceerr_in    <= Ctrl.FF_K5.CHANNEL(iChan).INFO.DEBUG.TX.PRBS_FORCE_ERR;
    FF_K5_channel_in(iChan).txprbssel_in         <= Ctrl.FF_K5.CHANNEL(iChan).INFO.DEBUG.TX.PRBS_SEL;  
    FF_K5_channel_in(iChan).txprecursor_in       <= Ctrl.FF_K5.CHANNEL(iChan).INFO.DEBUG.TX.PRE_CURSOR;



    Mon.FF_K5.CHANNEL(iChan).INFO.RX_DATA.DATA <= FF_K5_channel_out(iChan).gtwiz_userdata_rx_out;
    Mon.FF_K5.CHANNEL(iChan).INFO.RX_DATA.K <= FF_K5_channel_out(iChan).rxctrl2_out(3 downto 0);
    Mon.FF_K5.CHANNEL(iChan).INFO.TX_DATA.DATA <= FF_K5_channel_in(iChan).gtwiz_userdata_tx_in;    
    Mon.FF_K5.CHANNEL(iChan).INFO.TX_DATA.K <= FF_K5_channel_in(iChan).txctrl2_in(3 downto 0);  
    
    ChannelTest_1: entity work.ChannelTest
      port map (
        clk         => FF_K5_Common_Out.gtwiz_userclk_rx_usrclk_out,
        clk_axi     => clk_axi,
        reset       => reset,
        rx_data     => FF_K5_channel_out(iChan).gtwiz_userdata_rx_out,
        rx_k_data   => FF_K5_channel_out(iChan).rxctrl2_out(3 downto 0),
        tx_data     => FF_K5_channel_in(iChan).gtwiz_userdata_tx_in,
        tx_k_data   => FF_K5_channel_in(iChan).txctrl2_in(3 downto 0),  
        error_rate  => Mon.FF_K5.CHANNEL(iChan).INFO.ERROR_RATE,
        error_count => Mon.FF_K5.CHANNEL(iChan).INFO.ERROR_COUNT);
  end generate FF_K5;


    --FF_K6
  Mon.FF_K6.COMMON.COUNTERS.REFCLK_FREQ <= ref_clk_freq(6);
  FF_K6_wrapper_1: entity work.FF_K6_wrapper
    port map (
      common_in   => FF_K6_common_in,
      common_out  => FF_K6_common_out,
      channel_in  => FF_K6_channel_in,
      channel_out => FF_K6_channel_out);
  rate_counter_12: entity work.rate_counter
    generic map (
      CLK_A_1_SECOND => 50000000)
    port map (
      clk_A         => clk_axi,
      clk_B         => FF_K6_common_out.gtwiz_userclk_rx_usrclk_out,
      reset_A_async => Ctrl.FF_K6.COMMON.RESETS.FULL or Ctrl.FF_K6.COMMON.RESETS.RX_PLL_DATAPATH,
      event_b       => '1',
      rate          => Mon.FF_K6.COMMON.COUNTERS.RX_USER_FREQ);
  rate_counter_13: entity work.rate_counter
    generic map (
      CLK_A_1_SECOND => 50000000)
    port map (
      clk_A         => clk_axi,
      clk_B         => FF_K6_common_out.gtwiz_userclk_tx_usrclk_out,
      reset_A_async => Ctrl.FF_K6.COMMON.RESETS.FULL or Ctrl.FF_K6.COMMON.RESETS.TX_PLL_DATAPATH,
      event_b       => '1',
      rate          => Mon.FF_K6.COMMON.COUNTERS.TX_USER_FREQ);
  FF_K6_common_in.gtwiz_userclk_tx_reset_in      <= (not or_reduce(tx_pma_reset(6))) or Ctrl.FF_K6.COMMON.RESETS.TX_USERCLK;
  FF_K6_common_in.gtwiz_userclk_rx_reset_in      <= (not or_reduce(rx_pma_reset(6))) or Ctrl.FF_K6.COMMON.RESETS.RX_USERCLK;
  FF_K6_common_in.gtwiz_reset_clk_freerun_in     <= Ctrl.FF_K6.COMMON.RESETS.FREERUN;
  FF_K6_common_in.gtwiz_reset_all_in             <= Ctrl.FF_K6.COMMON.RESETS.FULL;
  FF_K6_common_in.gtwiz_reset_tx_pll_and_datapath_in  <= Ctrl.FF_K6.COMMON.RESETS.TX_PLL_DATAPATH;
  FF_K6_common_in.gtwiz_reset_tx_datapath_in      <= Ctrl.FF_K6.COMMON.RESETS.TX_DATAPATH;
  FF_K6_common_in.gtwiz_reset_rx_pll_and_datapath_in <= Ctrl.FF_K6.COMMON.RESETS.RX_PLL_DATAPATH;
  FF_K6_common_in.gtwiz_reset_rx_datapath_in     <= Ctrl.FF_K6.COMMON.RESETS.RX_DATAPATH;  
--  FF_K6: for iChan in FF_K6_channel_in'low to FF_K6_channel_in'high  generate
--    FF_K6: for iChan in 1 to 12  generate
  FF_K6: for iChan in FF_K6_channel_in'RANGE  generate
    
    --DRP interface
    Mon.FF_K6.CHANNEL(iChan).DRP.rd_data        <= FF_K6_channel_out(iChan).drpdo_out;     
    Mon.FF_K6.CHANNEL(iChan).DRP.rd_data_valid  <= FF_K6_channel_out(iChan).drprdy_out;
    FF_K6_channel_in(iChan).drpaddr_in           <= Ctrl.FF_K6.CHANNEL(iChan).DRP.address;
    FF_K6_channel_in(iChan).drpclk_in            <= Ctrl.FF_K6.CHANNEL(iChan).DRP.clk;
    FF_K6_channel_in(iChan).drpdi_in             <= Ctrl.FF_K6.CHANNEL(iChan).DRP.wr_data;
    FF_K6_channel_in(iChan).drpen_in             <= Ctrl.FF_K6.CHANNEL(iChan).DRP.enable or Ctrl.FF_K6.CHANNEL(iChan).DRP.wr_enable;                     
    FF_K6_channel_in(iChan).drprst_in            <= reset;
    FF_K6_channel_in(iChan).drpwe_in             <= Ctrl.FF_K6.CHANNEL(iChan).DRP.wr_enable;
    
    --User
    Mon.FF_K6.CHANNEL(iChan).INFO.TXRX_TYPE          <= FF_K6_channel_out(iChan).TXRX_TYPE;

    --refclk
    FF_K6_channel_in(iChan).gtrefclk0_in      <= ref_clk(6);

    --Other
    Mon.FF_K6.CHANNEL(iChan).INFO.DEBUG.CPLL_LOCK    <= FF_K6_channel_out(iChan).cplllock_out;             
    Mon.FF_K6.CHANNEL(iChan).INFO.DEBUG.DMONITOR     <= FF_K6_channel_out(iChan).dmonitorout_out;          
    Mon.FF_K6.CHANNEL(iChan).INFO.DEBUG.EYESCAN_DATA_ERROR  <= FF_K6_channel_out(iChan).eyescandataerror_out;     
    tx_n(iChan + (12 *5))  <= FF_K6_channel_out(iChan).gtytxn_out;               
    tx_p(iChan + (12 *5))  <= FF_K6_channel_out(iChan).gtytxp_out;               
    Mon.FF_K6.CHANNEL(iChan).INFO.GT_PWR_GOOD  <= FF_K6_channel_out(iChan).gtpowergood_out;         
    Mon.FF_K6.CHANNEL(iChan).INFO.DEBUG.RX.BUF_STATUS  <= FF_K6_channel_out(iChan).rxbufstatus_out;          
    Mon.FF_K6.CHANNEL(iChan).INFO.RX_BYTE_ALIGNED  <= FF_K6_channel_out(iChan).rxbyteisaligned_out;     
    Mon.FF_K6.CHANNEL(iChan).INFO.RX_BYTE_REALIGN  <= FF_K6_channel_out(iChan).rxbyterealign_out;       
    Mon.FF_K6.CHANNEL(iChan).INFO.RX_COMMA_DET  <= FF_K6_channel_out(iChan).rxcommadet_out;          
    Mon.FF_K6.CHANNEL(iChan).INFO.RX_PMA_RESET_DONE <= rx_pma_reset(6)(iChan);
rx_pma_reset(6)(iChan)   <= FF_K6_channel_out(iChan).rxpmaresetdone_out;          
    Mon.FF_K6.CHANNEL(iChan).INFO.DEBUG.RX.PRBS_ERR  <= FF_K6_channel_out(iChan).rxprbserr_out;            
    Mon.FF_K6.CHANNEL(iChan).INFO.DEBUG.RX.RESET_DONE  <= FF_K6_channel_out(iChan).rxresetdone_out;          
    Mon.FF_K6.CHANNEL(iChan).INFO.DEBUG.TX.BUF_STATUS  <= FF_K6_channel_out(iChan).txbufstatus_out;         
    Mon.FF_K6.CHANNEL(iChan).INFO.TX_PMA_RESET_DONE <= tx_pma_reset(6)(iChan);
tx_pma_reset(6)(iChan)   <= FF_K6_channel_out(iChan).txpmaresetdone_out;      
    Mon.FF_K6.CHANNEL(iChan).INFO.DEBUG.TX.RESET_DONE  <= FF_K6_channel_out(iChan).txresetdone_out;          


    FF_K6_channel_in(iChan).loopback_in          <= Ctrl.FF_K6.CHANNEL(iChan).INFO.LOOPBACK;


    FF_K6_channel_in(iChan).eyescanreset_in      <= Ctrl.FF_K6.CHANNEL(iChan).INFO.DEBUG.EYESCAN_RESET;
    FF_K6_channel_in(iChan).eyescantrigger_in    <= Ctrl.FF_K6.CHANNEL(iChan).INFO.DEBUG.EYESCAN_TRIGGER;   
    FF_K6_channel_in(iChan).gtyrxn_in            <= rx_n(iChan + (12 *5));
    FF_K6_channel_in(iChan).gtyrxp_in            <= rx_p(iChan + (12 *5));
    FF_K6_channel_in(iChan).pcsrsvdin_in         <= Ctrl.FF_K6.CHANNEL(iChan).INFO.DEBUG.PCS_RSV_DIN;  
    FF_K6_channel_in(iChan).rxbufreset_in        <= Ctrl.FF_K6.CHANNEL(iChan).INFO.DEBUG.RX.BUF_RESET;
    FF_K6_channel_in(iChan).rxcdrhold_in         <= Ctrl.FF_K6.CHANNEL(iChan).INFO.DEBUG.RX.CDR_HOLD;
--  FF_K6_channel_in(iChan).rxcommadeten_in      <= Ctrl.FF_K6.CHANNEL(iChan).;
    FF_K6_channel_in(iChan).rxdfelpmreset_in     <= Ctrl.FF_K6.CHANNEL(iChan).INFO.DEBUG.RX.DFE_LPM_RESET;
    FF_K6_channel_in(iChan).rxlpmen_in           <= Ctrl.FF_K6.CHANNEL(iChan).INFO.DEBUG.RX.LPM_EN;
--  FF_K6_channel_in(iChan).rxmcommaalignen_in   <= Ctrl.FF_K6.CHANNEL(iChan).;
--  FF_K6_channel_in(iChan).rxpcommaalignen_in   <= Ctrl.FF_K6.CHANNEL(iChan).;
    FF_K6_channel_in(iChan).rxpcsreset_in        <= Ctrl.FF_K6.CHANNEL(iChan).INFO.DEBUG.RX.PCS_RESET;
    FF_K6_channel_in(iChan).rxpmareset_in        <= Ctrl.FF_K6.CHANNEL(iChan).INFO.DEBUG.RX.PMA_RESET;
    FF_K6_channel_in(iChan).rxprbscntreset_in    <= Ctrl.FF_K6.CHANNEL(iChan).INFO.DEBUG.RX.PRBS_CNT_RST;
    FF_K6_channel_in(iChan).rxprbssel_in         <= Ctrl.FF_K6.CHANNEL(iChan).INFO.DEBUG.RX.PRBS_SEL;
    FF_K6_channel_in(iChan).rxrate_in            <= Ctrl.FF_K6.CHANNEL(iChan).INFO.DEBUG.RX.RATE;
    FF_K6_channel_in(iChan).txdiffctrl_in        <= Ctrl.FF_K6.CHANNEL(iChan).INFO.DEBUG.TX.DIFF_CTRL;
    FF_K6_channel_in(iChan).txinhibit_in         <= Ctrl.FF_K6.CHANNEL(iChan).INFO.DEBUG.TX.INHIBIT;
    FF_K6_channel_in(iChan).txpcsreset_in        <= Ctrl.FF_K6.CHANNEL(iChan).INFO.DEBUG.TX.PCS_RESET;
    FF_K6_channel_in(iChan).txpmareset_in        <= Ctrl.FF_K6.CHANNEL(iChan).INFO.DEBUG.TX.PMA_RESET;
    FF_K6_channel_in(iChan).txpolarity_in        <= Ctrl.FF_K6.CHANNEL(iChan).INFO.DEBUG.TX.POLARITY;
    FF_K6_channel_in(iChan).txpostcursor_in      <= Ctrl.FF_K6.CHANNEL(iChan).INFO.DEBUG.TX.POST_CURSOR;
    FF_K6_channel_in(iChan).txprbsforceerr_in    <= Ctrl.FF_K6.CHANNEL(iChan).INFO.DEBUG.TX.PRBS_FORCE_ERR;
    FF_K6_channel_in(iChan).txprbssel_in         <= Ctrl.FF_K6.CHANNEL(iChan).INFO.DEBUG.TX.PRBS_SEL;  
    FF_K6_channel_in(iChan).txprecursor_in       <= Ctrl.FF_K6.CHANNEL(iChan).INFO.DEBUG.TX.PRE_CURSOR;



    Mon.FF_K6.CHANNEL(iChan).INFO.RX_DATA.DATA <= FF_K6_channel_out(iChan).gtwiz_userdata_rx_out;
    Mon.FF_K6.CHANNEL(iChan).INFO.RX_DATA.K <= FF_K6_channel_out(iChan).rxctrl2_out(3 downto 0);
    Mon.FF_K6.CHANNEL(iChan).INFO.TX_DATA.DATA <= FF_K6_channel_in(iChan).gtwiz_userdata_tx_in;    
    Mon.FF_K6.CHANNEL(iChan).INFO.TX_DATA.K <= FF_K6_channel_in(iChan).txctrl2_in(3 downto 0);  
    
    ChannelTest_1: entity work.ChannelTest
      port map (
        clk         => FF_K6_Common_Out.gtwiz_userclk_rx_usrclk_out,
        clk_axi     => clk_axi,
        reset       => reset,
        rx_data     => FF_K6_channel_out(iChan).gtwiz_userdata_rx_out,
        rx_k_data   => FF_K6_channel_out(iChan).rxctrl2_out(3 downto 0),
        tx_data     => FF_K6_channel_in(iChan).gtwiz_userdata_tx_in,
        tx_k_data   => FF_K6_channel_in(iChan).txctrl2_in(3 downto 0),  
        error_rate  => Mon.FF_K6.CHANNEL(iChan).INFO.ERROR_RATE,
        error_count => Mon.FF_K6.CHANNEL(iChan).INFO.ERROR_COUNT);
  end generate FF_K6;

    --FF_K7
  Mon.FF_K7.COMMON.COUNTERS.REFCLK_FREQ <= ref_clk_freq(7);
  FF_K7_wrapper_1: entity work.FF_K7_wrapper
    port map (
      common_in   => FF_K7_common_in,
      common_out  => FF_K7_common_out,
      channel_in  => FF_K7_channel_in,
      channel_out => FF_K7_channel_out);
  rate_counter_14: entity work.rate_counter
    generic map (
      CLK_A_1_SECOND => 50000000)
    port map (
      clk_A         => clk_axi,
      clk_B         => FF_K7_common_out.gtwiz_userclk_rx_usrclk_out,
      reset_A_async => Ctrl.FF_K7.COMMON.RESETS.FULL or Ctrl.FF_K7.COMMON.RESETS.RX_PLL_DATAPATH,
      event_b       => '1',
      rate          => Mon.FF_K7.COMMON.COUNTERS.RX_USER_FREQ);
  rate_counter_15: entity work.rate_counter
    generic map (
      CLK_A_1_SECOND => 50000000)
    port map (
      clk_A         => clk_axi,
      clk_B         => FF_K7_common_out.gtwiz_userclk_tx_usrclk_out,
      reset_A_async => Ctrl.FF_K7.COMMON.RESETS.FULL or Ctrl.FF_K7.COMMON.RESETS.TX_PLL_DATAPATH,
      event_b       => '1',
      rate          => Mon.FF_K7.COMMON.COUNTERS.TX_USER_FREQ);
  FF_K7_common_in.gtwiz_userclk_tx_reset_in      <= (not or_reduce(tx_pma_reset(7))) or Ctrl.FF_K7.COMMON.RESETS.TX_USERCLK;
  FF_K7_common_in.gtwiz_userclk_rx_reset_in      <= (not or_reduce(rx_pma_reset(7))) or Ctrl.FF_K7.COMMON.RESETS.RX_USERCLK;
  FF_K7_common_in.gtwiz_reset_clk_freerun_in     <= Ctrl.FF_K7.COMMON.RESETS.FREERUN;
  FF_K7_common_in.gtwiz_reset_all_in             <= Ctrl.FF_K7.COMMON.RESETS.FULL;
  FF_K7_common_in.gtwiz_reset_tx_pll_and_datapath_in  <= Ctrl.FF_K7.COMMON.RESETS.TX_PLL_DATAPATH;
  FF_K7_common_in.gtwiz_reset_tx_datapath_in      <= Ctrl.FF_K7.COMMON.RESETS.TX_DATAPATH;
  FF_K7_common_in.gtwiz_reset_rx_pll_and_datapath_in <= Ctrl.FF_K7.COMMON.RESETS.RX_PLL_DATAPATH;
  FF_K7_common_in.gtwiz_reset_rx_datapath_in     <= Ctrl.FF_K7.COMMON.RESETS.RX_DATAPATH;  
--  FF_K7: for iChan in FF_K7_channel_in'low to FF_K7_channel_in'high  generate
--    FF_K7: for iChan in 1 to 12  generate
  FF_K7: for iChan in FF_K7_channel_in'RANGE  generate
    
    --DRP interface
    Mon.FF_K7.CHANNEL(iChan).DRP.rd_data        <= FF_K7_channel_out(iChan).drpdo_out;     
    Mon.FF_K7.CHANNEL(iChan).DRP.rd_data_valid  <= FF_K7_channel_out(iChan).drprdy_out;
    FF_K7_channel_in(iChan).drpaddr_in           <= Ctrl.FF_K7.CHANNEL(iChan).DRP.address;
    FF_K7_channel_in(iChan).drpclk_in            <= Ctrl.FF_K7.CHANNEL(iChan).DRP.clk;
    FF_K7_channel_in(iChan).drpdi_in             <= Ctrl.FF_K7.CHANNEL(iChan).DRP.wr_data;
    FF_K7_channel_in(iChan).drpen_in             <= Ctrl.FF_K7.CHANNEL(iChan).DRP.enable or Ctrl.FF_K7.CHANNEL(iChan).DRP.wr_enable;                     
    FF_K7_channel_in(iChan).drprst_in            <= reset;
    FF_K7_channel_in(iChan).drpwe_in             <= Ctrl.FF_K7.CHANNEL(iChan).DRP.wr_enable;
    
    --User
    Mon.FF_K7.CHANNEL(iChan).INFO.TXRX_TYPE          <= FF_K7_channel_out(iChan).TXRX_TYPE;

    --refclk
    FF_K7_channel_in(iChan).gtrefclk0_in      <= ref_clk(7);

    --Other
    Mon.FF_K7.CHANNEL(iChan).INFO.DEBUG.CPLL_LOCK    <= FF_K7_channel_out(iChan).cplllock_out;             
    Mon.FF_K7.CHANNEL(iChan).INFO.DEBUG.DMONITOR     <= FF_K7_channel_out(iChan).dmonitorout_out;          
    Mon.FF_K7.CHANNEL(iChan).INFO.DEBUG.EYESCAN_DATA_ERROR  <= FF_K7_channel_out(iChan).eyescandataerror_out;     
    tx_n(iChan + (12 *6))  <= FF_K7_channel_out(iChan).gtytxn_out;               
    tx_p(iChan + (12 *6))  <= FF_K7_channel_out(iChan).gtytxp_out;               
    Mon.FF_K7.CHANNEL(iChan).INFO.GT_PWR_GOOD  <= FF_K7_channel_out(iChan).gtpowergood_out;         
    Mon.FF_K7.CHANNEL(iChan).INFO.DEBUG.RX.BUF_STATUS  <= FF_K7_channel_out(iChan).rxbufstatus_out;          
    Mon.FF_K7.CHANNEL(iChan).INFO.RX_BYTE_ALIGNED  <= FF_K7_channel_out(iChan).rxbyteisaligned_out;     
    Mon.FF_K7.CHANNEL(iChan).INFO.RX_BYTE_REALIGN  <= FF_K7_channel_out(iChan).rxbyterealign_out;       
    Mon.FF_K7.CHANNEL(iChan).INFO.RX_COMMA_DET  <= FF_K7_channel_out(iChan).rxcommadet_out;          
    Mon.FF_K7.CHANNEL(iChan).INFO.RX_PMA_RESET_DONE <= rx_pma_reset(7)(iChan);
    rx_pma_reset(7)(iChan)   <= FF_K7_channel_out(iChan).rxpmaresetdone_out;          
    Mon.FF_K7.CHANNEL(iChan).INFO.DEBUG.RX.PRBS_ERR  <= FF_K7_channel_out(iChan).rxprbserr_out;            
    Mon.FF_K7.CHANNEL(iChan).INFO.DEBUG.RX.RESET_DONE  <= FF_K7_channel_out(iChan).rxresetdone_out;          
    Mon.FF_K7.CHANNEL(iChan).INFO.DEBUG.TX.BUF_STATUS  <= FF_K7_channel_out(iChan).txbufstatus_out;         
    Mon.FF_K7.CHANNEL(iChan).INFO.TX_PMA_RESET_DONE <= tx_pma_reset(7)(iChan);
tx_pma_reset(7)(iChan)   <= FF_K7_channel_out(iChan).txpmaresetdone_out;      
    Mon.FF_K7.CHANNEL(iChan).INFO.DEBUG.TX.RESET_DONE  <= FF_K7_channel_out(iChan).txresetdone_out;          


    FF_K7_channel_in(iChan).loopback_in          <= Ctrl.FF_K7.CHANNEL(iChan).INFO.LOOPBACK;


    FF_K7_channel_in(iChan).eyescanreset_in      <= Ctrl.FF_K7.CHANNEL(iChan).INFO.DEBUG.EYESCAN_RESET;
    FF_K7_channel_in(iChan).eyescantrigger_in    <= Ctrl.FF_K7.CHANNEL(iChan).INFO.DEBUG.EYESCAN_TRIGGER;   
    FF_K7_channel_in(iChan).gtyrxn_in            <= rx_n(iChan + (12 *6));
    FF_K7_channel_in(iChan).gtyrxp_in            <= rx_p(iChan + (12 *6));
    FF_K7_channel_in(iChan).pcsrsvdin_in         <= Ctrl.FF_K7.CHANNEL(iChan).INFO.DEBUG.PCS_RSV_DIN;  
    FF_K7_channel_in(iChan).rxbufreset_in        <= Ctrl.FF_K7.CHANNEL(iChan).INFO.DEBUG.RX.BUF_RESET;
    FF_K7_channel_in(iChan).rxcdrhold_in         <= Ctrl.FF_K7.CHANNEL(iChan).INFO.DEBUG.RX.CDR_HOLD;
--  FF_K7_channel_in(iChan).rxcommadeten_in      <= Ctrl.FF_K7.CHANNEL(iChan).;
    FF_K7_channel_in(iChan).rxdfelpmreset_in     <= Ctrl.FF_K7.CHANNEL(iChan).INFO.DEBUG.RX.DFE_LPM_RESET;
    FF_K7_channel_in(iChan).rxlpmen_in           <= Ctrl.FF_K7.CHANNEL(iChan).INFO.DEBUG.RX.LPM_EN;
--  FF_K7_channel_in(iChan).rxmcommaalignen_in   <= Ctrl.FF_K7.CHANNEL(iChan).;
--  FF_K7_channel_in(iChan).rxpcommaalignen_in   <= Ctrl.FF_K7.CHANNEL(iChan).;
    FF_K7_channel_in(iChan).rxpcsreset_in        <= Ctrl.FF_K7.CHANNEL(iChan).INFO.DEBUG.RX.PCS_RESET;
    FF_K7_channel_in(iChan).rxpmareset_in        <= Ctrl.FF_K7.CHANNEL(iChan).INFO.DEBUG.RX.PMA_RESET;
    FF_K7_channel_in(iChan).rxprbscntreset_in    <= Ctrl.FF_K7.CHANNEL(iChan).INFO.DEBUG.RX.PRBS_CNT_RST;
    FF_K7_channel_in(iChan).rxprbssel_in         <= Ctrl.FF_K7.CHANNEL(iChan).INFO.DEBUG.RX.PRBS_SEL;
    FF_K7_channel_in(iChan).rxrate_in            <= Ctrl.FF_K7.CHANNEL(iChan).INFO.DEBUG.RX.RATE;
    FF_K7_channel_in(iChan).txdiffctrl_in        <= Ctrl.FF_K7.CHANNEL(iChan).INFO.DEBUG.TX.DIFF_CTRL;
    FF_K7_channel_in(iChan).txinhibit_in         <= Ctrl.FF_K7.CHANNEL(iChan).INFO.DEBUG.TX.INHIBIT;
    FF_K7_channel_in(iChan).txpcsreset_in        <= Ctrl.FF_K7.CHANNEL(iChan).INFO.DEBUG.TX.PCS_RESET;
    FF_K7_channel_in(iChan).txpmareset_in        <= Ctrl.FF_K7.CHANNEL(iChan).INFO.DEBUG.TX.PMA_RESET;
    FF_K7_channel_in(iChan).txpolarity_in        <= Ctrl.FF_K7.CHANNEL(iChan).INFO.DEBUG.TX.POLARITY;
    FF_K7_channel_in(iChan).txpostcursor_in      <= Ctrl.FF_K7.CHANNEL(iChan).INFO.DEBUG.TX.POST_CURSOR;
    FF_K7_channel_in(iChan).txprbsforceerr_in    <= Ctrl.FF_K7.CHANNEL(iChan).INFO.DEBUG.TX.PRBS_FORCE_ERR;
    FF_K7_channel_in(iChan).txprbssel_in         <= Ctrl.FF_K7.CHANNEL(iChan).INFO.DEBUG.TX.PRBS_SEL;  
    FF_K7_channel_in(iChan).txprecursor_in       <= Ctrl.FF_K7.CHANNEL(iChan).INFO.DEBUG.TX.PRE_CURSOR;



    Mon.FF_K7.CHANNEL(iChan).INFO.RX_DATA.DATA <= FF_K7_channel_out(iChan).gtwiz_userdata_rx_out;
    Mon.FF_K7.CHANNEL(iChan).INFO.RX_DATA.K <= FF_K7_channel_out(iChan).rxctrl2_out(3 downto 0);
    Mon.FF_K7.CHANNEL(iChan).INFO.TX_DATA.DATA <= FF_K7_channel_in(iChan).gtwiz_userdata_tx_in;    
    Mon.FF_K7.CHANNEL(iChan).INFO.TX_DATA.K <= FF_K7_channel_in(iChan).txctrl2_in(3 downto 0);  
    
    ChannelTest_1: entity work.ChannelTest
      port map (
        clk         => FF_K7_Common_Out.gtwiz_userclk_rx_usrclk_out,
        clk_axi     => clk_axi,
        reset       => reset,
        rx_data     => FF_K7_channel_out(iChan).gtwiz_userdata_rx_out,
        rx_k_data   => FF_K7_channel_out(iChan).rxctrl2_out(3 downto 0),
        tx_data     => FF_K7_channel_in(iChan).gtwiz_userdata_tx_in,
        tx_k_data   => FF_K7_channel_in(iChan).txctrl2_in(3 downto 0),  
        error_rate  => Mon.FF_K7.CHANNEL(iChan).INFO.ERROR_RATE,
        error_count => Mon.FF_K7.CHANNEL(iChan).INFO.ERROR_COUNT);
  end generate FF_K7;

end architecture behavioral;
