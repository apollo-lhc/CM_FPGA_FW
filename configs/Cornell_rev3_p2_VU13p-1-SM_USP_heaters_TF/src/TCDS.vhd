library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.axiRegPkg.all;
use work.VIRTEX_TCDS_Ctrl.all;
use work.types.all;

Library UNISIM;
use UNISIM.vcomponents.all;


entity TCDS is
  port (
    clk_axi              : in  std_logic; --50 MHz
    clk_200              : in  std_logic;
    reset_axi_n          : in  std_logic;
    readMOSI             : in  AXIreadMOSI;
    readMISO             : out AXIreadMISO;
    writeMOSI            : in  AXIwriteMOSI;
    writeMISO            : out AXIwriteMISO;
    --DRP_readMOSI         : in  AXIreadMOSI;
    --DRP_readMISO         : out AXIreadMISO;
    --DRP_writeMOSI        : in  AXIwriteMOSI;
    --DRP_writeMISO        : out AXIwriteMISO;
--    refclk0_p : in std_logic;
--    refclk0_n : in std_logic;
----    refclk1_p : in std_logic;
----    refclk1_n : in std_logic; 
--    tx_p : out std_logic;
--    tx_n : out std_logic;
--    rx_p : in  std_logic;
--    rx_n : in  std_logic;
    heater_output : out slv32_array_t(31 downto 0);
    TxRx_clk_sel : in std_logic := '0'); -- '0' for refclk0, std_logic' ('1') for refclk1

end entity TCDS;

architecture behavioral of TCDS is
  signal heater_output_pl : slv32_array_t(31 downto 0);
  signal heater_enable : std_logic;
  signal heater_adjust : std_logic_vector(31 downto 0);
  signal heater_select : std_logic_vector(31 downto 0);
  signal reset : std_logic;
  signal refclk : std_logic;
  signal refclk0 : std_logic;
  signal refclk0_ODIV2 : std_logic;
  signal refclk0_ODIV2_int : std_logic;
  signal refclk1 : std_logic;
  signal qpll0outclk : std_logic;
  signal qpll0refclk : std_logic;
  signal counts_txoutclk : std_logic_vector(31 downto 0);

  signal gtwiz_userclk_tx_active_out : std_logic;
  signal drpclk : std_logic;
  signal drpen_int : std_logic;
  signal drpwe_int : std_logic;
  signal drpaddr_int : std_logic_vector(9 downto 0);
  signal drpdi_int : std_logic_vector(15 downto 0);
  signal drprdy_int : std_logic;
  signal drpdo_int : std_logic_vector(15 downto 0);
  signal eyescanreset_int : std_logic;
  signal rxrate_int : std_logic_vector(2 downto 0);
  signal txdiffctrl_int : std_logic_vector(4 downto 0);
  signal txprecursor_int : std_logic_vector(4 downto 0);
  signal txpostcursor_int : std_logic_vector(4 downto 0);
  signal rxlpmen_int : std_logic;
  signal ch0_txheader_int : std_logic_vector(5 downto 0);
  signal ch0_txsequence_int : std_logic_vector(6 downto 0);

  signal clk_tx_int     : std_logic;
  signal clk_tx_int_raw : std_logic;
  signal clk_rx_int     : std_logic;
  signal clk_rx_int_raw : std_logic;
  
  type DRP_t is record
    en   : STD_LOGIC;
    we   : STD_LOGIC;
    addr : STD_LOGIC_VECTOR ( 9 downto 0 );
    di   : STD_LOGIC_VECTOR (15 downto 0 );
    do   : STD_LOGIC_VECTOR (15 downto 0 );
    rdy  : STD_LOGIC;
  end record DRP_t;
  signal drp_intf : DRP_t;

  signal Mon              :  VIRTEX_TCDS_Mon_t;
  signal Ctrl             :  VIRTEX_TCDS_Ctrl_t;

  signal tx_data : slv_64_t;
  signal hb0_gtwiz_userdata_tx_int : slv_64_t;
  signal rx_data : slv_64_t;
  signal tx_k_data : slv_4_t;
  signal rx_k_data : slv_4_t;

  signal tx_k_data_fixed : slv_4_t;
  signal tx_data_fixed : slv_64_t;
  signal rx_data_cap : slv_64_t;
  signal rx_k_data_Cap : slv_4_t;

  signal mode : slv_4_t;
  signal capture_data : std_logic;
  
