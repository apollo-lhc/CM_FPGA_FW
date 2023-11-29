library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use ieee.std_logic_misc.all;

Library UNISIM;
use UNISIM.vcomponents.all;


-------------------------------------------------------------------------------
-- I2C Slave
-------------------------------------------------------------------------------
-- This is a simple i2c slave to 8bit addressed register block
--
-- Reads:
--   To read from a register first do a full write transaction that sends the
--   8bit address.
--   Then do a read transaction with 1 to N bytes, finishing by master non-ack.
--   The address will auto increment.
--
-- Writes:
--   First write the 8 bit register address, then in the same i2c transaction
--   write your date bytes.  The address will auto increment.
--   
-- Notes for = '1' on inout derived signals.
-- We need to put in /= '0' to replace this to cover the 'Z'/'H'/'1' issue
--
-- I2C_ADDR_WILDCARD_BITS 
--   This allows for multiple I2C slaves that share the same MSB bits, but differ 
--   in the I2C_ADDR_WILDCARD_BITS.  
--   The I2C_ADDR bits of a transaction are added as the MSB of the register address
-------------------------------------------------------------------------------

entity i2c_slave is
  generic (
    REGISTER_COUNT_BIT_SIZE : integer range 1 to 8 := 4;
    TIMEOUT_COUNT : unsigned(31 downto 0) := x"00100000";
    I2C_ADDR_WILDCARD_BITS : integer range 0 to 7 := 0);
  port (
    reset   : in std_logic;
    clk     : in std_logic;             -- several Mhz clock
    
    SDA_in  : in std_logic;
    SDA_out : out std_logic;
    SDA_en  : out std_logic;
    
    SCL     : in  std_logic;
    address    : in  std_logic_vector(6 downto 0);

    data_out : out std_logic_vector(7 downto 0);
    data_out_dv : out std_logic;
    data_in  : in std_logic_vector(7 downto 0);
    register_address : out std_logic_vector(I2C_ADDR_WILDCARD_BITS + REGISTER_COUNT_BIT_SIZE-1 downto 0)
    
    );        

end i2c_slave;          
architecture Behavioral of i2c_slave is

  -----------------------------------------------------------------------------
  -- signals
  -----------------------------------------------------------------------------
  signal SDA_in_old : std_logic;
  signal SCL_old : std_logic;
  signal scl_edge : std_logic_vector(1 downto 0);
  signal serial_monitor_counter : unsigned(31 downto 0);
  signal internal_reset : std_logic;
  
  signal start : std_logic;
  signal stop : std_logic;

  signal local_register_address : unsigned(I2C_ADDR_WILDCARD_BITS + REGISTER_COUNT_BIT_SIZE-1 downto 0);
  signal transaction_i2c_address : std_logic_vector(6 downto 0);
  signal bit_count : unsigned(3 downto 0);
  signal input_byte : std_logic_vector(7 downto 0);
  signal output_byte : std_logic_vector(7 downto 0);
  
  type i2c_state is (STATE_IDLE,
                     STATE_DEV_ADDR,
                     STATE_MASTER_READ,
                     STATE_REG_ADDR_SET,
                     STATE_MASTER_WRITE);
  signal state : i2c_state;
  signal state_num : std_logic_vector(2 downto 0);
  
  signal ack : std_logic;
  signal rw : std_logic;

  signal SDA_int : std_logic;
  signal SCL_int : std_logic;
  
  signal address_detect : std_logic;
  signal SDA_out_buffer : std_logic;
  signal SDA_en_buffer : std_logic;
  signal data_out_buffer : std_logic_vector(7 downto 0);
  signal data_out_dv_buffer : std_logic;
begin  -- Behavioral

  state_num_proc: process (state,state_num) is
  begin  -- process state_num_proc
    case state is
      when STATE_IDLE         => state_num <= "001";
      when STATE_DEV_ADDR     => state_num <= "010";
      when STATE_MASTER_READ  => state_num <= "011";
      when STATE_REG_ADDR_SET => state_num <= "100";
      when STATE_MASTER_WRITE => state_num <= "101";                         
      when others => state_num <= "000";
    end case;
  end process state_num_proc;

  sda_out <= sda_out_buffer;
  sda_en <= sda_en_buffer;
  data_out <= data_out_buffer;
  data_out_dv <= data_out_dv_buffer;
