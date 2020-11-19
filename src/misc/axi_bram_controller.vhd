library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.AXIRegPkg.all;

library axi_bram_ctrl_v4_1_2;
use axi_bram_ctrl_v4_1_2.axi_bram_ctrl;

entity axi_bram_controller is
  generic (

    C_ADR_WIDTH  : integer := 32;
    C_DATA_WIDTH : integer := 32;

    -- options: virtex7, kintexuplus, virtexuplus, etc.
    -- Specify the target architecture type
    C_FAMILY : string := "kintexuplus";

    --------------------------------------------------------------------------------
    -- Block Ram Configuration
    --------------------------------------------------------------------------------

    --determines whether the bmg is external or internal to axi bram ctrl wrapper
    C_BRAM_INST_MODE   : string  := "EXTERNAL";  -- external ; internal
    C_MEMORY_DEPTH     : integer := 4096;        --Memory depth specified by the user
    C_BRAM_ADDR_WIDTH  : integer := 12;          -- Width of bram address bus (in bits)
    C_SINGLE_PORT_BRAM : integer := 1;           -- Enable single port usage of BRAM
    C_READ_LATENCY     : integer := 1;
    C_RD_CMD_OPTIMIZATION  : integer := 1;

    --------------------------------------------------------------------------------
    -- AXI Configuration
    --------------------------------------------------------------------------------

    C_S_AXI_ID_WIDTH              : integer := AXI_ID_BIT_COUNT;  --  AXI ID vector width
    C_S_AXI_ADDR_WIDTH            : integer := 32;                -- Width of AXI address bus (in bits)
    C_S_AXI_DATA_WIDTH            : integer := 32;                -- Width of AXI data bus (in bits)
    C_S_AXI_PROTOCOL              : string  := "AXI4LITE";        -- Set to AXI4LITE to optimize out burst transaction support
    C_S_AXI_SUPPORTS_NARROW_BURST : integer := 1;                 -- Support for narrow burst operations

    --------------------------------------------------------------------------------
    -- ECC Configuration
    --------------------------------------------------------------------------------

    -- AXI-Lite ECC Control Port Register Parameters
    C_S_AXI_CTRL_ADDR_WIDTH : integer := 32;  -- Width of AXI-Lite address bus (in bits)
    C_S_AXI_CTRL_DATA_WIDTH : integer := 32;  -- Width of AXI-Lite data bus (in bits)

    -- ECC is enabled by configuring the design parameter, C_ECC = 1.
    C_ECC                   : integer := 0;  -- Enables or disables ECC functionality
    C_ECC_TYPE              : integer := 1;  -- ECC algorithm
    C_FAULT_INJECT          : integer := 0;  -- Enable fault injection registers (default = disabled)
    C_ECC_ONOFF_RESET_VALUE : integer := 1   -- By default, ECC checking is on (can disable ECC @ reset by setting this to 0)
    );
  port (

    -- AXI Common
    s_axi_aclk    : in std_logic;
    s_axi_aresetn : in std_logic;

    -- Block RAM AXI Ports
    r_mosi : in  axireadmosi;
    r_miso : out axireadmiso;
    w_mosi : in  axiwritemosi;
    w_miso : out axiwritemiso;

    -- AXI Lite Port for ECC Control
    ecc_r_mosi : in  axireadmosi  := defaultaxireadmosi;
    ecc_r_miso : out axireadmiso  ;
    ecc_w_mosi : in  axiwritemosi := defaultaxiwritemosi;
    ecc_w_miso : out axiwritemiso;

    -- AXI Lite Port for ECC Control
    -- Interrupt to signal ECC error condition: Signal unused when C_ECC = 0
    ecc_interrupt : out std_logic;
    -- ECC uncorrectable error output flag: The behavior of this flag is described in ECC. Signal unused when C_ECC = 0.
    ecc_ue        : out std_logic;

    bram_rst_a    : out std_logic;
    bram_clk_a    : out std_logic;
    bram_en_a     : out std_logic;
    bram_we_a     : out std_logic_vector(C_DATA_WIDTH/8-1 downto 0);
    bram_addr_a   : out std_logic_vector(C_ADR_WIDTH-1 downto 0);
    bram_wrdata_a : out std_logic_vector(C_DATA_WIDTH-1 downto 0);
    bram_rddata_a : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);

    bram_rst_b    : out std_logic;
    bram_clk_b    : out std_logic;
    bram_en_b     : out std_logic;
    bram_we_b     : out std_logic_vector(C_DATA_WIDTH/8-1 downto 0);
    bram_addr_b   : out std_logic_vector(C_ADR_WIDTH-1 downto 0);
    bram_wrdata_b : out std_logic_vector(C_DATA_WIDTH-1 downto 0);
    bram_rddata_b : in  std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0')
    );
