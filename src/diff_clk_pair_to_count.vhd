library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity diff_clk_pair_to_count is

    port (
          --p_clk : in std_logic;
          --n_clk : in std_logic;
          clk: in std_logic;
              clk_50 : in std_logic;
                  reset : in std_logic;
                      clk_cnt : out std_logic_vector(31 downto 0);
                          test_constant_out : out std_logic_vector(31 downto 0)
                              );

    end entity diff_clk_pair_to_count;

architecture behavioral of diff_clk_pair_to_count is

    --signal clk : std_logic;
    signal counter_clock_out : std_logic_vector(31 downto 0);

      begin

            --IBUFDS_INST : IBUFDS
              --port map (
                --O => clk,
                --I => p_clk,
                --IB => n_clk
                --);

            counter_clock_1: entity work.counter_clock
              generic map (
                DATA_WIDTH => 32)
              port map (
                clk0       => clk_50, --changed 200 to 50 and commented all things commented
                clk1       => clk,
                reset_sync => reset,
                count      => counter_clock_out
                );

            latch_measured_count: process (reset) is
              begin
                if reset = '1' then         -- asynchronous reset (active high)
                  clk_cnt <= (others => '0');
                elsif clk'event and clk = '1' then  -- rising clock edge
                  clk_cnt <= counter_clock_out;
                end if;
              end process latch_measured_count;

            test_constant_out <= X"BEEFBEEF";

end architecture behavioral;