begin  -- architecture TCDS
  reset <= not reset_axi_n;

 gen_heater_1: for i in 0 to 7 generate
   heater_1: entity  work.heater
     generic map (
       C_SLV_DWIDTH            => 32,
       C_NUM_LUTS              => 4096--8192--32768--131072--65536
       ) port map (
         clk                     => clk_200,
         reset                   => reset,
         enable_heater           => heater_enable,
         adjust_heaters          => heater_adjust,
         read_which_heater       => heater_select,
         heater_output           => heater_output_pl(i)
         );
 end generate gen_heater_1;

  gen_heater_2: for i in 8 to 15 generate
    heater_2: entity  work.heater
      generic map (
        C_SLV_DWIDTH            => 32,
        C_NUM_LUTS              => 4096--8192--32768--131072--65536
        ) port map (
          clk                     => clk_200,
          reset                   => reset,
          enable_heater           => heater_enable,
          adjust_heaters          => heater_adjust,
          read_which_heater       => heater_select,
          heater_output           => heater_output_pl(i)
          );
  end generate gen_heater_2;
  
  gen_heater_3: for i in 16 to 23 generate
   heater_3: entity  work.heater
     generic map (
       C_SLV_DWIDTH            => 32,
       C_NUM_LUTS              => 4096--8192--32768--131072--65536
       ) port map (
         clk                     => clk_200,
         reset                   => reset,
         enable_heater           => heater_enable,
         adjust_heaters          => heater_adjust,
         read_which_heater       => heater_select,
         heater_output           => heater_output_pl(i)
         );
 end generate gen_heater_3;

  gen_heater_4: for i in 24 to 31 generate
    heater_4: entity  work.heater
      generic map (
        C_SLV_DWIDTH            => 32,
        C_NUM_LUTS              => 4096--8192--32768--131072--65536
        ) port map (
          clk                     => clk_200,
          reset                   => reset,
          enable_heater           => heater_enable,
          adjust_heaters          => heater_adjust,
          read_which_heater       => heater_select,
          heater_output           => heater_output_pl(i)
          );
  end generate gen_heater_4;
            
  data_proc: process (clk_200, reset) is
    begin  -- process data_proc
      if rising_edge(clk_200) then
        if (reset = '1') then
          heater_enable <= '0';
          heater_adjust <= (others=>'0');
          heater_output <= (others => (others => '0'));
          heater_select <= (others => '0');
        else
          heater_enable <= Ctrl.Heater.Enable;
          heater_adjust <= Ctrl.Heater.Adjust;
          heater_output <= heater_output_pl;
          heater_select <= Ctrl.Heater.SelectHeater;
        end if;
      end if;
    end process data_proc;
  
  
--  reflk_buf : IBUFDS_GTE4
--    generic map (
--      REFCLK_EN_TX_PATH => '0',
--      REFCLK_HROW_CK_SEL => "00",
--      REFCLK_ICNTL_RX    => "00")
--    port map (
--      I     => refclk0_p,        
--      IB    => refclk0_n,
--      CEB   => std_logic' ('0'),
--      O     => refclk0,  
--      ODIV2 => refclk0_ODIV2);

----  reflk1_buf : IBUFDS_GTE4
----    generic map (
----      REFCLK_EN_TX_PATH => '0',
----      REFCLK_HROW_CK_SEL => "00",
----      REFCLK_ICNTL_RX    => "00")
----    port map (
----      I     => refclk1_p,
----      IB    => refclk1_n,
----      CEB   => std_logic' ('0'),
----      O     => refclk1,
----      ODIV2 => open);
    
