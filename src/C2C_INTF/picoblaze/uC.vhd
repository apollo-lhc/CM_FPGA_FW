library IEEE;
use IEEE.std_logic_1164.all;
package uC_LINK is
  type uC_Link_in_t is record
    link_reset_done       : std_logic;    
    link_good             : std_logic;
    lane_up               : std_logic;
    sb_err_rate           : std_logic_vector(31 downto 0);
    sb_err_rate_threshold : std_logic_vector(31 downto 0);
    mb_err_rate           : std_logic_vector(31 downto 0);
    mb_err_rate_threshold : std_logic_vector(31 downto 0);
  end record uc_Link_in_t;
  type uC_link_in_t_ARRAY is array(integer range <>) of uC_Link_in_t;
  type uC_Link_out_t is record
    link_reset            : std_logic;
    link_init             : std_logic;
    state                 : std_logic_vector(7 downto 0);
  end record uc_Link_out_t;
  constant DEFAULT_uC_Link_out_t : uC_Link_out_t := (link_reset => '0',
                                                     link_init  => '0',
                                                     state      => X"00");
  type uC_link_out_t_ARRAY is array(integer range <>) of uC_Link_out_t;
end package uC_LINK;



library IEEE;
use IEEE.STD_LOGIC_1164.all;

use ieee.numeric_std.all;
use IEEE.std_logic_misc.all;

library UNISIM;
use UNISIM.vcomponents.all;
use work.uC_LINK.all;

entity uC is
  generic (
    LINK_COUNT : integer range 0 to 15 := 1
  );
  port (
    clk          : in std_logic;               -- 50MHz oscillator input
    reset        : in std_logic;               -- reset to picoblaze

    reprogram_addr   : in  std_logic_vector(10 downto 0);
    reprogram_wen    : in  std_logic;                    
    reprogram_di     : in  std_logic_vector(17 downto 0);
    reprogram_do     : out std_logic_vector(17 downto 0);
    reprogram_reset  : in std_logic;               -- reset the picoblaze for reprogramming
    
    -- UART_INT
    UART_Rx : in  std_logic;              -- serial in
    UART_Tx : out std_logic := '1';       -- serial out

    --monitoring
    irq_count             :  in std_logic_vector(31 downto 0);
    link_INFO_in          :  in uC_link_in_t_ARRAY (0 to LINK_COUNT-1);
    link_INFO_out         :  out uC_link_out_t_ARRAY(0 to LINK_COUNT-1)
        
    );


end entity uC;

architecture arch of uC is

--
-- KCPSM6 uc
-- 
  component kcpsm6
    generic(
      hwbuild                 : std_logic_vector(7 downto 0)  := X"00";
      interrupt_vector        : std_logic_vector(11 downto 0) := X"600";
      scratch_pad_memory_size : integer                       := 256);
    port (
      address        : out std_logic_vector(11 downto 0);
      instruction    : in  std_logic_vector(17 downto 0);
      bram_enable    : out std_logic;
      in_port        : in  std_logic_vector(7 downto 0);
      out_port       : out std_logic_vector(7 downto 0);
      port_id        : out std_logic_vector(7 downto 0);
      write_strobe   : out std_logic;
      k_write_strobe : out std_logic;
      read_strobe    : out std_logic;
      interrupt      : in  std_logic;
      interrupt_ack  : out std_logic;
      sleep          : in  std_logic;
      reset          : in  std_logic;
      clk            : in  std_logic);
  end component;

--
-- KCPSM6 ROM
-- 
  component cli is
    port (
      address     : in  std_logic_vector(11 downto 0);
      instruction : out std_logic_vector(17 downto 0);
      portB_addr  : in  std_logic_vector(11 downto 0);
      portB_wen   : in  std_logic;
      portB_di    : in  std_logic_vector(17 downto 0);
      portB_do    : out std_logic_vector(17 downto 0);
      msize       : out std_logic_vector(11 downto 0);
      clk         : in  std_logic);
  end component cli;
--  component cli
--    generic(
--      C_FAMILY             : string  := "US";
--      C_RAM_SIZE_KWORDS    : integer := 2;
--      C_JTAG_LOADER_ENABLE : integer := 0);
--    port (
--      address     : in  std_logic_vector(11 downto 0);
--      instruction : out std_logic_vector(17 downto 0);
--      enable      : in  std_logic;
--      rdl         : out std_logic;
--      clk         : in  std_logic);
--  end component;

