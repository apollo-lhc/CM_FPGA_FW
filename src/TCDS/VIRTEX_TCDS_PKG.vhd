--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;


package VIRTEX_TCDS_CTRL is
  type VIRTEX_TCDS_CLOCKING_MON_t is record
    POWER_GOOD                 :std_logic;   
    RX_CDR_STABLE              :std_logic;   
    COUNTS_TXOUTCLK            :std_logic_vector(31 downto 0);
  end record VIRTEX_TCDS_CLOCKING_MON_t;


  type VIRTEX_TCDS_RESETS_MON_t is record
    TX_RESET_DONE              :std_logic;   
    TX_PMA_RESET_DONE          :std_logic;   
    RX_RESET_DONE              :std_logic;   
    RX_PMA_RESET_DONE          :std_logic;   
  end record VIRTEX_TCDS_RESETS_MON_t;


  type VIRTEX_TCDS_RESETS_CTRL_t is record
    RESET_ALL                  :std_logic;   
    TX_PLL_DATAPATH            :std_logic;   
    TX_DATAPATH                :std_logic;   
    RX_PLL_DATAPATH            :std_logic;   
    RX_DATAPATH                :std_logic;   
  end record VIRTEX_TCDS_RESETS_CTRL_t;


  constant DEFAULT_VIRTEX_TCDS_RESETS_CTRL_t : VIRTEX_TCDS_RESETS_CTRL_t := (
                                                                             RESET_ALL => '0',
                                                                             RX_PLL_DATAPATH => '0',
                                                                             RX_DATAPATH => '0',
                                                                             TX_DATAPATH => '0',
                                                                             TX_PLL_DATAPATH => '0'
                                                                            );
  type VIRTEX_TCDS_RX_MON_t is record
    PMA_RESET_DONE             :std_logic;   
    BAD_CHAR                   :std_logic_vector( 3 downto 0);
    DISP_ERROR                 :std_logic_vector( 3 downto 0);
  end record VIRTEX_TCDS_RX_MON_t;


  type VIRTEX_TCDS_RX_CTRL_t is record
    PRBS_SEL                   :std_logic_vector( 3 downto 0);
    PRBS_RESET                 :std_logic;                    
    USER_CLK_READY             :std_logic;                    
  end record VIRTEX_TCDS_RX_CTRL_t;


  constant DEFAULT_VIRTEX_TCDS_RX_CTRL_t : VIRTEX_TCDS_RX_CTRL_t := (
                                                                     PRBS_RESET => '0',
                                                                     PRBS_SEL => (others => '0'),
                                                                     USER_CLK_READY => '0'
                                                                    );
  type VIRTEX_TCDS_TX_MON_t is record
    PMA_RESET_DONE             :std_logic;   
    PWR_GOOD                   :std_logic;   
  end record VIRTEX_TCDS_TX_MON_t;


  type VIRTEX_TCDS_TX_CTRL_t is record
    PRBS_SEL                   :std_logic_vector( 3 downto 0);
    PRBS_FORCE_ERROR           :std_logic;                    
    INHIBIT                    :std_logic;                    
    USER_CLK_READY             :std_logic;                    
  end record VIRTEX_TCDS_TX_CTRL_t;


  constant DEFAULT_VIRTEX_TCDS_TX_CTRL_t : VIRTEX_TCDS_TX_CTRL_t := (
                                                                     PRBS_FORCE_ERROR => '0',
                                                                     PRBS_SEL => (others => '0'),
                                                                     INHIBIT => '0',
                                                                     USER_CLK_READY => '0'
                                                                    );
  type VIRTEX_TCDS_EYESCAN_CTRL_t is record
    RESET                      :std_logic;   
    TRIGGER                    :std_logic;   
  end record VIRTEX_TCDS_EYESCAN_CTRL_t;


  constant DEFAULT_VIRTEX_TCDS_EYESCAN_CTRL_t : VIRTEX_TCDS_EYESCAN_CTRL_t := (
                                                                               RESET => '0',
                                                                               TRIGGER => '0'
                                                                              );
  type VIRTEX_TCDS_DEBUG_MON_t is record
    CAPTURE_D                  :std_logic_vector(31 downto 0);
    CAPTURE_K                  :std_logic_vector( 3 downto 0);
  end record VIRTEX_TCDS_DEBUG_MON_t;


  type VIRTEX_TCDS_DEBUG_CTRL_t is record
    CAPTURE                    :std_logic;   
    MODE                       :std_logic_vector( 3 downto 0);
    FIXED_SEND_D               :std_logic_vector(31 downto 0);
    FIXED_SEND_K               :std_logic_vector( 3 downto 0);
  end record VIRTEX_TCDS_DEBUG_CTRL_t;


  constant DEFAULT_VIRTEX_TCDS_DEBUG_CTRL_t : VIRTEX_TCDS_DEBUG_CTRL_t := (
                                                                           CAPTURE => '0',
                                                                           FIXED_SEND_D => (others => '0'),
                                                                           MODE => (others => '0'),
                                                                           FIXED_SEND_K => (others => '0')
                                                                          );
  type VIRTEX_TCDS_MON_t is record
    CLOCKING                   :VIRTEX_TCDS_CLOCKING_MON_t;
    RESETS                     :VIRTEX_TCDS_RESETS_MON_t;  
    RX                         :VIRTEX_TCDS_RX_MON_t;      
    TX                         :VIRTEX_TCDS_TX_MON_t;      
    DEBUG                      :VIRTEX_TCDS_DEBUG_MON_t;   
  end record VIRTEX_TCDS_MON_t;


  type VIRTEX_TCDS_CTRL_t is record
    RESETS                     :VIRTEX_TCDS_RESETS_CTRL_t;
    LOOPBACK                   :std_logic_vector( 2 downto 0);
    RX                         :VIRTEX_TCDS_RX_CTRL_t;        
    TX                         :VIRTEX_TCDS_TX_CTRL_t;        
    EYESCAN                    :VIRTEX_TCDS_EYESCAN_CTRL_t;   
    DEBUG                      :VIRTEX_TCDS_DEBUG_CTRL_t;     
  end record VIRTEX_TCDS_CTRL_t;


  constant DEFAULT_VIRTEX_TCDS_CTRL_t : VIRTEX_TCDS_CTRL_t := (
                                                               TX => DEFAULT_VIRTEX_TCDS_TX_CTRL_t,
                                                               LOOPBACK => (others => '0'),
                                                               RX => DEFAULT_VIRTEX_TCDS_RX_CTRL_t,
                                                               DEBUG => DEFAULT_VIRTEX_TCDS_DEBUG_CTRL_t,
                                                               RESETS => DEFAULT_VIRTEX_TCDS_RESETS_CTRL_t,
                                                               EYESCAN => DEFAULT_VIRTEX_TCDS_EYESCAN_CTRL_t
                                                              );


end package VIRTEX_TCDS_CTRL;