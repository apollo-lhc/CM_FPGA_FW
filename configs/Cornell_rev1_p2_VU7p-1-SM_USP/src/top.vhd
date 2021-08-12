library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.axiRegPkg.all;
use work.axiRegPkg_d64.all;
use work.types.all;
use work.V_IO_Ctrl.all;


Library UNISIM;
use UNISIM.vcomponents.all;

entity top is
  port (
    -- clocks
    p_clk_200a : in  std_logic;
    n_clk_200a : in  std_logic;                -- 200 MHz system clock

    -- Zynq AXI Chip2Chip
    n_util_clk_chan0 : in std_logic;
    p_util_clk_chan0 : in std_logic;
    n_mgt_z2v        : in  std_logic_vector(1 downto 1);
    p_mgt_z2v        : in  std_logic_vector(1 downto 1);
    n_mgt_v2z        : out std_logic_vector(1 downto 1);
    p_mgt_v2z        : out std_logic_vector(1 downto 1);

    v_fpga_i2c_scl   : inout std_logic;
    v_fpga_i2c_sda   : inout std_logic;

    --TCDS
    p_clk0_chan0     : in std_logic; -- 200 MHz system clock
    n_clk0_chan0     : in std_logic; 
    p_clk1_chan0     : in std_logic; -- 312.195122 MHz synth clock
    n_clk1_chan0     : in std_logic;
--    p_atca_tts_out   : out std_logic;
--    n_atca_tts_out   : out std_logic;
--    p_atca_ttc_in    : in  std_logic;
--    n_atca_ttc_in    : in  std_logic;

    -- tri-color LED
    led_red : out std_logic;
    led_green : out std_logic;
    led_blue : out std_logic       -- assert to turn on
    );    
end entity top;

architecture structure of top is

  signal clk_200_raw     : std_logic;
  signal clk_200         : std_logic;
  signal clk_50          : std_logic;
  signal reset           : std_logic;
  signal locked_clk200   : std_logic;

  signal led_blue_local  : slv_8_t;
  signal led_red_local   : slv_8_t;
  signal led_green_local : slv_8_t;

  constant localAXISlaves    : integer := 4;
  signal local_AXI_ReadMOSI  :  AXIReadMOSI_array_t(0 to localAXISlaves-1) := (others => DefaultAXIReadMOSI);
  signal local_AXI_ReadMISO  :  AXIReadMISO_array_t(0 to localAXISlaves-1) := (others => DefaultAXIReadMISO);
  signal local_AXI_WriteMOSI : AXIWriteMOSI_array_t(0 to localAXISlaves-1) := (others => DefaultAXIWriteMOSI);
  signal local_AXI_WriteMISO : AXIWriteMISO_array_t(0 to localAXISlaves-1) := (others => DefaultAXIWriteMISO);

  signal AXI_CLK             : std_logic;
  signal AXI_RST_N           : std_logic;
  signal AXI_RESET           : std_logic;

  signal ext_AXI_ReadMOSI  :  AXIReadMOSI_d64 := DefaultAXIReadMOSI_d64;
  signal ext_AXI_ReadMISO  :  AXIReadMISO_d64 := DefaultAXIReadMISO_d64;
  signal ext_AXI_WriteMOSI : AXIWriteMOSI_d64 := DefaultAXIWriteMOSI_d64;
  signal ext_AXI_WriteMISO : AXIWriteMISO_d64 := DefaultAXIWriteMISO_d64;

  

  signal C2C_Mon  : V_IO_C2C_MON_t;
  signal C2C_Ctrl : V_IO_C2C_Ctrl_t;

  signal clk_V_C2C_PHY_user                  : STD_logic;


  signal BRAM_write : std_logic;
  signal BRAM_addr  : std_logic_vector(9 downto 0);
  signal BRAM_WR_data : std_logic_vector(31 downto 0);
  signal BRAM_RD_data : std_logic_vector(31 downto 0);


  signal bram_rst_a    : std_logic;
  signal bram_clk_a    : std_logic;
  signal bram_en_a     : std_logic;
  signal bram_we_a     : std_logic_vector(7 downto 0);
  signal bram_addr_a   : std_logic_vector(8 downto 0);
  signal bram_wrdata_a : std_logic_vector(63 downto 0);
  signal bram_rddata_a : std_logic_vector(63 downto 0);

  
