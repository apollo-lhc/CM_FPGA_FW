-------------------------------------------------------------------------------
-- Pass std_logic_vector between clocks
-- Dan Gastler
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

entity pass_std_logic_vector is
  generic(
    DATA_WIDTH : integer := 32
    );
  port (
    clk_in   : in  std_logic; 
    clk_out  : in  std_logic;
    reset    : in  std_logic; --async
    pass_in  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    pass_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );

end entity pass_std_logic_vector;

architecture behavioral of pass_std_logic_vector is

  signal pass_in_local    : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  signal pass_out_local_1 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  signal pass_out_local_2 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  signal pass_out_local_3 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  
begin  -- architecture behavioral

  -- buffer the input on the input clock's domain
  buffer_clk_in: process (clk_in, reset) is
  begin  -- process buffer_clk_in
    if reset = '1' then                 -- asynchronous reset (active high)
      pass_in_local <= (others => '0');
    elsif clk_in'event and clk_in = '1' then  -- rising clock edge
      pass_in_local <= pass_in;
    end if;
  end process buffer_clk_in;

  buffer_clk_out: process (clk_out, reset) is
  begin  -- process buffer_clk_out
    if reset = '1' then                 -- asynchronous reset (active high)
      pass_out_local_1 <= (others => '0');
      pass_out_local_2 <= (others => '0');
      pass_out_local_3 <= (others => '0');
    elsif clk_out'event and clk_out = '1' then  -- rising clock edge
      pass_out_local_1 <= pass_in_local;
      pass_out_local_2 <= pass_out_local_1;
      pass_out_local_3 <= pass_out_local_2;
    end if;
  end process buffer_clk_out;

  pass_out <= pass_out_local_3;
end architecture behavioral;

