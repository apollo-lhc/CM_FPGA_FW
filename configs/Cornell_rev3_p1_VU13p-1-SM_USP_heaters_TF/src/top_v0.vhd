library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.axiRegPkg.all;
use work.axiRegPkg_d64.all;
use work.types.all;
use work.V_IO_Ctrl.all;


Library UNISIM;
use UNISIM.vcomponents.all;

entity top is
  port (
    -- clocks
    p_clk_200 : in  std_logic;
    n_clk_200 : in  std_logic;                -- 200 MHz system clock

    -- A copy of the RefClk#0 used by the 12-channel FireFlys on the left side of the FPGA.
    --This can be the output of either refclk synthesizer R0A or R0B. 
  --  p_lf_x12_r0_clk : in std_logic;
  --  n_lf_x12_r0_clk : in std_logic;
    
  --  -- A copy of the RefClk#0 used by the 4-channel FireFlys on the left side of the FPGA.
  --  -- This can be the output of either refclk synthesizer R0A or R0B. 
  --  p_lf_x4_r0_clk : in std_logic;
  --  n_lf_x4_r0_clk : in std_logic;

  ---- A copy of the RefClk#0 used by the 12-channel FireFlys on the right side of the FPGA.
  ---- This can be the output of either refclk synthesizer R0A or R0B. 
  --   p_rt_x12_r0_clk : in std_logic;
  --   n_rt_x12_r0_clk : in std_logic;

  ---- A copy of the RefClk#0 used by the 4-channel FireFlys on the right side of the FPGA.
  ---- This can be the output of either refclk synthesizer R0A or R0B. 
  --   p_rt_x4_r0_clk : in std_logic;
  --   n_rt_x4_r0_clk : in std_logic;

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
  --  p_lf_r0_ab : in std_logic;
  --  n_lf_r0_ab : in std_logic;
  ----
  ---- RefClk#1 comes from REFCLK SYNTHESIZER R1B which can be driven by: 
  ----  a) synth oscillator
  ----  b) an output from EXTERNAL REFCLK SYNTH R1A
  ----  c) the 40 MHz TCDS RECOVERED CLOCK from FPGA #1 
  ---- RefClk#1 is only connected on FPGA#1, and is only used when FPGA#1 is the TCDS endpoint.
  ---- quad AB
  --   p_lf_r1_ab : in std_logic;
  --   n_lf_r1_ab : in std_logic;
  ---- quad L
  --   p_lf_r1_l : in std_logic;
  --   n_lf_r1_l : in std_logic;   

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
  --   p_tcds40_clk : in std_logic;
  --   n_tcds40_clk : in std_logic;

  
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
     p_mgt_sm_to_f_1 : in std_logic_vector(1 downto 1);
     n_mgt_sm_to_f_1 : in std_logic_vector(1 downto 1);
     p_mgt_f_to_sm_1 : out std_logic_vector(1 downto 1);
     n_mgt_f_to_sm_1 : out std_logic_vector(1 downto 1);
     --p_mgt_sm_to_f_2 : in std_logic;
     --n_mgt_sm_to_f_2 : in std_logic;
     --p_mgt_f_to_sm_2 : out std_logic;
     --n_mgt_f_to_sm_2 : out std_logic;

     --n_mgt_z2v        : in  std_logic_vector(1 downto 1);
     --p_mgt_z2v        : in  std_logic_vector(1 downto 1);
     --n_mgt_v2z        : out std_logic_vector(1 downto 1);
     --p_mgt_v2z        : out std_logic_vector(1 downto 1);
     
 -- Connect FF1, 12 lane, quad AC,AD,AE
 --    p_lt_r0_ad : in std_logic;
 --    n_lt_r0_ad : in std_logic;
 --    n_ff1_recv : in std_logic_vector(11 downto 0);
 --    p_ff1_recv : in std_logic_vector(11 downto 0);
 --    n_ff1_xmit : out std_logic_vector(11 downto 0);
 --    p_ff1_xmit : out std_logic_vector(11 downto 0);      

 -- Connect FF4, 4 lane, quad AF
     p_lf_r0_af : in std_logic;
     n_lf_r0_af : in std_logic;
     n_ff4_recv : in std_logic_vector(3 downto 0);
     p_ff4_recv : in std_logic_vector(3 downto 0);
     n_ff4_xmit : out std_logic_vector(3 downto 0);
     p_ff4_xmit : out std_logic_vector(3 downto 0);  

 -- Connect FF4, 4 lane, quad T
     n_ff5_recv : in std_logic_vector(3 downto 0);
     p_ff5_recv : in std_logic_vector(3 downto 0);
     n_ff5_xmit : out std_logic_vector(3 downto 0);
     p_ff5_xmit : out std_logic_vector(3 downto 0);
     
  -- Connect FF4, 4 lane, quad U
     p_lf_r0_u : in std_logic;
     n_lf_r0_u : in std_logic;
     n_ff6_recv : in std_logic_vector(3 downto 0);
     p_ff6_recv : in std_logic_vector(3 downto 0);
     n_ff6_xmit : out std_logic_vector(3 downto 0);
     p_ff6_xmit : out std_logic_vector(3 downto 0);

  -- Connect FF4, 4 lane, quad V
     p_lf_r0_v : in std_logic;
     n_lf_r0_v : in std_logic;
     n_ff7_recv : in std_logic_vector(3 downto 0);
     p_ff7_recv : in std_logic_vector(3 downto 0);
     n_ff7_xmit : out std_logic_vector(3 downto 0);
     p_ff7_xmit : out std_logic_vector(3 downto 0);
     
  -- I2C pins
  -- The "sysmon" port can be accessed before the FPGA is configured.
  -- The "generic" port requires a configured FPGA with an I2C module. The information
  -- that can be accessed on the generic port is user-defined.
    --i2c_scl_f_generic   : inout std_logic;
    --i2c_sda_f_generic   : inout std_logic;
    i2c_scl_f_sysmon    : inout std_logic;
    i2c_sda_f_sysmon    : inout std_logic
    );
  end entity top;

  architecture structure of top is
      signal clk_200_raw     : std_logic;
      signal clk_200         : std_logic;
      signal clk_50          : std_logic;
      signal reset           : std_logic;
      signal locked_clk200   : std_logic;

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

      signal C2C_Mon  : V_IO_C2C_MON_t;
      signal C2C_Ctrl : V_IO_C2C_Ctrl_t;

      signal clk_V_C2C_PHY_user                  : STD_logic;
      signal BRAM_write : std_logic;
      signal BRAM_addr  : std_logic_vector(9 downto 0);
      signal BRAM_WR_data : std_logic_vector(31 downto 0);
      signal BRAM_RD_data : std_logic_vector(31 downto 0);

      signal bram_rst_a    : std_logic;
      signal bram_clk_a    : std_logic;
      signal bram_en_a     : std_logic;
      signal bram_we_a     : std_logic_vector(7 downto 0);
      signal bram_addr_a   : std_logic_vector(8 downto 0);
      signal bram_wrdata_a : std_logic_vector(63 downto 0);
      signal bram_rddata_a : std_logic_vector(63 downto 0);
      
      signal myreg1_test_vector : std_logic_vector(31 downto 0);
      signal heater_output : slv32_array_t(31 downto 0);

      function and_reduce_array(a : slv32_array_t(15 downto 0)) return std_logic_vector is
        variable ret : std_logic_vector(31 downto 0) := (others => '0');
      begin
        for i in a'range loop
          ret := ret and a(i);
        end loop;
        
        return ret;
      end function and_reduce_array;

