library ieee;
use ieee.std_logic_1164.all;

use work.axiRegPkg.all;
use work.types.all;

entity axiLiteReg is
  
  port (
    clk_axi     : in  std_logic;
    reset_axi_n : in  std_logic;
    readMOSI    : in  AXIreadMOSI;
    readMISO    : out AXIreadMISO;
    writeMOSI   : in  AXIwriteMOSI;
    writeMISO   : out AXIwriteMISO;
    address     : out slv_32_t;
    rd_data     : in  slv_32_t;
    wr_data     : out slv_32_t;
    write_en    : out std_logic;
    read_req    : out std_logic;
    read_ack    : in  std_logic);
end entity axiLiteReg;

architecture behavioral of axiLiteReg is

  --state machine
  type read_state_t is (SMR_RESET,
                        SMR_IDLE,
                        SMR_REQUEST,
                        SMR_RESPONSE,
                        SMR_SEND,
                        SMR_ERROR);
  signal read_state : read_state_t;
  signal read_address : slv_32_t;

  type write_state_t is (SMW_RESET,
                         SMW_IDLE, 
                         SMW_ADDR,
                         SMW_DATA,
                         SMW_RESPOND,
                         SMW_ERROR);
  signal write_state : write_state_t;
  signal write_address : slv_32_t;

  type arbitrator_state_t is (SMA_RESET,
                              SMA_IDLE,
                              SMA_READ,
                              SMA_WRITE,
                              SMA_ERROR);
  signal arbt_state : arbitrator_state_t;
  

  
  signal localReadMISO   : AXIreadMISO;
  signal localWriteMISO  : AXIwriteMISO;
  
