library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity carry_lookahead_4 is
    Port ( p : in STD_LOGIC_VECTOR (3 downto 0);
           g : in STD_LOGIC_VECTOR (3 downto 0);
           cin : in STD_LOGIC;
           cout : out STD_LOGIC_VECTOR (3 downto 0);
           pg : out STD_LOGIC;
           gg : out STD_LOGIC);
end carry_lookahead_4;

architecture arch of carry_lookahead_4 is

signal c1 : std_logic;
signal c2 : std_logic;
signal c3 : std_logic;
signal c4 : std_logic;

begin

c1 <= g(0) or (p(0) and cin);
c2 <= g(1) or (g(0) and p(1)) or (cin and p(0) and p(1));
c3 <= g(2) or (g(1) and p(2)) or (g(0) and p(1) and p(2)) or (cin and p(0) and p(1) and p(2));
c4 <= g(3) or (g(2) and p(3)) or (g(1) and p(2) and p(3)) or (g(0) and p(1) and p(2) and p(3)) or (cin and p(0) and p(1) and p(2) and p(3));

cout <= c4 & c3 & c2 & c1;

pg <= p(0) and p(1) and p(2) and p(3);
gg <= g(3) or (g(2) and p(3)) or (g(1) and p(2) and p(3)) or (g(0) and p(1) and p(2) and p(3));
end arch;
