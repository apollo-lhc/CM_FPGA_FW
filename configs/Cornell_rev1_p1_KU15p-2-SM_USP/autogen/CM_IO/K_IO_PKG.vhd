--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;


package K_IO_CTRL is
  type K_IO_RGB_CTRL_t is record
    R                          :std_logic_vector( 7 downto 0);
    G                          :std_logic_vector( 7 downto 0);
    B                          :std_logic_vector( 7 downto 0);
  end record K_IO_RGB_CTRL_t;


  constant DEFAULT_K_IO_RGB_CTRL_t : K_IO_RGB_CTRL_t := (
                                                         R => x"00",
                                                         G => x"00",
                                                         B => x"ff"
                                                        );
  type K_IO_BRAM_MON_t is record
    RD_DATA                    :std_logic_vector(31 downto 0);
  end record K_IO_BRAM_MON_t;


  type K_IO_BRAM_CTRL_t is record
    WRITE                      :std_logic;   
    ADDR                       :std_logic_vector(14 downto 0);
    WR_DATA                    :std_logic_vector(31 downto 0);
  end record K_IO_BRAM_CTRL_t;


  constant DEFAULT_K_IO_BRAM_CTRL_t : K_IO_BRAM_CTRL_t := (
                                                           WRITE => '0',
                                                           ADDR => (others => '0'),
                                                           WR_DATA => (others => '0')
                                                          );
  type K_IO_MON_t is record
    CLK_200_LOCKED             :std_logic;   
    BRAM                       :K_IO_BRAM_MON_t;
  end record K_IO_MON_t;


  type K_IO_CTRL_t is record
    RGB                        :K_IO_RGB_CTRL_t;
    BRAM                       :K_IO_BRAM_CTRL_t;
  end record K_IO_CTRL_t;


  constant DEFAULT_K_IO_CTRL_t : K_IO_CTRL_t := (
                                                 RGB => DEFAULT_K_IO_RGB_CTRL_t,
                                                 BRAM => DEFAULT_K_IO_BRAM_CTRL_t
                                                );


end package K_IO_CTRL;