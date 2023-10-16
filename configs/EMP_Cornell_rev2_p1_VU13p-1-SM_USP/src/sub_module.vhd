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

entity sub_module is
  port (
    -- clocks
    clk_200       : in  std_logic;     -- 200 MHz system clock
    locked_clk200 : in  std_logic;
    clk_50        : in  std_logic;
    
    
    -- Zynq AXI Chip2Chip
    -- kh aug'22 drop _chan0 from refclk name, expand c2c links
    n_util_clk       : in std_logic;
    p_util_clk       : in std_logic;
    n_mgt_z2FPGA     : in  std_logic_vector(2 downto 1);
    p_mgt_z2FPGA     : in  std_logic_vector(2 downto 1);
    n_mgt_FPGA2z     : out std_logic_vector(2 downto 1);
    p_mgt_FPGA2z     : out std_logic_vector(2 downto 1);

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
    led_blue : out std_logic;       -- assert to turn on

    --kh aug'22
     c2c_ok : out std_logic
    );    
end entity sub_module;

architecture structure of sub_module is
  
  signal reset           : std_logic;

  signal led_blue_local  : slv_8_t;
  signal led_red_local   : slv_8_t;
  signal led_green_local : slv_8_t;

  -- kh aug'22
  constant localAXISlaves    : integer := 4;  
  --constant localAXISlaves    : integer := 2;
  signal local_AXI_ReadMOSI  :  AXIReadMOSI_array_t(0 to localAXISlaves-1) := ( others => DefaultAXIReadMOSI);
  signal local_AXI_ReadMISO  :  AXIReadMISO_array_t(0 to localAXISlaves-1) := ( others => DefaultAXIReadMISO);
  signal local_AXI_WriteMOSI : AXIWriteMOSI_array_t(0 to localAXISlaves-1) := ( others => DefaultAXIWriteMOSI);
  signal local_AXI_WriteMISO : AXIWriteMISO_array_t(0 to localAXISlaves-1) := ( others => DefaultAXIWriteMISO);
  signal AXI_CLK             : std_logic;
  signal AXI_RST_N           : std_logic;
  signal AXI_RESET           : std_logic;

  -- kh aug'22
  signal C2C_Mon  : C2C_INTF_MON_t;
  signal C2C_Ctrl : C2C_INTF_Ctrl_t;
  signal clk_F1_C2C_PHY_user                  : STD_logic_vector(1 downto 1);  
  signal pB_UART_tx : std_logic;
  signal pB_UART_rx : std_logic;

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

  -- KH sep'22 register rate
  signal rate_o : std_logic_vector(31 downto 0) := (others => '0');
  