-- Uncomment for i2c debuggin.  (Also add ila_i2c_debug ip core to files.tcl)
--  ila: entity work.ila_i2c_debug
--    port map(
--      clk    => clk,
--      probe0 => state_num,
--      probe1(0) => start,
--      probe2(0) => stop,
--      probe3(5 downto 0) => std_logic_vector(local_register_address),
--      probe4(0) => SDA_in,
--      probe5(0) => SDA_out_buffer,
--      probe6(0) => SDA_en_buffer,
--      probe7(0) => SCL,
--      probe8(0) => ack,
--      probe9(0) => address_detect,
--      probe10(7 downto 0) => input_byte,
--      probe11(7 downto 0) => data_in,
--      probe12(7 downto 0) => data_out_buffer,
--      probe13(0) => data_out_dv_buffer,
--      probe14(3 downto 0) => std_logic_vector(bit_count),
--      probe15(7 downto 0) => output_byte,
--      probe16(1 downto 0) => scl_edge,
--      probe17(0)          => internal_reset
--      );
  
  -----------------------------------------------------------------------------
  -- Keep an copy of the previous states of SDA and SCL for edge detection
  -----------------------------------------------------------------------------
  edge_detection: process (SCL_old,SCL_int) is
  begin  -- process edge_detection
    scl_edge <= "00";
    if SCL_old = '0' and SCL_int = '1' then
      scl_edge(0) <= '1';
    end if;
    if SCL_old = '1' and SCL_int = '0' then
      scl_edge(1) <= '1';
    end if;    
  end process edge_detection;

  serial_monitor: process (clk, reset)
  begin  -- process serial_monitor
    if reset = '1' then                 -- asynchronous reset (active high)
      SDA_in_old <= '1';
      SCL_old <= '1';
      serial_monitor_counter <= x"00000000";
      internal_reset <= '1';
      SDA_int <= '1';
      SCL_int <= '1';
    elsif clk'event and clk = '1' then  -- rising clock edge

      --latch incomming signals
      SDA_int <= SDA_in;
      SCL_int <= SCL;
      
      -- keep track of SDA and SCL transitions      
      SDA_in_old <= SDA_int;
      SCL_old <= SCL_int;
     
      --monitor the serial interface for an error
      serial_monitor_counter <= serial_monitor_counter + 1;
      internal_reset <= '0';
      if SDA_int = '1' and SCL_int = '1' then
        serial_monitor_counter <= x"00000000";
      elsif serial_monitor_counter = TIMEOUT_COUNT then
        internal_reset <= '1';
      end if;      
    end if;
  end process serial_monitor;
  
  -----------------------------------------------------------------------------
  -- detect start of i2c sequence
  -----------------------------------------------------------------------------
  detect_start: process (clk, internal_reset)
  begin  -- process detect_start
    if internal_reset = '1' then                 -- asynchronous internal_reset (active high)
      start <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge      
      -- Look for a start sequence on falling SDA edge if we are not in start      
      if start = '0' then
        if SDA_in_old = '1' and SDA_int = '0' then
          start <= SCL_int;
        end if;
      -- if we are in start, look for SCL rising to internal_reset start
      else
        if SCL_old = '1' and SCL_int = '0' then
          start <= '0';
        end if;
      end if;
    end if;
  end process detect_start;
  
  -----------------------------------------------------------------------------
  -- detect stop of a i2c sequence
  -----------------------------------------------------------------------------
  detect_stop: process (clk, internal_reset)
  begin  -- process detect_stop
    if internal_reset = '1' then                 -- asynchronous internal_reset (active high)
      stop <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if stop = '0' then
        if SDA_in_old = '0' and SDA_int = '1' then
          stop <= SCL_int;
        end if;
      else
        if SCL_int = '1' then
          stop <= '0';
        end if;
      end if;
    end if;
  end process detect_stop;

  -----------------------------------------------------------------------------
  -- bit counter for 8 bit words and lsb/ack bit signals
  -----------------------------------------------------------------------------
  bit_clock: process (clk, internal_reset)
  begin  -- process bit_clock
    if internal_reset = '1' then                 -- asynchronous internal_reset (active high)
      bit_count <= "0000";
    elsif clk'event and clk = '1' then  -- rising clock edge

      if start = '1' and scl_edge(1) = '1' then
        bit_count <= x"0";
      elsif scl_edge(1) = '1' then  -- update on the falling edge so we
                                    -- are ready for capture/output on
                                    -- the rising edge        
        -- count which bit we are on in this 9 bit sequence
        bit_count <= bit_count + 1;
        if bit_count = 8 then
          bit_count <= x"0";
        end if;
      end if;
    end if;
  end process bit_clock;

  -----------------------------------------------------------------------------
  -- capture incoming bit stream
  -----------------------------------------------------------------------------
  input_capture: process (clk, internal_reset)
  begin  -- process input_capture
    if internal_reset = '1' then                 -- asynchronous internal_reset (active high)
      input_byte <= x"00";
    elsif clk'event and clk = '1' then  -- rising clock edge
      if start = '1' then
        input_byte <= (others => '0');
      elsif scl_edge(0) = '1' then
        -- shift in new bit on rising clock
        if bit_count /= 8 then 
          input_byte <= input_byte(6 downto 0) & SDA_int;          
          ack <= '0';
        else
          rw <= input_byte(0);
          input_byte <= (others => '0');
          ack <= not SDA_int;
        end if;
      end if;
    end if;
  end process input_capture;

  address_detector: process (clk, internal_reset)
  begin  -- process address_detect
    if internal_reset = '1' then                 -- asynchronous internal_reset (active high)
      address_detect <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge      
      case state is
        when STATE_IDLE => address_detect <= '0';
        when STATE_DEV_ADDR =>
          if to_integer(bit_count) = 6 then
            --CHeck for a matching address.
            --This may include some WILDCARD bits
            if scl_edge(1) = '1' and input_byte(6 downto I2C_ADDR_WILDCARD_BITS) = address(6 downto I2C_ADDR_WILDCARD_BITS) then
              address_detect <= '1';
              --keep track of the i2c address for this transaction
              transaction_i2c_address <= input_byte(6 downto 0);
            end if;
          end if;
        when others => null;
      end case; 
    end if;
  end process address_detector;

  -----------------------------------------------------------------------------
  -- primary state machine
  -----------------------------------------------------------------------------
  --         
  --         
  --                                                          Master ACK
  --                                                          reg addr++
  --         
  --                                                        +-----------+
  --                                                        |           |
  --              +-----------+  slv addr +------------+    |     +-----+------+
  --              |           |           |            |    v     |            |
  -- start +----->+ DEV_ADDR  +---------->+REG_ADDR_SET+----+---->+MASTER_WRITE|
  --              |           |           |            |          |            |
  --              +-----+-----+           +-----+------+          +-----+------+
  --                    |                       |                       |                    +--------+
  --                    |              +------->+                       |                    |        |
  --                    |   Master ACK |        v                       |                    v        |
  --                    |   reg addr++ |  +-----+-----+                 |              +-----+-----+  |
  --          !slv addr |              |  |           |                 v              |           |  |
  --                    |              +--+MASTER_READ+------------------------------->+   IDLE    +--+
  --                    |                 |           |                 ^              |           |
  --                    |                 +-----------+                 |              +-----------+
  --                    |                                               |
  --                    +-----------------------------------------------+
  --    
  --    
  state_machine: process (clk, internal_reset)
  begin  -- process state_machine
    if internal_reset = '1' then                 -- asynchronous internal_reset (active high)
      state <= STATE_IDLE;
    elsif clk'event and clk = '1' then  -- rising clock edge
      if stop = '1' then
        state <= STATE_IDLE;
      elsif start = '1' then
          state <= STATE_DEV_ADDR;       
      elsif scl_edge(1) = '1' then
        case state is
          -------------------------------------------------------------------
          when STATE_IDLE =>
            state <= STATE_IDLE;
          -------------------------------------------------------------------
          when STATE_DEV_ADDR =>
            case to_integer(bit_count) is
              when 8 =>
                if rw = '1' then
                  -- master is going to read from us
                  state <= STATE_MASTER_READ;
                else
                  -- master is going to write to us, so this is a new register address
                  state <= STATE_REG_ADDR_SET;
                end if;
              when 7 => 
