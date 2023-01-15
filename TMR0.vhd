library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity TMR0 is
  Port (
        clock_100Mhz : in STD_LOGIC;
        CLK_EX: in STD_LOGIC;
        EN: in STD_LOGIC;
        RESET: in STD_LOGIC;
        SWT: in STD_LOGIC_VECTOR(7 downto 0);
        Anode_Activate: out STD_LOGIC_VECTOR(3 downto 0);
        LED_OUT: out STD_LOGIC_VECTOR( 6 downto 0)
        );
end TMR0;

architecture Behavioral of TMR0 is
signal TIMER: STD_LOGIC_VECTOR(7 downto 0);
signal TMRIF: STD_LOGIC;
signal LED_activating_counter: std_logic_vector(1 downto 0);
signal LED_BCD: STD_LOGIC_VECTOR (3 downto 0);
signal displayed_number: STD_LOGIC_VECTOR (9 downto 0);
signal refresh_counter: STD_LOGIC_VECTOR (19 downto 0);
begin

process(LED_BCD)
begin
    case LED_BCD is
    when "0000" => LED_out <= "1000000"; -- "0"     
    when "0001" => LED_out <= "1111001"; -- "1" 
    when "0010" => LED_out <= "0100100"; -- "2" 
    when "0011" => LED_out <= "0110000"; -- "3" 
    when "0100" => LED_out <= "0011001"; -- "4" 
    when "0101" => LED_out <= "0010010"; -- "5" 
    when "0110" => LED_out <= "0000010"; -- "6" 
    when "0111" => LED_out <= "1111000"; -- "7" 
    when "1000" => LED_out <= "0000000"; -- "8"     
    when "1001" => LED_out <= "0010000"; -- "9" 
    when others => LED_out <= "1111111";
    end case;
end process;

process(clock_100Mhz,reset)
begin 
    if(reset='1') then
        refresh_counter <= (others => '0');
    elsif(rising_edge(clock_100Mhz)) then
        refresh_counter <= refresh_counter + 1;
    end if;
end process;
 LED_activating_counter <= refresh_counter(19 downto 18);

process(LED_activating_counter)
begin
    case LED_activating_counter is
    when "00" =>
        Anode_Activate <= "1011";
        if (TMRIF = '1') then 
            LED_BCD <="1100" + displayed_number(9 downto 8);
        else
            LED_BCD <="0000" + displayed_number(9 downto 8);
        end if;
    when "01" =>
        Anode_Activate <= "1101"; 
        LED_BCD <= displayed_number(7 downto 4);
    when "10" =>
        Anode_Activate <= "1110"; 
        LED_BCD <= displayed_number(3 downto 0);
    when others => Anode_Activate <= "1111";    
    end case;
end process;

process(clk_ex, reset, EN)
begin
        TMRIF <= '0';
        if(reset='1') then
            TIMER <=(others => '0');
        elsif(EN = '1') then
            TIMER <= SWT;
        elsif(rising_edge(clk_ex)) then
            if(TIMER = "11111111") then       
                TMRIF <= '1';
            else
                TIMER <= TIMER + 1;
            end if;
        end if;
end process;

process (TIMER)
    variable z: STD_LOGIC_VECTOR(17 downto 0);
begin
    if (TMRIF = '1') then
    displayed_number <= "1111111111";
    else
        for i in 0 to 17 loop
            z(i) := '0';
        end loop;
        z(10 downto 3) := TIMER;
        for i in 0 to 4 loop
            if z(11 downto 8) > 4 then
                z(11 downto 8) := z(11 downto 8)+3;
            end if;
            if z(15 downto 12) > 4 then
                z(15 downto 12) := z(15 downto 12)+3;
            end if;
            z(17 downto 1) := z(16 downto 0);
        end loop;
        displayed_number(9 downto 0) <= z(17 downto 8);
    end if;
end process;
end Behavioral;


