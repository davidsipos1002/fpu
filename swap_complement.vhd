library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity swap_complement is
    Port ( xi : in STD_LOGIC_VECTOR (23 downto 0);
           yi : in STD_LOGIC_VECTOR (23 downto 0);
           swap : in STD_LOGIC;
           complement : in STD_LOGIC;
           xo : out STD_LOGIC_VECTOR (31 downto 0);
           yo : out STD_LOGIC_VECTOR (31 downto 0));
end swap_complement;

architecture arch of swap_complement is

signal swap_x : std_logic_vector (23 downto 0);
signal swap_y : std_logic_vector (23 downto 0);

begin

with swap select
    swap_x <= xi when '0',
              yi when others;
 
with swap select
    swap_y <= yi when '0',
              xi when others;       

xo <= x"00" & swap_x;

with complement select
    yo <= x"00" & swap_y when '0',
          x"FF" & (not swap_y) when others;

end arch;