begin  -- architecture behaioral


  -------------------------------------------------------------------------------
  -- RW arbitrator
  -------------------------------------------------------------------------------
  
  arbitrator_state_machine_ctr: process (clk_axi, reset_axi_n) is
  begin  -- process arbitrator_state_machine_ctr
    if reset_axi_n = '0' then          -- asynchronous reset (active high)
      arbt_state <= SMA_RESET;
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      case arbt_state is
        when SMA_RESET       =>  arbt_state <= SMA_IDLE ;
                                 
        when SMA_IDLE        =>
          if writeMOSI.address_valid = '1' and localWriteMISO.ready_for_address = '1' then
            arbt_state <= SMA_WRITE;
          elsif localReadMISO.ready_for_address = '1' and readMOSI.address_valid = '1' then
            arbt_state <= SMA_READ;
          else
            arbt_state <= SMA_IDLE;
          end if;
        when SMA_READ        =>
          if localReadMISO.data_valid = '1' and readMOSI.ready_for_data = '1' then
            arbt_state <= SMA_IDLE;
          else
            arbt_state <= SMA_READ;
          end if;
        when SMA_WRITE       =>
          if localWriteMISO.response_valid = '1' and writeMOSI.ready_for_response = '1' then
            arbt_state <= SMA_IDLE;
          else
            arbt_state <= SMA_WRITE;
          end if;
        when others          => arbt_state <= SMA_RESET;
      end case;
    end if;
  end process arbitrator_state_machine_ctr; 

  arbitrator_state_machine_proc: process (arbt_state,read_address,write_address) is
  begin  -- process arbitrator_state_machine_proc
    case arbt_state is
      when SMA_READ          => address <= "00" & read_address (31 downto 2);
      when SMA_WRITE         => address <= "00" & write_address(31 downto 2);
      when others            => address <= x"FFFFFFFF";
    end case;
  end process arbitrator_state_machine_proc;


  -------------------------------------------------------------------------------
  -- Read operations
  -------------------------------------------------------------------------------
  
  read_state_machine_ctrl: process (clk_axi, reset_axi_n) is
  begin  -- process read_state_machine_ctrl
    if reset_axi_n = '0' then           -- asynchronous reset (active low)
      read_state <= SMR_RESET;
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      case read_state is
        when SMR_RESET         =>  read_state <= SMR_IDLE;                                   
        when SMR_IDLE          =>
          if localReadMISO.ready_for_address = '1' and readMOSI.address_valid = '1' then
            read_state <= SMR_REQUEST;
          else
            read_state <= SMR_IDLE;
          end if;
        when SMR_REQUEST       =>
          if arbt_state = SMA_READ then
            --We force the read SM to wait until the arbt SM changes state to
            --give priority to the write SM
            read_state <= SMR_RESPONSE;            
          end if;          
        when SMR_RESPONSE      =>
          if readMOSI.ready_for_data = '1' then
            read_state <= SMR_IDLE;
          else
            read_state <= SMR_SEND;
          end if;
        when SMR_SEND          =>
          if localReadMISO.data_valid = '1' and readMOSI.ready_for_data = '1' then
            read_state <= SMR_IDLE;
          else
            read_state <= SMR_SEND;
          end if;            

        when others            =>
          read_state <= SMR_RESET;
      end case;
    end if;
  end process read_state_machine_ctrl;

  read_state_machine_latch: process (clk_axi, reset_axi_n) is
  begin  -- process read_state_machine_latch
    if reset_axi_n = '0' then           -- asynchronous reset (active high)
      readMISO  <= DefaultAXIReadMISO;
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      readMISO.ready_for_address  <= localReadMISO.ready_for_address;
      readMISO.data_valid         <= localReadMISO.data_valid;

      case read_state is
        when SMR_IDLE =>
          if localReadMISO.ready_for_address = '1' and readMOSI.address_valid = '1' then
            read_address <= readMOSI.address; --latch the address
          end if;
        when SMR_RESPONSE =>
          readMISO.data <= rd_data;
          if read_ack = '1' then        --OK address found            
            localReadMISO.response <= "00";
          else                          --Address not found                       
            localReadMISO.response <= "10";
          end if;          
        when others => null;
      end case;
    end if;
  end process read_state_machine_latch;

  read_state_machine_proc: process (read_state,
                                    arbt_state,
                                    rd_data,read_ack,
                                    readMOSI.address_valid,     readMOSI.ready_for_data,
                                    localReadMISO.ready_for_address, localReadMISO.data_valid) is
  begin  -- process read_state_machine_proc
    localReadMISO.ready_for_address <= '0';
    localReadMISO.data_valid <= '0';                        
    read_req <= '0';
    
    case read_state is
      when SMR_RESET => NULL;
      when SMR_IDLE  =>
        localReadMISO.ready_for_address <= '1';
      when SMR_REQUEST =>
        if arbt_state = SMA_READ then          
          read_req <= '1';          
        end if;
      when SMR_RESPONSE =>
        localReadMISO.data_valid <= '1';
      when SMR_SEND =>
        localReadMISO.data_valid <= '1';
      when others => null;
    end case;
  end process read_state_machine_proc;

  -------------------------------------------------------------------------------
  -- Write operations
  -------------------------------------------------------------------------------

  write_state_machine_ctrl: process (clk_axi, reset_axi_n) is
  begin  -- process write_state_machine_ctrl
    if reset_axi_n = '0' then           -- asynchronous reset (active low)
      write_state <= SMW_RESET;
      writeMISO  <= DefaultAXIWriteMISO;
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      writeMISO <= localWriteMISO;
      write_en <= '0';
      
      case write_state is
        when SMW_RESET =>
          write_state <= SMW_IDLE;        
        when SMW_IDLE =>
          if writeMOSI.address_valid = '1' and localWriteMISO.ready_for_address = '1' then          
            write_state <= SMW_ADDR;
            write_address <= writeMOSI.address; --latch the address
          end if;
        when SMW_ADDR =>
          if writeMOSI.data_valid = '1' and localWriteMISO.ready_for_data = '1' then
            write_state <= SMW_DATA;
            wr_data <= writeMOSI.data;
            write_en <= '1';        
          end if;
        when SMW_DATA =>
          write_state <= SMW_RESPOND;
        when SMW_RESPOND =>
          if localWriteMISO.response_valid = '1' and writeMOSI.ready_for_response = '1' then
            write_state <= SMW_IDLE;          
          end if;
        when others =>    
          write_state <= SMW_RESET;
      end case;
    end if;
  end process write_state_machine_ctrl;
  
  write_state_machine_proc: process (write_state,
                                     arbt_state,
                                     writeMOSI.address_valid, localWriteMISO.ready_for_address
                                     ) is
  begin  -- process write_state_machine_proc
    localWriteMISO <= DefaultAXIWriteMISO;
    case write_state is    
      when SMW_RESET => NULL;
      when SMW_IDLE  =>
        localWriteMISO.ready_for_address <= '1';
        if writeMOSI.address_valid = '1' and localWriteMISO.ready_for_address = '1' then
          
        end if;
      when SMW_ADDR  =>
        if arbt_state = SMA_WRITE then
          localWriteMISO.ready_for_data <= '1';
        end if;
      when SMW_DATA => NULL;
        
      when SMW_RESPOND =>
        localWriteMISO.response_valid <= '1';
        localWriteMISO.response <= "00"; --address found (fix?)
      when others => null;
    end case;
  end process write_state_machine_proc;
end architecture behavioral;

