library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity normalize_mul is
    Port ( sig_in : in STD_LOGIC_VECTOR (47 downto 0);
           exp_in : in STD_LOGIC_VECTOR (7 downto 0);
           sig_out : out STD_LOGIC_VECTOR (31 downto 0);
           exp_out : out STD_LOGIC_VECTOR (7 downto 0);
           r_out : out STD_LOGIC;
           s_out : out STD_LOGIC;
           overflow : out STD_LOGIC);
end normalize_mul;

architecture arch of normalize_mul is

component carry_lookahead_adder_8 is
    Port ( x : in STD_LOGIC_VECTOR (7 downto 0);
           y : in STD_LOGIC_VECTOR (7 downto 0);
           cin : in STD_LOGIC;
           s : out STD_LOGIC_VECTOR (7 downto 0);
           cout : out STD_LOGIC);
end component;

signal norm_exp : std_logic_vector (7 downto 0);
signal r : std_logic;
signal s : std_logic;

begin

adder: carry_lookahead_adder_8 port map(exp_in, x"00", sig_in(47), norm_exp);

process(norm_exp)
begin
    if norm_exp = x"FF" then
        overflow <= '1';
    else
        overflow <= '0';
    end if;
end process;

r <= sig_in(22);
s <= sig_in(21) or sig_in(20) or sig_in(19) or sig_in(18) or sig_in(17) or sig_in(16) or
     sig_in(15) or sig_in(14) or sig_in(13) or sig_in(12) or sig_in(11) or sig_in(10) or
     sig_in(9) or sig_in(8) or sig_in(7) or sig_in(6) or sig_in(5) or sig_in(4) or
     sig_in(3) or sig_in(2) or sig_in(1) or sig_in(0);

with sig_in(47) select
    sig_out <= b"0000000" & sig_in(47 downto 23) when '0',
               b"00000000" & sig_in(47 downto 24) when others;
               
exp_out <= norm_exp;
               
with sig_in(47) select
    r_out <= r when '0',
             sig_in(23) when others;

with sig_in(47) select
    s_out <= s when '0',
             s or sig_in(22) when others;
end arch;
