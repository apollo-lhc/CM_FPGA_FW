library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.my_package.all;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;





entity I2C  is
    port (
        clock200             : in  std_logic;
        reset                : in  std_logic;
        -- I2C
        SCL                  : in  std_logic;
        SDA                  : in  std_logic;
        SDA_Z_en             : out std_logic;
        -- info to monitor
        rates                : in array_64xreg32;
        clk_in_tc_rate       : in reg32;
        clk_out_tc_rate      : in reg32;
        clk_50_rate          : in reg32;
        led_out              : out std_logic
    );
end I2C;



architecture RTL of I2C is


    signal onesec_counter_200MHz : std_logic_vector(27 downto 0) := (others => '0');
    
    type i2c_states is (idle, start, write_reg_add, read_reg, write_reg);
    signal i2c_state : i2c_states := idle;

    signal SDA_sr : std_logic_vector(7 downto 0);
    signal SCL_sr : std_logic_vector(7 downto 0);

    signal SDA_IOB_r : std_logic;
    signal SCL_IOB_r : std_logic;

    attribute IOB : string;
    attribute IOB of SDA_IOB_r : signal is "TRUE";
    attribute IOB of SCL_IOB_r : signal is "TRUE";

    signal SDA_r : std_logic;
    signal SCL_r : std_logic;
    signal SDA_r_old : std_logic;
    signal SCL_r_old : std_logic;

    signal vio_configuration_en : std_logic;
    signal i2c_bit_counter : std_logic_vector(4 downto 0);
    
    constant Pad_i2c_slave_add : std_logic_vector(6 downto 0) := "0001000";
    signal i2c_slave_add : std_logic_vector(6 downto 0);

    signal i2c_timeout_counter : std_logic_vector(18 downto 0) := (others => '0');

    signal i2c_read : std_logic;

    signal i2c_reg_add : std_logic_vector(7 downto 0);
    signal control_reg : std_logic_vector(31 downto 0);
    signal control_reg2 : std_logic_vector(31 downto 0);
    signal control_reg3 : std_logic_vector(31 downto 0);
    signal status_reg : std_logic_vector(31 downto 0);
    signal status_reg2 : std_logic_vector(31 downto 0);
    signal status_reg3 : std_logic_vector(31 downto 0);
    signal vio_control : std_logic_vector(31 downto 0);
    signal i2c_sr : std_logic_vector(31 downto 0);

    signal byte_count : std_logic_vector(2 downto 0);
    
    signal SDA_out : std_logic;


    signal sel : natural;
    signal rate_0 : reg32;
    signal rate_1 : reg32;
    signal rate_2 : reg32;
    signal rate_3 : reg32;
    signal rate_4 : reg32;
    signal rate_5 : reg32;
    signal rate_6 : reg32;
    signal rate_7 : reg32;


    component vio_config
        port (
            clk         : in  std_logic;
            probe_in0   : in  std_logic_vector(31 downto 0);
            probe_in1   : in  std_logic_vector(31 downto 0);
            probe_in2   : in  std_logic_vector(31 downto 0);
            probe_in3   : in  std_logic_vector(31 downto 0);
            probe_in4   : in  std_logic_vector(31 downto 0);
            probe_in5   : in  std_logic_vector(31 downto 0);
            probe_in6   : in  std_logic_vector(31 downto 0);
            probe_in7   : in  std_logic_vector(31 downto 0);
            probe_in8   : in  std_logic_vector(31 downto 0);
            probe_in9   : in  std_logic_vector(31 downto 0);
            probe_in10   : in  std_logic_vector(31 downto 0);
            probe_out0  : out std_logic_vector(31 downto 0)
        );
    end component;

    
    constant control_reg_default  : std_logic_vector(31 downto 0) := X"00000000";--ro enabled --X"1D007108"; -- 00 01.11 0 1 .0000.0000.0111 .0 001.0 000.1000
    constant control_reg2_default : std_logic_vector(31 downto 0) := X"00000000";

