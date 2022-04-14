library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.axiRegPkg.all;
use work.TCDS_Ctrl.all;
use work.types.all;

Library UNISIM;
use UNISIM.vcomponents.all;


entity TCDS is
  generic (
    ALLOCATED_MEMORY_RANGE : integer
    );
  port (
    clk_axi              : in  std_logic; --50 MHz
    clk_200              : in  std_logic;
    reset_axi_n          : in  std_logic;
    readMOSI             : in  AXIreadMOSI;
    readMISO             : out AXIreadMISO;
    writeMOSI            : in  AXIwriteMOSI;
    writeMISO            : out AXIwriteMISO;
    refclk1_p : in std_logic;
    refclk1_n : in std_logic; 
    tx_p : out std_logic;
    tx_n : out std_logic;
    rx_p : in  std_logic;
    rx_n : in  std_logic);

end entity TCDS;

architecture behavioral of TCDS is
  signal reset : std_logic;
  signal refclk : std_logic;
  signal refclk0 : std_logic;
  signal refclk1 : std_logic;
  signal qpll0outclk : std_logic;
  signal qpll0refclk : std_logic;
  signal counts_txoutclk : std_logic_vector(31 downto 0);

  signal clk_tx_int     : std_logic;
  signal clk_tx_int_raw : std_logic;
  signal clk_rx_int     : std_logic;
  signal clk_rx_int_raw : std_logic;
  
  signal Mon              :  TCDS_Mon_t;
  signal Ctrl             :  TCDS_Ctrl_t;

  signal tx_data : slv_32_t;
  signal rx_data : slv_32_t;
  signal tx_k_data : slv_4_t;
  signal rx_k_data : slv_4_t;

  signal tx_k_data_fixed : slv_4_t;
  signal tx_data_fixed : slv_32_t;
  signal rx_data_cap : slv_32_t;
  signal rx_k_data_Cap : slv_4_t;

  signal counter_data : slv_16_t;
  signal counter_data_rev : slv_16_t;
  signal counter_data_at_max : std_logic;
  signal reset_tx_data_counter : std_logic;

  signal mode : slv_4_t;

  signal TxRx_clk_sel : std_logic; -- '0' for refclk0, '1' for refclk1


  
begin  -- architecture TCDS
  reset <= not reset_axi_n;
  TCDS_interface_1: entity work.TCDS_map
    generic map (
      ALLOCATED_MEMORY_RANGE => ALLOCATED_MEMORY_RANGE
      )
    port map (
      clk_axi         => clk_axi,
      reset_axi_n     => reset_axi_n,
      slave_readMOSI  => readMOSI,
      slave_readMISO  => readMISO,
      slave_writeMOSI => writeMOSI,
      slave_writeMISO => writeMISO,
      Mon             => Mon,
      Ctrl            => Ctrl);

  -------------------------------------------------------------------------------
  -- MGT link
  -------------------------------------------------------------------------------
  

  reflk1_buf : IBUFDS_GTE4
    generic map (
      REFCLK_EN_TX_PATH => '0',
      REFCLK_HROW_CK_SEL => "00",
      REFCLK_ICNTL_RX    => "00")
    port map (
      I     => refclk1_p,
      IB    => refclk1_n,
      CEB   => '0',
      O     => refclk1,
      ODIV2 => open);
    
--  --Convert QPLL clock to tx clocks
--  --BUFG_GT
--  clk_tx_int_buf : BUFG_GT
--    port map (
--      CE      => '1',
--      CEMASK  => '0',
--      CLR     => '0',
--      CLRMASK => '0',
--      DIV     => "000",
--      I       => clk_tx_int_raw,
--      O       => clk_tx_int);
--    
--  clk_rx_int_buf : BUFG_GT
--    port map (
--      CE      => '1',
--      CEMASK  => '0',
--      CLR     => '0',
--      CLRMASK => '0',
--      DIV     => "000",
--      I       => clk_rx_int_raw,
--      O       => clk_rx_int);
--

