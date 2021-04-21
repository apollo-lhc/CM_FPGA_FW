-- File: clocking.vhd
-- Auth: M. Fras, Electronics Division, MPI for Physics, Munich
-- Mod.: M. Fras, Electronics Division, MPI for Physics, Munich
-- Date: 24 Mar 2021
-- Rev.: 20 Apr 2021
--
-- Clock buffers and clocking wizards used in the KU15P of the MPI Command
-- Module (CM) demonstrator.
--



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use ieee.std_logic_misc.all;

library UNISIM;
use UNISIM.vcomponents.all;



entity clocking is
port (
    -- Clocks.
    -- 100 MHz system clock from crystal oscillator.
    i_clk_100_p             : in  std_logic;
    i_clk_100_n             : in  std_logic;
    o_clk_100               : out std_logic;
    -- Clock from clock generator IC54 (SI5341A).
    i_clk_gen_p             : in  std_logic;
    i_clk_gen_n             : in  std_logic;
    o_clk_gen               : out std_logic;
    -- LHC clock from jitter cleaner IC56 (Si5345A).
    i_clk_lhc_p             : in  std_logic;
    i_clk_lhc_n             : in  std_logic;
    o_clk_lhc               : out std_logic;
    -- Recovered LHC clock from clock and data recovery chip IC46 (ADN2814ACPZ).
    i_clk_legacy_ttc_p      : in  std_logic;
    i_clk_legacy_ttc_n      : in  std_logic;
    o_clk_legacy_ttc        : out std_logic;
    -- Clock from SMA connectors X76 and X78, directly connected.
    i_clk_sma_direct_p      : in  std_logic;
    i_clk_sma_direct_n      : in  std_logic;
    o_clk_sma_direct        : out std_logic;
    -- Clock from SMA connectors X68 and X69, fed through jitter cleaner IC65.
    i_clk_sma_jc_p          : in  std_logic;
    i_clk_sma_jc_n          : in  std_logic;
    o_clk_sma_jc            : out std_logic;
    -- Output for recovered LHC clock, fed into jitter cleaner IC56 (Si5345A).
    i_clk_lhc_rec           : in  std_logic;
    o_clk_lhc_rec_p         : out std_logic;
    o_clk_lhc_rec_n         : out std_logic;

    -- Generated clocks.
    i_reset                 : in  std_logic;
    o_locked                : out std_logic;
    o_clk_50                : out std_logic;
    o_clk_200               : out std_logic;
    o_clk_axi               : out std_logic
);
end entity clocking;



architecture structure of clocking is

    -- Clocks.
    signal clk_100_ibufgds          : std_logic;
    signal clk_100_bufg             : std_logic;
    signal clk_gen_ibufgds          : std_logic;
    signal clk_gen_bufg             : std_logic;
    signal clk_lhc_ibufgds          : std_logic;
    signal clk_lhc_bufg             : std_logic;
    signal clk_legacy_ttc_ibufgds   : std_logic;
    signal clk_legacy_ttc_bufg      : std_logic;
    signal clk_sma_direct_ibufgds   : std_logic;
    signal clk_sma_direct_bufg      : std_logic;
    signal clk_sma_jc_ibufgds       : std_logic;
    signal clk_sma_jc_bufg          : std_logic;

    -- Clocking wizard: Local clocking.
    signal clkwiz_lc_clk_200        : std_logic;
    signal clkwiz_lc_clk_50         : std_logic;
    signal clkwiz_lc_clk_axi        : std_logic;
    signal clkwiz_lc_reset          : std_logic;
    signal clkwiz_lc_locked         : std_logic;