begin

    led_out <= onesec_counter_200MHz(onesec_counter_200MHz'high);
    
    SDA_Z_en <= SDA_out;
    
    status_reg(31 downto 0) <= ( others => '0');
    status_reg2(31 downto 0) <= (others => '0');



    assign_register_logic : process(clock200)
    begin
        if rising_edge(clock200) then
            if vio_configuration_en = '1' then
                sel <= to_integer(unsigned(vio_control(6 downto 4)));
            else
                sel <= to_integer(unsigned(control_reg(6 downto 4)));
            end if;
        end if;
    end process;

    vio_config_inst : vio_config
    port map (
        clk           => clock200,
        probe_in0     => rate_0,
        probe_in1     => rate_1,
        probe_in2     => rate_2,
        probe_in3     => rate_3,
        probe_in4     => rate_4,
        probe_in5     => rate_5,
        probe_in6     => rate_6,
        probe_in7     => rate_7,
        probe_in8     => clk_in_tc_rate,
        probe_in9     => clk_out_tc_rate,
        probe_in10    => clk_50_rate,
        probe_out0    => vio_control

    );

    vio_configuration_en <= vio_control(0);

    rate_0 <= rates(sel*8);
    rate_1 <= rates(sel*8+1);
    rate_2 <= rates(sel*8+2);
    rate_3 <= rates(sel*8+3);
    rate_4 <= rates(sel*8+4);
    rate_5 <= rates(sel*8+5);
    rate_6 <= rates(sel*8+6);
    rate_7 <= rates(sel*8+7);
    -- 1 sec counter @ 40.07897 MHz LHC clock frequency
    onesec_counter_200MHz_logic : process(clock200)
    begin
        if rising_edge(clock200) then
            if onesec_counter_200MHz = X"BEBC200" then -- X"2638E7A" then
                onesec_counter_200MHz <= (others => '0');
            else
                onesec_counter_200MHz <= onesec_counter_200MHz + 1;
            end if;
        end if;
    end process;




    i2c_filter_logic : process(clock200)
    begin
        if rising_edge(clock200) then
            SDA_IOB_r <= SDA;
            SCL_IOB_r <= SCL;
            SDA_sr <= SDA_sr(6 downto 0) & SDA_IOB_r;
            SCL_sr <= SCL_sr(6 downto 0) & SCL_IOB_r;
            if SDA_sr = X"FF" then
                SDA_r <= '1';
            elsif SDA_sr = X"00" then
                SDA_r <= '0';
            end if;
            if SCL_sr = X"FF" then
                SCL_r <= '1';
            elsif SCL_sr = X"00" then
                SCL_r <= '0';
            end if;
            SDA_r_old <= SDA_r;
            SCL_r_old <= SCL_r;
        end if;
    end process;

    i2c_slave_logic : process(reset, clock200)
    begin
        if rising_edge(clock200) then
            if reset = '1' then
                i2c_state <= idle;
                control_reg <= control_reg_default;
                control_reg2 <= control_reg2_default;

                i2c_slave_add <= (others => '0');
                i2c_reg_add <= (others => '0');
                i2c_read <= '1';
                i2c_sr <= (others => '0');
            else
                case i2c_state is
                    when idle =>
                        SDA_out <= '1';
                        i2c_bit_counter <= (others => '0');
                        i2c_timeout_counter <= (others => '0');
                        byte_count <= (others => '0');
                        if SCL_r = '1' and SDA_r_old = '1' and SDA_r = '0' then -- START
                            i2c_state <= start;
                        end if;
                    when start =>
                        if i2c_timeout_counter = "1111111111111111111" then
                            i2c_state <= idle;
                        else
                            i2c_timeout_counter <= i2c_timeout_counter + '1';
                            if SCL_r = '1' and SDA_r_old = '0' and SDA_r = '1' then -- STOP
                                i2c_state <= idle;
                            else
                            
                                if SCL_r_old = '0' and SCL_r = '1' then
                                    i2c_bit_counter <= i2c_bit_counter + 1;
                                    if i2c_bit_counter <= "00110" then
                                        i2c_slave_add <= i2c_slave_add(5 downto 0) & SDA_r;
                                    elsif i2c_bit_counter = "00111" then
                                        if i2c_slave_add = Pad_i2c_slave_add then
                                            i2c_read <= SDA_r;
                                        else
                                            i2c_state <= idle;
                                        end if;
                                    elsif i2c_bit_counter = "01000" then
                                        i2c_bit_counter <= (others => '0');
                                        i2c_timeout_counter <= (others => '0');
                                        if i2c_read = '0' then
                                            i2c_state <= write_reg_add;
                                        else
                                            i2c_state <= read_reg;
                                        end if;
                                    end if;
                                elsif SCL_r_old = '1' and SCL_r = '0' then
                                    if i2c_bit_counter = "01000" then
                                        SDA_out <= '0'; -- ACK
                                    end if;
                                end if;
                            
                            end if;
                        end if;
                    when write_reg_add =>
                        if i2c_timeout_counter = "1111111111111111111" then
                            i2c_state <= idle;
                        else
                            i2c_timeout_counter <= i2c_timeout_counter + '1';
                            if SCL_r = '1' and SDA_r_old = '0' and SDA_r = '1' then -- STOP
                                i2c_state <= idle;
                            else
                            
                                if SCL_r_old = '0' and SCL_r = '1' then
                                    if i2c_bit_counter <= "0111" then
                                        i2c_bit_counter <= i2c_bit_counter + 1;
                                        i2c_reg_add <= i2c_reg_add(6 downto 0) & SDA_r;
                                    elsif i2c_bit_counter = "01000" then
                                        i2c_timeout_counter <= (others => '0');
                                        i2c_bit_counter <= (others => '0');
                                        i2c_state <= write_reg;
                                    end if;
                                elsif SCL_r_old = '1' and SCL_r = '0' then
                                    if i2c_bit_counter = "00000" then
                                        SDA_out <= '1';
                                    elsif i2c_bit_counter = "01000" then
                                        if i2c_reg_add = X"00" or
                                           i2c_reg_add = X"01" or
                                           i2c_reg_add = X"02" or
                                           i2c_reg_add = X"03" or
                                           i2c_reg_add = X"04" or
                                           i2c_reg_add = X"05" or
                                           i2c_reg_add = X"06" or
                                           i2c_reg_add = X"07" or
                                           i2c_reg_add = X"08" or
                                           i2c_reg_add = X"09" or
                                           i2c_reg_add = X"0A" or
                                           i2c_reg_add = X"0B" or
                                           i2c_reg_add = X"0C" or
                                           i2c_reg_add = X"0D" or
                                           i2c_reg_add = X"0E" or
                                           i2c_reg_add = X"0F" or
                                           i2c_reg_add = X"10" or
                                           i2c_reg_add = X"11" or
                                           i2c_reg_add = X"12" OR
                                           i2c_reg_add = X"13" OR
                                           i2c_reg_add = X"14" OR
                                           i2c_reg_add = X"15" then
                                            SDA_out <= '0'; -- ACK
                                        else
                                            SDA_out <= '1'; -- NACK, wrong register address
                                            i2c_state <= idle;
                                        end if;
                                    end if;
                                end if;
                            
                            end if;
                        end if;
                    when write_reg =>
                        if i2c_timeout_counter = "1111111111111111111" then
                            i2c_state <= idle;
                        else
                            i2c_timeout_counter <= i2c_timeout_counter + '1';
                            if SCL_r = '1' and SDA_r_old = '0' and SDA_r = '1' then -- STOP
                                i2c_state <= idle;
                            else
                            
                                if SCL_r_old = '0' and SCL_r = '1' then
                                    if i2c_bit_counter <= "0111" then
                                        i2c_bit_counter <= i2c_bit_counter + 1;
                                        i2c_sr <= i2c_sr(30 downto 0) & SDA_r;
                                    else
                                        i2c_bit_counter <= (others => '0');
                                    end if;
                                elsif SCL_r_old = '1' and SCL_r = '0' then
                                    if i2c_bit_counter = "00000" then
                                        SDA_out <= '1';
                                        if byte_count = "100" then
                                            i2c_state <= idle;
                                        end if;
                                    elsif i2c_bit_counter = "01000" then
                                        SDA_out <= '0';
                                        byte_count <= byte_count + 1;
                                        if byte_count = "011" then
                                            case i2c_reg_add is
                                                when X"00" =>
                                                    control_reg <= i2c_sr;

                                                when others =>
                                                    null;
                                            end case;
                                        end if;
                                    end if;
                                end if;
                            
                            end if;
                        end if;
                    when read_reg =>
                        if i2c_timeout_counter = "1111111111111111111" then
                            i2c_state <= idle;
                        else
                            i2c_timeout_counter <= i2c_timeout_counter + '1';
                            if SCL_r = '1' and SDA_r_old = '0' and SDA_r = '1' then -- STOP
                                i2c_state <= idle;
                            else
                            
                                if SCL_r_old = '0' and SCL_r = '1' then
                                    if i2c_bit_counter = "1000" then
                                        i2c_bit_counter <= (others => '0');
                                        if SDA_r = '1' then
                                            i2c_state <= idle;
                                        end if;
                                    else
                                        i2c_bit_counter <= i2c_bit_counter + 1;
                                    end if;
                                elsif SCL_r_old = '1' and SCL_r = '0' then
                                    if i2c_bit_counter <= "0111" then
                                        case i2c_reg_add is
                                            when X"00" =>
                                                SDA_out <= control_reg(31 - 8*to_integer(unsigned(byte_count)) - to_integer(unsigned(i2c_bit_counter)));
                                            when X"01" =>
                                                SDA_out <= status_reg(31 - 8*to_integer(unsigned(byte_count)) - to_integer(unsigned(i2c_bit_counter)));
                                            when X"02" =>
                                                SDA_out <= '0';
                                            when X"03" =>
                                                SDA_out <= rate_0(31 - 8*to_integer(unsigned(byte_count)) - to_integer(unsigned(i2c_bit_counter)));
                                            when X"04" =>
                                                SDA_out <= rate_1(31 - 8*to_integer(unsigned(byte_count)) - to_integer(unsigned(i2c_bit_counter)));
                                            when X"05" =>
                                                SDA_out <= rate_2(31 - 8*to_integer(unsigned(byte_count)) - to_integer(unsigned(i2c_bit_counter)));
                                            when X"06" =>
                                                SDA_out <= rate_3(31 - 8*to_integer(unsigned(byte_count)) - to_integer(unsigned(i2c_bit_counter)));
                                            when X"07" =>
                                                SDA_out <= rate_4(31 - 8*to_integer(unsigned(byte_count)) - to_integer(unsigned(i2c_bit_counter)));
                                            when X"08" =>
                                                SDA_out <= rate_5(31 - 8*to_integer(unsigned(byte_count)) - to_integer(unsigned(i2c_bit_counter)));
                                            when X"09" =>
                                                SDA_out <= rate_6(31 - 8*to_integer(unsigned(byte_count)) - to_integer(unsigned(i2c_bit_counter)));
                                            when X"0A" =>
                                                SDA_out <= rate_7(31 - 8*to_integer(unsigned(byte_count)) - to_integer(unsigned(i2c_bit_counter)));
                                            when X"0B" =>
                                                SDA_out <= clk_in_tc_rate(31 - 8*to_integer(unsigned(byte_count)) - to_integer(unsigned(i2c_bit_counter)));
                                            when X"0C" =>
                                                SDA_out <= clk_out_tc_rate(31 - 8*to_integer(unsigned(byte_count)) - to_integer(unsigned(i2c_bit_counter)));
                                            when X"0D" =>
                                                SDA_out <= clk_50_rate(31 - 8*to_integer(unsigned(byte_count)) - to_integer(unsigned(i2c_bit_counter)));
                                            when others =>
                                                SDA_out <= '1';
                                        end case;
                                    elsif i2c_bit_counter = "1000" then
                                        byte_count <= byte_count + 1;
                                        SDA_out <= '1';
                                    end if;
                                    
                                end if;
                            
                            end if;
                        end if;
                    when others =>
                        i2c_state <= idle;
                end case;
            end if;
        end if;
    end process;

end RTL;


