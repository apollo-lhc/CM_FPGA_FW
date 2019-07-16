library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.axiRegPkg.all;
use work.types.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity top is
  port (
    -- clocks
    p_clk_200 : in  std_logic;
    n_clk_200 : in  std_logic;                -- 200 MHz system clock

    -- ATCA timing and control
    --input p_atca_ttc_in, n_atca_ttc_in,        -- GTH input, combined clock and data
    --output p_atca_tts_out, n_atca_tts_out,     -- GTH output
    -- legacy AMC13 signals
--    p_amc13_clk_40 : in  std_logic;
--    n_amc13_clk_40 : in  std_logic;      -- extracted 40 MHz experimental clock
--    p_amc13_cdr_data : in std_logic;
--    n_amc13_cdr_data : in  std_logic;  -- extracted TTC data
--    p_amc13_tts_out : out std_logic;
--    n_amc13_tts_out : out std_logic;   -- encoded TTS 
--    -- 2 positions from 4 position DIP SWITCH
--    dip_sw          : in std_logic_vector(3 downto 2); -- dip_sw[2] = position 2 of 4, no defined use yet
                                                       -- dip_sw[3] = position 3 of 4, no defined use yet
                                                       -- position 1 = boot mode , 0=MASTER_SPI, 1 = JTAG ONLY
                                                       -- position 4 = bit to TM4C

    -- Zynq AXI Chip2Chip
    n_util_clk_chan0 : in std_logic;
    p_util_clk_chan0 : in std_logic;
    n_mgt_z2k        : in  std_logic_vector(1 downto 1);
    p_mgt_z2k        : in  std_logic_vector(1 downto 1);
    n_mgt_k2z        : out std_logic_vector(1 downto 1);
    p_mgt_k2z        : out std_logic_vector(1 downto 1);

    
    -- tri-color LED
    led_red : out std_logic;
    led_green : out std_logic;
    led_blue : out std_logic       -- assert to turn on
    -- utility bits to/from TM4C
---    from_tm4c : in  std_logic;                           -- no defined use yet
---    to_tm4c   : out std_logic;                            -- no defined use yet
---    -- spare pairs from the VU7P, defined as inputs until an output is needed
---    p_kv_spare : in  std_logic_vector(12 downto 0);
---    n_kv_spare : in  std_logic_vector(12 downto 0); -- no defined use yet
---    -- test connector on bottom side of board, defined as inputs until an output is needed
---    p_test_conn : in std_logic_vector(5 downto 0);
---    n_test_conn : in std_logic_vector(5 downto 0) -- no defined use yet	
    );    
end entity top;

architecture structure of top is

  signal clk_200_raw     : std_logic;
  signal clk_200         : std_logic;
  signal clk_50          : std_logic;
  signal reset           : std_logic;
  signal counter         : unsigned(31 downto 0);
  signal locked_clk200   : std_logic;

  signal led_blue_local  : std_logic;
  signal led_red_local   : std_logic;
  signal led_green_local : std_logic;

  constant localAXISlaves    : integer := 2;
  signal local_AXI_ReadMOSI  :  AXIReadMOSI_array_t(0 to localAXISlaves-1);
  signal local_AXI_ReadMISO  :  AXIReadMISO_array_t(0 to localAXISlaves-1);
  signal local_AXI_WriteMOSI : AXIWriteMOSI_array_t(0 to localAXISlaves-1);
  signal local_AXI_WriteMISO : AXIWriteMISO_array_t(0 to localAXISlaves-1);
  signal AXI_CLK             : std_logic;
  signal AXI_RST_N           : std_logic;

  signal debug : std_logic_vector(2 downto 0);

  signal myreg1_test_vector : std_logic_vector(31 downto 0);
  signal myreg2_test_vector : std_logic_vector(31 downto 0);
  
