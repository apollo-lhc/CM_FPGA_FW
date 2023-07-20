library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use ieee.std_logic_misc.all;

use work.axiRegPkg.all;
use work.axiRegPkg_d64.all;
use work.types.all;
use work.IO_Ctrl.all;
use work.C2C_INTF_CTRL.all;
use work.AXISlaveAddrPkg.all;                                                                                       

Library UNISIM;
use UNISIM.vcomponents.all;

entity top is
  port (
    -- clocks
    clk_200_p : in std_logic;
    clk_200_n : in std_logic;           -- 100 MHz system clock
    -- FF clocks
    clk_ff_P        : in  std_logic_vector(63 downto 0);
    clk_ff_N        : in  std_logic_vector(63 downto 0);

    -- Zynq AXI Chip2Chip
    n_mgt_z2k        : in  std_logic_vector(2 downto 1);
    p_mgt_z2k        : in  std_logic_vector(2 downto 1);
    n_mgt_k2z        : out std_logic_vector(2 downto 1);
    p_mgt_k2z        : out std_logic_vector(2 downto 1);

    -- 200.00 MHz clock f
    clk_tc_p        : in  std_logic;
    clk_tc_n        : in  std_logic;        
    -- clock out
    CLK_TC_OUT_P    : out std_logic;
    CLK_TC_OUT_N    : out std_logic;
    -- I2C
    SCL             : in  std_logic;
    SDA             : inout std_logic

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

  constant localAXISlaves    : integer := 3;
  signal local_AXI_ReadMOSI  :  AXIReadMOSI_array_t(0 to localAXISlaves-1) := ( others => DefaultAXIReadMOSI);
  signal local_AXI_ReadMISO  :  AXIReadMISO_array_t(0 to localAXISlaves-1) := ( others => DefaultAXIReadMISO);
  signal local_AXI_WriteMOSI : AXIWriteMOSI_array_t(0 to localAXISlaves-1) := ( others => DefaultAXIWriteMOSI);
  signal local_AXI_WriteMISO : AXIWriteMISO_array_t(0 to localAXISlaves-1) := ( others => DefaultAXIWriteMISO);
  signal AXI_CLK             : std_logic;
  signal AXI_RST_N           : std_logic;
  signal AXI_RESET           : std_logic;

  signal ext_AXI_ReadMOSI  :  AXIReadMOSI_d64 := DefaultAXIReadMOSI_d64;
  signal ext_AXI_ReadMISO  :  AXIReadMISO_d64 := DefaultAXIReadMISO_d64;
  signal ext_AXI_WriteMOSI : AXIWriteMOSI_d64 := DefaultAXIWriteMOSI_d64;
  signal ext_AXI_WriteMISO : AXIWriteMISO_d64 := DefaultAXIWriteMISO_d64;

  signal C2C_Mon  : C2C_INTF_MON_t;
  signal C2C_Ctrl : C2C_INTF_Ctrl_t;
  
  signal clk_K_C2C_PHY_user                  : STD_logic_vector(2 downto 1);


  signal BRAM_write : std_logic;
  signal BRAM_addr  : std_logic_vector(10 downto 0);
  signal BRAM_WR_data : std_logic_vector(31 downto 0);
  signal BRAM_RD_data : std_logic_vector(31 downto 0);

  signal AXI_BRAM_EN : std_logic;
  signal AXI_BRAM_we : std_logic_vector(7 downto 0);
  signal AXI_BRAM_addr :std_logic_vector(12 downto 0);
  signal AXI_BRAM_DATA_IN : std_logic_vector(63 downto 0);
  signal AXI_BRAM_DATA_OUT : std_logic_vector(63 downto 0);


  signal bram_rst_a    : std_logic;
  signal bram_clk_a    : std_logic;
  signal bram_en_a     : std_logic;
  signal bram_we_a     : std_logic_vector(7 downto 0);
  signal bram_addr_a   : std_logic_vector(8 downto 0);
  signal bram_wrdata_a : std_logic_vector(63 downto 0);
  signal bram_rddata_a : std_logic_vector(63 downto 0);

  signal clocktc          : std_logic;
  signal clocktc_bufg     : std_logic;
  signal clk_ff_ds        : std_logic_vector (63 downto 0);
  signal clk_ff_bufg      : std_logic_vector (63 downto 0);
  signal SCL_b            : std_logic;
  signal SDA_b            : std_logic;
  signal SDA_Z_en         : std_logic;
  signal mmcm_reset_r0    : std_logic;
  signal mmcm_reset_r1    : std_logic;
  signal mmcm_reset_r2    : std_logic;
  signal mmcm_lock        : std_logic;
  
  signal clock_tc_out     : std_logic;

  constant family : string := "virtexuplus";
  constant axi_protocol : string := "AXI4";


  signal pB_UART_tx : std_logic;
  signal pB_UART_rx : std_logic;
  
  
begin  -- architecture structure

  core : entity work.core
  port map (
      clock200    =>  clk_200,
      reset       =>  mmcm_reset_r2,
      SCL         =>  SCL_b,
      SDA         =>  SDA_b,
      SDA_Z_en    =>  SDA_Z_en,
      clocks      =>  clk_ff_bufg,
      clk_50      =>  clk_50,
      clk_in_tc   =>  clocktc_bufg,
      clk_out_tc  =>  clocktc_bufg
  );



  --Clocking
  Local_Clocking: entity work.onboardclk
    port map (
      clk_200MHz   => clk_200,
      clk_50Mhz    => clk_50,
      reset     => '0',
      locked    => locked_clk200,
      clk_in1_p => clk_200_p,
      clk_in1_n => clk_200_n);
  
  AXI_CLK <= clk_50;

  

  c2csslave_wrapper_1: entity work.c2cslave_wrapper
    port map (
      AXI_CLK                             => AXI_CLK,
      AXI_RST_N(0)                        => AXI_RST_N,
      CM1_PB_UART_rxd                     => pB_UART_tx,
      CM1_PB_UART_txd                     => pB_UART_rx,

      K_C2C_phy_Rx_rxn                  => n_mgt_z2k(1 downto 1),
      K_C2C_phy_Rx_rxp                  => p_mgt_z2k(1 downto 1),
      K_C2C_phy_Tx_txn                  => n_mgt_k2z(1 downto 1),
      K_C2C_phy_Tx_txp                  => p_mgt_k2z(1 downto 1),
      K_C2CB_phy_Rx_rxn                  => n_mgt_z2k(2 downto 2),
      K_C2CB_phy_Rx_rxp                  => p_mgt_z2k(2 downto 2),
      K_C2CB_phy_Tx_txn                  => n_mgt_k2z(2 downto 2),
      K_C2CB_phy_Tx_txp                  => p_mgt_k2z(2 downto 2),
      K_C2C_phy_refclk_clk_n            => clk_ff_n(62),
      K_C2C_phy_refclk_clk_p            => clk_ff_p(62),
      clk50Mhz                            => clk_50,
      K_IO_araddr                         => local_AXI_ReadMOSI(0).address,              
      K_IO_arprot                         => local_AXI_ReadMOSI(0).protection_type,      
      K_IO_arready(0)                        => local_AXI_ReadMISO(0).ready_for_address,    
      K_IO_arvalid(0)                        => local_AXI_ReadMOSI(0).address_valid,        
      K_IO_awaddr                         => local_AXI_WriteMOSI(0).address,             
      K_IO_awprot                         => local_AXI_WriteMOSI(0).protection_type,     
      K_IO_awready(0)                        => local_AXI_WriteMISO(0).ready_for_address,   
      K_IO_awvalid(0)                        => local_AXI_WriteMOSI(0).address_valid,       
      K_IO_bready(0)                      => local_AXI_WriteMOSI(0).ready_for_response,  
      K_IO_bresp                          => local_AXI_WriteMISO(0).response,            
      K_IO_bvalid(0)                      => local_AXI_WriteMISO(0).response_valid,      
      K_IO_rdata                          => local_AXI_ReadMISO(0).data,                 
      K_IO_rready(0)                      => local_AXI_ReadMOSI(0).ready_for_data,       
      K_IO_rresp                          => local_AXI_ReadMISO(0).response,             
      K_IO_rvalid(0)                      => local_AXI_ReadMISO(0).data_valid,           
      K_IO_wdata                          => local_AXI_WriteMOSI(0).data,                
      K_IO_wready(0)                      => local_AXI_WriteMISO(0).ready_for_data,       
      K_IO_wstrb                          => local_AXI_WriteMOSI(0).data_write_strobe,   
      K_IO_wvalid(0)                      => local_AXI_WriteMOSI(0).data_valid,          
      K_CM_FW_INFO_araddr                    => local_AXI_ReadMOSI(1).address,              
      K_CM_FW_INFO_arprot                    => local_AXI_ReadMOSI(1).protection_type,      
      K_CM_FW_INFO_arready(0)                => local_AXI_ReadMISO(1).ready_for_address,    
      K_CM_FW_INFO_arvalid(0)                => local_AXI_ReadMOSI(1).address_valid,        
      K_CM_FW_INFO_awaddr                    => local_AXI_WriteMOSI(1).address,             
      K_CM_FW_INFO_awprot                    => local_AXI_WriteMOSI(1).protection_type,     
      K_CM_FW_INFO_awready(0)                => local_AXI_WriteMISO(1).ready_for_address,   
      K_CM_FW_INFO_awvalid(0)                => local_AXI_WriteMOSI(1).address_valid,       
      K_CM_FW_INFO_bready(0)                 => local_AXI_WriteMOSI(1).ready_for_response,  
      K_CM_FW_INFO_bresp                     => local_AXI_WriteMISO(1).response,            
      K_CM_FW_INFO_bvalid(0)                 => local_AXI_WriteMISO(1).response_valid,      
      K_CM_FW_INFO_rdata                     => local_AXI_ReadMISO(1).data,                 
      K_CM_FW_INFO_rready(0)                 => local_AXI_ReadMOSI(1).ready_for_data,       
      K_CM_FW_INFO_rresp                     => local_AXI_ReadMISO(1).response,             
      K_CM_FW_INFO_rvalid(0)                 => local_AXI_ReadMISO(1).data_valid,           
      K_CM_FW_INFO_wdata                     => local_AXI_WriteMOSI(1).data,                
      K_CM_FW_INFO_wready(0)                 => local_AXI_WriteMISO(1).ready_for_data,       
      K_CM_FW_INFO_wstrb                     => local_AXI_WriteMOSI(1).data_write_strobe,   
      K_CM_FW_INFO_wvalid(0)                 => local_AXI_WriteMOSI(1).data_valid,          

     
      reset_n                             => locked_clk200,--reset,
      K_C2C_PHY_DEBUG_cplllock(0)         => C2C_Mon.C2C(1).DEBUG.CPLL_LOCK,
      K_C2C_PHY_DEBUG_dmonitorout         => C2C_Mon.C2C(1).DEBUG.DMONITOR,
      K_C2C_PHY_DEBUG_eyescandataerror(0) => C2C_Mon.C2C(1).DEBUG.EYESCAN_DATA_ERROR,
      
      K_C2C_PHY_DEBUG_eyescanreset(0)     => C2C_Ctrl.C2C(1).DEBUG.EYESCAN_RESET,
      K_C2C_PHY_DEBUG_eyescantrigger(0)   => C2C_Ctrl.C2C(1).DEBUG.EYESCAN_TRIGGER,
      K_C2C_PHY_DEBUG_pcsrsvdin           => C2C_Ctrl.C2C(1).DEBUG.PCS_RSV_DIN,
      K_C2C_PHY_DEBUG_qplllock(0)         =>  C2C_Mon.C2C(1).DEBUG.QPLL_LOCK,
      K_C2C_PHY_DEBUG_rxbufreset(0)       => C2C_Ctrl.C2C(1).DEBUG.RX.BUF_RESET,
      K_C2C_PHY_DEBUG_rxbufstatus         =>  C2C_Mon.C2C(1).DEBUG.RX.BUF_STATUS,
      K_C2C_PHY_DEBUG_rxcdrhold(0)        => C2C_Ctrl.C2C(1).DEBUG.RX.CDR_HOLD,
      K_C2C_PHY_DEBUG_rxdfelpmreset(0)    => C2C_Ctrl.C2C(1).DEBUG.RX.DFE_LPM_RESET,
      K_C2C_PHY_DEBUG_rxlpmen(0)          => C2C_Ctrl.C2C(1).DEBUG.RX.LPM_EN,
      K_C2C_PHY_DEBUG_rxpcsreset(0)       => C2C_Ctrl.C2C(1).DEBUG.RX.PCS_RESET,
      K_C2C_PHY_DEBUG_rxpmareset(0)       => C2C_Ctrl.C2C(1).DEBUG.RX.PMA_RESET,
      K_C2C_PHY_DEBUG_rxpmaresetdone(0)   =>  C2C_Mon.C2C(1).DEBUG.RX.PMA_RESET_DONE,
      K_C2C_PHY_DEBUG_rxprbscntreset(0)   => C2C_Ctrl.C2C(1).DEBUG.RX.PRBS_CNT_RST,
      K_C2C_PHY_DEBUG_rxprbserr(0)        =>  C2C_Mon.C2C(1).DEBUG.RX.PRBS_ERR,
      K_C2C_PHY_DEBUG_rxprbssel           => C2C_Ctrl.C2C(1).DEBUG.RX.PRBS_SEL,
      K_C2C_PHY_DEBUG_rxrate              => C2C_Ctrl.C2C(1).DEBUG.RX.RATE,
      K_C2C_PHY_DEBUG_rxresetdone(0)      =>  C2C_Mon.C2C(1).DEBUG.RX.RESET_DONE,
      K_C2C_PHY_DEBUG_txbufstatus         =>  C2C_Mon.C2C(1).DEBUG.TX.BUF_STATUS,
      K_C2C_PHY_DEBUG_txdiffctrl          => C2C_Ctrl.C2C(1).DEBUG.TX.DIFF_CTRL,
      K_C2C_PHY_DEBUG_txinhibit(0)        => C2C_Ctrl.C2C(1).DEBUG.TX.INHIBIT,
      K_C2C_PHY_DEBUG_txpcsreset(0)       => C2C_Ctrl.C2C(1).DEBUG.TX.PCS_RESET,
      K_C2C_PHY_DEBUG_txpmareset(0)       => C2C_Ctrl.C2C(1).DEBUG.TX.PMA_RESET,
      K_C2C_PHY_DEBUG_txpolarity(0)       => C2C_Ctrl.C2C(1).DEBUG.TX.POLARITY,
      K_C2C_PHY_DEBUG_txpostcursor        => C2C_Ctrl.C2C(1).DEBUG.TX.POST_CURSOR,
      K_C2C_PHY_DEBUG_txprbsforceerr(0)   => C2C_Ctrl.C2C(1).DEBUG.TX.PRBS_FORCE_ERR,
      K_C2C_PHY_DEBUG_txprbssel           => C2C_Ctrl.C2C(1).DEBUG.TX.PRBS_SEL,
      K_C2C_PHY_DEBUG_txprecursor         => C2C_Ctrl.C2C(1).DEBUG.TX.PRE_CURSOR,
      K_C2C_PHY_DEBUG_txresetdone(0)      =>  C2C_MON.C2C(1).DEBUG.TX.RESET_DONE,

      K_C2C_PHY_channel_up         => C2C_Mon.C2C(1).STATUS.CHANNEL_UP,      
      K_C2C_PHY_gt_pll_lock        => C2C_MON.C2C(1).STATUS.PHY_GT_PLL_LOCK,
      K_C2C_PHY_hard_err           => C2C_Mon.C2C(1).STATUS.PHY_HARD_ERR,
      K_C2C_PHY_lane_up            => C2C_Mon.C2C(1).STATUS.PHY_LANE_UP(0 downto 0),
      K_C2C_PHY_mmcm_not_locked_out    => C2C_Mon.C2C(1).STATUS.PHY_MMCM_LOL,
      K_C2C_PHY_soft_err           => C2C_Mon.C2C(1).STATUS.PHY_SOFT_ERR,

      K_C2C_aurora_do_cc                =>  C2C_Mon.C2C(1).STATUS.DO_CC,
      K_C2C_aurora_pma_init_in          => C2C_Ctrl.C2C(1).STATUS.INITIALIZE,
      K_C2C_axi_c2c_config_error_out    =>  C2C_Mon.C2C(1).STATUS.CONFIG_ERROR,
      K_C2C_axi_c2c_link_status_out     =>  C2C_MON.C2C(1).STATUS.LINK_GOOD,
      K_C2C_axi_c2c_multi_bit_error_out =>  C2C_MON.C2C(1).STATUS.MB_ERROR,
      K_C2C_phy_power_down              => '0',
      K_C2C_PHY_clk                     => clk_K_C2C_PHY_user(1),
      K_C2C_PHY_DRP_daddr               => C2C_Ctrl.C2C(1).DRP.address,
      K_C2C_PHY_DRP_den                 => C2C_Ctrl.C2C(1).DRP.enable,
      K_C2C_PHY_DRP_di                  => C2C_Ctrl.C2C(1).DRP.wr_data,
      K_C2C_PHY_DRP_do                  => C2C_MON.C2C(1).DRP.rd_data,
      K_C2C_PHY_DRP_drdy                => C2C_MON.C2C(1).DRP.rd_data_valid,
      K_C2C_PHY_DRP_dwe                 => C2C_Ctrl.C2C(1).DRP.wr_enable,
            K_C2CB_PHY_DEBUG_cplllock(0)         => C2C_Mon.C2C(2).DEBUG.CPLL_LOCK,
      K_C2CB_PHY_DEBUG_dmonitorout         => C2C_Mon.C2C(2).DEBUG.DMONITOR,
      K_C2CB_PHY_DEBUG_eyescandataerror(0) => C2C_Mon.C2C(2).DEBUG.EYESCAN_DATA_ERROR,
      
      K_C2CB_PHY_DEBUG_eyescanreset(0)     => C2C_Ctrl.C2C(2).DEBUG.EYESCAN_RESET,
      K_C2CB_PHY_DEBUG_eyescantrigger(0)   => C2C_Ctrl.C2C(2).DEBUG.EYESCAN_TRIGGER,
      K_C2CB_PHY_DEBUG_pcsrsvdin           => C2C_Ctrl.C2C(2).DEBUG.PCS_RSV_DIN,
      K_C2CB_PHY_DEBUG_qplllock(0)         =>  C2C_Mon.C2C(2).DEBUG.QPLL_LOCK,
      K_C2CB_PHY_DEBUG_rxbufreset(0)       => C2C_Ctrl.C2C(2).DEBUG.RX.BUF_RESET,
      K_C2CB_PHY_DEBUG_rxbufstatus         =>  C2C_Mon.C2C(2).DEBUG.RX.BUF_STATUS,
      K_C2CB_PHY_DEBUG_rxcdrhold(0)        => C2C_Ctrl.C2C(2).DEBUG.RX.CDR_HOLD,
      K_C2CB_PHY_DEBUG_rxdfelpmreset(0)    => C2C_Ctrl.C2C(2).DEBUG.RX.DFE_LPM_RESET,
      K_C2CB_PHY_DEBUG_rxlpmen(0)          => C2C_Ctrl.C2C(2).DEBUG.RX.LPM_EN,
      K_C2CB_PHY_DEBUG_rxpcsreset(0)       => C2C_Ctrl.C2C(2).DEBUG.RX.PCS_RESET,
      K_C2CB_PHY_DEBUG_rxpmareset(0)       => C2C_Ctrl.C2C(2).DEBUG.RX.PMA_RESET,
      K_C2CB_PHY_DEBUG_rxpmaresetdone(0)   =>  C2C_Mon.C2C(2).DEBUG.RX.PMA_RESET_DONE,
      K_C2CB_PHY_DEBUG_rxprbscntreset(0)   => C2C_Ctrl.C2C(2).DEBUG.RX.PRBS_CNT_RST,
      K_C2CB_PHY_DEBUG_rxprbserr(0)        =>  C2C_Mon.C2C(2).DEBUG.RX.PRBS_ERR,
      K_C2CB_PHY_DEBUG_rxprbssel           => C2C_Ctrl.C2C(2).DEBUG.RX.PRBS_SEL,
      K_C2CB_PHY_DEBUG_rxrate              => C2C_Ctrl.C2C(2).DEBUG.RX.RATE,
      K_C2CB_PHY_DEBUG_rxresetdone(0)      =>  C2C_Mon.C2C(2).DEBUG.RX.RESET_DONE,
      K_C2CB_PHY_DEBUG_txbufstatus         =>  C2C_Mon.C2C(2).DEBUG.TX.BUF_STATUS,
      K_C2CB_PHY_DEBUG_txdiffctrl          => C2C_Ctrl.C2C(2).DEBUG.TX.DIFF_CTRL,
      K_C2CB_PHY_DEBUG_txinhibit(0)        => C2C_Ctrl.C2C(2).DEBUG.TX.INHIBIT,
      K_C2CB_PHY_DEBUG_txpcsreset(0)       => C2C_Ctrl.C2C(2).DEBUG.TX.PCS_RESET,
      K_C2CB_PHY_DEBUG_txpmareset(0)       => C2C_Ctrl.C2C(2).DEBUG.TX.PMA_RESET,
      K_C2CB_PHY_DEBUG_txpolarity(0)       => C2C_Ctrl.C2C(2).DEBUG.TX.POLARITY,
      K_C2CB_PHY_DEBUG_txpostcursor        => C2C_Ctrl.C2C(2).DEBUG.TX.POST_CURSOR,
      K_C2CB_PHY_DEBUG_txprbsforceerr(0)   => C2C_Ctrl.C2C(2).DEBUG.TX.PRBS_FORCE_ERR,
      K_C2CB_PHY_DEBUG_txprbssel           => C2C_Ctrl.C2C(2).DEBUG.TX.PRBS_SEL,
      K_C2CB_PHY_DEBUG_txprecursor         => C2C_Ctrl.C2C(2).DEBUG.TX.PRE_CURSOR,
      K_C2CB_PHY_DEBUG_txresetdone(0)      =>  C2C_MON.C2C(2).DEBUG.TX.RESET_DONE,

      K_C2CB_PHY_channel_up         => C2C_Mon.C2C(2).STATUS.CHANNEL_UP,      
      K_C2CB_PHY_gt_pll_lock        => C2C_MON.C2C(2).STATUS.PHY_GT_PLL_LOCK,
      K_C2CB_PHY_hard_err           => C2C_Mon.C2C(2).STATUS.PHY_HARD_ERR,
      K_C2CB_PHY_lane_up            => C2C_Mon.C2C(2).STATUS.PHY_LANE_UP(0 downto 0),
--      K_C2CB_PHY_mmcm_not_locked    => C2C_Mon.C2C(2).STATUS.PHY_MMCM_LOL,
      K_C2CB_PHY_soft_err           => C2C_Mon.C2C(2).STATUS.PHY_SOFT_ERR,

      K_C2CB_aurora_do_cc                =>  C2C_Mon.C2C(2).STATUS.DO_CC,
      K_C2CB_aurora_pma_init_in          => C2C_Ctrl.C2C(2).STATUS.INITIALIZE,
      K_C2CB_axi_c2c_config_error_out    =>  C2C_Mon.C2C(2).STATUS.CONFIG_ERROR,
      K_C2CB_axi_c2c_link_status_out     =>  C2C_MON.C2C(2).STATUS.LINK_GOOD,
      K_C2CB_axi_c2c_multi_bit_error_out =>  C2C_MON.C2C(2).STATUS.MB_ERROR,
      K_C2CB_phy_power_down              => '0',
--      K_C2CB_PHY_user_clk_out            => clk_K_C2CB_PHY_user,
      K_C2CB_PHY_DRP_daddr               => C2C_Ctrl.C2C(2).DRP.address,
      K_C2CB_PHY_DRP_den                 => C2C_Ctrl.C2C(2).DRP.enable,
      K_C2CB_PHY_DRP_di                  => C2C_Ctrl.C2C(2).DRP.wr_data,
      K_C2CB_PHY_DRP_do                  => C2C_MON.C2C(2).DRP.rd_data,
      K_C2CB_PHY_DRP_drdy                => C2C_MON.C2C(2).DRP.rd_data_valid,
      K_C2CB_PHY_DRP_dwe                 => C2C_Ctrl.C2C(2).DRP.wr_enable,

      K_C2C_INTF_araddr                   => local_AXI_ReadMOSI(2).address,              
      K_C2C_INTF_arprot                   => local_AXI_ReadMOSI(2).protection_type,      
      K_C2C_INTF_arready(0)               => local_AXI_ReadMISO(2).ready_for_address,    
      K_C2C_INTF_arvalid(0)               => local_AXI_ReadMOSI(2).address_valid,        
      K_C2C_INTF_awaddr                   => local_AXI_WriteMOSI(2).address,             
      K_C2C_INTF_awprot                   => local_AXI_WriteMOSI(2).protection_type,     
      K_C2C_INTF_awready(0)               => local_AXI_WriteMISO(2).ready_for_address,   
      K_C2C_INTF_awvalid(0)               => local_AXI_WriteMOSI(2).address_valid,       
      K_C2C_INTF_bready(0)                => local_AXI_WriteMOSI(2).ready_for_response,  
      K_C2C_INTF_bresp                    => local_AXI_WriteMISO(2).response,            
      K_C2C_INTF_bvalid(0)                => local_AXI_WriteMISO(2).response_valid,      
      K_C2C_INTF_rdata                    => local_AXI_ReadMISO(2).data,                 
      K_C2C_INTF_rready(0)                => local_AXI_ReadMOSI(2).ready_for_data,       
      K_C2C_INTF_rresp                    => local_AXI_ReadMISO(2).response,             
      K_C2C_INTF_rvalid(0)                => local_AXI_ReadMISO(2).data_valid,           
      K_C2C_INTF_wdata                    => local_AXI_WriteMOSI(2).data,                
      K_C2C_INTF_wready(0)                => local_AXI_WriteMISO(2).ready_for_data,       
      K_C2C_INTF_wstrb                    => local_AXI_WriteMOSI(2).data_write_strobe,   
      K_C2C_INTF_wvalid(0)                => local_AXI_WriteMOSI(2).data_valid

      
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
      LEDred     => open,
      LEDgreen   => open,
      LEDblue    => open);

  K_IO_interface_1: entity work.IO_map
    generic map(
      ALLOCATED_MEMORY_RANGE => to_integer(AXI_RANGE_K_IO)
      )
    port map (
      clk_axi         => AXI_CLK,
      reset_axi_n     => AXI_RST_N,
      slave_readMOSI  => local_AXI_readMOSI(0),
      slave_readMISO  => local_AXI_readMISO(0),
      slave_writeMOSI => local_AXI_writeMOSI(0),
      slave_writeMISO => local_AXI_writeMISO(0),
      Mon.CLK_200_LOCKED      => locked_clk200,      
      Mon.BRAM.RD_DATA        => BRAM_RD_DATA,
      Ctrl.RGB.R              => led_red_local,
      Ctrl.RGB.G              => led_green_local,
      Ctrl.RGB.B              => led_blue_local,
      Ctrl.BRAM.WRITE         => BRAM_WRITE,
      Ctrl.BRAM.ADDR(10 downto 0)          => BRAM_ADDR,
      Ctrl.BRAM.ADDR(14 downto 11) => open,
      Ctrl.BRAM.WR_DATA       => BRAM_WR_DATA
      );

  CM_K_info_1: entity work.CM_FW_info
    generic map (
      ALLOCATED_MEMORY_RANGE => to_integer(AXI_RANGE_K_CM_FW_INFO)
      )
    port map (
      clk_axi     => AXI_CLK,
      reset_axi_n => AXI_RST_N,
      readMOSI    => local_AXI_ReadMOSI(1),
      readMISO    => local_AXI_ReadMISO(1),
      writeMOSI   => local_AXI_WriteMOSI(1),
      writeMISO   => local_AXI_WriteMISO(1));


--  AXI_RESET <= not AXI_RST_N;

  C2C_INTF_1: entity work.C2C_INTF
    generic map (
      ERROR_WAIT_TIME => 90000000,
      ALLOCATED_MEMORY_RANGE => to_integer(AXI_RANGE_K_C2C_INTF))
    port map (
      clk_axi          => AXI_CLK,
      reset_axi_n      => AXI_RST_N,
      readMOSI         => local_AXI_readMOSI(2),
      readMISO         => local_AXI_readMISO(2),
      writeMOSI        => local_AXI_writeMOSI(2),
      writeMISO        => local_AXI_writeMISO(2),
      clk_C2C(1)       => clk_K_C2C_PHY_user(1),
      clk_C2C(2)       => clk_K_C2C_PHY_user(1),
      UART_Rx          => pb_UART_Rx,
      UART_Tx          => pb_UART_Tx,
      Mon              => C2C_Mon,
      Ctrl             => C2C_Ctrl);

    -- clocktc
    clocktc_i_buff : IBUFDS
    generic map (
        DIFF_TERM       =>  TRUE,
        IBUF_LOW_PWR    =>  FALSE
    )
    port map
    (
        I  => clk_tc_p,
        IB => clk_tc_n,
        O  => clocktc
    );
    clocktc_bufg_inst : BUFG
    port map (
        O => clocktc_bufg,
        I => clocktc
    );


  -- reset
  reset_logic : process(clk_200)
  begin
      if rising_edge(clk_200) then
          if mmcm_lock = '0' then
              mmcm_reset_r0 <= '1';
              mmcm_reset_r1 <= '1';
              mmcm_reset_r2 <= '1';
          else
              mmcm_reset_r0 <= '0';
              mmcm_reset_r1 <= mmcm_reset_r0;
              mmcm_reset_r2 <= mmcm_reset_r1;
          end if;
      end if;
  end process;

  -- FF clocks
  IBUFDS_GTE4_64: for i in 0 to 63 generate
    clockFF_i_buff : IBUFDS_GTE4
--        generic map (
--            REFCLK_HROW_CK_SEL  =>  2'b00
--        )
    port map
    (
        I   => clk_ff_p(i),
        IB  => clk_ff_n(i),
        CEB => '0',
        ODIV2   => clk_ff_ds(i)
    );
  
  clockFF_bufg : BUFG_GT
  port map (
    O => clk_ff_bufg(i),             -- 1-bit output: Buffer
    CE => '1',           -- 1-bit input: Buffer enable
    CEMASK => '1',   -- 1-bit input: CE Mask
    CLR => '0',         -- 1-bit input: Asynchronous clear
    CLRMASK => '0', -- 1-bit input: CLR Mask
    DIV => "000",         -- 3-bit input: Dynamic divide Value
    I => clk_ff_ds(i)             -- 1-bit input: Buffer
  );
  end generate;



  ODDRE1_inst : ODDRE1
  generic map (
    IS_C_INVERTED => '0',            -- Optional inversion for C
    IS_D1_INVERTED => '0',           -- Unsupported, do not use
    IS_D2_INVERTED => '0',           -- Unsupported, do not use
    SIM_DEVICE => "ULTRASCALE_PLUS", -- Set the device version for simulation functionality (ULTRASCALE,
                                    -- ULTRASCALE_PLUS, ULTRASCALE_PLUS_ES1, ULTRASCALE_PLUS_ES2)
    SRVAL => '0'                     -- Initializes the ODDRE1 Flip-Flops to the specified value ('0', '1')
  )
  port map (
    Q => clock_tc_out,   -- 1-bit output: Data output to IOB
    C => clk_ff_bufg(0),   --  clk_ff_bufg(0) corresponds to gty120
    D1 => '1', -- 1-bit input: Parallel data input 1
    D2 => '0', -- 1-bit input: Parallel data input 2
    SR => '0'  -- 1-bit input: Active-High Async Reset
  );
  OBUFDS_inst : OBUFDS
  port map (
    O => CLK_TC_OUT_P,   -- 1-bit output: Diff_p output (connect directly to top-level port)
    OB => CLK_TC_OUT_N, -- 1-bit output: Diff_n output (connect directly to top-level port)
    I => clock_tc_out    -- 1-bit input: Buffer input
  );
  SCL_buff_in: IBUF
  port map (
      I => SCL,
      O => SCL_b
  );

  SDA_buff_io : IOBUF
  generic map (
    DRIVE => 12,
    IOSTANDARD => "DEFAULT",
    SLEW => "SLOW")
  port map (
    O  => SDA_b,   -- Buffer output
    IO => SDA,     -- Buffer inout port (connect directly to top-level port)
    I  => '0',     -- Buffer input
    T  => SDA_Z_en -- 3-state enable input, high=input, low=output 
  );



  

  
end architecture structure;
