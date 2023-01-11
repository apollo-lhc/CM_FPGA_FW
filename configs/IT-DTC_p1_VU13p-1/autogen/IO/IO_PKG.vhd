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
  type IO_DEBUG_8B10B_CLK_CHANNEL_RX_MON_t is record
    USRCLK_FREQ                :std_logic_vector(31 downto 0);
    USRCLK2_FREQ               :std_logic_vector(31 downto 0);
  end record IO_DEBUG_8B10B_CLK_CHANNEL_RX_MON_t;


  type IO_DEBUG_8B10B_CLK_CHANNEL_TX_MON_t is record
    USRCLK_FREQ                :std_logic_vector(31 downto 0);
    USRCLK2_FREQ               :std_logic_vector(31 downto 0);
  end record IO_DEBUG_8B10B_CLK_CHANNEL_TX_MON_t;


  type IO_DEBUG_8B10B_CLK_CHANNEL_MON_t is record
    RX                         :IO_DEBUG_8B10B_CLK_CHANNEL_RX_MON_t;
    TX                         :IO_DEBUG_8B10B_CLK_CHANNEL_TX_MON_t;
  end record IO_DEBUG_8B10B_CLK_CHANNEL_MON_t;
  type IO_DEBUG_8B10B_CLK_CHANNEL_MON_t_ARRAY is array(0 to 3) of IO_DEBUG_8B10B_CLK_CHANNEL_MON_t;

  type IO_DEBUG_8B10B_CLK_MON_t is record
    CHANNEL                    :IO_DEBUG_8B10B_CLK_CHANNEL_MON_t_ARRAY;
  end record IO_DEBUG_8B10B_CLK_MON_t;


  type IO_DEBUG_8B10B_CHANNEL_RX_MON_t is record
    DATA                       :std_logic_vector(31 downto 0);
    KDATA                      :std_logic_vector( 3 downto 0);
    VALID                      :std_logic_vector( 3 downto 0);
    COMMA                      :std_logic;                    
    DISP_ERR                   :std_logic_vector( 3 downto 0);
  end record IO_DEBUG_8B10B_CHANNEL_RX_MON_t;


  type IO_DEBUG_8B10B_CHANNEL_RX_CTRL_t is record
    ENABLE                     :std_logic;   
    EN_COMMA_DET               :std_logic;   
  end record IO_DEBUG_8B10B_CHANNEL_RX_CTRL_t;


  constant DEFAULT_IO_DEBUG_8B10B_CHANNEL_RX_CTRL_t : IO_DEBUG_8B10B_CHANNEL_RX_CTRL_t := (
                                                                                           ENABLE => '0',
                                                                                           EN_COMMA_DET => '0'
                                                                                          );
  type IO_DEBUG_8B10B_CHANNEL_TX_CTRL_t is record
    DATA                       :std_logic_vector(31 downto 0);
    KDATA                      :std_logic_vector( 3 downto 0);
    ENABLE                     :std_logic;                    
  end record IO_DEBUG_8B10B_CHANNEL_TX_CTRL_t;


  constant DEFAULT_IO_DEBUG_8B10B_CHANNEL_TX_CTRL_t : IO_DEBUG_8B10B_CHANNEL_TX_CTRL_t := (
                                                                                           DATA => (others => '0'),
                                                                                           KDATA => (others => '0'),
                                                                                           ENABLE => '0'
                                                                                          );
  type IO_DEBUG_8B10B_CHANNEL_MON_t is record
    RX                         :IO_DEBUG_8B10B_CHANNEL_RX_MON_t;
  end record IO_DEBUG_8B10B_CHANNEL_MON_t;
  type IO_DEBUG_8B10B_CHANNEL_MON_t_ARRAY is array(0 to 3) of IO_DEBUG_8B10B_CHANNEL_MON_t;

  type IO_DEBUG_8B10B_CHANNEL_CTRL_t is record
    RX                         :IO_DEBUG_8B10B_CHANNEL_RX_CTRL_t;
    TX                         :IO_DEBUG_8B10B_CHANNEL_TX_CTRL_t;
  end record IO_DEBUG_8B10B_CHANNEL_CTRL_t;
  type IO_DEBUG_8B10B_CHANNEL_CTRL_t_ARRAY is array(0 to 3) of IO_DEBUG_8B10B_CHANNEL_CTRL_t;

  constant DEFAULT_IO_DEBUG_8B10B_CHANNEL_CTRL_t : IO_DEBUG_8B10B_CHANNEL_CTRL_t := (
                                                                                     RX => DEFAULT_IO_DEBUG_8B10B_CHANNEL_RX_CTRL_t,
                                                                                     TX => DEFAULT_IO_DEBUG_8B10B_CHANNEL_TX_CTRL_t
                                                                                    );
  type IO_DEBUG_8B10B_MON_t is record
    CHANNEL                    :IO_DEBUG_8B10B_CHANNEL_MON_t_ARRAY;
  end record IO_DEBUG_8B10B_MON_t;


  type IO_DEBUG_8B10B_CTRL_t is record
    CHANNEL                    :IO_DEBUG_8B10B_CHANNEL_CTRL_t_ARRAY;
  end record IO_DEBUG_8B10B_CTRL_t;


  constant DEFAULT_IO_DEBUG_8B10B_CTRL_t : IO_DEBUG_8B10B_CTRL_t := (
                                                                     CHANNEL => (others => DEFAULT_IO_DEBUG_8B10B_CHANNEL_CTRL_t )
                                                                    );
  type IO_MON_t is record
    CLK_200_LOCKED             :std_logic;   
    BRAM                       :IO_BRAM_MON_t;
    DEBUG_8B10B_CLK            :IO_DEBUG_8B10B_CLK_MON_t;
    DEBUG_8B10B                :IO_DEBUG_8B10B_MON_t;    
  end record IO_MON_t;


  type IO_CTRL_t is record
    RGB                        :IO_RGB_CTRL_t;
    BRAM                       :IO_BRAM_CTRL_t;
    DEBUG_8B10B                :IO_DEBUG_8B10B_CTRL_t;
  end record IO_CTRL_t;


  constant DEFAULT_IO_CTRL_t : IO_CTRL_t := (
                                             RGB => DEFAULT_IO_RGB_CTRL_t,
                                             BRAM => DEFAULT_IO_BRAM_CTRL_t,
                                             DEBUG_8B10B => DEFAULT_IO_DEBUG_8B10B_CTRL_t
                                            );


end package IO_CTRL;