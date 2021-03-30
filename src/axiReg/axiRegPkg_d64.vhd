----------------------------------------------------------------------------------
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.types.all;
use work.AXIRegWidthPkg.all;
use work.AXIRegPkg.all;

package AXIRegPkg_d64 is

--  constant AXI_ID_BIT_COUNT : integer := 6;


  
  type AXIReadMOSI_d64 is record
    --read address
    address           : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);  -- ARADDR
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
  end record AXIReadMOSI_d64;
  type AXIReadMOSI_d64_array_t is array (integer range <>) of AXIReadMOSI_d64;
  constant DefaultAXIReadMOSI_d64 : AXIReadMOSI_d64 := (address => (others => '0'),
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
  
  
  type AXIReadMISO_d64 is record
    --read address
    ready_for_address : std_logic;      -- ARREADY

    --read data
    data_ID       : std_logic_vector(AXI_ID_BIT_COUNT-1 downto 0); --RID
    data          : slv_64_t;           -- RDATA
    data_valid    : std_logic;          -- RVALID
    response      : slv_2_t;            -- RRESP
    last          : std_logic;          -- RLAST
    data_user         : slv_4_t;        -- RUSER
  end record AXIReadMISO_d64;
  type AXIReadMISO_d64_array_t is array (integer range <>) of AXIReadMISO_d64;
  constant DefaultAXIReadMISO_d64 : AXIReadMISO_d64 := (ready_for_address => '0',
                                                data_ID => (others => '0'),
                                                data => (others => '0'),
                                                data_valid => '0',
                                                response => "00",
                                                last => '0',
                                                data_user => x"0");

  
  type AXIWriteMOSI_d64 is record
    --write address
    address         : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);   -- AWADDR
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
    address_user    : slv_4_t;          -- AWUSER
    
    --write data
    write_ID          : std_logic_vector(AXI_ID_BIT_COUNT-1 downto 0); --WID
    data              : slv_64_t;       -- WDATA
    data_valid        : std_logic;      -- WVALID
    data_write_strobe : slv_8_t;        -- WSTRB
    last              : std_logic;      -- WLAST
    data_user         : slv_4_t;        -- WUSER

    --write response
    ready_for_response : std_logic;         -- BREADY
  end record AXIWriteMOSI_d64;
  type AXIWriteMOSI_d64_array_t is array (integer range <>) of AXIWriteMOSI_d64;
  constant DefaultAXIWriteMOSI_d64 : AXIWriteMOSI_d64 := (address => (others => '0'),
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
                                                  data => (others => '0'),
                                                  data_valid => '0',
                                                  data_write_strobe => (others => '0'),
                                                  last => '0',
                                                  data_user => x"0",
                                                  ready_for_response => '0');    

  
  type AXIWriteMISO_d64 is record
    --write address
    ready_for_address : std_logic;      -- AWREADY

    --write data
    ready_for_data    : std_logic;      -- WREADY

    --write response
    response_ID       : std_logic_vector(AXI_ID_BIT_COUNT-1 downto 0); --BID
    response_valid    : std_logic;      -- BVALID
    response          : slv_2_t;        -- BRESP
    response_user     : slv_4_t;        -- BUSER
  end record AXIWriteMISO_d64;
  type AXIWriteMISO_d64_array_t is array (integer range <>) of AXIWriteMISO_d64;
  constant DefaultAXIWriteMISO_d64 : AXIWriteMISO_d64 := (ready_for_address => '0',
                                                  ready_for_data => '0',
                                                  response_ID => (others => '0'),                                                  
                                                  response_valid => '0',
                                                  response => "00",
                                                  response_user => x"0");
  
  
end package AXIRegPkg_d64;