begin  -- architecture structure

  --Clocking
  Local_Clocking_1: entity work.Local_Clocking
    port map (
      clk_200   => clk_200,
      clk_50    => clk_50,
      clk_axi   => AXI_CLK,
      reset     => '0',
      locked    => locked_clk200,
      clk_in1_p => p_clk_200a,
      clk_in1_n => n_clk_200a);

  

  c2csslave_wrapper_1: entity work.c2cslave_wrapper
    port map (
      AXI_CLK                               => AXI_CLK,
      AXI_RST_N(0)                          => AXI_RST_N,
      V_C2C_phy_Rx_rxn                  => n_mgt_z2v,
      V_C2C_phy_Rx_rxp                  => p_mgt_z2v,
      V_C2C_phy_Tx_txn                  => n_mgt_v2z,
      V_C2C_phy_Tx_txp                  => p_mgt_v2z,
      V_C2C_phy_refclk_clk_n            => n_util_clk_chan0,
      V_C2C_phy_refclk_clk_p            => p_util_clk_chan0,
      clk50Mhz                              => clk_50,
      
      V_IO_araddr                           => local_AXI_ReadMOSI(0).address,              
      V_IO_arprot                           => local_AXI_ReadMOSI(0).protection_type,      
      V_IO_arready                          => local_AXI_ReadMISO(0).ready_for_address,    
      V_IO_arvalid                          => local_AXI_ReadMOSI(0).address_valid,        
      V_IO_awaddr                           => local_AXI_WriteMOSI(0).address,             
      V_IO_awprot                           => local_AXI_WriteMOSI(0).protection_type,     
      V_IO_awready                          => local_AXI_WriteMISO(0).ready_for_address,   
      V_IO_awvalid                          => local_AXI_WriteMOSI(0).address_valid,       
      V_IO_bready                           => local_AXI_WriteMOSI(0).ready_for_response,  
      V_IO_bresp                            => local_AXI_WriteMISO(0).response,            
      V_IO_bvalid                           => local_AXI_WriteMISO(0).response_valid,      
      V_IO_rdata                            => local_AXI_ReadMISO(0).data,                 
      V_IO_rready                           => local_AXI_ReadMOSI(0).ready_for_data,       
      V_IO_rresp                            => local_AXI_ReadMISO(0).response,             
      V_IO_rvalid                           => local_AXI_ReadMISO(0).data_valid,           
      V_IO_wdata                            => local_AXI_WriteMOSI(0).data,                
      V_IO_wready                           => local_AXI_WriteMISO(0).ready_for_data,       
      V_IO_wstrb                            => local_AXI_WriteMOSI(0).data_write_strobe,   
      V_IO_wvalid                           => local_AXI_WriteMOSI(0).data_valid,
                                            
      CM_V_INFO_araddr                      => local_AXI_ReadMOSI(1).address,              
      CM_V_INFO_arprot                      => local_AXI_ReadMOSI(1).protection_type,      
      CM_V_INFO_arready                     => local_AXI_ReadMISO(1).ready_for_address,    
      CM_V_INFO_arvalid                     => local_AXI_ReadMOSI(1).address_valid,        
      CM_V_INFO_awaddr                      => local_AXI_WriteMOSI(1).address,             
      CM_V_INFO_awprot                      => local_AXI_WriteMOSI(1).protection_type,     
      CM_V_INFO_awready                     => local_AXI_WriteMISO(1).ready_for_address,   
      CM_V_INFO_awvalid                     => local_AXI_WriteMOSI(1).address_valid,       
      CM_V_INFO_bready                      => local_AXI_WriteMOSI(1).ready_for_response,  
      CM_V_INFO_bresp                       => local_AXI_WriteMISO(1).response,            
      CM_V_INFO_bvalid                      => local_AXI_WriteMISO(1).response_valid,      
      CM_V_INFO_rdata                       => local_AXI_ReadMISO(1).data,                 
      CM_V_INFO_rready                      => local_AXI_ReadMOSI(1).ready_for_data,       
      CM_V_INFO_rresp                       => local_AXI_ReadMISO(1).response,             
      CM_V_INFO_rvalid                      => local_AXI_ReadMISO(1).data_valid,           
      CM_V_INFO_wdata                       => local_AXI_WriteMOSI(1).data,                
      CM_V_INFO_wready                      => local_AXI_WriteMISO(1).ready_for_data,       
      CM_V_INFO_wstrb                       => local_AXI_WriteMOSI(1).data_write_strobe,   
      CM_V_INFO_wvalid                      => local_AXI_WriteMOSI(1).data_valid,
      

      VIRTEX_IPBUS_araddr                   => ext_AXI_ReadMOSI.address,              
      VIRTEX_IPBUS_arburst                  => ext_AXI_ReadMOSI.burst_type,
      VIRTEX_IPBUS_arcache                  => ext_AXI_ReadMOSI.cache_type,
      VIRTEX_IPBUS_arlen                    => ext_AXI_ReadMOSI.burst_length,
      VIRTEX_IPBUS_arlock(0)                => ext_AXI_ReadMOSI.lock_type,
      VIRTEX_IPBUS_arprot                   => ext_AXI_ReadMOSI.protection_type,      
      VIRTEX_IPBUS_arqos                    => ext_AXI_ReadMOSI.qos,
      VIRTEX_IPBUS_arready(0)               => ext_AXI_ReadMISO.ready_for_address,
      VIRTEX_IPBUS_arregion                 => ext_AXI_ReadMOSI.region,
      VIRTEX_IPBUS_arsize                   => ext_AXI_ReadMOSI.burst_size,
      VIRTEX_IPBUS_arvalid(0)               => ext_AXI_ReadMOSI.address_valid,        
      VIRTEX_IPBUS_awaddr                   => ext_AXI_WriteMOSI.address,             
      VIRTEX_IPBUS_awburst                  => ext_AXI_WriteMOSI.burst_type,
      VIRTEX_IPBUS_awcache                  => ext_AXI_WriteMOSI.cache_type,
      VIRTEX_IPBUS_awlen                    => ext_AXI_WriteMOSI.burst_length,
      VIRTEX_IPBUS_awlock(0)                => ext_AXI_WriteMOSI.lock_type,
      VIRTEX_IPBUS_awprot                   => ext_AXI_WriteMOSI.protection_type,
      VIRTEX_IPBUS_awqos                    => ext_AXI_WriteMOSI.qos,
      VIRTEX_IPBUS_awready(0)               => ext_AXI_WriteMISO.ready_for_address,   
      VIRTEX_IPBUS_awregion                 => ext_AXI_WriteMOSI.region,
      VIRTEX_IPBUS_awsize                   => ext_AXI_WriteMOSI.burst_size,
      VIRTEX_IPBUS_awvalid(0)               => ext_AXI_WriteMOSI.address_valid,       
      VIRTEX_IPBUS_bready(0)                => ext_AXI_WriteMOSI.ready_for_response,  
      VIRTEX_IPBUS_bresp                    => ext_AXI_WriteMISO.response,            
      VIRTEX_IPBUS_bvalid(0)                => ext_AXI_WriteMISO.response_valid,      
      VIRTEX_IPBUS_rdata                    => ext_AXI_ReadMISO.data,
      VIRTEX_IPBUS_rlast(0)                 => ext_AXI_ReadMISO.last,
      VIRTEX_IPBUS_rready(0)                => ext_AXI_ReadMOSI.ready_for_data,       
      VIRTEX_IPBUS_rresp                    => ext_AXI_ReadMISO.response,             
      VIRTEX_IPBUS_rvalid(0)                => ext_AXI_ReadMISO.data_valid,           
      VIRTEX_IPBUS_wdata                    => ext_AXI_WriteMOSI.data,
      VIRTEX_IPBUS_wlast(0)                 => ext_AXI_WriteMOSI.last,
      VIRTEX_IPBUS_wready(0)                => ext_AXI_WriteMISO.ready_for_data,       
      VIRTEX_IPBUS_wstrb                    => ext_AXI_WriteMOSI.data_write_strobe,   
      VIRTEX_IPBUS_wvalid(0)                => ext_AXI_WriteMOSI.data_valid,          
      reset_n                               => locked_clk200,--reset,

      V_C2C_PHY_DEBUG_cplllock(0)         => C2C_Mon.DEBUG.CPLL_LOCK,
      V_C2C_PHY_DEBUG_dmonitorout         => C2C_Mon.DEBUG.DMONITOR,
      V_C2C_PHY_DEBUG_eyescandataerror(0) => C2C_Mon.DEBUG.EYESCAN_DATA_ERROR,
      
      V_C2C_PHY_DEBUG_eyescanreset(0)     => C2C_Ctrl.DEBUG.EYESCAN_RESET,
      V_C2C_PHY_DEBUG_eyescantrigger(0)   => C2C_Ctrl.DEBUG.EYESCAN_TRIGGER,
      V_C2C_PHY_DEBUG_pcsrsvdin           => C2C_Ctrl.DEBUG.PCS_RSV_DIN,
      V_C2C_PHY_DEBUG_qplllock(0)         => C2C_Mon.DEBUG.QPLL_LOCK,
      V_C2C_PHY_DEBUG_rxbufreset(0)       => C2C_Ctrl.DEBUG.RX.BUF_RESET,
      V_C2C_PHY_DEBUG_rxbufstatus         => C2C_Mon.DEBUG.RX.BUF_STATUS,
      V_C2C_PHY_DEBUG_rxcdrhold(0)        => C2C_Ctrl.DEBUG.RX.CDR_HOLD,
      V_C2C_PHY_DEBUG_rxdfelpmreset(0)    => C2C_Ctrl.DEBUG.RX.DFE_LPM_RESET,
      V_C2C_PHY_DEBUG_rxlpmen(0)          => C2C_Ctrl.DEBUG.RX.LPM_EN,
      V_C2C_PHY_DEBUG_rxpcsreset(0)       => C2C_Ctrl.DEBUG.RX.PCS_RESET,
      V_C2C_PHY_DEBUG_rxpmareset(0)       => C2C_Ctrl.DEBUG.RX.PMA_RESET,
      V_C2C_PHY_DEBUG_rxpmaresetdone      => open,--C2C_Mon.DEBUG.RX.RESET_DONE,
      V_C2C_PHY_DEBUG_rxprbscntreset(0)   => C2C_Ctrl.DEBUG.RX.PRBS_CNT_RST,
      V_C2C_PHY_DEBUG_rxprbserr(0)        => C2C_Mon.DEBUG.RX.PRBS_ERR,
      V_C2C_PHY_DEBUG_rxprbssel           => C2C_Ctrl.DEBUG.RX.PRBS_SEL,
      V_C2C_PHY_DEBUG_rxrate              => C2C_Ctrl.DEBUG.RX.RATE,
      V_C2C_PHY_DEBUG_rxresetdone(0)      => C2C_Mon.DEBUG.RX.RESET_DONE,
      V_C2C_PHY_DEBUG_txbufstatus         => C2C_Mon.DEBUG.TX.BUF_STATUS,
      V_C2C_PHY_DEBUG_txdiffctrl          => C2C_Ctrl.DEBUG.TX.DIFF_CTRL,
      V_C2C_PHY_DEBUG_txinhibit(0)        => C2C_Ctrl.DEBUG.TX.INHIBIT,
      V_C2C_PHY_DEBUG_txpcsreset(0)       => C2C_Ctrl.DEBUG.TX.PCS_RESET,
      V_C2C_PHY_DEBUG_txpmareset(0)       => C2C_Ctrl.DEBUG.TX.PMA_RESET,
      V_C2C_PHY_DEBUG_txpolarity(0)       => C2C_Ctrl.DEBUG.TX.POLARITY,
      V_C2C_PHY_DEBUG_txpostcursor        => C2C_Ctrl.DEBUG.TX.POST_CURSOR,
      V_C2C_PHY_DEBUG_txprbsforceerr(0)   => C2C_Ctrl.DEBUG.TX.PRBS_FORCE_ERR,
      V_C2C_PHY_DEBUG_txprbssel           => C2C_Ctrl.DEBUG.TX.PRBS_SEL,
      V_C2C_PHY_DEBUG_txprecursor         => C2C_Ctrl.DEBUG.TX.PRE_CURSOR,
      V_C2C_PHY_DEBUG_txresetdone(0)      => C2C_MON.DEBUG.TX.RESET_DONE,

      V_C2C_PHY_STATUS_channel_up         => C2C_Mon.STATUS.CHANNEL_UP,      
      V_C2C_PHY_STATUS_gt_pll_lock        => C2C_MON.STATUS.PHY_GT_PLL_LOCK,
      V_C2C_PHY_STATUS_hard_err           => C2C_Mon.STATUS.PHY_HARD_ERR,
      V_C2C_PHY_STATUS_lane_up            => C2C_Mon.STATUS.PHY_LANE_UP(0 downto 0),
      V_C2C_PHY_STATUS_mmcm_not_locked    => C2C_Mon.STATUS.PHY_MMCM_LOL,
      V_C2C_PHY_STATUS_soft_err           => C2C_Mon.STATUS.PHY_SOFT_ERR,

      V_C2C_aurora_do_cc                => C2C_Mon.STATUS.DO_CC,
      V_C2C_axi_c2c_config_error_out    => C2C_Mon.STATUS.CONFIG_ERROR,
      V_C2C_axi_c2c_link_status_out     => C2C_MON.STATUS.LINK_GOOD,
      V_C2C_axi_c2c_multi_bit_error_out => C2C_MON.STATUS.MB_ERROR,
      V_C2C_phy_power_down              => '0',
      V_C2C_PHY_user_clk_out            => clk_V_C2C_PHY_user,

      VIRTEX_SYS_MGMT_sda                   =>v_fpga_i2c_sda,
      VIRTEX_SYS_MGMT_scl                   =>v_fpga_i2c_scl
);

  RGB_pwm_1: entity work.RGB_pwm
    generic map (
      CLKFREQ => 200000000,
      RGBFREQ => 1000)
    port map (
      clk        => clk_200,
      redcount   => led_red_local,
      greencount => led_green_local,
      bluecount  => led_blue_local,
      LEDred     => led_red,
      LEDgreen   => led_green,
      LEDblue    => led_blue);

  rate_counter_1: entity work.rate_counter
    generic map (
      CLK_A_1_SECOND => 2000000)
    port map (
      clk_A         => clk_200,
      clk_B         => clk_V_C2C_PHY_user,
      reset_A_async => AXI_RESET,
      event_b       => '1',
      rate          => C2C_Mon.USER_FREQ);

  V_IO_interface_1: entity work.V_IO_map
    port map (
      clk_axi         => AXI_CLK,
      reset_axi_n     => AXI_RST_N,
      slave_readMOSI  => local_AXI_readMOSI(0),
      slave_readMISO  => local_AXI_readMISO(0),
      slave_writeMOSI => local_AXI_writeMOSI(0),
      slave_writeMISO => local_AXI_writeMISO(0),
      Mon.C2C                 => C2C_Mon,
      Mon.CLK_200_LOCKED      => locked_clk200,
      Mon.BRAM.RD_DATA        => BRAM_RD_DATA,
      Ctrl.C2C                => C2C_Ctrl,
      Ctrl.RGB.R              => led_red_local,
      Ctrl.RGB.G              => led_green_local,
      Ctrl.RGB.B              => led_blue_local,
      Ctrl.BRAM.WRITE         => BRAM_WRITE,
      Ctrl.BRAM.ADDR(9 downto 0) => BRAM_ADDR,
      Ctrl.BRAM.ADDR(14 downto 10) => open,
      Ctrl.BRAM.WR_DATA       => BRAM_WR_DATA
      );

  CM_V_info_1: entity work.CM_V_info
    port map (
      clk_axi     => AXI_CLK,
      reset_axi_n => AXI_RST_N,
      readMOSI    => local_AXI_ReadMOSI(1),
      readMISO    => local_AXI_ReadMISO(1),
      writeMOSI   => local_AXI_WriteMOSI(1),
      writeMISO   => local_AXI_WriteMISO(1));


  AXI_RESET <= not AXI_RST_N;



  axi_bram_controller_1: entity work.axi_bram_controller
    generic map (
      USE_D64_PKG                   => 1,
      C_ADR_WIDTH                   => 32,
      C_DATA_WIDTH                  => 64,
      C_FAMILY                      => "virtexuplus",
      C_MEMORY_DEPTH                => 4096,
      C_BRAM_ADDR_WIDTH             => 12,
      C_SINGLE_PORT_BRAM            => 1,
      C_S_AXI_ID_WIDTH              => 0,
      C_S_AXI_PROTOCOL              => "AXI4",
      C_S_AXI_DATA_WIDTH            => 64)
    port map (
      s_axi_aclk    => AXI_CLK,
      s_axi_aresetn => AXI_RST_N,
      r_mosi_d64        => ext_AXI_ReadMOSI,
      r_miso_d64        => ext_AXI_ReadMISO,
      w_mosi_d64        => ext_AXI_WriteMOSI,
      w_miso_d64        => ext_AXI_WriteMISO,
      bram_rst_a    => bram_rst_a,
      bram_clk_a    => bram_clk_a,
      bram_en_a     => bram_en_a,
      bram_we_a     => bram_we_a,
      bram_addr_a(31 downto 11) => open,
      bram_addr_a(10 downto  2) => bram_addr_a,
      bram_addr_a( 1 downto  0) => open,
      bram_wrdata_a => bram_wrdata_a,
      bram_rddata_a => bram_rddata_a);

  asym_ram_tdp_1: entity work.asym_ram_tdp
    generic map (
      WIDTHA     => 32,
      SIZEA      => 1024,
      ADDRWIDTHA => 10,
      WIDTHB     => 64,
      SIZEB      => 512,
      ADDRWIDTHB => 9)
    port map (
      clkA  => AXI_CLK,
      clkB  => AXI_CLK,
      enA   => '1',
      enB   => bram_en_a,
      weA   => BRAM_WRITE,
      weB   => or_reduce(bram_we_a),
      addrA => BRAM_ADDR,
      addrB => bram_addr_a,
      diA   => BRAM_WR_DATA,
      diB   => bram_wrdata_a,
      doA   => open,
      doB   => bram_rddata_a);
end architecture structure;
