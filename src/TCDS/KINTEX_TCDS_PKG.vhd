--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;


package KINTEX_TCDS_CTRL is
  type KINTEX_TCDS_CLOCKING_MON_t is record
    POWER_GOOD                 : std_logic;   
    RX_CDR_STABLE              : std_logic;   
  end record KINTEX_TCDS_CLOCKING_MON_t;

  type KINTEX_TCDS_RESETS_MON_t is record
    RX_PMA_RESET_DONE          : std_logic;   
    RX_RESET_DONE              : std_logic;   
    TX_PMA_RESET_DONE          : std_logic;   
    TX_RESET_DONE              : std_logic;   
  end record KINTEX_TCDS_RESETS_MON_t;

  type KINTEX_TCDS_RESETS_CTRL_t is record
    RESET_ALL                  : std_logic;   
    RX_DATAPATH                : std_logic;   
    RX_PLL_DATAPATH            : std_logic;   
    TX_DATAPATH                : std_logic;   
    TX_PLL_DATAPATH            : std_logic;   
  end record KINTEX_TCDS_RESETS_CTRL_t;

  constant DEFAULT_KINTEX_TCDS_RESETS_CTRL_t : KINTEX_TCDS_RESETS_CTRL_t := (
                                                                             RESET_ALL => '0',
                                                                             RX_PLL_DATAPATH => '0',
                                                                             RX_DATAPATH => '0',
                                                                             TX_DATAPATH => '0',
                                                                             TX_PLL_DATAPATH => '0'
                                                                            );
  type KINTEX_TCDS_RX_MON_t is record
    BAD_CHAR                   : std_logic_vector( 3 downto  0);
    DISP_ERROR                 : std_logic_vector( 3 downto  0);
    PMA_RESET_DONE             : std_logic;                     
  end record KINTEX_TCDS_RX_MON_t;

  type KINTEX_TCDS_RX_CTRL_t is record
    PRBS_RESET                 : std_logic;                     
    PRBS_SEL                   : std_logic_vector( 3 downto  0);
    USER_CLK_READY             : std_logic;                     
  end record KINTEX_TCDS_RX_CTRL_t;

  constant DEFAULT_KINTEX_TCDS_RX_CTRL_t : KINTEX_TCDS_RX_CTRL_t := (
                                                                     PRBS_RESET => '0',
                                                                     PRBS_SEL => (others => '0'),
                                                                     USER_CLK_READY => '0'
                                                                    );
  type KINTEX_TCDS_TX_MON_t is record
    PMA_RESET_DONE             : std_logic;   
    PWR_GOOD                   : std_logic;   
  end record KINTEX_TCDS_TX_MON_t;

  type KINTEX_TCDS_TX_CTRL_t is record
    INHIBIT                    : std_logic;                     
    PRBS_FORCE_ERROR           : std_logic;                     
    PRBS_SEL                   : std_logic_vector( 3 downto  0);
    USER_CLK_READY             : std_logic;                     
  end record KINTEX_TCDS_TX_CTRL_t;

  constant DEFAULT_KINTEX_TCDS_TX_CTRL_t : KINTEX_TCDS_TX_CTRL_t := (
                                                                     PRBS_FORCE_ERROR => '0',
                                                                     PRBS_SEL => (others => '0'),
                                                                     INHIBIT => '0',
                                                                     USER_CLK_READY => '0'
                                                                    );
  type KINTEX_TCDS_EYESCAN_CTRL_t is record
    RESET                      : std_logic;   
    TRIGGER                    : std_logic;   
  end record KINTEX_TCDS_EYESCAN_CTRL_t;

  constant DEFAULT_KINTEX_TCDS_EYESCAN_CTRL_t : KINTEX_TCDS_EYESCAN_CTRL_t := (
                                                                               RESET => '0',
                                                                               TRIGGER => '0'
                                                                              );
  type KINTEX_TCDS_DEBUG_MON_t is record
    CAPTURE_D                  : std_logic_vector(31 downto  0);
    CAPTURE_K                  : std_logic_vector( 3 downto  0);
  end record KINTEX_TCDS_DEBUG_MON_t;

  type KINTEX_TCDS_DEBUG_CTRL_t is record
    CAPTURE                    : std_logic;                     
    FIXED_SEND_D               : std_logic_vector(31 downto  0);
    FIXED_SEND_K               : std_logic_vector( 3 downto  0);
    MODE                       : std_logic_vector( 3 downto  0);
  end record KINTEX_TCDS_DEBUG_CTRL_t;

  constant DEFAULT_KINTEX_TCDS_DEBUG_CTRL_t : KINTEX_TCDS_DEBUG_CTRL_t := (
                                                                           CAPTURE => '0',
                                                                           FIXED_SEND_D => (others => '0'),
                                                                           MODE => (others => '0'),
                                                                           FIXED_SEND_K => (others => '0')
                                                                          );
  type KINTEX_TCDS_MON_t is record
    CLOCKING                   : KINTEX_TCDS_CLOCKING_MON_t;
    DEBUG                      : KINTEX_TCDS_DEBUG_MON_t;   
    RESETS                     : KINTEX_TCDS_RESETS_MON_t;  
    RX                         : KINTEX_TCDS_RX_MON_t;      
    TX                         : KINTEX_TCDS_TX_MON_t;      
  end record KINTEX_TCDS_MON_t;

  type KINTEX_TCDS_CTRL_t is record
    DEBUG                      : KINTEX_TCDS_DEBUG_CTRL_t;      
    EYESCAN                    : KINTEX_TCDS_EYESCAN_CTRL_t;    
    LOOPBACK                   : std_logic_vector( 2 downto  0);
    RESETS                     : KINTEX_TCDS_RESETS_CTRL_t;     
    RX                         : KINTEX_TCDS_RX_CTRL_t;         
    TX                         : KINTEX_TCDS_TX_CTRL_t;         
  end record KINTEX_TCDS_CTRL_t;

  constant DEFAULT_KINTEX_TCDS_CTRL_t : KINTEX_TCDS_CTRL_t := (
                                                               TX => DEFAULT_KINTEX_TCDS_TX_CTRL_t,
                                                               LOOPBACK => (others => '0'),
                                                               RX => DEFAULT_KINTEX_TCDS_RX_CTRL_t,
                                                               DEBUG => DEFAULT_KINTEX_TCDS_DEBUG_CTRL_t,
                                                               RESETS => DEFAULT_KINTEX_TCDS_RESETS_CTRL_t,
                                                               EYESCAN => DEFAULT_KINTEX_TCDS_EYESCAN_CTRL_t
                                                              );


end package KINTEX_TCDS_CTRL;