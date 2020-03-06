--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;


package K_IO_CTRL is
  type K_IO_C2C_MON_t is record
    CONFIG_ERR                 : std_logic;   
    DO_CC                      : std_logic;   
    GT_PLL_LOCK                : std_logic;   
    HARD_ERR                   : std_logic;   
    LANE_UP                    : std_logic;   
    LINK_RESET                 : std_logic;   
    LINK_STATUS                : std_logic;   
    MMCM_NOT_LOCKED            : std_logic;   
    MULTIBIT_ERR               : std_logic;   
    SOFT_ERR                   : std_logic;   
  end record K_IO_C2C_MON_t;

  type K_IO_RGB_CTRL_t is record
    B                          : std_logic_vector( 7 downto  0);
    G                          : std_logic_vector( 7 downto  0);
    R                          : std_logic_vector( 7 downto  0);
  end record K_IO_RGB_CTRL_t;

  constant DEFAULT_K_IO_RGB_CTRL_t : K_IO_RGB_CTRL_t := (
                                                         B => x"ff",
                                                         R => x"00",
                                                         G => x"00"
                                                        );
  type K_IO_BRAM_MON_t is record
    RD_DATA                    : std_logic_vector(31 downto  0);
  end record K_IO_BRAM_MON_t;

  type K_IO_BRAM_CTRL_t is record
    ADDR                       : std_logic_vector(14 downto  0);
    WRITE                      : std_logic;                     
    WR_DATA                    : std_logic_vector(31 downto  0);
  end record K_IO_BRAM_CTRL_t;

  constant DEFAULT_K_IO_BRAM_CTRL_t : K_IO_BRAM_CTRL_t := (
                                                           WRITE => '0',
                                                           ADDR => (others => '0'),
                                                           WR_DATA => (others => '0')
                                                          );
  type K_IO_MON_t is record
    BRAM                       : K_IO_BRAM_MON_t;
    C2C                        : K_IO_C2C_MON_t; 
    CLK_200_LOCKED             : std_logic;      
  end record K_IO_MON_t;

  type K_IO_CTRL_t is record
    BRAM                       : K_IO_BRAM_CTRL_t;
    RGB                        : K_IO_RGB_CTRL_t; 
  end record K_IO_CTRL_t;

  constant DEFAULT_K_IO_CTRL_t : K_IO_CTRL_t := (
                                                 RGB => DEFAULT_K_IO_RGB_CTRL_t,
                                                 BRAM => DEFAULT_K_IO_BRAM_CTRL_t
                                                );


end package K_IO_CTRL;