--
-- UART Transmitter     
--
  component uart_tx6
    port (
      data_in             : in  std_logic_vector(7 downto 0);
      en_16_x_baud        : in  std_logic;
      serial_out          : out std_logic;
      buffer_write        : in  std_logic;
      buffer_data_present : out std_logic;
      buffer_half_full    : out std_logic;
      buffer_full         : out std_logic;
      buffer_reset        : in  std_logic;
      clk                 : in  std_logic);
  end component;

--
-- UART Receiver
--
  component uart_rx6
    port (
      serial_in           : in  std_logic;
      en_16_x_baud        : in  std_logic;
      data_out            : out std_logic_vector(7 downto 0);
      buffer_read         : in  std_logic;
      buffer_data_present : out std_logic;
      buffer_half_full    : out std_logic;
      buffer_full         : out std_logic;
      buffer_reset        : in  std_logic;
      clk                 : in  std_logic);
  end component;

-----------------------------------------------------------------------------
-- Signals
-----------------------------------------------------------------------------
  signal rst : std_logic;

--
-- KCPSM6 & ROM signals
--
  signal address        : std_logic_vector(11 downto 0);
  signal instruction    : std_logic_vector(17 downto 0);
  signal bram_enable    : std_logic;
  signal in_port        : std_logic_vector(7 downto 0) := "00000000";
  signal out_port       : std_logic_vector(7 downto 0) := "00000000";
  signal port_id        : std_logic_vector(7 downto 0) := "00000000";
  signal write_strobe   : std_logic                    := '0';
  signal k_write_strobe : std_logic                    := '0';
  signal read_strobe    : std_logic                    := '0';
  signal interrupt      : std_logic;
  signal interrupt_ack  : std_logic;
  signal interrupt_reset : std_logic;
  signal kcpsm6_sleep   : std_logic;


--
-- KCPSM6 port names
--

  constant PB_PORT_UART_CONTROL    : std_logic_vector(3 downto 0) := x"0";
  constant PB_PORT_UART_STATUS     : std_logic_vector(3 downto 0) := x"0";
  constant PB_PORT_UART_OUTPUT     : std_logic_vector(3 downto 0) := x"1";
  constant PB_PORT_UART_INPUT      : std_logic_vector(3 downto 0) := x"1";
  constant PB_PORT_LINK_SELECT     : std_logic_vector(3 downto 0) := x"3";
  constant PB_PORT_LINK_CTRL       : std_logic_vector(3 downto 0) := x"4";
  constant PB_PORT_LINK_STATUS     : std_logic_vector(3 downto 0) := x"5";
  
--
-- UART UART_TX signals
--
  signal UART_Tx_data_in      : std_logic_vector(7 downto 0);
  signal write_to_UART_Tx        : std_logic;
  signal UART_Tx_data_present : std_logic;
  signal UART_Tx_half_full    : std_logic;
  signal UART_Tx_full         : std_logic;
  signal UART_Tx_reset        : std_logic := '0';

--
-- UART UART_RX signals
--
  signal UART_Rx_data_out     : std_logic_vector(7 downto 0);
  signal read_from_UART_Rx    : std_logic;
  signal UART_Rx_data_present : std_logic;
  signal UART_Rx_half_full    : std_logic;
  signal UART_Rx_full         : std_logic;
  signal UART_Rx_reset        : std_logic := '0';

--
-- UART UART baud rate signals
--
  signal baud_count   : integer range 0 to 67 := 0;
  signal en_16_x_baud : std_logic             := '0';


--
-- MOnitoring singals
--
  signal irq_counter        : unsigned(31 downto 0);

  signal link_INFO_out_local: uC_link_out_t_ARRAY(0 to LINK_COUNT-1);

  signal iLink              : integer range 0 to LINK_COUNT-1;
  signal err_sb_over_thresh : std_logic_vector(0 to LINK_COUNT-1);
  signal err_mb_over_thresh : std_logic_vector(0 to LINK_COUNT-1);
  
begin  -- architecture arch


