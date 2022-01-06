--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;


package C2C_INTF_CTRL is
  type C2C_INTF_C2C_DRP_MOSI_t is record
    clk       : std_logic;
    enable    : std_logic;
    wr_enable : std_logic;
    address   : std_logic_vector(10-1 downto 0);
    wr_data   : std_logic_vector(16-1 downto 0);
  end record C2C_INTF_C2C_DRP_MOSI_t;
  type C2C_INTF_C2C_DRP_MISO_t is record
    rd_data         : std_logic_vector(16-1 downto 0);
    rd_data_valid   : std_logic;
  end record C2C_INTF_C2C_DRP_MISO_t;
  constant Default_C2C_INTF_C2C_DRP_MOSI_t : C2C_INTF_C2C_DRP_MOSI_t := ( 
                                                     clk       => '0',
                                                     enable    => '0',
                                                     wr_enable => '0',
                                                     address   => (others => '0'),
                                                     wr_data   => (others => '0')
  );
  type C2C_INTF_C2C_STATUS_MON_t is record
    CONFIG_ERROR               :std_logic;     -- C2C config error
    LINK_ERROR                 :std_logic;     -- C2C link error
    LINK_GOOD                  :std_logic;     -- C2C link FSM in SYNC
    MB_ERROR                   :std_logic;     -- C2C multi-bit error
    DO_CC                      :std_logic;     -- Aurora do CC
    PHY_RESET                  :std_logic;     -- Aurora phy in reset
    PHY_GT_PLL_LOCK            :std_logic;     -- Aurora phy GT PLL locked
    PHY_MMCM_LOL               :std_logic;     -- Aurora phy mmcm LOL
    PHY_LANE_UP                :std_logic_vector( 1 downto 0);  -- Aurora phy lanes up
    PHY_HARD_ERR               :std_logic;                      -- Aurora phy hard error
    PHY_SOFT_ERR               :std_logic;                      -- Aurora phy soft error
    CHANNEL_UP                 :std_logic;                      -- Channel up
    LINK_IN_FW                 :std_logic;                      -- FW includes this link
  end record C2C_INTF_C2C_STATUS_MON_t;


  type C2C_INTF_C2C_STATUS_CTRL_t is record
    INITIALIZE                 :std_logic;     -- C2C initialize
  end record C2C_INTF_C2C_STATUS_CTRL_t;


  constant DEFAULT_C2C_INTF_C2C_STATUS_CTRL_t : C2C_INTF_C2C_STATUS_CTRL_t := (
                                                                               INITIALIZE => '0'
                                                                              );
  type C2C_INTF_C2C_DEBUG_RX_MON_t is record
    BUF_STATUS                 :std_logic_vector( 2 downto 0);  -- DEBUG rx buf status
    PMA_RESET_DONE             :std_logic;                      -- DEBUG rx reset done
    PRBS_ERR                   :std_logic;                      -- DEBUG rx PRBS error
    RESET_DONE                 :std_logic;                      -- DEBUG rx reset done
  end record C2C_INTF_C2C_DEBUG_RX_MON_t;


  type C2C_INTF_C2C_DEBUG_RX_CTRL_t is record
    BUF_RESET                  :std_logic;     -- DEBUG rx buf reset
    CDR_HOLD                   :std_logic;     -- DEBUG rx CDR hold
    DFE_LPM_RESET              :std_logic;     -- DEBUG rx DFE LPM RESET
    LPM_EN                     :std_logic;     -- DEBUG rx LPM ENABLE
    PCS_RESET                  :std_logic;     -- DEBUG rx pcs reset
    PMA_RESET                  :std_logic;     -- DEBUG rx pma reset
    PRBS_CNT_RST               :std_logic;     -- DEBUG rx PRBS counter reset
    PRBS_SEL                   :std_logic_vector( 3 downto 0);  -- DEBUG rx PRBS select
    RATE                       :std_logic_vector( 2 downto 0);  -- DEBUG rx rate
  end record C2C_INTF_C2C_DEBUG_RX_CTRL_t;


  constant DEFAULT_C2C_INTF_C2C_DEBUG_RX_CTRL_t : C2C_INTF_C2C_DEBUG_RX_CTRL_t := (
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
  type C2C_INTF_C2C_DEBUG_TX_MON_t is record
    BUF_STATUS                 :std_logic_vector( 1 downto 0);  -- DEBUG tx buf status
    RESET_DONE                 :std_logic;                      -- DEBUG tx reset done
  end record C2C_INTF_C2C_DEBUG_TX_MON_t;


  type C2C_INTF_C2C_DEBUG_TX_CTRL_t is record
    INHIBIT                    :std_logic;     -- DEBUG tx inhibit
    PCS_RESET                  :std_logic;     -- DEBUG tx pcs reset
    PMA_RESET                  :std_logic;     -- DEBUG tx pma reset
    POLARITY                   :std_logic;     -- DEBUG tx polarity
    POST_CURSOR                :std_logic_vector( 4 downto 0);  -- DEBUG post cursor
    PRBS_FORCE_ERR             :std_logic;                      -- DEBUG force PRBS error
    PRE_CURSOR                 :std_logic_vector( 4 downto 0);  -- DEBUG pre cursor
    PRBS_SEL                   :std_logic_vector( 3 downto 0);  -- DEBUG PRBS select
    DIFF_CTRL                  :std_logic_vector( 4 downto 0);  -- DEBUG tx diff control
  end record C2C_INTF_C2C_DEBUG_TX_CTRL_t;


  constant DEFAULT_C2C_INTF_C2C_DEBUG_TX_CTRL_t : C2C_INTF_C2C_DEBUG_TX_CTRL_t := (
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
  type C2C_INTF_C2C_DEBUG_MON_t is record
    DMONITOR                   :std_logic_vector(15 downto 0);  -- DEBUG d monitor
    QPLL_LOCK                  :std_logic;                      -- DEBUG cplllock
    CPLL_LOCK                  :std_logic;                      -- DEBUG cplllock
    EYESCAN_DATA_ERROR         :std_logic;                      -- DEBUG eyescan data error
    RX                         :C2C_INTF_C2C_DEBUG_RX_MON_t;  
    TX                         :C2C_INTF_C2C_DEBUG_TX_MON_t;  
  end record C2C_INTF_C2C_DEBUG_MON_t;


  type C2C_INTF_C2C_DEBUG_CTRL_t is record
    EYESCAN_RESET              :std_logic;     -- DEBUG eyescan reset
    EYESCAN_TRIGGER            :std_logic;     -- DEBUG eyescan trigger
    PCS_RSV_DIN                :std_logic_vector(15 downto 0);  -- bit 2 is DRP uber reset
    RX                         :C2C_INTF_C2C_DEBUG_RX_CTRL_t; 
    TX                         :C2C_INTF_C2C_DEBUG_TX_CTRL_t; 
  end record C2C_INTF_C2C_DEBUG_CTRL_t;


  constant DEFAULT_C2C_INTF_C2C_DEBUG_CTRL_t : C2C_INTF_C2C_DEBUG_CTRL_t := (
                                                                             EYESCAN_RESET => '0',
                                                                             EYESCAN_TRIGGER => '0',
                                                                             PCS_RSV_DIN => (others => '0'),
                                                                             RX => DEFAULT_C2C_INTF_C2C_DEBUG_RX_CTRL_t,
                                                                             TX => DEFAULT_C2C_INTF_C2C_DEBUG_TX_CTRL_t
                                                                            );
  type C2C_INTF_C2C_COUNTERS_MON_t is record
    ERRORS_ALL_TIME            :std_logic_vector(31 downto 0);  -- Counter for all errors while locked
    ERRORS_SINCE_LOCKED        :std_logic_vector(31 downto 0);  -- Counter for errors since locked
    CONFIG_ERROR_COUNT         :std_logic_vector(31 downto 0);  -- Counter for CONFIG_ERROR
    LINK_ERROR_COUNT           :std_logic_vector(31 downto 0);  -- Counter for LINK_ERROR
    MB_ERROR_COUNT             :std_logic_vector(31 downto 0);  -- Counter for MB_ERROR
    PHY_HARD_ERROR_COUNT       :std_logic_vector(31 downto 0);  -- Counter for PHY_HARD_ERROR
    PHY_SOFT_ERROR_COUNT       :std_logic_vector(31 downto 0);  -- Counter for PHY_SOFT_ERROR
    PHYLANE_STATE              :std_logic_vector( 2 downto 0);  -- Current state of phy_lane_control module
    ERROR_WAITS_SINCE_LOCKED   :std_logic_vector(31 downto 0);  -- Count for phylane in error state
    USER_CLK_FREQ              :std_logic_vector(31 downto 0);  -- Frequency of the user C2C clk
    XCVR_RESETS                :std_logic_vector(31 downto 0);  -- Count for phylane in error state
    WAITING_TIMEOUTS           :std_logic_vector(31 downto 0);  -- Count of initialize cycles
    SB_ERROR_RATE              :std_logic_vector(31 downto 0);  -- single bit error rate
    MB_ERROR_RATE              :std_logic_vector(31 downto 0);  -- multi bit error rate
  end record C2C_INTF_C2C_COUNTERS_MON_t;


  type C2C_INTF_C2C_COUNTERS_CTRL_t is record
    RESET_COUNTERS             :std_logic;     -- Reset counters in Monitor
  end record C2C_INTF_C2C_COUNTERS_CTRL_t;


  constant DEFAULT_C2C_INTF_C2C_COUNTERS_CTRL_t : C2C_INTF_C2C_COUNTERS_CTRL_t := (
                                                                                   RESET_COUNTERS => '0'
                                                                                  );
  type C2C_INTF_C2C_MON_t is record
    DRP                        :C2C_INTF_C2C_DRP_MISO_t;
    STATUS                     :C2C_INTF_C2C_STATUS_MON_t;
    DEBUG                      :C2C_INTF_C2C_DEBUG_MON_t; 
    COUNTERS                   :C2C_INTF_C2C_COUNTERS_MON_t;
    USER_FREQ                  :std_logic_vector(31 downto 0);  -- Measured Freq of clock
  end record C2C_INTF_C2C_MON_t;
  type C2C_INTF_C2C_MON_t_ARRAY is array(1 to 2) of C2C_INTF_C2C_MON_t;

  type C2C_INTF_C2C_CTRL_t is record
    DRP                        :C2C_INTF_C2C_DRP_MOSI_t;
    STATUS                     :C2C_INTF_C2C_STATUS_CTRL_t;
    DEBUG                      :C2C_INTF_C2C_DEBUG_CTRL_t; 
    COUNTERS                   :C2C_INTF_C2C_COUNTERS_CTRL_t;
    PHY_READ_TIME              :std_logic_vector(23 downto 0);  -- Time spent waiting for phylane to stabilize
    ENABLE_PHY_CTRL            :std_logic;                      -- phy_lane_control is enabled
    PHY_LANE_STABLE            :std_logic_vector(19 downto 0);  -- Contious phy_lane_up signals required to lock phylane control
    PHY_LANE_ERRORS_TO_RESET   :std_logic_vector( 7 downto 0);  -- Number of failures before we reset the pma
    PHY_MAX_SINGLE_BIT_ERROR_RATE  :std_logic_vector(31 downto 0);  -- Max single bit error rate
    PHY_MAX_MULTI_BIT_ERROR_RATE   :std_logic_vector(31 downto 0);  -- Max multi bit error rate
  end record C2C_INTF_C2C_CTRL_t;
  type C2C_INTF_C2C_CTRL_t_ARRAY is array(1 to 2) of C2C_INTF_C2C_CTRL_t;

  constant DEFAULT_C2C_INTF_C2C_CTRL_t : C2C_INTF_C2C_CTRL_t := (
                                                                 DRP => Default_C2C_INTF_C2C_DRP_MOSI_t,
                                                                 STATUS => DEFAULT_C2C_INTF_C2C_STATUS_CTRL_t,
                                                                 DEBUG => DEFAULT_C2C_INTF_C2C_DEBUG_CTRL_t,
                                                                 COUNTERS => DEFAULT_C2C_INTF_C2C_COUNTERS_CTRL_t,
                                                                 PHY_READ_TIME => x"4c4b40",
                                                                 ENABLE_PHY_CTRL => '1',
                                                                 PHY_LANE_STABLE => x"000ff",
                                                                 PHY_LANE_ERRORS_TO_RESET => x"ff",
                                                                 PHY_MAX_SINGLE_BIT_ERROR_RATE => x"0000ffff",
                                                                 PHY_MAX_MULTI_BIT_ERROR_RATE => x"0000ffff"
                                                                );
  type C2C_INTF_PB_MEM_MOSI_t is record
    clk       : std_logic;
    enable    : std_logic;
    wr_enable : std_logic;
    address   : std_logic_vector(11-1 downto 0);
    wr_data   : std_logic_vector(18-1 downto 0);
  end record C2C_INTF_PB_MEM_MOSI_t;
  type C2C_INTF_PB_MEM_MISO_t is record
    rd_data         : std_logic_vector(18-1 downto 0);
    rd_data_valid   : std_logic;
  end record C2C_INTF_PB_MEM_MISO_t;
  constant Default_C2C_INTF_PB_MEM_MOSI_t : C2C_INTF_PB_MEM_MOSI_t := ( 
                                                     clk       => '0',
                                                     enable    => '0',
                                                     wr_enable => '0',
                                                     address   => (others => '0'),
                                                     wr_data   => (others => '0')
  );
  type C2C_INTF_PB_MON_t is record
    MEM                        :C2C_INTF_PB_MEM_MISO_t;
  end record C2C_INTF_PB_MON_t;


  type C2C_INTF_PB_CTRL_t is record
    MEM                        :C2C_INTF_PB_MEM_MOSI_t;
    RESET                      :std_logic;             
    IRQ_COUNT                  :std_logic_vector(31 downto 0);
  end record C2C_INTF_PB_CTRL_t;


  constant DEFAULT_C2C_INTF_PB_CTRL_t : C2C_INTF_PB_CTRL_t := (
                                                               MEM => Default_C2C_INTF_PB_MEM_MOSI_t,
                                                               RESET => '0',
                                                               IRQ_COUNT => x"00989680"
                                                              );
  type C2C_INTF_MON_t is record
    C2C                        :C2C_INTF_C2C_MON_t_ARRAY;
    PB                         :C2C_INTF_PB_MON_t;       
  end record C2C_INTF_MON_t;


  type C2C_INTF_CTRL_t is record
    C2C                        :C2C_INTF_C2C_CTRL_t_ARRAY;
    PB                         :C2C_INTF_PB_CTRL_t;       
  end record C2C_INTF_CTRL_t;


  constant DEFAULT_C2C_INTF_CTRL_t : C2C_INTF_CTRL_t := (
                                                         C2C => (others => DEFAULT_C2C_INTF_C2C_CTRL_t ),
                                                         PB => DEFAULT_C2C_INTF_PB_CTRL_t
                                                        );


end package C2C_INTF_CTRL;