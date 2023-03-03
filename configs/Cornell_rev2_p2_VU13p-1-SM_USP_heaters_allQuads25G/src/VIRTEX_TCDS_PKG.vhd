--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;


package VIRTEX_TCDS_CTRL is
  type VIRTEX_TCDS_CLOCKING_MON_t is record
    COUNTS_REFCLK0             : std_logic_vector(31 downto  0);
    COUNTS_TXOUTCLK            : std_logic_vector(31 downto  0);
    POWER_GOOD                 : std_logic;                     
    QPLL0_FBCLKLOST            : std_logic;                     
    QPLL0_LOCK                 : std_logic;                     
    QPLL0_REFCLKLOST           : std_logic;                     
    RX_CDR_STABLE              : std_logic;                     
  end record VIRTEX_TCDS_CLOCKING_MON_t;

  type VIRTEX_TCDS_RESETS_MON_t is record
    RX_PMA_RESET_DONE          : std_logic;   
    RX_RESET_DONE              : std_logic;   
    TX_PMA_RESET_DONE          : std_logic;   
    TX_RESET_DONE              : std_logic;   
  end record VIRTEX_TCDS_RESETS_MON_t;

  type VIRTEX_TCDS_RESETS_CTRL_t is record
    RESET_ALL                  : std_logic;   
    RX_DATAPATH                : std_logic;   
    RX_PLL_DATAPATH            : std_logic;   
    TX_DATAPATH                : std_logic;   
    TX_PLL_DATAPATH            : std_logic;   
  end record VIRTEX_TCDS_RESETS_CTRL_t;

  type VIRTEX_TCDS_RX_MON_t is record
    BAD_CHAR                   : std_logic_vector( 3 downto  0);
    DISP_ERROR                 : std_logic_vector( 3 downto  0);
    PMA_RESET_DONE             : std_logic;                     
  end record VIRTEX_TCDS_RX_MON_t;

  type VIRTEX_TCDS_RX_CTRL_t is record
    PRBS_RESET                 : std_logic;                     
    PRBS_SEL                   : std_logic_vector( 3 downto  0);
    USER_CLK_READY             : std_logic;                     
  end record VIRTEX_TCDS_RX_CTRL_t;

  type VIRTEX_TCDS_TX_MON_t is record
    PMA_RESET_DONE             : std_logic;   
    PWR_GOOD                   : std_logic;   
  end record VIRTEX_TCDS_TX_MON_t;

  type VIRTEX_TCDS_TX_CTRL_t is record
    INHIBIT                    : std_logic;                     
    PRBS_FORCE_ERROR           : std_logic;                     
    PRBS_SEL                   : std_logic_vector( 3 downto  0);
    USER_CLK_READY             : std_logic;                     
  end record VIRTEX_TCDS_TX_CTRL_t;

  type VIRTEX_TCDS_EYESCAN_CTRL_t is record
    RESET                      : std_logic;   
    TRIGGER                    : std_logic;   
  end record VIRTEX_TCDS_EYESCAN_CTRL_t;

  type VIRTEX_TCDS_DEBUG_MON_t is record
    CAPTURE_D                  : std_logic_vector(31 downto  0);
    CAPTURE_K                  : std_logic_vector( 3 downto  0);
  end record VIRTEX_TCDS_DEBUG_MON_t;

  type VIRTEX_TCDS_DEBUG_CTRL_t is record
    CAPTURE                    : std_logic;                     
    FIXED_SEND_D               : std_logic_vector(31 downto  0);
    FIXED_SEND_K               : std_logic_vector( 3 downto  0);
    MODE                       : std_logic_vector( 3 downto  0);
  end record VIRTEX_TCDS_DEBUG_CTRL_t;

  type VIRTEX_TCDS_Heater_MON_t is record
    Output                     : std_logic_vector(31 downto  0);
  end record VIRTEX_TCDS_Heater_MON_t;

  type VIRTEX_TCDS_Heater_CTRL_t is record
    Adjust                     : std_logic_vector(31 downto  0);
    Enable                     : std_logic;                     
    SelectHeater               : std_logic_vector(31 downto  0);
  end record VIRTEX_TCDS_Heater_CTRL_t;

  type VIRTEX_TCDS_MON_t is record
    CLOCKING                   : VIRTEX_TCDS_CLOCKING_MON_t;
    DEBUG                      : VIRTEX_TCDS_DEBUG_MON_t;   
    Heater                     : VIRTEX_TCDS_Heater_MON_t;  
    RESETS                     : VIRTEX_TCDS_RESETS_MON_t;  
    RX                         : VIRTEX_TCDS_RX_MON_t;      
    TX                         : VIRTEX_TCDS_TX_MON_t;      
  end record VIRTEX_TCDS_MON_t;

  type VIRTEX_TCDS_CTRL_t is record
    DEBUG                      : VIRTEX_TCDS_DEBUG_CTRL_t;      
    EYESCAN                    : VIRTEX_TCDS_EYESCAN_CTRL_t;    
    Heater                     : VIRTEX_TCDS_Heater_CTRL_t;     
    LOOPBACK                   : std_logic_vector( 2 downto  0);
    RESETS                     : VIRTEX_TCDS_RESETS_CTRL_t;     
    RX                         : VIRTEX_TCDS_RX_CTRL_t;         
    TX                         : VIRTEX_TCDS_TX_CTRL_t;         
  end record VIRTEX_TCDS_CTRL_t;



end package VIRTEX_TCDS_CTRL;
