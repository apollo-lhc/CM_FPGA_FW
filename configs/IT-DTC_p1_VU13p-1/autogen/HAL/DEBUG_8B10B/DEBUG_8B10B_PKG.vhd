--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;




package DEBUG_8B10B_PKG is
type DEBUG_8B10B_common_input_t is record
  GTWIZ_USERCLK_TX_RESET         : std_logic_vector(0 downto 0);
  GTWIZ_USERCLK_RX_RESET         : std_logic_vector(0 downto 0);
  GTWIZ_RESET_ALL                : std_logic_vector(0 downto 0);
  GTWIZ_RESET_TX_PLL_AND_DATAPATH : std_logic_vector(0 downto 0);
  GTWIZ_RESET_TX_DATAPATH        : std_logic_vector(0 downto 0);
  GTWIZ_RESET_RX_PLL_AND_DATAPATH : std_logic_vector(0 downto 0);
  GTWIZ_RESET_RX_DATAPATH        : std_logic_vector(0 downto 0);
end record DEBUG_8B10B_common_input_t;
type DEBUG_8B10B_common_input_array_t is array (integer range <>) of DEBUG_8B10B_common_input_t;
type DEBUG_8B10B_common_output_t is record
  GTWIZ_USERCLK_TX_ACTIVE        : std_logic_vector(0 downto 0);
  GTWIZ_USERCLK_RX_ACTIVE        : std_logic_vector(0 downto 0);
  GTWIZ_RESET_RX_CDR_STABLE      : std_logic_vector(0 downto 0);
  GTWIZ_RESET_TX_DONE            : std_logic_vector(0 downto 0);
  GTWIZ_RESET_RX_DONE            : std_logic_vector(0 downto 0);
end record DEBUG_8B10B_common_output_t;
type DEBUG_8B10B_common_output_array_t is array (integer range <>) of DEBUG_8B10B_common_output_t;
type DEBUG_8B10B_clocks_input_t is record
  GTWIZ_RESET_CLK_FREERUN        : std_logic_vector(0 downto 0);
  GTREFCLK00                     : std_logic_vector(0 downto 0);
end record DEBUG_8B10B_clocks_input_t;
type DEBUG_8B10B_clocks_input_array_t is array (integer range <>) of DEBUG_8B10B_clocks_input_t;
type DEBUG_8B10B_clocks_output_t is record
  GTWIZ_USERCLK_TX_SRCCLK        : std_logic_vector(0 downto 0);
  GTWIZ_USERCLK_TX_USRCLK        : std_logic_vector(0 downto 0);
  GTWIZ_USERCLK_TX_USRCLK2       : std_logic_vector(0 downto 0);
  GTWIZ_USERCLK_RX_SRCCLK        : std_logic_vector(0 downto 0);
  GTWIZ_USERCLK_RX_USRCLK        : std_logic_vector(0 downto 0);
  GTWIZ_USERCLK_RX_USRCLK2       : std_logic_vector(0 downto 0);
  QPLL0OUTCLK                    : std_logic_vector(0 downto 0);
  QPLL0OUTREFCLK                 : std_logic_vector(0 downto 0);
end record DEBUG_8B10B_clocks_output_t;
type DEBUG_8B10B_clocks_output_array_t is array (integer range <>) of DEBUG_8B10B_clocks_output_t;
type DEBUG_8B10B_channel_input_t is record
  EYESCANRESET                   : std_logic_vector(0 downto 0);
  EYESCANTRIGGER                 : std_logic_vector(0 downto 0);
  LOOPBACK                       : std_logic_vector(2 downto 0);
  PCSRSVDIN                      : std_logic_vector(15 downto 0);
  RXBUFRESET                     : std_logic_vector(0 downto 0);
  RXCDRHOLD                      : std_logic_vector(0 downto 0);
  RXDFELPMRESET                  : std_logic_vector(0 downto 0);
  RXLPMEN                        : std_logic_vector(0 downto 0);
  RXMCOMMAALIGNEN                : std_logic_vector(0 downto 0);
  RXPCOMMAALIGNEN                : std_logic_vector(0 downto 0);
  RXPCSRESET                     : std_logic_vector(0 downto 0);
  RXPMARESET                     : std_logic_vector(0 downto 0);
  RXPRBSCNTRESET                 : std_logic_vector(0 downto 0);
  RXPRBSSEL                      : std_logic_vector(3 downto 0);
  RXRATE                         : std_logic_vector(2 downto 0);
  TXCTRL0                        : std_logic_vector(15 downto 0);
  TXCTRL1                        : std_logic_vector(15 downto 0);
  TXDIFFCTRL                     : std_logic_vector(4 downto 0);
  TXINHIBIT                      : std_logic_vector(0 downto 0);
  TXPCSRESET                     : std_logic_vector(0 downto 0);
  TXPMARESET                     : std_logic_vector(0 downto 0);
  TXPOLARITY                     : std_logic_vector(0 downto 0);
  TXPOSTCURSOR                   : std_logic_vector(4 downto 0);
  TXPRBSFORCEERR                 : std_logic_vector(0 downto 0);
  TXPRBSSEL                      : std_logic_vector(3 downto 0);
  TXPRECURSOR                    : std_logic_vector(4 downto 0);
