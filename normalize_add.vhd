library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity normalize_add is
    Port ( sig_in : in STD_LOGIC_VECTOR (31 downto 0);
           exp_in : in STD_LOGIC_VECTOR (7 downto 0);
           g_in : in STD_LOGIC;
           r_in : in STD_LOGIC;
           s_in : in STD_LOGIC;
           sig_out : out STD_LOGIC_VECTOR (31 downto 0);
           exp_out : out STD_LOGIC_VECTOR (7 downto 0);
           r_out : out STD_LOGIC;
           s_out : out STD_LOGIC;
           underflow : out STD_LOGIC;
           overflow : out STD_LOGIC);
end normalize_add;

architecture arch of normalize_add is

component barrel_shifter_left is
    Port ( x : in STD_LOGIC_VECTOR (31 downto 0);
           sa : in STD_LOGIC_VECTOR (4 downto 0);
           o : out STD_LOGIC_VECTOR (31 downto 0));
end component;

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

signal dir : std_logic;
signal or_sum : std_logic_vector(22 downto 0);
signal sa : std_logic_vector (4 downto 0);
signal left_sa : std_logic_vector (4 downto 0);
signal g_mask : std_logic_vector (31 downto 0);
signal left_shifted : std_logic_vector (31 downto 0);
signal final_left_shifted : std_logic_vector (31 downto 0);
signal right_shifted : std_logic_vector (31 downto 0);
signal adjust_exp : std_logic_vector (8 downto 0);
signal new_exp : std_logic_vector (7 downto 0);
signal cout : std_logic;
signal exp_sign : std_logic;
signal left_r : std_logic;
signal left_s : std_logic;

begin

dir <= sig_in(24);

or_sum(0) <= sig_in(22);
or_sum(1) <= or_sum(0) or sig_in(21);
or_sum(2) <= or_sum(1) or sig_in(20);
or_sum(3) <= or_sum(2) or sig_in(19);
or_sum(4) <= or_sum(3) or sig_in(18);
or_sum(5) <= or_sum(4) or sig_in(17);
or_sum(6) <= or_sum(5) or sig_in(16);
or_sum(7) <= or_sum(6) or sig_in(15);
or_sum(8) <= or_sum(7) or sig_in(14);
or_sum(9) <= or_sum(8) or sig_in(13);
or_sum(10) <= or_sum(9) or sig_in(12);
or_sum(11) <= or_sum(10) or sig_in(11);
or_sum(12) <= or_sum(11) or sig_in(10);
or_sum(13) <= or_sum(12) or sig_in(9);
or_sum(14) <= or_sum(13) or sig_in(8);
or_sum(15) <= or_sum(14) or sig_in(7);
or_sum(16) <= or_sum(15) or sig_in(6);
or_sum(17) <= or_sum(16) or sig_in(5);
or_sum(18) <= or_sum(17) or sig_in(4);
or_sum(19) <= or_sum(18) or sig_in(3);
or_sum(20) <= or_sum(19) or sig_in(2);
or_sum(21) <= or_sum(20) or sig_in(1);
or_sum(22) <= or_sum(21) or sig_in(0);

sa <=      b"00001" when or_sum(0) = '1' else
           b"00010" when or_sum(1) = '1' else
           b"00011" when or_sum(2) = '1' else
           b"00100" when or_sum(3) = '1' else
           b"00101" when or_sum(4) = '1' else
           b"00110" when or_sum(5) = '1' else
           b"00111" when or_sum(6) = '1' else
           b"01000" when or_sum(7) = '1' else
           b"01001" when or_sum(8) = '1' else
           b"01010" when or_sum(9) = '1' else
           b"01011" when or_sum(10) = '1' else
           b"01100" when or_sum(11) = '1' else
           b"01101" when or_sum(12) = '1' else
           b"01110" when or_sum(13) = '1' else
           b"01111" when or_sum(14) = '1' else
           b"10000" when or_sum(15) = '1' else
           b"10001" when or_sum(16) = '1' else
           b"10010" when or_sum(17) = '1' else
           b"10011" when or_sum(18) = '1' else
           b"10100" when or_sum(19) = '1' else
           b"10101" when or_sum(20) = '1' else
           b"10110" when or_sum(21) = '1' else
           b"10111" when or_sum(22) = '1' else
           b"00000";
           

with sig_in(23) select 
    left_sa <= sa when '0',
               b"00000" when others;
           
with left_sa select
g_mask <= x"00000000" when b"00000",
       x"00000001" when b"00001",
       x"00000002" when b"00010",
       x"00000004" when b"00011",
       x"00000008" when b"00100",
       x"00000010" when b"00101",
       x"00000020" when b"00110",
       x"00000040" when b"00111",
       x"00000080" when b"01000",
       x"00000100" when b"01001",
       x"00000200" when b"01010",
       x"00000400" when b"01011",
       x"00000800" when b"01100",
       x"00001000" when b"01101",
       x"00002000" when b"01110",
       x"00004000" when b"01111",
       x"00008000" when b"10000",
       x"00010000" when b"10001",
       x"00020000" when b"10010",
       x"00040000" when b"10011",
       x"00080000" when b"10100",
       x"00100000" when b"10101",
       x"00200000" when b"10110",
       x"00400000" when b"10111",
       x"00000000" when others;

left_shift: barrel_shifter_left port map(sig_in, left_sa, left_shifted);

right_shifted <= b"0" & sig_in(31 downto 1);

with g_in select
    final_left_shifted <= left_shifted when '0',
                          left_shifted or g_mask when others;

with dir select 
    sig_out <= final_left_shifted when '0',
               right_shifted when others;
               
with dir select 
    adjust_exp <= x"F" & (not left_sa) when '0',
                       b"000000000" when others;

adder0: carry_lookahead_adder_8 port map(exp_in, adjust_exp(7 downto 0), 
    '1', new_exp, cout);
adder1: full_adder port map('0', adjust_exp(8), cout, exp_sign);

process (exp_sign, new_exp)
begin
    if exp_sign = '1' or new_exp = x"00" then
        underflow <= '1';
    else
        underflow <= '0';
    end if;
    
    if new_exp = x"FF" then 
        overflow <= '1';
    else
        overflow <= '0';
    end if;
end process;

exp_out <= new_exp;

with left_sa select
    left_r <= g_in when b"00000",
              r_in when b"00001",
              '0' when others;

with left_sa select
    left_s <= r_in or s_in when b"00000",
              s_in when b"00001",
              '0' when others;

with dir select
    r_out <= left_r when '0',
             sig_in(0) when others;

with dir select
    s_out <= left_s when '0',
             g_in or r_in or s_in when others;

end arch;
