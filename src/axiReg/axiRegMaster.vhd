library ieee;
use ieee.std_logic_1164.all;

use work.axiRegWidthPkg.all;
use work.axiRegPkg.all;
use work.types.all;

entity axiLiteMaster is
  
  port (
    clk_axi      : in  std_logic;
    reset_axi_n  : in  std_logic;
    readMOSI     : out AXIreadMOSI;
    readMISO     : in  AXIreadMISO;
    writeMOSI    : out AXIwriteMOSI;
    writeMISO    : in  AXIwriteMISO;
    busy         : out std_logic;
    address      : in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
    rd_en        : in  std_logic;
    rd_data      : out slv_32_t;
    rd_data_valid: out std_logic;
    wr_data      : in  slv_32_t;
    wr_en        : in  std_logic);
end entity axiLiteMaster;

architecture behavioral of axiLiteMaster is

  --state machine
  type op_state_t is (SM_RESET,
                      SM_IDLE,
                      SM_READ_START,
                      SM_READ_WAIT,
                      SM_WRITE_START,
                      SM_WRITE_WAIT_SEND,
                      SM_WRITE_WAIT_RESP,
                      SM_FINISH);
  signal state : op_state_t;
  
  
  signal local_readMOSI_address_valid  : std_logic;
  signal local_readMOSI_address        : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
  signal local_writeMOSI_address_valid : std_logic;
  signal local_writeMOSI_address       : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
  signal local_writeMOSI_data_valid    : std_logic;
  signal local_writeMOSI_data          : slv_32_t;

  signal local_address_latch :std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
  signal local_data_latch    :slv_32_t;

  signal wr_waiting_for_ready_for_address : std_logic;
  signal wr_waiting_for_ready_for_data    : std_logic;
  
begin  -- architecture behaioral

  busy <= '0' when state = SM_IDLE else '1';
  state_machine_ctrl: process (clk_axi, reset_axi_n) is
  begin  -- process read_state_machine_ctrl
    if reset_axi_n = '0' then           -- asynchronous reset (active low)
      state <= SM_RESET;
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      case state is
        when SM_RESET =>
          state <= SM_IDLE;
        when SM_IDLE =>
          --logic for master starting transaction
          if wr_en = '1' then
            state <= SM_WRITE_START;
          elsif rd_en = '1' then
            state <= SM_READ_START;
          end if;
        when SM_READ_START =>
          state <= SM_READ_WAIT;
        when SM_READ_WAIT =>
          if readMISO.data_valid = '1' then
            state <= SM_IDLE;
          end if;
        when SM_WRITE_START =>
          state <= SM_WRITE_WAIT_SEND;          
        when SM_WRITE_WAIT_SEND =>
          if wr_waiting_for_ready_for_address = '0' and wr_waiting_for_ready_for_data = '0' then
            if writeMISO.response_valid = '1' then
              state <= SM_IDLE;
            else
              state <= SM_WRITE_WAIT_RESP;              
            end if;
          end if;
        when SM_WRITE_WAIT_RESP =>
          if writeMISO.response_valid = '1' then
            state <= SM_IDLE;
          end if;          
        when others            =>
          state <= SM_RESET;
      end case;
    end if;
  end process state_machine_ctrl;

  state_machine_latch: process (clk_axi, reset_axi_n) is
  begin  -- process read_state_machine_latch
    if reset_axi_n = '0' then           -- asynchronous reset (active high)
      rd_data_valid <= '0';
      local_readMOSI_address_valid  <= '0';
      local_writeMOSI_address_valid <= '0';
      local_writeMOSI_data_valid    <= '0';
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge      
      rd_data_valid <= '0';
      case state is       
        when SM_IDLE =>
          local_address_latch <= address;
          local_data_latch    <= wr_data;
        ---------------------------------
        -- Read transaction
        ---------------------------------                        
        when SM_READ_START =>          
          local_readMOSI_address_valid <= '1';
          local_readMOSI_address       <= local_address_latch;
        when SM_READ_WAIT  =>
          --handle case where 
          if readMISO.ready_for_address = '1' then
            local_readMOSI_address_valid <= '0';
          end if;
          if readMISO.data_valid = '1' then
            rd_data_valid <= '1';
            rd_data <= readMISO.data;
            local_readMOSI_address_valid <= '0';
          end if;
        ---------------------------------
        -- Write transaction
        ---------------------------------                        
        when SM_WRITE_START =>
          local_writeMOSI_address_valid <= '1';
          local_writeMOSI_address       <= local_address_latch;

          local_writeMOSI_data_valid    <= '1';
          local_writeMOSI_data          <= local_data_latch;
          
          wr_waiting_for_ready_for_address <= '1';
          wr_waiting_for_ready_for_data <= '1';          
          
        when SM_WRITE_WAIT_SEND =>

          if (wr_waiting_for_ready_for_address = '1' and
              writeMISO.ready_for_address = '1') then
            wr_waiting_for_ready_for_address <= '0';
            local_writeMOSI_address_valid <= '0';
          end if;

          if (wr_waiting_for_ready_for_data = '1' and
              writeMISO.ready_for_data = '1') then
            wr_waiting_for_ready_for_data <= '0';
            local_writeMOSI_data_valid <= '0';
          end if;
        when others => null;
      end case;
    end if;
  end process state_machine_latch;


  
  
  state_machine_proc: process (state,
                                    local_readMOSI_address_valid,
                                    local_readMOSI_address,
                                    local_writeMOSI_address_valid,
                                    local_writeMOSI_address,
                                    local_writeMOSI_data_valid,
                                    local_writeMOSI_data
                                    ) is
  begin  -- process read_state_machine_proc    
    --set unused values to default
    readMOSI  <= DefaultAXIReadMOSI;
    writeMOSI <= DefaultAXIWriteMOSI;

    --modifications
    writeMOSI.data_write_strobe <= x"f";
    
    --Set defaults for case controlled signals
    readMOSI.ready_for_data      <= '0';    
    writeMOSI.ready_for_response <= '0';    

    --Pass through signals assigned by clocked process;
    readMOSI.address_valid  <= local_readMOSI_address_valid;
    readMOSI.address        <= local_readMOSI_address;

    writeMOSI.address_valid <= local_writeMOSI_address_valid;
    writeMOSI.address       <= local_writeMOSI_address;
    writeMOSI.data_valid    <= local_writeMOSI_data_valid;
    writeMOSI.data          <= local_writeMOSI_data;           
      
    case state is
      when SM_READ_WAIT =>
        --Say we are ready for read data
        readMOSI.ready_for_data <= '1';
      when SM_WRITE_WAIT_SEND | SM_WRITE_WAIT_RESP =>
        --Say we are ready for write response when we are in either write wait state
        writeMOSI.ready_for_response <= '1';    
      when others => null;
    end case;
  end process state_machine_proc;

end architecture behavioral;

