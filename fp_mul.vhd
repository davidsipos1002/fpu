library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fp_mul is
    Port ( x : in STD_LOGIC_VECTOR (31 downto 0);
           y : in STD_LOGIC_VECTOR (31 downto 0);
           p : out STD_LOGIC_VECTOR (31 downto 0);
           overflow : out STD_LOGIC;
           underflow : out STD_LOGIC);
end fp_mul;

architecture arch of fp_mul is

component unpack is
    Port ( x : in STD_LOGIC_VECTOR (31 downto 0);
           y : in STD_LOGIC_VECTOR (31 downto 0);
           sign_x : out STD_LOGIC;
           exponent_x : out STD_LOGIC_VECTOR (7 downto 0);
           significand_x : out STD_LOGIC_VECTOR (23 downto 0);
           sign_y : out STD_LOGIC;
           exponent_y : out STD_LOGIC_VECTOR (7 downto 0);
           significand_y : out STD_LOGIC_VECTOR (23 downto 0));
end component;

component carry_lookahead_adder_8 is
    Port ( x : in STD_LOGIC_VECTOR (7 downto 0);
           y : in STD_LOGIC_VECTOR (7 downto 0);
           cin : in STD_LOGIC;
           s : out STD_LOGIC_VECTOR (7 downto 0);
           cout : out STD_LOGIC);
end component;

component wallace_tree_24 is
    Port ( x : in STD_LOGIC_VECTOR (23 downto 0);
           y : in STD_LOGIC_VECTOR (23 downto 0);
           p : out STD_LOGIC_VECTOR (47 downto 0));
end component;

component normalize_mul is
    Port ( sig_in : in STD_LOGIC_VECTOR (47 downto 0);
           exp_in : in STD_LOGIC_VECTOR (7 downto 0);
           sig_out : out STD_LOGIC_VECTOR (31 downto 0);
           exp_out : out STD_LOGIC_VECTOR (7 downto 0);
           r_out : out STD_LOGIC;
           s_out : out STD_LOGIC;
           overflow : out STD_LOGIC);
end component;

component round_mul is
    Port ( sig_in : in STD_LOGIC_VECTOR (31 downto 0);
           exp_in : in STD_LOGIC_VECTOR (7 downto 0);
           r : in STD_LOGIC;
           s : in STD_LOGIC;
           sig_out : out STD_LOGIC_VECTOR (22 downto 0);
           exp_out : out STD_LOGIC_VECTOR (7 downto 0);
           overflow : out STD_LOGIC);
end component;

signal sign_x : std_logic;
signal exponent_x : std_logic_vector (7 downto 0);
signal significand_x : std_logic_vector (23 downto 0);
signal sign_y : std_logic;
signal exponent_y : std_logic_vector (7 downto 0);
signal significand_y : std_logic_vector (23 downto 0);
signal exponent_sum : std_logic_vector (8 downto 0);
signal sum_overflow : std_logic;
signal sum_underflow : std_logic;
signal tentative_exponent : std_logic_vector (7 downto 0);
signal product : std_logic_vector (47 downto 0);
signal preround_significand : std_logic_vector (31 downto 0);
signal preround_tentative_exponent : std_logic_vector (7 downto 0);
signal r : std_logic;
signal s : std_logic;
signal normalize_overflow : std_logic;
signal final_sign : std_logic;
signal final_exponent : std_logic_vector (7 downto 0);
signal postround_significand : std_logic_vector (22 downto 0);
signal round_overflow : std_logic;

begin

unpack_input: unpack port map(x, y, sign_x, exponent_x, significand_x,
    sign_y, exponent_y, significand_y);
    
exponent_adder0: carry_lookahead_adder_8 port map(exponent_x, exponent_y, '1',
    exponent_sum(7 downto 0), exponent_sum(8));
    
tentative_exponent <= (not exponent_sum(7)) & exponent_sum(6 downto 0);

process(exponent_sum)
begin
    if exponent_sum(8) = '0' and exponent_sum(7) = '0' then
        sum_underflow <= '1';
    else
        sum_underflow <= '0';
    end if;
end process;

process(exponent_sum)
begin
    if exponent_sum >= b"101111111" then
        sum_overflow <= '1';
    else
        sum_overflow <= '0';
    end if;
end process;

multiplier: wallace_tree_24 port map(significand_x, significand_y, product);

normalize_product: normalize_mul port map(product, tentative_exponent, preround_significand,
    preround_tentative_exponent, r, s, normalize_overflow);

round_product: round_mul port map(preround_significand, preround_tentative_exponent,
    r, s, postround_significand, final_exponent, round_overflow);
    
final_sign <= sign_x xor sign_y;

process(exponent_x, exponent_y, final_sign, final_exponent, postround_significand,
    sum_overflow, normalize_overflow, round_overflow, sum_underflow)
begin
    if exponent_x = x"00" or exponent_y = x"00" then
        p <= final_sign & x"00" & b"000" & x"00000";
        overflow <= '0';
        underflow <= '0';
    else
        p <= final_sign & final_exponent & postround_significand;
        overflow <= sum_overflow or normalize_overflow or round_overflow;
        underflow <= sum_underflow;
    end if;
end process;

end arch;
