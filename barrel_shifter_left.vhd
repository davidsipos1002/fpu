library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity barrel_shifter_left is
    Port ( x : in STD_LOGIC_VECTOR (31 downto 0);
           sa : in STD_LOGIC_VECTOR (4 downto 0);
           o : out STD_LOGIC_VECTOR (31 downto 0));
end barrel_shifter_left;

architecture arch of barrel_shifter_left is

component mux_2_1 is
    Port ( i0 : in STD_LOGIC;
           i1 : in STD_LOGIC;
           s : in STD_LOGIC;
           o : out STD_LOGIC);
end component;

type shifter is array(0 to 4) of std_logic_vector(31 downto 0);
signal levels : shifter;

begin

level0: for i in 31 downto 0 generate
    if0: if i = 0 generate
        mux0: mux_2_1 port map(x(0), '0', sa(0), levels(0)(i));
    end generate;
    
    if1: if i > 0 generate
        mux1: mux_2_1 port map(x(i), x(i - 1), sa(0), levels(0)(i));
    end generate;
end generate;

outer: for lvl in 1 to 4 generate
    inner: for i in 31 downto 0 generate
        if0: if i <= 2 ** lvl - 1 generate
            mux0: mux_2_1 port map(levels(lvl - 1)(i), '0', sa(lvl), levels(lvl)(i));
        end generate;
        
        if1: if i > 2 ** lvl - 1 generate
            mux1: mux_2_1 port map(levels(lvl - 1)(i), levels(lvl - 1)(i - 2 ** lvl), sa(lvl), levels(lvl)(i));
        end generate;
    end generate;
end generate;

o <= levels(4);

end arch;