begin  -- architecture structure


                   
  AXI_CLK <= clk_50;  -- for now we just use the 50 MHz from emp for axi

  --export the axi clock and reset to emp
  clk_axi <= AXI_CLK;
  rst_n_axi <= AXI_RST_N;

  -- kh aug'22 : add uart.  c2cb. V->F1
  c2csslave_wrapper_1: entity work.c2cSlave_sane_wrapper
    port map (
      EXT_CLK                                => clk_50,
      AXI_MASTER_CLK                         => AXI_CLK,      
      AXI_MASTER_RSTN                        => locked_clk200,
      sys_reset_rst_n(0)                     => AXI_RST_N,
                                             
      --AXI endpoint--                       
      F1_C2C_INTF_RMOSI                      => local_AXI_ReadMOSI(2), 
      F1_C2C_INTF_RMISO                      => local_AXI_ReadMISO(2), 
      F1_C2C_INTF_WMOSI                      => local_AXI_WriteMOSI(2),
      F1_C2C_INTF_WMISO                      => local_AXI_WriteMISO(2),
      --AXI endpoint--                       
      F1_CM_FW_INFO_RMOSI                    => local_AXI_ReadMOSI(1), 
      F1_CM_FW_INFO_RMISO                    => local_AXI_ReadMISO(1), 
      F1_CM_FW_INFO_WMOSI                    => local_AXI_WriteMOSI(1),
      F1_CM_FW_INFO_WMISO                    => local_AXI_WriteMISO(1),
      --AXI endpoint--                       
      F1_IO_RMOSI                            => local_AXI_ReadMOSI(0), 
      F1_IO_RMISO                            => local_AXI_ReadMISO(0), 
      F1_IO_WMOSI                            => local_AXI_WriteMOSI(0),
      F1_IO_WMISO                            => local_AXI_WriteMISO(0),
      --AXI endpoint--                       
      F1_IPBUS_RMOSI                         => ext_AXI_ReadMOSI, 
      F1_IPBUS_RMISO                         => ext_AXI_ReadMISO, 
      F1_IPBUS_WMOSI                         => ext_AXI_WriteMOSI,
      F1_IPBUS_WMISO                         => ext_AXI_WriteMISO,
                                             
                                             
                                             
      CM1_PB_UART_rxd                        => pB_UART_tx,
      CM1_PB_UART_txd                        => pB_UART_rx,
                                             
      F1_C2C_phy_Rx_rxn                      => n_mgt_z2FPGA(1 downto 1),
      F1_C2C_phy_Rx_rxp                      => p_mgt_z2FPGA(1 downto 1),
      F1_C2C_phy_Tx_txn                      => n_mgt_FPGA2z(1 downto 1),
      F1_C2C_phy_Tx_txp                      => p_mgt_FPGA2z(1 downto 1),
      F1_C2CB_phy_Rx_rxn                     => n_mgt_z2FPGA(2 downto 2),
      F1_C2CB_phy_Rx_rxp                     => p_mgt_z2FPGA(2 downto 2),
      F1_C2CB_phy_Tx_txn                     => n_mgt_FPGA2z(2 downto 2),
      F1_C2CB_phy_Tx_txp                     => p_mgt_FPGA2z(2 downto 2),      
      F1_C2C_phy_refclk                      => c2c_refclk,
      F1_C2CB_phy_refclk                     => c2c_refclk,
                                             
                                             
                                             
      F1_C2C_PHY_DEBUG_cplllock(0)           => C2C_Mon.C2C(1).DEBUG.CPLL_LOCK,
      F1_C2C_PHY_DEBUG_dmonitorout           => C2C_Mon.C2C(1).DEBUG.DMONITOR,
      F1_C2C_PHY_DEBUG_eyescandataerror(0)   => C2C_Mon.C2C(1).DEBUG.EYESCAN_DATA_ERROR,
                                             
      F1_C2C_PHY_DEBUG_eyescanreset(0)       => C2C_Ctrl.C2C(1).DEBUG.EYESCAN_RESET,
      F1_C2C_PHY_DEBUG_eyescantrigger(0)     => C2C_Ctrl.C2C(1).DEBUG.EYESCAN_TRIGGER,
      F1_C2C_PHY_DEBUG_pcsrsvdin             => C2C_Ctrl.C2C(1).DEBUG.PCS_RSV_DIN,
      F1_C2C_PHY_DEBUG_qplllock(0)           =>  C2C_Mon.C2C(1).DEBUG.QPLL_LOCK,
      F1_C2C_PHY_DEBUG_rxbufreset(0)         => C2C_Ctrl.C2C(1).DEBUG.RX.BUF_RESET,
      F1_C2C_PHY_DEBUG_rxbufstatus           =>  C2C_Mon.C2C(1).DEBUG.RX.BUF_STATUS,
      F1_C2C_PHY_DEBUG_rxcdrhold(0)          => C2C_Ctrl.C2C(1).DEBUG.RX.CDR_HOLD,
      F1_C2C_PHY_DEBUG_rxdfelpmreset(0)      => C2C_Ctrl.C2C(1).DEBUG.RX.DFE_LPM_RESET,
      F1_C2C_PHY_DEBUG_rxlpmen(0)            => C2C_Ctrl.C2C(1).DEBUG.RX.LPM_EN,
      F1_C2C_PHY_DEBUG_rxpcsreset(0)         => C2C_Ctrl.C2C(1).DEBUG.RX.PCS_RESET,
      F1_C2C_PHY_DEBUG_rxpmareset(0)         => C2C_Ctrl.C2C(1).DEBUG.RX.PMA_RESET,
      F1_C2C_PHY_DEBUG_rxpmaresetdone(0)     =>  C2C_Mon.C2C(1).DEBUG.RX.PMA_RESET_DONE,
      F1_C2C_PHY_DEBUG_rxprbscntreset(0)     => C2C_Ctrl.C2C(1).DEBUG.RX.PRBS_CNT_RST,
      F1_C2C_PHY_DEBUG_rxprbserr(0)          =>  C2C_Mon.C2C(1).DEBUG.RX.PRBS_ERR,
      F1_C2C_PHY_DEBUG_rxprbssel             => C2C_Ctrl.C2C(1).DEBUG.RX.PRBS_SEL,
      F1_C2C_PHY_DEBUG_rxrate                => C2C_Ctrl.C2C(1).DEBUG.RX.RATE,
      F1_C2C_PHY_DEBUG_rxresetdone(0)        =>  C2C_Mon.C2C(1).DEBUG.RX.RESET_DONE,
      F1_C2C_PHY_DEBUG_txbufstatus           =>  C2C_Mon.C2C(1).DEBUG.TX.BUF_STATUS,
      F1_C2C_PHY_DEBUG_txdiffctrl            => C2C_Ctrl.C2C(1).DEBUG.TX.DIFF_CTRL,
      F1_C2C_PHY_DEBUG_txinhibit(0)          => C2C_Ctrl.C2C(1).DEBUG.TX.INHIBIT,
      F1_C2C_PHY_DEBUG_txpcsreset(0)         => C2C_Ctrl.C2C(1).DEBUG.TX.PCS_RESET,
      F1_C2C_PHY_DEBUG_txpmareset(0)         => C2C_Ctrl.C2C(1).DEBUG.TX.PMA_RESET,
      F1_C2C_PHY_DEBUG_txpolarity(0)         => C2C_Ctrl.C2C(1).DEBUG.TX.POLARITY,
      F1_C2C_PHY_DEBUG_txpostcursor          => C2C_Ctrl.C2C(1).DEBUG.TX.POST_CURSOR,
      F1_C2C_PHY_DEBUG_txprbsforceerr(0)     => C2C_Ctrl.C2C(1).DEBUG.TX.PRBS_FORCE_ERR,
      F1_C2C_PHY_DEBUG_txprbssel             => C2C_Ctrl.C2C(1).DEBUG.TX.PRBS_SEL,
      F1_C2C_PHY_DEBUG_txprecursor           => C2C_Ctrl.C2C(1).DEBUG.TX.PRE_CURSOR,
      F1_C2C_PHY_DEBUG_txresetdone(0)        =>  C2C_MON.C2C(1).DEBUG.TX.RESET_DONE,
                                             
      F1_C2C_PHY_channel_up                  => C2C_Mon.C2C(1).STATUS.CHANNEL_UP,      
      F1_C2C_PHY_gt_pll_lock                 => C2C_MON.C2C(1).STATUS.PHY_GT_PLL_LOCK,
      F1_C2C_PHY_hard_err                    => C2C_Mon.C2C(1).STATUS.PHY_HARD_ERR,
      F1_C2C_PHY_lane_up                     => C2C_Mon.C2C(1).STATUS.PHY_LANE_UP(0 downto 0),
      F1_C2C_PHY_mmcm_not_locked_out         => C2C_Mon.C2C(1).STATUS.PHY_MMCM_LOL,
      F1_C2C_PHY_soft_err                    => C2C_Mon.C2C(1).STATUS.PHY_SOFT_ERR,
                                             
      F1_C2C_aurora_do_cc                    =>  C2C_Mon.C2C(1).STATUS.DO_CC,
      F1_C2C_aurora_pma_init_in              => C2C_Ctrl.C2C(1).STATUS.INITIALIZE,
      F1_C2C_axi_c2c_config_error_out        =>  C2C_Mon.C2C(1).STATUS.CONFIG_ERROR,
      F1_C2C_axi_c2c_link_status_out         =>  C2C_MON.C2C(1).STATUS.LINK_GOOD,
      F1_C2C_axi_c2c_multi_bit_error_out     =>  C2C_MON.C2C(1).STATUS.MB_ERROR,
      F1_C2C_phy_power_down                  => '0',
      F1_C2C_PHY_clk                         => clk_F1_C2C_PHY_user(1),
      F1_C2C_PHY_DRP_daddr                   => C2C_Ctrl.C2C(1).DRP.address,
      F1_C2C_PHY_DRP_den                     => C2C_Ctrl.C2C(1).DRP.enable,
      F1_C2C_PHY_DRP_di                      => C2C_Ctrl.C2C(1).DRP.wr_data,
      F1_C2C_PHY_DRP_do                      => C2C_MON.C2C(1).DRP.rd_data,
      F1_C2C_PHY_DRP_drdy                    => C2C_MON.C2C(1).DRP.rd_data_valid,
      F1_C2C_PHY_DRP_dwe                     => C2C_Ctrl.C2C(1).DRP.wr_enable,

      F1_C2CB_PHY_DEBUG_cplllock(0)          => C2C_Mon.C2C(2).DEBUG.CPLL_LOCK,
      F1_C2CB_PHY_DEBUG_dmonitorout          => C2C_Mon.C2C(2).DEBUG.DMONITOR,
      F1_C2CB_PHY_DEBUG_eyescandataerror(0)  => C2C_Mon.C2C(2).DEBUG.EYESCAN_DATA_ERROR,
                                             
      F1_C2CB_PHY_DEBUG_eyescanreset(0)      => C2C_Ctrl.C2C(2).DEBUG.EYESCAN_RESET,
      F1_C2CB_PHY_DEBUG_eyescantrigger(0)    => C2C_Ctrl.C2C(2).DEBUG.EYESCAN_TRIGGER,
      F1_C2CB_PHY_DEBUG_pcsrsvdin            => C2C_Ctrl.C2C(2).DEBUG.PCS_RSV_DIN,
      F1_C2CB_PHY_DEBUG_qplllock(0)          =>  C2C_Mon.C2C(2).DEBUG.QPLL_LOCK,
      F1_C2CB_PHY_DEBUG_rxbufreset(0)        => C2C_Ctrl.C2C(2).DEBUG.RX.BUF_RESET,
      F1_C2CB_PHY_DEBUG_rxbufstatus          =>  C2C_Mon.C2C(2).DEBUG.RX.BUF_STATUS,
      F1_C2CB_PHY_DEBUG_rxcdrhold(0)         => C2C_Ctrl.C2C(2).DEBUG.RX.CDR_HOLD,
      F1_C2CB_PHY_DEBUG_rxdfelpmreset(0)     => C2C_Ctrl.C2C(2).DEBUG.RX.DFE_LPM_RESET,
      F1_C2CB_PHY_DEBUG_rxlpmen(0)           => C2C_Ctrl.C2C(2).DEBUG.RX.LPM_EN,
      F1_C2CB_PHY_DEBUG_rxpcsreset(0)        => C2C_Ctrl.C2C(2).DEBUG.RX.PCS_RESET,
      F1_C2CB_PHY_DEBUG_rxpmareset(0)        => C2C_Ctrl.C2C(2).DEBUG.RX.PMA_RESET,
      F1_C2CB_PHY_DEBUG_rxpmaresetdone(0)    =>  C2C_Mon.C2C(2).DEBUG.RX.PMA_RESET_DONE,
      F1_C2CB_PHY_DEBUG_rxprbscntreset(0)    => C2C_Ctrl.C2C(2).DEBUG.RX.PRBS_CNT_RST,
      F1_C2CB_PHY_DEBUG_rxprbserr(0)         =>  C2C_Mon.C2C(2).DEBUG.RX.PRBS_ERR,
      F1_C2CB_PHY_DEBUG_rxprbssel            => C2C_Ctrl.C2C(2).DEBUG.RX.PRBS_SEL,
      F1_C2CB_PHY_DEBUG_rxrate               => C2C_Ctrl.C2C(2).DEBUG.RX.RATE,
      F1_C2CB_PHY_DEBUG_rxresetdone(0)       =>  C2C_Mon.C2C(2).DEBUG.RX.RESET_DONE,
      F1_C2CB_PHY_DEBUG_txbufstatus          =>  C2C_Mon.C2C(2).DEBUG.TX.BUF_STATUS,
      F1_C2CB_PHY_DEBUG_txdiffctrl           => C2C_Ctrl.C2C(2).DEBUG.TX.DIFF_CTRL,
      F1_C2CB_PHY_DEBUG_txinhibit(0)         => C2C_Ctrl.C2C(2).DEBUG.TX.INHIBIT,
      F1_C2CB_PHY_DEBUG_txpcsreset(0)        => C2C_Ctrl.C2C(2).DEBUG.TX.PCS_RESET,
      F1_C2CB_PHY_DEBUG_txpmareset(0)        => C2C_Ctrl.C2C(2).DEBUG.TX.PMA_RESET,
      F1_C2CB_PHY_DEBUG_txpolarity(0)        => C2C_Ctrl.C2C(2).DEBUG.TX.POLARITY,
      F1_C2CB_PHY_DEBUG_txpostcursor         => C2C_Ctrl.C2C(2).DEBUG.TX.POST_CURSOR,
      F1_C2CB_PHY_DEBUG_txprbsforceerr(0)    => C2C_Ctrl.C2C(2).DEBUG.TX.PRBS_FORCE_ERR,
      F1_C2CB_PHY_DEBUG_txprbssel            => C2C_Ctrl.C2C(2).DEBUG.TX.PRBS_SEL,
      F1_C2CB_PHY_DEBUG_txprecursor          => C2C_Ctrl.C2C(2).DEBUG.TX.PRE_CURSOR,
      F1_C2CB_PHY_DEBUG_txresetdone(0)       =>  C2C_MON.C2C(2).DEBUG.TX.RESET_DONE,

      F1_C2CB_PHY_channel_up                 => C2C_Mon.C2C(2).STATUS.CHANNEL_UP,      
      F1_C2CB_PHY_gt_pll_lock                => C2C_MON.C2C(2).STATUS.PHY_GT_PLL_LOCK,
      F1_C2CB_PHY_hard_err                   => C2C_Mon.C2C(2).STATUS.PHY_HARD_ERR,
      F1_C2CB_PHY_lane_up                    => C2C_Mon.C2C(2).STATUS.PHY_LANE_UP(0 downto 0),
--      F1_C2CB_PHY_mmcm_not_locked            => C2C_Mon.C2C(2).STATUS.PHY_MMCM_LOL,
      F1_C2CB_PHY_soft_err                   => C2C_Mon.C2C(2).STATUS.PHY_SOFT_ERR,

      F1_C2CB_aurora_do_cc                   =>  C2C_Mon.C2C(2).STATUS.DO_CC,
      F1_C2CB_aurora_pma_init_in             => C2C_Ctrl.C2C(2).STATUS.INITIALIZE,
      F1_C2CB_axi_c2c_config_error_out       =>  C2C_Mon.C2C(2).STATUS.CONFIG_ERROR,
      F1_C2CB_axi_c2c_link_status_out        =>  C2C_MON.C2C(2).STATUS.LINK_GOOD,
      F1_C2CB_axi_c2c_multi_bit_error_out    =>  C2C_MON.C2C(2).STATUS.MB_ERROR,
      F1_C2CB_phy_power_down                 => '0',
--      F1_C2CB_PHY_user_clk_out               => clk_F1_C2CB_PHY_user,
      F1_C2CB_PHY_DRP_daddr                  => C2C_Ctrl.C2C(2).DRP.address,
      F1_C2CB_PHY_DRP_den                    => C2C_Ctrl.C2C(2).DRP.enable,
      F1_C2CB_PHY_DRP_di                     => C2C_Ctrl.C2C(2).DRP.wr_data,
      F1_C2CB_PHY_DRP_do                     => C2C_MON.C2C(2).DRP.rd_data,
      F1_C2CB_PHY_DRP_drdy                   => C2C_MON.C2C(2).DRP.rd_data_valid,
      F1_C2CB_PHY_DRP_dwe                    => C2C_Ctrl.C2C(2).DRP.wr_enable


);
  c2c_ok <= C2C_Mon.C2C(1).STATUS.LINK_GOOD and
            C2C_Mon.C2C(1).STATUS.PHY_LANE_UP(0) and
            C2C_Mon.C2C(2).STATUS.LINK_GOOD and
            C2C_Mon.C2C(2).STATUS.PHY_LANE_UP(0);


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


  -- kh aug'22
  rate_counter_1: entity work.rate_counter
    generic map (
      CLK_A_1_SECOND => 2000000)
    port map (
      clk_A         => clk_200,
      clk_B         => clk_F1_C2C_PHY_user(1),
      reset_A_async => AXI_RESET,
      event_b       => '1',
-- KH register for timing
--      rate          => C2C_Mon.C2C(1).USER_FREQ);
      rate          => rate_o);
  rate_register : process ( clk_F1_C2C_PHY_user(1), rate_o )
    variable rate_reg : std_logic_vector(31 downto 0) := (others => '0');
  begin
    if( rising_edge( clk_F1_C2C_PHY_user(1) )  ) then
      C2C_Mon.C2C(1).USER_FREQ  <= rate_reg;             
      rate_reg := rate_o;   
    end if;       
  end process;
  C2C_Mon.C2C(2).USER_FREQ <= C2C_Mon.C2C(1).USER_FREQ;  
  


