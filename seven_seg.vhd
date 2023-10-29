library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity seven_seg is
    Port ( clk : in STD_LOGIC;
           data : in STD_LOGIC_VECTOR(31 downto 0);
           an : out STD_LOGIC_VECTOR(7 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0));
end seven_seg;

architecture arch of seven_seg is

signal cnt : std_logic_vector(15 downto 0);
signal d : std_logic_vector(3 downto 0);

begin

process(clk)
begin
    if clk'event and clk='1' then
        cnt <= cnt + 1;
    end if;
end process;

process(cnt(15 downto 13))
begin
    case cnt(15 downto 13) is
        when "000" => an <= "11111110";
        when "001" => an <= "11111101";
        when "010" => an <= "11111011";
        when "011" => an <= "11110111";
        when "100" => an <= "11101111";
        when "101" => an <= "11011111";
        when "110" => an <= "10111111";
        when "111" => an <= "01111111";
        when others => an <= "00000000";
    end case;
end process;

process(data, cnt(15 downto 13))
begin
    case cnt(15 downto 13) is
        when "000" => d <= data(3 downto 0);
        when "001" => d <= data(7 downto 4);
        when "010" => d <= data(11 downto 8);
        when "011" => d <= data(15 downto 12);
        when "100" => d <= data(19 downto 16);
        when "101" => d <= data(23 downto 20);
        when "110" => d <= data(27 downto 24);
        when "111" => d <= data(31 downto 28);
        when others => d <= "0000";
    end case;
end process;

with d select
   cat<= "1111001" when "0001",   --1
         "0100100" when "0010",   --2
         "0110000" when "0011",   --3
         "0011001" when "0100",   --4
         "0010010" when "0101",   --5
         "0000010" when "0110",   --6
         "1111000" when "0111",   --7
         "0000000" when "1000",   --8
         "0010000" when "1001",   --9
         "0001000" when "1010",   --A
         "0000011" when "1011",   --b
         "1000110" when "1100",   --C
         "0100001" when "1101",   --d
         "0000110" when "1110",   --E
         "0001110" when "1111",   --F
         "1000000" when others;   --0

end arch;
