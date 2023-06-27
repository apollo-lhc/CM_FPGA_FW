library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use ieee.std_logic_misc.all;

use work.axiRegPkg.all;
use work.axiRegPkg_d64.all;
use work.AXISlaveAddrPkg.all;                                                                                       
use work.AXIRegWidthPkg.all;
use work.types.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity i2cAXIMaster is
  generic (
    I2C_ADDRESS : std_logic_vector(6 downto 0));
  port(

    clk_axi         : in  std_logic;
    reset_axi_n     : in  std_logic;
    readMOSI        : out AXIReadMOSI := DefaultAXIReadMOSI;
    readMISO        : in  AXIReadMISO;
    writeMOSI       : out AXIWriteMOSI := DefaultAXIWriteMOSI;
    writeMISO       : in  AXIWriteMISO;


    SCL             : in  std_logic;
    SDA_in          : in  std_logic;
    SDA_out         : out std_logic;
    SDA_en          : out std_logic

    );
end entity i2cAXIMaster;

architecture behavioral of i2cAXIMaster is

  signal axi_address : std_logic_vector(40-1 downto 0);
  signal axi_rd_en   : std_logic;
  signal axi_rd_data : slv_32_t;
  signal axi_rd_data_valid : std_logic;
  signal axi_wr_data : slv_32_t;
  signal axi_wr_en : std_logic;
  signal axi_busy      : std_logic;

  signal i2c_data_out : slv_8_t;
  signal i2c_data_out_dv : std_logic;
  signal i2c_data_in : slv_8_t;
  signal i2c_register_address : std_logic_vector(3 downto 0);

  
  -------------------------------------------------------------------------------
  --regmap
  -------------------------------------------------------------------------------
  signal registers        : slv8_array_t(integer range 0 to 16);
  signal iReg             : integer range 0 to 16;
  -- bytes (unset are reserved)
  constant REG_STATUS     : integer :=  0;
  constant REG_CTRL       : integer :=  1;
  constant REG_DATA_BYTE0 : integer :=  4;
  constant REG_DATA_BYTE1 : integer :=  5;
  constant REG_DATA_BYTE2 : integer :=  6;
  constant REG_DATA_BYTE3 : integer :=  7;
  constant REG_ADDR_BYTE0 : integer :=  8;
  constant REG_ADDR_BYTE1 : integer :=  9;
  constant REG_ADDR_BYTE2 : integer := 10;
  constant REG_ADDR_BYTE3 : integer := 11;
  constant REG_ADDR_BYTE4 : integer := 12;

  --ctrl register bits
  constant MASK_CTRL_RD_REQ      : integer := 1; --x"01"
  constant MASK_CTRL_WR_REQ      : integer := 2; --x"02"
  constant MASK_CTRL_ERROR_CLEAR : integer := 2; --x"02"
  --status register_bits
  constant MASK_STATUS_BUSY      : integer := 1; --x"01"
  constant MASK_STATUS_ERROR     : integer := 2; --x"02"



  -------------------------------------------------------------------------------
  --state machine
  -------------------------------------------------------------------------------
  type SM_state_t is (SM_IDLE,SM_READ,SM_WRITE,SM_ERROR);
  signal state : SM_state_t;

  type SMR_state_t is (SMR_IDLE,SMR_WAIT,SMR_READ_WAIT,SMR_ERROR);
  signal read_state : SMR_state_t;
  
  type SMW_state_t is (SMW_IDLE,SMW_WAIT,SMW_WRITE_WAIT,SMW_ERROR);
  signal write_state : SMW_state_t;

  signal write_done : std_logic;
  signal read_done  : std_logic;


  
  