--  refclk <= refclk1 when TxRx_clk_sel = '1' else refclk0;
  TxRx_clk_sel <= Ctrl.TxRx_clk_sel;

  localTCDS_1: entity work.localTCDS_MGT
    port map (
      gtwiz_userclk_tx_reset_in(0)       => Ctrl.TX.RESET,
      gtwiz_userclk_tx_srcclk_out     => open,
      gtwiz_userclk_tx_usrclk_out     => open,
      gtwiz_userclk_tx_usrclk2_out(0)    => clk_tx_int,
      gtwiz_userclk_tx_active_out(0)     => Mon.TX.ACTIVE,
      gtwiz_userclk_rx_reset_in(0)       => Ctrl.RX.RESET,
      gtwiz_userclk_rx_srcclk_out     => open,
      gtwiz_userclk_rx_usrclk_out     => open,
      gtwiz_userclk_rx_usrclk2_out(0)    => clk_rx_int,
      gtwiz_userclk_rx_active_out(0)     => Mon.RX.ACTIVE,

      gtwiz_reset_clk_freerun_in(0)      => clk_axi,
      gtwiz_reset_all_in(0)              => Ctrl.RESET.RESET_ALL,
      gtwiz_reset_tx_pll_and_datapath_in(0) => Ctrl.RESET.TX_PLL_AND_DATAPATH,
      gtwiz_reset_tx_datapath_in(0)         => Ctrl.RESET.TX_DATAPATH,
      gtwiz_reset_rx_pll_and_datapath_in(0) => Ctrl.RESET.RX_PLL_AND_DATAPATH,
      gtwiz_reset_rx_datapath_in(0)         => Ctrl.RESET.RX_DATAPATH,
--      gtwiz_reset_qpll0lock_in              => '1',
      gtwiz_reset_rx_cdr_stable_out(0)      => Mon.CLOCKING.RX_CDR_STABLE,
      gtwiz_reset_tx_done_out            => open,
      gtwiz_reset_rx_done_out            => open,
--      gtwiz_reset_qpll0reset_out         => open,
      gtwiz_userdata_tx_in               => tx_data,
      gtwiz_userdata_rx_out              => rx_data,

--      qpll0clk_in                        => '0',
--      qpll0refclk_in                     => '0',
--      qpll1clk_in                        => refclk1,
--      qpll1refclk_in                     =>  refclk1,

      gtrefclk01_in(0)                   => refclk1,
      qpll1outclk_out                    => open,
      qpll1outrefclk_out                 => open,
      drpaddr_in                         => Ctrl.DRP.address,
      drpclk_in(0)                          => Ctrl.DRP.clk,
      drpdi_in                           => Ctrl.DRP.wr_data,
      drpen_in(0)                           => Ctrl.DRP.wr_enable or Ctrl.DRP.enable,
      drprst_in(0)                          => Ctrl.RESET.DRP,
      drpwe_in(0)                           => Ctrl.DRP.wr_enable,
      eyescanreset_in(0)                    => Ctrl.DEBUG.EYESCAN_RESET,
      eyescantrigger_in(0)                  => Ctrl.DEBUG.EYESCAN_TRIGGER,
      gthrxn_in(0)                          => rx_n,
      gthrxp_in(0)                          => rx_p,
      loopback_in                           => Ctrl.loopback,
      pcsrsvdin_in                       => Ctrl.DEBUG.PCS_RSV_DIN,
      rx8b10ben_in                       => B"1",
      rxbufreset_in                      => B"1",
      rxcdrhold_in(0)                       => Ctrl.DEBUG.RX.CDR_HOLD,
      rxcommadeten_in                    => B"1",
      rxdfelpmreset_in(0)                   => Ctrl.DEBUG.RX.DFE_LPM_RESET,
      rxlpmen_in(0)                         => Ctrl.DEBUG.RX.LPM_EN,
      rxmcommaalignen_in                 => B"1",
      rxpcommaalignen_in                 => B"1",
      rxpcsreset_in(0)                      => Ctrl.DEBUG.RX.PCS_RESET,
      rxpmareset_in(0)                      => Ctrl.DEBUG.RX.PMA_RESET,
      rxprbscntreset_in(0)                  => Ctrl.DEBUG.RX.PRBS_CNT_RST,
      rxprbssel_in                       => Ctrl.DEBUG.RX.PRBS_SEL,
      rxrate_in                          => Ctrl.DEBUG.RX.RATE,
      tx8b10ben_in                       => B"1",
      txctrl0_in                         => Ctrl.TX.CTRL0,
      txctrl1_in                         => Ctrl.TX.CTRL1,
      txctrl2_in( 3 downto  0)           => tx_k_data,
      txctrl2_in( 7 downto  4)           => Ctrl.TX.ctrl2(7 downto 4),
      txdiffctrl_in                      => Ctrl.DEBUG.TX.DIFF_CTRL,
      txinhibit_in(0)                       => Ctrl.DEBUG.TX.INHIBIT,
      txpcsreset_in(0)                      => Ctrl.DEBUG.TX.PCS_RESET,
      txpmareset_in(0)                      => Ctrl.DEBUG.TX.PMA_RESET,
      txpolarity_in(0)                      => Ctrl.DEBUG.TX.POLARITY,
      txpostcursor_in                    => Ctrl.DEBUG.TX.POST_CURSOR,
      txprbsforceerr_in(0)                  => Ctrl.DEBUG.TX.PRBS_FORCE_ERR,
      txprbssel_in                       => Ctrl.DEBUG.TX.PRBS_SEL,
      txprecursor_in                     => Ctrl.DEBUG.TX.PRE_CURSOR,
      cplllock_out(0)                       => Mon.DEBUG.CPLL_LOCK,
      dmonitorout_out                    => Mon.DEBUG.DMONITOR,
      drpdo_out                          => Mon.DRP.rd_data,
      drprdy_out(0)                         => Mon.DRP.rd_data_valid,
      eyescandataerror_out(0)               => Mon.DEBUG.EYESCAN_DATA_ERROR,
      gtpowergood_out(0)                    => Mon.CLOCKING.POWER_GOOD,
      gthtxn_out(0)                         => tx_n,
      gthtxp_out(0)                         => tx_p,
      rxbufstatus_out                    => Mon.DEBUG.RX.BUF_STATUS,
      rxbyteisaligned_out                => open,
      rxbyterealign_out                  => open,
      rxcommadet_out                     => open,
      rxctrl0_out( 3 downto  0)          => rx_k_data,
      rxctrl0_out(15 downto  4)          => Mon.RX.CTRL0(15 downto  4),
      rxctrl1_out                        => Mon.RX.CTRL1,
      rxctrl2_out                        => Mon.RX.CTRL2,
      rxctrl3_out                        => Mon.RX.CTRL3,
      rxpmaresetdone_out(0)                 => Mon.DEBUG.RX.PMA_RESET_DONE,
      rxprbserr_out(0)                      => Mon.DEBUG.RX.PRBS_ERR,
      rxresetdone_out(0)                    => Mon.DEBUG.RX.RESET_DONE,
      txbufstatus_out                    => Mon.DEBUG.TX.BUF_STATUS,
      txpmaresetdone_out                 => open,
      txresetdone_out(0)                    => Mon.DEBUG.TX.RESET_DONE);
