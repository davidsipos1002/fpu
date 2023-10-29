library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity carry_lookahead_adder_8 is
    Port ( x : in STD_LOGIC_VECTOR (7 downto 0);
           y : in STD_LOGIC_VECTOR (7 downto 0);
           cin : in STD_LOGIC;
           s : out STD_LOGIC_VECTOR (7 downto 0);
           cout : out STD_LOGIC);
end carry_lookahead_adder_8;

architecture arch of carry_lookahead_adder_8 is

component carry_lookahead_adder_4 is
    Port ( x : in STD_LOGIC_VECTOR (3 downto 0);
           y : in STD_LOGIC_VECTOR (3 downto 0);
           cin : in STD_LOGIC;
           s : out STD_LOGIC_VECTOR (3 downto 0);
           cout : out STD_LOGIC;
           pg : out STD_LOGIC;
           gg : out STD_LOGIC);
end component;

signal c4 : std_logic;

begin

adder0: carry_lookahead_adder_4 port map(x(3 downto 0), y(3 downto 0), cin, s(3 downto 0), c4);
adder1: carry_lookahead_adder_4 port map(x(7 downto 4), y(7 downto 4), c4, s(7 downto 4), cout); 

end arch;
