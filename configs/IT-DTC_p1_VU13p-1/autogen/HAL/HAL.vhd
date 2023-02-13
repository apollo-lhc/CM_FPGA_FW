library ieee;
use ieee.std_logic_1164.all;

use work.axiRegPkg.all;
use work.hal_pkg.all;


use work.DEBUG_8B10B_PKG.all;
use work.DEBUG_8B10B_Ctrl.all;
Library UNISIM;
use UNISIM.vcomponents.all;


entity HAL is
  generic (
                DEBUG_8B10B_MEMORY_RANGE : integer);
  port (
                                 clk_axi : in  std_logic;
                             reset_axi_n : in  std_logic;
                                readMOSI : in  AXIreadMOSI_array_t (1 - 1 downto 0);
                                readMISO : out AXIreadMISO_array_t (1 - 1 downto 0);
                               writeMOSI : in  AXIwriteMOSI_array_t(1 - 1 downto 0);
                               writeMISO : out AXIwriteMISO_array_t(1 - 1 downto 0);
                             HAL_refclks : in  HAL_refclks_t;
                        HAL_serdes_input : in  HAL_serdes_input_t;
                       HAL_serdes_output : out HAL_serdes_output_t;
              DEBUG_8B10B_userdata_input : in  DEBUG_8B10B_userdata_input_array_t(  4-1 downto 0);
             DEBUG_8B10B_userdata_output : out DEBUG_8B10B_userdata_output_array_t(  4-1 downto 0);
               DEBUG_8B10B_clocks_output : out DEBUG_8B10B_clocks_output_array_t(  4-1 downto 0));
end entity HAL;


architecture behavioral of HAL is
  signal                          refclk_126_clk0 : std_logic;
  signal                        refclk_126_clk0_2 : std_logic;
  signal                    buf_refclk_126_clk0_2 : std_logic;

  signal                            freq_126_clk0 : std_logic_vector(31 downto 0);
  signal                 DEBUG_8B10B_common_input : DEBUG_8B10B_common_input_array_t(4-1 downto 0);
  signal                DEBUG_8B10B_common_output : DEBUG_8B10B_common_output_array_t(4-1 downto 0);
  signal                 DEBUG_8B10B_clocks_input : DEBUG_8B10B_clocks_input_array_t(4-1 downto 0);
  signal                    DEBUG_8B10B_drp_input : DEBUG_8B10B_drp_input_array_t(4-1 downto 0);
  signal                   DEBUG_8B10B_drp_output : DEBUG_8B10B_drp_output_array_t(4-1 downto 0);
  signal                DEBUG_8B10B_channel_input : DEBUG_8B10B_channel_input_array_t(4-1 downto 0);
  signal               DEBUG_8B10B_channel_output : DEBUG_8B10B_channel_output_array_t(4-1 downto 0);


  signal                         Ctrl_DEBUG_8B10B : DEBUG_8B10B_Ctrl_t;
  signal                          Mon_DEBUG_8B10B : DEBUG_8B10B_Mon_t;
begin
  ibufds_126_clk0 : ibufds_gte4
    generic map (
      REFCLK_EN_TX_PATH  => '0',
      REFCLK_HROW_CK_SEL => "00",
      REFCLK_ICNTL_RX    => "00")
    port map (
      O     => refclk_126_clk0,
      ODIV2 => refclk_126_clk0_2,
      CEB   => '0',
      I     => HAL_refclks.refclk_126_clk0_P,
      IB    => HAL_refclks.refclk_126_clk0_N
      );
      