end record DEBUG_8B10B_channel_input_t;
type DEBUG_8B10B_channel_input_array_t is array (integer range <>) of DEBUG_8B10B_channel_input_t;
type DEBUG_8B10B_channel_output_t is record
  TXRX_TYPE                      : std_logic_vector(3 downto 0);
  CPLLLOCK                       : std_logic_vector(0 downto 0);
  DMONITOROUT                    : std_logic_vector(15 downto 0);
  EYESCANDATAERROR               : std_logic_vector(0 downto 0);
  GTPOWERGOOD                    : std_logic_vector(0 downto 0);
  RXBUFSTATUS                    : std_logic_vector(2 downto 0);
  RXBYTEISALIGNED                : std_logic_vector(0 downto 0);
  RXBYTEREALIGN                  : std_logic_vector(0 downto 0);
  RXCTRL2                        : std_logic_vector(7 downto 0);
  RXPMARESETDONE                 : std_logic_vector(0 downto 0);
  RXPRBSERR                      : std_logic_vector(0 downto 0);
  RXRESETDONE                    : std_logic_vector(0 downto 0);
  TXBUFSTATUS                    : std_logic_vector(1 downto 0);
  TXPMARESETDONE                 : std_logic_vector(0 downto 0);
  TXRESETDONE                    : std_logic_vector(0 downto 0);
end record DEBUG_8B10B_channel_output_t;
type DEBUG_8B10B_channel_output_array_t is array (integer range <>) of DEBUG_8B10B_channel_output_t;
type DEBUG_8B10B_userdata_input_t is record
  GTWIZ_USERDATA_TX              : std_logic_vector(31 downto 0);
  RX8B10BEN                      : std_logic_vector(0 downto 0);
  RXCOMMADETEN                   : std_logic_vector(0 downto 0);
  TX8B10BEN                      : std_logic_vector(0 downto 0);
  TXCTRL2                        : std_logic_vector(7 downto 0);
end record DEBUG_8B10B_userdata_input_t;
type DEBUG_8B10B_userdata_input_array_t is array (integer range <>) of DEBUG_8B10B_userdata_input_t;
type DEBUG_8B10B_userdata_output_t is record
  GTWIZ_USERDATA_RX              : std_logic_vector(31 downto 0);
  RXCOMMADET                     : std_logic_vector(0 downto 0);
  RXCTRL0                        : std_logic_vector(15 downto 0);
  RXCTRL1                        : std_logic_vector(15 downto 0);
  RXCTRL3                        : std_logic_vector(7 downto 0);
end record DEBUG_8B10B_userdata_output_t;
type DEBUG_8B10B_userdata_output_array_t is array (integer range <>) of DEBUG_8B10B_userdata_output_t;
type DEBUG_8B10B_drp_input_t is record
  ADDRESS                        : std_logic_vector(9 downto 0);
  CLK                            : std_logic_vector(0 downto 0);
  WR_DATA                        : std_logic_vector(15 downto 0);
  ENABLE                         : std_logic_vector(0 downto 0);
  RESET                          : std_logic_vector(0 downto 0);
  WR_ENABLE                      : std_logic_vector(0 downto 0);
end record DEBUG_8B10B_drp_input_t;
type DEBUG_8B10B_drp_input_array_t is array (integer range <>) of DEBUG_8B10B_drp_input_t;
type DEBUG_8B10B_drp_output_t is record
  RD_DATA                        : std_logic_vector(15 downto 0);
  RD_DATA_VALID                  : std_logic_vector(0 downto 0);
end record DEBUG_8B10B_drp_output_t;
type DEBUG_8B10B_drp_output_array_t is array (integer range <>) of DEBUG_8B10B_drp_output_t;
end package DEBUG_8B10B_PKG;
