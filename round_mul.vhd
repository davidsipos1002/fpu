library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity round_mul is
    Port ( sig_in : in STD_LOGIC_VECTOR (31 downto 0);
           exp_in : in STD_LOGIC_VECTOR (7 downto 0);
           r : in STD_LOGIC;
           s : in STD_LOGIC;
           sig_out : out STD_LOGIC_VECTOR (22 downto 0);
           exp_out : out STD_LOGIC_VECTOR (7 downto 0);
           overflow : out STD_LOGIC);
end round_mul;

architecture arch of round_mul is

component carry_lookahead_adder_8 is
    Port ( x : in STD_LOGIC_VECTOR (7 downto 0);
           y : in STD_LOGIC_VECTOR (7 downto 0);
           cin : in STD_LOGIC;
           s : out STD_LOGIC_VECTOR (7 downto 0);
           cout : out STD_LOGIC);
end component;

component carry_lookahead_adder_32 is
    Port ( x : in STD_LOGIC_VECTOR (31 downto 0);
           y : in STD_LOGIC_VECTOR (31 downto 0);
           cin : in STD_LOGIC;
           s : out STD_LOGIC_VECTOR (31 downto 0);
           cout : out STD_LOGIC);
end component;

signal round : std_logic;
signal rounded_exp : std_logic_vector (7 downto 0);
signal rounded_significand : std_logic_vector (31 downto 0);

begin

round <= r and (sig_in(0) or s);

round_adder: carry_lookahead_adder_32 port map(sig_in, x"00000000", 
    round, rounded_significand);

exp_adder: carry_lookahead_adder_8 port map(exp_in, x"00", rounded_significand(24),
    rounded_exp);
    
process(rounded_exp)
begin
    if rounded_exp = x"FF" then
        overflow <= '1';
    else
        overflow <= '0';
    end if;
end process;

exp_out <= rounded_exp;

with rounded_significand(24) select
    sig_out <= rounded_significand(22 downto 0) when '0',
               rounded_significand(23 downto 1) when others;

end arch;
