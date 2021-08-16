-- Single-Port Block RAM Write-First Mode (recommended template)
--
-- File: rams_sp_wf.vhd
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types.all;

entity rams_sp_wf is
  generic (
    RAM_WIDTH : integer := 8;
    RAM_DEPTH : integer := 128);
  port(
    clk : in std_logic;
    we : in std_logic;
    en : in std_logic;
    addr : in std_logic_vector(log2(RAM_DEPTH)-1 downto 0);
    di : in std_logic_vector(RAM_WIDTH-1 downto 0);
    do : out std_logic_vector(RAM_WIDTH-1 downto 0);
    do_valid : out std_logic
    );
end rams_sp_wf;
architecture syn of rams_sp_wf is
  type ram_type is array (RAM_DEPTH-1 downto 0) of std_logic_vector(RAM_WIDTH-1 downto 0);
  signal RAM : ram_type;
begin

  process(clk)
  begin
    if clk'event and clk = '1' then
      do_valid <= en;
    end if;
  end process;
    
  process(clk)
  begin
    if clk'event and clk = '1' then
      if en = '1' then
        if we = '1' then
          RAM(to_integer(unsigned(addr))) <= di;
          do <= di;
        else
          do <= RAM(to_integer(unsigned(addr)));
        end if;
      end if;
    end if;
  end process;
end syn;
