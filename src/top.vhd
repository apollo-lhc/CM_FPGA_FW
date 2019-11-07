library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.axiRegPkg.all;
use work.types.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity top is
  port (
    -- clocks
    p_clk_200 : in  std_logic;
    n_clk_200 : in  std_logic;                -- 200 MHz system clock

    -- ATCA timing and control
    --input p_atca_ttc_in, n_atca_ttc_in,        -- GTH input, combined clock and data
    --output p_atca_tts_out, n_atca_tts_out,     -- GTH output
    -- legacy AMC13 signals
--    p_amc13_clk_40 : in  std_logic;
--    n_amc13_clk_40 : in  std_logic;      -- extracted 40 MHz experimental clock
--    p_amc13_cdr_data : in std_logic;
--    n_amc13_cdr_data : in  std_logic;  -- extracted TTC data
--    p_amc13_tts_out : out std_logic;
--    n_amc13_tts_out : out std_logic;   -- encoded TTS 
--    -- 2 positions from 4 position DIP SWITCH
--    dip_sw          : in std_logic_vector(3 downto 2); -- dip_sw[2] = position 2 of 4, no defined use yet
                                                       -- dip_sw[3] = position 3 of 4, no defined use yet
                                                       -- position 1 = boot mode , 0=MASTER_SPI, 1 = JTAG ONLY
                                                       -- position 4 = bit to TM4C

    -- Zynq AXI Chip2Chip
    n_util_clk_chan0 : in std_logic;
    p_util_clk_chan0 : in std_logic;
    n_mgt_z2k        : in  std_logic_vector(1 downto 1);
    p_mgt_z2k        : in  std_logic_vector(1 downto 1);
    n_mgt_k2z        : out std_logic_vector(1 downto 1);
    p_mgt_k2z        : out std_logic_vector(1 downto 1);

    k_fpga_i2c_scl   : inout std_logic;
    k_fpga_i2c_sda   : inout std_logic;
    
    -- tri-color LED
    led_red : out std_logic;
    led_green : out std_logic;
    led_blue : out std_logic       -- assert to turn on
    -- utility bits to/from TM4C
---    from_tm4c : in  std_logic;                           -- no defined use yet
---    to_tm4c   : out std_logic;                            -- no defined use yet
---    -- spare pairs from the VU7P, defined as inputs until an output is needed
---    p_kv_spare : in  std_logic_vector(12 downto 0);
---    n_kv_spare : in  std_logic_vector(12 downto 0); -- no defined use yet
---    -- test connector on bottom side of board, defined as inputs until an output is needed
---    p_test_conn : in std_logic_vector(5 downto 0);
---    n_test_conn : in std_logic_vector(5 downto 0) -- no defined use yet	
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

  constant localAXISlaves    : integer := 2;
  signal local_AXI_ReadMOSI  :  AXIReadMOSI_array_t(0 to localAXISlaves-1) := (others => DefaultAXIReadMOSI);
  signal local_AXI_ReadMISO  :  AXIReadMISO_array_t(0 to localAXISlaves-1) := (others => DefaultAXIReadMISO);
  signal local_AXI_WriteMOSI : AXIWriteMOSI_array_t(0 to localAXISlaves-1) := (others => DefaultAXIWriteMOSI);
  signal local_AXI_WriteMISO : AXIWriteMISO_array_t(0 to localAXISlaves-1) := (others => DefaultAXIWriteMISO);
  signal AXI_CLK             : std_logic;
  signal AXI_RST_N           : std_logic;



  signal C2CLink_aurora_do_cc                : STD_LOGIC;
  signal C2CLink_axi_c2c_config_error_out    : STD_LOGIC;
  signal C2CLink_axi_c2c_link_status_out     : STD_LOGIC;
  signal C2CLink_axi_c2c_multi_bit_error_out : STD_LOGIC;
  signal C2CLink_phy_gt_pll_lock             : STD_LOGIC;
  signal C2CLink_phy_hard_err                : STD_LOGIC;
  signal C2CLink_phy_lane_up                 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal C2CLink_phy_link_reset_out          : STD_LOGIC;
  signal C2CLink_phy_mmcm_not_locked_out     : STD_LOGIC;
--  signal C2CLink_phy_power_down              : in  STD_LOGIC;
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
      AXI_CLK                  => AXI_CLK,
      AXI_RST_N(0)             => AXI_RST_N,
      C2CLink_phy_Rx_rxn       => n_mgt_z2k,
      C2CLink_phy_Rx_rxp       => p_mgt_z2k,
      C2CLink_phy_Tx_txn       => n_mgt_k2z,
      C2CLink_phy_Tx_txp       => p_mgt_k2z,
      C2CLink_phy_refclk_clk_n => n_util_clk_chan0,
      C2CLink_phy_refclk_clk_p => p_util_clk_chan0,
      clk50Mhz                 => clk_50,
      CM_K_INFO_araddr         => local_AXI_ReadMOSI(0).address,              
      CM_K_INFO_arprot         => local_AXI_ReadMOSI(0).protection_type,      
      CM_K_INFO_arready(0)     => local_AXI_ReadMISO(0).ready_for_address,    
      CM_K_INFO_arvalid(0)     => local_AXI_ReadMOSI(0).address_valid,        
      CM_K_INFO_awaddr         => local_AXI_WriteMOSI(0).address,             
      CM_K_INFO_awprot         => local_AXI_WriteMOSI(0).protection_type,     
      CM_K_INFO_awready(0)     => local_AXI_WriteMISO(0).ready_for_address,   
      CM_K_INFO_awvalid(0)     => local_AXI_WriteMOSI(0).address_valid,       
      CM_K_INFO_bready(0)      => local_AXI_WriteMOSI(0).ready_for_response,  
      CM_K_INFO_bresp          => local_AXI_WriteMISO(0).response,            
      CM_K_INFO_bvalid(0)      => local_AXI_WriteMISO(0).response_valid,      
      CM_K_INFO_rdata          => local_AXI_ReadMISO(0).data,                 
      CM_K_INFO_rready(0)      => local_AXI_ReadMOSI(0).ready_for_data,       
      CM_K_INFO_rresp          => local_AXI_ReadMISO(0).response,             
      CM_K_INFO_rvalid(0)      => local_AXI_ReadMISO(0).data_valid,           
      CM_K_INFO_wdata          => local_AXI_WriteMOSI(0).data,                
      CM_K_INFO_wready(0)      => local_AXI_WriteMISO(0).ready_for_data,       
      CM_K_INFO_wstrb          => local_AXI_WriteMOSI(0).data_write_strobe,   
      CM_K_INFO_wvalid(0)      => local_AXI_WriteMOSI(0).data_valid,          
      KINTEX_IPBUS_awaddr      => local_AXI_WriteMOSI(1).address,             
      KINTEX_IPBUS_awprot      => local_AXI_WriteMOSI(1).protection_type,     
      KINTEX_IPBUS_awvalid(0)  => local_AXI_WriteMOSI(1).address_valid,       
      KINTEX_IPBUS_awready(0)  => local_AXI_WriteMISO(1).ready_for_address,   
      KINTEX_IPBUS_wdata       => local_AXI_WriteMOSI(1).data,                
      KINTEX_IPBUS_wstrb       => local_AXI_WriteMOSI(1).data_write_strobe,   
      KINTEX_IPBUS_wvalid(0)   => local_AXI_WriteMOSI(1).data_valid,          
      KINTEX_IPBUS_wready(0)   => local_AXI_WriteMISO(1).ready_for_data,      
      KINTEX_IPBUS_bresp       => local_AXI_WriteMISO(1).response,            
      KINTEX_IPBUS_bvalid(0)   => local_AXI_WriteMISO(1).response_valid,      
      KINTEX_IPBUS_bready(0)   => local_AXI_WriteMOSI(1).ready_for_response,  
      KINTEX_IPBUS_araddr      => local_AXI_ReadMOSI(1).address,              
      KINTEX_IPBUS_arprot      => local_AXI_ReadMOSI(1).protection_type,      
      KINTEX_IPBUS_arvalid(0)  => local_AXI_ReadMOSI(1).address_valid,        
      KINTEX_IPBUS_arready(0)  => local_AXI_ReadMISO(1).ready_for_address,    
      KINTEX_IPBUS_rdata       => local_AXI_ReadMISO(1).data,                 
      KINTEX_IPBUS_rresp       => local_AXI_ReadMISO(1).response,             
      KINTEX_IPBUS_rvalid(0)   => local_AXI_ReadMISO(1).data_valid,           
      KINTEX_IPBUS_rready(0)   => local_AXI_ReadMOSI(1).ready_for_data,       
      reset_n                  => locked_clk200,--reset,
      C2CLink_aurora_do_cc                => C2CLink_aurora_do_cc, 
      C2CLink_axi_c2c_config_error_out    => C2CLink_axi_c2c_config_error_out, 
      C2CLink_axi_c2c_link_status_out     => C2CLink_axi_c2c_link_status_out, 
      C2CLink_axi_c2c_multi_bit_error_out => C2CLink_axi_c2c_multi_bit_error_out, 
      C2CLink_phy_gt_pll_lock             => C2CLink_phy_gt_pll_lock, 
      C2CLink_phy_hard_err                => C2CLink_phy_hard_err, 
      C2CLink_phy_lane_up                 => C2CLink_phy_lane_up(0), 
      C2CLink_phy_link_reset_out          => C2CLink_phy_link_reset_out, 
      C2CLink_phy_mmcm_not_locked_out     => C2CLink_phy_mmcm_not_locked_out, 
      C2CLink_phy_power_down              => '0', 
      C2CLink_phy_soft_err                => C2CLink_phy_soft_err,
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

  K_IO: entity work.BoardIO
    generic map (
      REG_COUNT_PWR_OF_2 => 2,
      REG_OUT_DEFAULTS   => (x"00000000", x"00000000", x"00000000", x"00000000"))
    port map (
      clk_axi     => AXI_CLK,
      reset_axi_n => AXI_RST_N,
      readMOSI    => local_AXI_ReadMOSI(0),
      readMISO    => local_AXI_ReadMISO(0),
      writeMOSI   => local_AXI_WriteMOSI(0),
      writeMISO   => local_AXI_WriteMISO(0),
      reg_out(0)( 7 downto  0)  => led_red_local,
      reg_out(0)(15 downto  8)  => led_green_local,
      reg_out(0)(23 downto 16)  => led_blue_local,
      reg_out(0)(31 downto 24) => open,
      reg_out(3 downto 1) => open,
      reg_in(0)   => x"00000" & "00" &
                      C2CLink_aurora_do_cc &               
                      C2CLink_axi_c2c_config_error_out &   
                      C2CLink_axi_c2c_link_status_out &    
                      C2CLink_axi_c2c_multi_bit_error_out &
                      C2CLink_phy_gt_pll_lock &            
                      C2CLink_phy_hard_err &               
                      C2CLink_phy_lane_up(0) &                
                      C2CLink_phy_link_reset_out &         
                      C2CLink_phy_mmcm_not_locked_out &    
                      C2CLink_phy_soft_err,
      reg_in(3 downto 1) => (others => x"00000000"));

  CM_K_info_1: entity work.CM_K_info
    port map (
      clk_axi     => AXI_CLK,
      reset_axi_n => AXI_RST_N,
      readMOSI    => local_AXI_ReadMOSI(2),
      readMISO    => local_AXI_ReadMISO(2),
      writeMOSI   => local_AXI_WriteMOSI(2),
      writeMISO   => local_AXI_WriteMISO(2));
>>>>>>> First step in breaking FW up into top and submodule forms
  
end architecture structure;
