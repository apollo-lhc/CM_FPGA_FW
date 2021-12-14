--
-- Inferred program rom test for PicoBlaze
--
{{notes}}

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity {{baseName}} is

  port (
    address     : in  std_logic_vector({{ADDR_WIDTH}}-1 downto 0);
    instruction : out std_logic_vector(17 downto 0);
    portB_addr  : in  std_logic_vector({{ADDR_WIDTH}}-1 downto 0);
    portB_wen   : in  std_logic;                    
    portB_di    : in  std_logic_vector(17 downto 0);
    portB_do    : out std_logic_vector(17 downto 0);
    msize       : out std_logic_vector({{ADDR_WIDTH}}-1 downto 0);
    clk         : in  std_logic);

end entity {{baseName}};


architecture syn of {{baseName}} is
  -- N.B. (0 to nn) order needed otherwise data is backwards!
  type ram_type is array (0 to {{MEM_SIZE}}-1 ) of std_logic_vector(19 downto 0);
  signal RAM : ram_type := (
{{MEM_DATA}}
    );
begin

  process (clk) is
  begin  -- process
    if clk'event and clk = '1' then     -- rising clock edge
      instruction <= RAM(to_integer(unsigned(address)))(17 downto 0);
      if portB_wen = '1' then
        RAM(to_integer(unsigned(portB_addr))) <= B"00" & portB_di;
      end if;
    end if;
  end process;

  portB_do <= RAM(to_integer(unsigned(portB_addr)))(17 downto 0);

  msize <= std_logic_vector( to_unsigned( RAM'length, msize'length));

end syn;
