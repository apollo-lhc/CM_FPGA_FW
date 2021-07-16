--This file was auto-generated.
--Modifications might be lost.
library IEEE;
use IEEE.std_logic_1164.all;


package SPYBUFFER_TEST_CTRL is
  type SPYBUFFER_TEST_BUILD_DATE_MON_t is record
    DAY                        :std_logic_vector( 7 downto 0);
    MONTH                      :std_logic_vector( 7 downto 0);
    YEAR                       :std_logic_vector(15 downto 0);
  end record SPYBUFFER_TEST_BUILD_DATE_MON_t;


  type SPYBUFFER_TEST_BUILD_TIME_MON_t is record
    SEC                        :std_logic_vector( 7 downto 0);
    MIN                        :std_logic_vector( 7 downto 0);
    HOUR                       :std_logic_vector( 7 downto 0);
  end record SPYBUFFER_TEST_BUILD_TIME_MON_t;


  type SPYBUFFER_TEST_FPGA_MON_t is record
    WORD_00                    :std_logic_vector(31 downto 0);
    WORD_01                    :std_logic_vector(31 downto 0);
    WORD_02                    :std_logic_vector(31 downto 0);
    WORD_03                    :std_logic_vector(31 downto 0);
    WORD_04                    :std_logic_vector(31 downto 0);
    WORD_05                    :std_logic_vector(31 downto 0);
    WORD_06                    :std_logic_vector(31 downto 0);
    WORD_07                    :std_logic_vector(31 downto 0);
    WORD_08                    :std_logic_vector(31 downto 0);
  end record SPYBUFFER_TEST_FPGA_MON_t;


  type SPYBUFFER_TEST_MEM1_MOSI_t is record
    clk       : std_logic;
    enable    : std_logic;
    wr_enable : std_logic;
    address   : std_logic_vector(8-1 downto 0);
    wr_data   : std_logic_vector(13-1 downto 0);
  end record SPYBUFFER_TEST_MEM1_MOSI_t;
  type SPYBUFFER_TEST_MEM1_MISO_t is record
    rd_data         : std_logic_vector(13-1 downto 0);
    rd_data_valid   : std_logic;
  end record SPYBUFFER_TEST_MEM1_MISO_t;
  constant Default_SPYBUFFER_TEST_MEM1_MOSI_t : SPYBUFFER_TEST_MEM1_MOSI_t := ( 
                                                     clk       => '0',
                                                     enable    => '0',
                                                     wr_enable => '0',                                                    
                                                     address   => (others => '0'),
                                                     wr_data   => (others => '0')
  );
  type SPYBUFFER_TEST_LEVEL_TEST_MEM_MOSI_t is record
    clk       : std_logic;
    enable    : std_logic;
    wr_enable : std_logic;
    address   : std_logic_vector(8-1 downto 0);
    wr_data   : std_logic_vector(13-1 downto 0);
  end record SPYBUFFER_TEST_LEVEL_TEST_MEM_MOSI_t;
  type SPYBUFFER_TEST_LEVEL_TEST_MEM_MISO_t is record
    rd_data         : std_logic_vector(13-1 downto 0);
    rd_data_valid   : std_logic;
  end record SPYBUFFER_TEST_LEVEL_TEST_MEM_MISO_t;
  constant Default_SPYBUFFER_TEST_LEVEL_TEST_MEM_MOSI_t : SPYBUFFER_TEST_LEVEL_TEST_MEM_MOSI_t := ( 
                                                     clk       => '0',
                                                     enable    => '0',
                                                     wr_enable => '0',
                                                     address   => (others => '0'),
                                                     wr_data   => (others => '0')
  );
  type SPYBUFFER_TEST_LEVEL_TEST_MON_t is record
    MEM                        :SPYBUFFER_TEST_LEVEL_TEST_MEM_MISO_t;
  end record SPYBUFFER_TEST_LEVEL_TEST_MON_t;


  type SPYBUFFER_TEST_LEVEL_TEST_CTRL_t is record
    THING                      :std_logic_vector(31 downto 0);
    MEM                        :SPYBUFFER_TEST_LEVEL_TEST_MEM_MOSI_t;
  end record SPYBUFFER_TEST_LEVEL_TEST_CTRL_t;


  constant DEFAULT_SPYBUFFER_TEST_LEVEL_TEST_CTRL_t : SPYBUFFER_TEST_LEVEL_TEST_CTRL_t := (
                                                                               MEM => Default_SPYBUFFER_TEST_LEVEL_TEST_MEM_MOSI_t,
                                                                               THING => (others => '0')
                                                                              );
  type SPYBUFFER_TEST_MON_t is record
    STATUS_FLAG                :std_logic_vector(31 downto 0);                 
    MEM1                       :SPYBUFFER_TEST_MEM1_MISO_t;         
    LEVEL_TEST                 :SPYBUFFER_TEST_LEVEL_TEST_MON_t;    
  end record SPYBUFFER_TEST_MON_t;


  type SPYBUFFER_TEST_CTRL_t is record
    FREEZE                     :std_logic_vector;
    PLAYBACK                   :std_logic_vector;
    MEM1                       :SPYBUFFER_TEST_MEM1_MOSI_t;         
    LEVEL_TEST                 :SPYBUFFER_TEST_LEVEL_TEST_CTRL_t;   
  end record SPYBUFFER_TEST_CTRL_t;


  constant DEFAULT_SPYBUFFER_TEST_CTRL_t : SPYBUFFER_TEST_CTRL_t := (
                                                         FREEZE => '0',
                                                         PLAYBACK => '0',
                                                         MEM1 => Default_SPYBUFFER_TEST_MEM1_MOSI_t,
                                                         LEVEL_TEST => DEFAULT_SPYBUFFER_TEST_LEVEL_TEST_CTRL_t
                                                        );


end package SPYBUFFER_TEST_CTRL;
