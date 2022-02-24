--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;


package IO_CTRL is
  type IO_RGB_CTRL_t is record
    R                          :std_logic_vector( 7 downto 0);
    G                          :std_logic_vector( 7 downto 0);
    B                          :std_logic_vector( 7 downto 0);
  end record IO_RGB_CTRL_t;


  constant DEFAULT_IO_RGB_CTRL_t : IO_RGB_CTRL_t := (
                                                     R => x"00",
                                                     G => x"00",
                                                     B => x"ff"
                                                    );
  type IO_BRAM_MON_t is record
    RD_DATA                    :std_logic_vector(31 downto 0);
  end record IO_BRAM_MON_t;


  type IO_BRAM_CTRL_t is record
    WRITE                      :std_logic;   
    ADDR                       :std_logic_vector(14 downto 0);
    WR_DATA                    :std_logic_vector(31 downto 0);
  end record IO_BRAM_CTRL_t;


  constant DEFAULT_IO_BRAM_CTRL_t : IO_BRAM_CTRL_t := (
                                                       WRITE => '0',
                                                       ADDR => (others => '0'),
                                                       WR_DATA => (others => '0')
                                                      );
  type IO_MON_t is record
    CLK_200_LOCKED             :std_logic;   
    BRAM                       :IO_BRAM_MON_t;
  end record IO_MON_t;


  type IO_CTRL_t is record
    RGB                        :IO_RGB_CTRL_t;
    BRAM                       :IO_BRAM_CTRL_t;
  end record IO_CTRL_t;


  constant DEFAULT_IO_CTRL_t : IO_CTRL_t := (
                                             RGB => DEFAULT_IO_RGB_CTRL_t,
                                             BRAM => DEFAULT_IO_BRAM_CTRL_t
                                            );


end package IO_CTRL;