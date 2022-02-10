library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.AXIRegWidthPkg.all;
use work.AXIRegPkg.all;
use work.types.all;
use work.C2C_INTF_CTRL.all;
use work.uC_LINK.all;


Library UNISIM;
use UNISIM.vcomponents.all;

entity C2C_INTF is
  generic (
    SM_LANES         : std_logic_vector(2 downto 1) := "01"; -- active links on
    CLKFREQ          : integer := 50000000;       --clk frequency in Hz
    ERROR_WAIT_TIME  : integer := 50000000);      --Wait time for error checking states
  port (
    clk_axi           : in  std_logic;
    reset_axi_n       : in  std_logic;
    readMOSI          : in  AXIReadMOSI;
    readMISO          : out AXIReadMISO  := DefaultAXIReadMISO;
    writeMOSI         : in  AXIWriteMOSI;
    writeMISO         : out AXIWriteMISO := DefaultAXIWriteMISO;
    clk_C2C           : in  std_logic_vector(2 downto 1);
    UART_Rx           : in  std_logic;               -- serial in
    UART_Tx           : out std_logic := '1';       -- serial out
    Mon               : in  C2C_INTF_MON_t;
    Ctrl              : out C2C_INTF_CTRL_t
    );
end entity C2C_INTF;

architecture behavioral of C2C_INTF is
  constant HW_LINK_COUNT : integer := 2;
  
  constant DATA_WIDTH : integer := 32;
  

  --phy_lane_control
  signal phylanelock     : std_logic_vector(HW_LINK_COUNT downto 1);
  signal aurora_init_buf : std_logic_vector(HW_LINK_COUNT downto 1);
  signal phy_reset       : std_logic_vector(HW_LINK_COUNT downto 1);
  signal phycontrol_en   : std_logic_vector(HW_LINK_COUNT downto 1);
    
  signal reset : std_logic;                     


--  constant INACTIVE_COUNT : slv_32_t := x"03FFFFFF";
 
  signal counter_en      : std_logic_vector(HW_LINK_COUNT downto 1);
  constant COUNTER_COUNT : integer := 5;
  signal C2C_counter     : slv32_array_t(0 to (HW_LINK_COUNT*COUNTER_COUNT)-1);
  signal counter_events  : std_logic_vector(  (HW_LINK_COUNT*COUNTER_COUNT)-1 downto 0);

  signal PRBS_CNT_RST    : std_logic_vector(HW_LINK_COUNT*COUNTER_COUNT downto 1);
  signal PRBS_FORCE_ERR  : std_logic_vector(HW_LINK_COUNT*COUNTER_COUNT downto 1);
  
  signal Mon_local  : C2C_INTF_MON_t;
  signal Ctrl_local : C2C_INTF_CTRL_t;


  signal single_bit_error_rate : slv32_array_t(HW_LINK_COUNT downto 1);
  signal multi_bit_error_rate : slv32_array_t(HW_LINK_COUNT downto 1);
  signal link_INFO_out : uC_Link_out_t_array(0 to HW_LINK_COUNT-1);
  signal link_INFO_in  : uC_Link_in_t_array (0 to HW_LINK_COUNT-1);

  constant one :std_logic := '1';
  constant zero :std_logic := '1';
  
