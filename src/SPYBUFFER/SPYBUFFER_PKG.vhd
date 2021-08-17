--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;


package SPYBUFFER_CTRL is
  type SPYBUFFER_SPY_CTRL_CTRL_t is record
    FREEZE                     :std_logic;   
    PLAYBACK                   :std_logic_vector( 1 downto 0);
  end record SPYBUFFER_SPY_CTRL_CTRL_t;


  constant DEFAULT_SPYBUFFER_SPY_CTRL_CTRL_t : SPYBUFFER_SPY_CTRL_CTRL_t := (
                                                                             FREEZE => '0',
                                                                             PLAYBACK => (others => '0')
                                                                            );
  type SPYBUFFER_SPY_MEM_MOSI_t is record
    clk       : std_logic;
    enable    : std_logic;
    wr_enable : std_logic;
    address   : std_logic_vector(8-1 downto 0);
    wr_data   : std_logic_vector(32-1 downto 0);
  end record SPYBUFFER_SPY_MEM_MOSI_t;
  type SPYBUFFER_SPY_MEM_MISO_t is record
    rd_data         : std_logic_vector(32-1 downto 0);
    rd_data_valid   : std_logic;
  end record SPYBUFFER_SPY_MEM_MISO_t;
  constant Default_SPYBUFFER_SPY_MEM_MOSI_t : SPYBUFFER_SPY_MEM_MOSI_t := ( 
                                                     clk       => '0',
                                                     enable    => '0',
                                                     wr_enable => '0',
                                                     address   => (others => '0'),
                                                     wr_data   => (others => '0')
  );
  type SPYBUFFER_SPY_META_MOSI_t is record
    clk       : std_logic;
    enable    : std_logic;
    wr_enable : std_logic;
    address   : std_logic_vector(8-1 downto 0);
    wr_data   : std_logic_vector(32-1 downto 0);
  end record SPYBUFFER_SPY_META_MOSI_t;
  type SPYBUFFER_SPY_META_MISO_t is record
    rd_data         : std_logic_vector(32-1 downto 0);
    rd_data_valid   : std_logic;
  end record SPYBUFFER_SPY_META_MISO_t;
  constant Default_SPYBUFFER_SPY_META_MOSI_t : SPYBUFFER_SPY_META_MOSI_t := ( 
                                                     clk       => '0',
                                                     enable    => '0',
                                                     wr_enable => '0',
                                                     address   => (others => '0'),
                                                     wr_data   => (others => '0')
  );
  type SPYBUFFER_MON_t is record
    SPY_STATUS                 :std_logic_vector(31 downto 0);
    SPY_MEM                    :SPYBUFFER_SPY_MEM_MISO_t;     
    SPY_META                   :SPYBUFFER_SPY_META_MISO_t;    
  end record SPYBUFFER_MON_t;


  type SPYBUFFER_CTRL_t is record
    SPY_CTRL                   :SPYBUFFER_SPY_CTRL_CTRL_t;
    SPY_MEM                    :SPYBUFFER_SPY_MEM_MOSI_t; 
    SPY_META                   :SPYBUFFER_SPY_META_MOSI_t;
  end record SPYBUFFER_CTRL_t;


  constant DEFAULT_SPYBUFFER_CTRL_t : SPYBUFFER_CTRL_t := (
                                                           SPY_CTRL => DEFAULT_SPYBUFFER_SPY_CTRL_CTRL_t,
                                                           SPY_MEM => Default_SPYBUFFER_SPY_MEM_MOSI_t,
                                                           SPY_META => Default_SPYBUFFER_SPY_META_MOSI_t
                                                          );


end package SPYBUFFER_CTRL;