begin        
    -- connect 200 MHz to a clock wizard that outputs 200 MHz, 100 MHz, and 50 MHz
    Local_Clocking_1: entity work.Local_Clocking
        port map (
            clk_200   => clk_200,
            clk_50    => clk_50,
            clk_axi   => AXI_CLK,
            reset     => '0',
            locked    => locked_clk200,
            clk_in1_p => p_clk_200,
            clk_in1_n => n_clk_200);
            

-- add differential clock buffers to all the incoming clocks
--wire lf_x12_r0_clk;
--IBUFDS lf_x12_r0_clk_buf(.O(lf_x12_r0_clk), .I(p_lf_x12_r0_clk), .IB(n_lf_x12_r0_clk) );
--wire lf_x4_r0_clk;
--IBUFDS lf_x4_r0_clk_buf(.O(lf_x4_r0_clk), .I(p_lf_x4_r0_clk), .IB(n_lf_x4_r0_clk) );
--wire rt_x12_r0_clk;
--IBUFDS rt_x12_r0_clk_buf(.O(rt_x12_r0_clk), .I(p_rt_x12_r0_clk), .IB(n_rt_x12_r0_clk) );
--wire rt_x4_r0_clk;
--IBUFDS rt_x4_r0_clk_buf(.O(rt_x4_r0_clk), .I(p_rt_x4_r0_clk), .IB(n_rt_x4_r0_clk) );
--wire tcds40_clk;           -- 40 MHz LHC clock
--IBUFDS tcds40_clk_buf(.O(tcds40_clk), .I(p_tcds40_clk), .IB(n_tcds40_clk) );

-- add differential output buffer to TCDS recovered clock
--wire tcds_recov_clk;
--OBUFDS(.I(tcds_recov_clk), .O(p_tcds_recov_clk), .OB(n_tcds_recov_clk)); 
---- dummy connection to tcds_recov_clk
--assign tcds_recov_clk = tcds40_clk;

-- add a free running counter to divide the clock
--reg [27:0] divider;
--always @(posedge clk_200) begin
--  divider[27:0] <= divider[27:0] + 1;
--end

--assign led_f1_red = divider[27];
--assign led_f1_green = divider[26];
--assign led_f1_blue = divider[25];
--assign led_f2_red = divider[27];
--assign led_f2_green = divider[26];
--assign led_f2_blue = divider[25];

---- create 3 differential buffers for spare inputs 
--genvar chan;
--wire [2:0] in_spare;
--generate
--  for (chan=0; chan < 3; chan=chan+1)
--    begin: gen_in_spare_buf
--      IBUFDS in_spare_buf(.O(in_spare[chan]), .I(p_in_spare[chan]), .IB(n_in_spare[chan]) );
--  end
--endgenerate

---- create 3 differential buffers for spare outputs 
--reg [2:0] out_spare;
--generate
--  for (chan=0; chan < 3; chan=chan+1)
--    begin: gen_out_spare_buf
--      OBUFDS out_spare_buf(.I(out_spare[chan]), .O(p_out_spare[chan]), .OB(n_out_spare[chan]) );
--  end
--endgenerate

