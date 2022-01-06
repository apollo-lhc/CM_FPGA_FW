--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;


package V_IO_CTRL is
  type V_IO_RGB_CTRL_t is record
    R                          :std_logic_vector( 7 downto 0);
    G                          :std_logic_vector( 7 downto 0);
    B                          :std_logic_vector( 7 downto 0);
  end record V_IO_RGB_CTRL_t;


  constant DEFAULT_V_IO_RGB_CTRL_t : V_IO_RGB_CTRL_t := (
                                                         R => x"00",
                                                         G => x"00",
                                                         B => x"ff"
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