--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;


package DEBUG_8B10B_CTRL is
  type DEBUG_8B10B_COMMON_MON_t is record
    GTWIZ_USERCLK_TX_ACTIVE    :std_logic;   
    GTWIZ_USERCLK_RX_ACTIVE    :std_logic;   
    GTWIZ_RESET_RX_CDR_STABLE  :std_logic;   
    GTWIZ_RESET_TX_DONE        :std_logic;   
    GTWIZ_RESET_RX_DONE        :std_logic;   
  end record DEBUG_8B10B_COMMON_MON_t;
  type DEBUG_8B10B_COMMON_MON_t_ARRAY is array(0 to 0) of DEBUG_8B10B_COMMON_MON_t;

  type DEBUG_8B10B_COMMON_CTRL_t is record
    GTWIZ_USERCLK_TX_RESET     :std_logic;   
    GTWIZ_USERCLK_RX_RESET     :std_logic;   
    GTWIZ_RESET_CLK_FREERUN    :std_logic;   
    GTWIZ_RESET_ALL            :std_logic;   
    GTWIZ_RESET_TX_PLL_AND_DATAPATH  :std_logic;   
    GTWIZ_RESET_TX_DATAPATH          :std_logic;   
    GTWIZ_RESET_RX_PLL_AND_DATAPATH  :std_logic;   
    GTWIZ_RESET_RX_DATAPATH          :std_logic;   
  end record DEBUG_8B10B_COMMON_CTRL_t;
  type DEBUG_8B10B_COMMON_CTRL_t_ARRAY is array(0 to 0) of DEBUG_8B10B_COMMON_CTRL_t;

  constant DEFAULT_DEBUG_8B10B_COMMON_CTRL_t : DEBUG_8B10B_COMMON_CTRL_t := (
                                                                             GTWIZ_USERCLK_TX_RESET => '0',
                                                                             GTWIZ_USERCLK_RX_RESET => '0',
                                                                             GTWIZ_RESET_CLK_FREERUN => '0',
                                                                             GTWIZ_RESET_ALL => '0',
                                                                             GTWIZ_RESET_TX_PLL_AND_DATAPATH => '0',
                                                                             GTWIZ_RESET_TX_DATAPATH => '0',
                                                                             GTWIZ_RESET_RX_PLL_AND_DATAPATH => '0',
                                                                             GTWIZ_RESET_RX_DATAPATH => '0'
                                                                            );
  type DEBUG_8B10B_CHANNEL_CONFIG_MON_t is record
    TXRX_TYPE                  :std_logic_vector( 3 downto 0);
    CPLLLOCK                   :std_logic;                    
    DMONITOROUT                :std_logic_vector(15 downto 0);
    EYESCANDATAERROR           :std_logic;                    
    GTPOWERGOOD                :std_logic;                    
    RXBUFSTATUS                :std_logic_vector( 2 downto 0);
    RXBYTEISALIGNED            :std_logic;                    
    RXBYTEREALIGN              :std_logic;                    
    RXCTRL2                    :std_logic_vector( 7 downto 0);
    RXPMARESETDONE             :std_logic;                    
    RXPRBSERR                  :std_logic;                    
    RXRESETDONE                :std_logic;                    
    TXBUFSTATUS                :std_logic_vector( 1 downto 0);
    TXPMARESETDONE             :std_logic;                    
    TXRESETDONE                :std_logic;                    
  end record DEBUG_8B10B_CHANNEL_CONFIG_MON_t;


  type DEBUG_8B10B_CHANNEL_CONFIG_CTRL_t is record
    EYESCANRESET               :std_logic;   
    EYESCANTRIGGER             :std_logic;   
    LOOPBACK                   :std_logic_vector( 2 downto 0);
    PCSRSVDIN                  :std_logic_vector(15 downto 0);
    RXBUFRESET                 :std_logic;                    
    RXCDRHOLD                  :std_logic;                    
    RXDFELPMRESET              :std_logic;                    
    RXLPMEN                    :std_logic;                    
    RXMCOMMAALIGNEN            :std_logic;                    
    RXPCOMMAALIGNEN            :std_logic;                    
    RXPCSRESET                 :std_logic;                    
    RXPMARESET                 :std_logic;                    
    RXPRBSCNTRESET             :std_logic;                    
    RXPRBSSEL                  :std_logic_vector( 3 downto 0);
    RXRATE                     :std_logic_vector( 2 downto 0);
    TXCTRL0                    :std_logic_vector(15 downto 0);
    TXCTRL1                    :std_logic_vector(15 downto 0);
    TXDIFFCTRL                 :std_logic_vector( 4 downto 0);
    TXINHIBIT                  :std_logic;                    
    TXPCSRESET                 :std_logic;                    
    TXPMARESET                 :std_logic;                    
    TXPOLARITY                 :std_logic;                    
    TXPOSTCURSOR               :std_logic_vector( 4 downto 0);
    TXPRBSFORCEERR             :std_logic;                    
    TXPRBSSEL                  :std_logic_vector( 3 downto 0);
    TXPRECURSOR                :std_logic_vector( 4 downto 0);
  end record DEBUG_8B10B_CHANNEL_CONFIG_CTRL_t;


  constant DEFAULT_DEBUG_8B10B_CHANNEL_CONFIG_CTRL_t : DEBUG_8B10B_CHANNEL_CONFIG_CTRL_t := (
                                                                                             EYESCANRESET => '0',
                                                                                             EYESCANTRIGGER => '0',
                                                                                             LOOPBACK => (others => '0'),
                                                                                             PCSRSVDIN => (others => '0'),
                                                                                             RXBUFRESET => '0',
                                                                                             RXCDRHOLD => '0',
                                                                                             RXDFELPMRESET => '0',
                                                                                             RXLPMEN => '0',
                                                                                             RXMCOMMAALIGNEN => '0',
                                                                                             RXPCOMMAALIGNEN => '0',
                                                                                             RXPCSRESET => '0',
                                                                                             RXPMARESET => '0',
                                                                                             RXPRBSCNTRESET => '0',
                                                                                             RXPRBSSEL => (others => '0'),
                                                                                             RXRATE => (others => '0'),
                                                                                             TXCTRL0 => (others => '0'),
                                                                                             TXCTRL1 => (others => '0'),
                                                                                             TXDIFFCTRL => (others => '0'),
                                                                                             TXINHIBIT => '0',
                                                                                             TXPCSRESET => '0',
                                                                                             TXPMARESET => '0',
                                                                                             TXPOLARITY => '0',
                                                                                             TXPOSTCURSOR => (others => '0'),
                                                                                             TXPRBSFORCEERR => '0',
                                                                                             TXPRBSSEL => (others => '0'),
                                                                                             TXPRECURSOR => (others => '0')
                                                                                            );
  type DEBUG_8B10B_CHANNEL_DRP_MOSI_t is record
    clk       : std_logic;
    reset     : std_logic;
    enable    : std_logic;
    wr_enable : std_logic;
    address   : std_logic_vector(10-1 downto 0);
    wr_data   : std_logic_vector(16-1 downto 0);
  end record DEBUG_8B10B_CHANNEL_DRP_MOSI_t;
  type DEBUG_8B10B_CHANNEL_DRP_MISO_t is record
    rd_data         : std_logic_vector(16-1 downto 0);
    rd_data_valid   : std_logic;
  end record DEBUG_8B10B_CHANNEL_DRP_MISO_t;
  constant Default_DEBUG_8B10B_CHANNEL_DRP_MOSI_t : DEBUG_8B10B_CHANNEL_DRP_MOSI_t := ( 
                                                     clk       => '0',
                                                     reset     => '0',
                                                     enable    => '0',
                                                     wr_enable => '0',
                                                     address   => (others => '0'),
                                                     wr_data   => (others => '0')
  );
  type DEBUG_8B10B_CHANNEL_MON_t is record
    CONFIG                     :DEBUG_8B10B_CHANNEL_CONFIG_MON_t;
    DRP                        :DEBUG_8B10B_CHANNEL_DRP_MISO_t;  
  end record DEBUG_8B10B_CHANNEL_MON_t;
  type DEBUG_8B10B_CHANNEL_MON_t_ARRAY is array(0 to 3) of DEBUG_8B10B_CHANNEL_MON_t;

  type DEBUG_8B10B_CHANNEL_CTRL_t is record
    CONFIG                     :DEBUG_8B10B_CHANNEL_CONFIG_CTRL_t;
    DRP                        :DEBUG_8B10B_CHANNEL_DRP_MOSI_t;   
  end record DEBUG_8B10B_CHANNEL_CTRL_t;
  type DEBUG_8B10B_CHANNEL_CTRL_t_ARRAY is array(0 to 3) of DEBUG_8B10B_CHANNEL_CTRL_t;

  constant DEFAULT_DEBUG_8B10B_CHANNEL_CTRL_t : DEBUG_8B10B_CHANNEL_CTRL_t := (
                                                                               CONFIG => DEFAULT_DEBUG_8B10B_CHANNEL_CONFIG_CTRL_t,
                                                                               DRP => Default_DEBUG_8B10B_CHANNEL_DRP_MOSI_t
                                                                              );
  type DEBUG_8B10B_MON_t is record
    COMMON                     :DEBUG_8B10B_COMMON_MON_t_ARRAY;
    CHANNEL                    :DEBUG_8B10B_CHANNEL_MON_t_ARRAY;
  end record DEBUG_8B10B_MON_t;


  type DEBUG_8B10B_CTRL_t is record
    COMMON                     :DEBUG_8B10B_COMMON_CTRL_t_ARRAY;
    CHANNEL                    :DEBUG_8B10B_CHANNEL_CTRL_t_ARRAY;
  end record DEBUG_8B10B_CTRL_t;


  constant DEFAULT_DEBUG_8B10B_CTRL_t : DEBUG_8B10B_CTRL_t := (
                                                               COMMON => (others => DEFAULT_DEBUG_8B10B_COMMON_CTRL_t ),
                                                               CHANNEL => (others => DEFAULT_DEBUG_8B10B_CHANNEL_CTRL_t )
                                                              );


end package DEBUG_8B10B_CTRL;