library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity PmodAD1 is 
  port (
  clk     : in     std_logic;
  reset   : in     std_logic;
  data_0  : in     std_logic;
  data_1  : in     std_logic;
  sck     : buffer std_logic;
  cs      : buffer std_logic;
  led     : out    std_logic_vector(3 downto 0));
end PmodAD1;

architecture Behavioral of PmodAD1 is
--  signal clk  :   std_logic := '0';       --sygna³y do symulacji
--  signal reset  :   std_logic := '1';
--  signal cs     :   std_logic := '0';
--  signal sck    : std_logic := '0';
--  signal data_0  :  std_logic :='0';
--  signal data_1  :  std_logic :='0';
--  signal exdata_0   :   std_logic_vector(15 downto 0) := "0000110101101011"; --wartoœci do symulacji
--  signal exdata_1   :   std_logic_vector(15 downto 0) := "0000110101010011";
--  signal led    :       std_logic_vector(3 downto 0);
  
  signal adc_0   :    std_logic_vector(11 downto 0);
  signal adc_1   :    std_logic_vector(11 downto 0); 
  signal led_reg       : std_logic_vector(3 downto 0) := "0000";
  signal spi_rx_data_0 : std_logic_vector(15 downto 0);
  signal spi_rx_data_1 : std_logic_vector(15 downto 0);
  signal spi_enable    : std_logic;
  signal spi_busy      : std_logic;
  signal count         : integer range 0 to 5;
  
 component SPI_Master is
  port (
    clock   : in     std_logic;
    reset   : in     std_logic;
    enable  : in     std_logic;
    miso_0  : in     std_logic;
    miso_1  : in     std_logic;
    sclk    : buffer std_logic;
    ss_n    : buffer std_logic;
    busy    : out    std_logic;
    rx_data_0 : out  std_logic_vector(15 downto 0);
    rx_data_1 : out  std_logic_vector(15 downto 0));
    end component SPI_Master;
        
begin
    
--  process is			    -- symulacja zegara
--  begin					    
--    wait for 4 ns;          -- odczekanie 1/8ns = 125MHz
--    clk <= not clk;         -- zmiana stanu clk
--  end process;

--  process(sck)				-- symulacja danych odbieranych z PmodAD1
--  begin					
--    if rising_edge(sck) then
--        data_0 <= exdata_0(15);
--        data_1 <= exdata_1(15);
--        exdata_0 <= exdata_0(14 downto 0) & exdata_0(15);
--        exdata_1 <= exdata_1(14 downto 0) & exdata_1(15);
--    end if;  
--  end process;	

  SPI_Master_0:  SPI_Master
    PORT MAP(clock => clk,
             reset => reset,
             enable => spi_enable,
             miso_0 => data_0,
             miso_1 => data_1,
             sclk => sck,
             ss_n => cs,
             busy => spi_busy, 
             rx_data_0 => spi_rx_data_0,
             rx_data_1 => spi_rx_data_1);
             
    process(clk,reset)
--        variable count : natural range 0 to 5;
    begin
        if(reset = '1') then
            count <= 0;
            spi_enable <= '0';
            led_reg(3 downto 0) <= "0000";
        elsif(clk'event and clk = '1') then
            if(spi_busy = '0') then
                if(count < 5) then
                    count <= count + 1;
                    spi_enable <= '0';
                else
                    spi_enable <= '1';
                end if;
            else
                count <= 0;
                spi_enable <= '0';
            end if;
        end if;
        
        
        if(spi_rx_data_0(12 downto 11) = "11") then
            led_reg(3) <= '1';
        else
            led_reg(3) <= '0';
        end if;
        
        if(spi_rx_data_0(12 downto 11) = "00") then
            led_reg(2) <= '1';
        else
            led_reg(2) <= '0';
        end if;
        
        if(spi_rx_data_1(12 downto 11) = "11") then
            led_reg(1) <= '1';
        else
            led_reg(1) <= '0';
        end if;
        
        if(spi_rx_data_1(12 downto 11) = "00") then
            led_reg(0) <= '1';
        else
            led_reg(0) <= '0';
        end if;
    end process;
    
    led <= led_reg;
    adc_0 <= spi_rx_data_0(11 downto 0);
    adc_1 <= spi_rx_data_1(11 downto 0);
    

end Behavioral;
