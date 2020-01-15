--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;


package TCDS_CTRL is
  type TCDS_CLOCKING_MON_t is record
    POWER_GOOD                 : std_logic;   
    RX_CDR_STABLE              : std_logic;   
  end record TCDS_CLOCKING_MON_t;

  type TCDS_RESETS_MON_t is record
    RX_PMA_RESET_DONE          : std_logic;   
    RX_RESET_DONE              : std_logic;   
    TX_PMA_RESET_DONE          : std_logic;   
    TX_RESET_DONE              : std_logic;   
  end record TCDS_RESETS_MON_t;

  type TCDS_RESETS_CTRL_t is record
    RESET_ALL                  : std_logic;   
    RX_DATAPATH                : std_logic;   
    RX_PLL_DATAPATH            : std_logic;   
    TX_DATAPATH                : std_logic;   
    TX_PLL_DATAPATH            : std_logic;   
  end record TCDS_RESETS_CTRL_t;

  type TCDS_RX_MON_t is record
    BAD_CHAR                   : std_logic_vector( 3 downto  0);
    DISP_ERROR                 : std_logic_vector( 3 downto  0);
    PMA_RESET_DONE             : std_logic;                     
  end record TCDS_RX_MON_t;

  type TCDS_RX_CTRL_t is record
    PRBS_RESET                 : std_logic;                     
    PRBS_SEL                   : std_logic_vector( 3 downto  0);
    USER_CLK_READY             : std_logic;                     
  end record TCDS_RX_CTRL_t;

  type TCDS_TX_MON_t is record
    PMA_RESET_DONE             : std_logic;   
    PWR_GOOD                   : std_logic;   
  end record TCDS_TX_MON_t;

  type TCDS_TX_CTRL_t is record
    INHIBIT                    : std_logic;                     
    PRBS_FORCE_ERROR           : std_logic;                     
    PRBS_SEL                   : std_logic_vector( 3 downto  0);
    USER_CLK_READY             : std_logic;                     
  end record TCDS_TX_CTRL_t;

  type TCDS_EYESCAN_CTRL_t is record
    RESET                      : std_logic;   
    TRIGGER                    : std_logic;   
  end record TCDS_EYESCAN_CTRL_t;

  type TCDS_MON_t is record
    CLOCKING                   : TCDS_CLOCKING_MON_t;
    RESETS                     : TCDS_RESETS_MON_t;  
    RX                         : TCDS_RX_MON_t;      
    TX                         : TCDS_TX_MON_t;      
  end record TCDS_MON_t;

  type TCDS_CTRL_t is record
    EYESCAN                    : TCDS_EYESCAN_CTRL_t;           
    LOOPBACK                   : std_logic_vector( 2 downto  0);
    RESETS                     : TCDS_RESETS_CTRL_t;            
    RX                         : TCDS_RX_CTRL_t;                
    TX                         : TCDS_TX_CTRL_t;                
  end record TCDS_CTRL_t;



end package TCDS_CTRL;