library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity carry_lookahead_adder_48 is
    Port ( x : in STD_LOGIC_VECTOR (47 downto 0);
           y : in STD_LOGIC_VECTOR (47 downto 0);
           cin : in STD_LOGIC;
           s : out STD_LOGIC_VECTOR (47 downto 0);
           cout : out STD_LOGIC);
end carry_lookahead_adder_48;

architecture arch of carry_lookahead_adder_48 is

component carry_lookahead_adder_16 is
    Port ( x : in STD_LOGIC_VECTOR (15 downto 0);
           y : in STD_LOGIC_VECTOR (15 downto 0);
           cin : in STD_LOGIC;
           s : out STD_LOGIC_VECTOR (15 downto 0);
           cout : out STD_LOGIC;
           pg : out STD_LOGIC;
           gg : out STD_LOGIC);
end component;

signal p0 : std_logic;
signal g0 : std_logic;
signal p1 : std_logic;
signal g1 : std_logic;
signal c1 : std_logic;
signal c2 : std_logic;

begin

adder0: carry_lookahead_adder_16 port map(x => x(15 downto 0), y => y(15 downto 0),
    cin => cin, s=> s(15 downto 0), pg => p0, gg => g0);
    
c1 <= g0 or (cin and p0);

adder1: carry_lookahead_adder_16 port map(x => x(31 downto 16), y => y(31 downto 16),
    cin => c1, s => s(31 downto 16), pg => p1, gg => g1);
    
c2 <= g1 or (g0 and p1) or (cin and p0 and p1);

adder2: carry_lookahead_adder_16 port map(x => x(47 downto 32), y => y(47 downto 32),
    cin => c2, s => s(47 downto 32), cout => cout);

end arch;