-- loop the spare in to the spare out
--always @(posedge clk_200) begin
--  out_spare[2:0] <= in_spare[2:0];
--end

---- create differential buffers to loop the test_conn signals
--wire test_conn_clk;
--IBUFDS test_conn_clk_buf(.O(test_conn_clk), .I(p_test_conn_0), .IB(n_test_conn_0) );
--wire test_conn_3, test_conn_4;
--IBUFDS test_conn_4_buf(.O(test_conn_4), .I(p_test_conn_4), .IB(n_test_conn_4));
--IBUFDS test_conn_3_buf(.O(test_conn_3), .I(p_test_conn_3), .IB(n_test_conn_3));
--reg test_conn_out_2, test_conn_out_1;
--OBUFDS test_conn_out_2_buf(.I(test_conn_out_2), .O(p_test_conn_2), .OB(n_test_conn_2));
--OBUFDS test_conn_out_1_buf(.I(test_conn_out_1), .O(p_test_conn_1), .OB(n_test_conn_1));

---- loop test_conn 'in' to 'out' using 'clk'
--always @(posedge test_conn_clk) begin
--  test_conn_out_2 <= test_conn_4;
--  test_conn_out_1 <= test_conn_3;
--  test_conn_5 <= test_conn_6;
--end

---- create differential buffers to loop the 'hdr' signals
--wire hdr_clk;
--IBUFDS hdr_clk_buf(.O(hdr_clk), .I(hdr1), .IB(hdr2) );

---- loop hdr 'in' to 'out' using 'clk'
--always @(posedge hdr_clk) begin
--  hdr7 <= hdr3;
--  hdr8 <= hdr4;
--  hdr9 <= hdr5;
--  hdr10 <= hdr6;
--end

---- create tri-state buffers for generic I2C scl and sda
--wire i2c_scl_generic_out, i2c_scl_generic_tri, i2c_scl_generic_in;
--generic_scl: IOBUF 
--  port map (
--    clk_200   => clk_200,
--    I => i2c_scl_generic_out,
--    T => i2c_scl_generic_tri,
--    O => i2c_scl_generic_in,
--    IO => i2c_scl_f_generic
--    );                    
--wire i2c_sda_generic_out, i2c_sda_generic_tri, i2c_sda_generic_in; 
--IOBUF generic_sda(.I(i2c_sda_generic_out),.T(i2c_sda_generic_tri), .O(i2c_sda_generic_in), .IO(i2c_sda_f_generic));

--wire i2c_scl_sysmon_out, i2c_scl_sysmon_tri, i2c_scl_sysmon_in; 
--IOBUF sysmon_scl(.I(i2c_scl_sysmon_out),.T(i2c_scl_sysmon_tri), .O(i2c_scl_sysmon_in), .IO(i2c_scl_f_sysmon));
--wire i2c_sda_sysmon_out, i2c_sda_sysmon_tri, i2c_sda_sysmon_in; 
--IOBUF sysmon_sda(.I(i2c_sda_sysmon_out),.T(i2c_sda_sysmon_tri), .O(i2c_sda_sysmon_in), .IO(i2c_sda_f_sysmon));

---- create dummy logic to use remaining inputs and outputs 
--always @(posedge clk_200) begin
--  f_to_mcu <= mcu_to_f & fpga_identity;
--end

-- Connect the c2c block
--top_block_wrapper top_block_wrapper1 (
--   .c2c_refclk_n(n_rt_r0_l),
--   .c2c_refclk_p(p_rt_r0_l),
--   .c2c_rxn(n_mgt_sm_to_f_1),
--   .c2c_rxp(p_mgt_sm_to_f_1),
--   .c2c_txn(n_mgt_f_to_sm_1),
--   .c2c_txp(p_mgt_f_to_sm_1),
--   .c2c2_rxn(n_mgt_sm_to_f_2),
--   .c2c2_rxp(p_mgt_sm_to_f_2),
--   .c2c2_txn(n_mgt_f_to_sm_2),
--   .c2c2_txp(p_mgt_f_to_sm_2),
--   .clk_100(clk_100),
--   .c2c_ok(c2c_ok),
--   .scl_i(i2c_scl_generic_in),
--   .scl_o(i2c_scl_generic_out),
--   .scl_t(i2c_scl_generic_tri),
--   .sda_i(i2c_sda_generic_in),
--   .sda_o(i2c_sda_generic_out),
--   .sda_t(i2c_sda_generic_tri)
--);

-- add a ffx4 block to use 1 quad (quad AF = FF4)
--BD_FFx4 FFx4_AF (
--  .init_clk(clk_50),
--  .refclk_n(n_lf_r0_af),
--  .refclk_p(p_lf_r0_af),
--  .rx_n({n_ff4_recv[0],n_ff4_recv[1],n_ff4_recv[2],n_ff4_recv[3]}),
--  .rx_p({p_ff4_recv[0],p_ff4_recv[1],p_ff4_recv[2],p_ff4_recv[3]}),
--  .tx_n({n_ff4_xmit[0],n_ff4_xmit[1],n_ff4_xmit[2],n_ff4_xmit[3]}),
--  .tx_p({p_ff4_xmit[0],p_ff4_xmit[1],p_ff4_xmit[2],p_ff4_xmit[3]})
--);

