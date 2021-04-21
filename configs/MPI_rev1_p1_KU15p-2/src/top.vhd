-- File: top.vhd
-- Auth: Dan Gastler, Boston University Physics
-- Mod.: M. Fras, Electronics Division, MPI for Physics, Munich
-- Date: 18 Dec 2020
-- Rev.: 21 Apr 2021
--
-- KU15P top VHDL file for the MPI Command Module (CM) demonstrator.
--



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use ieee.std_logic_misc.all;

use work.axiRegPkg.all;
use work.axiRegPkg_d64.all;
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
    -- Clock from clock generator IC54 (Si5341A).
    i_clk_gen_p             : in  std_logic;
    i_clk_gen_n             : in  std_logic;
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
    o_clk_lhc_rec_p         : out std_logic;
    o_clk_lhc_rec_n         : out std_logic;

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

    -- Configuration.
    constant family         : string := "kintexuplus";
    constant axi_protocol   : string := "AXI4";

    -- Clocking module.
    signal clk_100          : std_logic;
    signal clk_gen          : std_logic;
    signal clk_lhc_in       : std_logic;
    signal clk_legacy_ttc   : std_logic;
    signal clk_sma_direct   : std_logic;
    signal clk_sma_jc       : std_logic;
    signal clk_lhc_rec      : std_logic;
    signal clk_50           : std_logic;
    signal clk_200          : std_logic;
    signal clk_axi          : std_logic;
    signal clocking_reset   : std_logic;
    signal clocking_locked  : std_logic;

    -- Legacy TTC data.
    signal data_legacy_ttc  : std_logic;

    -- IBERT module.
    signal ibert_reset      : std_logic;

    -- LED signals from Cornell board. No use on MPI CM.
    signal led_blue_local   : slv_8_t;
    signal led_red_local    : slv_8_t;
    signal led_green_local  : slv_8_t;

    -- AXI signals.
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


    signal C2CLink_aurora_do_cc                : std_logic;
    signal C2CLink_axi_c2c_config_error_out    : std_logic;
    signal C2CLink_axi_c2c_link_status_out     : std_logic;
    signal C2CLink_axi_c2c_multi_bit_error_out : std_logic;
    signal C2CLink_phy_gt_pll_lock             : std_logic;
    signal C2CLink_phy_hard_err                : std_logic;
    signal C2CLink_phy_lane_up                 : std_logic_vector(0 to 0);
    signal C2CLink_phy_link_reset_out          : std_logic;
    signal C2CLink_phy_mmcm_not_locked_out     : std_logic;
    signal C2CLink_phy_soft_err                : std_logic;


    -- AXI BRAM module.
    signal BRAM_write               : std_logic;
    signal BRAM_addr                : std_logic_vector(9 downto 0);
    signal BRAM_WR_data             : std_logic_vector(31 downto 0);
    signal BRAM_RD_data             : std_logic_vector(31 downto 0);

    signal bram_rst_a               : std_logic;
    signal bram_clk_a               : std_logic;
    signal bram_en_a                : std_logic;
    signal bram_we_a                : std_logic_vector(7 downto 0);
    signal bram_addr_a              : std_logic_vector(8 downto 0);
    signal bram_wrdata_a            : std_logic_vector(63 downto 0);
    signal bram_rddata_a            : std_logic_vector(63 downto 0);

    -- Counters.
    signal rst_cnt_clk_100          : std_logic;
    signal cnt_clk_100              : std_logic_vector(31 downto 0);
    signal rst_cnt_clk_gen          : std_logic;
    signal cnt_clk_gen              : std_logic_vector(31 downto 0);
    signal rst_cnt_clk_lhc_in       : std_logic;
    signal cnt_clk_lhc_in           : std_logic_vector(31 downto 0);
    signal rst_cnt_clk_legacy_ttc   : std_logic;
    signal cnt_clk_legacy_ttc       : std_logic_vector(31 downto 0);
    signal rst_cnt_clk_sma_direct   : std_logic;
    signal cnt_clk_sma_direct       : std_logic_vector(31 downto 0);
    signal rst_cnt_clk_sma_jc       : std_logic;
    signal cnt_clk_sma_jc           : std_logic_vector(31 downto 0);
    signal rst_cnt_clk_lhc_rec      : std_logic;
    signal cnt_clk_lhc_rec          : std_logic_vector(31 downto 0);
    signal rst_cnt_clk_50           : std_logic;
    signal cnt_clk_50               : std_logic_vector(31 downto 0);
    signal rst_cnt_clk_200          : std_logic;
    signal cnt_clk_200              : std_logic_vector(31 downto 0);
    signal rst_cnt_clk_axi          : std_logic;
    signal cnt_clk_axi              : std_logic_vector(31 downto 0);

    -- User LEDs and multiplexer.
    signal user_led_axi             : std_logic_vector(31 downto 0);
    signal user_led                 : std_logic_vector(o_led'range);

    -- Debug IO tri-state buffer.
    signal dbg_se_in                : std_logic_vector(io_dbg_se'range);
    signal dbg_se_out               : std_logic_vector(io_dbg_se'range);
    signal dbg_se_dir               : std_logic_vector(io_dbg_se'range);    -- '0': read (tri-stated), '1': drive



begin  -- Architecture structure.

    -- Clocking module: Generate all clocks.
    clocking_1 : entity work.clocking
    port map (
        -- Clocks.
        -- 100 MHz system clock from crystal oscillator.
        i_clk_100_p             => i_clk_100_p,
        i_clk_100_n             => i_clk_100_n,
        o_clk_100               => clk_100,
        -- Clock from clock generator IC54 (Si5341A).
        i_clk_gen_p             => i_clk_gen_p,
        i_clk_gen_n             => i_clk_gen_n,
        o_clk_gen               => clk_gen,
        -- LHC clock from jitter cleaner IC56 (Si5345A).
        i_clk_lhc_p             => i_clk_lhc_p,
        i_clk_lhc_n             => i_clk_lhc_n,
        o_clk_lhc               => clk_lhc_in,
        -- Recovered LHC clock from clock and data recovery chip IC46 (ADN2814ACPZ).
        i_clk_legacy_ttc_p      => i_clk_legacy_ttc_p,
        i_clk_legacy_ttc_n      => i_clk_legacy_ttc_n,
        o_clk_legacy_ttc        => clk_legacy_ttc,
        -- Clock from SMA connectors X76 and X78, directly connected.
        i_clk_sma_direct_p      => i_clk_sma_direct_p,
        i_clk_sma_direct_n      => i_clk_sma_direct_n,
        o_clk_sma_direct        => clk_sma_direct,
        -- Clock from SMA connectors X68 and X69, fed through jitter cleaner IC65.
        i_clk_sma_jc_p          => i_clk_sma_jc_p,
        i_clk_sma_jc_n          => i_clk_sma_jc_n,
        o_clk_sma_jc            => clk_sma_jc,
        -- Output for recovered LHC clock, fed into jitter cleaner IC56 (Si5345A).
        i_clk_lhc_rec           => clk_lhc_rec,
        o_clk_lhc_rec_p         => o_clk_lhc_rec_p,
        o_clk_lhc_rec_n         => o_clk_lhc_rec_n,

        -- Generated clocks.
        i_reset                 => clocking_reset,
        o_locked                => clocking_locked,
        o_clk_50                => clk_50,
        o_clk_200               => clk_200,
        o_clk_axi               => clk_axi
    );
--    clk_lhc_rec <= '0';

    -- Custom IBERT module.
    ibert_1 : entity work.ibert
    port map (
        -- Clocks.
        i_clk_100               => clk_100,

        -- Reset.
        i_rst                   => ibert_reset,

        -- GTH transceivers.
        i_gth_refclk0_p         => i_gth_refclk0_p,
        i_gth_refclk0_n         => i_gth_refclk0_n,
        i_gth_refclk1_p         => i_gth_refclk1_p,
        i_gth_refclk1_n         => i_gth_refclk1_n,
        i_gth_rx_p              => i_gth_rx_p,
        i_gth_rx_n              => i_gth_rx_n,
        -- The GTH TX ports are automatically assigned by the IBERT module.
        o_gth_tx_p              => open,
        o_gth_tx_n              => open,

        -- GTY transceivers.
        i_gty_refclk0_p         => i_gty_refclk0_p,
        i_gty_refclk0_n         => i_gty_refclk0_n,
        i_gty_refclk1_p         => i_gty_refclk1_p,
        i_gty_refclk1_n         => i_gty_refclk1_n,
        i_gty_rx_p              => i_gty_rx_p,
        i_gty_rx_n              => i_gty_rx_n,
        -- The GTY TX ports are automatically assigned by the IBERT module.
        o_gty_tx_p              => open,
        o_gty_tx_n              => open,

        -- Recovered LHC clock.
        o_clk_lhc_rec           => clk_lhc_rec
    );



    -- Common AXI signals.
    AXI_CLK <= clk_axi;
    AXI_RESET <= not AXI_RST_N;

  -- AXI slave connections.
  c2cslave_wrapper_1 : entity work.c2cslave_wrapper
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
      reset_n                           => clocking_locked,--reset,
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
      K_C2C_phy_soft_err                => C2CLink_phy_soft_err);

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
      Mon.CLK_200_LOCKED      => clocking_locked,
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


  axi_bram_controller_1: entity work.axi_bram_controller
    generic map (
      USE_D64_PKG                   => 1,
      C_ADR_WIDTH                   => 32,
      C_DATA_WIDTH                  => 64,
--      C_FAMILY                      => "kintexuplus",
      C_FAMILY                      => family,
      C_MEMORY_DEPTH                => 4096,
      C_BRAM_ADDR_WIDTH             => 12,
      C_SINGLE_PORT_BRAM            => 1,
      C_S_AXI_ID_WIDTH              => 0,
--      C_S_AXI_PROTOCOL              => "AXI4",
      C_S_AXI_PROTOCOL              => axi_protocol,
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



    -- ==============================================================
    -- Test and debug features.
    -- ==============================================================

    -- Counter running with 100 MHz clock.
    rst_cnt_clk_100 <= '0';
    proc_cnt_clk_100 : process (clk_100, rst_cnt_clk_100) begin
        if (rst_cnt_clk_100 = '1') then
            cnt_clk_100 <= (others => '0');
        elsif (clk_100'event and clk_100 = '1') then
            cnt_clk_100 <= std_logic_vector(unsigned(cnt_clk_100) + 1);
        end if;
    end process;

    -- Counter running with clock from clock generator IC54 (Si5341A).
    rst_cnt_clk_gen <= '0';
    proc_cnt_clk_gen : process (clk_gen, rst_cnt_clk_gen) begin
        if (rst_cnt_clk_gen = '1') then
            cnt_clk_gen <= (others => '0');
        elsif (clk_gen'event and clk_gen = '1') then
            cnt_clk_gen <= std_logic_vector(unsigned(cnt_clk_gen) + 1);
        end if;
    end process;

    -- Counter running with LHC clock from jitter cleaner IC56 (Si5345A).
    rst_cnt_clk_lhc_in <= '0';
    proc_cnt_clk_lhc_in : process (clk_lhc_in, rst_cnt_clk_lhc_in) begin
        if (rst_cnt_clk_lhc_in = '1') then
            cnt_clk_lhc_in <= (others => '0');
        elsif (clk_lhc_in'event and clk_lhc_in = '1') then
            cnt_clk_lhc_in <= std_logic_vector(unsigned(cnt_clk_lhc_in) + 1);
        end if;
    end process;

    -- Counter running with recovered LHC clock from clock and data recovery chip IC46 (ADN2814ACPZ).
    rst_cnt_clk_legacy_ttc <= '0';
    proc_cnt_clk_legacy_ttc : process (clk_legacy_ttc, rst_cnt_clk_legacy_ttc) begin
        if (rst_cnt_clk_legacy_ttc = '1') then
            cnt_clk_legacy_ttc <= (others => '0');
        elsif (clk_legacy_ttc'event and clk_legacy_ttc = '1') then
            cnt_clk_legacy_ttc <= std_logic_vector(unsigned(cnt_clk_legacy_ttc) + 1);
        end if;
    end process;

    -- Counter running with clock from SMA connectors X76 and X78, directly connected.
    rst_cnt_clk_sma_direct <= '0';
    proc_cnt_clk_sma_direct : process (clk_sma_direct, rst_cnt_clk_sma_direct) begin
        if (rst_cnt_clk_sma_direct = '1') then
            cnt_clk_sma_direct <= (others => '0');
        elsif (clk_sma_direct'event and clk_sma_direct = '1') then
            cnt_clk_sma_direct <= std_logic_vector(unsigned(cnt_clk_sma_direct) + 1);
        end if;
    end process;

    -- Counter running with clock from SMA connectors X68 and X69, fed through jitter cleaner IC65.
    rst_cnt_clk_sma_jc <= '0';
    proc_cnt_clk_sma_jc : process (clk_sma_jc, rst_cnt_clk_sma_jc) begin
        if (rst_cnt_clk_sma_jc = '1') then
            cnt_clk_sma_jc <= (others => '0');
        elsif (clk_sma_jc'event and clk_sma_jc = '1') then
            cnt_clk_sma_jc <= std_logic_vector(unsigned(cnt_clk_sma_jc) + 1);
        end if;
    end process;

    -- Counter running with recovered LHC clock from MGT.
    rst_cnt_clk_lhc_rec <= '0';
    proc_cnt_clk_lhc_rec : process (clk_lhc_rec, rst_cnt_clk_lhc_rec) begin
        if (rst_cnt_clk_lhc_rec = '1') then
            cnt_clk_lhc_rec <= (others => '0');
        elsif (clk_lhc_rec'event and clk_lhc_rec = '1') then
            cnt_clk_lhc_rec <= std_logic_vector(unsigned(cnt_clk_lhc_rec) + 1);
        end if;
    end process;

    -- Counter running with 50 MHz clock.
    rst_cnt_clk_50 <= '0';
    proc_cnt_clk_50 : process (clk_50, rst_cnt_clk_50) begin
        if (rst_cnt_clk_50 = '1') then
            cnt_clk_50 <= (others => '0');
        elsif (clk_50'event and clk_50 = '1') then
            cnt_clk_50 <= std_logic_vector(unsigned(cnt_clk_50) + 1);
        end if;
    end process;

    -- Counter running with 200 MHz clock.
    rst_cnt_clk_200 <= '0';
    proc_cnt_clk_200 : process (clk_200, rst_cnt_clk_200) begin
        if (rst_cnt_clk_200 = '1') then
            cnt_clk_200 <= (others => '0');
        elsif (clk_200'event and clk_200 = '1') then
            cnt_clk_200 <= std_logic_vector(unsigned(cnt_clk_200) + 1);
        end if;
    end process;

    -- Counter running with AXI clock.
    rst_cnt_clk_axi <= '0';
    proc_cnt_clk_axi : process (clk_axi, rst_cnt_clk_axi) begin
        if (rst_cnt_clk_axi = '1') then
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
    proc_user_led_mux : process (user_led_axi, cnt_clk_100, cnt_clk_gen, cnt_clk_lhc_in, cnt_clk_legacy_ttc,
                                 cnt_clk_sma_direct, cnt_clk_sma_jc, cnt_clk_50, cnt_clk_200, cnt_clk_axi)
        variable v_user_led_mux_sel : std_logic_vector(7 downto 0);
        variable v_user_led_val : std_logic_vector(o_led'range);
    begin
        v_user_led_mux_sel := user_led_axi(o_led'high + v_user_led_mux_sel'high + 1 downto o_led'high + v_user_led_mux_sel'low + 1);
        v_user_led_val := user_led_axi(o_led'range);
        case v_user_led_mux_sel is
            when X"00" => user_led <= cnt_clk_100(26 downto 19);
            when X"01" => user_led <= cnt_clk_gen(26 downto 19);
            when X"02" => user_led <= cnt_clk_lhc_in(26 downto 19);
            when X"03" => user_led <= cnt_clk_legacy_ttc(26 downto 19);
            when X"04" => user_led <= cnt_clk_sma_direct(26 downto 19);
            when X"05" => user_led <= cnt_clk_sma_jc(26 downto 19);
            when X"06" => user_led <= cnt_clk_lhc_rec(26 downto 19);
            when X"07" => user_led <= cnt_clk_50(26 downto 19);
            when X"08" => user_led <= cnt_clk_200(26 downto 19);
            when X"09" => user_led <= cnt_clk_axi(26 downto 19);
            when others => user_led <= v_user_led_val;
        end case;
    end process;

    -- Assign user LED to output port.
    o_led <= user_led;

    -- Multiplexer for the debug pins.
    proc_dbg_se_mux : process (io_mcu_se, clk_gen, clk_lhc_in, clk_legacy_ttc, clk_lhc_rec, clocking_locked)
        variable v_dbg_se_mux_sel : std_logic_vector(io_mcu_se'range);
    begin
        v_dbg_se_mux_sel := io_mcu_se;
        case v_dbg_se_mux_sel is
            when X"0" =>
                dbg_se_out <= (
                    1 => clk_gen,
                    2 => clk_lhc_in,
                    3 => clk_legacy_ttc,
                    4 => clk_lhc_rec,
                    5 => clocking_locked,
                    others => '0'
                );
            when others => dbg_se_out <= (others => '0');
        end case;
    end process;

    -- Tri-state buffer for the KU15P debug header X39.
    proc_dbg_se_tri : process (io_dbg_se, dbg_se_out, dbg_se_dir)
    begin
        for i in io_dbg_se'range loop
            if dbg_se_dir(i) = '1' then
                io_dbg_se(i) <= dbg_se_out(i);
            else
                io_dbg_se(i) <= 'Z';
            end if;
            dbg_se_in(i) <= io_dbg_se(i);
        end loop;
    end process;
    -- Set the direction of all IO buffers to '1' = 'drive'.
    dbg_se_dir <= (others => '1');

end architecture structure;

