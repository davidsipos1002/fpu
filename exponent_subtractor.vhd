library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity exponent_subtractor is
    Port ( x : in STD_LOGIC_VECTOR (7 downto 0);
           y : in STD_LOGIC_VECTOR (7 downto 0);
           sa : out STD_LOGIC_VECTOR (4 downto 0);
           swap : out STD_LOGIC;
           zero: out STD_LOGIC);
end exponent_subtractor;

architecture arch of exponent_subtractor is

component carry_lookahead_adder_8 is
    Port ( x : in STD_LOGIC_VECTOR (7 downto 0);
           y : in STD_LOGIC_VECTOR (7 downto 0);
           cin : in STD_LOGIC;
           s : out STD_LOGIC_VECTOR (7 downto 0);
           cout : out STD_LOGIC);
end component;

component full_adder is
    Port ( x : in STD_LOGIC;
           y : in STD_LOGIC;
           cin : in STD_LOGIC;
           s : out STD_LOGIC;
           p : out STD_LOGIC;
           g : out STD_LOGIC;
           cout : out STD_LOGIC);
end component;

signal diff0 : std_logic_vector (8 downto 0);
signal diff1 : std_logic_vector (8 downto 0);
signal not_x : std_logic_vector (7 downto 0);
signal not_y : std_logic_vector (7 downto 0);
signal cout0 : std_logic;
signal cout1 : std_logic;
signal pos_diff : std_logic_vector (7 downto 0);

begin

not_x <= not x;
not_y <= not y;

adder0_8: carry_lookahead_adder_8 port map(x => x, y => not_y, 
    cin => '1', s => diff0(7 downto 0), cout => cout0);
adder0_1: full_adder port map(x => '0', y => '1', cin => cout0, s => diff0(8));

adder1_8: carry_lookahead_adder_8 port map(x => y, y => not_x, cin => '1',
    s => diff1(7 downto 0), cout => cout1);
adder1_1: full_adder port map(x =>'0', y => '1', cin => cout1, s => diff1(8));

with diff0(8) select
    pos_diff <= diff0(7 downto 0) when '0',
                diff1(7 downto 0) when others;

swap <= diff1(8);
sa <= pos_diff(4 downto 0);
zero <= pos_diff(7) or pos_diff(6) or pos_diff(5);

end arch;
