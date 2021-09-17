library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.axiRegPkg.all;
use work.axiRegPkg_d64.all;
use work.types.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity sub_module is
  port (
    -- clocks
    clk_200       : in  std_logic;     -- 200 MHz system clock
    locked_clk200 : in  std_logic;
    clk_50        : in  std_logic;
    
    
    -- Zynq AXI Chip2Chip
    n_util_clk_chan0 : in std_logic;
    p_util_clk_chan0 : in std_logic;
    n_mgt_z2FPGA     : in  std_logic_vector(1 downto 1);
    p_mgt_z2FPGA     : in  std_logic_vector(1 downto 1);
    n_mgt_FPGA2z     : out std_logic_vector(1 downto 1);
    p_mgt_FPGA2z     : out std_logic_vector(1 downto 1);

    fpga_i2c_scl   : inout std_logic;
    fpga_i2c_sda   : inout std_logic;

    clk_axi           : out std_logic;
    rst_n_axi         : out std_logic;
    ext_AXI_ReadMOSI  : out AXIReadMOSI_d64  := DefaultAXIReadMOSI_d64;
    ext_AXI_ReadMISO  : in  AXIReadMISO_d64  := DefaultAXIReadMISO_d64;
    ext_AXI_WriteMOSI : out AXIWriteMOSI_d64 := DefaultAXIWriteMOSI_d64;
    ext_AXI_WriteMISO : in  AXIWriteMISO_d64 := DefaultAXIWriteMISO_d64;
    
    -- tri-color LED
    led_red : out std_logic;
    led_green : out std_logic;
    led_blue : out std_logic       -- assert to turn on
    );    
end entity sub_module;

architecture structure of sub_module is
  
  signal reset           : std_logic;

  signal led_blue_local  : slv_8_t;
  signal led_red_local   : slv_8_t;
  signal led_green_local : slv_8_t;

  constant localAXISlaves    : integer := 2;
  signal local_AXI_ReadMOSI  :  AXIReadMOSI_array_t(0 to localAXISlaves-1) := ( others => DefaultAXIReadMOSI);
  signal local_AXI_ReadMISO  :  AXIReadMISO_array_t(0 to localAXISlaves-1) := ( others => DefaultAXIReadMISO);
  signal local_AXI_WriteMOSI : AXIWriteMOSI_array_t(0 to localAXISlaves-1) := ( others => DefaultAXIWriteMOSI);
  signal local_AXI_WriteMISO : AXIWriteMISO_array_t(0 to localAXISlaves-1) := ( others => DefaultAXIWriteMISO);
  signal AXI_CLK             : std_logic;
  signal AXI_RST_N           : std_logic;
  signal AXI_RESET           : std_logic;

  

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


  constant std_logic1 : std_logic := '1';
  constant std_logic0 : std_logic := '0';

  
