library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;
use IEEE.std_logic_textio.all;          -- I/O for logic types


entity tb_channel_test is

--    clk     : in std_logic;
--    reset   : in std_logic);

end entity tb_channel_test;

architecture behavioral of tb_channel_test is
  signal clk : std_logic := '0';
  signal reset : std_logic := '1';
  signal counter : integer;

  signal rx_data     : std_logic_vector(31 downto  0);
  signal rx_k_data   : std_logic_vector( 3 downto  0);
  signal rt_data     : std_logic_vector(31 downto  0);
  signal rt_k_data   : std_logic_vector( 3 downto  0);
  signal error_count : std_logic_vector(31 downto  0);

  
begin  -- architecture behavioral

  clk <= not clk after 10 ns;
  reset <= '0' after 100 ns;
  
  tb: process (clk, reset) is
  file out_file_status : text is out "tb_out.txt";
  variable test_result       : line;  
    
  begin  -- process tb
  
    if reset = '1' then              -- asynchronous reset (active high)
      counter <= 0;
    elsif clk'event and clk = '1' then  -- rising clock edge
      counter <= counter + 1;

      rx_data <= tx_data;
      rx_k_data <= tx_k_data;
      case counter is
        when 1000 =>
          rx_k_data <= not tx_k_data;
          rx_data <= not tx_data;
                       
        when others => null;
      end case;


--      write(test_result,master_address      );
--      write(test_result,master_rd_en        );
--      write(test_result,master_rd_data      );
--      write(test_result,master_rd_data_valid);
--      write(test_result,master_wr_data      );
--      write(test_result,master_wr_en        );
--
--      writeline(out_file_status,test_result);
    end if;
  end process tb;
  ChannelTest_1: entity work.ChannelTest
    port map (
      clk         => clk,
      clk_axi     => clk,
      reset       => reset,
      rx_data     => rx_data,
      rx_k_data   => rx_k_data,
      rt_data     => rt_data,
      rt_k_data   => rt_k_data,
      error_count => error_count);
end architecture behavioral;