-----------------------------------------------------------------------------------------
-- Instantiate KCPSM6 and connect to Program Memory
-----------------------------------------------------------------------------------------
  processor : kcpsm6
    generic map (
      hwbuild                 => X"01",
      interrupt_vector        => X"600",
      scratch_pad_memory_size => 256)
    port map(
      address        => address,
      instruction    => instruction,
      bram_enable    => bram_enable,
      port_id        => port_id,
      write_strobe   => write_strobe,
      k_write_strobe => k_write_strobe,
      out_port       => out_port,
      read_strobe    => read_strobe,
      in_port        => in_port,
      interrupt      => interrupt,
      interrupt_ack  => interrupt_ack,
      sleep          => kcpsm6_sleep,
      reset          => rst,
      clk            => clk);

--
--Disable sleep and interrupts on kcpsm6
--
  kcpsm6_sleep <= '0';
  rst          <= reprogram_reset or reset;

  interrupt_reset <= reset or interrupt_ack;
  interrupt_signal :   process (clk, interrupt_reset) is
  begin
    if interrupt_reset = '1' then
      interrupt <= '0';
    elsif clk'event and clk = '1' then      
      if irq_counter = unsigned(irq_count) then
        interrupt <= or_reduce(irq_count); --if irq_count is zero we don't use
                                           --interrupts
      end if;
    end if;
  end process interrupt_signal;
  
  interrupt_generator: process (clk, reset) is
  begin  -- process interrupt_generator
    if reset = '1' then                 -- asynchronous reset (active high)
      irq_counter <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if irq_counter = unsigned(irq_count) then
        irq_counter <= to_unsigned(0,32);
      else
        irq_counter <= irq_counter + 1;
      end if;
    end if;
  end process interrupt_generator;
  
--
-- KCPSM6 ROM
--
--  program_rom : cli
--    generic map(
--      C_FAMILY             => "7s",     --Family 'S6', 'V6' or '7S'
--      C_RAM_SIZE_KWORDS    => 2,        --Program size '1', '2' or '4'
--      C_JTAG_LOADER_ENABLE => 0)        --Include JTAG Loader when set to '1' 
--    port map(
--      address     => address,
--      instruction => instruction,
--      enable      => bram_enable,
--      rdl         => kcpsm6_reset,
--      clk         => clk);

  cli_1: entity work.cli
    port map (
      address     => address(10 downto 0),
      instruction => instruction,
      portB_addr  => reprogram_addr,
      portB_wen   => reprogram_wen,
      portB_di    => reprogram_di,
      portB_do    => reprogram_do,
      msize       => open,
      clk         => clk);

--
-- Logic board UART Transmitter
--

  TDC_tx_mod : uart_tx6
    port map (
      data_in             => UART_Tx_data_in,
      en_16_x_baud        => en_16_x_baud,
      serial_out          => UART_Tx,
      buffer_write        => write_to_UART_Tx,
      buffer_data_present => UART_Tx_data_present,
      buffer_half_full    => UART_Tx_half_full,
      buffer_full         => UART_Tx_full,
      buffer_reset        => UART_Tx_reset,
      clk                 => clk);
--
-- Logic board UART Receiver
--
  TDC_rx_mod : uart_rx6
    port map (
      serial_in           => UART_Rx,
      en_16_x_baud        => en_16_x_baud,
      data_out            => UART_Rx_data_out,
      buffer_read         => read_from_UART_Rx,
      buffer_data_present => UART_Rx_data_present,
      buffer_half_full    => UART_Rx_half_full,
      buffer_full         => UART_Rx_full,
      buffer_reset        => UART_Rx_reset,
      clk                 => clk);


  
-----------------------------------------------------------------------------------------
-- RS232 (UART) baud rate 
-----------------------------------------------------------------------------------------
--
-- To set serial communication baud rate to 115,200 then en_16_x_baud must pulse 
-- High at 1.84MHz which is every 54 cycles at 100Mhz. In this implementation 
-- a pulse is generated every 31 cycles resulting is a baud rate of 126,01 baud (0.8%)
--

  baud_rate : process(clk)
  begin
    if clk'event and clk = '1' then
      if baud_count = 26 then           -- counts 54 states including zero
        baud_count   <= 0;
        en_16_x_baud <= '1';            -- single cycle enable pulse
      else
        baud_count   <= baud_count + 1;
        en_16_x_baud <= '0';
      end if;        
    end if;
  end process baud_rate;




