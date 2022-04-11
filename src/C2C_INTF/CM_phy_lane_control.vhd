library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use work.types.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity CM_phy_lane_control is
  generic (
    CLKFREQ           : integer := 50000000;  --Frequency of clk (hz)
    DATA_WIDTH        : integer := 32;        --Data width for error counter,
                                              --this might be required to be 32
    ERROR_WAIT_TIME   : integer := 50000000); --Wait time for error checking state
  port (              
    clk                 : in  std_logic;
    reset               : in  std_logic;
    reset_counter       : in  std_logic;
    enable              : in  std_logic;
    phy_lane_up         : in  std_logic;
    phy_lane_stable     : in  std_logic_vector(19 downto 0);
    read_time           : in  std_logic_vector(23 downto 0);
    failed_cnt_to_rst   : in  std_logic_vector( 7 downto 0);
    initialize_out      : out std_logic;
    lock                : out std_logic;
    xcvr_reset          : out std_logic;
    xcvr_reset_done     : in  std_logic;
    single_bit_error    : in  std_logic;
    single_bit_rate_max : in  std_logic_vector(31 downto 0);
    multi_bit_error     : in  std_logic;
    multi_bit_rate_max  : in  std_logic_vector(31 downto 0);    
    state_out           : out std_logic_vector(2 downto 0);
    count_waiting_timeouts         : out std_logic_vector(DATA_WIDTH-1 downto 0);
    count_errors_all_time          : out std_logic_vector(DATA_WIDTH-1 downto 0);
    count_errors_since_locked      : out std_logic_vector(DATA_WIDTH-1 downto 0);
    count_error_waits_since_locked : out std_logic_vector(DATA_WIDTH-1 downto 0);
    count_xcvr_resets              : out std_logic_vector(DATA_WIDTH-1 downto 0));
