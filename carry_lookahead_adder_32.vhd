library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity carry_lookahead_adder_32 is
    Port ( x : in STD_LOGIC_VECTOR (31 downto 0);
           y : in STD_LOGIC_VECTOR (31 downto 0);
           cin : in STD_LOGIC;
           s : out STD_LOGIC_VECTOR (31 downto 0);
           cout : out STD_LOGIC);
end carry_lookahead_adder_32;

architecture arch of carry_lookahead_adder_32 is

component carry_lookahead_adder_16 is
    Port ( x : in STD_LOGIC_VECTOR (15 downto 0);
           y : in STD_LOGIC_VECTOR (15 downto 0);
           cin : in STD_LOGIC;
           s : out STD_LOGIC_VECTOR (15 downto 0);
           cout : out STD_LOGIC;
           pg : out STD_LOGIC;
           gg : out STD_LOGIC);
end component;

signal p : std_logic;
signal g : std_logic;
signal c : std_logic;

begin

adder0 : carry_lookahead_adder_16 port map(x => x(15 downto 0), y => y(15 downto 0), 
    cin => cin, s => s(15 downto 0), pg => p, gg => g);

adder1: carry_lookahead_adder_16 port map(x => x(31 downto 16), y => y(31 downto 16),
     cin => c, s => s(31 downto 16), cout => cout);

c <= g or (p and cin);

end arch;