---- add a ffx4 block to use 1 quad (quad U = FF6)
--FFx4_U FFx4_U (
--  .init_clk(clk_200),
--  .refclk_n(n_lf_r0_u),
--  .refclk_p(p_lf_r0_u),
--  .rx_n({n_ff6_recv[0],n_ff6_recv[1],n_ff6_recv[2],n_ff6_recv[3]}),
--  .rx_p({p_ff6_recv[0],p_ff6_recv[1],p_ff6_recv[2],p_ff6_recv[3]}),
--  .tx_n({n_ff6_xmit[0],n_ff6_xmit[1],n_ff6_xmit[2],n_ff6_xmit[3]}),
--  .tx_p({p_ff6_xmit[0],p_ff6_xmit[1],p_ff6_xmit[2],p_ff6_xmit[3]})
--);

-- add a ffx12 block to use 3 quads (quad AC,AD,AE = FF1)
--BD_FFx12 FFx12_AD (
--  .init_clk(clk_50),
--  .refclk_n(n_lf_r0_ad),
--  .refclk_p(p_lf_r0_ad),
--  .rx_n({n_ff1_recv[11],n_ff1_recv[10],n_ff1_recv[9],n_ff1_recv[8],n_ff1_recv[7],n_ff1_recv[6],n_ff1_recv[5],n_ff1_recv[4],n_ff1_recv[3],n_ff1_recv[2],n_ff1_recv[1],n_ff1_recv[0]}),
--  .rx_p({p_ff1_recv[11],p_ff1_recv[10],p_ff1_recv[9],p_ff1_recv[8],p_ff1_recv[7],p_ff1_recv[6],p_ff1_recv[5],p_ff1_recv[4],p_ff1_recv[3],p_ff1_recv[2],p_ff1_recv[1],p_ff1_recv[0]}),
--  .tx_n({n_ff1_xmit[11],n_ff1_xmit[10],n_ff1_xmit[9],n_ff1_xmit[8],n_ff1_xmit[7],n_ff1_xmit[6],n_ff1_xmit[5],n_ff1_xmit[4],n_ff1_xmit[3],n_ff1_xmit[2],n_ff1_xmit[1],n_ff1_xmit[0]}),
--  .tx_p({p_ff1_xmit[11],p_ff1_xmit[10],p_ff1_xmit[9],p_ff1_xmit[8],p_ff1_xmit[7],p_ff1_xmit[6],p_ff1_xmit[5],p_ff1_xmit[4],p_ff1_xmit[3],p_ff1_xmit[2],p_ff1_xmit[1],p_ff1_xmit[0]})
--);

 c2csslave_wrapper_1: entity work.c2cslave_wrapper
    port map (
      AXI_CLK                               => AXI_CLK,
      AXI_RST_N(0)                          => AXI_RST_N,
      V_C2C_phy_Rx_rxn                  => n_mgt_sm_to_f_1,
      V_C2C_phy_Rx_rxp                  => p_mgt_sm_to_f_1,
      V_C2C_phy_Tx_txn                  => n_mgt_f_to_sm_1,
      V_C2C_phy_Tx_txp                  => p_mgt_f_to_sm_1,
      V_C2C_phy_refclk_clk_n            => n_rt_r0_l,
      V_C2C_phy_refclk_clk_p            => p_rt_r0_l,
      clk50Mhz                              => clk_50,
      
      V_IO_araddr                           => local_AXI_ReadMOSI(0).address,              
      V_IO_arprot                           => local_AXI_ReadMOSI(0).protection_type,      
      V_IO_arready                          => local_AXI_ReadMISO(0).ready_for_address,    
      V_IO_arvalid                          => local_AXI_ReadMOSI(0).address_valid,        
      V_IO_awaddr                           => local_AXI_WriteMOSI(0).address,             
      V_IO_awprot                           => local_AXI_WriteMOSI(0).protection_type,     
      V_IO_awready                          => local_AXI_WriteMISO(0).ready_for_address,   
      V_IO_awvalid                          => local_AXI_WriteMOSI(0).address_valid,       
      V_IO_bready                           => local_AXI_WriteMOSI(0).ready_for_response,  
      V_IO_bresp                            => local_AXI_WriteMISO(0).response,            
      V_IO_bvalid                           => local_AXI_WriteMISO(0).response_valid,      
      V_IO_rdata                            => local_AXI_ReadMISO(0).data,                 
      V_IO_rready                           => local_AXI_ReadMOSI(0).ready_for_data,       
      V_IO_rresp                            => local_AXI_ReadMISO(0).response,             
      V_IO_rvalid                           => local_AXI_ReadMISO(0).data_valid,           
      V_IO_wdata                            => local_AXI_WriteMOSI(0).data,                
      V_IO_wready                           => local_AXI_WriteMISO(0).ready_for_data,       
      V_IO_wstrb                            => local_AXI_WriteMOSI(0).data_write_strobe,   
      V_IO_wvalid                           => local_AXI_WriteMOSI(0).data_valid,
                                            
      CM_V_INFO_araddr                      => local_AXI_ReadMOSI(1).address,              
      CM_V_INFO_arprot                      => local_AXI_ReadMOSI(1).protection_type,      
      CM_V_INFO_arready                     => local_AXI_ReadMISO(1).ready_for_address,    
      CM_V_INFO_arvalid                     => local_AXI_ReadMOSI(1).address_valid,        
      CM_V_INFO_awaddr                      => local_AXI_WriteMOSI(1).address,             
      CM_V_INFO_awprot                      => local_AXI_WriteMOSI(1).protection_type,     
      CM_V_INFO_awready                     => local_AXI_WriteMISO(1).ready_for_address,   
      CM_V_INFO_awvalid                     => local_AXI_WriteMOSI(1).address_valid,       
      CM_V_INFO_bready                      => local_AXI_WriteMOSI(1).ready_for_response,  
      CM_V_INFO_bresp                       => local_AXI_WriteMISO(1).response,            
      CM_V_INFO_bvalid                      => local_AXI_WriteMISO(1).response_valid,      
      CM_V_INFO_rdata                       => local_AXI_ReadMISO(1).data,                 
      CM_V_INFO_rready                      => local_AXI_ReadMOSI(1).ready_for_data,       
      CM_V_INFO_rresp                       => local_AXI_ReadMISO(1).response,             
      CM_V_INFO_rvalid                      => local_AXI_ReadMISO(1).data_valid,           
      CM_V_INFO_wdata                       => local_AXI_WriteMOSI(1).data,                
      CM_V_INFO_wready                      => local_AXI_WriteMISO(1).ready_for_data,       
      CM_V_INFO_wstrb                       => local_AXI_WriteMOSI(1).data_write_strobe,   
      CM_V_INFO_wvalid                      => local_AXI_WriteMOSI(1).data_valid,
      

      VIRTEX_IPBUS_araddr                   => ext_AXI_ReadMOSI.address,              
      VIRTEX_IPBUS_arburst                  => ext_AXI_ReadMOSI.burst_type,
      VIRTEX_IPBUS_arcache                  => ext_AXI_ReadMOSI.cache_type,
      VIRTEX_IPBUS_arlen                    => ext_AXI_ReadMOSI.burst_length,
      VIRTEX_IPBUS_arlock(0)                => ext_AXI_ReadMOSI.lock_type,
      VIRTEX_IPBUS_arprot                   => ext_AXI_ReadMOSI.protection_type,      
      VIRTEX_IPBUS_arqos                    => ext_AXI_ReadMOSI.qos,
      VIRTEX_IPBUS_arready(0)               => ext_AXI_ReadMISO.ready_for_address,
      VIRTEX_IPBUS_arregion                 => ext_AXI_ReadMOSI.region,
      VIRTEX_IPBUS_arsize                   => ext_AXI_ReadMOSI.burst_size,
      VIRTEX_IPBUS_arvalid(0)               => ext_AXI_ReadMOSI.address_valid,        
      VIRTEX_IPBUS_awaddr                   => ext_AXI_WriteMOSI.address,             
      VIRTEX_IPBUS_awburst                  => ext_AXI_WriteMOSI.burst_type,
      VIRTEX_IPBUS_awcache                  => ext_AXI_WriteMOSI.cache_type,
      VIRTEX_IPBUS_awlen                    => ext_AXI_WriteMOSI.burst_length,
      VIRTEX_IPBUS_awlock(0)                => ext_AXI_WriteMOSI.lock_type,
      VIRTEX_IPBUS_awprot                   => ext_AXI_WriteMOSI.protection_type,
      VIRTEX_IPBUS_awqos                    => ext_AXI_WriteMOSI.qos,
      VIRTEX_IPBUS_awready(0)               => ext_AXI_WriteMISO.ready_for_address,   
      VIRTEX_IPBUS_awregion                 => ext_AXI_WriteMOSI.region,
      VIRTEX_IPBUS_awsize                   => ext_AXI_WriteMOSI.burst_size,
      VIRTEX_IPBUS_awvalid(0)               => ext_AXI_WriteMOSI.address_valid,       
      VIRTEX_IPBUS_bready(0)                => ext_AXI_WriteMOSI.ready_for_response,  
      VIRTEX_IPBUS_bresp                    => ext_AXI_WriteMISO.response,            
      VIRTEX_IPBUS_bvalid(0)                => ext_AXI_WriteMISO.response_valid,      
      VIRTEX_IPBUS_rdata                    => ext_AXI_ReadMISO.data,
      VIRTEX_IPBUS_rlast(0)                 => ext_AXI_ReadMISO.last,
      VIRTEX_IPBUS_rready(0)                => ext_AXI_ReadMOSI.ready_for_data,       
      VIRTEX_IPBUS_rresp                    => ext_AXI_ReadMISO.response,             
      VIRTEX_IPBUS_rvalid(0)                => ext_AXI_ReadMISO.data_valid,           
      VIRTEX_IPBUS_wdata                    => ext_AXI_WriteMOSI.data,
      VIRTEX_IPBUS_wlast(0)                 => ext_AXI_WriteMOSI.last,
      VIRTEX_IPBUS_wready(0)                => ext_AXI_WriteMISO.ready_for_data,       
      VIRTEX_IPBUS_wstrb                    => ext_AXI_WriteMOSI.data_write_strobe,   
      VIRTEX_IPBUS_wvalid(0)                => ext_AXI_WriteMOSI.data_valid,          
      reset_n                               => locked_clk200,--reset,

      V_C2C_PHY_DEBUG_cplllock(0)         => C2C_Mon.DEBUG.CPLL_LOCK,
      V_C2C_PHY_DEBUG_dmonitorout         => C2C_Mon.DEBUG.DMONITOR,
      V_C2C_PHY_DEBUG_eyescandataerror(0) => C2C_Mon.DEBUG.EYESCAN_DATA_ERROR,
      
      V_C2C_PHY_DEBUG_eyescanreset(0)     => C2C_Ctrl.DEBUG.EYESCAN_RESET,
      V_C2C_PHY_DEBUG_eyescantrigger(0)   => C2C_Ctrl.DEBUG.EYESCAN_TRIGGER,
      V_C2C_PHY_DEBUG_pcsrsvdin           => C2C_Ctrl.DEBUG.PCS_RSV_DIN,
      V_C2C_PHY_DEBUG_qplllock(0)         => C2C_Mon.DEBUG.QPLL_LOCK,
      V_C2C_PHY_DEBUG_rxbufreset(0)       => C2C_Ctrl.DEBUG.RX.BUF_RESET,
      V_C2C_PHY_DEBUG_rxbufstatus         => C2C_Mon.DEBUG.RX.BUF_STATUS,
      V_C2C_PHY_DEBUG_rxcdrhold(0)        => C2C_Ctrl.DEBUG.RX.CDR_HOLD,
      V_C2C_PHY_DEBUG_rxdfelpmreset(0)    => C2C_Ctrl.DEBUG.RX.DFE_LPM_RESET,
      V_C2C_PHY_DEBUG_rxlpmen(0)          => C2C_Ctrl.DEBUG.RX.LPM_EN,
      V_C2C_PHY_DEBUG_rxpcsreset(0)       => C2C_Ctrl.DEBUG.RX.PCS_RESET,
      V_C2C_PHY_DEBUG_rxpmareset(0)       => C2C_Ctrl.DEBUG.RX.PMA_RESET,
      V_C2C_PHY_DEBUG_rxpmaresetdone      => open,--C2C_Mon.DEBUG.RX.RESET_DONE,
      V_C2C_PHY_DEBUG_rxprbscntreset(0)   => C2C_Ctrl.DEBUG.RX.PRBS_CNT_RST,
      V_C2C_PHY_DEBUG_rxprbserr(0)        => C2C_Mon.DEBUG.RX.PRBS_ERR,
      V_C2C_PHY_DEBUG_rxprbssel           => C2C_Ctrl.DEBUG.RX.PRBS_SEL,
      V_C2C_PHY_DEBUG_rxrate              => C2C_Ctrl.DEBUG.RX.RATE,
      V_C2C_PHY_DEBUG_rxresetdone(0)      => C2C_Mon.DEBUG.RX.RESET_DONE,
      V_C2C_PHY_DEBUG_txbufstatus         => C2C_Mon.DEBUG.TX.BUF_STATUS,
      V_C2C_PHY_DEBUG_txdiffctrl          => C2C_Ctrl.DEBUG.TX.DIFF_CTRL,
      V_C2C_PHY_DEBUG_txinhibit(0)        => C2C_Ctrl.DEBUG.TX.INHIBIT,
      V_C2C_PHY_DEBUG_txpcsreset(0)       => C2C_Ctrl.DEBUG.TX.PCS_RESET,
      V_C2C_PHY_DEBUG_txpmareset(0)       => C2C_Ctrl.DEBUG.TX.PMA_RESET,
      V_C2C_PHY_DEBUG_txpolarity(0)       => C2C_Ctrl.DEBUG.TX.POLARITY,
      V_C2C_PHY_DEBUG_txpostcursor        => C2C_Ctrl.DEBUG.TX.POST_CURSOR,
      V_C2C_PHY_DEBUG_txprbsforceerr(0)   => C2C_Ctrl.DEBUG.TX.PRBS_FORCE_ERR,
      V_C2C_PHY_DEBUG_txprbssel           => C2C_Ctrl.DEBUG.TX.PRBS_SEL,
      V_C2C_PHY_DEBUG_txprecursor         => C2C_Ctrl.DEBUG.TX.PRE_CURSOR,
      V_C2C_PHY_DEBUG_txresetdone(0)      => C2C_MON.DEBUG.TX.RESET_DONE,

      V_C2C_PHY_STATUS_channel_up         => C2C_Mon.STATUS.CHANNEL_UP,      
      V_C2C_PHY_STATUS_gt_pll_lock        => C2C_MON.STATUS.PHY_GT_PLL_LOCK,
      V_C2C_PHY_STATUS_hard_err           => C2C_Mon.STATUS.PHY_HARD_ERR,
      V_C2C_PHY_STATUS_lane_up            => C2C_Mon.STATUS.PHY_LANE_UP(0 downto 0),
      V_C2C_PHY_STATUS_mmcm_not_locked    => C2C_Mon.STATUS.PHY_MMCM_LOL,
      V_C2C_PHY_STATUS_soft_err           => C2C_Mon.STATUS.PHY_SOFT_ERR,

      V_C2C_aurora_do_cc                => C2C_Mon.STATUS.DO_CC,
      V_C2C_axi_c2c_config_error_out    => C2C_Mon.STATUS.CONFIG_ERROR,
      V_C2C_axi_c2c_link_status_out     => C2C_MON.STATUS.LINK_GOOD,
      V_C2C_axi_c2c_multi_bit_error_out => C2C_MON.STATUS.MB_ERROR,
      V_C2C_phy_power_down              => '0',
      V_C2C_PHY_user_clk_out            => clk_V_C2C_PHY_user,

      VIRTEX_SYS_MGMT_sda                   =>i2c_sda_f_sysmon,
      VIRTEX_SYS_MGMT_scl                   =>i2c_scl_f_sysmon
);

    c2c_ok <= C2C_MON.STATUS.LINK_GOOD;

  RGB_pwm_1: entity work.RGB_pwm
    generic map (
      CLKFREQ => 200000000,
      RGBFREQ => 1000)
    port map (
      clk        => clk_200,
      --redcount   => led_red_local,
      --greencount => led_green_local,
      --bluecount  => led_blue_local,
      redcount   => myreg1_test_vector( 7 downto  0),
      greencount => myreg1_test_vector(15 downto  8),
      bluecount  => myreg1_test_vector(23 downto 16),
      
      LEDred     => led_f1_red,
      LEDgreen   => led_f1_green,
      LEDblue    => led_f1_blue);

  myreg1_test_vector <= and_reduce_array(heater_output);
    
  rate_counter_1: entity work.rate_counter
    generic map (
      CLK_A_1_SECOND => 2000000)
    port map (
      clk_A         => clk_200,
      clk_B         => clk_V_C2C_PHY_user,
      reset_A_async => AXI_RESET,
      event_b       => '1',
      rate          => C2C_Mon.USER_FREQ);