--------------------------------------------------------------------------------
--DEBUG_8B10B
--------------------------------------------------------------------------------
DEBUG_8B10B_map_1: entity work.DEBUG_8B10B_map
  generic map (
    ALLOCATED_MEMORY_RANGE => DEBUG_8B10B_MEMORY_RANGE)
  port map (
    clk_axi         => clk_axi,
    reset_axi_n     => reset_axi_n,
    slave_readMOSI  => readMOSI(0),
    slave_readMISO  => readMISO(0),
    slave_writeMOSI => writeMOSI(0),
    slave_writeMISO => writeMISO(0),
    Mon             => Mon_DEBUG_8B10B,
    Ctrl            => Ctrl_DEBUG_8B10B);
  BUFG_GT_inst_126_clk0 : BUFG_GT
  port map (
  	      O => buf_refclk_126_clk0_2,
  	      CE => '1',
  	      CEMASK => '1',
  	      CLR => '0',
  	      CLRMASK => '1', 
  	      DIV => "000",
  	      I => refclk_126_clk0_2
        );
    rate_counter_126_clk0: entity work.rate_counter
      generic map (
        CLK_A_1_SECOND => 50000000)
      port map (
        clk_A         => clk_axi,
        clk_B         => buf_refclk_126_clk0_2,
        reset_A_async => not reset_axi_n,
        event_b       => '1',
        rate          => freq_126_clk0);            
    Mon_DEBUG_8B10B.REFCLK.freq_126_clk0 <= freq_126_clk0;
  QUAD_GTH_126_DEBUG_8B10B_inst : entity work.QUAD_GTH_126_DEBUG_8B10B_wrapper
    port map (
                                            gtyrxn => HAL_serdes_input.QUAD_GTH_126_DEBUG_8B10B_gtyrxn,
                                            gtyrxp => HAL_serdes_input.QUAD_GTH_126_DEBUG_8B10B_gtyrxp,
                                            gtytxn => HAL_serdes_output.QUAD_GTH_126_DEBUG_8B10B_gtytxn,
                                            gtytxp => HAL_serdes_output.QUAD_GTH_126_DEBUG_8B10B_gtytxp,
                                      common_input => DEBUG_8B10B_common_input(  0),
                                     common_output => DEBUG_8B10B_common_output(  0),
                                    userdata_input => DEBUG_8B10B_userdata_input(  3 downto   0),
                                   userdata_output => DEBUG_8B10B_userdata_output(  3 downto   0),
                                      clocks_input => DEBUG_8B10B_clocks_input(  0),
                                     clocks_output => DEBUG_8B10B_clocks_output(  0),
                                         drp_input => DEBUG_8B10B_drp_input(  3 downto   0),
                                        drp_output => DEBUG_8B10B_drp_output(  3 downto   0),
                                     channel_input => DEBUG_8B10B_channel_input(  3 downto   0),
                                    channel_output => DEBUG_8B10B_channel_output(  3 downto   0)
    );


    DEBUG_8B10B_clocks_input(0).gtrefclk00(0) <= refclk_126_clk0;

   DEBUG_8B10B_common_input(0).gtwiz_userclk_tx_reset(0)                  <= Ctrl_DEBUG_8B10B.common(0).gtwiz_userclk_tx_reset;
   DEBUG_8B10B_common_input(0).gtwiz_userclk_rx_reset(0)                  <= Ctrl_DEBUG_8B10B.common(0).gtwiz_userclk_rx_reset;
   DEBUG_8B10B_common_input(0).gtwiz_reset_clk_freerun(0)                 <= Ctrl_DEBUG_8B10B.common(0).gtwiz_reset_clk_freerun;
   DEBUG_8B10B_common_input(0).gtwiz_reset_all(0)                         <= Ctrl_DEBUG_8B10B.common(0).gtwiz_reset_all;
   DEBUG_8B10B_common_input(0).gtwiz_reset_tx_pll_and_datapath(0)         <= Ctrl_DEBUG_8B10B.common(0).gtwiz_reset_tx_pll_and_datapath;
   DEBUG_8B10B_common_input(0).gtwiz_reset_tx_datapath(0)                 <= Ctrl_DEBUG_8B10B.common(0).gtwiz_reset_tx_datapath;
   DEBUG_8B10B_common_input(0).gtwiz_reset_rx_pll_and_datapath(0)         <= Ctrl_DEBUG_8B10B.common(0).gtwiz_reset_rx_pll_and_datapath;
   DEBUG_8B10B_common_input(0).gtwiz_reset_rx_datapath(0)                 <= Ctrl_DEBUG_8B10B.common(0).gtwiz_reset_rx_datapath;
   Mon_DEBUG_8B10B.common(0).gtwiz_userclk_tx_active                      <= DEBUG_8B10B_common_output(0).gtwiz_userclk_tx_active(0);
   Mon_DEBUG_8B10B.common(0).gtwiz_userclk_rx_active                      <= DEBUG_8B10B_common_output(0).gtwiz_userclk_rx_active(0);
   Mon_DEBUG_8B10B.common(0).gtwiz_reset_rx_cdr_stable                    <= DEBUG_8B10B_common_output(0).gtwiz_reset_rx_cdr_stable(0);
   Mon_DEBUG_8B10B.common(0).gtwiz_reset_tx_done                          <= DEBUG_8B10B_common_output(0).gtwiz_reset_tx_done(0);
   Mon_DEBUG_8B10B.common(0).gtwiz_reset_rx_done                          <= DEBUG_8B10B_common_output(0).gtwiz_reset_rx_done(0);
   DEBUG_8B10B_channel_input(0).eyescanreset(0)                           <= Ctrl_DEBUG_8B10B.channel(0).config.eyescanreset;
   DEBUG_8B10B_channel_input(0).eyescantrigger(0)                         <= Ctrl_DEBUG_8B10B.channel(0).config.eyescantrigger;
   DEBUG_8B10B_channel_input(0).loopback                                  <= Ctrl_DEBUG_8B10B.channel(0).config.loopback;
   DEBUG_8B10B_channel_input(0).pcsrsvdin                                 <= Ctrl_DEBUG_8B10B.channel(0).config.pcsrsvdin;
   DEBUG_8B10B_channel_input(0).rxbufreset(0)                             <= Ctrl_DEBUG_8B10B.channel(0).config.rxbufreset;
   DEBUG_8B10B_channel_input(0).rxcdrhold(0)                              <= Ctrl_DEBUG_8B10B.channel(0).config.rxcdrhold;
   DEBUG_8B10B_channel_input(0).rxdfelpmreset(0)                          <= Ctrl_DEBUG_8B10B.channel(0).config.rxdfelpmreset;
   DEBUG_8B10B_channel_input(0).rxlpmen(0)                                <= Ctrl_DEBUG_8B10B.channel(0).config.rxlpmen;
   DEBUG_8B10B_channel_input(0).rxmcommaalignen(0)                        <= Ctrl_DEBUG_8B10B.channel(0).config.rxmcommaalignen;
   DEBUG_8B10B_channel_input(0).rxpcommaalignen(0)                        <= Ctrl_DEBUG_8B10B.channel(0).config.rxpcommaalignen;
   DEBUG_8B10B_channel_input(0).rxpcsreset(0)                             <= Ctrl_DEBUG_8B10B.channel(0).config.rxpcsreset;
   DEBUG_8B10B_channel_input(0).rxpmareset(0)                             <= Ctrl_DEBUG_8B10B.channel(0).config.rxpmareset;
   DEBUG_8B10B_channel_input(0).rxprbscntreset(0)                         <= Ctrl_DEBUG_8B10B.channel(0).config.rxprbscntreset;
   DEBUG_8B10B_channel_input(0).rxprbssel                                 <= Ctrl_DEBUG_8B10B.channel(0).config.rxprbssel;
   DEBUG_8B10B_channel_input(0).rxrate                                    <= Ctrl_DEBUG_8B10B.channel(0).config.rxrate;
   DEBUG_8B10B_channel_input(0).txctrl0                                   <= Ctrl_DEBUG_8B10B.channel(0).config.txctrl0;
   DEBUG_8B10B_channel_input(0).txctrl1                                   <= Ctrl_DEBUG_8B10B.channel(0).config.txctrl1;
   DEBUG_8B10B_channel_input(0).txdiffctrl                                <= Ctrl_DEBUG_8B10B.channel(0).config.txdiffctrl;
   DEBUG_8B10B_channel_input(0).txinhibit(0)                              <= Ctrl_DEBUG_8B10B.channel(0).config.txinhibit;
   DEBUG_8B10B_channel_input(0).txpcsreset(0)                             <= Ctrl_DEBUG_8B10B.channel(0).config.txpcsreset;
   DEBUG_8B10B_channel_input(0).txpmareset(0)                             <= Ctrl_DEBUG_8B10B.channel(0).config.txpmareset;
   DEBUG_8B10B_channel_input(0).txpolarity(0)                             <= Ctrl_DEBUG_8B10B.channel(0).config.txpolarity;
   DEBUG_8B10B_channel_input(0).txpostcursor                              <= Ctrl_DEBUG_8B10B.channel(0).config.txpostcursor;
   DEBUG_8B10B_channel_input(0).txprbsforceerr(0)                         <= Ctrl_DEBUG_8B10B.channel(0).config.txprbsforceerr;
   DEBUG_8B10B_channel_input(0).txprbssel                                 <= Ctrl_DEBUG_8B10B.channel(0).config.txprbssel;
   DEBUG_8B10B_channel_input(0).txprecursor                               <= Ctrl_DEBUG_8B10B.channel(0).config.txprecursor;
   DEBUG_8B10B_channel_input(1).eyescanreset(0)                           <= Ctrl_DEBUG_8B10B.channel(1).config.eyescanreset;
   DEBUG_8B10B_channel_input(1).eyescantrigger(0)                         <= Ctrl_DEBUG_8B10B.channel(1).config.eyescantrigger;
   DEBUG_8B10B_channel_input(1).loopback                                  <= Ctrl_DEBUG_8B10B.channel(1).config.loopback;
   DEBUG_8B10B_channel_input(1).pcsrsvdin                                 <= Ctrl_DEBUG_8B10B.channel(1).config.pcsrsvdin;
   DEBUG_8B10B_channel_input(1).rxbufreset(0)                             <= Ctrl_DEBUG_8B10B.channel(1).config.rxbufreset;
   DEBUG_8B10B_channel_input(1).rxcdrhold(0)                              <= Ctrl_DEBUG_8B10B.channel(1).config.rxcdrhold;
   DEBUG_8B10B_channel_input(1).rxdfelpmreset(0)                          <= Ctrl_DEBUG_8B10B.channel(1).config.rxdfelpmreset;
   DEBUG_8B10B_channel_input(1).rxlpmen(0)                                <= Ctrl_DEBUG_8B10B.channel(1).config.rxlpmen;
   DEBUG_8B10B_channel_input(1).rxmcommaalignen(0)                        <= Ctrl_DEBUG_8B10B.channel(1).config.rxmcommaalignen;
   DEBUG_8B10B_channel_input(1).rxpcommaalignen(0)                        <= Ctrl_DEBUG_8B10B.channel(1).config.rxpcommaalignen;
   DEBUG_8B10B_channel_input(1).rxpcsreset(0)                             <= Ctrl_DEBUG_8B10B.channel(1).config.rxpcsreset;
   DEBUG_8B10B_channel_input(1).rxpmareset(0)                             <= Ctrl_DEBUG_8B10B.channel(1).config.rxpmareset;
   DEBUG_8B10B_channel_input(1).rxprbscntreset(0)                         <= Ctrl_DEBUG_8B10B.channel(1).config.rxprbscntreset;
   DEBUG_8B10B_channel_input(1).rxprbssel                                 <= Ctrl_DEBUG_8B10B.channel(1).config.rxprbssel;
   DEBUG_8B10B_channel_input(1).rxrate                                    <= Ctrl_DEBUG_8B10B.channel(1).config.rxrate;
   DEBUG_8B10B_channel_input(1).txctrl0                                   <= Ctrl_DEBUG_8B10B.channel(1).config.txctrl0;
   DEBUG_8B10B_channel_input(1).txctrl1                                   <= Ctrl_DEBUG_8B10B.channel(1).config.txctrl1;
   DEBUG_8B10B_channel_input(1).txdiffctrl                                <= Ctrl_DEBUG_8B10B.channel(1).config.txdiffctrl;
   DEBUG_8B10B_channel_input(1).txinhibit(0)                              <= Ctrl_DEBUG_8B10B.channel(1).config.txinhibit;
   DEBUG_8B10B_channel_input(1).txpcsreset(0)                             <= Ctrl_DEBUG_8B10B.channel(1).config.txpcsreset;
   DEBUG_8B10B_channel_input(1).txpmareset(0)                             <= Ctrl_DEBUG_8B10B.channel(1).config.txpmareset;
   DEBUG_8B10B_channel_input(1).txpolarity(0)                             <= Ctrl_DEBUG_8B10B.channel(1).config.txpolarity;
   DEBUG_8B10B_channel_input(1).txpostcursor                              <= Ctrl_DEBUG_8B10B.channel(1).config.txpostcursor;
   DEBUG_8B10B_channel_input(1).txprbsforceerr(0)                         <= Ctrl_DEBUG_8B10B.channel(1).config.txprbsforceerr;
   DEBUG_8B10B_channel_input(1).txprbssel                                 <= Ctrl_DEBUG_8B10B.channel(1).config.txprbssel;
   DEBUG_8B10B_channel_input(1).txprecursor                               <= Ctrl_DEBUG_8B10B.channel(1).config.txprecursor;
   DEBUG_8B10B_channel_input(2).eyescanreset(0)                           <= Ctrl_DEBUG_8B10B.channel(2).config.eyescanreset;
   DEBUG_8B10B_channel_input(2).eyescantrigger(0)                         <= Ctrl_DEBUG_8B10B.channel(2).config.eyescantrigger;
   DEBUG_8B10B_channel_input(2).loopback                                  <= Ctrl_DEBUG_8B10B.channel(2).config.loopback;
   DEBUG_8B10B_channel_input(2).pcsrsvdin                                 <= Ctrl_DEBUG_8B10B.channel(2).config.pcsrsvdin;
   DEBUG_8B10B_channel_input(2).rxbufreset(0)                             <= Ctrl_DEBUG_8B10B.channel(2).config.rxbufreset;
   DEBUG_8B10B_channel_input(2).rxcdrhold(0)                              <= Ctrl_DEBUG_8B10B.channel(2).config.rxcdrhold;
   DEBUG_8B10B_channel_input(2).rxdfelpmreset(0)                          <= Ctrl_DEBUG_8B10B.channel(2).config.rxdfelpmreset;
   DEBUG_8B10B_channel_input(2).rxlpmen(0)                                <= Ctrl_DEBUG_8B10B.channel(2).config.rxlpmen;
   DEBUG_8B10B_channel_input(2).rxmcommaalignen(0)                        <= Ctrl_DEBUG_8B10B.channel(2).config.rxmcommaalignen;
   DEBUG_8B10B_channel_input(2).rxpcommaalignen(0)                        <= Ctrl_DEBUG_8B10B.channel(2).config.rxpcommaalignen;
   DEBUG_8B10B_channel_input(2).rxpcsreset(0)                             <= Ctrl_DEBUG_8B10B.channel(2).config.rxpcsreset;
   DEBUG_8B10B_channel_input(2).rxpmareset(0)                             <= Ctrl_DEBUG_8B10B.channel(2).config.rxpmareset;
   DEBUG_8B10B_channel_input(2).rxprbscntreset(0)                         <= Ctrl_DEBUG_8B10B.channel(2).config.rxprbscntreset;
   DEBUG_8B10B_channel_input(2).rxprbssel                                 <= Ctrl_DEBUG_8B10B.channel(2).config.rxprbssel;
   DEBUG_8B10B_channel_input(2).rxrate                                    <= Ctrl_DEBUG_8B10B.channel(2).config.rxrate;
   DEBUG_8B10B_channel_input(2).txctrl0                                   <= Ctrl_DEBUG_8B10B.channel(2).config.txctrl0;
   DEBUG_8B10B_channel_input(2).txctrl1                                   <= Ctrl_DEBUG_8B10B.channel(2).config.txctrl1;
   DEBUG_8B10B_channel_input(2).txdiffctrl                                <= Ctrl_DEBUG_8B10B.channel(2).config.txdiffctrl;
   DEBUG_8B10B_channel_input(2).txinhibit(0)                              <= Ctrl_DEBUG_8B10B.channel(2).config.txinhibit;
   DEBUG_8B10B_channel_input(2).txpcsreset(0)                             <= Ctrl_DEBUG_8B10B.channel(2).config.txpcsreset;
   DEBUG_8B10B_channel_input(2).txpmareset(0)                             <= Ctrl_DEBUG_8B10B.channel(2).config.txpmareset;
   DEBUG_8B10B_channel_input(2).txpolarity(0)                             <= Ctrl_DEBUG_8B10B.channel(2).config.txpolarity;
   DEBUG_8B10B_channel_input(2).txpostcursor                              <= Ctrl_DEBUG_8B10B.channel(2).config.txpostcursor;
   DEBUG_8B10B_channel_input(2).txprbsforceerr(0)                         <= Ctrl_DEBUG_8B10B.channel(2).config.txprbsforceerr;
   DEBUG_8B10B_channel_input(2).txprbssel                                 <= Ctrl_DEBUG_8B10B.channel(2).config.txprbssel;
   DEBUG_8B10B_channel_input(2).txprecursor                               <= Ctrl_DEBUG_8B10B.channel(2).config.txprecursor;
   DEBUG_8B10B_channel_input(3).eyescanreset(0)                           <= Ctrl_DEBUG_8B10B.channel(3).config.eyescanreset;
   DEBUG_8B10B_channel_input(3).eyescantrigger(0)                         <= Ctrl_DEBUG_8B10B.channel(3).config.eyescantrigger;
   DEBUG_8B10B_channel_input(3).loopback                                  <= Ctrl_DEBUG_8B10B.channel(3).config.loopback;
   DEBUG_8B10B_channel_input(3).pcsrsvdin                                 <= Ctrl_DEBUG_8B10B.channel(3).config.pcsrsvdin;
   DEBUG_8B10B_channel_input(3).rxbufreset(0)                             <= Ctrl_DEBUG_8B10B.channel(3).config.rxbufreset;
   DEBUG_8B10B_channel_input(3).rxcdrhold(0)                              <= Ctrl_DEBUG_8B10B.channel(3).config.rxcdrhold;
   DEBUG_8B10B_channel_input(3).rxdfelpmreset(0)                          <= Ctrl_DEBUG_8B10B.channel(3).config.rxdfelpmreset;
   DEBUG_8B10B_channel_input(3).rxlpmen(0)                                <= Ctrl_DEBUG_8B10B.channel(3).config.rxlpmen;
   DEBUG_8B10B_channel_input(3).rxmcommaalignen(0)                        <= Ctrl_DEBUG_8B10B.channel(3).config.rxmcommaalignen;
   DEBUG_8B10B_channel_input(3).rxpcommaalignen(0)                        <= Ctrl_DEBUG_8B10B.channel(3).config.rxpcommaalignen;
   DEBUG_8B10B_channel_input(3).rxpcsreset(0)                             <= Ctrl_DEBUG_8B10B.channel(3).config.rxpcsreset;
   DEBUG_8B10B_channel_input(3).rxpmareset(0)                             <= Ctrl_DEBUG_8B10B.channel(3).config.rxpmareset;
   DEBUG_8B10B_channel_input(3).rxprbscntreset(0)                         <= Ctrl_DEBUG_8B10B.channel(3).config.rxprbscntreset;
   DEBUG_8B10B_channel_input(3).rxprbssel                                 <= Ctrl_DEBUG_8B10B.channel(3).config.rxprbssel;
   DEBUG_8B10B_channel_input(3).rxrate                                    <= Ctrl_DEBUG_8B10B.channel(3).config.rxrate;
   DEBUG_8B10B_channel_input(3).txctrl0                                   <= Ctrl_DEBUG_8B10B.channel(3).config.txctrl0;
   DEBUG_8B10B_channel_input(3).txctrl1                                   <= Ctrl_DEBUG_8B10B.channel(3).config.txctrl1;
   DEBUG_8B10B_channel_input(3).txdiffctrl                                <= Ctrl_DEBUG_8B10B.channel(3).config.txdiffctrl;
   DEBUG_8B10B_channel_input(3).txinhibit(0)                              <= Ctrl_DEBUG_8B10B.channel(3).config.txinhibit;
   DEBUG_8B10B_channel_input(3).txpcsreset(0)                             <= Ctrl_DEBUG_8B10B.channel(3).config.txpcsreset;
   DEBUG_8B10B_channel_input(3).txpmareset(0)                             <= Ctrl_DEBUG_8B10B.channel(3).config.txpmareset;
   DEBUG_8B10B_channel_input(3).txpolarity(0)                             <= Ctrl_DEBUG_8B10B.channel(3).config.txpolarity;
   DEBUG_8B10B_channel_input(3).txpostcursor                              <= Ctrl_DEBUG_8B10B.channel(3).config.txpostcursor;
   DEBUG_8B10B_channel_input(3).txprbsforceerr(0)                         <= Ctrl_DEBUG_8B10B.channel(3).config.txprbsforceerr;
   DEBUG_8B10B_channel_input(3).txprbssel                                 <= Ctrl_DEBUG_8B10B.channel(3).config.txprbssel;
   DEBUG_8B10B_channel_input(3).txprecursor                               <= Ctrl_DEBUG_8B10B.channel(3).config.txprecursor;
   Mon_DEBUG_8B10B.channel(0).config.TXRX_TYPE                            <= DEBUG_8B10B_channel_output(0).TXRX_TYPE;
   Mon_DEBUG_8B10B.channel(0).config.cplllock                             <= DEBUG_8B10B_channel_output(0).cplllock(0);
   Mon_DEBUG_8B10B.channel(0).config.dmonitorout                          <= DEBUG_8B10B_channel_output(0).dmonitorout;
   Mon_DEBUG_8B10B.channel(0).config.eyescandataerror                     <= DEBUG_8B10B_channel_output(0).eyescandataerror(0);
   Mon_DEBUG_8B10B.channel(0).config.gtpowergood                          <= DEBUG_8B10B_channel_output(0).gtpowergood(0);
   Mon_DEBUG_8B10B.channel(0).config.rxbufstatus                          <= DEBUG_8B10B_channel_output(0).rxbufstatus;
   Mon_DEBUG_8B10B.channel(0).config.rxbyteisaligned                      <= DEBUG_8B10B_channel_output(0).rxbyteisaligned(0);
   Mon_DEBUG_8B10B.channel(0).config.rxbyterealign                        <= DEBUG_8B10B_channel_output(0).rxbyterealign(0);
   Mon_DEBUG_8B10B.channel(0).config.rxctrl2                              <= DEBUG_8B10B_channel_output(0).rxctrl2;
   Mon_DEBUG_8B10B.channel(0).config.rxpmaresetdone                       <= DEBUG_8B10B_channel_output(0).rxpmaresetdone(0);
   Mon_DEBUG_8B10B.channel(0).config.rxprbserr                            <= DEBUG_8B10B_channel_output(0).rxprbserr(0);
   Mon_DEBUG_8B10B.channel(0).config.rxresetdone                          <= DEBUG_8B10B_channel_output(0).rxresetdone(0);
   Mon_DEBUG_8B10B.channel(0).config.txbufstatus                          <= DEBUG_8B10B_channel_output(0).txbufstatus;
   Mon_DEBUG_8B10B.channel(0).config.txpmaresetdone                       <= DEBUG_8B10B_channel_output(0).txpmaresetdone(0);
   Mon_DEBUG_8B10B.channel(0).config.txresetdone                          <= DEBUG_8B10B_channel_output(0).txresetdone(0);
   Mon_DEBUG_8B10B.channel(1).config.TXRX_TYPE                            <= DEBUG_8B10B_channel_output(1).TXRX_TYPE;
   Mon_DEBUG_8B10B.channel(1).config.cplllock                             <= DEBUG_8B10B_channel_output(1).cplllock(0);
   Mon_DEBUG_8B10B.channel(1).config.dmonitorout                          <= DEBUG_8B10B_channel_output(1).dmonitorout;
   Mon_DEBUG_8B10B.channel(1).config.eyescandataerror                     <= DEBUG_8B10B_channel_output(1).eyescandataerror(0);
   Mon_DEBUG_8B10B.channel(1).config.gtpowergood                          <= DEBUG_8B10B_channel_output(1).gtpowergood(0);
   Mon_DEBUG_8B10B.channel(1).config.rxbufstatus                          <= DEBUG_8B10B_channel_output(1).rxbufstatus;
   Mon_DEBUG_8B10B.channel(1).config.rxbyteisaligned                      <= DEBUG_8B10B_channel_output(1).rxbyteisaligned(0);
   Mon_DEBUG_8B10B.channel(1).config.rxbyterealign                        <= DEBUG_8B10B_channel_output(1).rxbyterealign(0);
   Mon_DEBUG_8B10B.channel(1).config.rxctrl2                              <= DEBUG_8B10B_channel_output(1).rxctrl2;
   Mon_DEBUG_8B10B.channel(1).config.rxpmaresetdone                       <= DEBUG_8B10B_channel_output(1).rxpmaresetdone(0);
   Mon_DEBUG_8B10B.channel(1).config.rxprbserr                            <= DEBUG_8B10B_channel_output(1).rxprbserr(0);
   Mon_DEBUG_8B10B.channel(1).config.rxresetdone                          <= DEBUG_8B10B_channel_output(1).rxresetdone(0);
   Mon_DEBUG_8B10B.channel(1).config.txbufstatus                          <= DEBUG_8B10B_channel_output(1).txbufstatus;
   Mon_DEBUG_8B10B.channel(1).config.txpmaresetdone                       <= DEBUG_8B10B_channel_output(1).txpmaresetdone(0);
   Mon_DEBUG_8B10B.channel(1).config.txresetdone                          <= DEBUG_8B10B_channel_output(1).txresetdone(0);
   Mon_DEBUG_8B10B.channel(2).config.TXRX_TYPE                            <= DEBUG_8B10B_channel_output(2).TXRX_TYPE;
   Mon_DEBUG_8B10B.channel(2).config.cplllock                             <= DEBUG_8B10B_channel_output(2).cplllock(0);
   Mon_DEBUG_8B10B.channel(2).config.dmonitorout                          <= DEBUG_8B10B_channel_output(2).dmonitorout;
   Mon_DEBUG_8B10B.channel(2).config.eyescandataerror                     <= DEBUG_8B10B_channel_output(2).eyescandataerror(0);
   Mon_DEBUG_8B10B.channel(2).config.gtpowergood                          <= DEBUG_8B10B_channel_output(2).gtpowergood(0);
   Mon_DEBUG_8B10B.channel(2).config.rxbufstatus                          <= DEBUG_8B10B_channel_output(2).rxbufstatus;
   Mon_DEBUG_8B10B.channel(2).config.rxbyteisaligned                      <= DEBUG_8B10B_channel_output(2).rxbyteisaligned(0);
   Mon_DEBUG_8B10B.channel(2).config.rxbyterealign                        <= DEBUG_8B10B_channel_output(2).rxbyterealign(0);
   Mon_DEBUG_8B10B.channel(2).config.rxctrl2                              <= DEBUG_8B10B_channel_output(2).rxctrl2;
   Mon_DEBUG_8B10B.channel(2).config.rxpmaresetdone                       <= DEBUG_8B10B_channel_output(2).rxpmaresetdone(0);
   Mon_DEBUG_8B10B.channel(2).config.rxprbserr                            <= DEBUG_8B10B_channel_output(2).rxprbserr(0);
   Mon_DEBUG_8B10B.channel(2).config.rxresetdone                          <= DEBUG_8B10B_channel_output(2).rxresetdone(0);
   Mon_DEBUG_8B10B.channel(2).config.txbufstatus                          <= DEBUG_8B10B_channel_output(2).txbufstatus;
   Mon_DEBUG_8B10B.channel(2).config.txpmaresetdone                       <= DEBUG_8B10B_channel_output(2).txpmaresetdone(0);
   Mon_DEBUG_8B10B.channel(2).config.txresetdone                          <= DEBUG_8B10B_channel_output(2).txresetdone(0);
   Mon_DEBUG_8B10B.channel(3).config.TXRX_TYPE                            <= DEBUG_8B10B_channel_output(3).TXRX_TYPE;
   Mon_DEBUG_8B10B.channel(3).config.cplllock                             <= DEBUG_8B10B_channel_output(3).cplllock(0);
   Mon_DEBUG_8B10B.channel(3).config.dmonitorout                          <= DEBUG_8B10B_channel_output(3).dmonitorout;
   Mon_DEBUG_8B10B.channel(3).config.eyescandataerror                     <= DEBUG_8B10B_channel_output(3).eyescandataerror(0);
   Mon_DEBUG_8B10B.channel(3).config.gtpowergood                          <= DEBUG_8B10B_channel_output(3).gtpowergood(0);
   Mon_DEBUG_8B10B.channel(3).config.rxbufstatus                          <= DEBUG_8B10B_channel_output(3).rxbufstatus;
   Mon_DEBUG_8B10B.channel(3).config.rxbyteisaligned                      <= DEBUG_8B10B_channel_output(3).rxbyteisaligned(0);
   Mon_DEBUG_8B10B.channel(3).config.rxbyterealign                        <= DEBUG_8B10B_channel_output(3).rxbyterealign(0);
   Mon_DEBUG_8B10B.channel(3).config.rxctrl2                              <= DEBUG_8B10B_channel_output(3).rxctrl2;
   Mon_DEBUG_8B10B.channel(3).config.rxpmaresetdone                       <= DEBUG_8B10B_channel_output(3).rxpmaresetdone(0);
   Mon_DEBUG_8B10B.channel(3).config.rxprbserr                            <= DEBUG_8B10B_channel_output(3).rxprbserr(0);
   Mon_DEBUG_8B10B.channel(3).config.rxresetdone                          <= DEBUG_8B10B_channel_output(3).rxresetdone(0);
   Mon_DEBUG_8B10B.channel(3).config.txbufstatus                          <= DEBUG_8B10B_channel_output(3).txbufstatus;
   Mon_DEBUG_8B10B.channel(3).config.txpmaresetdone                       <= DEBUG_8B10B_channel_output(3).txpmaresetdone(0);
   Mon_DEBUG_8B10B.channel(3).config.txresetdone                          <= DEBUG_8B10B_channel_output(3).txresetdone(0);
   DEBUG_8B10B_drp_input(0).address                                       <= Ctrl_DEBUG_8B10B.channel(0).drp.address;
   DEBUG_8B10B_drp_input(0).clk(0)                                        <= Ctrl_DEBUG_8B10B.channel(0).drp.clk;
   DEBUG_8B10B_drp_input(0).wr_data                                       <= Ctrl_DEBUG_8B10B.channel(0).drp.wr_data;
   DEBUG_8B10B_drp_input(0).enable(0)                                     <= Ctrl_DEBUG_8B10B.channel(0).drp.enable;
   DEBUG_8B10B_drp_input(0).reset(0)                                      <= Ctrl_DEBUG_8B10B.channel(0).drp.reset;
   DEBUG_8B10B_drp_input(0).wr_enable(0)                                  <= Ctrl_DEBUG_8B10B.channel(0).drp.wr_enable;
   DEBUG_8B10B_drp_input(1).address                                       <= Ctrl_DEBUG_8B10B.channel(1).drp.address;
   DEBUG_8B10B_drp_input(1).clk(0)                                        <= Ctrl_DEBUG_8B10B.channel(1).drp.clk;
   DEBUG_8B10B_drp_input(1).wr_data                                       <= Ctrl_DEBUG_8B10B.channel(1).drp.wr_data;
   DEBUG_8B10B_drp_input(1).enable(0)                                     <= Ctrl_DEBUG_8B10B.channel(1).drp.enable;
   DEBUG_8B10B_drp_input(1).reset(0)                                      <= Ctrl_DEBUG_8B10B.channel(1).drp.reset;
   DEBUG_8B10B_drp_input(1).wr_enable(0)                                  <= Ctrl_DEBUG_8B10B.channel(1).drp.wr_enable;
   DEBUG_8B10B_drp_input(2).address                                       <= Ctrl_DEBUG_8B10B.channel(2).drp.address;
   DEBUG_8B10B_drp_input(2).clk(0)                                        <= Ctrl_DEBUG_8B10B.channel(2).drp.clk;
   DEBUG_8B10B_drp_input(2).wr_data                                       <= Ctrl_DEBUG_8B10B.channel(2).drp.wr_data;
   DEBUG_8B10B_drp_input(2).enable(0)                                     <= Ctrl_DEBUG_8B10B.channel(2).drp.enable;
   DEBUG_8B10B_drp_input(2).reset(0)                                      <= Ctrl_DEBUG_8B10B.channel(2).drp.reset;
   DEBUG_8B10B_drp_input(2).wr_enable(0)                                  <= Ctrl_DEBUG_8B10B.channel(2).drp.wr_enable;
   DEBUG_8B10B_drp_input(3).address                                       <= Ctrl_DEBUG_8B10B.channel(3).drp.address;
   DEBUG_8B10B_drp_input(3).clk(0)                                        <= Ctrl_DEBUG_8B10B.channel(3).drp.clk;
   DEBUG_8B10B_drp_input(3).wr_data                                       <= Ctrl_DEBUG_8B10B.channel(3).drp.wr_data;
   DEBUG_8B10B_drp_input(3).enable(0)                                     <= Ctrl_DEBUG_8B10B.channel(3).drp.enable;
   DEBUG_8B10B_drp_input(3).reset(0)                                      <= Ctrl_DEBUG_8B10B.channel(3).drp.reset;
   DEBUG_8B10B_drp_input(3).wr_enable(0)                                  <= Ctrl_DEBUG_8B10B.channel(3).drp.wr_enable;
   Mon_DEBUG_8B10B.channel(0).drp.rd_data                                 <= DEBUG_8B10B_drp_output(0).rd_data;
   Mon_DEBUG_8B10B.channel(0).drp.rd_data_valid                           <= DEBUG_8B10B_drp_output(0).rd_data_valid(0);
   Mon_DEBUG_8B10B.channel(1).drp.rd_data                                 <= DEBUG_8B10B_drp_output(1).rd_data;
   Mon_DEBUG_8B10B.channel(1).drp.rd_data_valid                           <= DEBUG_8B10B_drp_output(1).rd_data_valid(0);
   Mon_DEBUG_8B10B.channel(2).drp.rd_data                                 <= DEBUG_8B10B_drp_output(2).rd_data;
   Mon_DEBUG_8B10B.channel(2).drp.rd_data_valid                           <= DEBUG_8B10B_drp_output(2).rd_data_valid(0);
   Mon_DEBUG_8B10B.channel(3).drp.rd_data                                 <= DEBUG_8B10B_drp_output(3).rd_data;
   Mon_DEBUG_8B10B.channel(3).drp.rd_data_valid                           <= DEBUG_8B10B_drp_output(3).rd_data_valid(0);


end architecture behavioral;