begin  -- Architecture structure.

    -- Clocking.
    -- 100 MHz system clock from crystal oscillator.
    IBUFGDS_clk_100 : IBUFGDS
    port map (
        I   => i_clk_100_p,
        IB  => i_clk_100_n,
        O   => clk_100_ibufgds
    );
    BUFG_clk_100 : BUFG
    port map (
        I => clk_100_ibufgds,
        O => clk_100_bufg
    );
    o_clk_100 <= clk_100_bufg;
    -- Clock from clock generator IC54 (SI5341A).
    IBUFGDS_clk_gen : IBUFGDS
    port map (
        I   => i_clk_gen_p,
        IB  => i_clk_gen_n,
        O   => clk_gen_ibufgds
    );
    BUFG_clk_gen : BUFG
    port map (
        I => clk_gen_ibufgds,
        O => clk_gen_bufg
    );
    o_clk_gen <= clk_gen_bufg;
    -- LHC clock from jitter cleaner IC56 (Si5345A).
    IBUFGDS_clk_lhc : IBUFGDS
    port map (
        I   => i_clk_lhc_p,
        IB  => i_clk_lhc_n,
        O   => clk_lhc_ibufgds
    );
    BUFG_clk_lhc : BUFG
    port map (
        I => clk_lhc_ibufgds,
        O => clk_lhc_bufg
    );
    o_clk_lhc <= clk_lhc_bufg;
    -- Recovered LHC clock from clock and data recovery chip IC46 (ADN2814ACPZ).
    IBUFGDS_clk_legacy_ttc : IBUFGDS
    port map (
        I   => i_clk_legacy_ttc_p,
        IB  => i_clk_legacy_ttc_n,
        O   => clk_legacy_ttc_ibufgds
    );
    BUFG_clk_legacy_ttc : BUFG
    port map (
        I => clk_legacy_ttc_ibufgds,
        O => clk_legacy_ttc_bufg
    );
    o_clk_legacy_ttc <= clk_legacy_ttc_bufg;
    -- Clock from SMA connectors X76 and X78, directly connected.
    IBUFGDS_clk_sma_direct : IBUFGDS
    port map (
        I   => i_clk_sma_direct_p,
        IB  => i_clk_sma_direct_n,
        O   => clk_sma_direct_ibufgds
    );
    BUFG_clk_sma_direct : BUFG
    port map (
        I => clk_sma_direct_ibufgds,
        O => clk_sma_direct_bufg
    );
    o_clk_sma_direct <= clk_sma_direct_bufg;
    -- Clock from SMA connectors X68 and X69, fed through jitter cleaner IC65.
    IBUFGDS_clk_sma_jc : IBUFGDS
    port map (
        I   => i_clk_sma_jc_p,
        IB  => i_clk_sma_jc_n,
        O   => clk_sma_jc_ibufgds
    );
    BUFG_clk_sma_jc : BUFG
    port map (
        I => clk_sma_jc_ibufgds,
        O => clk_sma_jc_bufg
    );
    o_clk_sma_jc <= clk_sma_jc_bufg;
    -- Output for recovered LHC clock, fed into jitter cleaner IC56 (Si5345A).
    OBUFDS_clk_lhc_rec : OBUFDS
    port map (
        I   => i_clk_lhc_rec,
        O   => o_clk_lhc_rec_p,
        OB  => o_clk_lhc_rec_n
    );

    -- Clocking wizard: Local clock.
    Local_Clocking_1 : entity work.Local_Clocking
    port map (
        -- Clock out ports.
        clk_200   => clkwiz_lc_clk_200,
        clk_50    => clkwiz_lc_clk_50,
        clk_axi   => clkwiz_lc_clk_axi,
        -- Status and control signals.
        reset     => clkwiz_lc_reset,
        locked    => clkwiz_lc_locked,
        -- Clock in ports.
        clk_in1   => clk_100_bufg
    );
    -- Assign signals from inputs and to outputs.
    clkwiz_lc_reset <= i_reset;
    o_locked        <= clkwiz_lc_locked;
    o_clk_50        <= clkwiz_lc_clk_50;
    o_clk_200       <= clkwiz_lc_clk_200;
    o_clk_axi       <= clkwiz_lc_clk_axi;

end architecture structure;

