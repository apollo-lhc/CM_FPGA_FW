-- File: top.vhd
-- Auth: Dan Gastler, Boston University Physics
-- Mod.: M. Fras, Electronics Division, MPI for Physics, Munich
-- Date: 18 Dec 2020
-- Rev.: 24 Mar 2021
--
-- KU15P top VHDL file for the MPI Command Module (CM) demonstrator.
--



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use ieee.std_logic_misc.all;

use work.axiRegPkg.all;
use work.types.all;
use work.K_IO_Ctrl.all;



library UNISIM;
use UNISIM.vcomponents.all;

entity top is
  port (
    -- Clocks.
    -- 100 MHz system clock from crystal oscillator.
    i_clk_100_p             : in  std_logic;
    i_clk_100_n             : in  std_logic;
    -- LHC clock from jitter cleaner IC56 (Si5345A).
    i_clk_lhc_p             : in  std_logic;
    i_clk_lhc_n             : in  std_logic;
    -- Recovered LHC clock from clock and data recovery chip IC46 (ADN2814ACPZ).
    i_clk_legacy_ttc_p      : in  std_logic;
    i_clk_legacy_ttc_n      : in  std_logic;
    -- Clock from SMA connectors X76 and X78, directly connected.
    i_clk_sma_direct_p      : in  std_logic;
    i_clk_sma_direct_n      : in  std_logic;
    -- Clock from SMA connectors X68 and X69, fed through jitter cleaner IC65.
    i_clk_sma_jc_p          : in  std_logic;
    i_clk_sma_jc_n          : in  std_logic;
    -- Output for recovered LHC clock, fed into jitter cleaner IC56 (Si5345A).
    o_clk_lhc_p             : out std_logic;
    o_clk_lhc_n             : out std_logic;

    -- Legacy TTC recovered data from clock and data recovery chip IC46 (ADN2814ACPZ).
    i_data_legacy_ttc_p     : in  std_logic;
    i_data_legacy_ttc_n     : in  std_logic;

    -- SM SoC AXI Chip2Chip.
    i_refclk_axi_c2c_p      : in  std_logic;
    i_refclk_axi_c2c_n      : in  std_logic;
    i_mgt_axi_c2c_p         : in  std_logic_vector(1 downto 1);
    i_mgt_axi_c2c_n         : in  std_logic_vector(1 downto 1);
    o_mgt_axi_c2c_p         : out std_logic_vector(1 downto 1);
    o_mgt_axi_c2c_n         : out std_logic_vector(1 downto 1);

    -- GTH transceivers.
    -- Hint: The first 2 transceivers (on MGT bank 224) are used for SM SoC AXI
    --       Chip2Chip. It utilizes refclk1[0]. The corresponding IO pins are
    --       defined in the SM SoC AXI Chip2Chip section.
    i_gth_refclk0_p         : in  std_logic_vector(10 downto 0);
    i_gth_refclk0_n         : in  std_logic_vector(10 downto 0);
    i_gth_refclk1_p         : in  std_logic_vector(10 downto 1);    -- i_gth_refclk1_p/n[0] reserved for SM SoC AXI Chip2Chip.
    i_gth_refclk1_n         : in  std_logic_vector(10 downto 1);
    i_gth_rx_p              : in  std_logic_vector(43 downto 2);    -- i_gth_rx_p/n[1..0] reserved for SM SoC AXI Chip2Chip.
    i_gth_rx_n              : in  std_logic_vector(43 downto 2);
    o_gth_tx_p              : out std_logic_vector(43 downto 2);    -- o_gth_tx_p/n[1..0] reserved for SM SoC AXI Chip2Chip.
    o_gth_tx_n              : out std_logic_vector(43 downto 2);

    -- GTY transceivers.
    i_gty_refclk0_p         : in  std_logic_vector( 7 downto 0);
    i_gty_refclk0_n         : in  std_logic_vector( 7 downto 0);
    i_gty_refclk1_p         : in  std_logic_vector( 7 downto 0);
    i_gty_refclk1_n         : in  std_logic_vector( 7 downto 0);
    i_gty_rx_p              : in  std_logic_vector(31 downto 0);
    i_gty_rx_n              : in  std_logic_vector(31 downto 0);
    o_gty_tx_p              : out std_logic_vector(31 downto 0);
    o_gty_tx_n              : out std_logic_vector(31 downto 0);

    -- Spare MCU connections.
    io_mcu_se               : inout std_logic_vector(3 downto 0);
    
    -- Spare SM-CM connections.
    io_sm_gpio              : inout std_logic_vector(1 to 2);

    -- Spare I2C bus.
    io_reserved_i2c_scl     : inout std_logic;
    io_reserved_i2c_sda     : inout std_logic;

    -- Expansion header.
    io_exp_lvds_p           : inout std_logic_vector(10 downto 0);
    io_exp_lvds_n           : inout std_logic_vector(10 downto 0);
    io_exp_se               : inout std_logic_vector(10 downto 0);

    -- Debug header.
    io_dbg_lvds_p           : inout std_logic_vector(1 downto 0);
    io_dbg_lvds_n           : inout std_logic_vector(1 downto 0);
    io_dbg_se               : inout std_logic_vector(5 downto 0);

    -- Inter-FPGA connections (KU15P - ZU11EG).
    io_k2z_lvds_p           : inout std_logic_vector(23 downto 0);
    io_k2z_lvds_n           : inout std_logic_vector(23 downto 0);
    io_k2z_se               : inout std_logic_vector(23 downto 0);

    -- Xilinx system monitor.
--    io_sysmon_i2c_scl       : inout std_logic;
--    io_sysmon_i2c_sda       : inout std_logic

    -- User LEDs.
    o_led                   : out std_logic_vector(7 downto 0)
    );
