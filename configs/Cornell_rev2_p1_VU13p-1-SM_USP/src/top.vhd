library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.axiRegPkg.all;
use work.axiRegPkg_d64.all;
use work.types.all;
use work.IO_Ctrl.all;
use work.C2C_INTF_CTRL.all;
use work.AXISlaveAddrPkg.all;                                                                                              

use work.Global_PKG.all;


Library UNISIM;
use UNISIM.vcomponents.all;

entity top is
  port (
    -- clocks
    p_clk_200 : in  std_logic;
    n_clk_200 : in  std_logic;                -- 200 MHz system clock

    -- A copy of the RefClk#0 used by the 12-channel FireFlys on the left side of the FPGA.
    --This can be the output of either refclk synthesizer R0A or R0B. 
    p_lf_x12_r0_clk : in std_logic;
    n_lf_x12_r0_clk : in std_logic;
    
  --  -- A copy of the RefClk#0 used by the 4-channel FireFlys on the left side of the FPGA.
  --  -- This can be the output of either refclk synthesizer R0A or R0B. 
    p_lf_x4_r0_clk : in std_logic;
    n_lf_x4_r0_clk : in std_logic;

  ---- A copy of the RefClk#0 used by the 12-channel FireFlys on the right side of the FPGA.
  ---- This can be the output of either refclk synthesizer R0A or R0B. 
     p_rt_x12_r0_clk : in std_logic;
     n_rt_x12_r0_clk : in std_logic;

  ---- A copy of the RefClk#0 used by the 4-channel FireFlys on the right side of the FPGA.
  ---- This can be the output of either refclk synthesizer R0A or R0B. 
     p_rt_x4_r0_clk : in std_logic;
     n_rt_x4_r0_clk : in std_logic;

  --'input' "fpga_identity" to differentiate FPGA#1 from FPGA#2.
  -- The signal will be HI in FPGA#1 and LO in FPGA#2.
--   fpga_identity : in std_logic;
  
  -- 'output' "led": 3 bits to light a tri-color LED
  -- These use different pins on F1 vs. F2. The pins are unused on the "other" FPGA,
  -- so each color for both FPGAs can be driven at the same time
    led_f1_red : out std_logic;
    led_f1_green : out std_logic;
    led_f1_blue : out std_logic;
    --led_f2_red : out std_logic;
    --led_f2_green : out std_logic;
    --led_f2_blue : out std_logic;
    
  -- 'input' "mcu_to_f": 1 bit trom the MCU
  -- 'output' "f_to_mcu": 1 bit to the MCU
  -- There is no currently defined use for these.
     --mcu_to_f : in std_logic;
     --f_to_mcu : out std_logic;

  -- 'output' "c2c_ok": 1 bit to the MCU
  -- The FPGA should set this output HI when the chip-2-chip link is working.
     c2c_ok : out std_logic;

  -- If the Zynq on the SM is the TCDS endpoint, then both FPGAs only use port #0 for TCDS
  -- signals and the two FPGAs are programmed identically.
  --
  -- If FPGA#1 is the TCDS endpoint, then:
  --  1) TCDS signals from the ATCA backplane connect to port#0 on FPGA#1
  --  2) TCDS information is sent from FPGA#1 to FPGA#2 on port #3
  --  3) TCDS information is sent from FPGA#1 to the Zynq on the SM on port #2.
  --
  -- RefClk#0 for quad AB comes from REFCLK SYNTHESIZER R1A which can be driven by: 
  --  a) synth oscillator
  --  b) HQ_CLK from the SM
  --     b1) 320 MHz if FPGA#1 is the TCDS endpoint
  --     b2) 40 MHz if the SM is the TCDS endpoint
  --  c) Optional front panel connector for an external LVDS clock
  -- quad AB
    p_lf_r0_ab : in std_logic;
    n_lf_r0_ab : in std_logic;
  ----
  ---- RefClk#1 comes from REFCLK SYNTHESIZER R1B which can be driven by: 
  ----  a) synth oscillator
  ----  b) an output from EXTERNAL REFCLK SYNTH R1A
  ----  c) the 40 MHz TCDS RECOVERED CLOCK from FPGA #1 
  ---- RefClk#1 is only connected on FPGA#1, and is only used when FPGA#1 is the TCDS endpoint.
  ---- quad AB
     p_lf_r1_ab : in std_logic;
     n_lf_r1_ab : in std_logic;
  ---- quad L
     p_lf_r1_l : in std_logic;
     n_lf_r1_l : in std_logic; 

  --
  -- Port #0 is the main TCDS path. Both FPGAs use it when the Zynq on the SM is the
  -- TCDS endpoint. Only FPGA#1 uses it when FPGA#1 is the TCDS endpoint.
  -- Port #0 receive (schematic name is "con*_tcds_in")
  --   p_tcds_in : in std_logic;
  --   n_tcds_in : in std_logic;

  ---- Port #0 transmit (schematic name is "con*_tcds_out")
  --   p_tcds_out : out std_logic;
  --   n_tcds_out : out std_logic;
  ----
  ---- Port #2 is used to send TCDS signals between FPGA#1 and the Zynq when
  ---- FPGA#1 is the TCDS endpoint. Port #2 is not used when the Zynq on the SM is the
  ---- TCDS endpoint. Port #2 is not connected to anything on FPGA#2.
  ---- quad AB
  --   p_tcds_from_zynq_a : in std_logic;
  --   n_tcds_from_zynq_a : in std_logic;
  --   p_tcds_to_zynq_a   : out std_logic;
  --   n_tcds_to_zynq_a   : out std_logic;

  ---- quad L
  --   p_tcds_from_zynq_b : in std_logic;
  --   n_tcds_from_zynq_b : in std_logic;
  --   p_tcds_to_zynq_b   : out std_logic;
  --   n_tcds_to_zynq_b   : out std_logic;

  ----
  ---- Port #3 is cross-connected between the two FPGAs. It is only used when FPGA#1
  ---- is the TCDS endpoint.
  ---- quad AB
  --   p_tcds_cross_recv_a : in std_logic;
  --   n_tcds_cross_recv_a : in std_logic;
  --   p_tcds_cross_xmit_a   : out std_logic;
  --   n_tcds_cross_xmit_a   : out std_logic;

  ---- quad L
  --   p_tcds_cross_recv_b : in std_logic;
  --   n_tcds_cross_recv_b : in std_logic;
  --   p_tcds_cross_xmit_b   : out std_logic;
  --   n_tcds_cross_xmit_b   : out std_logic;

  ----
  ---- Recovered 40 MHz TCDS clock output to feed REFCLK SYNTHESIZER R1B.
  ---- This is only connected on FPGA#1, and is only used when FPGA#1 is the
  ---- TCDS endpoint. On FPGA#2, these signals are not connected, but are reserved.
  --   p_tcds_recov_clk   : out std_logic;
  --   n_tcds_recov_clk   : out std_logic;

  ----
  ---- 40 MHz TCDS clock connected to FPGA logic. This is used in the FPGA for two
  ---- purposes. The first is to generate high-speed processing clocks by multiplying
  ---- in an MMCM. The second is to synchronize processing to the 40 MHz LHC bunch crossing.
     p_tcds40_clk : in std_logic;
     n_tcds40_clk : in std_logic;

  
  ---- Spare input signals from the "other" FPGA.
  ---- These cross-connect to the spare output signals on the other FPGA
  ---- 'in_spare[2]' is connected to global glock-capable input pins
  --   p_in_spare : in std_logic_vector(2 downto 0);
  --   n_in_spare : in std_logic_vector(2 downto 0);
  ---- Spare output signals to the "other" FPGA.
  ---- These cross-connect to the spare input signals on the other FPGA
  --   p_out_spare : out std_logic_vector(2 downto 0);
  --   n_out_spare : out std_logic_vector(2 downto 0);
  
  ---- HDMI-style test connector on the front panel
  ---- 5 differential and 2 single-ended
  ---- 'test_conn_0' connects to global clock-capable input pins
  ---- THE DIRECTIONS ARE SET UP FOR TESTING. CHANGE THEM FOR REAL APPLICATIONS.
  --   p_test_conn_0 : in std_logic;
  --   n_test_conn_0 : in std_logic;
  --   p_test_conn_1 : in std_logic;
  --   n_test_conn_1 : in std_logic;
  --   p_test_conn_2 : in std_logic;
  --   n_test_conn_2 : in std_logic;
  --   p_test_conn_3 : in std_logic;
  --   n_test_conn_3 : in std_logic;
  --   p_test_conn_4 : in std_logic;
  --   n_test_conn_4 : in std_logic;
  --   test_conn_5   : out std_logic;
  --   test_conn_6   : out std_logic;
  
  -- Spare pins to 1mm x 1mm headers on the bottom of the board
  -- They could be used in an emergency as I/Os, or for debugging
  -- hdr[1] and hdr[2] are on global clock-capable pins
  --input hdr1, hdr2,
  --input hdr3, hdr4, hdr5, hdr6,
  --output reg hdr7, hdr8, hdr9, hdr10,
  
  -- C2C primary (#1) and secondary (#2) links to the Zynq on the SM
     p_rt_r0_l : in std_logic;
     n_rt_r0_l : in std_logic;
     p_mgt_sm_to_f : in std_logic_vector(2 downto 1);
     n_mgt_sm_to_f : in std_logic_vector(2 downto 1);
     p_mgt_f_to_sm : out std_logic_vector(2 downto 1);
     n_mgt_f_to_sm : out std_logic_vector(2 downto 1);

     --n_mgt_z2v        : in  std_logic_vector(1 downto 1);
     --p_mgt_z2v        : in  std_logic_vector(1 downto 1);
     --n_mgt_v2z        : out std_logic_vector(1 downto 1);
     --p_mgt_v2z        : out std_logic_vector(1 downto 1);
     
 -- Connect FF1, 12 lane, quad AC,AD,AE
     p_lf_r0_ad : in std_logic;
     n_lf_r0_ad : in std_logic;
     p_lf_r1_ad : in std_logic;
     n_lf_r1_ad : in std_logic;
 --    n_ff1_recv : in std_logic_vector(11 downto 0);
 --    p_ff1_recv : in std_logic_vector(11 downto 0);
 --    n_ff1_xmit : out std_logic_vector(11 downto 0);
 --    p_ff1_xmit : out std_logic_vector(11 downto 0);      

 ---- Connect FF4, 4 lane, quad AF
     p_lf_r0_af : in std_logic;
     n_lf_r0_af : in std_logic;
     p_lf_r1_af : in std_logic;
     n_lf_r1_af : in std_logic;
 --    n_ff4_recv : in std_logic_vector(3 downto 0);
 --    p_ff4_recv : in std_logic_vector(3 downto 0);
 --    n_ff4_xmit : out std_logic_vector(3 downto 0);
 --    p_ff4_xmit : out std_logic_vector(3 downto 0);  
   
 -- -- Connect FF4, 4 lane, quad U
     p_lf_r0_u : in std_logic;
     n_lf_r0_u : in std_logic;
     p_lf_r1_u : in std_logic;
     n_lf_r1_u : in std_logic;
 --    n_ff6_recv : in std_logic_vector(3 downto 0);
 --    p_ff6_recv : in std_logic_vector(3 downto 0);
 --    n_ff6_xmit : out std_logic_vector(3 downto 0);
 --    p_ff6_xmit : out std_logic_vector(3 downto 0);
 
     p_lf_r0_r : in std_logic;
     n_lf_r0_r : in std_logic;
     p_lf_r1_r : in std_logic;
     n_lf_r1_r : in std_logic;
     
     p_lf_r0_y : in std_logic;
     n_lf_r0_y : in std_logic;
     p_lf_r1_y : in std_logic;
     n_lf_r1_y : in std_logic;
     
     p_lf_r0_v : in std_logic;
     n_lf_r0_v : in std_logic;
     
     p_rt_r0_n : in std_logic;
     n_rt_r0_n : in std_logic;
     p_rt_r1_n : in std_logic;
     n_rt_r1_n : in std_logic;
     
     p_rt_r0_b : in std_logic;
     n_rt_r0_b : in std_logic;
     p_rt_r1_b : in std_logic;
     n_rt_r1_b : in std_logic;
     
     p_rt_r0_e : in std_logic;
     n_rt_r0_e : in std_logic;
     p_rt_r1_e : in std_logic;
     n_rt_r1_e : in std_logic;
     
     p_rt_r0_f : in std_logic;
     n_rt_r0_f : in std_logic;
     
     p_rt_r0_g : in std_logic;
     n_rt_r0_g : in std_logic;
     p_rt_r1_g : in std_logic;
     n_rt_r1_g : in std_logic;
     
     p_rt_r0_p : in std_logic;
     n_rt_r0_p : in std_logic;
     p_rt_r1_p : in std_logic;
     n_rt_r1_p : in std_logic;
     
     p_rt_r0_i : in std_logic;
     n_rt_r0_i : in std_logic;
     p_rt_r1_i : in std_logic;
     n_rt_r1_i : in std_logic;

  -- I2C pins
  -- The "sysmon" port can be accessed before the FPGA is configured.
  -- The "generic" port requires a configured FPGA with an I2C module. The information
  -- that can be accessed on the generic port is user-defined.
    --i2c_scl_f_generic   : inout std_logic;
    --i2c_sda_f_generic   : inout std_logic;
    i2c_scl_f_sysmon    : inout std_logic;
    i2c_sda_f_sysmon    : inout std_logic;
    SDA                : inout std_logic;
    SCL                : in    std_logic
    );
  end entity top;

  architecture structure of top is
      signal clk_200_raw     : std_logic;
      signal clk_200         : std_logic;
      signal clk_50          : std_logic;
      signal reset           : std_logic;
      signal locked_clk200   : std_logic;


      constant serdes_refclk_count        : integer := 28;
      type serdes_t is record
        p        : std_logic;
        n        : std_logic;
        refclk   : std_logic;
        refclk_2 : std_logic;
        clk      : std_logic;
        freq     : std_logic_vector(31 downto 0);
      end record serdes_t;
      type serdes_array_t is array (integer range <>) of serdes_t;
      signal serdes_refclk : serdes_array_t(0 to SERDES_REFCLK_COUNT-1);

      constant fabric_refclk_count        : integer := 5;
      type fabric_t is record
        p     : std_logic;
        n     : std_logic;
        clk   : std_logic;
        freq  : std_logic_vector(31 downto 0);
      end record fabric_t;
      type fabric_array_t is array (integer range <>) of fabric_t;
      signal fabric_refclk : fabric_array_t(0 to FABRIC_REFCLK_COUNT-1);
      
      signal count_lf_x12_r0_clk : std_logic_vector(31 downto 0);
      signal count_lf_x4_r0_clk  : std_logic_vector(31 downto 0);
      signal count_rt_x12_r0_clk : std_logic_vector(31 downto 0);
      signal count_rt_x4_r0_clk  : std_logic_vector(31 downto 0);
      signal count_lf_r0_ab      : std_logic_vector(31 downto 0);
      signal count_lf_r1_ab      : std_logic_vector(31 downto 0);
      signal count_lf_r1_l       : std_logic_vector(31 downto 0);
      signal count_tcds40_clk    : std_logic_vector(31 downto 0);      
      signal count_rt_r0_l       : std_logic_vector(31 downto 0);
      signal count_lf_r0_ad      : std_logic_vector(31 downto 0);
      signal count_lf_r1_ad      : std_logic_vector(31 downto 0);
      signal count_lf_r0_af      : std_logic_vector(31 downto 0);
      signal count_lf_r1_af      : std_logic_vector(31 downto 0);
      signal count_lf_r0_u       : std_logic_vector(31 downto 0);
      signal count_lf_r1_u       : std_logic_vector(31 downto 0);
      signal count_lf_r0_r       : std_logic_vector(31 downto 0);
      signal count_lf_r1_r       : std_logic_vector(31 downto 0);
      signal count_lf_r0_y       : std_logic_vector(31 downto 0);
      signal count_lf_r1_y       : std_logic_vector(31 downto 0);
      signal count_lf_r0_v       : std_logic_vector(31 downto 0);
      signal count_rt_r0_n       : std_logic_vector(31 downto 0);
      signal count_rt_r1_n       : std_logic_vector(31 downto 0);
      signal count_rt_r0_b       : std_logic_vector(31 downto 0);
      signal count_rt_r1_b       : std_logic_vector(31 downto 0);
      signal count_rt_r0_e       : std_logic_vector(31 downto 0);
      signal count_rt_r1_e       : std_logic_vector(31 downto 0);
      signal count_rt_r0_f       : std_logic_vector(31 downto 0);
      signal count_rt_r0_g       : std_logic_vector(31 downto 0);
      signal count_rt_r1_g       : std_logic_vector(31 downto 0);
      signal count_rt_r0_p       : std_logic_vector(31 downto 0);
      signal count_rt_r1_p       : std_logic_vector(31 downto 0);
      signal count_rt_r0_i       : std_logic_vector(31 downto 0);
      signal count_rt_r1_i       : std_logic_vector(31 downto 0);

      signal led_blue_local  : slv_8_t;
      signal led_red_local   : slv_8_t;
      signal led_green_local : slv_8_t;

      constant localAXISlaves    : integer := 4;
      signal local_AXI_ReadMOSI  :  AXIReadMOSI_array_t(0 to localAXISlaves-1) := (others => DefaultAXIReadMOSI);
      signal local_AXI_ReadMISO  :  AXIReadMISO_array_t(0 to localAXISlaves-1) := (others => DefaultAXIReadMISO);
      signal local_AXI_WriteMOSI : AXIWriteMOSI_array_t(0 to localAXISlaves-1) := (others => DefaultAXIWriteMOSI);
      signal local_AXI_WriteMISO : AXIWriteMISO_array_t(0 to localAXISlaves-1) := (others => DefaultAXIWriteMISO);

      signal AXI_CLK             : std_logic;
      signal AXI_RST_N           : std_logic;
      signal AXI_RESET           : std_logic;

      signal ext_AXI_ReadMOSI  :  AXIReadMOSI_d64 := DefaultAXIReadMOSI_d64;
      signal ext_AXI_ReadMISO  :  AXIReadMISO_d64 := DefaultAXIReadMISO_d64;
      signal ext_AXI_WriteMOSI : AXIWriteMOSI_d64 := DefaultAXIWriteMOSI_d64;
      signal ext_AXI_WriteMISO : AXIWriteMISO_d64 := DefaultAXIWriteMISO_d64;

      signal i2c_AXI_MASTER_ReadMOSI  :  AXIReadMOSI := DefaultAXIReadMOSI;
      signal i2c_AXI_MASTER_ReadMISO  :  AXIReadMISO := DefaultAXIReadMISO;
      signal i2c_AXI_MASTER_WriteMOSI : AXIWriteMOSI := DefaultAXIWriteMOSI;
      signal i2c_AXI_MASTER_WriteMISO : AXIWriteMISO := DefaultAXIWriteMISO;
      signal i2c_AXI_MASTER_rst_n : std_logic;
      

      
      signal C2C_Mon  : C2C_INTF_MON_t;
      signal C2C_Ctrl : C2C_INTF_Ctrl_t;

      signal clk_F1_C2C_PHY_user                  : STD_logic_vector(1 downto 1);
      signal BRAM_write : std_logic;
      signal BRAM_addr  : std_logic_vector(10 downto 0);
      signal BRAM_WR_data : std_logic_vector(31 downto 0);
      signal BRAM_RD_data : std_logic_vector(31 downto 0);

      signal bram_rst_a    : std_logic;
      signal bram_clk_a    : std_logic;
      signal bram_en_a     : std_logic;
      signal bram_we_a     : std_logic_vector(7 downto 0);
      signal bram_addr_a   : std_logic_vector(8 downto 0);
      signal bram_wrdata_a : std_logic_vector(63 downto 0);
      signal bram_rddata_a : std_logic_vector(63 downto 0);


      signal AXI_BRAM_EN : std_logic;
      signal AXI_BRAM_we : std_logic_vector(7 downto 0);
      signal AXI_BRAM_addr :std_logic_vector(12 downto 0);
      signal AXI_BRAM_DATA_IN : std_logic_vector(63 downto 0);
      signal AXI_BRAM_DATA_OUT : std_logic_vector(63 downto 0);

      signal pB_UART_tx : std_logic;
      signal pB_UART_rx : std_logic;

      signal C2C_REFCLK_FREQ : slv_32_t;
      signal c2c_refclk : std_logic;
      signal c2c_refclk_odiv2     : std_logic;
      signal buf_c2c_refclk_odiv2 : std_logic;
      
      signal sda_in  : std_logic;
      signal sda_out : std_logic;
      signal sda_en  : std_logic;


      
