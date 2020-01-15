--This file was auto-generated.
--Modifications might be lost.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.AXIRegPkg.all;
use work.types.all;
use work.TCDS_Ctrl.all;
entity TCDS_interface is
  port (
    clk_axi          : in  std_logic;
    reset_axi_n      : in  std_logic;
    slave_readMOSI   : in  AXIReadMOSI;
    slave_readMISO   : out AXIReadMISO  := DefaultAXIReadMISO;
    slave_writeMOSI  : in  AXIWriteMOSI;
    slave_writeMISO  : out AXIWriteMISO := DefaultAXIWriteMISO;
    Mon              : in  TCDS_Mon_t;
    Ctrl             : out TCDS_Ctrl_t
    );
end entity TCDS_interface;
architecture behavioral of TCDS_interface is
  signal localAddress       : slv_32_t;
  signal localRdData        : slv_32_t;
  signal localRdData_latch  : slv_32_t;
  signal localWrData        : slv_32_t;
  signal localWrEn          : std_logic;
  signal localRdReq         : std_logic;
  signal localRdAck         : std_logic;


  signal reg_data :  slv32_array_t(integer range 0 to 71);
  constant Default_reg_data : slv32_array_t(integer range 0 to 71) := (others => x"00000000");
begin  -- architecture behavioral

  -------------------------------------------------------------------------------
  -- AXI 
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  AXIRegBridge : entity work.axiLiteReg
    port map (
      clk_axi     => clk_axi,
      reset_axi_n => reset_axi_n,
      readMOSI    => slave_readMOSI,
      readMISO    => slave_readMISO,
      writeMOSI   => slave_writeMOSI,
      writeMISO   => slave_writeMISO,
      address     => localAddress,
      rd_data     => localRdData_latch,
      wr_data     => localWrData,
      write_en    => localWrEn,
      read_req    => localRdReq,
      read_ack    => localRdAck);

  latch_reads: process (clk_axi) is
  begin  -- process latch_reads
    if clk_axi'event and clk_axi = '1' then  -- rising clock edge
      if localRdReq = '1' then
        localRdData_latch <= localRdData;        
      end if;
    end if;
  end process latch_reads;
  reads: process (localRdReq,localAddress,reg_data) is
  begin  -- process reads
    localRdAck  <= '0';
    localRdData <= x"00000000";
    if localRdReq = '1' then
      localRdAck  <= '1';
      case localAddress(6 downto 0) is
        when x"0" =>
          localRdData( 1)            <=  Mon.CLOCKING.POWER_GOOD;           --
          localRdData( 9)            <=  Mon.CLOCKING.RX_CDR_STABLE;        --
        when x"20" =>
          localRdData( 1)            <=  Mon.TX.PMA_RESET_DONE;             --
          localRdData( 4)            <=  Mon.TX.PWR_GOOD;                   --
        when x"42" =>
          localRdData( 3 downto  0)  <=  reg_data(66)( 3 downto  0);        --
        when x"44" =>
          localRdData(31 downto  0)  <=  Mon.DEBUG.CAPTURE_D;               --
        when x"5" =>
          localRdData( 0)            <=  reg_data( 5)( 0);                  --
          localRdData( 4)            <=  reg_data( 5)( 4);                  --
          localRdData( 5)            <=  reg_data( 5)( 5);                  --
          localRdData( 8)            <=  reg_data( 5)( 8);                  --
          localRdData( 9)            <=  reg_data( 5)( 9);                  --
        when x"6" =>
          localRdData( 6)            <=  Mon.RESETS.TX_RESET_DONE;          --
          localRdData( 7)            <=  Mon.RESETS.TX_PMA_RESET_DONE;      --
          localRdData(10)            <=  Mon.RESETS.RX_RESET_DONE;          --
          localRdData(11)            <=  Mon.RESETS.RX_PMA_RESET_DONE;      --
        when x"21" =>
          localRdData( 3 downto  0)  <=  reg_data(33)( 3 downto  0);        --
          localRdData( 5)            <=  reg_data(33)( 5);                  --
          localRdData( 6)            <=  reg_data(33)( 6);                  --
        when x"8" =>
          localRdData( 2 downto  0)  <=  reg_data( 8)( 2 downto  0);        --
        when x"47" =>
          localRdData( 3 downto  0)  <=  reg_data(71)( 3 downto  0);        --
        when x"10" =>
          localRdData( 1)            <=  Mon.RX.PMA_RESET_DONE;             --
          localRdData( 7 downto  4)  <=  Mon.RX.BAD_CHAR;                   --
          localRdData(11 downto  8)  <=  Mon.RX.DISP_ERROR;                 --
        when x"11" =>
          localRdData( 3 downto  0)  <=  reg_data(17)( 3 downto  0);        --
          localRdData( 5)            <=  reg_data(17)( 5);                  --
        when x"31" =>
          localRdData( 0)            <=  reg_data(49)( 0);                  --
        when x"46" =>
          localRdData(31 downto  0)  <=  reg_data(70)(31 downto  0);        --
        when x"45" =>
          localRdData( 3 downto  0)  <=  Mon.DEBUG.CAPTURE_K;               --
        when others =>
          localRdData <= x"00000000";
      end case;
    end if;
  end process reads;



  -- Register mapping to ctrl structures
  Ctrl.RESETS.RESET_ALL        <=  reg_data( 5)( 0);               
  Ctrl.RESETS.TX_PLL_DATAPATH  <=  reg_data( 5)( 4);               
  Ctrl.RESETS.TX_DATAPATH      <=  reg_data( 5)( 5);               
  Ctrl.RESETS.RX_PLL_DATAPATH  <=  reg_data( 5)( 8);               
  Ctrl.RESETS.RX_DATAPATH      <=  reg_data( 5)( 9);               
  Ctrl.LOOPBACK                <=  reg_data( 8)( 2 downto  0);     
  Ctrl.RX.PRBS_SEL             <=  reg_data(17)( 3 downto  0);     
  Ctrl.RX.USER_CLK_READY       <=  reg_data(17)( 5);               
  Ctrl.TX.PRBS_SEL             <=  reg_data(33)( 3 downto  0);     
  Ctrl.TX.INHIBIT              <=  reg_data(33)( 5);               
  Ctrl.TX.USER_CLK_READY       <=  reg_data(33)( 6);               
  Ctrl.EYESCAN.RESET           <=  reg_data(49)( 0);               
  Ctrl.DEBUG.MODE              <=  reg_data(66)( 3 downto  0);     
  Ctrl.DEBUG.FIXED_SEND_D      <=  reg_data(70)(31 downto  0);     
  Ctrl.DEBUG.FIXED_SEND_K      <=  reg_data(71)( 3 downto  0);     



  reg_writes: process (clk_axi, reset_axi_n) is
  begin  -- process reg_writes
    if reset_axi_n = '0' then                 -- asynchronous reset (active low)
      reg_data <= default_reg_data;
    elsif clk_axi'event and clk_axi = '1' then  -- rising clock edge
      Ctrl.RX.PRBS_RESET <= '0';
      Ctrl.TX.PRBS_FORCE_ERROR <= '0';
      Ctrl.EYESCAN.TRIGGER <= '0';
      Ctrl.DEBUG.CAPTURE <= '0';
      
      if localWrEn = '1' then
        case localAddress(6 downto 0) is
        when x"40" =>
          Ctrl.DEBUG.CAPTURE          <=  localWrData( 0);               
        when x"21" =>
          Ctrl.TX.PRBS_FORCE_ERROR    <=  localWrData( 4);               
          reg_data(33)( 3 downto  0)  <=  localWrData( 3 downto  0);      --
          reg_data(33)( 5)            <=  localWrData( 5);                --
          reg_data(33)( 6)            <=  localWrData( 6);                --
        when x"42" =>
          reg_data(66)( 3 downto  0)  <=  localWrData( 3 downto  0);      --
        when x"5" =>
          reg_data( 5)( 0)            <=  localWrData( 0);                --
          reg_data( 5)( 4)            <=  localWrData( 4);                --
          reg_data( 5)( 5)            <=  localWrData( 5);                --
          reg_data( 5)( 8)            <=  localWrData( 8);                --
          reg_data( 5)( 9)            <=  localWrData( 9);                --
        when x"46" =>
          reg_data(70)(31 downto  0)  <=  localWrData(31 downto  0);      --
        when x"31" =>
          reg_data(49)( 0)            <=  localWrData( 0);                --
          Ctrl.EYESCAN.TRIGGER        <=  localWrData( 4);               
        when x"8" =>
          reg_data( 8)( 2 downto  0)  <=  localWrData( 2 downto  0);      --
        when x"47" =>
          reg_data(71)( 3 downto  0)  <=  localWrData( 3 downto  0);      --
        when x"11" =>
          Ctrl.RX.PRBS_RESET          <=  localWrData( 4);               
          reg_data(17)( 3 downto  0)  <=  localWrData( 3 downto  0);      --
          reg_data(17)( 5)            <=  localWrData( 5);                --
          when others => null;
        end case;
      end if;
    end if;
  end process reg_writes;

end architecture behavioral;