begin
  --reset
  reset <= not reset_axi_n;

  

  --For AXI
  C2C_INTF_1: entity work.C2C_INTF_map
    port map (
      clk_axi         => clk_axi,
      reset_axi_n     => reset_axi_n,
      slave_readMOSI  => readMOSI,
      slave_readMISO  => readMISO,
      slave_writeMOSI => writeMOSI,
      slave_writeMISO => writeMISO,
      Mon             => Mon_local,
      Ctrl            => Ctrl_local);


  -------------------------------------------------------------------------------
  -- AXI 
  -------------------------------------------------------------------------------

  rd_dv: process(clk_axi) is
  begin
    if clk_axi'event and clk_axi = '1' then
      MON_local.PB.MEM.rd_data_valid <= CTRL_local.PB.MEM.enable;
    end if;
  end process rd_dv;
  uC_1: entity work.uC
    generic map(
      LINK_COUNT => 2)
    port map (
      clk                   => clk_axi,
      reset                 => reset,
      reprogram_addr        => CTRL_local.PB.MEM.address,
      reprogram_wen         => CTRL_local.PB.MEM.wr_enable,
      reprogram_di          => CTRL_local.PB.MEM.wr_data,
      reprogram_do          => MON_local.PB.MEM.rd_data,
      reprogram_reset       => CTRL_local.PB.reset,
      UART_Rx               => UART_Rx,
      UART_Tx               => UART_Tx,
      irq_count             => CTRL_local.PB.IRQ_COUNT,
      link_INFO_in          => link_INFO_in,
      link_INFO_out         => link_INFO_out
      );

  

  GENERATE_LANE_LOOP: for iLane in 1 to HW_LINK_COUNT generate
  begin      
    --For signals variable on CM_COUNT
    phycontrol_en(iLane) <= CTRL_local.C2C(iLane).ENABLE_PHY_CTRL;
    counter_en(iLane)    <= '1';

    rate_counter_C2C_USER: entity work.rate_counter
      generic map (
        CLK_A_1_SECOND => 50000000)
      port map (
        clk_A         => clk_axi,
        clk_B         => clk_C2C(iLane),
        reset_A_async => reset or Mon.C2C(iLane).status.phy_mmcm_lol,
        event_b       => one,--'1',
        rate          => Mon_local.C2C(iLane).COUNTERS.USER_CLK_FREQ);            
    
    -------------------------------------------------------------------------------
    -- DC data CDC
    -------------------------------------------------------------------------------
    
    pacd_1: entity work.pacd
      port map (
        iPulseA => Ctrl_local.C2C(iLane).DEBUG.RX.PRBS_CNT_RST,
        iClkA   => clk_axi,
        iRSTA   => reset,
        iClkB   => clk_C2C(iLane),
        iRSTB   => reset,
        oPulseB => PRBS_CNT_RST(iLane));
    pacd_2: entity work.pacd
      port map (
        iPulseA => Ctrl_local.C2C(iLane).DEBUG.TX.PRBS_FORCE_ERR,
        iClkA   => clk_axi,
        iRSTA   => reset,
        iClkB   => clk_C2C(iLane),
        iRSTB   => reset,
        oPulseB => PRBS_FORCE_ERR(iLane));


    
    assignment: process (CTRL_local.C2C(iLane),Mon.C2C(iLane),PRBS_CNT_RST,PRBS_FORCE_ERR,aurora_init_buf,phy_reset ) is
    begin  -- process assignment
      CTRL.C2C(iLane) <= Ctrl_local.C2C(iLane);
      CTRL.C2C(iLane).DEBUG.RX.PRBS_CNT_RST   <= PRBS_CNT_RST(iLane);
      CTRL.C2C(iLane).DEBUG.TX.PRBS_FORCE_ERR <= PRBS_FORCE_ERR(iLane);
      CTRL.C2C(iLane).DRP.enable   <= Ctrl_local.C2C(iLane).DRP.enable or Ctrl_local.C2C(iLane).DRP.wr_enable;
      
      if CTRL_local.C2C(iLane).ENABLE_PHY_CTRL = '1' then
        Ctrl.C2C(iLane).STATUS.INITIALIZE  <= aurora_init_buf(iLane);
        Ctrl.C2C(iLane).DEBUG.RX.PMA_RESET <= phy_reset(iLane) or Ctrl_local.C2C(iLane).DEBUG.RX.PMA_RESET;
      else 
        Ctrl.C2C(iLane).STATUS.INITIALIZE  <= CTRL_local.C2C(iLane).STATUS.INITIALIZE;
        Ctrl.C2C(iLane).DEBUG.RX.PMA_RESET <= Ctrl_local.C2C(iLane).DEBUG.RX.PMA_RESET;
      end if;

      
      Mon_local.C2C(iLane).STATUS <= Mon.C2C(iLane).STATUS;
      Mon_local.C2C(iLane).DEBUG  <= Mon.C2C(iLane).DEBUG;
      Mon_local.C2C(iLane).DRP    <= Mon.C2C(iLane).DRP;
      Mon_local.C2C(iLane).USER_FREQ <= Mon.C2C(iLane).USER_FREQ;
      
    end process assignment;

    

    -------------------------------------------------------------------------------
    -- Phy_lane_control
    -------------------------------------------------------------------------------