end entity CM_phy_lane_control;
architecture behavioral of CM_phy_lane_control is

 
  
  --- *** TIMING *** ---
  signal   timeout_to_initialize_cntr     : integer range 0 to (2**(read_time'length)) -1;
  signal   TIMEOUT_TO_INITIALIZE_CNTR_MAX : integer range 0 to (2**(read_time'length)) -1;
  
  signal   error_wait_cntr                : integer range 0 to ERROR_WAIT_TIME;
  
  signal   init_wait_cntr                 : integer range 0 to 63;
  constant INIT_WAIT_CNTR_MAX             : integer range 0 to 63 := 63;
  constant INIT_WAIT_CNTR_HALFWAY         : integer range 0 to 63 := INIT_WAIT_CNTR_MAX/2;
                                           
  signal   phy_up_cnt                     : integer range 0 to (2**(phy_lane_stable'length)) -1;
  signal   PHY_UP_CNT_MAX                 : integer range 0 to (2**(phy_lane_stable'length)) -1;

  signal   failed_cnt                     : integer range 0 to (2**(FAILED_CNT_TO_RST'length))-1;
  signal   FAILED_CNT_MAX                 : integer range 0 to (2**(FAILED_CNT_TO_RST'length))-1;


  signal   pma_reset_wait_cntr                 : integer range 0 to 127;
  constant PMA_RESET_WAIT_CNTR_MAX             : integer range 0 to 127 := 127;

  --- *** STATE_MACINE *** ---
  type state_t is (IDLE,
                   WAITING,
                   INITIALIZING,
                   LOCKED,
                   ERROR_WAIT,
                   PMA_RESET,
                   PMA_RESET_WAIT,
                   UNKNOWN
                   );
  signal state     : state_t;
  
  --- *** COUNTER *** ---
  signal reset_shortterm_counter  : std_logic;
  signal reset_rate_counter       : std_logic;
  signal transition_to_error_wait : std_logic;
  signal transceiver_reset        : std_logic;

  signal error_while_locked       : std_logic;
  
  signal single_bit_error_rate    : std_logic_vector(31 downto 0);
  signal multi_bit_error_rate     : std_logic_vector(31 downto 0);

  signal waiting_timeout          : std_logic;
begin

----------------------------------------------------------------------------------------------------------------
--                    +------------------------------------------------------------------------------+
--                    |                                                                              |
--                    |                                                                              |
--                    |                                             timer /= 10ms                    |
--                    |                                            +------------+                    |
--                    |                                            |            |                    |
--                    |                                            |            |                    |
--                    |      +-----------+  phylaneup = 1 +--------+-----+      |                    v
--                    |      |           +<---------------+              +<-----+             +------+------+
--                    |      |  LOCKED   |                |  ERROR_WAIT  |                    |             |
--                    |      |  111      +--------------->+     110      |                +-->+  PMA_RESET  |
--                    |      +--+--------+ phylaneup = 0  +--------+-----+                |   |             |
--                    |         ^                                  |                      |   +------+------+
-- ALL STATES         |         +                                  |phylaneup = 0         |          |
--      +             |   phylaneup = 1                            |timer = 10ms          |          |
--      | enable = 0  |         +           FAILED_CNT++           |FAILED_CNT++          |          v
--      v             |         |           timer = 10ms           v                      |   +------+------+
--  +---+----+        |    +----+------+   phylaneup = 0   +-------+------+               |   |             +---+
--  |        |        |    |           +------------------>+              +---------------+   |PMA_RESET_WAIT|   |
--  |  IDLE  +--------+    |   WAIT    |                   |  INITIALIZE  | FAILED_CNT = M    |             +<--+
--  |  000   | enable = 1  |   010     +<------------------+  001         +-------+           +------+------+
--  +--------+             +-+---+----++   INIT_CNTR = 32  +-----------+--+       |                  |
--                           ^   ^    |                                ^          |                  |
--                           |   |    |                                |          |                  |
--                           |   +----+                                +----------+                  |
--                           |   Timer /= 10ms                         INIT_CNTR /= 32               |
--                           |                                                                       |
--                           |                                                                       |
--                           +-----------------------------------------------------------------------+
----------------------------------------------------------------------------------------------------------------
  
--process for managing state
  TIMEOUT_TO_INITIALIZE_CNTR_MAX <= to_integer(unsigned(read_time));
  PHY_UP_CNT_MAX                 <= to_integer(unsigned(phy_lane_stable));
  FAILED_CNT_MAX                 <= to_integer(unsigned(failed_cnt_to_rst));
  STATE_MACHINE: process (clk, reset) is
  begin
    if reset = '1' then --async reset
      state <= IDLE;      
    elsif clk'event and clk='1' then --rising clk edge

      if enable = '0' then
        state <= IDLE;
      else
        case state is
          when IDLE => --move to INITIALIZE on enable
            ---IDLE--------------------------------------------------------------
            state <= PMA_RESET;
          when PMA_RESET =>
            ---PMA_RESET-------------------------------------------------------------
            state <= PMA_RESET_WAIT;
          when PMA_RESET_WAIT =>
            ---PMA_RESET_WAIT--------------------------------------------------------
            if pma_reset_wait_cntr = PMA_RESET_WAIT_CNTR_MAX then
              state <= WAITING;
            end if;
--            if xcvr_reset_done = '1' then
--              state <= WAITING;
--            end if;
          when INITIALIZING => --move to WAITING after 32 clk's
            ---INITIALIZING------------------------------------------------------
            if failed_cnt = FAILED_CNT_MAX then
              --We've failed to initialize enough times, so try resetting the link
              failed_cnt <= 0;
              state <= PMA_RESET;
            elsif init_wait_cntr = INIT_WAIT_CNTR_MAX then
              --we've waited long enough in initialize, leave
              state <= WAITING;
            end if;
          when WAITING => --read phy_lane_up for 1ms
            ---WAITING-----------------------------------------------------------
            if phy_up_cnt = PHY_UP_CNT_MAX then
              --we haven't seen an error for phy_lane_stable tics, so we are locked
              state <= LOCKED;
            elsif timeout_to_initialize_cntr = TIMEOUT_TO_INITIALIZE_CNTR_MAX then
              --we are still seeing errors on the link even over REAT_TIME
              --tics, so let's re-initialize the link.
              if failed_cnt /= FAILED_CNT_MAX then
                failed_cnt <= failed_cnt + 1;
              end if;
              state <= INITIALIZING;
            end if;
          when LOCKED =>
            ---LOCKED------------------------------------------------------------
            if ( phy_lane_up = '0' or
                 unsigned(multi_bit_error_rate)  >= unsigned(multi_bit_rate_max) or
                 unsigned(single_bit_error_rate) >= unsigned(single_bit_rate_max)
                 )then              
              state <= ERROR_WAIT;
            end if;
            
          when ERROR_WAIT =>
            ---ERROR_WAIT--------------------------------------------------------
            if phy_up_cnt = PHY_UP_CNT_MAX then
              --we saw an error once, but we've run for phy_lane_stable clock
              --ticks without another, so we are back to locked
              state <= LOCKED;
            elsif error_wait_cntr = ERROR_WAIT_TIME then
              -- we've waited a long time and still have errors, so let's try
              -- to re-initialize the link
              if failed_cnt /= FAILED_CNT_MAX then
                failed_cnt <= failed_cnt + 1;
              end if;
              state <= INITIALIZING;
              
              
            end if;
          when others => --reset
            ---others------------------------------------------------------------
            state       <= IDLE;
        end case;
      end if;
    end if;
  end process STATE_MACHINE;

  --Process for managing timing
  TIMING: process (reset, clk) is
  begin
    if reset = '1' then --async reset
      init_wait_cntr             <= 0;
      timeout_to_initialize_cntr <= 0;
      error_wait_cntr            <= 0;
      waiting_timeout            <= '0';
    elsif clk'event and clk='1' then --rising clk edge
      waiting_timeout            <= '0';
      case state is
        when INITIALIZING => --count 32 clk's
          ---INITIALIZING--------------------------------------------------------
          if init_wait_cntr = INIT_WAIT_CNTR_MAX then
            init_wait_cntr <= 0;
          else
            init_wait_cntr <= init_wait_cntr + 1;
          end if;
          
        when WAITING => --count to 1 ms
          ---WAITING-------------------------------------------------------------
          if timeout_to_initialize_cntr = TIMEOUT_TO_INITIALIZE_CNTR_MAX then
            timeout_to_initialize_cntr <= 0;
            waiting_timeout <= '1';
          else
            timeout_to_initialize_cntr <= timeout_to_initialize_cntr + 1;
          end if;

        when ERROR_WAIT =>
          ---ERROR_WAIT----------------------------------------------------------
          if error_wait_cntr = ERROR_WAIT_TIME then
            error_wait_cntr <= 0;
          else
            error_wait_cntr <= error_wait_cntr + 1;
          end if;
        when PMA_RESET_WAIT =>
          if pma_reset_wait_cntr = PMA_RESET_WAIT_CNTR_MAX then
            pma_reset_wait_cntr <= 0;
          else
            pma_reset_wait_cntr <= pma_reset_wait_cntr + 1;
          end if;
        when others => null;
      end case;
    end if;
  end process TIMING;

  link_monitor: process (clk, reset) is
  begin  -- process link_monitor
    if reset = '1' then                 -- asynchronous reset (active high)
      phy_up_cnt  <= 0;
    elsif clk'event and clk = '1' then  -- rising clock edge
      if phy_lane_up = '1' then
        if phy_up_cnt = PHY_UP_CNT_MAX then
          phy_up_cnt <= PHY_UP_CNT_MAX;
        else
          phy_up_cnt <= phy_up_cnt + 1;
        end if;
      else
        phy_up_cnt <= 0;
      end if;      
    end if;
  end process link_monitor;
  
  --Process for managing output signals
  xcvr_reset <= transceiver_reset;
  CONTROL: process (reset, clk) is
  begin
    if reset = '1' then --async reset
      initialize_out            <= '0';
      transceiver_reset         <= '0';
      lock                      <= '0';
    elsif clk'event and clk='1' then --rising clk edge
--      initialize_out            <= '0';
      transceiver_reset         <= '0';

      lock                      <= '0';
      error_while_locked        <= '0';
      reset_shortterm_counter   <= '1';
      transition_to_error_wait  <= '0';
      
      case state is
        when INITIALIZING => --force initialize
          if init_wait_cntr = 0 then
            initialize_out               <= '1';
          elsif init_wait_cntr = INIT_WAIT_CNTR_HALFWAY then
            initialize_out               <= '0';
          end if;
        when WAITING => --hold at 0    
        when LOCKED | ERROR_WAIT =>
          reset_shortterm_counter      <= '0';
          lock                         <= '1';
          if phy_lane_up = '0' then    
            error_while_locked         <= '1';
            if state = LOCKED then
              transition_to_error_wait <= '1';
            end if;
          end if;          
        when PMA_RESET =>
          transceiver_reset            <= '1';          
        when others => null;
      end case;
    end if;
  end process CONTROL;

  SM_to_slv: process (state) is
  begin  -- process SM_to_slv
    case state is
      when IDLE           => state_out <= "000";
      when INITIALIZING   => state_out <= "001";
      when WAITING        => state_out <= "010";
      when PMA_RESET      => state_out <= "011";
      when PMA_RESET_WAIT => state_out <= "100";
      when UNKNOWN        => state_out <= "101";
      when ERROR_WAIT     => state_out <= "110";
      when LOCKED         => state_out <= "111";
      when others         => state_out <= "101"; -- UNKNOWN
    end case;
  end process SM_to_slv;


  --rate counters for single and multibit errors
  reset_rate_counter        <= reset_shortterm_counter; -- different names for
                                                        -- the same signal
  single_bit_error_rate_counter: entity work.rate_counter
    generic map (
      CLK_A_1_SECOND => CLKFREQ)
    port map (
      clk_A             => clk,
      clk_B             => clk,
      reset_A_async     => reset_rate_counter,
      event_b           => single_bit_error,
      rate              => single_bit_error_rate);
  multi_bit_error_rate_counter: entity work.rate_counter
    generic map (
      CLK_A_1_SECOND => CLKFREQ)
    port map (
      clk_A             => clk,
      clk_B             => clk,
      reset_A_async     => reset_rate_counter,
      event_b           => multi_bit_error,
      rate              => multi_bit_error_rate);

  
  --Counter for monitoring
  counter_errors_all_time: entity work.counter
    generic map (
      roll_over   => '0',
      end_value   => x"FFFFFFFF",
      start_value => x"00000000",
      DATA_WIDTH  => DATA_WIDTH)
    port map (
      clk         => clk,
      reset_async => reset_counter,
      reset_sync  => '0',
      enable      => enable,
      event       => error_while_locked,
      count       => count_errors_all_time,
      at_max      => open);
  counter_errors_since_locked: entity work.counter
    generic map (
      roll_over   => '0',
      end_value   => x"FFFFFFFF",
      start_value => x"00000000",
      DATA_WIDTH  => DATA_WIDTH)
    port map (
      clk         => clk,
      reset_async => reset_counter,
      reset_sync  => reset_shortterm_counter,
      enable      => enable,
      event       => error_while_locked,
      count       => count_errors_since_locked,
      at_max      => open);
  counter_error_waits_since_locked: entity work.counter
    generic map (
      roll_over   => '0',
      end_value   => x"FFFFFFFF",
      start_value => x"00000000",
      DATA_WIDTH  => DATA_WIDTH)
    port map (
      clk         => clk,
      reset_async => reset_counter,
      reset_sync  => reset_shortterm_counter,
      enable      => enable,
      event       => transition_to_error_wait,
      count       => count_error_waits_since_locked,
      at_max      => open);
  Count_resets: entity work.counter
    generic map (
      roll_over   => '0',
      end_value   => x"FFFFFFFF",
      start_value => x"00000000",
      DATA_WIDTH  => DATA_WIDTH)
    port map (
      clk         => clk,
      reset_async => reset_counter,
      reset_sync  => '0',
      enable      => enable,
      event       => transceiver_reset,
      count       => count_xcvr_resets,
      at_max      => open);

  Count_wait_timeouts: entity work.counter
    generic map (
      roll_over   => '0',
      end_value   => x"FFFFFFFF",
      start_value => x"00000000",
      DATA_WIDTH  => DATA_WIDTH)
    port map (
      clk         => clk,
      reset_async => reset_counter,
      reset_sync  => '0',
      enable      => enable,
      event       => waiting_timeout,
      count       => count_waiting_timeouts,
      at_max      => open);

end architecture behavioral;
