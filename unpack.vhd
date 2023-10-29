library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity unpack is
    Port ( x : in STD_LOGIC_VECTOR (31 downto 0);
           y : in STD_LOGIC_VECTOR (31 downto 0);
           sign_x : out STD_LOGIC;
           exponent_x : out STD_LOGIC_VECTOR (7 downto 0);
           significand_x : out STD_LOGIC_VECTOR (23 downto 0);
           sign_y : out STD_LOGIC;
           exponent_y : out STD_LOGIC_VECTOR (7 downto 0);
           significand_y : out STD_LOGIC_VECTOR (23 downto 0));
end unpack;

architecture arch of unpack is

signal zero_x : std_logic_vector (7 downto 0);
signal zero_y : std_logic_vector (7 downto 0);


begin

sign_x <= x(31);
exponent_x <= x(30 downto 23);

process (x)
begin
    if x(30 downto 23) = x"00" then
        significand_x <= x"000000";
    else
        significand_x <= b"1" & x(22 downto 0);
    end if;
end process;

sign_y <= y(31);
exponent_y <= y(30 downto 23);

process (y)
begin
    if y(30 downto 23) = x"00" then
        significand_y <= x"000000";
    else
        significand_y <= b"1" & y(22 downto 0);
    end if;
end process;

end arch;
