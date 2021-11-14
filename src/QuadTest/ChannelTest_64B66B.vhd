library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;


entity ChannelTest is
  port (
    clk         : in  std_logic;
    clk_axi     : in  std_logic;
    reset       : in  std_logic;
    tx_fixed    : in  std_logic_vector(65 downto 0);
    tx_fixed_en : in  std_logic;
    rx_data_valid: in std_logic;
    rx_data     : in  std_logic_vector(63 downto 0);
    rx_H_data   : in  std_logic_vector(1 downto 0);
    tx_data     : out std_logic_vector(63 downto 0);
    tx_H_data   : out std_logic_vector(1 downto 0);
    error_rate  : out std_logic_vector(31 downto 0);
    error_count : out std_logic_vector(31 downto 0));
end entity ChannelTest;
architecture behavioral of ChannelTest is
  signal counter       : unsigned(31 downto 0);
  signal check_counter : unsigned(31 downto 0);
  signal search_mode   : std_logic_vector(1 downto 0);
  signal rx_error      : std_logic;
  
  
begin  -- architecture behavioral  
  rate_counter_1: entity work.rate_counter
    generic map (
      CLK_A_1_SECOND => 500000000)
    port map (
      clk_A         => clk_axi,
      clk_B         => clk,
      reset_A_async => reset,
      event_b       => rx_error,
      rate          => error_rate);
  counter_2: entity work.counter
    generic map (
      roll_over   => '0')
    port map (
      clk         => clk,
      reset_async => reset,
      reset_sync  => '0',
      enable      => '1',
      event       => rx_error,
      count       => error_count,
      at_max      => open);

  
  data_gen: process (clk, reset) is
  begin  -- process data_proc
    if reset = '1' then               -- asynchronous reset (active high)
      tx_data <= x"DEADBEEFABADCAFE";
      tx_H_data <= "10";
      counter <= x"00000000";
    elsif clk'event and clk = '1' then  -- rising clock edge
      
      
      counter <= counter + 1;
      if counter(8 downto 0) = "100000000" then
        tx_data <= x"DEADBEEFABADCAFE";
        tx_H_data <= "10";
      else
        tx_data(31 downto  0) <= std_logic_vector(counter);
        tx_data(63 downto 32) <= std_logic_vector(counter);
        tx_h_data <= "01";        
      end if;

      if tx_fixed_en = '1' then
        tx_data <= tx_fixed(63 downto 0);
        tx_H_data <= tx_fixed(65 downto 64);
      end if;
    end if;
  end process data_gen;

  data_proc: process (clk, reset) is
  begin  -- process data_proc
    if reset = '1' then                 -- asynchronous reset (active low)
      search_mode <= "00";
      check_counter <= x"00000000";
    elsif clk'event and clk = '1' then  -- rising clock edge
      rx_error <= '0';
      if rx_data_valid = '1' then
        case search_mode is
          when "00" =>
            -- wait for a K-char word
            if rx_h_data = "10" then
              search_mode <= "01";
            end if;
          when "01" =>
            --grab the current counter value
            if rx_h_data = "10" then
              rx_error <= '1';
            else
              check_counter <= unsigned(rx_data(31 downto 0)) + 1;
              search_mode <= "10";            
            end if;
          when "10" =>
            --process counter values          
            if rx_h_data = "01" then
              if rx_data(31 downto 0) /= std_logic_vector(check_counter) then
                rx_error <= '1';
                -- go back to searching
                search_mode <= "00";
              end if;
              check_counter <= check_counter +1 ;
            elsif rx_h_data = "10"  then
              check_counter <= check_counter +1 ;
              if check_counter(8 downto 0) = "100000000" then
              --nothing
              else
                rx_error <= '1';
                search_mode <= "00";
              end if;
            else
              rx_error <= '1';
              search_mode <= "00";
            end if;          
          when others => null;
        end case;
      end if;
    end if;
  end process data_proc;
end architecture behavioral;
