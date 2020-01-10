library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Library UNISIM;
use UNISIM.vcomponents.all;


entity TCDS is
  
  port (
    sys_clk  : in std_logic;
    reset_n  : in std_logic;
    refclk_p : in std_logic;
    refclk_n : in std_logic;
    tx_p : out std_logic;
    tx_n : out std_logic;
    rx_p : in  std_logic;
    rx_n : in  std_logic);

end entity TCDS;

architecture behavioral of TCDS is
  signal refclk : std_logic;
  
begin  -- architecture TCDS

  reflk_buf : IBUFDS_GTE4
    generic map (
      REFCLK_EN_TX_PATH => '0',
      REFCLK_HROW_CK_SEL => "00",
      REFCLK_ICNTL_RX    => "00")
    port map (
      I     => refclk_p,        
      IB    => refclk_n,
      CEB   => '0',
      O     => refclk,  
      ODIV2 => open);

  
  --Convert QPLL clock to tx clocks
  --BUFG_GT
  clk_int_buf : BUFG_GT
    port map (
      CE      => '1',
      CEMASK  => '0',
      CLR     => '0',
      CLKMASK => '0',
      DIV     => 0,
      I       => clk_tx_int_raw,
      O       => clk_tx_int);
    
  clk_int_buf : BUFG_GT
    port map (
      CE      => '1',
      CEMASK  => '0',
      CLR     => '0',
      CLKMASK => '0',
      DIV     => 0,
      I       => clk_rx_int_raw,
      O       => clk_rx_int);

  TCDS_TxRx_2: entity work.TCDS_TxRx
    port map (
      gtwiz_userclk_tx_active_in         => "1",
      gtwiz_userclk_rx_active_in         => "1",
      gtwiz_reset_clk_freerun_in         => sysclk,
      gtwiz_reset_all_in                 => reset_n,
      gtwiz_reset_tx_pll_and_datapath_in => "0",
      gtwiz_reset_tx_datapath_in         => "0",
      gtwiz_reset_rx_pll_and_datapath_in => "0",
      gtwiz_reset_rx_datapath_in         => "0",
      gtwiz_reset_rx_cdr_stable_out      => open,
      gtwiz_reset_tx_done_out            => open,
      gtwiz_reset_rx_done_out            => open,
      gtwiz_userdata_tx_in               => tx_data,
      gtwiz_userdata_rx_out              => rx_data,    
      gtrefclk00_in(0)                   => refclk,
      qpll0outclk_out                    => open,
      qpll0outrefclk_out                 => open,
      drpaddr_in                         => (others => '0'),
      drpclk_in                          => sysclk,
      drpdi_in                           => (others => '0'),
      drpen_in                           => (others => '0'),
      drpwe_in                           => (others => '0'),
      eyescanreset_in                    => (others => '0'),
      gthrxn_in(0)                       => rx_n,
      gthrxp_in(0)                       => rx_p,
      rx8b10ben_in                       => "1",
      rxcommadeten_in                    => "1",
      rxlpmen_in                         => "X",
      rxmcommaalignen_in                 => "1",
      rxpcommaalignen_in                 => "1",
      rxrate_in                          => "000",
      rxusrclk_in                        => clk_rx_int,
      rxusrclk2_in                       => clk_rx_int,
      tx8b10ben_in                       => "1",
      txctrl0_in                         => x"0000",
      txctrl1_in                         => x"0000",
      txctrl2_in( 3 downto  0)           => tx_k_data,
      txctrl2_in( 7 downto  0)           => (others => '0'),
      txdiffctrl_in                      => (others => 'X'),
      txpostcursor_in                    => (others => 'X'),
      txprbsforceerr_in                  => "0",
      txprbssel_in                       => "0",
      txprecursor_in                     => (others => 'X'),
      txusrclk_in                        => clk_tx_int,
      txusrclk2_in                       => clk_tx_int,
      drpdo_out                          => open,
      drprdy_out                         => open,
      gthtxn_out                         => tx_n,
      gthtxp_out                         => tx_p,
      gtpowergood_out                    => open,
      rxbyteisaligned_out                => open,
      rxbyterealign_out                  => open,
      rxcommadet_out                     => open,
      rxctrl0_out( 3 downto  0)          => rx_k_data,
      rxctrl0_out(15 downto  4)          => open,
      rxctrl1_out( 3 downto  0)          => rx_disp_error,
      rxctrl1_out(15 downto  4)          => open,
      rxctrl2_out                        => open,
      rxctrl3_out( 3 downto  0)          => rx_invalid,
      rxctrl3_out( 7 downto  4)          => open,
      rxdata_out                         => open, 
      rxoutclk_out                       => clk_rx_int_raw,
      rxpmaresetdone_out                 => open,
      txoutclk_out                       => clk_tx_int_raw,
      txpmaresetdone_out                 => open);


end architecture TCDS;
