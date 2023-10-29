library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_2_1 is
    Port ( i0 : in STD_LOGIC;
           i1 : in STD_LOGIC;
           s : in STD_LOGIC;
           o : out STD_LOGIC);
end mux_2_1;

architecture arch of mux_2_1 is

begin

with s select
    o <= i1 when '1',
         i0 when others;

end arch;