--                if input_byte(7 downto 1) = address then
                if input_byte(7 downto 1+I2C_ADDR_WILDCARD_BITS) = address(6 downto I2C_ADDR_WILDCARD_BITS) then
                  state <= STATE_DEV_ADDR;
                else                    
                  state <= STATE_IDLE;
                end if;
              when others => null;
            end case;
          ------------------------------------------------------------------
          when STATE_MASTER_READ =>
            if to_integer(bit_count) = 8 then
              if ack = '1' then
                -- master wants to read another byte
                state <= STATE_MASTER_READ;
              else
                -- master is done reading
                state <= STATE_IDLE;
              end if;
            end if;                
          ------------------------------------------------------------------
          when STATE_REG_ADDR_SET =>
            if to_integer(bit_count) = 8 then
              state <= STATE_MASTER_WRITE;              
            end if;
          ------------------------------------------------------------------             
          when STATE_MASTER_WRITE =>
            state <= STATE_MASTER_WRITE;
          when others => state <= STATE_IDLE;
        end case;
      end if;    
    end if;
  end process state_machine;
  


  -----------------------------------------------------------------------------
  -- registers
  -----------------------------------------------------------------------------
  register_address <= std_logic_vector(local_register_address);
  register_address_proc: process (clk, internal_reset)
  begin  -- process register_address
    if internal_reset = '1' then                 -- asynchronous internal_reset (active high)
      local_register_address <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge      
      if scl_edge(1) = '1' then
        case state is
          when STATE_REG_ADDR_SET =>
            if to_integer(bit_count) = 7 then
              if I2C_ADDR_WILDCARD_BITS = 0 then
                local_register_address <= unsigned(input_byte(REGISTER_COUNT_BIT_SIZE-1 downto 0));
              else
                --I2C address part of the register address
                local_register_address(I2C_ADDR_WILDCARD_BITS + REGISTER_COUNT_BIT_SIZE - 1 downto REGISTER_COUNT_BIT_SIZE)
                  <= unsigned(transaction_i2c_address(I2C_ADDR_WILDCARD_BITS-1 downto 0));
                --Register part of the register address
                local_register_address(REGISTER_COUNT_BIT_SIZE-1 downto 0)
                  <= unsigned(input_byte(REGISTER_COUNT_BIT_SIZE-1 downto 0));
              end if;

            end if;
          when STATE_MASTER_WRITE | STATE_MASTER_READ  =>
            if to_integer(bit_count) = 7 then
              if I2C_ADDR_WILDCARD_BITS = 0 then                
                local_register_address <= local_register_address + 1;
              else
                --I2C address part of the register address
                local_register_address(I2C_ADDR_WILDCARD_BITS + REGISTER_COUNT_BIT_SIZE - 1 downto REGISTER_COUNT_BIT_SIZE)
                  <= unsigned(transaction_i2c_address(I2C_ADDR_WILDCARD_BITS-1 downto 0));
                --Register part of the register address
                local_register_address(REGISTER_COUNT_BIT_SIZE-1 downto 0)
                  <= local_register_address(REGISTER_COUNT_BIT_SIZE-1 downto 0) + 1;
              end if;              
            end if;            
          when others => null;
        end case;
      end if;      
    end if;
  end process register_address_proc;

 
  write_register: process (clk, internal_reset)
  begin  -- process write_registers
    if internal_reset = '1' then                 -- asynchronous internal_reset (active high)
      data_out_dv_buffer <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      -- if the master has writen all the bits of this byte, set the write
      -- write out the data
      data_out_dv_buffer <= '0';        
      if scl_edge(0) = '1' then
        if state = STATE_MASTER_WRITE then          
          if to_integer(bit_count) = 7 then           
            data_out_buffer <= input_byte(6 downto 0) & SDA_int;
            data_out_dv_buffer <= '1';
          end if;
        end if;
      end if;
    end if;
  end process write_register;

  read_register: process (clk, internal_reset)
  begin  -- process read_register
    if internal_reset = '1' then                 -- asynchronous internal_reset (active low)
      output_byte <= x"00";
    elsif clk'event and clk = '1' then  -- rising clock edge
      if scl_edge(0) = '1' then
        if to_integer(bit_count) = 8 then
          -- load next round of bits on the ack bit on the rising edge of the clock
          output_byte <= data_in;
        else
          -- shift through the bits on other rising edges
          output_byte <= output_byte(6 downto 0) & '0';
        end if;        
      end if;
    end if;
  end process read_register;
  
  -----------------------------------------------------------------------------
  -- Output driver
  -----------------------------------------------------------------------------
  SDA_driver: process (clk, internal_reset)
  begin  -- process SDA_driver
    if internal_reset = '1' then                 -- asynchronous internal_reset (active high)
      sda_out_buffer <= '1';
      SDA_en_buffer  <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if state = STATE_IDLE then
        sda_out_buffer <= '1';
        SDA_en_buffer  <= '0';        
      elsif scl_edge(1) = '1' then
        case state is
          when STATE_DEV_ADDR | STATE_REG_ADDR_SET | STATE_MASTER_WRITE =>
            if address_detect = '1' and to_integer(bit_count) = 7 then
              sda_out_buffer <= '0';
              SDA_en_buffer  <= '1';            
            else
              sda_out_buffer <= '1';
              SDA_en_buffer  <= '0';              
            end if;
            --hande the first bit of a read at the end of the DEV_ADDR state
            if (state = STATE_DEV_ADDR and address_detect = '1' and
                to_integer(bit_count) = 8 and rw = '1')then
              if output_byte(7) = '0' then
                sda_out_buffer <= '0';
                SDA_en_buffer  <= '1';
              end if;
            end if;
          when STATE_MASTER_READ =>
            if to_integer(bit_count) = 7 then
              sda_out_buffer <= '1';
              SDA_en_buffer  <= '0';                            
            elsif output_byte(7) = '0' then
              sda_out_buffer <= '0';
              SDA_en_buffer  <= '1';
            else
              sda_out_buffer <= '1';
              SDA_en_buffer  <= '0';              
            end if;  
          when others =>
            sda_out_buffer <= '1';
            SDA_en_buffer  <= '0';
        end case;
      end if;
    end if;
  end process SDA_driver;

end Behavioral;