begin  -- architecture structure


                   
  AXI_CLK <= clk_50;  -- for now we just use the 50 MHz from emp for axi

  --export the axi clock and reset to emp
  clk_axi <= AXI_CLK;
  rst_n_axi <= AXI_RST_N;
  
  c2csslave_wrapper_1: entity work.c2cslave_wrapper
    port map (
      AXI_CLK                             => AXI_CLK,
      AXI_RST_N(0)                        => AXI_RST_N,
      V_C2C_phy_Rx_rxn                    => n_mgt_z2FPGA,
      V_C2C_phy_Rx_rxp                    => p_mgt_z2FPGA,
      V_C2C_phy_Tx_txn                    => n_mgt_FPGA2z,
      V_C2C_phy_Tx_txp                    => p_mgt_FPGA2z,
      V_C2C_phy_refclk_clk_n              => n_util_clk_chan0,
      V_C2C_phy_refclk_clk_p              => p_util_clk_chan0,
      clk50Mhz                            => clk_50,
      V_IO_araddr                         => local_AXI_ReadMOSI(0).address,              
      V_IO_arprot                         => local_AXI_ReadMOSI(0).protection_type,      
      V_IO_arready(0)                     => local_AXI_ReadMISO(0).ready_for_address,    
      V_IO_arvalid(0)                     => local_AXI_ReadMOSI(0).address_valid,        
      V_IO_awaddr                         => local_AXI_WriteMOSI(0).address,             
      V_IO_awprot                         => local_AXI_WriteMOSI(0).protection_type,     
      V_IO_awready(0)                     => local_AXI_WriteMISO(0).ready_for_address,   
      V_IO_awvalid(0)                     => local_AXI_WriteMOSI(0).address_valid,       
      V_IO_bready(0)                      => local_AXI_WriteMOSI(0).ready_for_response,  
      V_IO_bresp                          => local_AXI_WriteMISO(0).response,            
      V_IO_bvalid(0)                      => local_AXI_WriteMISO(0).response_valid,      
      V_IO_rdata                          => local_AXI_ReadMISO(0).data,                 
      V_IO_rready(0)                      => local_AXI_ReadMOSI(0).ready_for_data,       
      V_IO_rresp                          => local_AXI_ReadMISO(0).response,             
      V_IO_rvalid(0)                      => local_AXI_ReadMISO(0).data_valid,           
      V_IO_wdata                          => local_AXI_WriteMOSI(0).data,                
      V_IO_wready(0)                      => local_AXI_WriteMISO(0).ready_for_data,       
      V_IO_wstrb                          => local_AXI_WriteMOSI(0).data_write_strobe,   
      V_IO_wvalid(0)                      => local_AXI_WriteMOSI(0).data_valid,          
      CM_V_INFO_araddr                    => local_AXI_ReadMOSI(1).address,              
      CM_V_INFO_arprot                    => local_AXI_ReadMOSI(1).protection_type,      
      CM_V_INFO_arready(0)                => local_AXI_ReadMISO(1).ready_for_address,    
      CM_V_INFO_arvalid(0)                => local_AXI_ReadMOSI(1).address_valid,        
      CM_V_INFO_awaddr                    => local_AXI_WriteMOSI(1).address,             
      CM_V_INFO_awprot                    => local_AXI_WriteMOSI(1).protection_type,     
      CM_V_INFO_awready(0)                => local_AXI_WriteMISO(1).ready_for_address,   
      CM_V_INFO_awvalid(0)                => local_AXI_WriteMOSI(1).address_valid,       
      CM_V_INFO_bready(0)                 => local_AXI_WriteMOSI(1).ready_for_response,  
      CM_V_INFO_bresp                     => local_AXI_WriteMISO(1).response,            
      CM_V_INFO_bvalid(0)                 => local_AXI_WriteMISO(1).response_valid,      
      CM_V_INFO_rdata                     => local_AXI_ReadMISO(1).data,                 
      CM_V_INFO_rready(0)                 => local_AXI_ReadMOSI(1).ready_for_data,       
      CM_V_INFO_rresp                     => local_AXI_ReadMISO(1).response,             
      CM_V_INFO_rvalid(0)                 => local_AXI_ReadMISO(1).data_valid,           
      CM_V_INFO_wdata                     => local_AXI_WriteMOSI(1).data,                
      CM_V_INFO_wready(0)                 => local_AXI_WriteMISO(1).ready_for_data,       
      CM_V_INFO_wstrb                     => local_AXI_WriteMOSI(1).data_write_strobe,   
      CM_V_INFO_wvalid(0)                 => local_AXI_WriteMOSI(1).data_valid,          

      VIRTEX_IPBUS_araddr                 => ext_AXI_ReadMOSI.address,              
      VIRTEX_IPBUS_arburst                => ext_AXI_ReadMOSI.burst_type,
      VIRTEX_IPBUS_arcache                => ext_AXI_ReadMOSI.cache_type,
      VIRTEX_IPBUS_arlen                  => ext_AXI_ReadMOSI.burst_length,
      VIRTEX_IPBUS_arlock(0)              => ext_AXI_ReadMOSI.lock_type,
      VIRTEX_IPBUS_arprot                 => ext_AXI_ReadMOSI.protection_type,      
      VIRTEX_IPBUS_arqos                  => ext_AXI_ReadMOSI.qos,
      VIRTEX_IPBUS_arready(0)             => ext_AXI_ReadMISO.ready_for_address,
      VIRTEX_IPBUS_arregion               => ext_AXI_ReadMOSI.region,
      VIRTEX_IPBUS_arsize                 => ext_AXI_ReadMOSI.burst_size,
      VIRTEX_IPBUS_arvalid(0)             => ext_AXI_ReadMOSI.address_valid,        
      VIRTEX_IPBUS_awaddr                 => ext_AXI_WriteMOSI.address,             
      VIRTEX_IPBUS_awburst                => ext_AXI_WriteMOSI.burst_type,
      VIRTEX_IPBUS_awcache                => ext_AXI_WriteMOSI.cache_type,
      VIRTEX_IPBUS_awlen                  => ext_AXI_WriteMOSI.burst_length,
      VIRTEX_IPBUS_awlock(0)              => ext_AXI_WriteMOSI.lock_type,
      VIRTEX_IPBUS_awprot                 => ext_AXI_WriteMOSI.protection_type,
      VIRTEX_IPBUS_awqos                  => ext_AXI_WriteMOSI.qos,
      VIRTEX_IPBUS_awready(0)             => ext_AXI_WriteMISO.ready_for_address,   
      VIRTEX_IPBUS_awregion               => ext_AXI_WriteMOSI.region,
      VIRTEX_IPBUS_awsize                 => ext_AXI_WriteMOSI.burst_size,
      VIRTEX_IPBUS_awvalid(0)             => ext_AXI_WriteMOSI.address_valid,       
      VIRTEX_IPBUS_bready(0)              => ext_AXI_WriteMOSI.ready_for_response,  
      VIRTEX_IPBUS_bresp                  => ext_AXI_WriteMISO.response,            
      VIRTEX_IPBUS_bvalid(0)              => ext_AXI_WriteMISO.response_valid,      
      VIRTEX_IPBUS_rdata                  => ext_AXI_ReadMISO.data,
      VIRTEX_IPBUS_rlast(0)               => ext_AXI_ReadMISO.last,
      VIRTEX_IPBUS_rready(0)              => ext_AXI_ReadMOSI.ready_for_data,       
      VIRTEX_IPBUS_rresp                  => ext_AXI_ReadMISO.response,             
      VIRTEX_IPBUS_rvalid(0)              => ext_AXI_ReadMISO.data_valid,           
      VIRTEX_IPBUS_wdata                  => ext_AXI_WriteMOSI.data,
      VIRTEX_IPBUS_wlast(0)               => ext_AXI_WriteMOSI.last,
      VIRTEX_IPBUS_wready(0)              => ext_AXI_WriteMISO.ready_for_data,       
      VIRTEX_IPBUS_wstrb                  => ext_AXI_WriteMOSI.data_write_strobe,   
      VIRTEX_IPBUS_wvalid(0)              => ext_AXI_WriteMOSI.data_valid,
      
      reset_n                             => locked_clk200,--reset,
      V_C2C_aurora_do_cc                  => C2CLink_aurora_do_cc,               
      V_C2C_axi_c2c_config_error_out      => C2CLink_axi_c2c_config_error_out,   
      V_C2C_axi_c2c_link_status_out       => C2CLink_axi_c2c_link_status_out,    
      V_C2C_axi_c2c_multi_bit_error_out   => C2CLink_axi_c2c_multi_bit_error_out,
      V_C2C_phy_gt_pll_lock               => C2CLink_phy_gt_pll_lock,            
      V_C2C_phy_hard_err                  => C2CLink_phy_hard_err,               
      V_C2C_phy_lane_up                   => C2CLink_phy_lane_up,                
      V_C2C_phy_link_reset_out            => C2CLink_phy_link_reset_out,         
      V_C2C_phy_mmcm_not_locked_out       => C2CLink_phy_mmcm_not_locked_out,    
      V_C2C_phy_power_down                => std_logic0,
      V_C2C_phy_soft_err                  => C2CLink_phy_soft_err
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

  V_IO_interface_1: entity work.V_IO_interface
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
      Mon.BRAM.RD_DATA        => (others => '0'),
      Ctrl.RGB.R              => led_red_local,
      Ctrl.RGB.G              => led_green_local,
      Ctrl.RGB.B              => led_blue_local,
      Ctrl.BRAM               => open
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

  
end architecture structure;