--  --Convert QPLL clock to tx clocks
--  --BUFG_GT
--  clk_tx_int_buf : BUFG_GT
--    port map (
--      CE      => std_logic' ('1'),
--      CEMASK  => std_logic' ('0'),
--      CLR     => std_logic' ('0'),
--      CLRMASK => std_logic' ('0'),
--      DIV     => std_logic_vector'("000"),
--      I       => clk_tx_int_raw,
--      O       => clk_tx_int);
    
--  clk_rx_int_buf : BUFG_GT
--    port map (
--      CE      => std_logic' ('1'),
--      CEMASK  => std_logic' ('0'),
--      CLR     => std_logic' ('0'),
--      CLRMASK => std_logic' ('0'),
--      DIV     => "000",
--      I       => clk_rx_int_raw,
--      O       => clk_rx_int);

----  refclk0_buf : BUFG_GT
----    port map (
----      CE      => std_logic' ('1'),
----      CEMASK  => std_logic' ('0'),
----      CLR     => std_logic' ('0'),
----      CLRMASK => std_logic' ('0'),
----      DIV     => "000",
----      I       => refclk0_ODIV2,
--      O       => refclk0_ODIV2_int);
  


  TCDS_interface_1: entity work.Virtex_TCDS_interface
    port map (
      clk_axi         => clk_axi,
      reset_axi_n     => reset_axi_n,
      slave_readMOSI  => readMOSI,
      slave_readMISO  => readMISO,
      slave_writeMOSI => writeMOSI,
      slave_writeMISO => writeMISO,
      Mon             => Mon,
      Ctrl            => Ctrl);
      
  gtwiz_userclk_tx_active_out <= std_logic' ('1');

  refclk <= refclk0;--1 when TxRx_clk_sel = std_logic' ('1') else refclk0;
  