--  V_IO_interface_1: entity work.V_IO_map
--    port map (
--      clk_axi         => AXI_CLK,
--      reset_axi_n     => AXI_RST_N,
--      slave_readMOSI  => local_AXI_readMOSI(0),
--      slave_readMISO  => local_AXI_readMISO(0),
--      slave_writeMOSI => local_AXI_writeMOSI(0),
--      slave_writeMISO => local_AXI_writeMISO(0),
--      Mon.C2C                 => C2C_Mon,
--      Mon.CLK_200_LOCKED      => locked_clk200,
--      Mon.BRAM.RD_DATA        => BRAM_RD_DATA,
--      Ctrl.C2C                => C2C_Ctrl,
--      Ctrl.RGB.R              => led_red_local,
--      Ctrl.RGB.G              => led_green_local,
--      Ctrl.RGB.B              => led_blue_local,
--      Ctrl.BRAM.WRITE         => BRAM_WRITE,
--      Ctrl.BRAM.ADDR(9 downto 0) => BRAM_ADDR,
--      Ctrl.BRAM.ADDR(14 downto 10) => open,
--      Ctrl.BRAM.WR_DATA       => BRAM_WR_DATA
--      );

  CM_V_info_1: entity work.CM_V_info
    port map (
      clk_axi     => AXI_CLK,
      reset_axi_n => AXI_RST_N,
      readMOSI    => local_AXI_ReadMOSI(1),
      readMISO    => local_AXI_ReadMISO(1),
      writeMOSI   => local_AXI_WriteMOSI(1),
      writeMISO   => local_AXI_WriteMISO(1));


  AXI_RESET <= not AXI_RST_N;



  axi_bram_controller_1: entity work.axi_bram_controller
    generic map (
      USE_D64_PKG                   => 1,
      C_ADR_WIDTH                   => 32,
      C_DATA_WIDTH                  => 64,
      C_FAMILY                      => "virtexuplus",
      C_MEMORY_DEPTH                => 4096,
      C_BRAM_ADDR_WIDTH             => 12,
      C_SINGLE_PORT_BRAM            => 1,
      C_S_AXI_ID_WIDTH              => 0,
      C_S_AXI_PROTOCOL              => "AXI4",
      C_S_AXI_DATA_WIDTH            => 64)
    port map (
      s_axi_aclk    => AXI_CLK,
      s_axi_aresetn => AXI_RST_N,
      r_mosi_d64        => ext_AXI_ReadMOSI,
      r_miso_d64        => ext_AXI_ReadMISO,
      w_mosi_d64        => ext_AXI_WriteMOSI,
      w_miso_d64        => ext_AXI_WriteMISO,
      bram_rst_a    => bram_rst_a,
      bram_clk_a    => bram_clk_a,
      bram_en_a     => bram_en_a,
      bram_we_a     => bram_we_a,
      bram_addr_a(31 downto 11) => open,
      bram_addr_a(10 downto  2) => bram_addr_a,
      bram_addr_a( 1 downto  0) => open,
      bram_wrdata_a => bram_wrdata_a,
      bram_rddata_a => bram_rddata_a);

  asym_ram_tdp_1: entity work.asym_ram_tdp
    generic map (
      WIDTHA     => 32,
      SIZEA      => 1024,
      ADDRWIDTHA => 10,
      WIDTHB     => 64,
      SIZEB      => 512,
      ADDRWIDTHB => 9)
    port map (
      clkA  => AXI_CLK,
      clkB  => AXI_CLK,
      enA   => '1',
      enB   => bram_en_a,
      weA   => BRAM_WRITE,
      weB   => or_reduce(bram_we_a),
      addrA => BRAM_ADDR,
      addrB => bram_addr_a,
      diA   => BRAM_WR_DATA,
      diB   => bram_wrdata_a,
      doA   => open,
      doB   => bram_rddata_a);
      
    TCDS_1: entity work.TCDS
    port map (
      clk_axi              => AXI_CLK,
      clk_200              => clk_200,
      reset_axi_n          => AXI_RST_N,
      readMOSI             => local_AXI_readMOSI(1-1),
      readMISO             => local_AXI_readMISO(1-1),
      writeMOSI            => local_AXI_writeMOSI(1-1),
      writeMISO            => local_AXI_writeMISO(1-1),
      heater_output => heater_output,
      TxRx_clk_sel => '0');    
      

 IBERT: entity work.example_ibert_ultrascale_gty_0
    port map (
--      gty_sysclkp_i => p_clk_200a,
--      gty_sysclkn_i => n_clk_200a,

      -- quad 124
      gty_rxn_i(0) => n_ff4_recv(0),
      gty_rxn_i(1) => n_ff4_recv(1),
      gty_rxn_i(2) => n_ff4_recv(2),
      gty_rxn_i(3) => n_ff4_recv(3),      
     -- quad 128
      gty_rxn_i(4) => n_ff5_recv(0),
      gty_rxn_i(5) => n_ff5_recv(1),
      gty_rxn_i(6) => n_ff5_recv(2),
      gty_rxn_i(7) => n_ff5_recv(3),
      -- quad 129
      gty_rxn_i(8) => n_ff6_recv(0),
      gty_rxn_i(9) => n_ff6_recv(1),
      gty_rxn_i(10) => n_ff6_recv(2),
      gty_rxn_i(11) => n_ff6_recv(3),
      -- quad 130
      gty_rxn_i(12) => n_ff7_recv(0),
      gty_rxn_i(13) => n_ff7_recv(1),
      gty_rxn_i(14) => n_ff7_recv(2),
      gty_rxn_i(15) => n_ff7_recv(3),
      
      -- quad 124
      gty_rxp_i(0) => p_ff4_recv(0),
      gty_rxp_i(1) => p_ff4_recv(1),
      gty_rxp_i(2) => p_ff4_recv(2),
      gty_rxp_i(3) => p_ff4_recv(3),      
     -- quad 128
      gty_rxp_i(4) => p_ff5_recv(0),
      gty_rxp_i(5) => p_ff5_recv(1),
      gty_rxp_i(6) => p_ff5_recv(2),
      gty_rxp_i(7) => p_ff5_recv(3),
      -- quad 129
      gty_rxp_i(8) => p_ff6_recv(0),
      gty_rxp_i(9) => p_ff6_recv(1),
      gty_rxp_i(10) => p_ff6_recv(2),
      gty_rxp_i(11) => p_ff6_recv(3),
      -- quad 130
      gty_rxp_i(12) => p_ff7_recv(0),
      gty_rxp_i(13) => p_ff7_recv(1),
      gty_rxp_i(14) => p_ff7_recv(2),
      gty_rxp_i(15) => p_ff7_recv(3),
            
      gty_refclk0p_i(0) => p_lf_r0_af,
      gty_refclk0p_i(1) => p_lf_r0_u,
      gty_refclk0p_i(2) => p_lf_r0_v,
      
      gty_refclk0n_i(0) => n_lf_r0_af,
      gty_refclk0n_i(1) => n_lf_r0_u,
      gty_refclk0n_i(2) => n_lf_r0_v,

      -- quad 124
      gty_txn_o(0) => n_ff4_xmit(0),
      gty_txn_o(1) => n_ff4_xmit(1),
      gty_txn_o(2) => n_ff4_xmit(2),
      gty_txn_o(3) => n_ff4_xmit(3),     
     -- quad 128
      gty_txn_o(4) => n_ff5_xmit(0),
      gty_txn_o(5) => n_ff5_xmit(1),
      gty_txn_o(6) => n_ff5_xmit(2),
      gty_txn_o(7) => n_ff5_xmit(3),
      -- quad 129
      gty_txn_o(8) => n_ff6_xmit(0),
      gty_txn_o(9) => n_ff6_xmit(1),
      gty_txn_o(10) => n_ff6_xmit(2),
      gty_txn_o(11) => n_ff6_xmit(3),
      -- quad 130
      gty_txn_o(12) => n_ff7_xmit(0),
      gty_txn_o(13) => n_ff7_xmit(1),
      gty_txn_o(14) => n_ff7_xmit(2),
      gty_txn_o(15) => n_ff7_xmit(3),
      
      -- quad 124
      gty_txp_o(0) => p_ff4_xmit(0),
      gty_txp_o(1) => p_ff4_xmit(1),
      gty_txp_o(2) => p_ff4_xmit(2),
      gty_txp_o(3) => p_ff4_xmit(3),     
     -- quad 128
      gty_txp_o(4) => p_ff5_xmit(0),
      gty_txp_o(5) => p_ff5_xmit(1),
      gty_txp_o(6) => p_ff5_xmit(2),
      gty_txp_o(7) => p_ff5_xmit(3),
      -- quad 129
      gty_txp_o(8) => p_ff6_xmit(0),
      gty_txp_o(9) => p_ff6_xmit(1),
      gty_txp_o(10) => p_ff6_xmit(2),
      gty_txp_o(11) => p_ff6_xmit(3),
      -- quad 130
      gty_txp_o(12) => p_ff7_xmit(0),
      gty_txp_o(13) => p_ff7_xmit(1),
      gty_txp_o(14) => p_ff7_xmit(2),
      gty_txp_o(15) => p_ff7_xmit(3)            
      
      );
      
    
end architecture structure;

