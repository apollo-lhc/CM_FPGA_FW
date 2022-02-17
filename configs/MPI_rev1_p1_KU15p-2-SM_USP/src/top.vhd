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
    p_clk_100 : in std_logic;
    n_clk_100 : in std_logic;           -- 100 MHz system clock

    -- Zynq AXI Chip2Chip
    n_util_clk_chan0 : in std_logic;
    p_util_clk_chan0 : in std_logic;
    n_mgt_z2k        : in  std_logic_vector(2 downto 1);
    p_mgt_z2k        : in  std_logic_vector(2 downto 1);
    n_mgt_k2z        : out std_logic_vector(2 downto 1);
    p_mgt_k2z        : out std_logic_vector(2 downto 1)

--    k_fpga_i2c_scl   : inout std_logic;
--    k_fpga_i2c_sda   : inout std_logic

    --TCDS
    --p_clk0_chan0     : in std_logic; -- 200 MHz system clock
    --n_clk0_chan0     : in std_logic; 
    --p_clk1_chan0     : in std_logic; -- 312.195122 MHz synth clock
    --n_clk1_chan0     : in std_logic;
    --p_atca_tts_out   : out std_logic;
    --n_atca_tts_out   : out std_logic;
    --p_atca_ttc_in    : in  std_logic;
    --n_atca_ttc_in    : in  std_logic;

    
    -- tri-color LED
    --led_red : out std_logic;
    --led_green : out std_logic;
    --led_blue : out std_logic       -- assert to turn on
    -- utility bits to/from TM4C
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

--  signal ext_AXI_ReadMOSI  :  AXIReadMOSI_d64 := DefaultAXIReadMOSI_d64;
--  signal ext_AXI_ReadMISO  :  AXIReadMISO_d64 := DefaultAXIReadMISO_d64;
--  signal ext_AXI_WriteMOSI : AXIWriteMOSI_d64 := DefaultAXIWriteMOSI_d64;
--  signal ext_AXI_WriteMISO : AXIWriteMISO_d64 := DefaultAXIWriteMISO_d64;

  signal C2C_Mon  : C2C_INTF_MON_t;
  signal C2C_Ctrl : C2C_INTF_Ctrl_t;
  
  signal clk_K_C2C_PHY_user                  : STD_logic_vector(2 downto 1);


  signal BRAM_write : std_logic;
  signal BRAM_addr  : std_logic_vector(9 downto 0);
  signal BRAM_WR_data : std_logic_vector(31 downto 0);
  signal BRAM_RD_data : std_logic_vector(31 downto 0);

--  signal AXI_BRAM_EN : std_logic;
--  signal AXI_BRAM_we : std_logic_vector(7 downto 0);
--  signal AXI_BRAM_addr :std_logic_vector(12 downto 0);
--  signal AXI_BRAM_DATA_IN : std_logic_vector(63 downto 0);
--  signal AXI_BRAM_DATA_OUT : std_logic_vector(63 downto 0);


  signal bram_rst_a    : std_logic;
  signal bram_clk_a    : std_logic;
  signal bram_en_a     : std_logic;
  signal bram_we_a     : std_logic_vector(7 downto 0);
  signal bram_addr_a   : std_logic_vector(8 downto 0);
  signal bram_wrdata_a : std_logic_vector(63 downto 0);
  signal bram_rddata_a : std_logic_vector(63 downto 0);


  constant family : string := "kintexuplus";
  constant axi_protocol : string := "AXI4";


  signal pB_UART_tx : std_logic;
  signal pB_UART_rx : std_logic;
  
  
begin  -- architecture structure

  --Clocking
  --Clocking
  Local_Clocking: entity work.onboardclk
    port map (
      clk_200MHz   => clk_200,
      clk_50Mhz    => clk_50,
      reset     => '0',
      locked    => locked_clk200,
      clk_in1_p => p_clk_100,
      clk_in1_n => n_clk_100);
  
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
      K_C2C_phy_refclk_clk_n            => n_util_clk_chan0,
      K_C2C_phy_refclk_clk_p            => p_util_clk_chan0,
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
      K_C2C_INTF_arready(0)                  => local_AXI_ReadMISO(2).ready_for_address,    
      K_C2C_INTF_arvalid(0)                  => local_AXI_ReadMOSI(2).address_valid,        
      K_C2C_INTF_awaddr                   => local_AXI_WriteMOSI(2).address,             
      K_C2C_INTF_awprot                   => local_AXI_WriteMOSI(2).protection_type,     
      K_C2C_INTF_awready(0)                  => local_AXI_WriteMISO(2).ready_for_address,   
      K_C2C_INTF_awvalid(0)                  => local_AXI_WriteMOSI(2).address_valid,       
      K_C2C_INTF_bready(0)                   => local_AXI_WriteMOSI(2).ready_for_response,  
      K_C2C_INTF_bresp                    => local_AXI_WriteMISO(2).response,            
      K_C2C_INTF_bvalid(0)                   => local_AXI_WriteMISO(2).response_valid,      
      K_C2C_INTF_rdata                    => local_AXI_ReadMISO(2).data,                 
      K_C2C_INTF_rready(0)                   => local_AXI_ReadMOSI(2).ready_for_data,       
      K_C2C_INTF_rresp                    => local_AXI_ReadMISO(2).response,             
      K_C2C_INTF_rvalid(0)                   => local_AXI_ReadMISO(2).data_valid,           
      K_C2C_INTF_wdata                    => local_AXI_WriteMOSI(2).data,                
      K_C2C_INTF_wready(0)                   => local_AXI_WriteMISO(2).ready_for_data,       
      K_C2C_INTF_wstrb                    => local_AXI_WriteMOSI(2).data_write_strobe,   
      K_C2C_INTF_wvalid(0)                   => local_AXI_WriteMOSI(2).data_valid

      
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
      Ctrl.BRAM.ADDR(9 downto 0)          => BRAM_ADDR,
      Ctrl.BRAM.ADDR(14 downto 10) => open,
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

  
end architecture structure;