end entity top;

architecture structure of top is

    -- Clocks.
    signal clk_100          : std_logic;
    signal clk_100_bufg     : std_logic;
    signal clk_lhc_in       : std_logic;
    signal clk_legacy_ttc   : std_logic;
    signal clk_sma_direct   : std_logic;
    signal clk_sma_jc       : std_logic;
    signal clk_lhc_out      : std_logic;

    -- Local clocking.
    signal clk_200          : std_logic;
    signal clk_50           : std_logic;
    signal reset            : std_logic;
    signal locked_clk200    : std_logic;

    signal data_legacy_ttc  : std_logic;

    signal led_blue_local   : slv_8_t;
    signal led_red_local    : slv_8_t;
    signal led_green_local  : slv_8_t;

    constant localAXISlaves    : integer := 3;
    signal local_AXI_ReadMOSI  :  AXIReadMOSI_array_t(0 to localAXISlaves-1) := ( others => DefaultAXIReadMOSI);
    signal local_AXI_ReadMISO  :  AXIReadMISO_array_t(0 to localAXISlaves-1) := ( others => DefaultAXIReadMISO);
    signal local_AXI_WriteMOSI : AXIWriteMOSI_array_t(0 to localAXISlaves-1) := ( others => DefaultAXIWriteMOSI);
    signal local_AXI_WriteMISO : AXIWriteMISO_array_t(0 to localAXISlaves-1) := ( others => DefaultAXIWriteMISO);
    signal AXI_CLK             : std_logic;
    signal AXI_RST_N           : std_logic;
    signal AXI_RESET           : std_logic;

    signal ext_AXI_ReadMOSI  :  AXIReadMOSI := DefaultAXIReadMOSI;
    signal ext_AXI_ReadMISO  :  AXIReadMISO := DefaultAXIReadMISO;
    signal ext_AXI_WriteMOSI : AXIWriteMOSI := DefaultAXIWriteMOSI;
    signal ext_AXI_WriteMISO : AXIWriteMISO := DefaultAXIWriteMISO;


    signal gty_refclk0 : std_logic_vector(7 downto 0);
    signal gty_odiv2_0 : std_logic_vector(7 downto 0);

    signal C2CLink_aurora_do_cc                : std_logic;
    signal C2CLink_axi_c2c_config_error_out    : std_logic;
    signal C2CLink_axi_c2c_link_status_out     : std_logic;
    signal C2CLink_axi_c2c_multi_bit_error_out : std_logic;
    signal C2CLink_phy_gt_pll_lock             : std_logic;
    signal C2CLink_phy_hard_err                : std_logic;
    signal C2CLink_phy_lane_up                 : std_logic_vector ( 0 to 0 );
    signal C2CLink_phy_link_reset_out          : std_logic;
    signal C2CLink_phy_mmcm_not_locked_out     : std_logic;
    signal C2CLink_phy_soft_err                : std_logic;


    signal BRAM_write : std_logic;
    signal BRAM_addr  : std_logic_vector(9 downto 0);
    signal BRAM_WR_data : std_logic_vector(31 downto 0);
    signal BRAM_RD_data : std_logic_vector(31 downto 0);

    signal AXI_BRAM_EN : std_logic;
    signal AXI_BRAM_we : std_logic_vector(3 downto 0);
    signal AXI_BRAM_addr :std_logic_vector(11 downto 0);
    signal AXI_BRAM_DATA_IN : std_logic_vector(31 downto 0);
    signal AXI_BRAM_DATA_OUT : std_logic_vector(31 downto 0);

    -- Auxiliary.
    signal std_logic_0 : std_logic;
    signal std_logic_1 : std_logic;

    -- Counters.
    signal rst_cnt_50  : std_logic;
    signal cnt_clk_50  : std_logic_vector(31 downto 0);
    signal rst_cnt_200 : std_logic;
    signal cnt_clk_200 : std_logic_vector(31 downto 0);
    signal clk_axi     : std_logic;
    signal rst_cnt_axi : std_logic;
    signal cnt_clk_axi : std_logic_vector(31 downto 0);

    -- User LEDs and multiplexer.
    signal user_led_axi : std_logic_vector(31 downto 0);
    signal user_led : std_logic_vector(o_led'range);


begin  -- architecture structure

    -- Clocking.
    IBUFGDS_clk_lhc : entity work.IBUFGDS
    port map (
        I   => i_clk_100_p,
        IB  => i_clk_100_n,
        O   => clk_100
    );
    BUFG_clk_100 : entity work.BUFG
    port map (
        I => clk_100,
        O => clk_100_bufg
    );
    IBUFDS_clk_lhc : entity work.IBUFDS
    port map (
        I   => i_clk_lhc_p,
        IB  => i_clk_lhc_n,
        O   => clk_lhc_in
    );
    IBUFDS_clk_legacy_ttc : entity work.IBUFDS
    port map (
        I   => i_clk_legacy_ttc_p,
        IB  => i_clk_legacy_ttc_n,
        O   => clk_legacy_ttc
    );
    IBUFDS_clk_sma_direct : entity work.IBUFDS
    port map (
        I   => i_clk_sma_direct_p,
        IB  => i_clk_sma_direct_n,
        O   => clk_sma_direct
    );
    IBUFDS_clk_sma_jc : entity work.IBUFDS
    port map (
        I   => i_clk_sma_jc_p,
        IB  => i_clk_sma_jc_n,
        O   => clk_sma_jc
    );
    OBUFDS_clk_lhc : entity work.OBUFDS
    port map (
        I   => clk_lhc_out,
        O   => o_clk_lhc_p,
        OB  => o_clk_lhc_n
    );
    clk_lhc_out <= '0';

    IBUFDS_data_legacy_ttc : entity work.IBUFDS
    port map (
        I   => i_data_legacy_ttc_p,
        IB  => i_data_legacy_ttc_n,
        O   => data_legacy_ttc
    );

    Local_Clocking_1 : entity work.Local_Clocking
    port map (
        -- Clock out ports.
        clk_200   => clk_200,
        clk_50    => clk_50,
        clk_axi   => AXI_CLK,
        -- Status and control signals.
        reset     => '0',
        locked    => locked_clk200,
        -- Clock in ports.
        clk_in1   => clk_100_bufg
    );

    std_logic_0 <= '0';
    std_logic_1 <= '1';
    
    IBUFDS_GTE4_ibert_gty_felix : entity work.IBUFDS_GTE4
    port map (
        O            => gty_refclk0(7),
        ODIV2        => gty_odiv2_0(7),
        CEB          => std_logic_0,
        I            => i_gty_refclk0_p(7),
        IB           => i_gty_refclk0_n(7)
    
    );
    
    ibert_gty_felix_1 : entity work.ibert_gty_felix
    port map (
        txn_o => o_gty_tx_n(31 downto 20),
        txp_o => o_gty_tx_p(31 downto 20),
        rxn_i => i_gty_rx_n(31 downto 20),
        rxp_i => i_gty_rx_p(31 downto 20),
        gtrefclk0_i => gty_refclk0(7 downto 5),
        gtrefclk1_i => "000",
        gtnorthrefclk0_i => "000",
        gtnorthrefclk1_i => "000",
        gtsouthrefclk0_i => "000",
        gtsouthrefclk1_i => "000",
        gtrefclk00_i => gty_refclk0(7 downto 5),
        gtrefclk10_i => "000",
        gtrefclk01_i => "000",
        gtrefclk11_i => "000",
        gtnorthrefclk00_i => "000",
        gtnorthrefclk10_i => "000",
        gtnorthrefclk01_i => "000",
        gtnorthrefclk11_i => "000",
        gtsouthrefclk00_i => "000",
        gtsouthrefclk10_i => "000",
        gtsouthrefclk01_i => "000",
        gtsouthrefclk11_i => "000",
        clk => clk_100_bufg
    );




    c2csslave_wrapper_1 : entity work.c2cslave_wrapper
    port map (
      AXI_CLK                           => AXI_CLK,
      AXI_RST_N(0)                      => AXI_RST_N,
      K_C2C_phy_Rx_rxn                  => i_mgt_axi_c2c_n,
      K_C2C_phy_Rx_rxp                  => i_mgt_axi_c2c_p,
      K_C2C_phy_Tx_txn                  => o_mgt_axi_c2c_n,
      K_C2C_phy_Tx_txp                  => o_mgt_axi_c2c_p,
      K_C2C_phy_refclk_clk_n            => i_refclk_axi_c2c_n,
      K_C2C_phy_refclk_clk_p            => i_refclk_axi_c2c_p,
      clk50Mhz                          => clk_50,
      K_IO_araddr                       => local_AXI_ReadMOSI(0).address,
      K_IO_arprot                       => local_AXI_ReadMOSI(0).protection_type,
      K_IO_arready                      => local_AXI_ReadMISO(0).ready_for_address,
      K_IO_arvalid                      => local_AXI_ReadMOSI(0).address_valid,
      K_IO_awaddr                       => local_AXI_WriteMOSI(0).address,
      K_IO_awprot                       => local_AXI_WriteMOSI(0).protection_type,
      K_IO_awready                      => local_AXI_WriteMISO(0).ready_for_address,
      K_IO_awvalid                      => local_AXI_WriteMOSI(0).address_valid,
      K_IO_bready                       => local_AXI_WriteMOSI(0).ready_for_response,
      K_IO_bresp                        => local_AXI_WriteMISO(0).response,
      K_IO_bvalid                       => local_AXI_WriteMISO(0).response_valid,
      K_IO_rdata                        => local_AXI_ReadMISO(0).data,
      K_IO_rready                       => local_AXI_ReadMOSI(0).ready_for_data,
      K_IO_rresp                        => local_AXI_ReadMISO(0).response,
      K_IO_rvalid                       => local_AXI_ReadMISO(0).data_valid,
      K_IO_wdata                        => local_AXI_WriteMOSI(0).data,
      K_IO_wready                       => local_AXI_WriteMISO(0).ready_for_data,
      K_IO_wstrb                        => local_AXI_WriteMOSI(0).data_write_strobe,
      K_IO_wvalid                       => local_AXI_WriteMOSI(0).data_valid,
      CM_K_INFO_araddr                  => local_AXI_ReadMOSI(1).address,
      CM_K_INFO_arprot                  => local_AXI_ReadMOSI(1).protection_type,
      CM_K_INFO_arready                 => local_AXI_ReadMISO(1).ready_for_address,
      CM_K_INFO_arvalid                 => local_AXI_ReadMOSI(1).address_valid,
      CM_K_INFO_awaddr                  => local_AXI_WriteMOSI(1).address,
      CM_K_INFO_awprot                  => local_AXI_WriteMOSI(1).protection_type,
      CM_K_INFO_awready                 => local_AXI_WriteMISO(1).ready_for_address,
      CM_K_INFO_awvalid                 => local_AXI_WriteMOSI(1).address_valid,
      CM_K_INFO_bready                  => local_AXI_WriteMOSI(1).ready_for_response,
      CM_K_INFO_bresp                   => local_AXI_WriteMISO(1).response,
      CM_K_INFO_bvalid                  => local_AXI_WriteMISO(1).response_valid,
      CM_K_INFO_rdata                   => local_AXI_ReadMISO(1).data,
      CM_K_INFO_rready                  => local_AXI_ReadMOSI(1).ready_for_data,
      CM_K_INFO_rresp                   => local_AXI_ReadMISO(1).response,
      CM_K_INFO_rvalid                  => local_AXI_ReadMISO(1).data_valid,
      CM_K_INFO_wdata                   => local_AXI_WriteMOSI(1).data,
      CM_K_INFO_wready                  => local_AXI_WriteMISO(1).ready_for_data,
      CM_K_INFO_wstrb                   => local_AXI_WriteMOSI(1).data_write_strobe,
      CM_K_INFO_wvalid                  => local_AXI_WriteMOSI(1).data_valid,
      -- Kintex user LEDs.
      MPI_KU15P_LEDS_araddr             => local_AXI_ReadMOSI(2).address,
      MPI_KU15P_LEDS_arprot             => local_AXI_ReadMOSI(2).protection_type,
      MPI_KU15P_LEDS_arready            => local_AXI_ReadMISO(2).ready_for_address,
      MPI_KU15P_LEDS_arvalid            => local_AXI_ReadMOSI(2).address_valid,
      MPI_KU15P_LEDS_awaddr             => local_AXI_WriteMOSI(2).address,
      MPI_KU15P_LEDS_awprot             => local_AXI_WriteMOSI(2).protection_type,
      MPI_KU15P_LEDS_awready            => local_AXI_WriteMISO(2).ready_for_address,
      MPI_KU15P_LEDS_awvalid            => local_AXI_WriteMOSI(2).address_valid,
      MPI_KU15P_LEDS_bready             => local_AXI_WriteMOSI(2).ready_for_response,
      MPI_KU15P_LEDS_bresp              => local_AXI_WriteMISO(2).response,
      MPI_KU15P_LEDS_bvalid             => local_AXI_WriteMISO(2).response_valid,
      MPI_KU15P_LEDS_rdata              => local_AXI_ReadMISO(2).data,
      MPI_KU15P_LEDS_rready             => local_AXI_ReadMOSI(2).ready_for_data,
      MPI_KU15P_LEDS_rresp              => local_AXI_ReadMISO(2).response,
      MPI_KU15P_LEDS_rvalid             => local_AXI_ReadMISO(2).data_valid,
      MPI_KU15P_LEDS_wdata              => local_AXI_WriteMOSI(2).data,
      MPI_KU15P_LEDS_wready             => local_AXI_WriteMISO(2).ready_for_data,
      MPI_KU15P_LEDS_wstrb              => local_AXI_WriteMOSI(2).data_write_strobe,
      MPI_KU15P_LEDS_wvalid             => local_AXI_WriteMOSI(2).data_valid,


      KINTEX_IPBUS_araddr               => ext_AXI_ReadMOSI.address,
      KINTEX_IPBUS_arburst              => ext_AXI_ReadMOSI.burst_type,
      KINTEX_IPBUS_arcache              => ext_AXI_ReadMOSI.cache_type,
      KINTEX_IPBUS_arlen                => ext_AXI_ReadMOSI.burst_length,
      KINTEX_IPBUS_arlock(0)            => ext_AXI_ReadMOSI.lock_type,
      KINTEX_IPBUS_arprot               => ext_AXI_ReadMOSI.protection_type,
      KINTEX_IPBUS_arqos                => ext_AXI_ReadMOSI.qos,
      KINTEX_IPBUS_arready(0)           => ext_AXI_ReadMISO.ready_for_address,
      KINTEX_IPBUS_arregion             => ext_AXI_ReadMOSI.region,
      KINTEX_IPBUS_arsize               => ext_AXI_ReadMOSI.burst_size,
      KINTEX_IPBUS_arvalid(0)           => ext_AXI_ReadMOSI.address_valid,
      KINTEX_IPBUS_awaddr               => ext_AXI_WriteMOSI.address,
      KINTEX_IPBUS_awburst              => ext_AXI_WriteMOSI.burst_type,
      KINTEX_IPBUS_awcache              => ext_AXI_WriteMOSI.cache_type,
      KINTEX_IPBUS_awlen                => ext_AXI_WriteMOSI.burst_length,
      KINTEX_IPBUS_awlock(0)            => ext_AXI_WriteMOSI.lock_type,
      KINTEX_IPBUS_awprot               => ext_AXI_WriteMOSI.protection_type,
      KINTEX_IPBUS_awqos                => ext_AXI_WriteMOSI.qos,
      KINTEX_IPBUS_awready(0)           => ext_AXI_WriteMISO.ready_for_address,
      KINTEX_IPBUS_awregion             => ext_AXI_WriteMOSI.region,
      KINTEX_IPBUS_awsize               => ext_AXI_WriteMOSI.burst_size,
      KINTEX_IPBUS_awvalid(0)           => ext_AXI_WriteMOSI.address_valid,
      KINTEX_IPBUS_bready(0)            => ext_AXI_WriteMOSI.ready_for_response,
      KINTEX_IPBUS_bresp                => ext_AXI_WriteMISO.response,
      KINTEX_IPBUS_bvalid(0)            => ext_AXI_WriteMISO.response_valid,
      KINTEX_IPBUS_rdata                => ext_AXI_ReadMISO.data,
      KINTEX_IPBUS_rlast(0)             => ext_AXI_ReadMISO.last,
      KINTEX_IPBUS_rready(0)            => ext_AXI_ReadMOSI.ready_for_data,
      KINTEX_IPBUS_rresp                => ext_AXI_ReadMISO.response,
      KINTEX_IPBUS_rvalid(0)            => ext_AXI_ReadMISO.data_valid,
      KINTEX_IPBUS_wdata                => ext_AXI_WriteMOSI.data,
      KINTEX_IPBUS_wlast(0)             => ext_AXI_WriteMOSI.last,
      KINTEX_IPBUS_wready(0)            => ext_AXI_WriteMISO.ready_for_data,
      KINTEX_IPBUS_wstrb                => ext_AXI_WriteMOSI.data_write_strobe,
      KINTEX_IPBUS_wvalid(0)            => ext_AXI_WriteMOSI.data_valid,
      reset_n                           => locked_clk200,--reset,
      K_C2C_aurora_do_cc                => C2CLink_aurora_do_cc,
      K_C2C_axi_c2c_config_error_out    => C2CLink_axi_c2c_config_error_out,
      K_C2C_axi_c2c_link_status_out     => C2CLink_axi_c2c_link_status_out,
      K_C2C_axi_c2c_multi_bit_error_out => C2CLink_axi_c2c_multi_bit_error_out,
      K_C2C_phy_gt_pll_lock             => C2CLink_phy_gt_pll_lock,
      K_C2C_phy_hard_err                => C2CLink_phy_hard_err,
      K_C2C_phy_lane_up                 => C2CLink_phy_lane_up,
      K_C2C_phy_link_reset_out          => C2CLink_phy_link_reset_out,
      K_C2C_phy_mmcm_not_locked_out     => C2CLink_phy_mmcm_not_locked_out,
      K_C2C_phy_power_down              => '0',
      K_C2C_phy_soft_err                => C2CLink_phy_soft_err
);

  RGB_pwm_1 : entity work.RGB_pwm
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

  K_IO_interface_1 : entity work.K_IO_interface
    port map (
      clk_axi                 => AXI_CLK,
      reset_axi_n             => AXI_RST_N,
      slave_readMOSI          => local_AXI_readMOSI(0),
      slave_readMISO          => local_AXI_readMISO(0),
      slave_writeMOSI         => local_AXI_writeMOSI(0),
      slave_writeMISO         => local_AXI_writeMISO(0),
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
      Mon.BRAM.RD_DATA        => BRAM_RD_DATA,
      Ctrl.RGB.R              => led_red_local,
      Ctrl.RGB.G              => led_green_local,
      Ctrl.RGB.B              => led_blue_local,
      Ctrl.BRAM.WRITE         => BRAM_WRITE,
      Ctrl.BRAM.ADDR          => BRAM_ADDR,
      Ctrl.BRAM.WR_DATA       => BRAM_WR_DATA
      );

  CM_K_info_1 : entity work.CM_K_info
    port map (
      clk_axi     => AXI_CLK,
      reset_axi_n => AXI_RST_N,
      readMOSI    => local_AXI_ReadMOSI(1),
      readMISO    => local_AXI_ReadMISO(1),
      writeMOSI   => local_AXI_WriteMOSI(1),
      writeMISO   => local_AXI_WriteMISO(1));


  AXI_RESET <= not AXI_RST_N;
  AXI_BRAM_1 : entity work.AXI_BRAM
    port map (
      s_axi_aclk    => AXI_CLK,
      s_axi_aresetn => AXI_RST_N,
      s_axi_araddr          => ext_AXI_ReadMOSI.address(11 downto 0),
      s_axi_arburst         => ext_AXI_ReadMOSI.burst_type,
      s_axi_arcache         => ext_AXI_ReadMOSI.cache_type,
      s_axi_arlen           => ext_AXI_ReadMOSI.burst_length,
      s_axi_arlock          => ext_AXI_ReadMOSI.lock_type,
      s_axi_arprot          => ext_AXI_ReadMOSI.protection_type,
--      s_axi_arqos           => ext_AXI_ReadMOSI.qos,
      s_axi_arready         => ext_AXI_ReadMISO.ready_for_address,
--      s_axi_arregion        => ext_AXI_ReadMOSI.region,
      s_axi_arsize          => ext_AXI_ReadMOSI.burst_size,
      s_axi_arvalid         => ext_AXI_ReadMOSI.address_valid,
      s_axi_awaddr          => ext_AXI_WriteMOSI.address(11 downto 0),
      s_axi_awburst         => ext_AXI_WriteMOSI.burst_type,
      s_axi_awcache         => ext_AXI_WriteMOSI.cache_type,
      s_axi_awlen           => ext_AXI_WriteMOSI.burst_length,
      s_axi_awlock          => ext_AXI_WriteMOSI.lock_type,
      s_axi_awprot          => ext_AXI_WriteMOSI.protection_type,
--      s_axi_awqos           => ext_AXI_WriteMOSI.qos,
      s_axi_awready         => ext_AXI_WriteMISO.ready_for_address,
--      s_axi_awregion        => ext_AXI_WriteMOSI.region,
      s_axi_awsize          => ext_AXI_WriteMOSI.burst_size,
      s_axi_awvalid         => ext_AXI_WriteMOSI.address_valid,
      s_axi_bready          => ext_AXI_WriteMOSI.ready_for_response,
      s_axi_bresp           => ext_AXI_WriteMISO.response,
      s_axi_bvalid          => ext_AXI_WriteMISO.response_valid,
      s_axi_rdata           => ext_AXI_ReadMISO.data,
      s_axi_rlast           => ext_AXI_ReadMISO.last,
      s_axi_rready          => ext_AXI_ReadMOSI.ready_for_data,
      s_axi_rresp           => ext_AXI_ReadMISO.response,
      s_axi_rvalid          => ext_AXI_ReadMISO.data_valid,
      s_axi_wdata           => ext_AXI_WriteMOSI.data,
      s_axi_wlast           => ext_AXI_WriteMOSI.last,
      s_axi_wready          => ext_AXI_WriteMISO.ready_for_data,
      s_axi_wstrb           => ext_AXI_WriteMOSI.data_write_strobe,
      s_axi_wvalid          => ext_AXI_WriteMOSI.data_valid,
      bram_rst_a            => AXI_reset,
      bram_clk_a            => AXI_CLK,
      bram_en_a             => AXI_BRAM_en,
      bram_we_a             => AXI_BRAM_we,
      bram_addr_a           => AXI_BRAM_addr,
      bram_wrdata_a         => AXI_BRAM_DATA_IN,
      bram_rddata_a         => AXI_BRAM_DATA_OUT);


  asym_ram_tdp_1 : entity work.asym_ram_tdp
    generic map (
      WIDTHA     => 32,
      SIZEA      => 4096,
      ADDRWIDTHA => 12,
      WIDTHB     => 32,
      SIZEB      => 4096,
      ADDRWIDTHB => 12)
    port map (
      clkA  => AXI_CLK,
      clkB  => AXI_CLK,
      enA   => AXI_BRAM_EN,
      enB   => '1',
      weA   => or_reduce(AXI_BRAM_we),
      weB   => BRAM_WRITE,
      addrA => AXI_BRAM_addr(11 downto 0),
      addrB(11 downto 2) => BRAM_ADDR,
      addrB( 1 downto 0) => "00",
      diA   => AXI_BRAM_DATA_IN,
      diB   => BRAM_WR_DATA,
      doA   => AXI_BRAM_DATA_OUT,
      doB   => BRAM_RD_DATA);



    -- ==============================================================
    -- Test and debug features.
    -- ==============================================================

    -- Counter running with 50 MHz clock.
    rst_cnt_50 <= '0';
    proc_cnt_clk_50 : process (clk_50, rst_cnt_50) begin
        if (rst_cnt_50 = '1') then
            cnt_clk_50 <= (others => '0');
        elsif (clk_50'event and clk_50 = '1') then
            cnt_clk_50 <= std_logic_vector(unsigned(cnt_clk_50) + 1);
        end if;
    end process;

    -- Counter running with 200 MHz clock.
    rst_cnt_200 <= '0';
    proc_cnt_clk_200 : process (clk_200, rst_cnt_200) begin
        if (rst_cnt_200 = '1') then
            cnt_clk_200 <= (others => '0');
        elsif (clk_200'event and clk_200 = '1') then
            cnt_clk_200 <= std_logic_vector(unsigned(cnt_clk_200) + 1);
        end if;
    end process;

    -- Counter running with AXI clock.
    clk_axi <= AXI_CLK;
    rst_cnt_axi <= '0';
    proc_cnt_clk_axi : process (clk_axi, rst_cnt_axi) begin
        if (rst_cnt_axi = '1') then
            cnt_clk_axi <= (others => '0');
        elsif (clk_axi'event and clk_axi = '1') then
            cnt_clk_axi <= std_logic_vector(unsigned(cnt_clk_axi) + 1);
        end if;
    end process;

    -- AXI interface for user LEDs and multiplexer.
    User_LEDs_1 : entity work.User_LEDs
    port map (
        s_axi_aclk          => AXI_CLK,
        s_axi_aresetn       => AXI_RST_N,
        s_axi_awaddr        => local_AXI_WriteMOSI(2).address(8 downto 0),
        s_axi_awvalid       => local_AXI_WriteMOSI(2).data_valid,
        s_axi_awready       => local_AXI_WriteMISO(2).ready_for_address,
        s_axi_wdata         => local_AXI_WriteMOSI(2).data,
        s_axi_wstrb         => local_AXI_WriteMOSI(2).data_write_strobe,
        s_axi_wvalid        => local_AXI_WriteMOSI(2).data_valid,
        s_axi_wready        => local_AXI_WriteMISO(2).ready_for_data,
        s_axi_bresp         => local_AXI_WriteMISO(2).response,
        s_axi_bvalid        => local_AXI_WriteMISO(2).response_valid,
        s_axi_bready        => local_AXI_WriteMOSI(2).ready_for_response,
        s_axi_araddr        => local_AXI_ReadMOSI(2).address(8 downto 0),
        s_axi_arvalid       => local_AXI_ReadMOSI(2).address_valid,
        s_axi_arready       => local_AXI_ReadMISO(2).ready_for_address,
        s_axi_rdata         => local_AXI_ReadMISO(2).data,
        s_axi_rresp         => local_AXI_ReadMISO(2).response,
        s_axi_rvalid        => local_AXI_ReadMISO(2).data_valid,
        s_axi_rready        => local_AXI_ReadMOSI(2).ready_for_data,
        gpio_io_o           => user_led_axi
    );

    -- Multiplexer for the 8 physical user LEDs on the board.
    proc_user_led_mux : process (user_led_axi, cnt_clk_50, cnt_clk_200, cnt_clk_axi)
        variable v_user_led_mux_sel : std_logic_vector(3 downto 0);
        variable v_user_led_val : std_logic_vector(o_led'range);
    begin
        v_user_led_mux_sel := user_led_axi(o_led'high + v_user_led_mux_sel'high + 1 downto o_led'high + v_user_led_mux_sel'low + 1);
        v_user_led_val := user_led_axi(o_led'range);
        case v_user_led_mux_sel is
            when "0000" => user_led <= cnt_clk_50(26 downto 19);
            when "0001" => user_led <= cnt_clk_200(26 downto 19);
            when "0010" => user_led <= cnt_clk_axi(26 downto 19);
            when others => user_led <= v_user_led_val;
        end case;
    end process;

    -- Assign user LED to output port.
    o_led <= user_led;

end architecture structure;
