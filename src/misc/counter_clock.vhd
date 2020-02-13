-------------------------------------------------------------------------------
-- Counter to compare clk1 against clk0
-- Dan Gastler, Rui Zou
-- Count number of clock cycles of clk1 in 0xBEBC200 cycles of clk0 (i.e. 1 second
-- when clk0 is 200 MHz)
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;


entity counter_clock is

  generic (
    end_value   : std_logic_vector(31 downto  0) := x"FFFFFFFF";
    start_value : std_logic_vector(31 downto  0) := x"00000000";
    DATA_WIDTH  : integer          := 32);
  port (
    clk0        : in  std_logic;
    clk1        : in std_logic;
    reset_sync  : in  std_logic;
    count       : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );

end entity counter_clock;

architecture behavioral of counter_clock is

  constant max_count_clk0 : unsigned(DATA_WIDTH-1 downto 0) := to_unsigned(200000000,DATA_WIDTH);--0X"0BEBC200"
  constant max_count_clk1 : unsigned(DATA_WIDTH-1 downto 0) := unsigned(end_value(DATA_WIDTH-1 downto 0));
  constant min_count : unsigned(DATA_WIDTH-1 downto 0) := unsigned(start_value(DATA_WIDTH-1 downto 0));
  signal local_count_clk0 : unsigned(DATA_WIDTH-1 downto 0) := min_count;
  signal local_count_clk1 : unsigned(DATA_WIDTH-1 downto 0) := min_count;
  signal local_count_clk1_reg : unsigned(DATA_WIDTH-1 downto 0) := min_count;
  signal reset1 : std_logic;
begin  -- architecture behavioral

  event_counter0 : process (clk0)
  begin  -- process malformed_counter
    if clk0'event and clk0 = '1' then  -- rising clock edge
      if reset_sync = '1' then
        -- synchronous reset
        local_count_clk0 <= min_count;
        reset1 <= '0';
      else
        if local_count_clk0 = max_count_clk0 then
        -- count clk0
          local_count_clk0 <= min_count;
          reset1 <= '1';
        else
          local_count_clk0 <= local_count_clk0 + 1;
          reset1 <= '0';
        end if;
      end if;
    end if;
  end process event_counter0;

  event_counter1 : process (clk1,reset1)
  begin
    if reset1 = '1' then
      count <= std_logic_vector(local_count_clk1_reg);
      local_count_clk1 <= min_count;
    elsif clk1'event and clk1 = '1' then
      if reset_sync = '1' then
        local_count_clk1 <= min_count;
      else
        if local_count_clk1 = max_count_clk1 then
          local_count_clk1 <= min_count;
        else
          local_count_clk1 <= local_count_clk1 + 1;
        end if;
      end if;
      local_count_clk1_reg <= local_count_clk1;
    end if;
  end process event_counter1;

end architecture behavioral;

