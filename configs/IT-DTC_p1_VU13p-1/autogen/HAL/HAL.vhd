library ieee;
use ieee.std_logic_1164.all;

use work.axiRegPkg.all;
use work.hal_pkg.all;


use work.LPGBT_PKG.all;
use work.LPGBT_Ctrl.all;
Library UNISIM;
use UNISIM.vcomponents.all;


entity HAL is
  generic (
                      LPGBT_MEMORY_RANGE : integer);
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
                    LPGBT_userdata_input : in  LPGBT_userdata_input_array_t( 12-1 downto 0);
                   LPGBT_userdata_output : out LPGBT_userdata_output_array_t( 12-1 downto 0);
                     LPGBT_clocks_output : out LPGBT_clocks_output_array_t( 12-1 downto 0));
end entity HAL;


architecture behavioral of HAL is
  signal                          refclk_126_clk0 : std_logic;
  signal                        refclk_126_clk0_2 : std_logic;
  signal                    buf_refclk_126_clk0_2 : std_logic;

  signal                            freq_126_clk0 : std_logic_vector(31 downto 0);
  signal                       LPGBT_common_input : LPGBT_common_input_array_t(12-1 downto 0);
  signal                      LPGBT_common_output : LPGBT_common_output_array_t(12-1 downto 0);
  signal                       LPGBT_clocks_input : LPGBT_clocks_input_array_t(12-1 downto 0);
  signal                          LPGBT_drp_input : LPGBT_drp_input_array_t(12-1 downto 0);
  signal                         LPGBT_drp_output : LPGBT_drp_output_array_t(12-1 downto 0);
  signal                      LPGBT_channel_input : LPGBT_channel_input_array_t(12-1 downto 0);
  signal                     LPGBT_channel_output : LPGBT_channel_output_array_t(12-1 downto 0);


  signal                               Ctrl_LPGBT : LPGBT_Ctrl_t;
  signal                                Mon_LPGBT : LPGBT_Mon_t;
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
--LPGBT
--------------------------------------------------------------------------------
LPGBT_map_1: entity work.LPGBT_map
  generic map (
    ALLOCATED_MEMORY_RANGE => LPGBT_MEMORY_RANGE)
  port map (
    clk_axi         => clk_axi,
    reset_axi_n     => reset_axi_n,
    slave_readMOSI  => readMOSI(0),
    slave_readMISO  => readMISO(0),
    slave_writeMOSI => writeMOSI(0),
    slave_writeMISO => writeMISO(0),
    Mon             => Mon_LPGBT,
    Ctrl            => Ctrl_LPGBT);
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
    Mon_LPGBT.REFCLK.freq_126_clk0 <= freq_126_clk0;
  QUAD_GTH_125_LPGBT_inst : entity work.QUAD_GTH_125_LPGBT_wrapper
    port map (
                                            gtyrxn => HAL_serdes_input.QUAD_GTH_125_LPGBT_gtyrxn,
                                            gtyrxp => HAL_serdes_input.QUAD_GTH_125_LPGBT_gtyrxp,
                                            gtytxn => HAL_serdes_output.QUAD_GTH_125_LPGBT_gtytxn,
                                            gtytxp => HAL_serdes_output.QUAD_GTH_125_LPGBT_gtytxp,
                                      common_input => LPGBT_common_input(  0),
                                     common_output => LPGBT_common_output(  0),
                                    userdata_input => LPGBT_userdata_input(  3 downto   0),
                                   userdata_output => LPGBT_userdata_output(  3 downto   0),
                                      clocks_input => LPGBT_clocks_input(  0),
                                     clocks_output => LPGBT_clocks_output(  0),
                                         drp_input => LPGBT_drp_input(  3 downto   0),
                                        drp_output => LPGBT_drp_output(  3 downto   0),
                                     channel_input => LPGBT_channel_input(  3 downto   0),
                                    channel_output => LPGBT_channel_output(  3 downto   0)
    );


    LPGBT_clocks_input(0).gtwiz_reset_clk_freerun(0) <= clk_axi;

    LPGBT_clocks_input(0).gtrefclk00(0) <= refclk_126_clk0;

   LPGBT_common_input(0).gtwiz_userclk_tx_reset(0)                        <= Ctrl_LPGBT.common(0).gtwiz_userclk_tx_reset;
   LPGBT_common_input(0).gtwiz_userclk_rx_reset(0)                        <= Ctrl_LPGBT.common(0).gtwiz_userclk_rx_reset;
   LPGBT_common_input(0).gtwiz_reset_all(0)                               <= Ctrl_LPGBT.common(0).gtwiz_reset_all;
   LPGBT_common_input(0).gtwiz_reset_tx_pll_and_datapath(0)               <= Ctrl_LPGBT.common(0).gtwiz_reset_tx_pll_and_datapath;
   LPGBT_common_input(0).gtwiz_reset_tx_datapath(0)                       <= Ctrl_LPGBT.common(0).gtwiz_reset_tx_datapath;
   LPGBT_common_input(0).gtwiz_reset_rx_pll_and_datapath(0)               <= Ctrl_LPGBT.common(0).gtwiz_reset_rx_pll_and_datapath;
   LPGBT_common_input(0).gtwiz_reset_rx_datapath(0)                       <= Ctrl_LPGBT.common(0).gtwiz_reset_rx_datapath;
   Mon_LPGBT.common(0).gtwiz_userclk_tx_active                            <= LPGBT_common_output(0).gtwiz_userclk_tx_active(0);
   Mon_LPGBT.common(0).gtwiz_userclk_rx_active                            <= LPGBT_common_output(0).gtwiz_userclk_rx_active(0);
   Mon_LPGBT.common(0).gtwiz_reset_rx_cdr_stable                          <= LPGBT_common_output(0).gtwiz_reset_rx_cdr_stable(0);
   Mon_LPGBT.common(0).gtwiz_reset_tx_done                                <= LPGBT_common_output(0).gtwiz_reset_tx_done(0);
   Mon_LPGBT.common(0).gtwiz_reset_rx_done                                <= LPGBT_common_output(0).gtwiz_reset_rx_done(0);
   LPGBT_channel_input(0).eyescanreset(0)                                 <= Ctrl_LPGBT.channel(0).config.eyescanreset;
   LPGBT_channel_input(0).eyescantrigger(0)                               <= Ctrl_LPGBT.channel(0).config.eyescantrigger;
   LPGBT_channel_input(0).loopback                                        <= Ctrl_LPGBT.channel(0).config.loopback;
   LPGBT_channel_input(0).pcsrsvdin                                       <= Ctrl_LPGBT.channel(0).config.pcsrsvdin;
   LPGBT_channel_input(0).rxbufreset(0)                                   <= Ctrl_LPGBT.channel(0).config.rxbufreset;
   LPGBT_channel_input(0).rxcdrhold(0)                                    <= Ctrl_LPGBT.channel(0).config.rxcdrhold;
   LPGBT_channel_input(0).rxdfelpmreset(0)                                <= Ctrl_LPGBT.channel(0).config.rxdfelpmreset;
   LPGBT_channel_input(0).rxlpmen(0)                                      <= Ctrl_LPGBT.channel(0).config.rxlpmen;
   LPGBT_channel_input(0).rxpcsreset(0)                                   <= Ctrl_LPGBT.channel(0).config.rxpcsreset;
   LPGBT_channel_input(0).rxpmareset(0)                                   <= Ctrl_LPGBT.channel(0).config.rxpmareset;
   LPGBT_channel_input(0).rxprbscntreset(0)                               <= Ctrl_LPGBT.channel(0).config.rxprbscntreset;
   LPGBT_channel_input(0).rxprbssel                                       <= Ctrl_LPGBT.channel(0).config.rxprbssel;
   LPGBT_channel_input(0).rxrate                                          <= Ctrl_LPGBT.channel(0).config.rxrate;
   LPGBT_channel_input(0).txctrl2                                         <= Ctrl_LPGBT.channel(0).config.txctrl2;
   LPGBT_channel_input(0).txdiffctrl                                      <= Ctrl_LPGBT.channel(0).config.txdiffctrl;
   LPGBT_channel_input(0).txinhibit(0)                                    <= Ctrl_LPGBT.channel(0).config.txinhibit;
   LPGBT_channel_input(0).txpcsreset(0)                                   <= Ctrl_LPGBT.channel(0).config.txpcsreset;
   LPGBT_channel_input(0).txpmareset(0)                                   <= Ctrl_LPGBT.channel(0).config.txpmareset;
   LPGBT_channel_input(0).txpolarity(0)                                   <= Ctrl_LPGBT.channel(0).config.txpolarity;
   LPGBT_channel_input(0).txpostcursor                                    <= Ctrl_LPGBT.channel(0).config.txpostcursor;
   LPGBT_channel_input(0).txprbsforceerr(0)                               <= Ctrl_LPGBT.channel(0).config.txprbsforceerr;
   LPGBT_channel_input(0).txprbssel                                       <= Ctrl_LPGBT.channel(0).config.txprbssel;
   LPGBT_channel_input(0).txprecursor                                     <= Ctrl_LPGBT.channel(0).config.txprecursor;
   LPGBT_channel_input(1).eyescanreset(0)                                 <= Ctrl_LPGBT.channel(1).config.eyescanreset;
   LPGBT_channel_input(1).eyescantrigger(0)                               <= Ctrl_LPGBT.channel(1).config.eyescantrigger;
   LPGBT_channel_input(1).loopback                                        <= Ctrl_LPGBT.channel(1).config.loopback;
   LPGBT_channel_input(1).pcsrsvdin                                       <= Ctrl_LPGBT.channel(1).config.pcsrsvdin;
   LPGBT_channel_input(1).rxbufreset(0)                                   <= Ctrl_LPGBT.channel(1).config.rxbufreset;
   LPGBT_channel_input(1).rxcdrhold(0)                                    <= Ctrl_LPGBT.channel(1).config.rxcdrhold;
   LPGBT_channel_input(1).rxdfelpmreset(0)                                <= Ctrl_LPGBT.channel(1).config.rxdfelpmreset;
   LPGBT_channel_input(1).rxlpmen(0)                                      <= Ctrl_LPGBT.channel(1).config.rxlpmen;
   LPGBT_channel_input(1).rxpcsreset(0)                                   <= Ctrl_LPGBT.channel(1).config.rxpcsreset;
   LPGBT_channel_input(1).rxpmareset(0)                                   <= Ctrl_LPGBT.channel(1).config.rxpmareset;
   LPGBT_channel_input(1).rxprbscntreset(0)                               <= Ctrl_LPGBT.channel(1).config.rxprbscntreset;
   LPGBT_channel_input(1).rxprbssel                                       <= Ctrl_LPGBT.channel(1).config.rxprbssel;
   LPGBT_channel_input(1).rxrate                                          <= Ctrl_LPGBT.channel(1).config.rxrate;
   LPGBT_channel_input(1).txctrl2                                         <= Ctrl_LPGBT.channel(1).config.txctrl2;
   LPGBT_channel_input(1).txdiffctrl                                      <= Ctrl_LPGBT.channel(1).config.txdiffctrl;
   LPGBT_channel_input(1).txinhibit(0)                                    <= Ctrl_LPGBT.channel(1).config.txinhibit;
   LPGBT_channel_input(1).txpcsreset(0)                                   <= Ctrl_LPGBT.channel(1).config.txpcsreset;
   LPGBT_channel_input(1).txpmareset(0)                                   <= Ctrl_LPGBT.channel(1).config.txpmareset;
   LPGBT_channel_input(1).txpolarity(0)                                   <= Ctrl_LPGBT.channel(1).config.txpolarity;
   LPGBT_channel_input(1).txpostcursor                                    <= Ctrl_LPGBT.channel(1).config.txpostcursor;
   LPGBT_channel_input(1).txprbsforceerr(0)                               <= Ctrl_LPGBT.channel(1).config.txprbsforceerr;
   LPGBT_channel_input(1).txprbssel                                       <= Ctrl_LPGBT.channel(1).config.txprbssel;
   LPGBT_channel_input(1).txprecursor                                     <= Ctrl_LPGBT.channel(1).config.txprecursor;
   LPGBT_channel_input(2).eyescanreset(0)                                 <= Ctrl_LPGBT.channel(2).config.eyescanreset;
   LPGBT_channel_input(2).eyescantrigger(0)                               <= Ctrl_LPGBT.channel(2).config.eyescantrigger;
   LPGBT_channel_input(2).loopback                                        <= Ctrl_LPGBT.channel(2).config.loopback;
   LPGBT_channel_input(2).pcsrsvdin                                       <= Ctrl_LPGBT.channel(2).config.pcsrsvdin;
   LPGBT_channel_input(2).rxbufreset(0)                                   <= Ctrl_LPGBT.channel(2).config.rxbufreset;
   LPGBT_channel_input(2).rxcdrhold(0)                                    <= Ctrl_LPGBT.channel(2).config.rxcdrhold;
   LPGBT_channel_input(2).rxdfelpmreset(0)                                <= Ctrl_LPGBT.channel(2).config.rxdfelpmreset;
   LPGBT_channel_input(2).rxlpmen(0)                                      <= Ctrl_LPGBT.channel(2).config.rxlpmen;
   LPGBT_channel_input(2).rxpcsreset(0)                                   <= Ctrl_LPGBT.channel(2).config.rxpcsreset;
   LPGBT_channel_input(2).rxpmareset(0)                                   <= Ctrl_LPGBT.channel(2).config.rxpmareset;
   LPGBT_channel_input(2).rxprbscntreset(0)                               <= Ctrl_LPGBT.channel(2).config.rxprbscntreset;
   LPGBT_channel_input(2).rxprbssel                                       <= Ctrl_LPGBT.channel(2).config.rxprbssel;
   LPGBT_channel_input(2).rxrate                                          <= Ctrl_LPGBT.channel(2).config.rxrate;
   LPGBT_channel_input(2).txctrl2                                         <= Ctrl_LPGBT.channel(2).config.txctrl2;
   LPGBT_channel_input(2).txdiffctrl                                      <= Ctrl_LPGBT.channel(2).config.txdiffctrl;
   LPGBT_channel_input(2).txinhibit(0)                                    <= Ctrl_LPGBT.channel(2).config.txinhibit;
   LPGBT_channel_input(2).txpcsreset(0)                                   <= Ctrl_LPGBT.channel(2).config.txpcsreset;
   LPGBT_channel_input(2).txpmareset(0)                                   <= Ctrl_LPGBT.channel(2).config.txpmareset;
   LPGBT_channel_input(2).txpolarity(0)                                   <= Ctrl_LPGBT.channel(2).config.txpolarity;
   LPGBT_channel_input(2).txpostcursor                                    <= Ctrl_LPGBT.channel(2).config.txpostcursor;
   LPGBT_channel_input(2).txprbsforceerr(0)                               <= Ctrl_LPGBT.channel(2).config.txprbsforceerr;
   LPGBT_channel_input(2).txprbssel                                       <= Ctrl_LPGBT.channel(2).config.txprbssel;
   LPGBT_channel_input(2).txprecursor                                     <= Ctrl_LPGBT.channel(2).config.txprecursor;
   LPGBT_channel_input(3).eyescanreset(0)                                 <= Ctrl_LPGBT.channel(3).config.eyescanreset;
   LPGBT_channel_input(3).eyescantrigger(0)                               <= Ctrl_LPGBT.channel(3).config.eyescantrigger;
   LPGBT_channel_input(3).loopback                                        <= Ctrl_LPGBT.channel(3).config.loopback;
   LPGBT_channel_input(3).pcsrsvdin                                       <= Ctrl_LPGBT.channel(3).config.pcsrsvdin;
   LPGBT_channel_input(3).rxbufreset(0)                                   <= Ctrl_LPGBT.channel(3).config.rxbufreset;
   LPGBT_channel_input(3).rxcdrhold(0)                                    <= Ctrl_LPGBT.channel(3).config.rxcdrhold;
   LPGBT_channel_input(3).rxdfelpmreset(0)                                <= Ctrl_LPGBT.channel(3).config.rxdfelpmreset;
   LPGBT_channel_input(3).rxlpmen(0)                                      <= Ctrl_LPGBT.channel(3).config.rxlpmen;
   LPGBT_channel_input(3).rxpcsreset(0)                                   <= Ctrl_LPGBT.channel(3).config.rxpcsreset;
   LPGBT_channel_input(3).rxpmareset(0)                                   <= Ctrl_LPGBT.channel(3).config.rxpmareset;
   LPGBT_channel_input(3).rxprbscntreset(0)                               <= Ctrl_LPGBT.channel(3).config.rxprbscntreset;
   LPGBT_channel_input(3).rxprbssel                                       <= Ctrl_LPGBT.channel(3).config.rxprbssel;
   LPGBT_channel_input(3).rxrate                                          <= Ctrl_LPGBT.channel(3).config.rxrate;
   LPGBT_channel_input(3).txctrl2                                         <= Ctrl_LPGBT.channel(3).config.txctrl2;
   LPGBT_channel_input(3).txdiffctrl                                      <= Ctrl_LPGBT.channel(3).config.txdiffctrl;
   LPGBT_channel_input(3).txinhibit(0)                                    <= Ctrl_LPGBT.channel(3).config.txinhibit;
   LPGBT_channel_input(3).txpcsreset(0)                                   <= Ctrl_LPGBT.channel(3).config.txpcsreset;
   LPGBT_channel_input(3).txpmareset(0)                                   <= Ctrl_LPGBT.channel(3).config.txpmareset;
   LPGBT_channel_input(3).txpolarity(0)                                   <= Ctrl_LPGBT.channel(3).config.txpolarity;
   LPGBT_channel_input(3).txpostcursor                                    <= Ctrl_LPGBT.channel(3).config.txpostcursor;
   LPGBT_channel_input(3).txprbsforceerr(0)                               <= Ctrl_LPGBT.channel(3).config.txprbsforceerr;
   LPGBT_channel_input(3).txprbssel                                       <= Ctrl_LPGBT.channel(3).config.txprbssel;
   LPGBT_channel_input(3).txprecursor                                     <= Ctrl_LPGBT.channel(3).config.txprecursor;
   Mon_LPGBT.channel(0).config.TXRX_TYPE                                  <= LPGBT_channel_output(0).TXRX_TYPE;
   Mon_LPGBT.channel(0).config.cplllock                                   <= LPGBT_channel_output(0).cplllock(0);
   Mon_LPGBT.channel(0).config.dmonitorout                                <= LPGBT_channel_output(0).dmonitorout;
   Mon_LPGBT.channel(0).config.eyescandataerror                           <= LPGBT_channel_output(0).eyescandataerror(0);
   Mon_LPGBT.channel(0).config.gtpowergood                                <= LPGBT_channel_output(0).gtpowergood(0);
   Mon_LPGBT.channel(0).config.rxbufstatus                                <= LPGBT_channel_output(0).rxbufstatus;
   Mon_LPGBT.channel(0).config.rxctrl2                                    <= LPGBT_channel_output(0).rxctrl2;
   Mon_LPGBT.channel(0).config.rxpmaresetdone                             <= LPGBT_channel_output(0).rxpmaresetdone(0);
   Mon_LPGBT.channel(0).config.rxprbserr                                  <= LPGBT_channel_output(0).rxprbserr(0);
   Mon_LPGBT.channel(0).config.rxresetdone                                <= LPGBT_channel_output(0).rxresetdone(0);
   Mon_LPGBT.channel(0).config.txbufstatus                                <= LPGBT_channel_output(0).txbufstatus;
   Mon_LPGBT.channel(0).config.txpmaresetdone                             <= LPGBT_channel_output(0).txpmaresetdone(0);
   Mon_LPGBT.channel(0).config.txresetdone                                <= LPGBT_channel_output(0).txresetdone(0);
   Mon_LPGBT.channel(1).config.TXRX_TYPE                                  <= LPGBT_channel_output(1).TXRX_TYPE;
   Mon_LPGBT.channel(1).config.cplllock                                   <= LPGBT_channel_output(1).cplllock(0);
   Mon_LPGBT.channel(1).config.dmonitorout                                <= LPGBT_channel_output(1).dmonitorout;
   Mon_LPGBT.channel(1).config.eyescandataerror                           <= LPGBT_channel_output(1).eyescandataerror(0);
   Mon_LPGBT.channel(1).config.gtpowergood                                <= LPGBT_channel_output(1).gtpowergood(0);
   Mon_LPGBT.channel(1).config.rxbufstatus                                <= LPGBT_channel_output(1).rxbufstatus;
   Mon_LPGBT.channel(1).config.rxctrl2                                    <= LPGBT_channel_output(1).rxctrl2;
   Mon_LPGBT.channel(1).config.rxpmaresetdone                             <= LPGBT_channel_output(1).rxpmaresetdone(0);
   Mon_LPGBT.channel(1).config.rxprbserr                                  <= LPGBT_channel_output(1).rxprbserr(0);
   Mon_LPGBT.channel(1).config.rxresetdone                                <= LPGBT_channel_output(1).rxresetdone(0);
   Mon_LPGBT.channel(1).config.txbufstatus                                <= LPGBT_channel_output(1).txbufstatus;
   Mon_LPGBT.channel(1).config.txpmaresetdone                             <= LPGBT_channel_output(1).txpmaresetdone(0);
   Mon_LPGBT.channel(1).config.txresetdone                                <= LPGBT_channel_output(1).txresetdone(0);
   Mon_LPGBT.channel(2).config.TXRX_TYPE                                  <= LPGBT_channel_output(2).TXRX_TYPE;
   Mon_LPGBT.channel(2).config.cplllock                                   <= LPGBT_channel_output(2).cplllock(0);
   Mon_LPGBT.channel(2).config.dmonitorout                                <= LPGBT_channel_output(2).dmonitorout;
   Mon_LPGBT.channel(2).config.eyescandataerror                           <= LPGBT_channel_output(2).eyescandataerror(0);
   Mon_LPGBT.channel(2).config.gtpowergood                                <= LPGBT_channel_output(2).gtpowergood(0);
   Mon_LPGBT.channel(2).config.rxbufstatus                                <= LPGBT_channel_output(2).rxbufstatus;
   Mon_LPGBT.channel(2).config.rxctrl2                                    <= LPGBT_channel_output(2).rxctrl2;
   Mon_LPGBT.channel(2).config.rxpmaresetdone                             <= LPGBT_channel_output(2).rxpmaresetdone(0);
   Mon_LPGBT.channel(2).config.rxprbserr                                  <= LPGBT_channel_output(2).rxprbserr(0);
   Mon_LPGBT.channel(2).config.rxresetdone                                <= LPGBT_channel_output(2).rxresetdone(0);
   Mon_LPGBT.channel(2).config.txbufstatus                                <= LPGBT_channel_output(2).txbufstatus;
   Mon_LPGBT.channel(2).config.txpmaresetdone                             <= LPGBT_channel_output(2).txpmaresetdone(0);
   Mon_LPGBT.channel(2).config.txresetdone                                <= LPGBT_channel_output(2).txresetdone(0);
   Mon_LPGBT.channel(3).config.TXRX_TYPE                                  <= LPGBT_channel_output(3).TXRX_TYPE;
   Mon_LPGBT.channel(3).config.cplllock                                   <= LPGBT_channel_output(3).cplllock(0);
   Mon_LPGBT.channel(3).config.dmonitorout                                <= LPGBT_channel_output(3).dmonitorout;
   Mon_LPGBT.channel(3).config.eyescandataerror                           <= LPGBT_channel_output(3).eyescandataerror(0);
   Mon_LPGBT.channel(3).config.gtpowergood                                <= LPGBT_channel_output(3).gtpowergood(0);
   Mon_LPGBT.channel(3).config.rxbufstatus                                <= LPGBT_channel_output(3).rxbufstatus;
   Mon_LPGBT.channel(3).config.rxctrl2                                    <= LPGBT_channel_output(3).rxctrl2;
   Mon_LPGBT.channel(3).config.rxpmaresetdone                             <= LPGBT_channel_output(3).rxpmaresetdone(0);
   Mon_LPGBT.channel(3).config.rxprbserr                                  <= LPGBT_channel_output(3).rxprbserr(0);
   Mon_LPGBT.channel(3).config.rxresetdone                                <= LPGBT_channel_output(3).rxresetdone(0);
   Mon_LPGBT.channel(3).config.txbufstatus                                <= LPGBT_channel_output(3).txbufstatus;
   Mon_LPGBT.channel(3).config.txpmaresetdone                             <= LPGBT_channel_output(3).txpmaresetdone(0);
   Mon_LPGBT.channel(3).config.txresetdone                                <= LPGBT_channel_output(3).txresetdone(0);
   LPGBT_drp_input(0).address                                             <= Ctrl_LPGBT.channel(0).drp.address;
   LPGBT_drp_input(0).clk(0)                                              <= Ctrl_LPGBT.channel(0).drp.clk;
   LPGBT_drp_input(0).wr_data                                             <= Ctrl_LPGBT.channel(0).drp.wr_data;
   LPGBT_drp_input(0).enable(0)                                           <= Ctrl_LPGBT.channel(0).drp.enable;
   LPGBT_drp_input(0).reset(0)                                            <= Ctrl_LPGBT.channel(0).drp.reset;
   LPGBT_drp_input(0).wr_enable(0)                                        <= Ctrl_LPGBT.channel(0).drp.wr_enable;
   LPGBT_drp_input(1).address                                             <= Ctrl_LPGBT.channel(1).drp.address;
   LPGBT_drp_input(1).clk(0)                                              <= Ctrl_LPGBT.channel(1).drp.clk;
   LPGBT_drp_input(1).wr_data                                             <= Ctrl_LPGBT.channel(1).drp.wr_data;
   LPGBT_drp_input(1).enable(0)                                           <= Ctrl_LPGBT.channel(1).drp.enable;
   LPGBT_drp_input(1).reset(0)                                            <= Ctrl_LPGBT.channel(1).drp.reset;
   LPGBT_drp_input(1).wr_enable(0)                                        <= Ctrl_LPGBT.channel(1).drp.wr_enable;
   LPGBT_drp_input(2).address                                             <= Ctrl_LPGBT.channel(2).drp.address;
   LPGBT_drp_input(2).clk(0)                                              <= Ctrl_LPGBT.channel(2).drp.clk;
   LPGBT_drp_input(2).wr_data                                             <= Ctrl_LPGBT.channel(2).drp.wr_data;
   LPGBT_drp_input(2).enable(0)                                           <= Ctrl_LPGBT.channel(2).drp.enable;
   LPGBT_drp_input(2).reset(0)                                            <= Ctrl_LPGBT.channel(2).drp.reset;
   LPGBT_drp_input(2).wr_enable(0)                                        <= Ctrl_LPGBT.channel(2).drp.wr_enable;
   LPGBT_drp_input(3).address                                             <= Ctrl_LPGBT.channel(3).drp.address;
   LPGBT_drp_input(3).clk(0)                                              <= Ctrl_LPGBT.channel(3).drp.clk;
   LPGBT_drp_input(3).wr_data                                             <= Ctrl_LPGBT.channel(3).drp.wr_data;
   LPGBT_drp_input(3).enable(0)                                           <= Ctrl_LPGBT.channel(3).drp.enable;
   LPGBT_drp_input(3).reset(0)                                            <= Ctrl_LPGBT.channel(3).drp.reset;
   LPGBT_drp_input(3).wr_enable(0)                                        <= Ctrl_LPGBT.channel(3).drp.wr_enable;
   Mon_LPGBT.channel(0).drp.rd_data                                       <= LPGBT_drp_output(0).rd_data;
   Mon_LPGBT.channel(0).drp.rd_data_valid                                 <= LPGBT_drp_output(0).rd_data_valid(0);
   Mon_LPGBT.channel(1).drp.rd_data                                       <= LPGBT_drp_output(1).rd_data;
   Mon_LPGBT.channel(1).drp.rd_data_valid                                 <= LPGBT_drp_output(1).rd_data_valid(0);
   Mon_LPGBT.channel(2).drp.rd_data                                       <= LPGBT_drp_output(2).rd_data;
   Mon_LPGBT.channel(2).drp.rd_data_valid                                 <= LPGBT_drp_output(2).rd_data_valid(0);
   Mon_LPGBT.channel(3).drp.rd_data                                       <= LPGBT_drp_output(3).rd_data;
   Mon_LPGBT.channel(3).drp.rd_data_valid                                 <= LPGBT_drp_output(3).rd_data_valid(0);
  QUAD_GTH_126_LPGBT_inst : entity work.QUAD_GTH_126_LPGBT_wrapper
    port map (
                                            gtyrxn => HAL_serdes_input.QUAD_GTH_126_LPGBT_gtyrxn,
                                            gtyrxp => HAL_serdes_input.QUAD_GTH_126_LPGBT_gtyrxp,
                                            gtytxn => HAL_serdes_output.QUAD_GTH_126_LPGBT_gtytxn,
                                            gtytxp => HAL_serdes_output.QUAD_GTH_126_LPGBT_gtytxp,
                                      common_input => LPGBT_common_input(  1),
                                     common_output => LPGBT_common_output(  1),
                                    userdata_input => LPGBT_userdata_input(  7 downto   4),
                                   userdata_output => LPGBT_userdata_output(  7 downto   4),
                                      clocks_input => LPGBT_clocks_input(  1),
                                     clocks_output => LPGBT_clocks_output(  1),
                                         drp_input => LPGBT_drp_input(  7 downto   4),
                                        drp_output => LPGBT_drp_output(  7 downto   4),
                                     channel_input => LPGBT_channel_input(  7 downto   4),
                                    channel_output => LPGBT_channel_output(  7 downto   4)
    );


    LPGBT_clocks_input(1).gtwiz_reset_clk_freerun(0) <= clk_axi;

    LPGBT_clocks_input(1).gtrefclk00(0) <= refclk_126_clk0;

   LPGBT_common_input(1).gtwiz_userclk_tx_reset(0)                        <= Ctrl_LPGBT.common(1).gtwiz_userclk_tx_reset;
   LPGBT_common_input(1).gtwiz_userclk_rx_reset(0)                        <= Ctrl_LPGBT.common(1).gtwiz_userclk_rx_reset;
   LPGBT_common_input(1).gtwiz_reset_all(0)                               <= Ctrl_LPGBT.common(1).gtwiz_reset_all;
   LPGBT_common_input(1).gtwiz_reset_tx_pll_and_datapath(0)               <= Ctrl_LPGBT.common(1).gtwiz_reset_tx_pll_and_datapath;
   LPGBT_common_input(1).gtwiz_reset_tx_datapath(0)                       <= Ctrl_LPGBT.common(1).gtwiz_reset_tx_datapath;
   LPGBT_common_input(1).gtwiz_reset_rx_pll_and_datapath(0)               <= Ctrl_LPGBT.common(1).gtwiz_reset_rx_pll_and_datapath;
   LPGBT_common_input(1).gtwiz_reset_rx_datapath(0)                       <= Ctrl_LPGBT.common(1).gtwiz_reset_rx_datapath;
   Mon_LPGBT.common(1).gtwiz_userclk_tx_active                            <= LPGBT_common_output(1).gtwiz_userclk_tx_active(0);
   Mon_LPGBT.common(1).gtwiz_userclk_rx_active                            <= LPGBT_common_output(1).gtwiz_userclk_rx_active(0);
   Mon_LPGBT.common(1).gtwiz_reset_rx_cdr_stable                          <= LPGBT_common_output(1).gtwiz_reset_rx_cdr_stable(0);
   Mon_LPGBT.common(1).gtwiz_reset_tx_done                                <= LPGBT_common_output(1).gtwiz_reset_tx_done(0);
   Mon_LPGBT.common(1).gtwiz_reset_rx_done                                <= LPGBT_common_output(1).gtwiz_reset_rx_done(0);
   LPGBT_channel_input(4).eyescanreset(0)                                 <= Ctrl_LPGBT.channel(4).config.eyescanreset;
   LPGBT_channel_input(4).eyescantrigger(0)                               <= Ctrl_LPGBT.channel(4).config.eyescantrigger;
   LPGBT_channel_input(4).loopback                                        <= Ctrl_LPGBT.channel(4).config.loopback;
   LPGBT_channel_input(4).pcsrsvdin                                       <= Ctrl_LPGBT.channel(4).config.pcsrsvdin;
   LPGBT_channel_input(4).rxbufreset(0)                                   <= Ctrl_LPGBT.channel(4).config.rxbufreset;
   LPGBT_channel_input(4).rxcdrhold(0)                                    <= Ctrl_LPGBT.channel(4).config.rxcdrhold;
   LPGBT_channel_input(4).rxdfelpmreset(0)                                <= Ctrl_LPGBT.channel(4).config.rxdfelpmreset;
   LPGBT_channel_input(4).rxlpmen(0)                                      <= Ctrl_LPGBT.channel(4).config.rxlpmen;
   LPGBT_channel_input(4).rxpcsreset(0)                                   <= Ctrl_LPGBT.channel(4).config.rxpcsreset;
   LPGBT_channel_input(4).rxpmareset(0)                                   <= Ctrl_LPGBT.channel(4).config.rxpmareset;
   LPGBT_channel_input(4).rxprbscntreset(0)                               <= Ctrl_LPGBT.channel(4).config.rxprbscntreset;
   LPGBT_channel_input(4).rxprbssel                                       <= Ctrl_LPGBT.channel(4).config.rxprbssel;
   LPGBT_channel_input(4).rxrate                                          <= Ctrl_LPGBT.channel(4).config.rxrate;
   LPGBT_channel_input(4).txctrl2                                         <= Ctrl_LPGBT.channel(4).config.txctrl2;
   LPGBT_channel_input(4).txdiffctrl                                      <= Ctrl_LPGBT.channel(4).config.txdiffctrl;
   LPGBT_channel_input(4).txinhibit(0)                                    <= Ctrl_LPGBT.channel(4).config.txinhibit;
   LPGBT_channel_input(4).txpcsreset(0)                                   <= Ctrl_LPGBT.channel(4).config.txpcsreset;
   LPGBT_channel_input(4).txpmareset(0)                                   <= Ctrl_LPGBT.channel(4).config.txpmareset;
   LPGBT_channel_input(4).txpolarity(0)                                   <= Ctrl_LPGBT.channel(4).config.txpolarity;
   LPGBT_channel_input(4).txpostcursor                                    <= Ctrl_LPGBT.channel(4).config.txpostcursor;
   LPGBT_channel_input(4).txprbsforceerr(0)                               <= Ctrl_LPGBT.channel(4).config.txprbsforceerr;
   LPGBT_channel_input(4).txprbssel                                       <= Ctrl_LPGBT.channel(4).config.txprbssel;
   LPGBT_channel_input(4).txprecursor                                     <= Ctrl_LPGBT.channel(4).config.txprecursor;
   LPGBT_channel_input(5).eyescanreset(0)                                 <= Ctrl_LPGBT.channel(5).config.eyescanreset;
   LPGBT_channel_input(5).eyescantrigger(0)                               <= Ctrl_LPGBT.channel(5).config.eyescantrigger;
   LPGBT_channel_input(5).loopback                                        <= Ctrl_LPGBT.channel(5).config.loopback;
   LPGBT_channel_input(5).pcsrsvdin                                       <= Ctrl_LPGBT.channel(5).config.pcsrsvdin;
   LPGBT_channel_input(5).rxbufreset(0)                                   <= Ctrl_LPGBT.channel(5).config.rxbufreset;
   LPGBT_channel_input(5).rxcdrhold(0)                                    <= Ctrl_LPGBT.channel(5).config.rxcdrhold;
   LPGBT_channel_input(5).rxdfelpmreset(0)                                <= Ctrl_LPGBT.channel(5).config.rxdfelpmreset;
   LPGBT_channel_input(5).rxlpmen(0)                                      <= Ctrl_LPGBT.channel(5).config.rxlpmen;
   LPGBT_channel_input(5).rxpcsreset(0)                                   <= Ctrl_LPGBT.channel(5).config.rxpcsreset;
   LPGBT_channel_input(5).rxpmareset(0)                                   <= Ctrl_LPGBT.channel(5).config.rxpmareset;
   LPGBT_channel_input(5).rxprbscntreset(0)                               <= Ctrl_LPGBT.channel(5).config.rxprbscntreset;
   LPGBT_channel_input(5).rxprbssel                                       <= Ctrl_LPGBT.channel(5).config.rxprbssel;
   LPGBT_channel_input(5).rxrate                                          <= Ctrl_LPGBT.channel(5).config.rxrate;
   LPGBT_channel_input(5).txctrl2                                         <= Ctrl_LPGBT.channel(5).config.txctrl2;
   LPGBT_channel_input(5).txdiffctrl                                      <= Ctrl_LPGBT.channel(5).config.txdiffctrl;
   LPGBT_channel_input(5).txinhibit(0)                                    <= Ctrl_LPGBT.channel(5).config.txinhibit;
   LPGBT_channel_input(5).txpcsreset(0)                                   <= Ctrl_LPGBT.channel(5).config.txpcsreset;
   LPGBT_channel_input(5).txpmareset(0)                                   <= Ctrl_LPGBT.channel(5).config.txpmareset;
   LPGBT_channel_input(5).txpolarity(0)                                   <= Ctrl_LPGBT.channel(5).config.txpolarity;
   LPGBT_channel_input(5).txpostcursor                                    <= Ctrl_LPGBT.channel(5).config.txpostcursor;
   LPGBT_channel_input(5).txprbsforceerr(0)                               <= Ctrl_LPGBT.channel(5).config.txprbsforceerr;
   LPGBT_channel_input(5).txprbssel                                       <= Ctrl_LPGBT.channel(5).config.txprbssel;
   LPGBT_channel_input(5).txprecursor                                     <= Ctrl_LPGBT.channel(5).config.txprecursor;
   LPGBT_channel_input(6).eyescanreset(0)                                 <= Ctrl_LPGBT.channel(6).config.eyescanreset;
   LPGBT_channel_input(6).eyescantrigger(0)                               <= Ctrl_LPGBT.channel(6).config.eyescantrigger;
   LPGBT_channel_input(6).loopback                                        <= Ctrl_LPGBT.channel(6).config.loopback;
   LPGBT_channel_input(6).pcsrsvdin                                       <= Ctrl_LPGBT.channel(6).config.pcsrsvdin;
   LPGBT_channel_input(6).rxbufreset(0)                                   <= Ctrl_LPGBT.channel(6).config.rxbufreset;
   LPGBT_channel_input(6).rxcdrhold(0)                                    <= Ctrl_LPGBT.channel(6).config.rxcdrhold;
   LPGBT_channel_input(6).rxdfelpmreset(0)                                <= Ctrl_LPGBT.channel(6).config.rxdfelpmreset;
   LPGBT_channel_input(6).rxlpmen(0)                                      <= Ctrl_LPGBT.channel(6).config.rxlpmen;
   LPGBT_channel_input(6).rxpcsreset(0)                                   <= Ctrl_LPGBT.channel(6).config.rxpcsreset;
   LPGBT_channel_input(6).rxpmareset(0)                                   <= Ctrl_LPGBT.channel(6).config.rxpmareset;
   LPGBT_channel_input(6).rxprbscntreset(0)                               <= Ctrl_LPGBT.channel(6).config.rxprbscntreset;
   LPGBT_channel_input(6).rxprbssel                                       <= Ctrl_LPGBT.channel(6).config.rxprbssel;
   LPGBT_channel_input(6).rxrate                                          <= Ctrl_LPGBT.channel(6).config.rxrate;
   LPGBT_channel_input(6).txctrl2                                         <= Ctrl_LPGBT.channel(6).config.txctrl2;
   LPGBT_channel_input(6).txdiffctrl                                      <= Ctrl_LPGBT.channel(6).config.txdiffctrl;
   LPGBT_channel_input(6).txinhibit(0)                                    <= Ctrl_LPGBT.channel(6).config.txinhibit;
   LPGBT_channel_input(6).txpcsreset(0)                                   <= Ctrl_LPGBT.channel(6).config.txpcsreset;
   LPGBT_channel_input(6).txpmareset(0)                                   <= Ctrl_LPGBT.channel(6).config.txpmareset;
   LPGBT_channel_input(6).txpolarity(0)                                   <= Ctrl_LPGBT.channel(6).config.txpolarity;
   LPGBT_channel_input(6).txpostcursor                                    <= Ctrl_LPGBT.channel(6).config.txpostcursor;
   LPGBT_channel_input(6).txprbsforceerr(0)                               <= Ctrl_LPGBT.channel(6).config.txprbsforceerr;
   LPGBT_channel_input(6).txprbssel                                       <= Ctrl_LPGBT.channel(6).config.txprbssel;
   LPGBT_channel_input(6).txprecursor                                     <= Ctrl_LPGBT.channel(6).config.txprecursor;
   LPGBT_channel_input(7).eyescanreset(0)                                 <= Ctrl_LPGBT.channel(7).config.eyescanreset;
   LPGBT_channel_input(7).eyescantrigger(0)                               <= Ctrl_LPGBT.channel(7).config.eyescantrigger;
   LPGBT_channel_input(7).loopback                                        <= Ctrl_LPGBT.channel(7).config.loopback;
   LPGBT_channel_input(7).pcsrsvdin                                       <= Ctrl_LPGBT.channel(7).config.pcsrsvdin;
   LPGBT_channel_input(7).rxbufreset(0)                                   <= Ctrl_LPGBT.channel(7).config.rxbufreset;
   LPGBT_channel_input(7).rxcdrhold(0)                                    <= Ctrl_LPGBT.channel(7).config.rxcdrhold;
   LPGBT_channel_input(7).rxdfelpmreset(0)                                <= Ctrl_LPGBT.channel(7).config.rxdfelpmreset;
   LPGBT_channel_input(7).rxlpmen(0)                                      <= Ctrl_LPGBT.channel(7).config.rxlpmen;
   LPGBT_channel_input(7).rxpcsreset(0)                                   <= Ctrl_LPGBT.channel(7).config.rxpcsreset;
   LPGBT_channel_input(7).rxpmareset(0)                                   <= Ctrl_LPGBT.channel(7).config.rxpmareset;
   LPGBT_channel_input(7).rxprbscntreset(0)                               <= Ctrl_LPGBT.channel(7).config.rxprbscntreset;
   LPGBT_channel_input(7).rxprbssel                                       <= Ctrl_LPGBT.channel(7).config.rxprbssel;
   LPGBT_channel_input(7).rxrate                                          <= Ctrl_LPGBT.channel(7).config.rxrate;
   LPGBT_channel_input(7).txctrl2                                         <= Ctrl_LPGBT.channel(7).config.txctrl2;
   LPGBT_channel_input(7).txdiffctrl                                      <= Ctrl_LPGBT.channel(7).config.txdiffctrl;
   LPGBT_channel_input(7).txinhibit(0)                                    <= Ctrl_LPGBT.channel(7).config.txinhibit;
   LPGBT_channel_input(7).txpcsreset(0)                                   <= Ctrl_LPGBT.channel(7).config.txpcsreset;
   LPGBT_channel_input(7).txpmareset(0)                                   <= Ctrl_LPGBT.channel(7).config.txpmareset;
   LPGBT_channel_input(7).txpolarity(0)                                   <= Ctrl_LPGBT.channel(7).config.txpolarity;
   LPGBT_channel_input(7).txpostcursor                                    <= Ctrl_LPGBT.channel(7).config.txpostcursor;
   LPGBT_channel_input(7).txprbsforceerr(0)                               <= Ctrl_LPGBT.channel(7).config.txprbsforceerr;
   LPGBT_channel_input(7).txprbssel                                       <= Ctrl_LPGBT.channel(7).config.txprbssel;
   LPGBT_channel_input(7).txprecursor                                     <= Ctrl_LPGBT.channel(7).config.txprecursor;
   Mon_LPGBT.channel(4).config.TXRX_TYPE                                  <= LPGBT_channel_output(4).TXRX_TYPE;
   Mon_LPGBT.channel(4).config.cplllock                                   <= LPGBT_channel_output(4).cplllock(0);
   Mon_LPGBT.channel(4).config.dmonitorout                                <= LPGBT_channel_output(4).dmonitorout;
   Mon_LPGBT.channel(4).config.eyescandataerror                           <= LPGBT_channel_output(4).eyescandataerror(0);
   Mon_LPGBT.channel(4).config.gtpowergood                                <= LPGBT_channel_output(4).gtpowergood(0);
   Mon_LPGBT.channel(4).config.rxbufstatus                                <= LPGBT_channel_output(4).rxbufstatus;
   Mon_LPGBT.channel(4).config.rxctrl2                                    <= LPGBT_channel_output(4).rxctrl2;
   Mon_LPGBT.channel(4).config.rxpmaresetdone                             <= LPGBT_channel_output(4).rxpmaresetdone(0);
   Mon_LPGBT.channel(4).config.rxprbserr                                  <= LPGBT_channel_output(4).rxprbserr(0);
   Mon_LPGBT.channel(4).config.rxresetdone                                <= LPGBT_channel_output(4).rxresetdone(0);
   Mon_LPGBT.channel(4).config.txbufstatus                                <= LPGBT_channel_output(4).txbufstatus;
   Mon_LPGBT.channel(4).config.txpmaresetdone                             <= LPGBT_channel_output(4).txpmaresetdone(0);
   Mon_LPGBT.channel(4).config.txresetdone                                <= LPGBT_channel_output(4).txresetdone(0);
   Mon_LPGBT.channel(5).config.TXRX_TYPE                                  <= LPGBT_channel_output(5).TXRX_TYPE;
   Mon_LPGBT.channel(5).config.cplllock                                   <= LPGBT_channel_output(5).cplllock(0);
   Mon_LPGBT.channel(5).config.dmonitorout                                <= LPGBT_channel_output(5).dmonitorout;
   Mon_LPGBT.channel(5).config.eyescandataerror                           <= LPGBT_channel_output(5).eyescandataerror(0);
   Mon_LPGBT.channel(5).config.gtpowergood                                <= LPGBT_channel_output(5).gtpowergood(0);
   Mon_LPGBT.channel(5).config.rxbufstatus                                <= LPGBT_channel_output(5).rxbufstatus;
   Mon_LPGBT.channel(5).config.rxctrl2                                    <= LPGBT_channel_output(5).rxctrl2;
   Mon_LPGBT.channel(5).config.rxpmaresetdone                             <= LPGBT_channel_output(5).rxpmaresetdone(0);
   Mon_LPGBT.channel(5).config.rxprbserr                                  <= LPGBT_channel_output(5).rxprbserr(0);
   Mon_LPGBT.channel(5).config.rxresetdone                                <= LPGBT_channel_output(5).rxresetdone(0);
   Mon_LPGBT.channel(5).config.txbufstatus                                <= LPGBT_channel_output(5).txbufstatus;
   Mon_LPGBT.channel(5).config.txpmaresetdone                             <= LPGBT_channel_output(5).txpmaresetdone(0);
   Mon_LPGBT.channel(5).config.txresetdone                                <= LPGBT_channel_output(5).txresetdone(0);
   Mon_LPGBT.channel(6).config.TXRX_TYPE                                  <= LPGBT_channel_output(6).TXRX_TYPE;
   Mon_LPGBT.channel(6).config.cplllock                                   <= LPGBT_channel_output(6).cplllock(0);
   Mon_LPGBT.channel(6).config.dmonitorout                                <= LPGBT_channel_output(6).dmonitorout;
   Mon_LPGBT.channel(6).config.eyescandataerror                           <= LPGBT_channel_output(6).eyescandataerror(0);
   Mon_LPGBT.channel(6).config.gtpowergood                                <= LPGBT_channel_output(6).gtpowergood(0);
   Mon_LPGBT.channel(6).config.rxbufstatus                                <= LPGBT_channel_output(6).rxbufstatus;
   Mon_LPGBT.channel(6).config.rxctrl2                                    <= LPGBT_channel_output(6).rxctrl2;
   Mon_LPGBT.channel(6).config.rxpmaresetdone                             <= LPGBT_channel_output(6).rxpmaresetdone(0);
   Mon_LPGBT.channel(6).config.rxprbserr                                  <= LPGBT_channel_output(6).rxprbserr(0);
   Mon_LPGBT.channel(6).config.rxresetdone                                <= LPGBT_channel_output(6).rxresetdone(0);
   Mon_LPGBT.channel(6).config.txbufstatus                                <= LPGBT_channel_output(6).txbufstatus;
   Mon_LPGBT.channel(6).config.txpmaresetdone                             <= LPGBT_channel_output(6).txpmaresetdone(0);
   Mon_LPGBT.channel(6).config.txresetdone                                <= LPGBT_channel_output(6).txresetdone(0);
   Mon_LPGBT.channel(7).config.TXRX_TYPE                                  <= LPGBT_channel_output(7).TXRX_TYPE;
   Mon_LPGBT.channel(7).config.cplllock                                   <= LPGBT_channel_output(7).cplllock(0);
   Mon_LPGBT.channel(7).config.dmonitorout                                <= LPGBT_channel_output(7).dmonitorout;
   Mon_LPGBT.channel(7).config.eyescandataerror                           <= LPGBT_channel_output(7).eyescandataerror(0);
   Mon_LPGBT.channel(7).config.gtpowergood                                <= LPGBT_channel_output(7).gtpowergood(0);
   Mon_LPGBT.channel(7).config.rxbufstatus                                <= LPGBT_channel_output(7).rxbufstatus;
   Mon_LPGBT.channel(7).config.rxctrl2                                    <= LPGBT_channel_output(7).rxctrl2;
   Mon_LPGBT.channel(7).config.rxpmaresetdone                             <= LPGBT_channel_output(7).rxpmaresetdone(0);
   Mon_LPGBT.channel(7).config.rxprbserr                                  <= LPGBT_channel_output(7).rxprbserr(0);
   Mon_LPGBT.channel(7).config.rxresetdone                                <= LPGBT_channel_output(7).rxresetdone(0);
   Mon_LPGBT.channel(7).config.txbufstatus                                <= LPGBT_channel_output(7).txbufstatus;
   Mon_LPGBT.channel(7).config.txpmaresetdone                             <= LPGBT_channel_output(7).txpmaresetdone(0);
   Mon_LPGBT.channel(7).config.txresetdone                                <= LPGBT_channel_output(7).txresetdone(0);
   LPGBT_drp_input(4).address                                             <= Ctrl_LPGBT.channel(4).drp.address;
   LPGBT_drp_input(4).clk(0)                                              <= Ctrl_LPGBT.channel(4).drp.clk;
   LPGBT_drp_input(4).wr_data                                             <= Ctrl_LPGBT.channel(4).drp.wr_data;
   LPGBT_drp_input(4).enable(0)                                           <= Ctrl_LPGBT.channel(4).drp.enable;
   LPGBT_drp_input(4).reset(0)                                            <= Ctrl_LPGBT.channel(4).drp.reset;
   LPGBT_drp_input(4).wr_enable(0)                                        <= Ctrl_LPGBT.channel(4).drp.wr_enable;
   LPGBT_drp_input(5).address                                             <= Ctrl_LPGBT.channel(5).drp.address;
   LPGBT_drp_input(5).clk(0)                                              <= Ctrl_LPGBT.channel(5).drp.clk;
   LPGBT_drp_input(5).wr_data                                             <= Ctrl_LPGBT.channel(5).drp.wr_data;
   LPGBT_drp_input(5).enable(0)                                           <= Ctrl_LPGBT.channel(5).drp.enable;
   LPGBT_drp_input(5).reset(0)                                            <= Ctrl_LPGBT.channel(5).drp.reset;
   LPGBT_drp_input(5).wr_enable(0)                                        <= Ctrl_LPGBT.channel(5).drp.wr_enable;
   LPGBT_drp_input(6).address                                             <= Ctrl_LPGBT.channel(6).drp.address;
   LPGBT_drp_input(6).clk(0)                                              <= Ctrl_LPGBT.channel(6).drp.clk;
   LPGBT_drp_input(6).wr_data                                             <= Ctrl_LPGBT.channel(6).drp.wr_data;
   LPGBT_drp_input(6).enable(0)                                           <= Ctrl_LPGBT.channel(6).drp.enable;
   LPGBT_drp_input(6).reset(0)                                            <= Ctrl_LPGBT.channel(6).drp.reset;
   LPGBT_drp_input(6).wr_enable(0)                                        <= Ctrl_LPGBT.channel(6).drp.wr_enable;
   LPGBT_drp_input(7).address                                             <= Ctrl_LPGBT.channel(7).drp.address;
   LPGBT_drp_input(7).clk(0)                                              <= Ctrl_LPGBT.channel(7).drp.clk;
   LPGBT_drp_input(7).wr_data                                             <= Ctrl_LPGBT.channel(7).drp.wr_data;
   LPGBT_drp_input(7).enable(0)                                           <= Ctrl_LPGBT.channel(7).drp.enable;
   LPGBT_drp_input(7).reset(0)                                            <= Ctrl_LPGBT.channel(7).drp.reset;
   LPGBT_drp_input(7).wr_enable(0)                                        <= Ctrl_LPGBT.channel(7).drp.wr_enable;
   Mon_LPGBT.channel(4).drp.rd_data                                       <= LPGBT_drp_output(4).rd_data;
   Mon_LPGBT.channel(4).drp.rd_data_valid                                 <= LPGBT_drp_output(4).rd_data_valid(0);
   Mon_LPGBT.channel(5).drp.rd_data                                       <= LPGBT_drp_output(5).rd_data;
   Mon_LPGBT.channel(5).drp.rd_data_valid                                 <= LPGBT_drp_output(5).rd_data_valid(0);
   Mon_LPGBT.channel(6).drp.rd_data                                       <= LPGBT_drp_output(6).rd_data;
   Mon_LPGBT.channel(6).drp.rd_data_valid                                 <= LPGBT_drp_output(6).rd_data_valid(0);
   Mon_LPGBT.channel(7).drp.rd_data                                       <= LPGBT_drp_output(7).rd_data;
   Mon_LPGBT.channel(7).drp.rd_data_valid                                 <= LPGBT_drp_output(7).rd_data_valid(0);
  QUAD_GTH_127_LPGBT_inst : entity work.QUAD_GTH_127_LPGBT_wrapper
    port map (
                                            gtyrxn => HAL_serdes_input.QUAD_GTH_127_LPGBT_gtyrxn,
                                            gtyrxp => HAL_serdes_input.QUAD_GTH_127_LPGBT_gtyrxp,
                                            gtytxn => HAL_serdes_output.QUAD_GTH_127_LPGBT_gtytxn,
                                            gtytxp => HAL_serdes_output.QUAD_GTH_127_LPGBT_gtytxp,
                                      common_input => LPGBT_common_input(  2),
                                     common_output => LPGBT_common_output(  2),
                                    userdata_input => LPGBT_userdata_input( 11 downto   8),
                                   userdata_output => LPGBT_userdata_output( 11 downto   8),
                                      clocks_input => LPGBT_clocks_input(  2),
                                     clocks_output => LPGBT_clocks_output(  2),
                                         drp_input => LPGBT_drp_input( 11 downto   8),
                                        drp_output => LPGBT_drp_output( 11 downto   8),
                                     channel_input => LPGBT_channel_input( 11 downto   8),
                                    channel_output => LPGBT_channel_output( 11 downto   8)
    );


    LPGBT_clocks_input(2).gtwiz_reset_clk_freerun(0) <= clk_axi;

    LPGBT_clocks_input(2).gtrefclk00(0) <= refclk_126_clk0;

   LPGBT_common_input(2).gtwiz_userclk_tx_reset(0)                        <= Ctrl_LPGBT.common(2).gtwiz_userclk_tx_reset;
   LPGBT_common_input(2).gtwiz_userclk_rx_reset(0)                        <= Ctrl_LPGBT.common(2).gtwiz_userclk_rx_reset;
   LPGBT_common_input(2).gtwiz_reset_all(0)                               <= Ctrl_LPGBT.common(2).gtwiz_reset_all;
   LPGBT_common_input(2).gtwiz_reset_tx_pll_and_datapath(0)               <= Ctrl_LPGBT.common(2).gtwiz_reset_tx_pll_and_datapath;
   LPGBT_common_input(2).gtwiz_reset_tx_datapath(0)                       <= Ctrl_LPGBT.common(2).gtwiz_reset_tx_datapath;
   LPGBT_common_input(2).gtwiz_reset_rx_pll_and_datapath(0)               <= Ctrl_LPGBT.common(2).gtwiz_reset_rx_pll_and_datapath;
   LPGBT_common_input(2).gtwiz_reset_rx_datapath(0)                       <= Ctrl_LPGBT.common(2).gtwiz_reset_rx_datapath;
   Mon_LPGBT.common(2).gtwiz_userclk_tx_active                            <= LPGBT_common_output(2).gtwiz_userclk_tx_active(0);
   Mon_LPGBT.common(2).gtwiz_userclk_rx_active                            <= LPGBT_common_output(2).gtwiz_userclk_rx_active(0);
   Mon_LPGBT.common(2).gtwiz_reset_rx_cdr_stable                          <= LPGBT_common_output(2).gtwiz_reset_rx_cdr_stable(0);
   Mon_LPGBT.common(2).gtwiz_reset_tx_done                                <= LPGBT_common_output(2).gtwiz_reset_tx_done(0);
   Mon_LPGBT.common(2).gtwiz_reset_rx_done                                <= LPGBT_common_output(2).gtwiz_reset_rx_done(0);
   LPGBT_channel_input(8).eyescanreset(0)                                 <= Ctrl_LPGBT.channel(8).config.eyescanreset;
   LPGBT_channel_input(8).eyescantrigger(0)                               <= Ctrl_LPGBT.channel(8).config.eyescantrigger;
   LPGBT_channel_input(8).loopback                                        <= Ctrl_LPGBT.channel(8).config.loopback;
   LPGBT_channel_input(8).pcsrsvdin                                       <= Ctrl_LPGBT.channel(8).config.pcsrsvdin;
   LPGBT_channel_input(8).rxbufreset(0)                                   <= Ctrl_LPGBT.channel(8).config.rxbufreset;
   LPGBT_channel_input(8).rxcdrhold(0)                                    <= Ctrl_LPGBT.channel(8).config.rxcdrhold;
   LPGBT_channel_input(8).rxdfelpmreset(0)                                <= Ctrl_LPGBT.channel(8).config.rxdfelpmreset;
   LPGBT_channel_input(8).rxlpmen(0)                                      <= Ctrl_LPGBT.channel(8).config.rxlpmen;
   LPGBT_channel_input(8).rxpcsreset(0)                                   <= Ctrl_LPGBT.channel(8).config.rxpcsreset;
   LPGBT_channel_input(8).rxpmareset(0)                                   <= Ctrl_LPGBT.channel(8).config.rxpmareset;
   LPGBT_channel_input(8).rxprbscntreset(0)                               <= Ctrl_LPGBT.channel(8).config.rxprbscntreset;
   LPGBT_channel_input(8).rxprbssel                                       <= Ctrl_LPGBT.channel(8).config.rxprbssel;
   LPGBT_channel_input(8).rxrate                                          <= Ctrl_LPGBT.channel(8).config.rxrate;
   LPGBT_channel_input(8).txctrl2                                         <= Ctrl_LPGBT.channel(8).config.txctrl2;
   LPGBT_channel_input(8).txdiffctrl                                      <= Ctrl_LPGBT.channel(8).config.txdiffctrl;
   LPGBT_channel_input(8).txinhibit(0)                                    <= Ctrl_LPGBT.channel(8).config.txinhibit;
   LPGBT_channel_input(8).txpcsreset(0)                                   <= Ctrl_LPGBT.channel(8).config.txpcsreset;
   LPGBT_channel_input(8).txpmareset(0)                                   <= Ctrl_LPGBT.channel(8).config.txpmareset;
   LPGBT_channel_input(8).txpolarity(0)                                   <= Ctrl_LPGBT.channel(8).config.txpolarity;
   LPGBT_channel_input(8).txpostcursor                                    <= Ctrl_LPGBT.channel(8).config.txpostcursor;
   LPGBT_channel_input(8).txprbsforceerr(0)                               <= Ctrl_LPGBT.channel(8).config.txprbsforceerr;
   LPGBT_channel_input(8).txprbssel                                       <= Ctrl_LPGBT.channel(8).config.txprbssel;
   LPGBT_channel_input(8).txprecursor                                     <= Ctrl_LPGBT.channel(8).config.txprecursor;
   LPGBT_channel_input(9).eyescanreset(0)                                 <= Ctrl_LPGBT.channel(9).config.eyescanreset;
   LPGBT_channel_input(9).eyescantrigger(0)                               <= Ctrl_LPGBT.channel(9).config.eyescantrigger;
   LPGBT_channel_input(9).loopback                                        <= Ctrl_LPGBT.channel(9).config.loopback;
   LPGBT_channel_input(9).pcsrsvdin                                       <= Ctrl_LPGBT.channel(9).config.pcsrsvdin;
   LPGBT_channel_input(9).rxbufreset(0)                                   <= Ctrl_LPGBT.channel(9).config.rxbufreset;
   LPGBT_channel_input(9).rxcdrhold(0)                                    <= Ctrl_LPGBT.channel(9).config.rxcdrhold;
   LPGBT_channel_input(9).rxdfelpmreset(0)                                <= Ctrl_LPGBT.channel(9).config.rxdfelpmreset;
   LPGBT_channel_input(9).rxlpmen(0)                                      <= Ctrl_LPGBT.channel(9).config.rxlpmen;
   LPGBT_channel_input(9).rxpcsreset(0)                                   <= Ctrl_LPGBT.channel(9).config.rxpcsreset;
   LPGBT_channel_input(9).rxpmareset(0)                                   <= Ctrl_LPGBT.channel(9).config.rxpmareset;
   LPGBT_channel_input(9).rxprbscntreset(0)                               <= Ctrl_LPGBT.channel(9).config.rxprbscntreset;
   LPGBT_channel_input(9).rxprbssel                                       <= Ctrl_LPGBT.channel(9).config.rxprbssel;
   LPGBT_channel_input(9).rxrate                                          <= Ctrl_LPGBT.channel(9).config.rxrate;
   LPGBT_channel_input(9).txctrl2                                         <= Ctrl_LPGBT.channel(9).config.txctrl2;
   LPGBT_channel_input(9).txdiffctrl                                      <= Ctrl_LPGBT.channel(9).config.txdiffctrl;
   LPGBT_channel_input(9).txinhibit(0)                                    <= Ctrl_LPGBT.channel(9).config.txinhibit;
   LPGBT_channel_input(9).txpcsreset(0)                                   <= Ctrl_LPGBT.channel(9).config.txpcsreset;
   LPGBT_channel_input(9).txpmareset(0)                                   <= Ctrl_LPGBT.channel(9).config.txpmareset;
   LPGBT_channel_input(9).txpolarity(0)                                   <= Ctrl_LPGBT.channel(9).config.txpolarity;
   LPGBT_channel_input(9).txpostcursor                                    <= Ctrl_LPGBT.channel(9).config.txpostcursor;
   LPGBT_channel_input(9).txprbsforceerr(0)                               <= Ctrl_LPGBT.channel(9).config.txprbsforceerr;
   LPGBT_channel_input(9).txprbssel                                       <= Ctrl_LPGBT.channel(9).config.txprbssel;
   LPGBT_channel_input(9).txprecursor                                     <= Ctrl_LPGBT.channel(9).config.txprecursor;
   LPGBT_channel_input(10).eyescanreset(0)                                <= Ctrl_LPGBT.channel(10).config.eyescanreset;
   LPGBT_channel_input(10).eyescantrigger(0)                              <= Ctrl_LPGBT.channel(10).config.eyescantrigger;
   LPGBT_channel_input(10).loopback                                       <= Ctrl_LPGBT.channel(10).config.loopback;
   LPGBT_channel_input(10).pcsrsvdin                                      <= Ctrl_LPGBT.channel(10).config.pcsrsvdin;
   LPGBT_channel_input(10).rxbufreset(0)                                  <= Ctrl_LPGBT.channel(10).config.rxbufreset;
   LPGBT_channel_input(10).rxcdrhold(0)                                   <= Ctrl_LPGBT.channel(10).config.rxcdrhold;
   LPGBT_channel_input(10).rxdfelpmreset(0)                               <= Ctrl_LPGBT.channel(10).config.rxdfelpmreset;
   LPGBT_channel_input(10).rxlpmen(0)                                     <= Ctrl_LPGBT.channel(10).config.rxlpmen;
   LPGBT_channel_input(10).rxpcsreset(0)                                  <= Ctrl_LPGBT.channel(10).config.rxpcsreset;
   LPGBT_channel_input(10).rxpmareset(0)                                  <= Ctrl_LPGBT.channel(10).config.rxpmareset;
   LPGBT_channel_input(10).rxprbscntreset(0)                              <= Ctrl_LPGBT.channel(10).config.rxprbscntreset;
   LPGBT_channel_input(10).rxprbssel                                      <= Ctrl_LPGBT.channel(10).config.rxprbssel;
   LPGBT_channel_input(10).rxrate                                         <= Ctrl_LPGBT.channel(10).config.rxrate;
   LPGBT_channel_input(10).txctrl2                                        <= Ctrl_LPGBT.channel(10).config.txctrl2;
   LPGBT_channel_input(10).txdiffctrl                                     <= Ctrl_LPGBT.channel(10).config.txdiffctrl;
   LPGBT_channel_input(10).txinhibit(0)                                   <= Ctrl_LPGBT.channel(10).config.txinhibit;
   LPGBT_channel_input(10).txpcsreset(0)                                  <= Ctrl_LPGBT.channel(10).config.txpcsreset;
   LPGBT_channel_input(10).txpmareset(0)                                  <= Ctrl_LPGBT.channel(10).config.txpmareset;
   LPGBT_channel_input(10).txpolarity(0)                                  <= Ctrl_LPGBT.channel(10).config.txpolarity;
   LPGBT_channel_input(10).txpostcursor                                   <= Ctrl_LPGBT.channel(10).config.txpostcursor;
   LPGBT_channel_input(10).txprbsforceerr(0)                              <= Ctrl_LPGBT.channel(10).config.txprbsforceerr;
   LPGBT_channel_input(10).txprbssel                                      <= Ctrl_LPGBT.channel(10).config.txprbssel;
   LPGBT_channel_input(10).txprecursor                                    <= Ctrl_LPGBT.channel(10).config.txprecursor;
   LPGBT_channel_input(11).eyescanreset(0)                                <= Ctrl_LPGBT.channel(11).config.eyescanreset;
   LPGBT_channel_input(11).eyescantrigger(0)                              <= Ctrl_LPGBT.channel(11).config.eyescantrigger;
   LPGBT_channel_input(11).loopback                                       <= Ctrl_LPGBT.channel(11).config.loopback;
   LPGBT_channel_input(11).pcsrsvdin                                      <= Ctrl_LPGBT.channel(11).config.pcsrsvdin;
   LPGBT_channel_input(11).rxbufreset(0)                                  <= Ctrl_LPGBT.channel(11).config.rxbufreset;
   LPGBT_channel_input(11).rxcdrhold(0)                                   <= Ctrl_LPGBT.channel(11).config.rxcdrhold;
   LPGBT_channel_input(11).rxdfelpmreset(0)                               <= Ctrl_LPGBT.channel(11).config.rxdfelpmreset;
   LPGBT_channel_input(11).rxlpmen(0)                                     <= Ctrl_LPGBT.channel(11).config.rxlpmen;
   LPGBT_channel_input(11).rxpcsreset(0)                                  <= Ctrl_LPGBT.channel(11).config.rxpcsreset;
   LPGBT_channel_input(11).rxpmareset(0)                                  <= Ctrl_LPGBT.channel(11).config.rxpmareset;
   LPGBT_channel_input(11).rxprbscntreset(0)                              <= Ctrl_LPGBT.channel(11).config.rxprbscntreset;
   LPGBT_channel_input(11).rxprbssel                                      <= Ctrl_LPGBT.channel(11).config.rxprbssel;
   LPGBT_channel_input(11).rxrate                                         <= Ctrl_LPGBT.channel(11).config.rxrate;
   LPGBT_channel_input(11).txctrl2                                        <= Ctrl_LPGBT.channel(11).config.txctrl2;
   LPGBT_channel_input(11).txdiffctrl                                     <= Ctrl_LPGBT.channel(11).config.txdiffctrl;
   LPGBT_channel_input(11).txinhibit(0)                                   <= Ctrl_LPGBT.channel(11).config.txinhibit;
   LPGBT_channel_input(11).txpcsreset(0)                                  <= Ctrl_LPGBT.channel(11).config.txpcsreset;
   LPGBT_channel_input(11).txpmareset(0)                                  <= Ctrl_LPGBT.channel(11).config.txpmareset;
   LPGBT_channel_input(11).txpolarity(0)                                  <= Ctrl_LPGBT.channel(11).config.txpolarity;
   LPGBT_channel_input(11).txpostcursor                                   <= Ctrl_LPGBT.channel(11).config.txpostcursor;
   LPGBT_channel_input(11).txprbsforceerr(0)                              <= Ctrl_LPGBT.channel(11).config.txprbsforceerr;
   LPGBT_channel_input(11).txprbssel                                      <= Ctrl_LPGBT.channel(11).config.txprbssel;
   LPGBT_channel_input(11).txprecursor                                    <= Ctrl_LPGBT.channel(11).config.txprecursor;
   Mon_LPGBT.channel(8).config.TXRX_TYPE                                  <= LPGBT_channel_output(8).TXRX_TYPE;
   Mon_LPGBT.channel(8).config.cplllock                                   <= LPGBT_channel_output(8).cplllock(0);
   Mon_LPGBT.channel(8).config.dmonitorout                                <= LPGBT_channel_output(8).dmonitorout;
   Mon_LPGBT.channel(8).config.eyescandataerror                           <= LPGBT_channel_output(8).eyescandataerror(0);
   Mon_LPGBT.channel(8).config.gtpowergood                                <= LPGBT_channel_output(8).gtpowergood(0);
   Mon_LPGBT.channel(8).config.rxbufstatus                                <= LPGBT_channel_output(8).rxbufstatus;
   Mon_LPGBT.channel(8).config.rxctrl2                                    <= LPGBT_channel_output(8).rxctrl2;
   Mon_LPGBT.channel(8).config.rxpmaresetdone                             <= LPGBT_channel_output(8).rxpmaresetdone(0);
   Mon_LPGBT.channel(8).config.rxprbserr                                  <= LPGBT_channel_output(8).rxprbserr(0);
   Mon_LPGBT.channel(8).config.rxresetdone                                <= LPGBT_channel_output(8).rxresetdone(0);
   Mon_LPGBT.channel(8).config.txbufstatus                                <= LPGBT_channel_output(8).txbufstatus;
   Mon_LPGBT.channel(8).config.txpmaresetdone                             <= LPGBT_channel_output(8).txpmaresetdone(0);
   Mon_LPGBT.channel(8).config.txresetdone                                <= LPGBT_channel_output(8).txresetdone(0);
   Mon_LPGBT.channel(9).config.TXRX_TYPE                                  <= LPGBT_channel_output(9).TXRX_TYPE;
   Mon_LPGBT.channel(9).config.cplllock                                   <= LPGBT_channel_output(9).cplllock(0);
   Mon_LPGBT.channel(9).config.dmonitorout                                <= LPGBT_channel_output(9).dmonitorout;
   Mon_LPGBT.channel(9).config.eyescandataerror                           <= LPGBT_channel_output(9).eyescandataerror(0);
   Mon_LPGBT.channel(9).config.gtpowergood                                <= LPGBT_channel_output(9).gtpowergood(0);
   Mon_LPGBT.channel(9).config.rxbufstatus                                <= LPGBT_channel_output(9).rxbufstatus;
   Mon_LPGBT.channel(9).config.rxctrl2                                    <= LPGBT_channel_output(9).rxctrl2;
   Mon_LPGBT.channel(9).config.rxpmaresetdone                             <= LPGBT_channel_output(9).rxpmaresetdone(0);
   Mon_LPGBT.channel(9).config.rxprbserr                                  <= LPGBT_channel_output(9).rxprbserr(0);
   Mon_LPGBT.channel(9).config.rxresetdone                                <= LPGBT_channel_output(9).rxresetdone(0);
   Mon_LPGBT.channel(9).config.txbufstatus                                <= LPGBT_channel_output(9).txbufstatus;
   Mon_LPGBT.channel(9).config.txpmaresetdone                             <= LPGBT_channel_output(9).txpmaresetdone(0);
   Mon_LPGBT.channel(9).config.txresetdone                                <= LPGBT_channel_output(9).txresetdone(0);
   Mon_LPGBT.channel(10).config.TXRX_TYPE                                 <= LPGBT_channel_output(10).TXRX_TYPE;
   Mon_LPGBT.channel(10).config.cplllock                                  <= LPGBT_channel_output(10).cplllock(0);
   Mon_LPGBT.channel(10).config.dmonitorout                               <= LPGBT_channel_output(10).dmonitorout;
   Mon_LPGBT.channel(10).config.eyescandataerror                          <= LPGBT_channel_output(10).eyescandataerror(0);
   Mon_LPGBT.channel(10).config.gtpowergood                               <= LPGBT_channel_output(10).gtpowergood(0);
   Mon_LPGBT.channel(10).config.rxbufstatus                               <= LPGBT_channel_output(10).rxbufstatus;
   Mon_LPGBT.channel(10).config.rxctrl2                                   <= LPGBT_channel_output(10).rxctrl2;
   Mon_LPGBT.channel(10).config.rxpmaresetdone                            <= LPGBT_channel_output(10).rxpmaresetdone(0);
   Mon_LPGBT.channel(10).config.rxprbserr                                 <= LPGBT_channel_output(10).rxprbserr(0);
   Mon_LPGBT.channel(10).config.rxresetdone                               <= LPGBT_channel_output(10).rxresetdone(0);
   Mon_LPGBT.channel(10).config.txbufstatus                               <= LPGBT_channel_output(10).txbufstatus;
   Mon_LPGBT.channel(10).config.txpmaresetdone                            <= LPGBT_channel_output(10).txpmaresetdone(0);
   Mon_LPGBT.channel(10).config.txresetdone                               <= LPGBT_channel_output(10).txresetdone(0);
   Mon_LPGBT.channel(11).config.TXRX_TYPE                                 <= LPGBT_channel_output(11).TXRX_TYPE;
   Mon_LPGBT.channel(11).config.cplllock                                  <= LPGBT_channel_output(11).cplllock(0);
   Mon_LPGBT.channel(11).config.dmonitorout                               <= LPGBT_channel_output(11).dmonitorout;
   Mon_LPGBT.channel(11).config.eyescandataerror                          <= LPGBT_channel_output(11).eyescandataerror(0);
   Mon_LPGBT.channel(11).config.gtpowergood                               <= LPGBT_channel_output(11).gtpowergood(0);
   Mon_LPGBT.channel(11).config.rxbufstatus                               <= LPGBT_channel_output(11).rxbufstatus;
   Mon_LPGBT.channel(11).config.rxctrl2                                   <= LPGBT_channel_output(11).rxctrl2;
   Mon_LPGBT.channel(11).config.rxpmaresetdone                            <= LPGBT_channel_output(11).rxpmaresetdone(0);
   Mon_LPGBT.channel(11).config.rxprbserr                                 <= LPGBT_channel_output(11).rxprbserr(0);
   Mon_LPGBT.channel(11).config.rxresetdone                               <= LPGBT_channel_output(11).rxresetdone(0);
   Mon_LPGBT.channel(11).config.txbufstatus                               <= LPGBT_channel_output(11).txbufstatus;
   Mon_LPGBT.channel(11).config.txpmaresetdone                            <= LPGBT_channel_output(11).txpmaresetdone(0);
   Mon_LPGBT.channel(11).config.txresetdone                               <= LPGBT_channel_output(11).txresetdone(0);
   LPGBT_drp_input(8).address                                             <= Ctrl_LPGBT.channel(8).drp.address;
   LPGBT_drp_input(8).clk(0)                                              <= Ctrl_LPGBT.channel(8).drp.clk;
   LPGBT_drp_input(8).wr_data                                             <= Ctrl_LPGBT.channel(8).drp.wr_data;
   LPGBT_drp_input(8).enable(0)                                           <= Ctrl_LPGBT.channel(8).drp.enable;
   LPGBT_drp_input(8).reset(0)                                            <= Ctrl_LPGBT.channel(8).drp.reset;
   LPGBT_drp_input(8).wr_enable(0)                                        <= Ctrl_LPGBT.channel(8).drp.wr_enable;
   LPGBT_drp_input(9).address                                             <= Ctrl_LPGBT.channel(9).drp.address;
   LPGBT_drp_input(9).clk(0)                                              <= Ctrl_LPGBT.channel(9).drp.clk;
   LPGBT_drp_input(9).wr_data                                             <= Ctrl_LPGBT.channel(9).drp.wr_data;
   LPGBT_drp_input(9).enable(0)                                           <= Ctrl_LPGBT.channel(9).drp.enable;
   LPGBT_drp_input(9).reset(0)                                            <= Ctrl_LPGBT.channel(9).drp.reset;
   LPGBT_drp_input(9).wr_enable(0)                                        <= Ctrl_LPGBT.channel(9).drp.wr_enable;
   LPGBT_drp_input(10).address                                            <= Ctrl_LPGBT.channel(10).drp.address;
   LPGBT_drp_input(10).clk(0)                                             <= Ctrl_LPGBT.channel(10).drp.clk;
   LPGBT_drp_input(10).wr_data                                            <= Ctrl_LPGBT.channel(10).drp.wr_data;
   LPGBT_drp_input(10).enable(0)                                          <= Ctrl_LPGBT.channel(10).drp.enable;
   LPGBT_drp_input(10).reset(0)                                           <= Ctrl_LPGBT.channel(10).drp.reset;
   LPGBT_drp_input(10).wr_enable(0)                                       <= Ctrl_LPGBT.channel(10).drp.wr_enable;
   LPGBT_drp_input(11).address                                            <= Ctrl_LPGBT.channel(11).drp.address;
   LPGBT_drp_input(11).clk(0)                                             <= Ctrl_LPGBT.channel(11).drp.clk;
   LPGBT_drp_input(11).wr_data                                            <= Ctrl_LPGBT.channel(11).drp.wr_data;
   LPGBT_drp_input(11).enable(0)                                          <= Ctrl_LPGBT.channel(11).drp.enable;
   LPGBT_drp_input(11).reset(0)                                           <= Ctrl_LPGBT.channel(11).drp.reset;
   LPGBT_drp_input(11).wr_enable(0)                                       <= Ctrl_LPGBT.channel(11).drp.wr_enable;
   Mon_LPGBT.channel(8).drp.rd_data                                       <= LPGBT_drp_output(8).rd_data;
   Mon_LPGBT.channel(8).drp.rd_data_valid                                 <= LPGBT_drp_output(8).rd_data_valid(0);
   Mon_LPGBT.channel(9).drp.rd_data                                       <= LPGBT_drp_output(9).rd_data;
   Mon_LPGBT.channel(9).drp.rd_data_valid                                 <= LPGBT_drp_output(9).rd_data_valid(0);
   Mon_LPGBT.channel(10).drp.rd_data                                      <= LPGBT_drp_output(10).rd_data;
   Mon_LPGBT.channel(10).drp.rd_data_valid                                <= LPGBT_drp_output(10).rd_data_valid(0);
   Mon_LPGBT.channel(11).drp.rd_data                                      <= LPGBT_drp_output(11).rd_data;
   Mon_LPGBT.channel(11).drp.rd_data_valid                                <= LPGBT_drp_output(11).rd_data_valid(0);


end architecture behavioral;
