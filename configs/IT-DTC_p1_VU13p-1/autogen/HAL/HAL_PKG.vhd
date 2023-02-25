library IEEE;
use IEEE.std_logic_1164.all;

package HAL_PKG is
type HAL_refclks_t is record
     refclk_126_clk0_P : std_logic;
     refclk_126_clk0_N : std_logic;
end record HAL_refclks_t;
type HAL_serdes_input_t is record
  QUAD_GTH_125_DEBUG_8B10B_gtyrxn : std_logic_vector(3 downto 0);
  QUAD_GTH_125_DEBUG_8B10B_gtyrxp : std_logic_vector(3 downto 0);
  QUAD_GTH_126_DEBUG_8B10B_gtyrxn : std_logic_vector(3 downto 0);
  QUAD_GTH_126_DEBUG_8B10B_gtyrxp : std_logic_vector(3 downto 0);
  QUAD_GTH_127_DEBUG_8B10B_gtyrxn : std_logic_vector(3 downto 0);
  QUAD_GTH_127_DEBUG_8B10B_gtyrxp : std_logic_vector(3 downto 0);
end record HAL_serdes_input_t;
type HAL_serdes_output_t is record
  QUAD_GTH_125_DEBUG_8B10B_gtytxn : std_logic_vector(3 downto 0);
  QUAD_GTH_125_DEBUG_8B10B_gtytxp : std_logic_vector(3 downto 0);
  QUAD_GTH_126_DEBUG_8B10B_gtytxn : std_logic_vector(3 downto 0);
  QUAD_GTH_126_DEBUG_8B10B_gtytxp : std_logic_vector(3 downto 0);
  QUAD_GTH_127_DEBUG_8B10B_gtytxn : std_logic_vector(3 downto 0);
  QUAD_GTH_127_DEBUG_8B10B_gtytxp : std_logic_vector(3 downto 0);
end record HAL_serdes_output_t;
end package HAL_PKG;