begin  -- architecture behavioral

  -------------------------------------------------------------------------------
  --AXI-Lite master
  -------------------------------------------------------------------------------
  axiLiteMaster_1: entity work.axiLiteMaster
    port map (
      clk_axi       => clk_axi,
      reset_axi_n   => reset_axi_n,
      readMOSI      => readMOSI,
      readMISO      => readMISO,
      writeMOSI     => writeMOSI,
      writeMISO     => writeMISO,
      busy          => axi_busy,
      address       => axi_address(AXI_ADDR_WIDTH-1 downto 0),
      rd_en         => axi_rd_en,
      rd_data       => axi_rd_data,
      rd_data_valid => axi_rd_data_valid,
      wr_data       => axi_wr_data,
      wr_en         => axi_wr_en);  

  -------------------------------------------------------------------------------
  --I2C endpoint
  -------------------------------------------------------------------------------
  i2c_endpoint: entity work.i2c_slave
    generic map (
      REGISTER_COUNT_BIT_SIZE => 4)
    port map (
      reset            => not reset_axi_n,
      clk              => clk_axi,
      SDA_in           => SDA_in,
      SDA_out          => SDA_out,
      SDA_en           => SDA_en,
      SCL              => SCL,
      address          => I2C_ADDRESS,
      data_out         => i2c_data_out,
      data_out_dv      => i2c_data_out_dv,
      data_in          => i2c_data_in,
      register_address => i2c_register_address);


  your_instance_name : entity work.debug_ila
    PORT MAP (
      clk => clk_axi,
      probe0(0) => SDA_in,
      probe0(1) => SDA_out,
      probe0(2) => SDA_en,
      probe0(3) => SCL,
      probe0(4) => i2c_data_out_dv,
      probe0( 8 downto  5) => i2c_register_address,
      probe0(10 downto  9) => std_logic_vector(to_unsigned(SMR_state_t'POS(read_state),2)),
      probe0(12 downto 11) => std_logic_vector(to_unsigned(SMW_state_t'POS(write_state),2)),
      probe0(15 downto 13) => "000",
      probe0(23 downto 16) => i2c_data_in,
      probe0(31 downto 24) => i2c_data_out,
      probe1 => x"00000000"
      );


  
  iReg <= to_integer(unsigned(i2c_register_address));
  i2c_data_in <= registers(iReg);

  --Process to control writing to the registers
  i2c_proc: process (clk_axi, reset_axi_n) is
  begin  -- process i2c_proc
    if reset_axi_n = '0' then           -- asynchronous reset (active low)
      registers <= (others => x"00");
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      -------------------------------------------------------
      --i2c writes to the regs
      if i2c_data_out_dv = '1' then
        registers(iReg) <= i2c_data_out;
      end if;
      -------------------------------------------------------
      --finished AXI reads take priority to write into regs
      if read_state = SMR_READ_WAIT and axi_rd_data_valid = '1' then        
        registers(REG_DATA_BYTE0) <= axi_rd_data( 7 downto  0);
        registers(REG_DATA_BYTE1) <= axi_rd_data(15 downto  8);
        registers(REG_DATA_BYTE2) <= axi_rd_data(23 downto 16);
        registers(REG_DATA_BYTE3) <= axi_rd_data(31 downto 24);
      end if;
      -------------------------------------------------------
      --BUSY signals override
      if ((state = SM_IDLE and
           registers(REG_STATUS)(MASK_STATUS_ERROR) = '0' and
           registers(REG_CTRL)(MASK_STATUS_BUSY) = '0')
          and          
          (registers(REG_STATUS)(MASK_CTRL_RD_REQ) = '1' or
           registers(REG_STATUS)(MASK_CTRL_WR_REQ) = '1')) then
        registers(REG_STATUS)(MASK_STATUS_BUSY) <= '1';
      end if;
      -------------------------------------------------------
      --BUSY signals override
      if state = SM_ERROR then
        registers(REG_STATUS)(MASK_STATUS_ERROR) <= '1';
      end if;
      
    end if;
  end process i2c_proc;

  -------------------------------------------------------------------------------
  -- State machine
  -------------------------------------------------------------------------------
  state_machine: process (clk_axi, reset_axi_n) is
  begin  -- process state_machine
    if reset_axi_n = '0' then           -- asynchronous reset (active low)
      state <= SM_IDLE;
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      case state is
        -----------------------------------------------------
        -- SM_IDLE
        -----------------------------------------------------
        when SM_IDLE =>
          state <= SM_IDLE; -- default do nothing

          if registers(REG_STATUS)(MASK_STATUS_ERROR) = '1' then
            
            --Check for read req
            if registers(REG_CTRL)(MASK_CTRL_RD_REQ) = '1' then
              if registers(REG_STATUS)(MASK_STATUS_BUSY) = '0' then
                state <= SM_READ;
              else
                state <= SM_ERROR;
              end if;
            -- check for write req (lower priority)
            elsif registers(REG_CTRL)(MASK_CTRL_WR_REQ) = '1' then
              if registers(REG_STATUS)(MASK_STATUS_BUSY) = '0' then
                state <= SM_WRITE;
              else
                state <= SM_ERROR;
              end if;            
            end if;
          end if;
        -----------------------------------------------------
        -- SM_READ
        -----------------------------------------------------
        when SM_READ =>
          state <= SM_READ;
          if read_done = '1' then
            state <= SM_IDLE;
          end if;
        -----------------------------------------------------
        -- SM_WRITE
        -----------------------------------------------------
        when SM_WRITE =>
          state <= SM_WRITE;
          if write_done = '1' then
            state <= SM_IDLE;
          end if;
        -----------------------------------------------------
        -- SM_ERROR
        -----------------------------------------------------
        when SM_ERROR =>
          --Stat in error until cleared
          state <= SM_ERROR;
          if registers(REG_CTRL)(MASK_CTRL_ERROR_CLEAR) = '1' then
            --clearing error
            state <= SM_IDLE;
          end if;
        -----------------------------------------------------
        -- other
        -----------------------------------------------------
        when others =>
          state <= SM_ERROR;
      end case;
    end if;
  end process state_machine;

  -------------------------------------------------------------------------------
  -- SM proc
  -------------------------------------------------------------------------------
  SM_proc: process (clk_axi, reset_axi_n) is
  begin  -- process SM_proc
    if reset_axi_n = '0' then           -- asynchronous reset (active low)
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      case state is
        -----------------------------------------------------
        -- SM_IDLE
        -----------------------------------------------------        
        when SM_IDLE =>
          if registers(REG_STATUS)(MASK_STATUS_ERROR) = '0' then
            
            --check if we are busy
            if registers(REG_STATUS)(MASK_STATUS_BUSY) = '0' then
              --check if there is a read or write request
              if (registers(REG_CTRL)(MASK_CTRL_RD_REQ) = '1' or
                  registers(REG_CTRL)(MASK_CTRL_WR_REQ) = '1') then
                --set busy in i2c_proc
                --capture the axi address to use
                axi_address( 7 downto  0) <= registers(REG_ADDR_BYTE0);
                axi_address(15 downto  8) <= registers(REG_ADDR_BYTE1);
                axi_address(23 downto 16) <= registers(REG_ADDR_BYTE2);
                axi_address(31 downto 24) <= registers(REG_ADDR_BYTE3);
                axi_address(39 downto 32) <= registers(REG_ADDR_BYTE4);                
              end if;
            end if;
          end if;
        -----------------------------------------------------
        -- SM_ERROR
        -----------------------------------------------------
        when SM_ERROR =>
          --in i2c_proc
        when others => null;
      end case;
    end if;
  end process SM_proc;

  -------------------------------------------------------------------------------
  -- Read proc
  -------------------------------------------------------------------------------
  read_proc: process (clk_axi, reset_axi_n) is
  begin  -- process read_proc
    if reset_axi_n = '0' then           -- asynchronous reset (active low)
      read_done  <= '0';
      axi_rd_en  <= '0';
      read_state <= SMR_IDLE;
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      axi_rd_en  <= '0';
      case read_state is
        -----------------------------------------------------
        -- SMR_IDLE
        -----------------------------------------------------
        when SMR_IDLE =>
          read_done <= '1';
          if state = SM_READ then
            read_state <= SMR_WAIT;
            read_done <= '0';
          end if;
        -----------------------------------------------------
        -- SMR_WAIT
        -----------------------------------------------------
        when SMR_WAIT =>
          if axi_busy = '0' then
            read_state <= SMR_READ_WAIT;
            axi_rd_en <= '1';
          end if;
        -----------------------------------------------------
        -- SMR_READ_WAIT
        -----------------------------------------------------          
        when SMR_READ_WAIT =>
         if axi_rd_data_valid = '1' then
           read_state <= SMR_IDLE;
         end if;
        -----------------------------------------------------
        -- SMR_ERROR
        -----------------------------------------------------         
        when SMR_ERROR =>
          read_state <= SMR_IDLE;
        -----------------------------------------------------
        -- others
        -----------------------------------------------------          
        when others =>
          read_state <= SMR_ERROR;
      end case;
    end if;
  end process read_proc;

  -------------------------------------------------------------------------------
  -- Write proc
  -------------------------------------------------------------------------------
  write_proc: process (clk_axi, reset_axi_n) is
  begin  -- process write_proc
    if reset_axi_n = '0' then           -- asynchronous reset (active low)
      write_done  <= '0';
      axi_wr_en  <= '0';
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      axi_wr_en  <= '0';
      case write_state is
        -----------------------------------------------------
        -- SMW_IDLE
        -----------------------------------------------------
        when SMW_IDLE =>
          write_done <= '1';
          if state = SM_WRITE then
            write_state <= SMW_WAIT;
            write_done <= '0';
          end if;
        -----------------------------------------------------
        -- SMW_WAIT
        -----------------------------------------------------
        when SMW_WAIT =>
          if axi_busy = '0' then
            write_state <= SMW_WRITE_WAIT;
            axi_wr_en <= '1';
          end if;
        -----------------------------------------------------
        -- SMW_WRITE_WAIT
        -----------------------------------------------------          
        when SMW_WRITE_WAIT =>
          if axi_busy = '0' then
            write_state <= SMW_IDLE;
          end if;
        -----------------------------------------------------
        -- SMW_ERROR
        -----------------------------------------------------         
        when SMW_ERROR =>
          write_state <= SMW_IDLE;
        -----------------------------------------------------
        -- others
        -----------------------------------------------------          
        when others =>
          write_state <= SMW_ERROR;
      end case;
    end if;
  end process write_proc;

  
end architecture behavioral;