--  V_IO_interface_1: entity work.V_IO_interface
  F1_IO_interface_1: entity work.IO_map
    generic map(
      ALLOCATED_MEMORY_RANGE => to_integer(AXI_RANGE_F1_IO)
      )
    port map (
      clk_axi         => AXI_CLK,
      reset_axi_n     => AXI_RST_N,
      slave_readMOSI  => local_AXI_readMOSI(0),
      slave_readMISO  => local_AXI_readMISO(0),
      slave_writeMOSI => local_AXI_writeMOSI(0),
      slave_writeMISO => local_AXI_writeMISO(0),
      Mon.CLK_200_LOCKED      => locked_clk200,
      Mon.BRAM.RD_DATA        => (others => '0'),
      Ctrl.RGB.R              => led_red_local,
      Ctrl.RGB.G              => led_green_local,
      Ctrl.RGB.B              => led_blue_local,
      Ctrl.BRAM               => open
      );

--  CM_V_info_1: entity work.CM_V_info
  CM_F1_info_1: entity work.CM_FW_info
    generic map (
      ALLOCATED_MEMORY_RANGE => to_integer(AXI_RANGE_F1_CM_FW_INFO)
      )
  port map (
      clk_axi     => AXI_CLK,
      reset_axi_n => AXI_RST_N,
      readMOSI    => local_AXI_ReadMOSI(1),
      readMISO    => local_AXI_ReadMISO(1),
      writeMOSI   => local_AXI_WriteMOSI(1),
      writeMISO   => local_AXI_WriteMISO(1));

 -- kh aug'22
  C2C_INTF_1: entity work.C2C_INTF
    generic map (
      ERROR_WAIT_TIME => 90000000,
      ALLOCATED_MEMORY_RANGE => to_integer(AXI_RANGE_F1_C2C_INTF)
      )
    port map (
      clk_axi          => AXI_CLK,
      reset_axi_n      => AXI_RST_N,
      readMOSI         => local_AXI_readMOSI(2),
      readMISO         => local_AXI_readMISO(2),
      writeMOSI        => local_AXI_writeMOSI(2),
      writeMISO        => local_AXI_writeMISO(2),
      clk_C2C(1)       => clk_F1_C2C_PHY_user(1),
      clk_C2C(2)       => clk_F1_C2C_PHY_user(1),
      UART_Rx          => pb_UART_Rx,
      UART_Tx          => pb_UART_Tx,
      Mon              => C2C_Mon,
      Ctrl             => C2C_Ctrl);


  AXI_RESET <= not AXI_RST_N;

  
end architecture structure;
