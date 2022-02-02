--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;


package K_TCDS_CTRL is
  type K_TCDS_CLOCKING_MON_t is record
    POWER_GOOD                 :std_logic;   
    RX_CDR_STABLE              :std_logic;   
    COUNTS_TXOUTCLK            :std_logic_vector(31 downto 0);
  end record K_TCDS_CLOCKING_MON_t;


  type K_TCDS_RESET_CTRL_t is record
    RESET_ALL                  :std_logic;   
    TX_PLL_AND_DATAPATH        :std_logic;   
    TX_DATAPATH                :std_logic;   
    RX_PLL_AND_DATAPATH        :std_logic;   
    RX_DATAPATH                :std_logic;   
    USERCLK_TX                 :std_logic;   
    USERCLK_RX                 :std_logic;   
    DRP                        :std_logic;   
  end record K_TCDS_RESET_CTRL_t;


  constant DEFAULT_K_TCDS_RESET_CTRL_t : K_TCDS_RESET_CTRL_t := (
                                                                 RESET_ALL => '0',
                                                                 TX_PLL_AND_DATAPATH => '0',
                                                                 TX_DATAPATH => '0',
                                                                 RX_PLL_AND_DATAPATH => '0',
                                                                 RX_DATAPATH => '0',
                                                                 USERCLK_TX => '0',
                                                                 USERCLK_RX => '0',
                                                                 DRP => '0'
                                                                );
  type K_TCDS_STATUS_MON_t is record
    PHY_RESET                  :std_logic;     -- Aurora phy in reset
    PHY_GT_PLL_LOCK            :std_logic;     -- Aurora phy GT PLL locked
    PHY_MMCM_LOL               :std_logic;     -- Aurora phy mmcm LOL
  end record K_TCDS_STATUS_MON_t;


  type K_TCDS_DEBUG_RX_MON_t is record
    BUF_STATUS                 :std_logic_vector( 2 downto 0);  -- DEBUG rx buf status
    PMA_RESET_DONE             :std_logic;                      -- DEBUG rx reset done
    PRBS_ERR                   :std_logic;                      -- DEBUG rx PRBS error
    RESET_DONE                 :std_logic;                      -- DEBUG rx reset done
  end record K_TCDS_DEBUG_RX_MON_t;


  type K_TCDS_DEBUG_RX_CTRL_t is record
    BUF_RESET                  :std_logic;     -- DEBUG rx buf reset
    CDR_HOLD                   :std_logic;     -- DEBUG rx CDR hold
    DFE_LPM_RESET              :std_logic;     -- DEBUG rx DFE LPM RESET
    LPM_EN                     :std_logic;     -- DEBUG rx LPM ENABLE
    PCS_RESET                  :std_logic;     -- DEBUG rx pcs reset
    PMA_RESET                  :std_logic;     -- DEBUG rx pma reset
    PRBS_CNT_RST               :std_logic;     -- DEBUG rx PRBS counter reset
    PRBS_SEL                   :std_logic_vector( 3 downto 0);  -- DEBUG rx PRBS select
    RATE                       :std_logic_vector( 2 downto 0);  -- DEBUG rx rate
  end record K_TCDS_DEBUG_RX_CTRL_t;


  constant DEFAULT_K_TCDS_DEBUG_RX_CTRL_t : K_TCDS_DEBUG_RX_CTRL_t := (
                                                                       BUF_RESET => '0',
                                                                       CDR_HOLD => '0',
                                                                       DFE_LPM_RESET => '0',
                                                                       LPM_EN => '1',
                                                                       PCS_RESET => '0',
                                                                       PMA_RESET => '0',
                                                                       PRBS_CNT_RST => '0',
                                                                       PRBS_SEL => (others => '0'),
                                                                       RATE => (others => '0')
                                                                      );
  type K_TCDS_DEBUG_TX_MON_t is record
    BUF_STATUS                 :std_logic_vector( 1 downto 0);  -- DEBUG tx buf status
    RESET_DONE                 :std_logic;                      -- DEBUG tx reset done
  end record K_TCDS_DEBUG_TX_MON_t;


  type K_TCDS_DEBUG_TX_CTRL_t is record
    INHIBIT                    :std_logic;     -- DEBUG tx inhibit
    PCS_RESET                  :std_logic;     -- DEBUG tx pcs reset
    PMA_RESET                  :std_logic;     -- DEBUG tx pma reset
    POLARITY                   :std_logic;     -- DEBUG tx polarity
    POST_CURSOR                :std_logic_vector( 4 downto 0);  -- DEBUG post cursor
    PRBS_FORCE_ERR             :std_logic;                      -- DEBUG force PRBS error
    PRE_CURSOR                 :std_logic_vector( 4 downto 0);  -- DEBUG pre cursor
    PRBS_SEL                   :std_logic_vector( 3 downto 0);  -- DEBUG PRBS select
    DIFF_CTRL                  :std_logic_vector( 4 downto 0);  -- DEBUG tx diff control
  end record K_TCDS_DEBUG_TX_CTRL_t;


  constant DEFAULT_K_TCDS_DEBUG_TX_CTRL_t : K_TCDS_DEBUG_TX_CTRL_t := (
                                                                       INHIBIT => '0',
                                                                       PCS_RESET => '0',
                                                                       PMA_RESET => '0',
                                                                       POLARITY => '0',
                                                                       POST_CURSOR => (others => '0'),
                                                                       PRBS_FORCE_ERR => '0',
                                                                       PRE_CURSOR => (others => '0'),
                                                                       PRBS_SEL => (others => '0'),
                                                                       DIFF_CTRL => (others => '0')
                                                                      );
  type K_TCDS_DEBUG_MON_t is record
    DMONITOR                   :std_logic_vector(15 downto 0);  -- DEBUG d monitor
    QPLL_LOCK                  :std_logic;                      -- DEBUG cplllock
    CPLL_LOCK                  :std_logic;                      -- DEBUG cplllock
    EYESCAN_DATA_ERROR         :std_logic;                      -- DEBUG eyescan data error
    RX                         :K_TCDS_DEBUG_RX_MON_t;        
    TX                         :K_TCDS_DEBUG_TX_MON_t;        
  end record K_TCDS_DEBUG_MON_t;


  type K_TCDS_DEBUG_CTRL_t is record
    EYESCAN_RESET              :std_logic;     -- DEBUG eyescan reset
    EYESCAN_TRIGGER            :std_logic;     -- DEBUG eyescan trigger
    PCS_RSV_DIN                :std_logic_vector(15 downto 0);  -- bit 2 is DRP uber reset
    RX                         :K_TCDS_DEBUG_RX_CTRL_t;       
    TX                         :K_TCDS_DEBUG_TX_CTRL_t;       
  end record K_TCDS_DEBUG_CTRL_t;


  constant DEFAULT_K_TCDS_DEBUG_CTRL_t : K_TCDS_DEBUG_CTRL_t := (
                                                                 EYESCAN_RESET => '0',
                                                                 EYESCAN_TRIGGER => '0',
                                                                 PCS_RSV_DIN => (others => '0'),
                                                                 RX => DEFAULT_K_TCDS_DEBUG_RX_CTRL_t,
                                                                 TX => DEFAULT_K_TCDS_DEBUG_TX_CTRL_t
                                                                );
  type K_TCDS_TX_MON_t is record
    ACTIVE                     :std_logic;   
  end record K_TCDS_TX_MON_t;


  type K_TCDS_TX_CTRL_t is record
    CTRL0                      :std_logic_vector(15 downto 0);
    CTRL1                      :std_logic_vector(15 downto 0);
    CTRL2                      :std_logic_vector( 7 downto 0);
    RESET                      :std_logic;                    
  end record K_TCDS_TX_CTRL_t;


  constant DEFAULT_K_TCDS_TX_CTRL_t : K_TCDS_TX_CTRL_t := (
                                                           CTRL0 => (others => '0'),
                                                           CTRL1 => (others => '0'),
                                                           CTRL2 => (others => '0'),
                                                           RESET => '0'
                                                          );
  type K_TCDS_RX_MON_t is record
    CTRL0                      :std_logic_vector(15 downto 0);
    CTRL1                      :std_logic_vector(15 downto 0);
    CTRL2                      :std_logic_vector( 7 downto 0);
    ACTIVE                     :std_logic;                    
    CTRL3                      :std_logic_vector( 7 downto 0);
  end record K_TCDS_RX_MON_t;


  type K_TCDS_RX_CTRL_t is record
    RESET                      :std_logic;   
  end record K_TCDS_RX_CTRL_t;


  constant DEFAULT_K_TCDS_RX_CTRL_t : K_TCDS_RX_CTRL_t := (
                                                           RESET => '0'
                                                          );
  type K_TCDS_DATA_CTRL_MON_t is record
    CAPTURE_D                  :std_logic_vector(31 downto 0);
    CAPTURE_K                  :std_logic_vector( 3 downto 0);
  end record K_TCDS_DATA_CTRL_MON_t;


  type K_TCDS_DATA_CTRL_CTRL_t is record
    CAPTURE                    :std_logic;   
    MODE                       :std_logic_vector( 3 downto 0);
    FIXED_SEND_D               :std_logic_vector(31 downto 0);
    FIXED_SEND_K               :std_logic_vector( 3 downto 0);
  end record K_TCDS_DATA_CTRL_CTRL_t;


  constant DEFAULT_K_TCDS_DATA_CTRL_CTRL_t : K_TCDS_DATA_CTRL_CTRL_t := (
                                                                         CAPTURE => '0',
                                                                         MODE => (others => '0'),
                                                                         FIXED_SEND_D => (others => '0'),
                                                                         FIXED_SEND_K => (others => '0')
                                                                        );
  type K_TCDS_DRP_MOSI_t is record
    clk       : std_logic;
    enable    : std_logic;
    wr_enable : std_logic;
    address   : std_logic_vector(10-1 downto 0);
    wr_data   : std_logic_vector(16-1 downto 0);
  end record K_TCDS_DRP_MOSI_t;
  type K_TCDS_DRP_MISO_t is record
    rd_data         : std_logic_vector(16-1 downto 0);
    rd_data_valid   : std_logic;
  end record K_TCDS_DRP_MISO_t;
  constant Default_K_TCDS_DRP_MOSI_t : K_TCDS_DRP_MOSI_t := ( 
                                                     clk       => '0',
                                                     enable    => '0',
                                                     wr_enable => '0',
                                                     address   => (others => '0'),
                                                     wr_data   => (others => '0')
  );
  type K_TCDS_MON_t is record
    CLOCKING                   :K_TCDS_CLOCKING_MON_t;
    STATUS                     :K_TCDS_STATUS_MON_t;  
    DEBUG                      :K_TCDS_DEBUG_MON_t;   
    TX                         :K_TCDS_TX_MON_t;      
    RX                         :K_TCDS_RX_MON_t;      
    DATA_CTRL                  :K_TCDS_DATA_CTRL_MON_t;
    DRP                        :K_TCDS_DRP_MISO_t;     
  end record K_TCDS_MON_t;


  type K_TCDS_CTRL_t is record
    RESET                      :K_TCDS_RESET_CTRL_t;
    DEBUG                      :K_TCDS_DEBUG_CTRL_t;
    TX                         :K_TCDS_TX_CTRL_t;   
    RX                         :K_TCDS_RX_CTRL_t;   
    DATA_CTRL                  :K_TCDS_DATA_CTRL_CTRL_t;
    TXRX_CLK_SEL               :std_logic;              
    LOOPBACK                   :std_logic_vector( 2 downto 0);
    DRP                        :K_TCDS_DRP_MOSI_t;            
  end record K_TCDS_CTRL_t;


  constant DEFAULT_K_TCDS_CTRL_t : K_TCDS_CTRL_t := (
                                                     RESET => DEFAULT_K_TCDS_RESET_CTRL_t,
                                                     DEBUG => DEFAULT_K_TCDS_DEBUG_CTRL_t,
                                                     TX => DEFAULT_K_TCDS_TX_CTRL_t,
                                                     RX => DEFAULT_K_TCDS_RX_CTRL_t,
                                                     DATA_CTRL => DEFAULT_K_TCDS_DATA_CTRL_CTRL_t,
                                                     TXRX_CLK_SEL => '0',
                                                     LOOPBACK => (others => '0'),
                                                     DRP => Default_K_TCDS_DRP_MOSI_t
                                                    );


end package K_TCDS_CTRL;