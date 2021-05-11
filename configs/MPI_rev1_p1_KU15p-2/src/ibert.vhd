-- File: ibert.vhd
-- Auth: M. Fras, Electronics Division, MPI for Physics, Munich
-- Mod.: M. Fras, Electronics Division, MPI for Physics, Munich
-- Date: 24 Mar 2021
-- Rev.: 12 Apr 2021
--
-- Xilinx IBERT modules used in the KU15P of the MPI Command Module (CM)
-- demonstrator.
--



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use ieee.std_logic_misc.all;

library UNISIM;
use UNISIM.vcomponents.all;



entity ibert is
port (
    -- Clocks.
    i_clk_100               : in  std_logic;

    -- Reset.
    i_rst                   : in  std_logic;

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

    -- Recovered LHC clock.
    o_clk_lhc_rec           : out std_logic
);
end entity ibert;



architecture structure of ibert is

    -- Reference clocks.
    -- GTH.
    signal gth_refclk0                  : std_logic_vector(i_gth_refclk0_p'range);
    signal gth_odiv2_0                  : std_logic_vector(i_gth_refclk0_p'range);
    signal gth_refclk1                  : std_logic_vector(i_gth_refclk1_p'range);
    signal gth_odiv2_1                  : std_logic_vector(i_gth_refclk1_p'range);
    -- GTY.
    signal gty_refclk0                  : std_logic_vector(i_gty_refclk0_p'range);
    signal gty_odiv2_0                  : std_logic_vector(i_gty_refclk0_p'range);
    signal gty_refclk1                  : std_logic_vector(i_gty_refclk1_p'range);
    signal gty_odiv2_1                  : std_logic_vector(i_gty_refclk1_p'range);

    -- Enable signals for IBUFDS_GTE4.
    signal IBUFDS_GTE4_gth_refclk0_CEB  : std_logic_vector(i_gth_refclk0_p'range);
    signal IBUFDS_GTE4_gth_refclk1_CEB  : std_logic_vector(i_gth_refclk1_p'range);
    signal IBUFDS_GTE4_gty_refclk0_CEB  : std_logic_vector(i_gty_refclk0_p'range);
    signal IBUFDS_GTE4_gty_refclk1_CEB  : std_logic_vector(i_gty_refclk1_p'range);

    -- Transceiver RX and TX clocks.
    signal ibert_gth_fe_rxoutclock      : std_logic_vector(35 downto 0);
    signal ibert_gth_fe_txoutclock      : std_logic_vector(35 downto 0);
    signal ibert_gty_felix_rxoutclock   : std_logic_vector(11 downto 0);
    signal ibert_gty_felix_txoutclock   : std_logic_vector(11 downto 0);



begin  -- Architecture structure.

    -- Reference clock buffers.
    -- GTH.
    gen_IBUFDS_GTE4_gth_refclk0 : for i in i_gth_refclk0_p'range generate
        IBUFDS_GTE4_gth_refclk0 : IBUFDS_GTE4
        port map (
            O       => gth_refclk0(i),
            ODIV2   => gth_odiv2_0(i),
            CEB     => IBUFDS_GTE4_gth_refclk0_CEB(i),
            I       => i_gth_refclk0_p(i),
            IB      => i_gth_refclk0_n(i)
        );
        IBUFDS_GTE4_gth_refclk0_CEB(i) <= '0';
    end generate gen_IBUFDS_GTE4_gth_refclk0;

    gen_IBUFDS_GTE4_gth_refclk1 : for i in i_gth_refclk1_p'range generate
        IBUFDS_GTE4_gth_refclk1 : IBUFDS_GTE4
        port map (
            O       => gth_refclk1(i),
            ODIV2   => gth_odiv2_1(i),
            CEB     => IBUFDS_GTE4_gth_refclk1_CEB(i),
            I       => i_gth_refclk1_p(i),
            IB      => i_gth_refclk1_n(i)
        );
        IBUFDS_GTE4_gth_refclk1_CEB(i) <= '0';
    end generate gen_IBUFDS_GTE4_gth_refclk1;

    -- GTY.
    gen_IBUFDS_GTE4_gty_refclk0 : for i in i_gty_refclk0_p'range generate
        IBUFDS_GTE4_gty_refclk0 : IBUFDS_GTE4
        port map (
            O       => gty_refclk0(i),
            ODIV2   => gty_odiv2_0(i),
            CEB     => IBUFDS_GTE4_gty_refclk0_CEB(i),
            I       => i_gty_refclk0_p(i),
            IB      => i_gty_refclk0_n(i)
        );
        IBUFDS_GTE4_gty_refclk0_CEB(i) <= '0';
    end generate gen_IBUFDS_GTE4_gty_refclk0;

    gen_IBUFDS_GTE4_gty_refclk1 : for i in i_gty_refclk1_p'range generate
        IBUFDS_GTE4_gty_refclk1 : IBUFDS_GTE4
        port map (
            O       => gty_refclk1(i),
            ODIV2   => gty_odiv2_1(i),
            CEB     => '0',
            I       => i_gty_refclk1_p(i),
            IB      => i_gty_refclk1_n(i)
        );
        IBUFDS_GTE4_gty_refclk1_CEB(i) <= '0';
    end generate gen_IBUFDS_GTE4_gty_refclk1;



    -- IBERT for front-end (FE) links:
    -- GTH quads on MGT banks 226.. 228 => CM FireFly 3.
    -- GTH quads on MGT banks 229.. 231 => CM FireFly 4.
    -- GTH quads on MGT banks 232.. 234 => CM FireFly 5.
    ibert_gth_fe_1 : entity work.ibert_gth_fe
    port map (
        txn_o               => o_gth_tx_n(43 downto 8),
        txp_o               => o_gth_tx_p(43 downto 8),
        rxoutclk_o          => ibert_gth_fe_rxoutclock,
        txoutclk_o          => ibert_gth_fe_txoutclock,
        rxn_i               => i_gth_rx_n(43 downto 8),
        rxp_i               => i_gth_rx_p(43 downto 8),
        gtrefclk0_i         => gth_refclk0(10 downto 2),
        gtrefclk1_i         => gth_refclk1(10 downto 2),
        gtnorthrefclk0_i    => "000000000",
        gtnorthrefclk1_i    => "000000000",
        gtsouthrefclk0_i    => "000000000",
        gtsouthrefclk1_i    => "000000000",
        gtrefclk00_i        => gth_refclk0(10 downto 2),
        gtrefclk10_i        => gth_refclk1(10 downto 2),
        gtrefclk01_i        => gth_refclk0(10 downto 2),
        gtrefclk11_i        => gth_refclk1(10 downto 2),
        gtnorthrefclk00_i   => "000000000",
        gtnorthrefclk10_i   => "000000000",
        gtnorthrefclk01_i   => "000000000",
        gtnorthrefclk11_i   => "000000000",
        gtsouthrefclk00_i   => "000000000",
        gtsouthrefclk10_i   => "000000000",
        gtsouthrefclk01_i   => "000000000",
        gtsouthrefclk11_i   => "000000000",
        clk                 => i_clk_100
    );

    -- IBERT for FELIX links:
    -- GTY quads on MGT banks 132..134 => CM FireFly 1.
    ibert_gty_felix_1 : entity work.ibert_gty_felix
    port map (
        txn_o               => o_gty_tx_n(31 downto 20),
        txp_o               => o_gty_tx_p(31 downto 20),
        rxoutclk_o          => ibert_gty_felix_rxoutclock,
        txoutclk_o          => ibert_gty_felix_txoutclock,
        rxn_i               => i_gty_rx_n(31 downto 20),
        rxp_i               => i_gty_rx_p(31 downto 20),
        gtrefclk0_i         => gty_refclk0(7 downto 5),
        gtrefclk1_i         => gty_refclk1(7 downto 5),
        gtnorthrefclk0_i    => "000",
        gtnorthrefclk1_i    => "000",
        gtsouthrefclk0_i    => "000",
        gtsouthrefclk1_i    => "000",
        gtrefclk00_i        => gty_refclk0(7 downto 5),
        gtrefclk10_i        => gty_refclk1(7 downto 5),
        gtrefclk01_i        => gty_refclk0(7 downto 5),
        gtrefclk11_i        => gty_refclk1(7 downto 5),
        gtnorthrefclk00_i   => "000",
        gtnorthrefclk10_i   => "000",
        gtnorthrefclk01_i   => "000",
        gtnorthrefclk11_i   => "000",
        gtsouthrefclk00_i   => "000",
        gtsouthrefclk10_i   => "000",
        gtsouthrefclk01_i   => "000",
        gtsouthrefclk11_i   => "000",
        clk                 => i_clk_100
    );

    -- Use the last GTY from the FELIX IBERT module as recovered LHC clock source.
    o_clk_lhc_rec <= ibert_gty_felix_rxoutclock(11);

end architecture structure;

