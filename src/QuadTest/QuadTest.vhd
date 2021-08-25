library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.axiRegPkg.all;
use work.Quad_Test_Ctrl.all;
use work.types.all;

Library UNISIM;
use UNISIM.vcomponents.all;

use work.FF_K1_PKG.all;

entity QuadTest is
  port (
    clk_axi              : in  std_logic; --50 MHz
    reset_axi_n          : in  std_logic;
    readMOSI             : in  AXIreadMOSI;
    readMISO             : out AXIreadMISO;
    writeMOSI            : in  AXIwriteMOSI;
    writeMISO            : out AXIwriteMISO); -- '0' for refclk0, '1' for refclk1

end entity QuadTest;

architecture behavioral of QuadTest is

  signal FF_K1_common_in : FF_K1_CommonIn;                        
  signal FF_K1_common_out : FF_K1_CommonOut;                       
  signal FF_K1_channel_in : FF_K1_ChannelIn_array_t(12 downto 1);  
  signal FF_K1_channel_out : FF_K1_ChannelOut_array_t(12 downto 1);
  signal reset             : std_logic;
  signal Mon               : QUAD_TEST_Mon_t;
  signal Ctrl              : QUAD_TEST_Ctrl_t;
  signal tx_n              : std_logic_vector(12 downto 1);
  signal tx_p              : std_logic_vector(12 downto 1);
  signal rx_n              : std_logic_vector(12 downto 1);
  signal rx_p              : std_logic_vector(12 downto 1);
    
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

  FF_K1_wrapper_1: entity work.FF_K1_wrapper
    port map (
      common_in   => FF_K1_common_in,
      common_out  => FF_K1_common_out,
      channel_in  => FF_K1_channel_in,
      channel_out => FF_K1_channel_out);


  FF_K1_common_in.gtwiz_userclk_tx_reset_in      <= '0';
  FF_K1_common_in.gtwiz_userclk_rx_reset_in      <= '0';
  FF_K1_common_in.gtwiz_reset_clk_freerun_in     <= '0';
  FF_K1_common_in.gtwiz_reset_all_in             <= '0';
  FF_K1_common_in.gtwiz_reset_tx_pll_and_datapath_in  <= '0';
  FF_K1_common_in.gtwiz_reset_tx_datapath_in      <= '0';
  FF_K1_common_in.gtwiz_reset_rx_pll_and_datapath_in <= '0';
  FF_K1_common_in.gtwiz_reset_rx_datapath_in     <= '0';

  FF_K1: for iChan in FF_K1_channel_in'low to FF_K1_channel_in'high  generate
    


    Mon.FF_K1.CHANNEL(iChan).DRP.rd_data        <= FF_K1_channel_out(iChan).drpdo_out;     
    Mon.FF_K1.CHANNEL(iChan).DRP.rd_data_valid  <= FF_K1_channel_out(iChan).drprdy_out;
    Mon.FF_K1.CHANNEL(iChan).INFO.TXRX_TYPE          <= FF_K1_channel_out(iChan).TXRX_TYPE;

    Mon.FF_K1.CHANNEL(iChan).INFO.DEBUG.CPLL_LOCK    <= FF_K1_channel_out(iChan).cplllock_out;             
    Mon.FF_K1.CHANNEL(iChan).INFO.DEBUG.DMONITOR     <= FF_K1_channel_out(iChan).dmonitorout_out;          
    Mon.FF_K1.CHANNEL(iChan).INFO.DEBUG.EYESCAN_DATA_ERROR  <= FF_K1_channel_out(iChan).eyescandataerror_out;     
    tx_n(iChan)  <= FF_K1_channel_out(iChan).gthtxn_out;               
    tx_p(iChan)  <= FF_K1_channel_out(iChan).gthtxp_out;               
--    Mon.FF_K1.CHANNEL(iChan).  <= FF_K1_channel_out(iChan).gtpowergood_out          
    Mon.FF_K1.CHANNEL(iChan).INFO.DEBUG.RX.BUF_STATUS  <= FF_K1_channel_out(iChan).rxbufstatus_out;          
--    Mon.FF_K1.CHANNEL(iChan).  <= FF_K1_channel_out(iChan).rxbyteisaligned_out      
--    Mon.FF_K1.CHANNEL(iChan).  <= FF_K1_channel_out(iChan).rxbyterealign_out        
--    Mon.FF_K1.CHANNEL(iChan).  <= FF_K1_channel_out(iChan).rxcommadet_out           
--    Mon.FF_K1.CHANNEL(iChan).  <= FF_K1_channel_out(iChan).rxpmaresetdone_out           
    Mon.FF_K1.CHANNEL(iChan).INFO.DEBUG.RX.PRBS_ERR  <= FF_K1_channel_out(iChan).rxprbserr_out;            
    Mon.FF_K1.CHANNEL(iChan).INFO.DEBUG.RX.RESET_DONE  <= FF_K1_channel_out(iChan).rxresetdone_out;          
    Mon.FF_K1.CHANNEL(iChan).INFO.DEBUG.TX.BUF_STATUS  <= FF_K1_channel_out(iChan).txbufstatus_out;          
--    Mon.FF_K1.CHANNEL(iChan).  <= FF_K1_channel_out(iChan).txpmaresetdone_out       
    Mon.FF_K1.CHANNEL(iChan).INFO.DEBUG.TX.RESET_DONE  <= FF_K1_channel_out(iChan).txresetdone_out;          





    FF_K1_channel_in(iChan).drpaddr_in           <= Ctrl.FF_K1.CHANNEL(iChan).DRP.address;
    FF_K1_channel_in(iChan).drpclk_in            <= Ctrl.FF_K1.CHANNEL(iChan).DRP.clk;                    
    FF_K1_channel_in(iChan).drpdi_in             <= Ctrl.FF_K1.CHANNEL(iChan).DRP.wr_data;                     
    FF_K1_channel_in(iChan).drpen_in             <= Ctrl.FF_K1.CHANNEL(iChan).DRP.enable;                     
    FF_K1_channel_in(iChan).drprst_in            <= reset;
    FF_K1_channel_in(iChan).drpwe_in             <= Ctrl.FF_K1.CHANNEL(iChan).DRP.wr_enable;                     
    FF_K1_channel_in(iChan).eyescanreset_in      <= Ctrl.FF_K1.CHANNEL(iChan).INFO.DEBUG.EYESCAN_RESET;
    FF_K1_channel_in(iChan).eyescantrigger_in    <= Ctrl.FF_K1.CHANNEL(iChan).INFO.DEBUG.EYESCAN_TRIGGER;   
    FF_K1_channel_in(iChan).gthrxn_in            <= rx_n(iChan);
    FF_K1_channel_in(iChan).gthrxp_in            <= rx_p(iChan);
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

    
    ChannelTest_1: entity work.ChannelTest
      port map (
        clk         => FF_K1_Common_Out.gtwiz_userclk_rx_usrclk_out,
        clk_axi     => clk_axi,
        reset       => reset,
        rx_data     => FF_K1_channel_out(iChan).gtwiz_userdata_rx_out,
        rx_k_data   => FF_K1_channel_out(iChan).rxctrl2_out(3 downto 0),
        tx_data     => FF_K1_channel_in(iChan).gtwiz_userdata_tx_in,
        tx_k_data   => FF_K1_channel_in(iChan).txctrl2_in(3 downto 0),
        error_count => open);
  end generate FF_K1;
  
end architecture behavioral;
