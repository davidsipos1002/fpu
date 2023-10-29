library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity half_adder is
    Port ( x : in STD_LOGIC;
           y : in STD_LOGIC;
           s : out STD_LOGIC;
           cout : out STD_LOGIC);
end half_adder;

architecture arch of half_adder is

begin

s <= x xor y;
cout <= x and y;

end arch;
