library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity SPI_Master is
  port (
    clock   : in     std_logic;
    reset   : in     std_logic;
    enable  : in     std_logic;
    miso_0  : in     std_logic;
    miso_1  : in     std_logic;
    sclk    : buffer std_logic := '0';
    ss_n    : buffer std_logic;
    busy    : out    std_logic;
    rx_data_0 : out  std_logic_vector(15 downto 0);
    rx_data_1 : out  std_logic_vector(15 downto 0));
end SPI_Master;
    
architecture cialo of SPI_Master is
    type type_state is(ready, execute);
    signal state        : type_state;
    signal count        : integer range 0 to 5;
    signal clk_toggles  : integer range 0 to 33;
    signal assert_data  : std_logic;
    signal continue     : std_logic;
    signal rx_buffer_0  : std_logic_vector(15 downto 0);
    signal rx_buffer_1  : std_logic_vector(15 downto 0);
    signal last_bit_rx  : integer range 0 to 32;  

begin
	
    process(clock, reset)
    begin
     if(reset = '1') then
        busy <= '1';
        ss_n <= '1';
        rx_data_0 <= (others => '0');
        rx_data_1 <= (others => '0');
        state <= ready;
        
     elsif(clock'event and clock = '1') then
        case state is
            when ready =>
                busy <= '0';
                ss_n <= '1';
                continue <= '0';
                
                if(enable = '1') then
                    busy <= '1';
                    count <= 4;
                    sclk <= '1';
                    assert_data <= '0';
                    clk_toggles <= 0;
                    last_bit_rx <= 32;
                    state <= execute;
                else
                    state <= ready;
                end if;
            
            when execute =>
                busy <= '1';
                ss_n <= '0';
                
                --utworzenie sclk z clk
                if(count = 4) then --
                    count <= 1;
                    assert_data <= not assert_data;
                    if(clk_toggles = 33) then
                        clk_toggles <= 0;
                    else
                        clk_toggles <= clk_toggles + 1;
                    end if;
                    
                    if(clk_toggles <= 32 and ss_n = '0') then
                        sclk <= not sclk;
                    end if;
                    
                    if(assert_data = '0' and clk_toggles < last_bit_rx + 1 and ss_n = '0') then
                        rx_buffer_0 <= rx_buffer_0(14 downto 0) & miso_0;
                        rx_buffer_1 <= rx_buffer_1(14 downto 0) & miso_1;
                    end if;
                                       
                    if(continue = '1') then
                        continue <= '0';
                        busy <= '0';
                        rx_data_0 <= rx_buffer_0;
                        rx_data_1 <= rx_buffer_1;
                    end if;
                    
                    if(clk_toggles = 33) then
                        busy <= '0';
                        ss_n <= '1';
                        rx_data_0 <= rx_buffer_0;
                        rx_data_1 <= rx_buffer_1;
                        state <= ready;
                    else
                        state <= execute;
                    end if;
                    
                else
                    count <= count + 1;
                    state <= execute;
                end if;
            end case;
     end if;
    end process;                                

end cialo;