-----------------------------------------------------------------------------
-- Reading interface of the UC to the UART
-----------------------------------------------------------------------------
  input_ports : process(clk)
  begin
    if clk'event and clk = '1' then

      
      case port_id(3 downto 0) is
        -----------------------------------------------------------------------
        -- UART status port
        when PB_PORT_UART_STATUS =>
          in_port(0)          <= UART_Tx_data_present;
          in_port(1)          <= UART_Tx_half_full;
          in_port(2)          <= UART_Tx_full;
          in_port(3)          <= UART_Rx_data_present;
          in_port(4)          <= UART_Rx_half_full;
          in_port(5)          <= UART_Rx_full;
          in_port(6)          <= '0';
          in_port(7)          <= '0';
        -----------------------------------------------------------------------
        -- UART input port
        when PB_PORT_UART_INPUT =>
          -- (see 'buffer_read' pulse generation below) 
          in_port <= UART_Rx_data_out;
        when PB_PORT_LINK_CTRL =>
          in_port(0) <= link_INFO_out_local(iLink).link_reset;
          in_port(1) <= link_INFO_in(iLink).link_reset_done;
          in_port(2) <= link_INFO_out_local(iLink).link_init;
          in_port(3) <= link_INFO_in(iLink).link_good;
          in_port(4) <= link_INFO_in(iLink).lane_up;
          in_port(5) <= err_sb_over_thresh(iLink);
          in_port(6) <= err_mb_over_thresh(iLink);
        when PB_PORT_LINK_SELECT =>
          in_port    <= std_logic_vector(to_unsigned(LINK_COUNT,8));
        -----------------------------------------------------------------------
        -- others do nothing
        when others => in_port <= x"00";

      end case;

      -------------------------------------------------------------------------
      -- For UART read
      -- Generate 'buffer_read' pulse following read from port address 01
      read_from_UART_Rx <= '0';
      if (read_strobe = '1') and (port_id = x"01") then
        read_from_UART_Rx <= '1';
      end if;

    end if;
  end process input_ports;

-----------------------------------------------------------------------------
-- Writing interface of the UC to UART and other devices
-----------------------------------------------------------------------------
  output_ports : process(clk, reset)
  begin
    if reset = '1' then
      UART_Tx_reset <= '1';
      UART_Rx_reset <= '1';
      link_INFO_out_local <= (others => DEFAULT_uC_Link_out_t);
      
    elsif clk'event and clk = '1' then
      -- reset register strobe
      UART_Tx_reset <= '0';
      UART_Rx_reset <= '0';


      -------------------------------------------------------------------------
      -- Constant write strobe
      if k_write_strobe = '1' then
        case port_id(3 downto 0) is
          --------------------
          -- Uart status port 
          when PB_PORT_UART_CONTROL =>
            UART_Tx_reset <= out_port(0);
            UART_Rx_reset <= out_port(1);
          when others => null;
        end case;
      -------------------------------------------------------------------------
      -- write strobe
      elsif write_strobe = '1' then
        case port_id(3 downto 0) is
          when PB_PORT_LINK_CTRL =>
            link_INFO_out_local(iLink).link_reset <= out_port(0);
            link_INFO_out_local(iLink).link_init  <= out_port(2);
          when PB_PORT_LINK_SELECT =>
            iLink                                 <= to_integer(unsigned(out_port(3 downto 0)));
          when PB_PORT_LINK_STATUS =>
            link_INFO_out_local(iLink).state            <= out_port;
          when others => null;
        end case;
      end if;
    end if;
  end process output_ports;


  

  UART_Tx_data_in  <= out_port;
  write_to_UART_Tx <= '1' when (write_strobe = '1') and (port_id(3 downto 0) = PB_PORT_UART_OUTPUT)
                      else '0';



  
-----------------------------------------------------------------------------
-- monitoring and control 
-----------------------------------------------------------------------------
  link_mon: process (clk) is
  begin  -- process link_mon
    if clk'event and clk = '1' then    -- rising clock edge
      link_INFO_out <= link_INFO_out_local;

      for i in 0 to LINK_COUNT-1 loop

        if unsigned(link_INFO_in(i).sb_err_rate) > unsigned(link_INFO_in(i).sb_err_rate_threshold) then
          err_sb_over_thresh(i) <= '1';
        else
          err_sb_over_thresh(i) <= '0';    
        end if;
        if unsigned(link_INFO_in(i).mb_err_rate) > unsigned(link_INFO_in(i).mb_err_rate_threshold) then
          err_mb_over_thresh(i) <= '1';
        else
          err_mb_over_thresh(i) <= '0';    
        end if;    
        
      end loop;  -- i
    end if;
  end process link_mon;
  
end architecture arch;