--  localTCDS_MGT: entity work.localTCDS
--    port map (
--      gtwiz_userclk_tx_active_in            => "1",
--      gtwiz_userclk_rx_active_in            => "1",
--      gtwiz_reset_clk_freerun_in(0)         => clk_axi,
--      gtwiz_reset_all_in(0)                 => Ctrl.RESET.RESET_ALL,
--      gtwiz_reset_tx_pll_and_datapath_in(0) => Ctrl.RESET.TX_PLL_AND_DATAPATH,
--      gtwiz_reset_tx_datapath_in(0)         => Ctrl.RESET.TX_DATAPATH,
--      gtwiz_reset_rx_pll_and_datapath_in(0) => Ctrl.RESET.RX_PLL_AND_DATAPATH,
--      gtwiz_reset_rx_datapath_in(0)         => Ctrl.RESET.RX_DATAPATH,
--      gtwiz_reset_rx_cdr_stable_out(0)      => Mon.CLOCKING.RX_CDR_STABLE,
--      gtwiz_reset_tx_done_out(0)            => Mon.RESET.TX_RESET_DONE,
--      gtwiz_reset_rx_done_out(0)            => Mon.RESET.RX_RESET_DONE,
--      gtwiz_userdata_tx_in               => tx_data,
--      gtwiz_userdata_rx_out              => rx_data,    
--      drpaddr_in                         => Ctrl.DRP.address,
--      drpclk_in(0)                       => Ctrl.DRP.clk,
--      drpdi_in                           => Ctrl.DRP.wr_data,
--      drpen_in(0)                        => Ctrl.DRP.wr_enable or Ctrl.DRP.enable,
--      drpwe_in(0)                        => Ctrl.DRP.wr_enable,
--      eyescanreset_in(0)                 => Ctrl.DEBUG.EYESCAN.RESET,
--      eyescantrigger_in(0)               => Ctrl.DEBUG.EYESCAN.TRIGGER,
--      gthrxn_in(0)                       => rx_n,
--      gthrxp_in(0)                       => rx_p,
--      pcsrsvdin_in                       => Ctrl.DEBUG.PCS_RSV_DIN,
--      qpll0clk_in : in STD_LOGIC_VECTOR ( 0 to 0 );
--      qpll0refclk_in : in STD_LOGIC_VECTOR ( 0 to 0 );
--      qpll1clk_in : in STD_LOGIC_VECTOR ( 0 to 0 );
--      qpll1refclk_in : in STD_LOGIC_VECTOR ( 0 to 0 );
--      rx8b10ben_in                       => B"1",
--      rxcommadeten_in                    => B"1",
--      rxlpmen_in                         => Ctrl.DEBUG.RX.LPM_EN,
--      rxmcommaalignen_in                 => B"1",
--      rxpcommaalignen_in                 => B"1",
--      rxprbscntreset_in(0)               => Ctrl.DEBUG.RX.PRBS_RESET,
--      rxprbssel_in                       => Ctrl.DEBUG.RX.PRBS_SEL,
--      rxrate_in                          => "000",
--      rxusrclk_in(0)                     => clk_rx_int,
--      rxusrclk2_in(0)                    => clk_rx_int,
--      tx8b10ben_in                       => "1",
--      txctrl0_in                         => x"0000",
--      txctrl1_in                         => x"0000",
--      txctrl2_in( 3 downto  0)           => tx_k_data,
--      txctrl2_in( 7 downto  4)           => (others => '0'),
--      txdiffctrl_in                      => (others => 'X'),
--      txinhibit_in(0)                    => Ctrl.DEBUG.TX.INHIBIT,
--      txpostcursor_in                    => (others => 'X'),
--      txprbsforceerr_in(0)               => Ctrl.DEBUG.TX.PRBS_FORCE_ERROR,
--      txprbssel_in                       => Ctrl.DEBUG.TX.PRBS_SEL,
--      txprecursor_in                     => (others => 'X'),
--      txusrclk_in(0)                     => clk_tx_int,
--      txusrclk2_in(0)                    => clk_tx_int,
--      drpdo_out                          => Mon.DRP.rd_data,
--      drprdy_out(0)                      => Mon.DRP.rd_data_valid,
--      gthtxn_out(0)                      => tx_n,
--      gthtxp_out(0)                      => tx_p,
--      gtpowergood_out(0)                 => Mon.CLOCKING.POWER_GOOD,
--      rxbyteisaligned_out                => open,
--      rxbyterealign_out                  => open,
--      rxcommadet_out                     => open,
--      rxctrl0_out( 3 downto  0)          => rx_k_data,
--      rxctrl0_out(15 downto  4)          => open,
--      rxctrl1_out( 3 downto  0)          => Mon.DEBUG.RX.DISP_ERROR,
--      rxctrl1_out(15 downto  4)          => open,
--      rxctrl2_out                        => open,
--      rxctrl3_out( 3 downto  0)          => Mon.DEBUG.RX.BAD_CHAR,
--      rxctrl3_out( 7 downto  4)          => open,
--      rxdata_out                         => open, 
--      rxoutclk_out(0)                    => clk_rx_int_raw,
--      rxpmaresetdone_out(0)              => Mon.RESET.RX_PMA_RESET_DONE,
--      txoutclk_out(0)                    => clk_tx_int_raw,
--      txpmaresetdone_out(0)              => Mon.RESET.TX_PMA_RESET_DONE);

  -------------------------------------------------------------------------------
  -- Data processing
  -------------------------------------------------------------------------------
  
  ----Monitoring Clock Synthesizer
  rate_counter_1: entity work.rate_counter
    generic map (
      CLK_A_1_SECOND => 50000000)
    port map (
      clk_A         => clk_axi,
      clk_B         => clk_tx_int,
      reset_A_async => reset,
      event_b       => '1',
      rate          => Mon.CLOCKING.COUNTS_TXOUTCLK);
  

    DC_data_CDC_1: entity work.DC_data_CDC
      generic map (
        DATA_WIDTH => 4)
      port map (
        clk_in   => clk_axi,
        clk_out  => clk_tx_int,
        reset    => reset,
        pass_in  => Ctrl.DATA_CTRL.MODE,
        pass_out => mode);

    --pass fixed data to the txrx domain for sending
    DC_data_CDC_2: entity work.DC_data_CDC
      generic map (
        DATA_WIDTH => 36)
      port map (
        clk_in   => clk_axi,
        clk_out  => clk_tx_int,
        reset    => reset,
        pass_in(31 downto  0)  => Ctrl.DATA_CTRL.FIXED_SEND_D,
        pass_in(35 downto 32)  => Ctrl.DATA_CTRL.FIXED_SEND_K,
        pass_out(31 downto  0) => tx_data_fixed,
        pass_out(35 downto 32) => tx_k_data_fixed);
    

    --Capture rx data from the txrx domain via a capture pulse
    capture_CDC_2: entity work.capture_CDC
      generic map (
        WIDTH => 36)
      port map (
        clkA           => clk_axi,
        resetA         => reset,
        clkB           => clk_tx_int,
        resetB         => reset,
        capture_pulseA => Ctrl.DATA_CTRL.CAPTURE,
        outA(31 downto  0) => Mon.DATA_CTRL.CAPTURE_D,
        outA(35 downto 32) => Mon.DATA_CTRL.CAPTURE_K,
        outA_valid     => open,
        capture_pulseB => open,
        inB(31 downto  0) => rx_data,
        inB(35 downto 32) => rx_k_data,
        inB_valid      => '1');

  counter_for_tx_data: entity work.counter
    generic map (
      roll_over   => '0',
      end_value   => x"0000FFFF",
      start_value => x"00000000",
      A_RST_CNT   => x"00000000",
      DATA_WIDTH  => 16)
    port map (
      clk         => clk_tx_int,
      reset_async => '0',
      reset_sync  => reset_tx_data_counter,
      enable      => '1',
      event       => '1',
      count       => counter_data,
      at_max      => counter_data_at_max);

  vec_reverse: for iBit in counter_data'range generate
    counter_data_rev(iBit) <= counter_data(counter_data'left - iBit);
  end generate vec_reverse;
  
  data_proc: process (clk_tx_int, reset) is
    begin  -- process data_proc
      if reset = '1' then               -- asynchronous reset (active high)
        tx_data <= x"BCBCBCBC";
        tx_k_data <= x"F";      
      elsif clk_tx_int'event and clk_tx_int = '1' then  -- rising clock edge
        reset_tx_data_counter <= '0';
        case mode is
          when x"0"  =>
            tx_data <= x"deadbeef";
            tx_k_data <= x"0";
          when x"1"  => 
            tx_data <= rx_data;
            tx_k_data <= rx_k_data;
          when x"2" =>
            tx_data <= x"BCBCBCBC";
            tx_k_data <= x"F";
          when x"3" =>
            tx_data   <= tx_data_fixed;
            tx_k_data <= tx_k_data_fixed;            
          when x"4" =>
            if counter_data_at_max = '1' then
              reset_tx_data_counter <= '1';
              tx_data <= x"BCBCBCBC";
              tx_k_data <= x"F";                
            else
              tx_data   <= counter_data_rev(7 downto 0) & counter_data_rev (7 downto 0) &
                           counter_data(15 downto 0);
              tx_k_data <= x"0";            
              
            end if;
          when others =>
            tx_data <= x"BCBCBCBC";
            tx_k_data <= x"F";
        end case;
      end if;
    end process data_proc;


  
end architecture behavioral;