begin        
    -- connect 200 MHz to a clock wizard that outputs 200 MHz, 100 MHz, and 50 MHz
    Local_Clocking_1: entity work.onboardclk
        port map (
            clk_200Mhz => clk_200,
            clk_50Mhz  => clk_50,
            reset      => '0',
            locked     => locked_clk200,
            clk_in1_p  => p_clk_200,
            clk_in1_n  => n_clk_200);
    AXI_CLK <= clk_50;

    fabric_refclk(0).p <= p_lf_x12_r0_clk;
    fabric_refclk(0).n <= n_lf_x12_r0_clk;
    count_lf_x12_r0_clk <= fabric_refclk(0).freq;
    fabric_refclk(1).p <= p_lf_x4_r0_clk;
    fabric_refclk(1).n <= n_lf_x4_r0_clk;
    count_lf_x4_r0_clk <= fabric_refclk(1).freq;
    fabric_refclk(2).p <= p_rt_x12_r0_clk;
    fabric_refclk(2).n <= n_rt_x12_r0_clk;
    count_rt_x12_r0_clk <= fabric_refclk(2).freq;
    fabric_refclk(3).p <= p_rt_x4_r0_clk;
    fabric_refclk(3).n <= n_rt_x4_r0_clk;
    count_rt_x4_r0_clk <= fabric_refclk(3).freq;
    fabric_refclk(4).p <= p_tcds40_clk;
    fabric_refclk(4).n <= n_tcds40_clk;
    count_tcds40_clk <= fabric_refclk(4).freq;


    serdes_refclk(0).p <= p_lf_r0_ab;
    serdes_refclk(0).n <= n_lf_r0_ab;
    count_lf_r0_ab <= serdes_refclk(0).freq;
    serdes_refclk(1).p <= p_lf_r1_ab;
    serdes_refclk(1).n <= n_lf_r1_ab;
    count_lf_r1_ab <= serdes_refclk(1).freq;
    serdes_refclk(2).p <= p_lf_r1_l;
    serdes_refclk(2).n <= n_lf_r1_l;
    count_lf_r1_l  <= serdes_refclk(2).freq;
    serdes_refclk(3).p <= p_lf_r0_ad;
    serdes_refclk(3).n <= n_lf_r0_ad;
    count_lf_r0_ad <= serdes_refclk(3).freq;
    serdes_refclk(4).p <= p_lf_r1_ad;
    serdes_refclk(4).n <= n_lf_r1_ad;
    count_lf_r1_ad <= serdes_refclk(4).freq;
    serdes_refclk(5).p <= p_lf_r0_af;
    serdes_refclk(5).n <= n_lf_r0_af;
    count_lf_r0_af <= serdes_refclk(5).freq;
    serdes_refclk(6).p <= p_lf_r1_af;
    serdes_refclk(6).n <= n_lf_r1_af;
    count_lf_r1_af <= serdes_refclk(6).freq;
    serdes_refclk(7).p <= p_lf_r0_u;
    serdes_refclk(7).n <= n_lf_r0_u;
    count_lf_r0_u  <= serdes_refclk(7).freq;
    serdes_refclk(8).p <= p_lf_r1_u;
    serdes_refclk(8).n <= n_lf_r1_u;
    count_lf_r1_u  <= serdes_refclk(8).freq;
    serdes_refclk(9).p <= p_lf_r0_r;
    serdes_refclk(9).n <= n_lf_r0_r;
    count_lf_r0_r  <= serdes_refclk(9).freq;
    serdes_refclk(10).p <= p_lf_r1_r;
    serdes_refclk(10).n <= n_lf_r1_r;
    count_lf_r1_r  <= serdes_refclk(10).freq;
    serdes_refclk(11).p <= p_lf_r0_y;
    serdes_refclk(11).n <= n_lf_r0_y;
    count_lf_r0_y  <= serdes_refclk(11).freq;
    serdes_refclk(12).p <= p_lf_r1_y;
    serdes_refclk(12).n <= n_lf_r1_y;
    count_lf_r1_y  <= serdes_refclk(12).freq;
    serdes_refclk(13).p <= p_lf_r0_v;
    serdes_refclk(13).n <= n_lf_r0_v;
    count_lf_r0_v  <= serdes_refclk(13).freq;
    serdes_refclk(14).p <= p_rt_r0_n;
    serdes_refclk(14).n <= n_rt_r0_n;
    count_rt_r0_n  <= serdes_refclk(14).freq;
    serdes_refclk(15).p <= p_rt_r1_n;
    serdes_refclk(15).n <= n_rt_r1_n;
    count_rt_r1_n  <= serdes_refclk(15).freq;
    serdes_refclk(16).p <= p_rt_r0_b;
    serdes_refclk(16).n <= n_rt_r0_b;
    count_rt_r0_b  <= serdes_refclk(16).freq;
    serdes_refclk(17).p <= p_rt_r1_b;
    serdes_refclk(17).n <= n_rt_r1_b;
    count_rt_r1_b  <= serdes_refclk(17).freq;
    serdes_refclk(18).p <= p_rt_r0_e;
    serdes_refclk(18).n <= n_rt_r0_e;
    count_rt_r0_e  <= serdes_refclk(18).freq;
    serdes_refclk(19).p <= p_rt_r1_e;
    serdes_refclk(19).n <= n_rt_r1_e;
    count_rt_r1_e  <= serdes_refclk(19).freq;
    serdes_refclk(20).p <= p_rt_r0_f;
    serdes_refclk(20).n <= n_rt_r0_f;
    count_rt_r0_f  <= serdes_refclk(20).freq;    
    serdes_refclk(21).p <= p_rt_r0_g;
    serdes_refclk(21).n <= n_rt_r0_g;
    count_rt_r0_g  <= serdes_refclk(21).freq;
    serdes_refclk(22).p <= p_rt_r1_g;
    serdes_refclk(22).n <= n_rt_r1_g;
    count_rt_r1_g  <= serdes_refclk(22).freq;
    serdes_refclk(23).p <= p_rt_r0_p;
    serdes_refclk(23).n <= n_rt_r0_p;
    count_rt_r0_p  <= serdes_refclk(23).freq;
    serdes_refclk(24).p <= p_rt_r1_p;
    serdes_refclk(24).n <= n_rt_r1_p;
    count_rt_r1_p  <= serdes_refclk(24).freq;
    serdes_refclk(25).p <= p_rt_r0_i;
    serdes_refclk(25).n <= n_rt_r0_i;
    count_rt_r0_i  <= serdes_refclk(25).freq;
    serdes_refclk(26).p <= p_rt_r1_i;
    serdes_refclk(26).n <= n_rt_r1_i;
    count_rt_r1_i  <= serdes_refclk(26).freq;
    serdes_refclk(27).p <= p_rt_r0_l;
    serdes_refclk(27).n <= n_rt_r0_l;
    count_rt_r0_l  <= serdes_refclk(27).freq;


    
    monitor_serdes_refclks: for iCLK in 0 to SERDES_REFCLK_COUNT-1 generate
      --Capture the refclk and generate copies for MGTS and for the fabric clocking
      IBUFDS_GTE4_INST : IBUFDS_GTE4
        generic map (
          REFCLK_EN_TX_PATH => '0',
          REFCLK_HROW_CK_SEL => "00",
          REFCLK_ICNTL_RX => "00")
        port map (
          O     => serdes_refclk(iClk).refclk,
          ODIV2 => serdes_refclk(iClk).refclk_2,
          CEB   => '0',
          I     => serdes_refclk(iClk).p,
          IB    => serdes_refclk(iClk).n);
      --place the second clock from the GTE4 onto the clock routing network
      BUFG_GT_INST : BUFG_GT
        port map (
          O       => serdes_refclk(iClk).clk,
          CE      => '1',
          CEMASK  => '1',
          CLR     => '0',
          CLRMASK => '1',
          DIV     => "000",
          I       => serdes_refclk(iClk).refclk_2
        );
      -- monitor the fabric clock with the axi clock to get its freq
      rate_counter_inst: entity work.rate_counter
        generic map (
          CLK_A_1_SECOND => AXI_MASTER_CLK_FREQ)
        port map (
          clk_A         => AXI_CLK,
          clk_B         => serdes_refclk(iClk).clk,
          reset_A_async => AXI_RESET,
          event_b       => '1',
          rate          => serdes_refclk(iClk).freq);
      
    end generate monitor_serdes_refclks;

    monitor_fabric_refclks: for iCLK in 0 to FABRIC_REFCLK_COUNT-1 generate
      --cacpture the clock and put it on the clocking network
      IBUFDS_inst_1 : IBUFDS
        generic map (
          DIFF_TERM => FALSE,
          IBUF_LOW_PWR => TRUE,
          IOSTANDARD => "DEFAULT")
        port map (
          O  => fabric_refclk(iCLK).clk,
          I  => fabric_refclk(iCLK).p,
          IB => fabric_refclk(iCLK).n);
      -- monitor the clk with the AXI clk
      rate_counter_inst: entity work.rate_counter
        generic map (
          CLK_A_1_SECOND => AXI_MASTER_CLK_FREQ)
        port map (
          clk_A         => AXI_CLK,
          clk_B         => fabric_refclk(iClk).clk,
          reset_A_async => AXI_RESET,
          event_b       => '1',
          rate          => fabric_refclk(iClk).freq);
      
    end generate monitor_fabric_refclks;


  c2c_refclk <= serdes_refclk(27).refclk;

    
 c2csslave_wrapper_1: entity work.c2cslave_wrapper
   port map (
      EXT_CLK                             => clk_50,
      --EXT_RSTN                            => locked_clk200,
      AXI_MASTER_CLK                             => AXI_CLK,      
      --AXI_MASTER_RSTN                        => --AXI_RST_N,
      AXI_MASTER_RSTN                        => locked_clk200,
      sys_reset_rst_n(0)                     => AXI_RST_N,
      CM1_PB_UART_rxd                     => pB_UART_tx,
      CM1_PB_UART_txd                     => pB_UART_rx,
      F1_C2C_phy_Rx_rxn                  => n_mgt_sm_to_f(1 downto 1),
      F1_C2C_phy_Rx_rxp                  => p_mgt_sm_to_f(1 downto 1),
      F1_C2C_phy_Tx_txn                  => n_mgt_f_to_sm(1 downto 1),
      F1_C2C_phy_Tx_txp                  => p_mgt_f_to_sm(1 downto 1),
      F1_C2CB_phy_Rx_rxn                  => n_mgt_sm_to_f(2 downto 2),
      F1_C2CB_phy_Rx_rxp                  => p_mgt_sm_to_f(2 downto 2),
      F1_C2CB_phy_Tx_txn                  => n_mgt_f_to_sm(2 downto 2),
      F1_C2CB_phy_Tx_txp                  => p_mgt_f_to_sm(2 downto 2),
      F1_C2C_phy_refclk                   => c2c_refclk,
      F1_C2CB_phy_refclk                   => c2c_refclk,


      F1_IO_araddr                           => local_AXI_ReadMOSI(0).address,              
      F1_IO_arprot                           => local_AXI_ReadMOSI(0).protection_type,      
      F1_IO_arready                          => local_AXI_ReadMISO(0).ready_for_address,    
      F1_IO_arvalid                          => local_AXI_ReadMOSI(0).address_valid,        
      F1_IO_awaddr                           => local_AXI_WriteMOSI(0).address,             
      F1_IO_awprot                           => local_AXI_WriteMOSI(0).protection_type,     
      F1_IO_awready                          => local_AXI_WriteMISO(0).ready_for_address,   
      F1_IO_awvalid                          => local_AXI_WriteMOSI(0).address_valid,       
      F1_IO_bready                           => local_AXI_WriteMOSI(0).ready_for_response,  
      F1_IO_bresp                            => local_AXI_WriteMISO(0).response,            
      F1_IO_bvalid                           => local_AXI_WriteMISO(0).response_valid,      
      F1_IO_rdata                            => local_AXI_ReadMISO(0).data,                 
      F1_IO_rready                           => local_AXI_ReadMOSI(0).ready_for_data,       
      F1_IO_rresp                            => local_AXI_ReadMISO(0).response,             
      F1_IO_rvalid                           => local_AXI_ReadMISO(0).data_valid,           
      F1_IO_wdata                            => local_AXI_WriteMOSI(0).data,                
      F1_IO_wready                           => local_AXI_WriteMISO(0).ready_for_data,       
      F1_IO_wstrb                            => local_AXI_WriteMOSI(0).data_write_strobe,   
      F1_IO_wvalid                           => local_AXI_WriteMOSI(0).data_valid,



      
      F1_CM_FW_INFO_araddr                      => local_AXI_ReadMOSI(1).address,              
      F1_CM_FW_INFO_arprot                      => local_AXI_ReadMOSI(1).protection_type,      
      F1_CM_FW_INFO_arready                     => local_AXI_ReadMISO(1).ready_for_address,    
      F1_CM_FW_INFO_arvalid                     => local_AXI_ReadMOSI(1).address_valid,        
      F1_CM_FW_INFO_awaddr                      => local_AXI_WriteMOSI(1).address,             
      F1_CM_FW_INFO_awprot                      => local_AXI_WriteMOSI(1).protection_type,     
      F1_CM_FW_INFO_awready                     => local_AXI_WriteMISO(1).ready_for_address,   
      F1_CM_FW_INFO_awvalid                     => local_AXI_WriteMOSI(1).address_valid,       
      F1_CM_FW_INFO_bready                      => local_AXI_WriteMOSI(1).ready_for_response,  
      F1_CM_FW_INFO_bresp                       => local_AXI_WriteMISO(1).response,            
      F1_CM_FW_INFO_bvalid                      => local_AXI_WriteMISO(1).response_valid,      
      F1_CM_FW_INFO_rdata                       => local_AXI_ReadMISO(1).data,                 
      F1_CM_FW_INFO_rready                      => local_AXI_ReadMOSI(1).ready_for_data,       
      F1_CM_FW_INFO_rresp                       => local_AXI_ReadMISO(1).response,             
      F1_CM_FW_INFO_rvalid                      => local_AXI_ReadMISO(1).data_valid,           
      F1_CM_FW_INFO_wdata                       => local_AXI_WriteMOSI(1).data,                
      F1_CM_FW_INFO_wready                      => local_AXI_WriteMISO(1).ready_for_data,       
      F1_CM_FW_INFO_wstrb                       => local_AXI_WriteMOSI(1).data_write_strobe,   
      F1_CM_FW_INFO_wvalid                      => local_AXI_WriteMOSI(1).data_valid,

      F1_C2C_INTF_araddr                   => local_AXI_ReadMOSI(2).address,              
      F1_C2C_INTF_arprot                   => local_AXI_ReadMOSI(2).protection_type,      
      F1_C2C_INTF_arready                  => local_AXI_ReadMISO(2).ready_for_address,    
      F1_C2C_INTF_arvalid                  => local_AXI_ReadMOSI(2).address_valid,        
      F1_C2C_INTF_awaddr                   => local_AXI_WriteMOSI(2).address,             
      F1_C2C_INTF_awprot                   => local_AXI_WriteMOSI(2).protection_type,     
      F1_C2C_INTF_awready                  => local_AXI_WriteMISO(2).ready_for_address,   
      F1_C2C_INTF_awvalid                  => local_AXI_WriteMOSI(2).address_valid,       
      F1_C2C_INTF_bready                   => local_AXI_WriteMOSI(2).ready_for_response,  
      F1_C2C_INTF_bresp                    => local_AXI_WriteMISO(2).response,            
      F1_C2C_INTF_bvalid                   => local_AXI_WriteMISO(2).response_valid,      
      F1_C2C_INTF_rdata                    => local_AXI_ReadMISO(2).data,                 
      F1_C2C_INTF_rready                   => local_AXI_ReadMOSI(2).ready_for_data,       
      F1_C2C_INTF_rresp                    => local_AXI_ReadMISO(2).response,             
      F1_C2C_INTF_rvalid                   => local_AXI_ReadMISO(2).data_valid,           
      F1_C2C_INTF_wdata                    => local_AXI_WriteMOSI(2).data,                
      F1_C2C_INTF_wready                   => local_AXI_WriteMISO(2).ready_for_data,       
      F1_C2C_INTF_wstrb                    => local_AXI_WriteMOSI(2).data_write_strobe,   
      F1_C2C_INTF_wvalid                   => local_AXI_WriteMOSI(2).data_valid,          

            F1_IPBUS_araddr                   => ext_AXI_ReadMOSI.address,              
      F1_IPBUS_arburst                  => ext_AXI_ReadMOSI.burst_type,
      F1_IPBUS_arcache                  => ext_AXI_ReadMOSI.cache_type,
      F1_IPBUS_arlen                    => ext_AXI_ReadMOSI.burst_length,
      F1_IPBUS_arlock(0)                => ext_AXI_ReadMOSI.lock_type,
      F1_IPBUS_arprot                   => ext_AXI_ReadMOSI.protection_type,      
      F1_IPBUS_arqos                    => ext_AXI_ReadMOSI.qos,
      F1_IPBUS_arready(0)               => ext_AXI_ReadMISO.ready_for_address,
      F1_IPBUS_arregion                 => ext_AXI_ReadMOSI.region,
      F1_IPBUS_arsize                   => ext_AXI_ReadMOSI.burst_size,
      F1_IPBUS_arvalid(0)               => ext_AXI_ReadMOSI.address_valid,        
      F1_IPBUS_awaddr                   => ext_AXI_WriteMOSI.address,             
      F1_IPBUS_awburst                  => ext_AXI_WriteMOSI.burst_type,
      F1_IPBUS_awcache                  => ext_AXI_WriteMOSI.cache_type,
      F1_IPBUS_awlen                    => ext_AXI_WriteMOSI.burst_length,
      F1_IPBUS_awlock(0)                => ext_AXI_WriteMOSI.lock_type,
      F1_IPBUS_awprot                   => ext_AXI_WriteMOSI.protection_type,
      F1_IPBUS_awqos                    => ext_AXI_WriteMOSI.qos,
      F1_IPBUS_awready(0)               => ext_AXI_WriteMISO.ready_for_address,   
      F1_IPBUS_awregion                 => ext_AXI_WriteMOSI.region,
      F1_IPBUS_awsize                   => ext_AXI_WriteMOSI.burst_size,
      F1_IPBUS_awvalid(0)               => ext_AXI_WriteMOSI.address_valid,       
      F1_IPBUS_bready(0)                => ext_AXI_WriteMOSI.ready_for_response, 
      F1_IPBUS_bresp                    => ext_AXI_WriteMISO.response,            
      F1_IPBUS_bvalid(0)                => ext_AXI_WriteMISO.response_valid,      
      F1_IPBUS_rdata                    => ext_AXI_ReadMISO.data,
      F1_IPBUS_rlast(0)                 => ext_AXI_ReadMISO.last,
      F1_IPBUS_rready(0)                => ext_AXI_ReadMOSI.ready_for_data,       
      F1_IPBUS_rresp                    => ext_AXI_ReadMISO.response,             
      F1_IPBUS_rvalid(0)                => ext_AXI_ReadMISO.data_valid,           
      F1_IPBUS_wdata                    => ext_AXI_WriteMOSI.data,
      F1_IPBUS_wlast(0)                 => ext_AXI_WriteMOSI.last,
      F1_IPBUS_wready(0)                => ext_AXI_WriteMISO.ready_for_data,       
      F1_IPBUS_wstrb                    => ext_AXI_WriteMOSI.data_write_strobe,   
      F1_IPBUS_wvalid(0)                => ext_AXI_WriteMOSI.data_valid,          
--      reset_n                               => locked_clk200,--reset,

      F1_C2C_PHY_DEBUG_cplllock(0)         => C2C_Mon.C2C(1).DEBUG.CPLL_LOCK,
      F1_C2C_PHY_DEBUG_dmonitorout         => C2C_Mon.C2C(1).DEBUG.DMONITOR,
      F1_C2C_PHY_DEBUG_eyescandataerror(0) => C2C_Mon.C2C(1).DEBUG.EYESCAN_DATA_ERROR,
      
      F1_C2C_PHY_DEBUG_eyescanreset(0)     => C2C_Ctrl.C2C(1).DEBUG.EYESCAN_RESET,
      F1_C2C_PHY_DEBUG_eyescantrigger(0)   => C2C_Ctrl.C2C(1).DEBUG.EYESCAN_TRIGGER,
      F1_C2C_PHY_DEBUG_pcsrsvdin           => C2C_Ctrl.C2C(1).DEBUG.PCS_RSV_DIN,
      F1_C2C_PHY_DEBUG_qplllock(0)         =>  C2C_Mon.C2C(1).DEBUG.QPLL_LOCK,
      F1_C2C_PHY_DEBUG_rxbufreset(0)       => C2C_Ctrl.C2C(1).DEBUG.RX.BUF_RESET,
      F1_C2C_PHY_DEBUG_rxbufstatus         =>  C2C_Mon.C2C(1).DEBUG.RX.BUF_STATUS,
      F1_C2C_PHY_DEBUG_rxcdrhold(0)        => C2C_Ctrl.C2C(1).DEBUG.RX.CDR_HOLD,
      F1_C2C_PHY_DEBUG_rxdfelpmreset(0)    => C2C_Ctrl.C2C(1).DEBUG.RX.DFE_LPM_RESET,
      F1_C2C_PHY_DEBUG_rxlpmen(0)          => C2C_Ctrl.C2C(1).DEBUG.RX.LPM_EN,
      F1_C2C_PHY_DEBUG_rxpcsreset(0)       => C2C_Ctrl.C2C(1).DEBUG.RX.PCS_RESET,
      F1_C2C_PHY_DEBUG_rxpmareset(0)       => C2C_Ctrl.C2C(1).DEBUG.RX.PMA_RESET,
      F1_C2C_PHY_DEBUG_rxpmaresetdone(0)   =>  C2C_Mon.C2C(1).DEBUG.RX.PMA_RESET_DONE,
      F1_C2C_PHY_DEBUG_rxprbscntreset(0)   => C2C_Ctrl.C2C(1).DEBUG.RX.PRBS_CNT_RST,
      F1_C2C_PHY_DEBUG_rxprbserr(0)        =>  C2C_Mon.C2C(1).DEBUG.RX.PRBS_ERR,
      F1_C2C_PHY_DEBUG_rxprbssel           => C2C_Ctrl.C2C(1).DEBUG.RX.PRBS_SEL,
      F1_C2C_PHY_DEBUG_rxrate              => C2C_Ctrl.C2C(1).DEBUG.RX.RATE,
      F1_C2C_PHY_DEBUG_rxresetdone(0)      =>  C2C_Mon.C2C(1).DEBUG.RX.RESET_DONE,
      F1_C2C_PHY_DEBUG_txbufstatus         =>  C2C_Mon.C2C(1).DEBUG.TX.BUF_STATUS,
      F1_C2C_PHY_DEBUG_txdiffctrl          => C2C_Ctrl.C2C(1).DEBUG.TX.DIFF_CTRL,
      F1_C2C_PHY_DEBUG_txinhibit(0)        => C2C_Ctrl.C2C(1).DEBUG.TX.INHIBIT,
      F1_C2C_PHY_DEBUG_txpcsreset(0)       => C2C_Ctrl.C2C(1).DEBUG.TX.PCS_RESET,
      F1_C2C_PHY_DEBUG_txpmareset(0)       => C2C_Ctrl.C2C(1).DEBUG.TX.PMA_RESET,
      F1_C2C_PHY_DEBUG_txpolarity(0)       => C2C_Ctrl.C2C(1).DEBUG.TX.POLARITY,
      F1_C2C_PHY_DEBUG_txpostcursor        => C2C_Ctrl.C2C(1).DEBUG.TX.POST_CURSOR,
      F1_C2C_PHY_DEBUG_txprbsforceerr(0)   => C2C_Ctrl.C2C(1).DEBUG.TX.PRBS_FORCE_ERR,
      F1_C2C_PHY_DEBUG_txprbssel           => C2C_Ctrl.C2C(1).DEBUG.TX.PRBS_SEL,
      F1_C2C_PHY_DEBUG_txprecursor         => C2C_Ctrl.C2C(1).DEBUG.TX.PRE_CURSOR,
      F1_C2C_PHY_DEBUG_txresetdone(0)      =>  C2C_MON.C2C(1).DEBUG.TX.RESET_DONE,

      F1_C2C_PHY_channel_up         => C2C_Mon.C2C(1).STATUS.CHANNEL_UP,      
      F1_C2C_PHY_gt_pll_lock        => C2C_MON.C2C(1).STATUS.PHY_GT_PLL_LOCK,
      F1_C2C_PHY_hard_err           => C2C_Mon.C2C(1).STATUS.PHY_HARD_ERR,
      F1_C2C_PHY_lane_up            => C2C_Mon.C2C(1).STATUS.PHY_LANE_UP(0 downto 0),
      F1_C2C_PHY_mmcm_not_locked_out    => C2C_Mon.C2C(1).STATUS.PHY_MMCM_LOL,
      F1_C2C_PHY_soft_err           => C2C_Mon.C2C(1).STATUS.PHY_SOFT_ERR,

      F1_C2C_aurora_do_cc                =>  C2C_Mon.C2C(1).STATUS.DO_CC,
      F1_C2C_aurora_pma_init_in          => C2C_Ctrl.C2C(1).STATUS.INITIALIZE,
      F1_C2C_axi_c2c_config_error_out    =>  C2C_Mon.C2C(1).STATUS.CONFIG_ERROR,
      F1_C2C_axi_c2c_link_status_out     =>  C2C_MON.C2C(1).STATUS.LINK_GOOD,
      F1_C2C_axi_c2c_multi_bit_error_out =>  C2C_MON.C2C(1).STATUS.MB_ERROR,
      F1_C2C_phy_power_down              => '0',
      F1_C2C_PHY_clk                     => clk_F1_C2C_PHY_user(1),
      F1_C2C_PHY_DRP_daddr               => C2C_Ctrl.C2C(1).DRP.address,
      F1_C2C_PHY_DRP_den                 => C2C_Ctrl.C2C(1).DRP.enable,
      F1_C2C_PHY_DRP_di                  => C2C_Ctrl.C2C(1).DRP.wr_data,
      F1_C2C_PHY_DRP_do                  => C2C_MON.C2C(1).DRP.rd_data,
      F1_C2C_PHY_DRP_drdy                => C2C_MON.C2C(1).DRP.rd_data_valid,
      F1_C2C_PHY_DRP_dwe                 => C2C_Ctrl.C2C(1).DRP.wr_enable,

      F1_C2CB_PHY_DEBUG_cplllock(0)         => C2C_Mon.C2C(2).DEBUG.CPLL_LOCK,
      F1_C2CB_PHY_DEBUG_dmonitorout         => C2C_Mon.C2C(2).DEBUG.DMONITOR,
      F1_C2CB_PHY_DEBUG_eyescandataerror(0) => C2C_Mon.C2C(2).DEBUG.EYESCAN_DATA_ERROR,
      
      F1_C2CB_PHY_DEBUG_eyescanreset(0)     => C2C_Ctrl.C2C(2).DEBUG.EYESCAN_RESET,
      F1_C2CB_PHY_DEBUG_eyescantrigger(0)   => C2C_Ctrl.C2C(2).DEBUG.EYESCAN_TRIGGER,
      F1_C2CB_PHY_DEBUG_pcsrsvdin           => C2C_Ctrl.C2C(2).DEBUG.PCS_RSV_DIN,
      F1_C2CB_PHY_DEBUG_qplllock(0)         =>  C2C_Mon.C2C(2).DEBUG.QPLL_LOCK,
      F1_C2CB_PHY_DEBUG_rxbufreset(0)       => C2C_Ctrl.C2C(2).DEBUG.RX.BUF_RESET,
      F1_C2CB_PHY_DEBUG_rxbufstatus         =>  C2C_Mon.C2C(2).DEBUG.RX.BUF_STATUS,
      F1_C2CB_PHY_DEBUG_rxcdrhold(0)        => C2C_Ctrl.C2C(2).DEBUG.RX.CDR_HOLD,
      F1_C2CB_PHY_DEBUG_rxdfelpmreset(0)    => C2C_Ctrl.C2C(2).DEBUG.RX.DFE_LPM_RESET,
      F1_C2CB_PHY_DEBUG_rxlpmen(0)          => C2C_Ctrl.C2C(2).DEBUG.RX.LPM_EN,
      F1_C2CB_PHY_DEBUG_rxpcsreset(0)       => C2C_Ctrl.C2C(2).DEBUG.RX.PCS_RESET,
      F1_C2CB_PHY_DEBUG_rxpmareset(0)       => C2C_Ctrl.C2C(2).DEBUG.RX.PMA_RESET,
      F1_C2CB_PHY_DEBUG_rxpmaresetdone(0)   =>  C2C_Mon.C2C(2).DEBUG.RX.PMA_RESET_DONE,
      F1_C2CB_PHY_DEBUG_rxprbscntreset(0)   => C2C_Ctrl.C2C(2).DEBUG.RX.PRBS_CNT_RST,
      F1_C2CB_PHY_DEBUG_rxprbserr(0)        =>  C2C_Mon.C2C(2).DEBUG.RX.PRBS_ERR,
      F1_C2CB_PHY_DEBUG_rxprbssel           => C2C_Ctrl.C2C(2).DEBUG.RX.PRBS_SEL,
      F1_C2CB_PHY_DEBUG_rxrate              => C2C_Ctrl.C2C(2).DEBUG.RX.RATE,
      F1_C2CB_PHY_DEBUG_rxresetdone(0)      =>  C2C_Mon.C2C(2).DEBUG.RX.RESET_DONE,
      F1_C2CB_PHY_DEBUG_txbufstatus         =>  C2C_Mon.C2C(2).DEBUG.TX.BUF_STATUS,
      F1_C2CB_PHY_DEBUG_txdiffctrl          => C2C_Ctrl.C2C(2).DEBUG.TX.DIFF_CTRL,
      F1_C2CB_PHY_DEBUG_txinhibit(0)        => C2C_Ctrl.C2C(2).DEBUG.TX.INHIBIT,
      F1_C2CB_PHY_DEBUG_txpcsreset(0)       => C2C_Ctrl.C2C(2).DEBUG.TX.PCS_RESET,
      F1_C2CB_PHY_DEBUG_txpmareset(0)       => C2C_Ctrl.C2C(2).DEBUG.TX.PMA_RESET,
      F1_C2CB_PHY_DEBUG_txpolarity(0)       => C2C_Ctrl.C2C(2).DEBUG.TX.POLARITY,
      F1_C2CB_PHY_DEBUG_txpostcursor        => C2C_Ctrl.C2C(2).DEBUG.TX.POST_CURSOR,
      F1_C2CB_PHY_DEBUG_txprbsforceerr(0)   => C2C_Ctrl.C2C(2).DEBUG.TX.PRBS_FORCE_ERR,
      F1_C2CB_PHY_DEBUG_txprbssel           => C2C_Ctrl.C2C(2).DEBUG.TX.PRBS_SEL,
      F1_C2CB_PHY_DEBUG_txprecursor         => C2C_Ctrl.C2C(2).DEBUG.TX.PRE_CURSOR,
      F1_C2CB_PHY_DEBUG_txresetdone(0)      =>  C2C_MON.C2C(2).DEBUG.TX.RESET_DONE,

      F1_C2CB_PHY_channel_up         => C2C_Mon.C2C(2).STATUS.CHANNEL_UP,      
      F1_C2CB_PHY_gt_pll_lock        => C2C_MON.C2C(2).STATUS.PHY_GT_PLL_LOCK,
      F1_C2CB_PHY_hard_err           => C2C_Mon.C2C(2).STATUS.PHY_HARD_ERR,
      F1_C2CB_PHY_lane_up            => C2C_Mon.C2C(2).STATUS.PHY_LANE_UP(0 downto 0),
--      F1_C2CB_PHY_mmcm_not_locked    => C2C_Mon.C2C(2).STATUS.PHY_MMCM_LOL,
      F1_C2CB_PHY_soft_err           => C2C_Mon.C2C(2).STATUS.PHY_SOFT_ERR,

      F1_C2CB_aurora_do_cc                =>  C2C_Mon.C2C(2).STATUS.DO_CC,
      F1_C2CB_aurora_pma_init_in          => C2C_Ctrl.C2C(2).STATUS.INITIALIZE,
      F1_C2CB_axi_c2c_config_error_out    =>  C2C_Mon.C2C(2).STATUS.CONFIG_ERROR,
      F1_C2CB_axi_c2c_link_status_out     =>  C2C_MON.C2C(2).STATUS.LINK_GOOD,
      F1_C2CB_axi_c2c_multi_bit_error_out =>  C2C_MON.C2C(2).STATUS.MB_ERROR,
      F1_C2CB_phy_power_down              => '0',
--      F1_C2CB_PHY_user_clk_out            => clk_F1_C2CB_PHY_user,
      F1_C2CB_PHY_DRP_daddr               => C2C_Ctrl.C2C(2).DRP.address,
      F1_C2CB_PHY_DRP_den                 => C2C_Ctrl.C2C(2).DRP.enable,
      F1_C2CB_PHY_DRP_di                  => C2C_Ctrl.C2C(2).DRP.wr_data,
      F1_C2CB_PHY_DRP_do                  => C2C_MON.C2C(2).DRP.rd_data,
      F1_C2CB_PHY_DRP_drdy                => C2C_MON.C2C(2).DRP.rd_data_valid,
      F1_C2CB_PHY_DRP_dwe                 => C2C_Ctrl.C2C(2).DRP.wr_enable,

      SYS_RESET_bus_rst_n(0)             => i2c_AXI_MASTER_rst_n,
      I2C_MASTER_araddr                  => i2c_AXI_MASTER_readMOSI.address,
      I2C_MASTER_arprot                  => i2c_AXI_MASTER_readMOSI.protection_type,
      I2C_MASTER_arready                 => i2c_AXI_MASTER_readMISO.ready_for_address,
      I2C_MASTER_arvalid                 => i2c_AXI_MASTER_readMOSI.address_valid,
      I2C_MASTER_awaddr                  => i2c_AXI_MASTER_writeMOSI.address,
      I2C_MASTER_awprot                  => i2c_AXI_MASTER_writeMOSI.protection_type,
      I2C_MASTER_awready                 => i2c_AXI_MASTER_writeMISO.ready_for_address,
      I2C_MASTER_awvalid                 => i2c_AXI_MASTER_writeMOSI.address_valid,
      I2C_MASTER_bready                  => i2c_AXI_MASTER_writeMOSI.ready_for_response,
      I2C_MASTER_bresp                   => i2c_AXI_MASTER_writeMISO.response,
      I2C_MASTER_bvalid                  => i2c_AXI_MASTER_writeMISO.response_valid,
      I2C_MASTER_rdata                   => i2c_AXI_MASTER_readMISO.data,
      I2C_MASTER_rready                  => i2c_AXI_MASTER_readMOSI.ready_for_data,
      I2C_MASTER_rresp                   => i2c_AXI_MASTER_readMISO.response,
      I2C_MASTER_rvalid                  => i2c_AXI_MASTER_readMISO.data_valid,
      I2C_MASTER_wdata                   => i2c_AXI_MASTER_writeMOSI.data,
      I2C_MASTER_wready                  => i2c_AXI_MASTER_writeMISO.ready_for_data,
      I2C_MASTER_wstrb                   => i2c_AXI_MASTER_writeMOSI.data_write_strobe,
      I2C_MASTER_wvalid                  => i2c_AXI_MASTER_writeMOSI.data_valid,

      
      F1_SYS_MGMT_sda                   =>i2c_sda_f_sysmon,
      F1_SYS_MGMT_scl                   =>i2c_scl_f_sysmon




);
  c2c_ok <= C2C_Mon.C2C(1).STATUS.LINK_GOOD and
            C2C_Mon.C2C(1).STATUS.PHY_LANE_UP(0) and
            C2C_Mon.C2C(2).STATUS.LINK_GOOD and
            C2C_Mon.C2C(2).STATUS.PHY_LANE_UP(0);

  i2cAXIMaster_1: entity work.i2cAXIMaster
    generic map (
      I2C_ADDRESS => "0100000"
      )
    port map (
      clk_axi         => AXI_CLK,
      reset_axi_n     => i2c_AXI_MASTER_rst_n,
      readMOSI        => i2c_AXI_MASTER_readMOSI,
      readMISO        => i2c_AXI_MASTER_readMISO,
      writeMOSI       => i2c_AXI_MASTER_writeMOSI,
      writeMISO       => i2c_AXI_MASTER_writeMISO,
      SCL             => SCL,
      SDA_in          => SDA_in,
      SDA_out         => SDA_out,
      SDA_en          => SDA_en);
  sda_iobuf : iobuf
    port map (
      IO => SDA,
      O => SDA_in,
      I => SDA_out,
      T => not SDA_en);

  

  RGB_pwm_1: entity work.RGB_pwm
    generic map (
      CLKFREQ => 200000000,
      RGBFREQ => 1000)
    port map (
      clk        => clk_200,
      redcount   => led_red_local,
      greencount => led_green_local,
      bluecount  => led_blue_local,
      LEDred     => led_f1_red,
      LEDgreen   => led_f1_green,
      LEDblue    => led_f1_blue);

  rate_counter_1: entity work.rate_counter
    generic map (
      CLK_A_1_SECOND => 200000000)
    port map (
      clk_A         => clk_200,
      clk_B         => clk_F1_C2C_PHY_user(1),
      reset_A_async => AXI_RESET,
      event_b       => '1',
      rate          => C2C_Mon.C2C(1).USER_FREQ);
  C2C_Mon.C2C(2).USER_FREQ <= C2C_Mon.C2C(1).USER_FREQ;

  F1_IO_interface_1: entity work.IO_map
    generic map(
      ALLOCATED_MEMORY_RANGE => to_integer(AXI_RANGE_F1_IO)
      )
    port map (
      clk_axi         => AXI_CLK,
      reset_axi_n     => AXI_RST_N,
      slave_readMOSI  => local_AXI_readMOSI(0),
      slave_readMISO  => local_AXI_readMISO(0),
      slave_writeMOSI => local_AXI_writeMOSI(0),
      slave_writeMISO => local_AXI_writeMISO(0),
      Mon.CLK_200_LOCKED      => locked_clk200,
      Mon.TEST_CONST          => X"BEEFBEEF",
      Mon.CLOCKS.LF_X12_R0_CLK       => count_lf_x12_r0_clk,
      Mon.CLOCKS.LF_X4_R0_CLK        => count_lf_x4_r0_clk,
      Mon.CLOCKS.RT_X12_R0_CLK       => count_rt_x12_r0_clk,
      Mon.CLOCKS.RT_X4_R0_CLK        => count_rt_x4_r0_clk,
      Mon.CLOCKS.LF_R0_AB            => count_lf_r0_ab,
      Mon.CLOCKS.LF_R1_AB            => count_lf_r1_ab,
      Mon.CLOCKS.LF_R1_L             => count_lf_r1_l,
      Mon.CLOCKS.TCDS40_CLK          => count_tcds40_clk,
      Mon.CLOCKS.RT_R0_L             => count_rt_r0_l,
      Mon.CLOCKS.LF_R0_AD            => count_lf_r0_ad,
      Mon.CLOCKS.LF_R1_AD            => count_lf_r1_ad,
      Mon.CLOCKS.LF_R0_AF            => count_lf_r0_af,
      Mon.CLOCKS.LF_R1_AF            => count_lf_r0_af,
      Mon.CLOCKS.LF_R0_U             => count_lf_r0_u,
      Mon.CLOCKS.LF_R1_U             => count_lf_r1_u,
      Mon.CLOCKS.LF_R0_R             => count_lf_r0_r,
      Mon.CLOCKS.LF_R1_R             => count_lf_r1_r,
      Mon.CLOCKS.LF_R0_Y             => count_lf_r0_y,
      Mon.CLOCKS.LF_R1_Y             => count_lf_r1_y,
      Mon.CLOCKS.LF_R0_V             => count_lf_r0_v,
      Mon.CLOCKS.RT_R0_N             => count_rt_r0_n,
      Mon.CLOCKS.RT_R1_N             => count_rt_r1_n,
      Mon.CLOCKS.RT_R0_B             => count_rt_r0_b,
      Mon.CLOCKS.RT_R1_B             => count_rt_r1_b,
      Mon.CLOCKS.RT_R0_E             => count_rt_r0_e,
      Mon.CLOCKS.RT_R1_E             => count_rt_r1_e,
      Mon.CLOCKS.RT_R0_F             => count_rt_r0_f,
      Mon.CLOCKS.RT_R0_G             => count_rt_r0_g,
      Mon.CLOCKS.RT_R1_G             => count_rt_r1_g,
      Mon.CLOCKS.RT_R0_P             => count_rt_r0_p,
      Mon.CLOCKS.RT_R1_P             => count_rt_r1_p,
      Mon.CLOCKS.RT_R0_I             => count_rt_r0_i,
      Mon.CLOCKS.RT_R1_I             => count_rt_r1_i,
      Mon.BRAM.RD_DATA        => BRAM_RD_DATA,
      Ctrl.RGB.R              => led_red_local,
      Ctrl.RGB.G              => led_green_local,
      Ctrl.RGB.B              => led_blue_local,
      Ctrl.BRAM.WRITE         => BRAM_WRITE,
      Ctrl.BRAM.ADDR(10 downto 0) => BRAM_ADDR,
      Ctrl.BRAM.ADDR(14 downto 11) => open,
      Ctrl.BRAM.WR_DATA       => BRAM_WR_DATA
      );

  CM_F1_info_1: entity work.CM_FW_info
    generic map (
      ALLOCATED_MEMORY_RANGE => to_integer(AXI_RANGE_F1_CM_FW_INFO)
      )
    port map (
      clk_axi     => AXI_CLK,
      reset_axi_n => AXI_RST_N,
      readMOSI    => local_AXI_ReadMOSI(1),
      readMISO    => local_AXI_ReadMISO(1),
      writeMOSI   => local_AXI_WriteMOSI(1),
      writeMISO   => local_AXI_WriteMISO(1));

  C2C_INTF_1: entity work.C2C_INTF
    generic map (
      ERROR_WAIT_TIME => 90000000,
      ALLOCATED_MEMORY_RANGE => to_integer(AXI_RANGE_F1_C2C_INTF)
      )
    port map (
      clk_axi          => AXI_CLK,
      reset_axi_n      => AXI_RST_N,
      readMOSI         => local_AXI_readMOSI(2),
      readMISO         => local_AXI_readMISO(2),
      writeMOSI        => local_AXI_writeMOSI(2),
      writeMISO        => local_AXI_writeMISO(2),
      clk_C2C(1)       => clk_F1_C2C_PHY_user(1),
      clk_C2C(2)       => clk_F1_C2C_PHY_user(1),
      UART_Rx          => pb_UART_Rx,
      UART_Tx          => pb_UART_Tx,
      Mon              => C2C_Mon,
      Ctrl             => C2C_Ctrl);


  AXI_RESET <= not AXI_RST_N;

  AXI_BRAM_1: entity work.AXI_BRAM
    port map (
      s_axi_aclk    => AXI_CLK,
      s_axi_aresetn => AXI_RST_N,
      s_axi_araddr                 => ext_AXI_ReadMOSI.address(12 downto 0),              
      s_axi_arburst                => ext_AXI_ReadMOSI.burst_type,
      s_axi_arcache                => ext_AXI_ReadMOSI.cache_type,
      s_axi_arlen                  => ext_AXI_ReadMOSI.burst_length,
      s_axi_arlock                 => ext_AXI_ReadMOSI.lock_type,
      s_axi_arprot                 => ext_AXI_ReadMOSI.protection_type,      
--      s_axi_arqos                  => ext_AXI_ReadMOSI.qos,
      s_axi_arready             => ext_AXI_ReadMISO.ready_for_address,
--      s_axi_arregion               => ext_AXI_ReadMOSI.region,
      s_axi_arsize                 => ext_AXI_ReadMOSI.burst_size,
      s_axi_arvalid             => ext_AXI_ReadMOSI.address_valid,        
      s_axi_awaddr                 => ext_AXI_WriteMOSI.address(12 downto 0),             
      s_axi_awburst                => ext_AXI_WriteMOSI.burst_type,
      s_axi_awcache                => ext_AXI_WriteMOSI.cache_type,
      s_axi_awlen                  => ext_AXI_WriteMOSI.burst_length,
      s_axi_awlock              => ext_AXI_WriteMOSI.lock_type,
      s_axi_awprot                 => ext_AXI_WriteMOSI.protection_type,
--      s_axi_awqos                  => ext_AXI_WriteMOSI.qos,
      s_axi_awready             => ext_AXI_WriteMISO.ready_for_address,   
--      s_axi_awregion               => ext_AXI_WriteMOSI.region,
      s_axi_awsize                 => ext_AXI_WriteMOSI.burst_size,
      s_axi_awvalid             => ext_AXI_WriteMOSI.address_valid,       
      s_axi_bready              => ext_AXI_WriteMOSI.ready_for_response,  
      s_axi_bresp                  => ext_AXI_WriteMISO.response,            
      s_axi_bvalid              => ext_AXI_WriteMISO.response_valid,      
      s_axi_rdata                  => ext_AXI_ReadMISO.data,
      s_axi_rlast               => ext_AXI_ReadMISO.last,
      s_axi_rready              => ext_AXI_ReadMOSI.ready_for_data,       
      s_axi_rresp                  => ext_AXI_ReadMISO.response,             
      s_axi_rvalid              => ext_AXI_ReadMISO.data_valid,           
      s_axi_wdata                  => ext_AXI_WriteMOSI.data,
      s_axi_wlast               => ext_AXI_WriteMOSI.last,
      s_axi_wready              => ext_AXI_WriteMISO.ready_for_data,       
      s_axi_wstrb                  => ext_AXI_WriteMOSI.data_write_strobe,   
      s_axi_wvalid              => ext_AXI_WriteMOSI.data_valid,          
      bram_rst_a                   => open,
      bram_clk_a                   => AXI_CLK,
      bram_en_a                    => AXI_BRAM_en,
      bram_we_a                    => AXI_BRAM_we,
      bram_addr_a                  => AXI_BRAM_addr,
      bram_wrdata_a                => AXI_BRAM_DATA_IN,
      bram_rddata_a                => AXI_BRAM_DATA_OUT);

  DP_BRAM_1: entity work.DP_BRAM
    port map (
      clka  => AXI_CLK,
      ena   => AXI_BRAM_EN,
      wea   => AXI_BRAM_we,
      addra => AXI_BRAM_addr(11 downto 2),
      dina  => AXI_BRAM_DATA_IN,
      douta => AXI_BRAM_DATA_OUT,
      clkb  => AXI_CLK,
      enb   => '1',
      web   => (others => BRAM_WRITE),
      addrb => BRAM_ADDR,
      dinb  => BRAM_WR_DATA,
      doutb => BRAM_RD_DATA);

  C2C_Mon.C2C_REFCLK_FREQ <=  count_rt_r0_l;


end architecture structure;

