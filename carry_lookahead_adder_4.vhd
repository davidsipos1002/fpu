library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity carry_lookahead_adder_4 is
    Port ( x : in STD_LOGIC_VECTOR (3 downto 0);
           y : in STD_LOGIC_VECTOR (3 downto 0);
           cin : in STD_LOGIC;
           s : out STD_LOGIC_VECTOR (3 downto 0);
           cout : out STD_LOGIC;
           pg : out STD_LOGIC;
           gg : out STD_LOGIC);
end carry_lookahead_adder_4;

architecture arch of carry_lookahead_adder_4 is

component full_adder is
    Port ( x : in STD_LOGIC;
           y : in STD_LOGIC;
           cin : in STD_LOGIC;
           s : out STD_LOGIC;
           p : out STD_LOGIC;
           g : out STD_LOGIC;
           cout : out STD_LOGIC);
end component;

component carry_lookahead_4 is
    Port ( p : in STD_LOGIC_VECTOR (3 downto 0);
           g : in STD_LOGIC_VECTOR (3 downto 0);
           cin : in STD_LOGIC;
           cout : out STD_LOGIC_VECTOR (3 downto 0);
           pg : out STD_LOGIC;
           gg : out STD_LOGIC);
end component;

signal p : std_logic_vector (3 downto 0);
signal g : std_logic_vector (3 downto 0);
signal c : std_logic_vector (3 downto 0);

begin

adder0: full_adder port map(x(0), y(0), cin, s(0), p(0), g(0));
adder1: full_adder port map(x(1), y(1), c(0), s(1), p(1), g(1));
adder2: full_adder port map(x(2), y(2), c(1), s(2), p(2), g(2));
adder3: full_adder port map(x(3), y(3), c(2), s(3), p(3), g(3));

carry_lookahead: carry_lookahead_4 port map(p, g, cin, c, pg, gg);

cout <= c(3);

end arch;