begin  -- architecture structure

  --Clocking
  reset <= not locked_clk200;
  Local_Clocking_1: entity work.Local_Clocking
    port map (
      clk_200   => clk_200,
      clk_50    => clk_50,
      clk_axi   => AXI_CLK,
      reset     => '0',
      locked    => locked_clk200,
      clk_in1_p => p_clk_200,
      clk_in1_n => n_clk_200);

  led_blue  <= led_blue_local;
  led_red   <= led_red_local;
  led_green <= led_green_local;
  
  counter_proc: process (clk_200) is
  begin  -- process counter_proc
    if clk_200'event and clk_200 = '1' then  -- rising clock edge
      counter <= counter +1;
    end if;
  end process counter_proc;

  blink_led: process (clk_200) is
  begin  -- process blink_led
    if clk_200'event and clk_200 = '1' then  -- rising clock edge
      if counter(28 downto 0) = "1"&x"0000000" then
        if debug(0) = '1' then
          led_blue_local <= not led_blue_local;
        else
          led_blue_local <= '0';
        end if;

      end if;

      if counter(26 downto 0) = "110"&x"000000" then
        if debug(1) = '1' then
          led_red_local <= not led_red_local;
        else
          led_red_local <= '0';
        end if;
      end if;

      if counter(24 downto 0) = "1"&x"000000" then
        if debug(2) = '0' then
          led_green_local <= not led_green_local;
        else
          led_green_local <= '0';
        end if;
      end if;



      if myreg1_test_vector(0) = '1' then
        led_green_local <= '1';
      end if;
      if myreg1_test_vector(1) = '1' then
        led_red_local <= '1';
      end if;
      if myreg2_test_vector(0) = '1' then
        led_blue_local <= '1';
      end if;



    end if;
  end process blink_led;

  c2csslave_wrapper_1: entity work.c2cslave_wrapper
    port map (
      AXI_CLK                  => AXI_CLK,
      AXI_RST_N(0)             => AXI_RST_N,
      C2CLink_phy_Rx_rxn       => n_mgt_z2k,
      C2CLink_phy_Rx_rxp       => p_mgt_z2k,
      C2CLink_phy_Tx_txn       => n_mgt_k2z,
      C2CLink_phy_Tx_txp       => p_mgt_k2z,
      C2CLink_phy_refclk_clk_n => n_util_clk_chan0,
      C2CLink_phy_refclk_clk_p => p_util_clk_chan0,
      clk50Mhz                 => clk_50,
      myReg0_araddr            => local_AXI_ReadMOSI(0).address,              
      myReg0_arprot            => local_AXI_ReadMOSI(0).protection_type,      
      myReg0_arready(0)        => local_AXI_ReadMISO(0).ready_for_address,    
      myReg0_arvalid(0)        => local_AXI_ReadMOSI(0).address_valid,        
      myReg0_awaddr            => local_AXI_WriteMOSI(0).address,             
      myReg0_awprot            => local_AXI_WriteMOSI(0).protection_type,     
      myReg0_awready(0)        => local_AXI_WriteMISO(0).ready_for_address,   
      myReg0_awvalid(0)        => local_AXI_WriteMOSI(0).address_valid,       
      myReg0_bready(0)         => local_AXI_WriteMOSI(0).ready_for_response,  
      myReg0_bresp             => local_AXI_WriteMISO(0).response,            
      myReg0_bvalid(0)         => local_AXI_WriteMISO(0).response_valid,      
      myReg0_rdata             => local_AXI_ReadMISO(0).data,                 
      myReg0_rready(0)         => local_AXI_ReadMOSI(0).ready_for_data,       
      myReg0_rresp             => local_AXI_ReadMISO(0).response,             
      myReg0_rvalid(0)         => local_AXI_ReadMISO(0).data_valid,           
      myReg0_wdata             => local_AXI_WriteMOSI(0).data,                
      myReg0_wready(0)         => local_AXI_WriteMISO(0).ready_for_data,       
      myReg0_wstrb             => local_AXI_WriteMOSI(0).data_write_strobe,   
      myReg0_wvalid(0)         => local_AXI_WriteMOSI(0).data_valid,          
      myReg1_araddr            => local_AXI_ReadMOSI(1).address,              
      myReg1_arprot            => local_AXI_ReadMOSI(1).protection_type,      
      myReg1_arready(0)        => local_AXI_ReadMISO(1).ready_for_address,    
      myReg1_arvalid(0)        => local_AXI_ReadMOSI(1).address_valid,        
      myReg1_awaddr            => local_AXI_WriteMOSI(1).address,             
      myReg1_awprot            => local_AXI_WriteMOSI(1).protection_type,     
      myReg1_awready(0)        => local_AXI_WriteMISO(1).ready_for_address,   
      myReg1_awvalid(0)        => local_AXI_WriteMOSI(1).address_valid,       
      myReg1_bready(0)         => local_AXI_WriteMOSI(1).ready_for_response,  
      myReg1_bresp             => local_AXI_WriteMISO(1).response,            
      myReg1_bvalid(0)         => local_AXI_WriteMISO(1).response_valid,      
      myReg1_rdata             => local_AXI_ReadMISO(1).data,                 
      myReg1_rready(0)         => local_AXI_ReadMOSI(1).ready_for_data,       
      myReg1_rresp             => local_AXI_ReadMISO(1).response,             
      myReg1_rvalid(0)         => local_AXI_ReadMISO(1).data_valid,           
      myReg1_wdata             => local_AXI_WriteMOSI(1).data,                
      myReg1_wready(0)         => local_AXI_WriteMISO(1).ready_for_data,       
      myReg1_wstrb             => local_AXI_WriteMOSI(1).data_write_strobe,   
      myReg1_wvalid(0)         => local_AXI_WriteMOSI(1).data_valid,          
      reset_n                  => locked_clk200,--reset,
      C2CLink_aurora_do_cc                => open, 
      C2CLink_axi_c2c_config_error_out    => open, 
      C2CLink_axi_c2c_link_status_out     => open, 
      C2CLink_axi_c2c_multi_bit_error_out => open, 
      C2CLink_phy_gt_pll_lock             => debug(0), 
      C2CLink_phy_hard_err                => open, 
      C2CLink_phy_lane_up                 => debug(1 downto 1), 
      C2CLink_phy_link_reset_out          => open, 
      C2CLink_phy_mmcm_not_locked_out     => debug(2), 
      C2CLink_phy_power_down              => '0', 
      C2CLink_phy_soft_err                => open 

);

  myReg_1: entity work.myReg
    port map (
      clk_axi     => AXI_CLK,
      reset_axi_n => AXI_RST_N,
      readMOSI    => local_AXI_ReadMOSI(0),
      readMISO    => local_AXI_ReadMISO(0),
      writeMOSI   => local_AXI_WriteMOSI(0),
      writeMISO   => local_AXI_WriteMISO(0),
      test        => myreg1_test_vector);
  myReg_2: entity work.myReg
    port map (
      clk_axi     => AXI_CLK,
      reset_axi_n => AXI_RST_N,
      readMOSI    => local_AXI_ReadMOSI(1),
      readMISO    => local_AXI_ReadMISO(1),
      writeMOSI   => local_AXI_WriteMOSI(1),
      writeMISO   => local_AXI_WriteMISO(1),
      test        => myreg2_test_vector);

  
end architecture structure;
