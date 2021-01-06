--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;


package V_IO_CTRL is
  type V_IO_C2C_MON_t is record
    SOFT_ERR                   :std_logic;   
    MMCM_NOT_LOCKED            :std_logic;   
    LINK_RESET                 :std_logic;   
    LANE_UP                    :std_logic;   
    HARD_ERR                   :std_logic;   
    GT_PLL_LOCK                :std_logic;   
    MULTIBIT_ERR               :std_logic;   
    LINK_STATUS                :std_logic;   
    CONFIG_ERR                 :std_logic;   
    DO_CC                      :std_logic;   
  end record V_IO_C2C_MON_t;


  type V_IO_RGB_CTRL_t is record
    R                          :std_logic_vector( 7 downto 0);
    G                          :std_logic_vector( 7 downto 0);
    B                          :std_logic_vector( 7 downto 0);
  end record V_IO_RGB_CTRL_t;


  constant DEFAULT_V_IO_RGB_CTRL_t : V_IO_RGB_CTRL_t := (
                                                         B => x"ff",
                                                         R => x"00",
                                                         G => x"00"
                                                        );
  type V_IO_BRAM_MON_t is record
    RD_DATA                    :std_logic_vector(31 downto 0);
  end record V_IO_BRAM_MON_t;


  type V_IO_BRAM_CTRL_t is record
    WRITE                      :std_logic;   
    ADDR                       :std_logic_vector(14 downto 0);
    WR_DATA                    :std_logic_vector(31 downto 0);
  end record V_IO_BRAM_CTRL_t;


  constant DEFAULT_V_IO_BRAM_CTRL_t : V_IO_BRAM_CTRL_t := (
                                                           WRITE => '0',
                                                           ADDR => (others => '0'),
                                                           WR_DATA => (others => '0')
                                                          );
  type V_IO_MON_t is record
    C2C                        :V_IO_C2C_MON_t;
    CLK_200_LOCKED             :std_logic;     
    BRAM                       :V_IO_BRAM_MON_t;
  end record V_IO_MON_t;


  type V_IO_CTRL_t is record
    RGB                        :V_IO_RGB_CTRL_t;
    BRAM                       :V_IO_BRAM_CTRL_t;
  end record V_IO_CTRL_t;


  constant DEFAULT_V_IO_CTRL_t : V_IO_CTRL_t := (
                                                 RGB => DEFAULT_V_IO_RGB_CTRL_t,
                                                 BRAM => DEFAULT_V_IO_BRAM_CTRL_t
                                                );


end package V_IO_CTRL;