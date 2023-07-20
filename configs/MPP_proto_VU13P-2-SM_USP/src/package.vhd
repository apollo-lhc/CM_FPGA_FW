library IEEE;

use IEEE.STD_LOGIC_1164.ALL;

use ieee.numeric_std.all;

use ieee.std_logic_unsigned.all;

package my_package is

    subtype reg32 is std_logic_vector(31 downto 0);
    type array_64xreg32  is array (0 to 63)  of reg32;


end my_package;