--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;


package FW_INFO_CTRL is
  type FW_INFO_BUILD_DATE_MON_t is record
    DAY                        : std_logic_vector( 7 downto  0);
    MONTH                      : std_logic_vector( 7 downto  0);
    YEAR                       : std_logic_vector(15 downto  0);
  end record FW_INFO_BUILD_DATE_MON_t;

  type FW_INFO_BUILD_TIME_MON_t is record
    HOUR                       : std_logic_vector( 7 downto  0);
    MIN                        : std_logic_vector( 7 downto  0);
    SEC                        : std_logic_vector( 7 downto  0);
  end record FW_INFO_BUILD_TIME_MON_t;

  type FW_INFO_MON_t is record
    BUILD_DATE                 : FW_INFO_BUILD_DATE_MON_t;      
    BUILD_TIME                 : FW_INFO_BUILD_TIME_MON_t;      
    GIT_HASH_1                 : std_logic_vector(31 downto  0);
    GIT_HASH_2                 : std_logic_vector(31 downto  0);
    GIT_HASH_3                 : std_logic_vector(31 downto  0);
    GIT_HASH_4                 : std_logic_vector(31 downto  0);
    GIT_HASH_5                 : std_logic_vector(31 downto  0);
    GIT_VALID                  : std_logic;                     
  end record FW_INFO_MON_t;



end package FW_INFO_CTRL;