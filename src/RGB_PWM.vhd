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

entity RGB_pwm is
    Generic (CLKFREQ    : integer := 100000000;     --input clk frequency in hz
             RGBFREQ    : integer := 1000);    --desired RGB frequency in hz
    Port    (clk        : in std_logic;
             redcount   : in std_logic_vector(7 downto 0);
             greencount : in std_logic_vector(7 downto 0);
             bluecount  : in std_logic_vector(7 downto 0);
             LEDred     : out std_logic;
             LEDgreen   : out std_logic;
             LEDblue    : out std_logic);          
end RGB_pwm;

architecture Behavioral of RGB_pwm is

--Declare LED_pwm
component LED_pwm is
    port    (clk        : in std_logic;
             enable     : in std_logic;
             number     : in std_logic_vector(7 downto 0);
             pulseout   : out std_logic);
end component;

--signals 
signal enable   : std_logic; --used to modify timing of LED_pwm
--Constants for timing
constant count_to   : integer := CLKFREQ / (RGBFREQ*256); --256 for the possible
                                                      --PWM values
--counters
signal count    : integer range 1 to count_to;

begin

--Process for generating enable signal
EN  : process (clk)
begin
    if clk'event and clk='1' then
        if count = count_to then
            enable <= '1';
            count <= 1;
        else
            count <= count + 1;
            enable <= '0';
        end if;
    end if;  
end process EN;

--LED_pwm for each color Red, Green, & Blue

r1  :   LED_pwm
    port map    (clk => clk,
                 enable => enable,
                 number => redcount,
                 pulseout => LEDred);
                 
g1  :   LED_pwm
    port map    (clk => clk,
                 enable => enable,
                 number => greencount,
                 pulseout => LEDgreen);
                 
b1  :   LED_pwm
    port map    (clk => clk,
                 enable => enable,
                 number => bluecount,
                 pulseout => LEDblue);
     
end Behavioral;
