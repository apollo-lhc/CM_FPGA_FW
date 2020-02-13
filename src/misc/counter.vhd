-------------------------------------------------------------------------------
-- Generic counter
-- Dan Gastler
-- Process count pulses and provide a buffered value of count
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;


entity counter is

  generic (
    roll_over   : std_logic        := '1';
    end_value   : std_logic_vector(31 downto  0) := x"FFFFFFFF";
    start_value : std_logic_vector(31 downto  0) := x"00000000";
    DATA_WIDTH  : integer          := 32);
  port (
    clk         : in  std_logic;
    reset_async : in  std_logic;
    reset_sync  : in  std_logic;
    enable      : in  std_logic;
    event       : in  std_logic;
    count       : out std_logic_vector(DATA_WIDTH-1 downto 0);
    at_max      : out std_logic
    );

end entity counter;

architecture behavioral of counter is

  constant max_count : unsigned(DATA_WIDTH-1 downto 0) := unsigned(end_value(DATA_WIDTH-1 downto 0));
  constant min_count : unsigned(DATA_WIDTH-1 downto 0) := unsigned(start_value(DATA_WIDTH-1 downto 0));
  signal local_count : unsigned(DATA_WIDTH-1 downto 0) := min_count;

begin  -- architecture behavioral

  event_counter : process (clk, reset_async)
  begin  -- process malformed_counter
    if reset_async = '1' then           -- asynchronous reset (active high)
      local_count <= min_count;
      count       <= std_logic_vector(min_count);
    elsif clk'event and clk = '1' then  -- rising clock edge
      if reset_sync = '1' then
        -- synchronous reset
        local_count <= min_count;
        count       <= std_logic_vector(min_count);
      else
        --output current counter;
--        count <= local_count;
        count <= std_logic_vector(local_count);

        -- count
        if enable = '1' and event = '1' then
          if local_count = max_count then
            --roll over if requested
            if roll_over = '1' then
              local_count <= min_count;
            end if;
          else
            local_count <= local_count + 1;
          end if;
        end if;
      end if;
    end if;
  end process event_counter;

  check_at_max : process (clk, reset_async) is
  begin  -- process check_at_max
    if reset_async = '1' then           -- asynchronous reset (active high)
      at_max <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if reset_sync = '1' then
        -- synchronous reset
        at_max      <= '0';
      else
        -- reset at_max
        at_max <= '0';
        if local_count = max_count then
          at_max <= '1';
        end if;

      end if;
    end if;
  end process check_at_max;

end architecture behavioral;