end axi_bram_controller;

architecture axi_bram_controller_arch of axi_bram_controller is

  component axi_bram_ctrl is
    generic (
      C_BRAM_INST_MODE              : string;
      C_MEMORY_DEPTH                : integer;
      C_BRAM_ADDR_WIDTH             : integer;
      C_S_AXI_ADDR_WIDTH            : integer;
      C_S_AXI_DATA_WIDTH            : integer;
      C_S_AXI_ID_WIDTH              : integer;
      C_S_AXI_PROTOCOL              : string;
      C_S_AXI_SUPPORTS_NARROW_BURST : integer;
      C_SINGLE_PORT_BRAM            : integer;
      C_FAMILY                      : string;
      C_READ_LATENCY                : integer;
      C_RD_CMD_OPTIMIZATION         : integer;
      C_S_AXI_CTRL_ADDR_WIDTH       : integer;
      C_S_AXI_CTRL_DATA_WIDTH       : integer;
      C_ECC                         : integer;
      C_ECC_TYPE                    : integer;
      C_FAULT_INJECT                : integer;
      C_ECC_ONOFF_RESET_VALUE       : integer
      );
    port (
      s_axi_aclk         : in  std_logic;
      s_axi_aresetn      : in  std_logic;
      ecc_interrupt      : out std_logic;
      ecc_ue             : out std_logic;
      s_axi_awid         : in  std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
      s_axi_awaddr       : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
      s_axi_awlen        : in  std_logic_vector(7 downto 0);
      s_axi_awsize       : in  std_logic_vector(2 downto 0);
      s_axi_awburst      : in  std_logic_vector(1 downto 0);
      s_axi_awlock       : in  std_logic;
      s_axi_awcache      : in  std_logic_vector(3 downto 0);
      s_axi_awprot       : in  std_logic_vector(2 downto 0);
      s_axi_awvalid      : in  std_logic;
      s_axi_awready      : out std_logic;
      s_axi_wdata        : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      s_axi_wstrb        : in  std_logic_vector(3 downto 0);
      s_axi_wlast        : in  std_logic;
      s_axi_wvalid       : in  std_logic;
      s_axi_wready       : out std_logic;
      s_axi_bid          : out std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
      s_axi_bresp        : out std_logic_vector(1 downto 0);
      s_axi_bvalid       : out std_logic;
      s_axi_bready       : in  std_logic;
      s_axi_arid         : in  std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
      s_axi_araddr       : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
      s_axi_arlen        : in  std_logic_vector(7 downto 0);
      s_axi_arsize       : in  std_logic_vector(2 downto 0);
      s_axi_arburst      : in  std_logic_vector(1 downto 0);
      s_axi_arlock       : in  std_logic;
      s_axi_arcache      : in  std_logic_vector(3 downto 0);
      s_axi_arprot       : in  std_logic_vector(2 downto 0);
      s_axi_arvalid      : in  std_logic;
      s_axi_arready      : out std_logic;
      s_axi_rid          : out std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
      s_axi_rdata        : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      s_axi_rresp        : out std_logic_vector(1 downto 0);
      s_axi_rlast        : out std_logic;
      s_axi_rvalid       : out std_logic;
      s_axi_rready       : in  std_logic;
      s_axi_ctrl_awvalid : in  std_logic;
      s_axi_ctrl_awready : out std_logic;
      s_axi_ctrl_awaddr  : in  std_logic_vector(C_S_AXI_CTRL_ADDR_WIDTH-1 downto 0);
      s_axi_ctrl_wdata   : in  std_logic_vector(C_S_AXI_CTRL_DATA_WIDTH-1 downto 0);
      s_axi_ctrl_wvalid  : in  std_logic;
      s_axi_ctrl_wready  : out std_logic;
      s_axi_ctrl_bresp   : out std_logic_vector(1 downto 0);
      s_axi_ctrl_bvalid  : out std_logic;
      s_axi_ctrl_bready  : in  std_logic;
      s_axi_ctrl_araddr  : in  std_logic_vector(C_S_AXI_CTRL_ADDR_WIDTH-1 downto 0);
      s_axi_ctrl_rdata   : out std_logic_vector(C_S_AXI_CTRL_DATA_WIDTH-1 downto 0);
      s_axi_ctrl_arvalid : in  std_logic;
      s_axi_ctrl_arready : out std_logic;
      s_axi_ctrl_rresp   : out std_logic_vector(1 downto 0);
      s_axi_ctrl_rvalid  : out std_logic;
      s_axi_ctrl_rready  : in  std_logic;
      bram_rst_a         : out std_logic;
      bram_clk_a         : out std_logic;
      bram_en_a          : out std_logic;
      bram_we_a          : out std_logic_vector(C_DATA_WIDTH/8-1 downto 0);
      bram_addr_a        : out std_logic_vector(C_ADR_WIDTH-1 downto 0);
      bram_wrdata_a      : out std_logic_vector(C_DATA_WIDTH-1 downto 0);
      bram_rddata_a      : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
      bram_rst_b         : out std_logic;
      bram_clk_b         : out std_logic;
      bram_en_b          : out std_logic;
      bram_we_b          : out std_logic_vector(C_DATA_WIDTH/8-1 downto 0);
      bram_addr_b        : out std_logic_vector(C_ADR_WIDTH-1 downto 0);
      bram_wrdata_b      : out std_logic_vector(C_DATA_WIDTH-1 downto 0);
      bram_rddata_b      : in  std_logic_vector(C_DATA_WIDTH-1 downto 0)
      );
  end component axi_bram_ctrl;