--  TCDS_TxRx_2: entity work.TCDS_TxRx
--    port map (
--      gtwiz_userclk_tx_active_in            => std_logic_vector' ( (others => '1')),
----      gtwiz_userclk_tx_active_out           => gtwiz_userclk_tx_active_out,
--      gtwiz_userclk_rx_active_in            => std_logic_vector' ( (others => '1')),--"1",
--      gtwiz_reset_clk_freerun_in(0)         => clk_axi,
--      gtwiz_reset_all_in(0)                 => Ctrl.RESETS.RESET_ALL,
--      gtwiz_reset_tx_pll_and_datapath_in(0) => Ctrl.RESETS.TX_PLL_DATAPATH,
--      gtwiz_reset_tx_datapath_in(0)         => Ctrl.RESETS.TX_DATAPATH,
--      gtwiz_reset_rx_pll_and_datapath_in(0) => Ctrl.RESETS.RX_PLL_DATAPATH,
--      gtwiz_reset_rx_datapath_in(0)         => Ctrl.RESETS.RX_DATAPATH,
--      gtwiz_reset_rx_cdr_stable_out(0)      => Mon.CLOCKING.RX_CDR_STABLE,
--      gtwiz_reset_tx_done_out(0)            => Mon.RESETS.TX_RESET_DONE,
--      gtwiz_reset_rx_done_out(0)            => Mon.RESETS.RX_RESET_DONE,
--      gtwiz_userdata_tx_in               => tx_data,
--      gtwiz_userdata_rx_out              => rx_data,
--      gtrefclk00_in(0)                   => refclk,
----      qpll0clk_in(0)                     => qpll0outclk,
--      qpll0outclk_out(0)                 => qpll0outclk,
----      qpll0refclk_in(0)                  => qpll0refclk,
--      qpll0outrefclk_out(0)              => qpll0refclk,
--      qpll0locken_in(0)                  => std_logic' ('1'),
--      qpll0lock_out(0)                   => Mon.CLOCKING.QPLL0_LOCK,
--      qpll0lockdetclk_in(0)              => clk_200,
--      qpll0fbclklost_out(0)              => Mon.CLOCKING.QPLL0_FBCLKLOST,
--      qpll0refclklost_out(0)             => Mon.CLOCKING.QPLL0_REFCLKLOST,
--      drpaddr_in                         => drp_intf.addr,
--      drpclk_in(0)                       => clk_axi,
--      drpdi_in                           => drp_intf.di,
--      drpen_in(0)                        => drp_intf.en,
--      drpwe_in(0)                        => drp_intf.we,
--      eyescanreset_in(0)                 => Ctrl.EYESCAN.RESET,
--      eyescantrigger_in(0)               => Ctrl.EYESCAN.TRIGGER,
--      gtyrxn_in(0)                       => rx_n,
--      gtyrxp_in(0)                       => rx_p,
--      loopback_in                        => CTRL.LOOPBACK,
--      rxlpmen_in(0)                      => 'X',--"X",
--      rxgearboxslip_in                   => std_logic_vector' ( (others => '0')),
--      rxprbscntreset_in(0)               => Ctrl.RX.PRBS_RESET,
--      rxprbssel_in                       => Ctrl.RX.PRBS_SEL,
--      rxrate_in                          => "000",
--      rxusrclk_in(0)                     => clk_rx_int,
--      rxusrclk2_in(0)                    => clk_rx_int,
--      txdiffctrl_in                      => (others => 'X'),
--      txinhibit_in(0)                    => Ctrl.TX.INHIBIT,
--      txpostcursor_in                    => (others => 'X'),
--      txprbsforceerr_in(0)               => Ctrl.TX.PRBS_FORCE_ERROR,
--      txprbssel_in                       => Ctrl.TX.PRBS_SEL,
--      txprecursor_in                     => (others => 'X'),
--      txusrclk_in(0)                     => clk_tx_int,
--      txusrclk2_in(0)                    => clk_tx_int,
--      txheader_in                        => ch0_txheader_int,
--      txsequence_in                      => ch0_txsequence_int,
--      drpdo_out                          => drp_intf.do,
--      drprdy_out(0)                      => drp_intf.rdy,
--      gtytxn_out(0)                      => tx_n,
--      gtytxp_out(0)                      => tx_p,
--      gtpowergood_out(0)                 => Mon.CLOCKING.POWER_GOOD,
--      rxdata_out                         => open, 
--      rxoutclk_out(0)                    => clk_rx_int_raw,
--      rxpmaresetdone_out(0)              => Mon.RESETS.RX_PMA_RESET_DONE,
--      txoutclk_out(0)                    => clk_tx_int_raw,
--      txpmaresetdone_out(0)              => Mon.RESETS.TX_PMA_RESET_DONE);

  ----Monitoring Clock Synthesizer
  --count_txoutclk: entity work.counter_clock
  --  port map (
  --    clk0        => clk_200,
  --    clk1        => clk_tx_int,
  --    reset_sync  => reset,
  --    count       => Mon.CLOCKING.COUNTS_TXOUTCLK
  --    );
  
  -- count_refclk0: entity work.counter_clock
  --   port map (
  --     clk0        => clk_200,
  --     clk1        => refclk0_ODIV2_int,
  --     reset_sync  => reset,
  --     count       => Mon.CLOCKING.COUNTS_REFCLK0
  --     );

  
  --AXI_DRP_1: entity work.AXI_DRP
  --  port map (
  --    AXI_aclk      => clk_axi,
  --    AXI_aresetn   => reset_axi_n,
  --    S_AXI_araddr  => DRP_readMOSI.address,
  --    S_AXI_arready => DRP_readMISO.ready_for_address,
  --    S_AXI_arvalid => DRP_readMOSI.address_valid,
  --    S_AXI_arprot  => DRP_readMOSI.protection_type,
  --    S_AXI_awaddr  => DRP_writeMOSI.address,
  --    S_AXI_awready => DRP_writeMISO.ready_for_address,
  --    S_AXI_awvalid => DRP_writeMOSI.address_valid,
  --    S_AXI_awprot  => DRP_writeMOSI.protection_type,
  --    S_AXI_bresp   => DRP_writeMISO.response,
  --    S_AXI_bready  => DRP_writeMOSI.ready_for_response,
  --    S_AXI_bvalid  => DRP_writeMISO.response_valid,
  --    S_AXI_rdata   => DRP_readMISO.data,
  --    S_AXI_rready  => DRP_readMOSI.ready_for_data,
  --    S_AXI_rvalid  => DRP_readMISO.data_valid,
  --    S_AXI_rresp   => DRP_readMISO.response,
  --    S_AXI_wdata   => DRP_writeMOSI.data,
  --    S_AXI_wready  => DRP_writeMISO.ready_for_data,
  --    S_AXI_wvalid  => DRP_writeMOSI.data_valid,
  --    S_AXI_wstrb   => DRP_writeMOSI.data_write_strobe,
  --    drp0_en       => drp_intf.en,
  --    drp0_we       => drp_intf.we,
  --    drp0_addr     => drp_intf.addr,
  --    drp0_di       => drp_intf.di,
  --    drp0_do       => drp_intf.do,
  --    drp0_rdy      => drp_intf.rdy);


  --pass_std_logic_vector_1: entity work.pass_std_logic_vector
  --  generic map (
  --    DATA_WIDTH => 4)
  --  port map (
  --    clk_in   => clk_axi,
  --    clk_out  => clk_tx_int,
  --    reset    => reset,
  --    pass_in  => Ctrl.DEBUG.MODE,
  --    pass_out => mode);

  ----pass fixed data to the txrx domain for sending
  --pass_std_logic_vector_2: entity work.pass_std_logic_vector
  --  generic map (
  --    DATA_WIDTH => 68)
  --  port map (
  --    clk_in   => clk_axi,
  --    clk_out  => clk_tx_int,
  --    reset    => reset,
  --    pass_in(31 downto  0)  => Ctrl.DEBUG.FIXED_SEND_D,
  --    pass_in(63 downto 32)  => Ctrl.DEBUG.FIXED_SEND_D,
  --    pass_in(67 downto 64)  => Ctrl.DEBUG.FIXED_SEND_K,
  --    pass_out(63 downto  0) => tx_data_fixed,
  --    pass_out(67 downto 64) => tx_k_data_fixed);
  

  ----Capture rx data from the txrx domain via a capture pulse
  --pacd_1: entity work.pacd
  --  port map (
  --    iPulseA => Ctrl.DEBUG.CAPTURE,
  --    iClkA   => clk_axi,
  --    iRSTAn  => reset_axi_n,
  --    iClkB   => clk_tx_int,
  --    iRSTBn  => reset_axi_n,
  --    oPulseB => capture_data);
  --capture_CDC_1: entity work.capture_CDC
  --  generic map (
  --    WIDTH => 36)
  --  port map (
  --    clkA               => clk_tx_int,
  --    clkB               => clk_axi,
  --    inA(31 downto  0)  => rx_data(31 downto 0),
  --    inA(35 downto 32)  => rx_k_data,
  --    inA_valid          => capture_data,
  --    outB(31 downto  0) => Mon.DEBUG.CAPTURE_D,
  --    outB(35 downto 32) => Mon.DEBUG.CAPTURE_K,
  --    outB_valid => open);
  
  --data_proc: process (clk_tx_int, reset) is
  --begin  -- process data_proc
  --  if reset = std_logic' ('1') then               -- asynchronous reset (active high)
  --    tx_data <= x"BCBCBCBCBCBCBCBC";
  --    tx_k_data <= x"F";      
  --  elsif clk_tx_int'event and clk_tx_int = std_logic' ('1') then  -- rising clock edge
  --    case mode is
  --      when x"0"  => 
  --        tx_data <= rx_data;
  --        tx_k_data <= rx_k_data;
  --      when x"1" =>
  --        tx_data <= x"BCBCBCBCBCBCBCBC";
  --        tx_k_data <= x"F";
  --      when x"2" =>
  --        tx_data <= tx_data_fixed;
  --        tx_k_data <= tx_k_data_fixed;
  --      when others =>
  --        tx_data <= x"BCBCBCBCBCBCBCBC";
  --        tx_k_data <= x"F";
  --    end case;
  --  end if;
  --end process data_proc;
end architecture behavioral;
