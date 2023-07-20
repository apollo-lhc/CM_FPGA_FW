library ieee;

use ieee.std_logic_1164.all;

use ieee.std_logic_unsigned.all;

use ieee.numeric_std.all;

library UNISIM;

use UNISIM.VCOMPONENTS.ALL;

library work;
use work.my_package.all;


entity core is
    port (
        clock200        : in    std_logic;
        reset           : in    std_logic;
        SCL             : in    std_logic;
        SDA             : in    std_logic;
        SDA_Z_en        : out   std_logic;

        clocks          : in    std_logic_vector (63 downto 0);
        clk_50          : in    std_logic;
        clk_in_tc       : in    std_logic;
        clk_out_tc      : in    std_logic
    );
end core;

architecture rtl of core is
    signal rates : array_64xreg32;
    signal clk50_rate : reg32;
    signal clk_in_tc_rate : reg32;
    signal clk_out_tc_rate : reg32;
begin

    monitors_gen: for i in 0 to 63 generate
    monitor_inst: entity work.rate_counter
    generic map (
        CLK_A_1_SECOND => 200000000 --200MHz
    )
    port map (
        clk_A   => clock200,
        clk_B   => clocks(i),
        reset_A_async => reset,
        event_b => '1',
        rate    => rates(i)
    );
    
    end generate;

clk_in_tc_inst: entity work.rate_counter
    generic map (
        CLK_A_1_SECOND => 200000000 --200MHz
    )
    port map (
        clk_A   => clock200,
        clk_B   => clk_in_tc,
        reset_A_async => reset,
        event_b => '1',
        rate    => clk_in_tc_rate
    );

axi_clk_rate_inst: entity work.rate_counter
    generic map (
        CLK_A_1_SECOND => 200000000 --200MHz
    )
    port map (
        clk_A   => clock200,
        clk_B   => clk_50,
        reset_A_async => reset,
        event_b => '1',
        rate    => clk50_rate
    );

clk_out_tc_inst: entity work.rate_counter
    generic map (
        CLK_A_1_SECOND => 200000000 --200MHz
    )
    port map (
        clk_A   => clock200,
        clk_B   => clk_out_tc,
        reset_A_async => reset,
        event_b => '1',
        rate    => clk_out_tc_rate
    );

    I2C: entity work.I2C
    port map (
        clock200             => clock200,
        reset                => reset,
        SCL                  => SCL,
        SDA                  => SDA,
        SDA_Z_en             => SDA_Z_en,
        rates                => rates,
        clk_in_tc_rate       => clk_in_tc_rate,
        clk_out_tc_rate      => rates(1),
        clk_50_rate          => clk50_rate,
        led_out              => open
    );
end architecture;