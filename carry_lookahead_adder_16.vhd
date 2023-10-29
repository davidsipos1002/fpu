library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity carry_lookahead_adder_16 is
    Port ( x : in STD_LOGIC_VECTOR (15 downto 0);
           y : in STD_LOGIC_VECTOR (15 downto 0);
           cin : in STD_LOGIC;
           s : out STD_LOGIC_VECTOR (15 downto 0);
           cout : out STD_LOGIC;
           pg : out STD_LOGIC;
           gg : out STD_LOGIC);
end carry_lookahead_adder_16;

architecture arch of carry_lookahead_adder_16 is

component carry_lookahead_adder_4 is
    Port ( x : in STD_LOGIC_VECTOR (3 downto 0);
           y : in STD_LOGIC_VECTOR (3 downto 0);
           cin : in STD_LOGIC;
           s : out STD_LOGIC_VECTOR (3 downto 0);
           cout : out STD_LOGIC;
           pg : out STD_LOGIC;
           gg : out STD_LOGIC);
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

adder0: carry_lookahead_adder_4 port map(x => x(3 downto 0), 
    y => y(3 downto 0), cin => cin , s => s(3 downto 0), pg => p(0), gg => g(0));

adder1: carry_lookahead_adder_4 port map(x => x(7 downto 4), 
    y => y(7 downto 4), cin => c(0) , s => s(7 downto 4), pg => p(1), gg => g(1));

adder2: carry_lookahead_adder_4 port map(x => x(11 downto 8), 
    y => y(11 downto 8), cin => c(1) , s => s(11 downto 8), pg => p(2), gg => g(2));

adder3: carry_lookahead_adder_4 port map(x => x(15 downto 12), 
    y => y(15 downto 12), cin => c(2) , s => s(15 downto 12), pg => p(3), gg => g(3));
    
carry_lookahead: carry_lookahead_4 port map(p => p, g => g, 
    cin => cin, cout => c, pg => pg, gg => gg);

cout <= c(3); 

end arch;
