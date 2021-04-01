----------------------------------------------------------------------------------
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package types is

  
  subtype slv_2_t is std_logic_vector(1 downto 0);
  subtype slv_3_t is std_logic_vector(2 downto 0);
  subtype slv_4_t is std_logic_vector(3 downto 0);
  subtype slv_7_t is std_logic_vector(6 downto 0);
  subtype slv_8_t is std_logic_vector(7 downto 0);
  subtype slv_12_t is std_logic_vector(11 downto 0);
  subtype slv_16_t is std_logic_vector(15 downto 0);
  subtype slv_26_t is std_logic_vector(25 downto 0);
  subtype slv_32_t is std_logic_vector(31 downto 0);
  subtype slv_64_t is std_logic_vector(63 downto 0);
  
  type slv4_array_t   is array (integer range <>) of std_logic_vector(  3 downto 0);
  type slv7_array_t   is array (integer range <>) of std_logic_vector(  6 downto 0);
  type slv8_array_t   is array (integer range <>) of std_logic_vector(  7 downto 0);
  type slv12_array_t  is array (integer range <>) of std_logic_vector( 11 downto 0);
  type slv16_array_t  is array (integer range <>) of std_logic_vector( 15 downto 0);
  type slv20_array_t  is array (integer range <>) of std_logic_vector( 19 downto 0);
  type slv24_array_t  is array (integer range <>) of std_logic_vector( 23 downto 0);
  type slv32_array_t  is array (integer range <>) of std_logic_vector( 31 downto 0);
  type slv36_array_t  is array (integer range <>) of std_logic_vector( 35 downto 0);
  type slv48_array_t  is array (integer range <>) of std_logic_vector( 47 downto 0);
  type slv64_array_t  is array (integer range <>) of std_logic_vector( 63 downto 0);
  type slv128_array_t is array (integer range <>) of std_logic_vector(127 downto 0);

  subtype uint32_t is unsigned(31 downto 0);
  subtype uint26_t is unsigned(25 downto 0);
  subtype uint27_t is unsigned(26 downto 0);

  type u16_array_t is array (integer range <>) of unsigned(47 downto 0);

end package types;

              
