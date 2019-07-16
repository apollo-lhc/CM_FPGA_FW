----------------------------------------------------------------------------------
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.types.all;

package AXIRegPkg is

  constant AXI_ID_BIT_COUNT : integer := 6;

  
  type AXIReadMOSI is record
    --read address
    address           : slv_32_t;                 -- ARADDR
    address_ID        : std_logic_vector(AXI_ID_BIT_COUNT-1 downto 0); --ARID
    protection_type   : slv_3_t;          -- ARPROT
    address_valid     : std_logic;          -- ARVALID
    burst_length      : slv_8_t;          -- ARLEN
    burst_size        : slv_3_t;          -- ARSIZE
    burst_type        : slv_2_t;          -- ARBURST
    lock_type         : std_logic;        -- ARLOCK
    cache_type        : slv_4_t;          -- ARCACHE
    qos               : slv_4_t;          -- ARQOS
    region            : slv_4_t;          -- ARREGION
    address_user      : slv_4_t;          -- ARUSER
    
    --read data                         
    ready_for_data : std_logic;         -- RREADY
  end record AXIReadMOSI;
  type AXIReadMOSI_array_t is array (integer range <>) of AXIReadMOSI;
  constant DefaultAXIReadMOSI : AXIReadMOSI := (address => x"00000000",
                                                address_ID => (others => '0'),
                                                protection_type => "000",
                                                address_valid => '0',
                                                burst_length => x"00",
                                                burst_size => "000",
                                                burst_type => "01",
                                                lock_type => '0',
                                                cache_type => x"0",
                                                qos => x"0",
                                                region => x"0",
                                                address_user => x"0",
                                                ready_for_Data => '0');
  
  
  type AXIReadMISO is record
    --read address
    ready_for_address : std_logic;      -- ARREADY

    --read data
    data_ID       : std_logic_vector(AXI_ID_BIT_COUNT-1 downto 0); --RID
    data          : slv_32_t;           -- RDATA
    data_valid    : std_logic;          -- RVALID
    response      : slv_2_t;            -- RRESP
    last          : std_logic;          -- RLAST
    data_user         : slv_4_t;        -- RUSER
  end record AXIReadMISO;
  type AXIReadMISO_array_t is array (integer range <>) of AXIReadMISO;
  constant DefaultAXIReadMISO : AXIReadMISO := (ready_for_address => '0',
                                                data_ID => (others => '0'),
                                                data => x"00000000",
                                                data_valid => '0',
                                                response => "00",
                                                last => '0',
                                                data_user => x"0");

  
  type AXIWriteMOSI is record
    --write address
    address         : slv_32_t;         -- AWADDR
    address_ID      : std_logic_vector(AXI_ID_BIT_COUNT-1 downto 0); --AWID
    protection_type : slv_3_t;          -- AWPROT
    address_valid   : std_logic;        -- AWVALID
    burst_length    : slv_8_t;          -- AWLEN
    burst_size      : slv_3_t;          -- AWSIZE
    burst_type      : slv_2_t;          -- AWBURST
    lock_type       : std_logic;        -- AWLOCK
    cache_type      : slv_4_t;          -- AWCACHE
    qos             : slv_4_t;          -- AWQOS
    region          : slv_4_t;          -- AWREGION
    address_user      : slv_4_t;        -- AWUSER
    
    --write data
    write_ID        : std_logic_vector(AXI_ID_BIT_COUNT-1 downto 0); --WID
    data : slv_32_t;                    -- WDATA
    data_valid : std_logic;             -- WVALID
    data_write_strobe : slv_4_t;        -- WSTRB
    last              : std_logic;      -- WLAST
    data_user         : slv_4_t;        -- WUSER

    --write response
    ready_for_response : std_logic;         -- BREADY
  end record AXIWriteMOSI;
  type AXIWriteMOSI_array_t is array (integer range <>) of AXIWriteMOSI;
  constant DefaultAXIWriteMOSI : AXIWriteMOSI := (address => x"00000000",
                                                  address_ID => (others => '0'),
                                                  protection_type => "000",
                                                  address_valid => '0',
                                                  burst_length => x"00",
                                                  burst_size => "000",
                                                  burst_type => "01",
                                                  lock_type => '0',
                                                  cache_type => x"0",
                                                  qos => x"0",
                                                  region => x"0",
                                                  address_user => x"0",
                                                  write_ID => (others => '0'),
                                                  data => x"00000000",
                                                  data_valid => '0',
                                                  data_write_strobe => x"0",
                                                  last => '0',
                                                  data_user => x"0",
                                                  ready_for_response => '0');    

  
  type AXIWriteMISO is record
    --write address
    ready_for_address : std_logic;      -- AWREADY

    --write data
    ready_for_data    : std_logic;      -- WREADY

    --write response
    response_ID       : std_logic_vector(AXI_ID_BIT_COUNT-1 downto 0); --BID
    response_valid    : std_logic;      -- BVALID
    response          : slv_2_t;        -- BRESP
    response_user     : slv_4_t;        -- BUSER
  end record AXIWriteMISO;
  type AXIWriteMISO_array_t is array (integer range <>) of AXIWriteMISO;
  constant DefaultAXIWriteMISO : AXIWriteMISO := (ready_for_address => '0',
                                                  ready_for_data => '0',
                                                  response_ID => (others => '0'),                                                  
                                                  response_valid => '0',
                                                  response => "00",
                                                  response_user => x"0");
  
  
end package AXIRegPkg;
