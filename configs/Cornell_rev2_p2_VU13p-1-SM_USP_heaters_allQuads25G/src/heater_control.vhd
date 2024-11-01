library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.axiRegPkg.all;
use work.HEATER_Ctrl.all;
use work.types.all;

Library UNISIM;
use UNISIM.vcomponents.all;


entity heater_control is
  port (
    clk_axi              : in  std_logic; --50 MHz
    clk_200              : in  std_logic;
    reset_axi_n          : in  std_logic;
    readMOSI             : in  AXIreadMOSI;
    readMISO             : out AXIreadMISO;
    writeMOSI            : in  AXIwriteMOSI;
    writeMISO            : out AXIwriteMISO;
    heater_output : out slv32_array_t(31 downto 0));

end entity heater_control;

architecture behavioral of heater_control is
  signal heater_output_pl : slv32_array_t(31 downto 0);
  signal heater_enable : std_logic;
  signal heater_adjust : std_logic_vector(31 downto 0);
  signal heater_select : std_logic_vector(31 downto 0);
  signal reset : std_logic;

  signal Mon              :  VIRTEX_Mon_t;
  signal Ctrl             :  VIRTEX_Ctrl_t;
  
begin  -- architecture TCDS
  reset <= not reset_axi_n;

 gen_heater_1: for i in 0 to 7 generate
   heater_1: entity  work.heater
     generic map (
       C_SLV_DWIDTH            => 32,
       C_NUM_LUTS              => 4096--8192--32768--131072--65536
       ) port map (
         clk                     => clk_200,
         reset                   => reset,
         enable_heater           => heater_enable,
         adjust_heaters          => heater_adjust,
         read_which_heater       => heater_select,
         heater_output           => heater_output_pl(i)
         );
 end generate gen_heater_1;

  gen_heater_2: for i in 8 to 15 generate
    heater_2: entity  work.heater
      generic map (
        C_SLV_DWIDTH            => 32,
        C_NUM_LUTS              => 4096--8192--32768--131072--65536
        ) port map (
          clk                     => clk_200,
          reset                   => reset,
          enable_heater           => heater_enable,
          adjust_heaters          => heater_adjust,
          read_which_heater       => heater_select,
          heater_output           => heater_output_pl(i)
          );
  end generate gen_heater_2;
  
  gen_heater_3: for i in 16 to 23 generate
   heater_3: entity  work.heater
     generic map (
       C_SLV_DWIDTH            => 32,
       C_NUM_LUTS              => 4096--8192--32768--131072--65536
       ) port map (
         clk                     => clk_200,
         reset                   => reset,
         enable_heater           => heater_enable,
         adjust_heaters          => heater_adjust,
         read_which_heater       => heater_select,
         heater_output           => heater_output_pl(i)
         );
 end generate gen_heater_3;

  gen_heater_4: for i in 24 to 31 generate
    heater_4: entity  work.heater
      generic map (
        C_SLV_DWIDTH            => 32,
        C_NUM_LUTS              => 4096--8192--32768--131072--65536
        ) port map (
          clk                     => clk_200,
          reset                   => reset,
          enable_heater           => heater_enable,
          adjust_heaters          => heater_adjust,
          read_which_heater       => heater_select,
          heater_output           => heater_output_pl(i)
          );
  end generate gen_heater_4;
            
  data_proc: process (clk_200, reset) is
    begin  -- process data_proc
      if rising_edge(clk_200) then
        if (reset = '1') then
          heater_enable <= '0';
          heater_adjust <= (others=>'0');
          heater_output <= (others => (others => '0'));
          heater_select <= (others => '0');
        else
          heater_enable <= Ctrl.Heater.Enable;
          heater_adjust <= Ctrl.Heater.Adjust;
          heater_output <= heater_output_pl;
          heater_select <= Ctrl.Heater.SelectHeater;
        end if;
      end if;
    end process data_proc;
    


  heater_interface_1: entity work.heater_interface
    port map (
      clk_axi         => clk_axi,
      reset_axi_n     => reset_axi_n,
      slave_readMOSI  => readMOSI,
      slave_readMISO  => readMISO,
      slave_writeMOSI => writeMOSI,
      slave_writeMISO => writeMISO,
      Mon             => Mon,
      Ctrl            => Ctrl);
      
end architecture behavioral;