begin

  U0 : entity work.axi_bram_ctrl
    generic map (
      C_BRAM_INST_MODE              => C_BRAM_INST_MODE,
      C_MEMORY_DEPTH                => C_MEMORY_DEPTH,
      C_BRAM_ADDR_WIDTH             => C_BRAM_ADDR_WIDTH,
      C_S_AXI_ADDR_WIDTH            => C_S_AXI_ADDR_WIDTH,
      C_S_AXI_DATA_WIDTH            => C_S_AXI_DATA_WIDTH,
      C_S_AXI_ID_WIDTH              => C_S_AXI_ID_WIDTH,
      C_S_AXI_PROTOCOL              => C_S_AXI_PROTOCOL,
      C_S_AXI_SUPPORTS_NARROW_BURST => C_S_AXI_SUPPORTS_NARROW_BURST,
      C_SINGLE_PORT_BRAM            => C_SINGLE_PORT_BRAM,
      C_FAMILY                      => C_FAMILY,
      C_READ_LATENCY                => C_READ_LATENCY,
      C_RD_CMD_OPTIMIZATION         => C_RD_CMD_OPTIMIZATION,
      C_S_AXI_CTRL_ADDR_WIDTH       => C_S_AXI_CTRL_ADDR_WIDTH,
      C_S_AXI_CTRL_DATA_WIDTH       => C_S_AXI_CTRL_DATA_WIDTH,
      C_ECC                         => C_ECC,
      C_ECC_TYPE                    => C_ECC_TYPE,
      C_FAULT_INJECT                => C_FAULT_INJECT,
      C_ECC_ONOFF_RESET_VALUE       => C_ECC_ONOFF_RESET_VALUE
      )
    port map (
      s_axi_aclk    => s_axi_aclk,
      s_axi_aresetn => s_axi_aresetn,
      ecc_interrupt => ecc_interrupt,
      ecc_ue        => ecc_ue,

      --------------------------------------------------------------------------------
      -- Write
      --------------------------------------------------------------------------------
      -- axi write, mosi, address
      s_axi_awaddr  => w_mosi.address,
      s_axi_awprot  => w_mosi.protection_type,
      s_axi_awvalid => w_mosi.address_valid,
      s_axi_awlen   => w_mosi.burst_length,
      s_axi_awsize  => w_mosi.burst_size,
      s_axi_awburst => w_mosi.burst_type,
      s_axi_awlock  => w_mosi.lock_type,
      s_axi_awcache => w_mosi.cache_type,
      s_axi_bready  => w_mosi.ready_for_response,

      -- axi write, mosi, data
      s_axi_awid   => w_mosi.write_id,
      s_axi_wdata  => w_mosi.data,
      s_axi_wvalid => w_mosi.data_valid,
      s_axi_wstrb  => w_mosi.data_write_strobe,
      s_axi_wlast  => w_mosi.last,

      -- axi write, miso, address
      s_axi_awready => w_miso.ready_for_address,
      -- axi write, miso, data
      s_axi_wready  => w_miso.ready_for_data,
      -- axi write, miso, response
      s_axi_bid     => w_miso.response_id,
      s_axi_bresp   => w_miso.response,
      s_axi_bvalid  => w_miso.response_valid,

      --------------------------------------------------------------------------------
      -- Read
      --------------------------------------------------------------------------------
      -- axi read, mosi, address
      s_axi_araddr  => r_mosi.address,
      s_axi_arid    => r_mosi.address_id,
      s_axi_arprot  => r_mosi.protection_type,
      s_axi_arvalid => r_mosi.address_valid,
      s_axi_arlen   => r_mosi.burst_length,
      s_axi_arsize  => r_mosi.burst_size,
      s_axi_arburst => r_mosi.burst_type,
      s_axi_arlock  => r_mosi.lock_type,
      s_axi_arcache => r_mosi.cache_type,

      s_axi_rready => r_mosi.ready_for_data,

      -- axi read, miso
      s_axi_arready => r_miso.ready_for_address,
      s_axi_rid     => r_miso.data_id,
      s_axi_rdata   => r_miso.data,
      s_axi_rvalid  => r_miso.data_valid,
      s_axi_rresp   => r_miso.response,
      s_axi_rlast   => r_miso.last,

      --------------------------------------------------------------------------------
      -- AXI4-Lite Control Signals (Only Available when C_ecc = 1)
      --------------------------------------------------------------------------------

      -- write
      s_axi_ctrl_wdata   => ecc_w_mosi.data,
      s_axi_ctrl_wvalid  => ecc_w_mosi.data_valid,
      s_axi_ctrl_wready  => ecc_w_miso.ready_for_data,
      s_axi_ctrl_bready  => ecc_w_mosi.ready_for_response,
      s_axi_ctrl_awvalid => ecc_w_mosi.address_valid,
      s_axi_ctrl_awready => ecc_w_miso.ready_for_address,
      s_axi_ctrl_awaddr  => ecc_w_mosi.address,
      s_axi_ctrl_bresp   => ecc_w_miso.response,
      s_axi_ctrl_bvalid  => ecc_w_miso.response_valid,

      -- read
      s_axi_ctrl_araddr  => ecc_r_mosi.address,
      s_axi_ctrl_arvalid => ecc_r_mosi.address_valid,
      s_axi_ctrl_rready  => ecc_r_mosi.ready_for_data,
      s_axi_ctrl_arready => ecc_r_miso.ready_for_address,
      s_axi_ctrl_rdata   => ecc_r_miso.data,
      s_axi_ctrl_rvalid  => ecc_r_miso.data_valid,
      s_axi_ctrl_rresp   => ecc_r_miso.response,

      -- bram a port
      bram_rst_a    => bram_rst_a,
      bram_clk_a    => bram_clk_a,
      bram_en_a     => bram_en_a,
      bram_we_a     => bram_we_a,
      bram_addr_a   => bram_addr_a,
      bram_wrdata_a => bram_wrdata_a,
      bram_rddata_a => bram_rddata_a,

      -- bram b port
      bram_rst_b    => bram_rst_b,
      bram_clk_b    => bram_clk_b,
      bram_en_b     => bram_en_b,
      bram_we_b     => bram_we_b,
      bram_addr_b   => bram_addr_b,
      bram_wrdata_b => bram_wrdata_b,
      bram_rddata_b => bram_rddata_b

      );
end axi_bram_controller_arch;