--    Phy_lane_control_X: entity work.CM_phy_lane_control
--      generic map (
--        CLKFREQ          => CLKFREQ,
--        DATA_WIDTH       => DATA_WIDTH,
--        ERROR_WAIT_TIME  => ERROR_WAIT_TIME)
--      port map (
--        clk              => clk_axi,
--        reset            => reset,
--        reset_counter    => CTRL_local.C2C(iLane).COUNTERS.RESET_COUNTERS,
--        enable           => phycontrol_en(iLane),
--        phy_lane_up      => Mon.C2C(iLane).status.phy_lane_up(0),
--        phy_lane_stable  => CTRL_local.C2C(iLane).PHY_LANE_STABLE,
--        failed_cnt_to_rst=> CTRL_local.C2C(iLane).PHY_LANE_ERRORS_TO_RESET,
--        READ_TIME        => CTRL_local.C2C(iLane).PHY_READ_TIME,
--        initialize_out   => aurora_init_buf(iLane),
--        lock             => phylanelock(iLane),
--        state_out        => Mon_local.C2C(iLane).COUNTERS.PHYLANE_STATE,
--        xcvr_reset       => phy_reset(iLane),
--        xcvr_reset_done  => Mon_local.C2C(iLane).DEBUG.RX.PMA_RESET_DONE,
--        single_bit_error    => Mon_local.C2C(iLane).STATUS.LINK_ERROR,
--        single_bit_rate_max => CTRL_local.C2C(iLane).PHY_MAX_SINGLE_BIT_ERROR_RATE,
--        multi_bit_error     => Mon_local.C2C(iLane).STATUS.MB_ERROR,
--        multi_bit_rate_max  => CTRL_local.C2C(iLane).PHY_MAX_MULTI_BIT_ERROR_RATE,
--        count_waiting_timeouts         => Mon_local.C2C(iLane).COUNTERS.WAITING_TIMEOUTS, 
--        count_errors_all_time          => Mon_local.C2C(iLane).COUNTERS.ERRORS_ALL_TIME,         
--        COUNT_ERRORS_SINCE_LOCKED      => MON_LOCAL.C2C(iLane).COUNTERS.ERRORS_SINCE_LOCKED,     
--        COUNT_ERROR_WAITS_SINCE_LOCKED => MON_LOCAL.C2C(iLane).COUNTERS.ERROR_WAITS_SINCE_LOCKED,
--        COUNT_XCVR_RESETS              => MON_LOCAL.C2C(iLane).COUNTERS.XCVR_RESETS         
--        );
    single_bit_error_rate_counter: entity work.rate_counter
      generic map (
        CLK_A_1_SECOND => CLKFREQ)
      port map (
        clk_A             => clk_axi,
        clk_B             => clk_axi,
        reset_A_async     => zero,--'0',
        event_b           => Mon_local.C2C(iLane).STATUS.LINK_ERROR,
        rate              => single_bit_error_rate(iLane));
    Mon_local.C2C(iLane).COUNTERS.SB_ERROR_RATE <= single_bit_error_rate(iLane);
    multi_bit_error_rate_counter: entity work.rate_counter
      generic map (
        CLK_A_1_SECOND => CLKFREQ)
      port map (
        clk_A             => clk_axi,
        clk_B             => clk_axi,
        reset_A_async     => zero,--'0',
        event_b           => Mon_local.C2C(iLane).STATUS.MB_ERROR,
        rate              => multi_bit_error_rate(iLane));
    Mon_local.C2C(iLane).COUNTERS.MB_ERROR_RATE <= multi_bit_error_rate(iLane);

    phy_reset(iLane)                             <= link_INFO_out(iLane-1).link_reset;        
    aurora_init_buf(iLane)                       <= link_INFO_out(iLane-1).link_init;         
    Mon_local.C2C(iLane).COUNTERS.PHYLANE_STATE  <= link_INFO_out(iLane-1).state(2 downto 0); 
                                  
    link_INFO_in(iLane-1).link_reset_done          <= Mon_local.C2C(iLane).DEBUG.RX.PMA_RESET_DONE;     
    link_INFO_in(iLane-1).link_good                <= Mon_local.C2C(iLane).status.LINK_GOOD;
    link_INFO_in(iLane-1).lane_up                  <= Mon_local.C2C(iLane).status.phy_lane_up(0);
    link_INFO_in(iLane-1).sb_err_rate              <= single_bit_error_rate(iLane);
    link_INFO_in(iLane-1).sb_err_rate_threshold    <= CTRL_local.C2C(iLane).PHY_MAX_SINGLE_BIT_ERROR_RATE;
    link_INFO_in(iLane-1).mb_err_rate              <= multi_bit_error_rate(iLane);
    link_INFO_in(iLane-1).mb_err_rate_threshold    <= CTRL_local.C2C(iLane).PHY_MAX_MULTI_BIT_ERROR_RATE;

   
    -------------------------------------------------------------------------------
    -- COUNTERS
    -------------------------------------------------------------------------------
    GENERATE_COUNTERS_LOOP: for iCNT in 0 to COUNTER_COUNT -1 generate --....counter_count
      Counter_X: entity work.counter
        generic map (
          roll_over   => '0',
          end_value   => x"FFFFFFFF",
          start_value => x"00000000",
          DATA_WIDTH  => 32)
        port map (
          clk         => clk_axi,
          reset_async => reset,
          reset_sync  => CTRL_local.C2C(iLane).COUNTERS.RESET_COUNTERS,
          enable      => counter_en(iLane),
          event       => counter_events((iLane-1)*COUNTER_COUNT + iCNT ),
          count       => C2C_Counter((iLane-1)*COUNTER_COUNT + iCNT),          --runs 1 to COUNTER_COUNT
          at_max      => open);   
    end generate GENERATE_COUNTERS_LOOP;


    --PATTERN FOR COUNTERS
    --setting events, run 0 to (COUNTER_COUNT - 1)
    counter_events((iLane-1)*COUNTER_COUNT + 0) <= Mon.C2C(iLane).STATUS.CONFIG_ERROR;
    counter_events((iLane-1)*COUNTER_COUNT + 1) <= Mon.C2C(iLane).STATUS.LINK_ERROR; 
    counter_events((iLane-1)*COUNTER_COUNT + 2) <= Mon.C2C(iLane).STATUS.MB_ERROR;
    counter_events((iLane-1)*COUNTER_COUNT + 3) <= Mon.C2C(iLane).STATUS.PHY_HARD_ERR;
    counter_events((iLane-1)*COUNTER_COUNT + 4) <= Mon.C2C(iLane).STATUS.PHY_SOFT_ERR;
    --setting counters, run 1 to COUNTER_COUNT
    Mon_local.C2C(iLane).COUNTERS.CONFIG_ERROR_COUNT   <= C2C_Counter((iLane-1)*COUNTER_COUNT + 0);
    Mon_local.C2C(iLane).COUNTERS.LINK_ERROR_COUNT     <= C2C_Counter((iLane-1)*COUNTER_COUNT + 1);
    Mon_local.C2C(iLane).COUNTERS.MB_ERROR_COUNT       <= C2C_Counter((iLane-1)*COUNTER_COUNT + 2);
    Mon_local.C2C(iLane).COUNTERS.PHY_HARD_ERROR_COUNT <= C2C_Counter((iLane-1)*COUNTER_COUNT + 3);
    Mon_local.C2C(iLane).COUNTERS.PHY_SOFT_ERROR_COUNT <= C2C_Counter((iLane-1)*COUNTER_COUNT + 4);   
  end generate GENERATE_LANE_LOOP;
end architecture behavioral;
