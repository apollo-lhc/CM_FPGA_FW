library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.axiRegPkg.all;
use work.types.all;
use work.K_IO_Ctrl.all;


Library UNISIM;
use UNISIM.vcomponents.all;

entity top is
  port (
    -- clocks
    p_clk_200 : in  std_logic;
    n_clk_200 : in  std_logic;                -- 200 MHz system clock


    -- Zynq AXI Chip2Chip
    n_util_clk_chan0 : in std_logic;
    p_util_clk_chan0 : in std_logic;
    n_mgt_z2k        : in  std_logic_vector(1 downto 1);
    p_mgt_z2k        : in  std_logic_vector(1 downto 1);
    n_mgt_k2z        : out std_logic_vector(1 downto 1);
    p_mgt_k2z        : out std_logic_vector(1 downto 1);

    k_fpga_i2c_scl   : inout std_logic;
    k_fpga_i2c_sda   : inout std_logic;

    --TCDS
    p_clk0_chan0     : in std_logic; -- 200 MHz system clock
    n_clk0_chan0     : in std_logic; 
    p_clk1_chan0     : in std_logic; -- 312.195122 MHz synth clock
    n_clk1_chan0     : in std_logic;
    p_atca_tts_out   : out std_logic;
    n_atca_tts_out   : out std_logic;
    p_atca_ttc_in    : in  std_logic;
    n_atca_ttc_in    : in  std_logic;

    
    -- tri-color LED
    led_red : out std_logic;
    led_green : out std_logic;
    led_blue : out std_logic       -- assert to turn on
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

  constant localAXISlaves    : integer := 4;
  signal local_AXI_ReadMOSI  :  AXIReadMOSI_array_t(0 to localAXISlaves-1) := ( others => DefaultAXIReadMOSI);
  signal local_AXI_ReadMISO  :  AXIReadMISO_array_t(0 to localAXISlaves-1) := ( others => DefaultAXIReadMISO);
  signal local_AXI_WriteMOSI : AXIWriteMOSI_array_t(0 to localAXISlaves-1) := ( others => DefaultAXIWriteMOSI);
  signal local_AXI_WriteMISO : AXIWriteMISO_array_t(0 to localAXISlaves-1) := ( others => DefaultAXIWriteMISO);
  signal AXI_CLK             : std_logic;
  signal AXI_RST_N           : std_logic;


  signal ext_AXI_ReadMOSI  :  AXIReadMOSI := DefaultAXIReadMOSI;
  signal ext_AXI_ReadMISO  :  AXIReadMISO := DefaultAXIReadMISO;
  signal ext_AXI_WriteMOSI : AXIWriteMOSI := DefaultAXIWriteMOSI;
  signal ext_AXI_WriteMISO : AXIWriteMISO := DefaultAXIWriteMISO;

  

  signal C2CLink_aurora_do_cc                : STD_LOGIC;
  signal C2CLink_axi_c2c_config_error_out    : STD_LOGIC;
  signal C2CLink_axi_c2c_link_status_out     : STD_LOGIC;
  signal C2CLink_axi_c2c_multi_bit_error_out : STD_LOGIC;
  signal C2CLink_phy_gt_pll_lock             : STD_LOGIC;
  signal C2CLink_phy_hard_err                : STD_LOGIC;
  signal C2CLink_phy_lane_up                 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal C2CLink_phy_link_reset_out          : STD_LOGIC;
  signal C2CLink_phy_mmcm_not_locked_out     : STD_LOGIC;
  signal C2CLink_phy_soft_err                : STD_LOGIC;


  
begin  -- architecture structure

  --Clocking
  reset <= not locked_clk200;
  Local_Clocking_1: entity work.Local_Clocking
    port map (
      clk_200   => clk_200,
      clk_50    => clk_50,
      clk_axi   => AXI_CLK,
      reset     => '0',
      locked    => locked_clk200,
      clk_in1_p => p_clk_200,
      clk_in1_n => n_clk_200);
  
  

  

  c2csslave_wrapper_1: entity work.c2cslave_wrapper
    port map (
      AXI_CLK                             => AXI_CLK,
      AXI_RST_N(0)                        => AXI_RST_N,
      K_C2CLink_phy_Rx_rxn                  => n_mgt_z2k,
      K_C2CLink_phy_Rx_rxp                  => p_mgt_z2k,
      K_C2CLink_phy_Tx_txn                  => n_mgt_k2z,
      K_C2CLink_phy_Tx_txp                  => p_mgt_k2z,
      K_C2CLink_phy_refclk_clk_n            => n_util_clk_chan0,
      K_C2CLink_phy_refclk_clk_p            => p_util_clk_chan0,
      clk50Mhz                            => clk_50,
      K_IO_araddr                         => local_AXI_ReadMOSI(0).address,              
      K_IO_arprot                         => local_AXI_ReadMOSI(0).protection_type,      
      K_IO_arready(0)                     => local_AXI_ReadMISO(0).ready_for_address,    
      K_IO_arvalid(0)                        => local_AXI_ReadMOSI(0).address_valid,        
      K_IO_awaddr                         => local_AXI_WriteMOSI(0).address,             
      K_IO_awprot                         => local_AXI_WriteMOSI(0).protection_type,     
      K_IO_awready(0)                     => local_AXI_WriteMISO(0).ready_for_address,   
      K_IO_awvalid(0)                     => local_AXI_WriteMOSI(0).address_valid,       
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
      CM_K_INFO_araddr                    => local_AXI_ReadMOSI(1).address,              
      CM_K_INFO_arprot                    => local_AXI_ReadMOSI(1).protection_type,      
      CM_K_INFO_arready(0)                => local_AXI_ReadMISO(1).ready_for_address,    
      CM_K_INFO_arvalid(0)                => local_AXI_ReadMOSI(1).address_valid,        
      CM_K_INFO_awaddr                    => local_AXI_WriteMOSI(1).address,             
      CM_K_INFO_awprot                    => local_AXI_WriteMOSI(1).protection_type,     
      CM_K_INFO_awready(0)                => local_AXI_WriteMISO(1).ready_for_address,   
      CM_K_INFO_awvalid(0)                => local_AXI_WriteMOSI(1).address_valid,       
      CM_K_INFO_bready(0)                 => local_AXI_WriteMOSI(1).ready_for_response,  
      CM_K_INFO_bresp                     => local_AXI_WriteMISO(1).response,            
      CM_K_INFO_bvalid(0)                 => local_AXI_WriteMISO(1).response_valid,      
      CM_K_INFO_rdata                     => local_AXI_ReadMISO(1).data,                 
      CM_K_INFO_rready(0)                 => local_AXI_ReadMOSI(1).ready_for_data,       
      CM_K_INFO_rresp                     => local_AXI_ReadMISO(1).response,             
      CM_K_INFO_rvalid(0)                 => local_AXI_ReadMISO(1).data_valid,           
      CM_K_INFO_wdata                     => local_AXI_WriteMOSI(1).data,                
      CM_K_INFO_wready(0)                 => local_AXI_WriteMISO(1).ready_for_data,       
      CM_K_INFO_wstrb                     => local_AXI_WriteMOSI(1).data_write_strobe,   
      CM_K_INFO_wvalid(0)                 => local_AXI_WriteMOSI(1).data_valid,          
      KINTEX_TCDS_DRP_araddr                     => local_AXI_ReadMOSI(2).address,
      KINTEX_TCDS_DRP_arprot                     => local_AXI_ReadMOSI(2).protection_type,
      KINTEX_TCDS_DRP_arready(0)                 => local_AXI_ReadMISO(2).ready_for_address,
      KINTEX_TCDS_DRP_arvalid(0)                 => local_AXI_ReadMOSI(2).address_valid,
      KINTEX_TCDS_DRP_awaddr                     => local_AXI_WriteMOSI(2).address,
      KINTEX_TCDS_DRP_awprot                     => local_AXI_WriteMOSI(2).protection_type,
      KINTEX_TCDS_DRP_awready(0)                 => local_AXI_WriteMISO(2).ready_for_address,
      KINTEX_TCDS_DRP_awvalid(0)                 => local_AXI_WriteMOSI(2).address_valid,
      KINTEX_TCDS_DRP_bready(0)                  => local_AXI_WriteMOSI(2).ready_for_response,
      KINTEX_TCDS_DRP_bresp                      => local_AXI_WriteMISO(2).response,
      KINTEX_TCDS_DRP_bvalid(0)                  => local_AXI_WriteMISO(2).response_valid,
      KINTEX_TCDS_DRP_rdata                      => local_AXI_ReadMISO(2).data,
      KINTEX_TCDS_DRP_rready(0)                  => local_AXI_ReadMOSI(2).ready_for_data,
      KINTEX_TCDS_DRP_rresp                      => local_AXI_ReadMISO(2).response,
      KINTEX_TCDS_DRP_rvalid(0)                  => local_AXI_ReadMISO(2).data_valid,
      KINTEX_TCDS_DRP_wdata                      => local_AXI_WriteMOSI(2).data,
      KINTEX_TCDS_DRP_wready(0)                  => local_AXI_WriteMISO(2).ready_for_data,
      KINTEX_TCDS_DRP_wstrb                      => local_AXI_WriteMOSI(2).data_write_strobe,
      KINTEX_TCDS_DRP_wvalid(0)                  => local_AXI_WriteMOSI(2).data_valid,
                                          
      KINTEX_TCDS_araddr                         => local_AXI_ReadMOSI(3).address,
      KINTEX_TCDS_arprot                         => local_AXI_ReadMOSI(3).protection_type,
      KINTEX_TCDS_arready(0)                     => local_AXI_ReadMISO(3).ready_for_address,
      KINTEX_TCDS_arvalid(0)                     => local_AXI_ReadMOSI(3).address_valid,
      KINTEX_TCDS_awaddr                         => local_AXI_WriteMOSI(3).address,
      KINTEX_TCDS_awprot                         => local_AXI_WriteMOSI(3).protection_type,
      KINTEX_TCDS_awready(0)                     => local_AXI_WriteMISO(3).ready_for_address,
      KINTEX_TCDS_awvalid(0)                     => local_AXI_WriteMOSI(3).address_valid,
      KINTEX_TCDS_bready(0)                      => local_AXI_WriteMOSI(3).ready_for_response,
      KINTEX_TCDS_bresp                          => local_AXI_WriteMISO(3).response,
      KINTEX_TCDS_bvalid(0)                      => local_AXI_WriteMISO(3).response_valid,
      KINTEX_TCDS_rdata                          => local_AXI_ReadMISO(3).data,
      KINTEX_TCDS_rready(0)                      => local_AXI_ReadMOSI(3).ready_for_data,
      KINTEX_TCDS_rresp                          => local_AXI_ReadMISO(3).response,
      KINTEX_TCDS_rvalid(0)                      => local_AXI_ReadMISO(3).data_valid,
      KINTEX_TCDS_wdata                          => local_AXI_WriteMOSI(3).data,
      KINTEX_TCDS_wready(0)                      => local_AXI_WriteMISO(3).ready_for_data,
      KINTEX_TCDS_wstrb                          => local_AXI_WriteMOSI(3).data_write_strobe,
      KINTEX_TCDS_wvalid(0)                      => local_AXI_WriteMOSI(3).data_valid,



      IPBUS_KINTEX_araddr                 => ext_AXI_ReadMOSI.address,              
      IPBUS_KINTEX_arprot                 => ext_AXI_ReadMOSI.protection_type,      
      IPBUS_KINTEX_arready(0)             => ext_AXI_ReadMISO.ready_for_address,    
      IPBUS_KINTEX_arvalid(0)             => ext_AXI_ReadMOSI.address_valid,        
      IPBUS_KINTEX_awaddr                 => ext_AXI_WriteMOSI.address,             
      IPBUS_KINTEX_awprot                 => ext_AXI_WriteMOSI.protection_type,     
      IPBUS_KINTEX_awready(0)             => ext_AXI_WriteMISO.ready_for_address,   
      IPBUS_KINTEX_awvalid(0)             => ext_AXI_WriteMOSI.address_valid,       
      IPBUS_KINTEX_bready(0)              => ext_AXI_WriteMOSI.ready_for_response,  
      IPBUS_KINTEX_bresp                  => ext_AXI_WriteMISO.response,            
      IPBUS_KINTEX_bvalid(0)              => ext_AXI_WriteMISO.response_valid,      
      IPBUS_KINTEX_rdata                  => ext_AXI_ReadMISO.data,                 
      IPBUS_KINTEX_rready(0)              => ext_AXI_ReadMOSI.ready_for_data,       
      IPBUS_KINTEX_rresp                  => ext_AXI_ReadMISO.response,             
      IPBUS_KINTEX_rvalid(0)              => ext_AXI_ReadMISO.data_valid,           
      IPBUS_KINTEX_wdata                  => ext_AXI_WriteMOSI.data,                
      IPBUS_KINTEX_wready(0)              => ext_AXI_WriteMISO.ready_for_data,       
      IPBUS_KINTEX_wstrb                  => ext_AXI_WriteMOSI.data_write_strobe,   
      IPBUS_KINTEX_wvalid(0)              => ext_AXI_WriteMOSI.data_valid,          
      reset_n                             => locked_clk200,--reset,
      K_C2CLink_aurora_do_cc                => C2CLink_aurora_do_cc,               
      K_C2CLink_axi_c2c_config_error_out    => C2CLink_axi_c2c_config_error_out,   
      K_C2CLink_axi_c2c_link_status_out     => C2CLink_axi_c2c_link_status_out,    
      K_C2CLink_axi_c2c_multi_bit_error_out => C2CLink_axi_c2c_multi_bit_error_out,
      K_C2CLink_phy_gt_pll_lock             => C2CLink_phy_gt_pll_lock,            
      K_C2CLink_phy_hard_err                => C2CLink_phy_hard_err,               
      K_C2CLink_phy_lane_up                 => C2CLink_phy_lane_up,                
      K_C2CLink_phy_link_reset_out          => C2CLink_phy_link_reset_out,         
      K_C2CLink_phy_mmcm_not_locked_out     => C2CLink_phy_mmcm_not_locked_out,    
      K_C2CLink_phy_power_down              => '0',
      K_C2CLink_phy_soft_err                => C2CLink_phy_soft_err,               
      KINTEX_SYS_MGMT_sda                 =>k_fpga_i2c_sda,
      KINTEX_SYS_MGMT_scl                 =>k_fpga_i2c_scl
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

  K_IO_interface_1: entity work.K_IO_interface
    port map (
      clk_axi         => AXI_CLK,
      reset_axi_n     => AXI_RST_N,
      slave_readMOSI  => local_AXI_readMOSI(0),
      slave_readMISO  => local_AXI_readMISO(0),
      slave_writeMOSI => local_AXI_writeMOSI(0),
      slave_writeMISO => local_AXI_writeMISO(0),
      Mon.C2C.CONFIG_ERR      => C2CLink_axi_c2c_config_error_out,
      Mon.C2C.DO_CC           => C2CLink_aurora_do_cc,
      Mon.C2C.GT_PLL_LOCK     => C2CLink_phy_gt_pll_lock,
      Mon.C2C.HARD_ERR        => C2CLink_phy_hard_err,
      Mon.C2C.LANE_UP         => C2CLink_phy_lane_up(0),
      Mon.C2C.LINK_RESET      => C2CLink_phy_link_reset_out,
      Mon.C2C.LINK_STATUS     => C2CLink_axi_c2c_link_status_out,
      Mon.C2C.MMCM_NOT_LOCKED => C2CLink_phy_mmcm_not_locked_out,
      Mon.C2C.MULTIBIT_ERR    => C2CLink_axi_c2c_multi_bit_error_out,
      Mon.C2C.SOFT_ERR        => C2CLink_phy_soft_err,
      Mon.CLK_200_LOCKED      => locked_clk200,
      Ctrl.RGB.R              => led_red_local,
      Ctrl.RGB.G              => led_green_local,
      Ctrl.RGB.B              => led_blue_local
      );

  CM_K_info_1: entity work.CM_K_info
    port map (
      clk_axi     => AXI_CLK,
      reset_axi_n => AXI_RST_N,
      readMOSI    => local_AXI_ReadMOSI(1),
      readMISO    => local_AXI_ReadMISO(1),
      writeMOSI   => local_AXI_WriteMOSI(1),
      writeMISO   => local_AXI_WriteMISO(1));

  TCDS_1: entity work.TCDS
    port map (
      clk_axi              => AXI_CLK,
      clk_200              => clk_200,
      reset_axi_n          => AXI_RST_N,
      readMOSI             => local_AXI_readMOSI(3),
      readMISO             => local_AXI_readMISO(3),
      writeMOSI            => local_AXI_writeMOSI(3),
      writeMISO            => local_AXI_writeMISO(3),
      DRP_readMOSI         => local_AXI_readMOSI(2),
      DRP_readMISO         => local_AXI_readMISO(2),
      DRP_writeMOSI        => local_AXI_writeMOSI(2),
      DRP_writeMISO        => local_AXI_writeMISO(2),
      refclk0_p => p_clk0_chan0,
      refclk0_n => n_clk0_chan0,
      refclk1_p => p_clk1_chan0,
      refclk1_n => n_clk1_chan0,  
      tx_p     => p_atca_tts_out  ,
      tx_n     => n_atca_tts_out  ,
      rx_p     => p_atca_ttc_in   ,
      rx_n     => n_atca_ttc_in   ,
      TxRx_clk_sel => '0'       );
  
end architecture structure;
