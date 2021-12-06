
library IEEE;
use IEEE.STD_LOGIC_1164.all;

use ieee.numeric_std.all;
use IEEE.std_logic_misc.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity uC is

  port (
    clk          : in std_logic;               -- 50MHz oscillator input
    reset        : in std_logic;               -- reset to picoblaze

    -- UART_INT
    UART_Rx : in  std_logic;              -- serial in
    UART_Tx : out std_logic := '1'       -- serial out

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
  component cli
    generic(
      C_FAMILY             : string  := "US";
      C_RAM_SIZE_KWORDS    : integer := 1;
      C_JTAG_LOADER_ENABLE : integer := 1);
    port (
      address     : in  std_logic_vector(11 downto 0);
      instruction : out std_logic_vector(17 downto 0);
      enable      : in  std_logic;
      rdl         : out std_logic;
      clk         : in  std_logic);
  end component;

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
  signal kcpsm6_sleep   : std_logic;
  signal kcpsm6_reset   : std_logic;

--
-- KCPSM6 port names
--

  constant PB_PORT_UART_CONTROL    : std_logic_vector(3 downto 0) := x"0";
  constant PB_PORT_UART_STATUS     : std_logic_vector(3 downto 0) := x"0";
  constant PB_PORT_UART_OUTPUT     : std_logic_vector(3 downto 0) := x"1";
  constant PB_PORT_UART_INPUT      : std_logic_vector(3 downto 0) := x"1";
  constant PB_PORT_REG_CONTROL     : std_logic_vector(3 downto 0) := x"3";
  constant PB_PORT_REG_STATUS      : std_logic_vector(3 downto 0) := x"3";
  constant PB_PORT_REG_ADDR_LSB    : std_logic_vector(3 downto 0) := x"4";
  constant PB_PORT_REG_ADDR_MSB    : std_logic_vector(3 downto 0) := x"5";
  constant PB_PORT_REG_DATA_BYTE_0 : std_logic_vector(3 downto 0) := x"6";
  constant PB_PORT_REG_DATA_BYTE_1 : std_logic_vector(3 downto 0) := x"7";
  constant PB_PORT_REG_DATA_BYTE_2 : std_logic_vector(3 downto 0) := x"8";
  constant PB_PORT_REG_DATA_BYTE_3 : std_logic_vector(3 downto 0) := x"9";
  constant PB_PORT_FLASH           : std_logic_vector(3 downto 0) := x"C";
  
--
-- UART UART_TX signals
--
  signal UART_Tx_local : std_logic;
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



  
begin  -- architecture arch


-----------------------------------------------------------------------------------------
-- Instantiate KCPSM6 and connect to Program Memory
-----------------------------------------------------------------------------------------
  processor : kcpsm6
    generic map (
      hwbuild                 => X"01",
      interrupt_vector        => X"7FF",
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
  interrupt    <= interrupt_ack;
  rst          <= kcpsm6_reset or reset;

--
-- KCPSM6 ROM
--
  program_rom : cli
    generic map(
      C_FAMILY             => "7S",     --Family 'S6', 'V6' or '7S'
      C_RAM_SIZE_KWORDS    => 2,        --Program size '1', '2' or '4'
      C_JTAG_LOADER_ENABLE => 0)        --Include JTAG Loader when set to '1' 
    port map(
      address     => address,
      instruction => instruction,
      enable      => bram_enable,
      rdl         => kcpsm6_reset,
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
--      elsif write_strobe = '1' then
      end if;
    end if;
  end process output_ports;


  

  UART_Tx_data_in  <= out_port;
  write_to_UART_Tx <= '1' when (write_strobe = '1') and (port_id(3 downto 0) = PB_PORT_UART_OUTPUT)
                      else '0';


  
end architecture arch;
