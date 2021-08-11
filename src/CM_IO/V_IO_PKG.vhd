--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;


package V_IO_CTRL is
  type V_IO_C2C_STATUS_MON_t is record
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
  end record V_IO_C2C_STATUS_MON_t;


  type V_IO_C2C_STATUS_CTRL_t is record
    INITIALIZE                 :std_logic;     -- C2C initialize
  end record V_IO_C2C_STATUS_CTRL_t;


  constant DEFAULT_V_IO_C2C_STATUS_CTRL_t : V_IO_C2C_STATUS_CTRL_t := (
                                                                       INITIALIZE => '0'
                                                                      );
  type V_IO_C2C_DEBUG_RX_MON_t is record
    BUF_STATUS                 :std_logic_vector( 2 downto 0);  -- DEBUG rx buf status
    PRBS_ERR                   :std_logic;                      -- DEBUG rx PRBS error
    RESET_DONE                 :std_logic;                      -- DEBUG rx reset done
  end record V_IO_C2C_DEBUG_RX_MON_t;


  type V_IO_C2C_DEBUG_RX_CTRL_t is record
    BUF_RESET                  :std_logic;     -- DEBUG rx buf reset
    CDR_HOLD                   :std_logic;     -- DEBUG rx CDR hold
    DFE_LPM_RESET              :std_logic;     -- DEBUG rx DFE LPM RESET
    LPM_EN                     :std_logic;     -- DEBUG rx LPM ENABLE
    PCS_RESET                  :std_logic;     -- DEBUG rx pcs reset
    PMA_RESET                  :std_logic;     -- DEBUG rx pma reset
    PRBS_CNT_RST               :std_logic;     -- DEBUG rx PRBS counter reset
    PRBS_SEL                   :std_logic_vector( 3 downto 0);  -- DEBUG rx PRBS select
    RATE                       :std_logic_vector( 2 downto 0);  -- DEBUG rx rate
  end record V_IO_C2C_DEBUG_RX_CTRL_t;


  constant DEFAULT_V_IO_C2C_DEBUG_RX_CTRL_t : V_IO_C2C_DEBUG_RX_CTRL_t := (
                                                                           BUF_RESET => '0',
                                                                           CDR_HOLD => '0',
                                                                           DFE_LPM_RESET => '0',
                                                                           LPM_EN => '0',
                                                                           PCS_RESET => '0',
                                                                           PMA_RESET => '0',
                                                                           PRBS_CNT_RST => '0',
                                                                           PRBS_SEL => (others => '0'),
                                                                           RATE => (others => '0')
                                                                          );
  type V_IO_C2C_DEBUG_TX_MON_t is record
    BUF_STATUS                 :std_logic_vector( 1 downto 0);  -- DEBUG tx buf status
    RESET_DONE                 :std_logic;                      -- DEBUG tx reset done
  end record V_IO_C2C_DEBUG_TX_MON_t;


  type V_IO_C2C_DEBUG_TX_CTRL_t is record
    INHIBIT                    :std_logic;     -- DEBUG tx inhibit
    PCS_RESET                  :std_logic;     -- DEBUG tx pcs reset
    PMA_RESET                  :std_logic;     -- DEBUG tx pma reset
    POLARITY                   :std_logic;     -- DEBUG tx polarity
    POST_CURSOR                :std_logic_vector( 4 downto 0);  -- DEBUG post cursor
    PRBS_FORCE_ERR             :std_logic;                      -- DEBUG force PRBS error
    PRE_CURSOR                 :std_logic_vector( 4 downto 0);  -- DEBUG pre cursor
    PRBS_SEL                   :std_logic_vector( 3 downto 0);  -- DEBUG PRBS select
    DIFF_CTRL                  :std_logic_vector( 4 downto 0);  -- DEBUG tx diff control
  end record V_IO_C2C_DEBUG_TX_CTRL_t;


  constant DEFAULT_V_IO_C2C_DEBUG_TX_CTRL_t : V_IO_C2C_DEBUG_TX_CTRL_t := (
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
  type V_IO_C2C_DEBUG_MON_t is record
    DMONITOR                   :std_logic_vector(15 downto 0);  -- DEBUG d monitor
    QPLL_LOCK                  :std_logic;                      -- DEBUG cplllock
    CPLL_LOCK                  :std_logic;                      -- DEBUG cplllock
    EYESCAN_DATA_ERROR         :std_logic;                      -- DEBUG eyescan data error
    RX                         :V_IO_C2C_DEBUG_RX_MON_t;      
    TX                         :V_IO_C2C_DEBUG_TX_MON_t;      
  end record V_IO_C2C_DEBUG_MON_t;


  type V_IO_C2C_DEBUG_CTRL_t is record
    EYESCAN_RESET              :std_logic;     -- DEBUG eyescan reset
    EYESCAN_TRIGGER            :std_logic;     -- DEBUG eyescan trigger
    PCS_RSV_DIN                :std_logic_vector(15 downto 0);  -- bit 2 is DRP uber reset
    RX                         :V_IO_C2C_DEBUG_RX_CTRL_t;     
    TX                         :V_IO_C2C_DEBUG_TX_CTRL_t;     
  end record V_IO_C2C_DEBUG_CTRL_t;


  constant DEFAULT_V_IO_C2C_DEBUG_CTRL_t : V_IO_C2C_DEBUG_CTRL_t := (
                                                                     EYESCAN_RESET => '0',
                                                                     EYESCAN_TRIGGER => '0',
                                                                     PCS_RSV_DIN => (others => '0'),
                                                                     RX => DEFAULT_V_IO_C2C_DEBUG_RX_CTRL_t,
                                                                     TX => DEFAULT_V_IO_C2C_DEBUG_TX_CTRL_t
                                                                    );
  type V_IO_C2C_MON_t is record
    STATUS                     :V_IO_C2C_STATUS_MON_t;
    DEBUG                      :V_IO_C2C_DEBUG_MON_t; 
    USER_FREQ                  :std_logic_vector(31 downto 0);  -- Measured Freq of clock
  end record V_IO_C2C_MON_t;


  type V_IO_C2C_CTRL_t is record
    STATUS                     :V_IO_C2C_STATUS_CTRL_t;
    DEBUG                      :V_IO_C2C_DEBUG_CTRL_t; 
  end record V_IO_C2C_CTRL_t;


  constant DEFAULT_V_IO_C2C_CTRL_t : V_IO_C2C_CTRL_t := (
                                                         STATUS => DEFAULT_V_IO_C2C_STATUS_CTRL_t,
                                                         DEBUG => DEFAULT_V_IO_C2C_DEBUG_CTRL_t
                                                        );
  type V_IO_RGB_CTRL_t is record
    R                          :std_logic_vector( 7 downto 0);
    G                          :std_logic_vector( 7 downto 0);
    B                          :std_logic_vector( 7 downto 0);
  end record V_IO_RGB_CTRL_t;


  constant DEFAULT_V_IO_RGB_CTRL_t : V_IO_RGB_CTRL_t := (
                                                         R => x"00",
                                                         G => x"00",
                                                         B => x"ff"
                                                        );
  type V_IO_BRAM_MON_t is record
    RD_DATA                    :std_logic_vector(31 downto 0);
  end record V_IO_BRAM_MON_t;


  type V_IO_BRAM_CTRL_t is record
    WRITE                      :std_logic;   
    ADDR                       :std_logic_vector(14 downto 0);
    WR_DATA                    :std_logic_vector(31 downto 0);
  end record V_IO_BRAM_CTRL_t;


  constant DEFAULT_V_IO_BRAM_CTRL_t : V_IO_BRAM_CTRL_t := (
                                                           WRITE => '0',
                                                           ADDR => (others => '0'),
                                                           WR_DATA => (others => '0')
                                                          );
  type V_IO_MON_t is record
    C2C                        :V_IO_C2C_MON_t;
    CLK_200_LOCKED             :std_logic;     
    BRAM                       :V_IO_BRAM_MON_t;
  end record V_IO_MON_t;


  type V_IO_CTRL_t is record
    C2C                        :V_IO_C2C_CTRL_t;
    RGB                        :V_IO_RGB_CTRL_t;
    BRAM                       :V_IO_BRAM_CTRL_t;
  end record V_IO_CTRL_t;


  constant DEFAULT_V_IO_CTRL_t : V_IO_CTRL_t := (
                                                 C2C => DEFAULT_V_IO_C2C_CTRL_t,
                                                 RGB => DEFAULT_V_IO_RGB_CTRL_t,
                                                 BRAM => DEFAULT_V_IO_BRAM_CTRL_t
                                                );


end package V_IO_CTRL;