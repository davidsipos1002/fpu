library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity full_adder is
    Port ( x : in STD_LOGIC;
           y : in STD_LOGIC;
           cin : in STD_LOGIC;
           s : out STD_LOGIC;
           p : out STD_LOGIC;
           g : out STD_LOGIC;
           cout : out STD_LOGIC);
end full_adder;

architecture arch of full_adder is

begin

s <= x xor y xor cin;
p <= x xor y;
g <= x and y;
cout <= (x and y) or (x and cin) or (y and cin);
end arch;
