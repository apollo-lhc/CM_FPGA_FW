----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/16/2019 01:47:45 PM
-- Design Name: 
-- Module Name: RGBcontroller - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity LED_pwm is
  Port    (clk        : in std_logic;             --clk in
           enable     : in std_logic;             --enable
           number     : in std_logic_vector(7 downto 0);  --numeric value for how often light is on
           pulseout   : out std_logic);           --pulsed output
end LED_pwm;

architecture Behavioral of LED_pwm is

--Counters
  signal   count  : unsigned (7 downto 0);
  signal count_to : unsigned(7 downto 0);
  constant count_start : unsigned(7 downto 0) := to_unsigned(0,8);

begin

  count_to <= unsigned(number);
  comparator : process (clk)
  begin
    if clk'event and clk='1' then
      if enable = '1' then
        count <= count + 1;
        if count = count_to then
          pulseout <= '0';
        elsif count = count_start then
          pulseout <= '1';
        end if;      
      end if;
    end if;
  end process comparator;
  
end Behavioral;
