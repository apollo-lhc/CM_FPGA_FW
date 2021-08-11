library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity capture_CDC is
  
  generic (
    WIDTH : integer := 16);
  port (
    clkA             : in  std_logic;
    resetA           : in  std_logic;
    clkB             : in  std_logic;
    resetB           : in  std_logic;
    capture_pulseA   : in  std_logic;
    outA             : out std_logic_vector(WIDTH-1 downto 0);
    outA_valid       : out std_logic;
    capture_pulseB   : out std_logic;
    inB              : in std_logic_vector(WIDTH-1 downto 0);
    inB_valid        : in std_logic
    );
end entity capture_CDC;


architecture behavioral of capture_CDC is

  component pacd is
    port (
      iPulseA : IN  std_logic;
      iClkA   : IN  std_logic;
      iRSTAn  : IN  std_logic;
      iClkB   : IN  std_logic;
      iRSTBn  : IN  std_logic;
      oPulseB : OUT std_logic);
  end component pacd;

  --- clkA
  signal local_outA_valid : std_logic;
  signal local_validA     : std_logic;
  -- clkB
  signal local_capture_pulseB   : std_logic;
  signal local_validB     : std_logic;
  signal wait_for_B_valid : std_logic;
  -- both
  signal local_data : std_logic_vector(WIDTH-1 downto 0);

  
begin  -- architecture behavioral
  capture_pulseB <= local_capture_pulseB;
  --pass a pulse from A to B for capture
  pacd_1: entity work.pacd
    port map (
      iPulseA => capture_pulseA,
      iClkA   => clkA,
      iRSTA   => resetA,--'1',
      iClkB   => clkB,
      iRSTB   => resetB, --'1',
      oPulseB => local_capture_pulseB);

  outA_valid <= local_outA_valid when resetA = '0' else '0';
  capture: process (clkA,capture_pulseA,resetA) is
  begin  -- process capture
    if capture_pulseA = '1' or resetA = '1' then
      --set outputA to be invalid
      local_outA_valid <= '0';
    elsif clkA'event and clkA = '1' then  -- rising clock edge
      --wait for the data from B to be valid (via PACD)
      if local_validA = '1' then
        -- latch the data and set it valid
        local_outA_valid <= '1';
        outA <= local_data;
      end if;      
    end if;
  end process capture;

  --Pass the data valid pulse from B to A
  pacd_2: entity work.pacd
    port map (
      iPulseA => local_validB,
      iClkA   => clkB,
      iRSTA   => resetB, --'1',
      iClkB   => clkA,
      iRSTB   => resetA,--'1',
      oPulseB => local_validA);

  
  display: process (clkB,resetB) is
  begin  -- process display
    if resetB = '1' then
      wait_for_B_valid <= '0';      
    elsif clkB'event and clkB = '1' then  -- rising clock edge
      --enforce a validB pulse is a pulse
      local_validB <= '0';

      --Wait for a capture_pulse from A (via PACD)
      if local_capture_pulseB = '1' then
        if inB_Valid = '1' then
          --The B data is already valid, pass it
          local_data <= inB;
          local_validB <= '1';
          wait_for_B_valid <=  '0';
        else
          --The B data isn't valid yet, wait for it
          wait_for_B_valid <= '1';
        end if;     
      end if;

      if wait_for_B_valid = '1' then
        --we are waiting for b data to be valid
        if inB_Valid = '1' then
          --b data is now valid
          local_data <= inB;
          local_validB <= '1';
          wait_for_B_valid <= '0';
        end if;
      end if;
    end if;
  end process display;

end architecture behavioral;
