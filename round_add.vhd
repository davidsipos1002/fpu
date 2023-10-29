library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity round_add is
    Port ( sig_in : in STD_LOGIC_VECTOR (31 downto 0);
           exp_in : in STD_LOGIC_VECTOR (7 downto 0);
           r : in STD_LOGIC;
           s : in STD_LOGIC;
           exp_out : out STD_LOGIC_VECTOR (7 downto 0);
           overflow : out STD_LOGIC;
           sig_out : out STD_LOGIC_VECTOR (22 downto 0));
end round_add;

architecture arch of round_add is

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

signal sig_cin : std_logic;
signal sum : std_logic_vector (31 downto 0);
signal normalized : std_logic_vector (31 downto 0);
signal new_exp : std_logic_vector (7 downto 0);

begin

sig_cin <= r and (sig_in(0) or s);

sig_round: carry_lookahead_adder_32 port map(sig_in, x"00000000", sig_cin, sum);

exp_add: carry_lookahead_adder_8 port map(exp_in, x"00", sum(24), new_exp);

process (new_exp)
begin
    if new_exp = x"FF" then
        overflow <= '1';
    else
        overflow <= '0';
   end if;
end process;

exp_out <= new_exp;

with sum(24) select
    normalized <= sum when '0',
                  b"0" & sum(31 downto 1) when others;

sig_out <= normalized(22 downto 0);

end arch;
