library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity testbench is
--  Port ( );
end testbench;

architecture Behavioral of testbench is

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

component exponent_subtractor is
    Port ( x : in STD_LOGIC_VECTOR (7 downto 0);
           y : in STD_LOGIC_VECTOR (7 downto 0);
           sa : out STD_LOGIC_VECTOR (4 downto 0);
           swap : out STD_LOGIC;
           zero: out STD_LOGIC);
end component;

component swap_complement is
    Port ( xi : in STD_LOGIC_VECTOR (23 downto 0);
           yi : in STD_LOGIC_VECTOR (23 downto 0);
           swap : in STD_LOGIC;
           complement : in STD_LOGIC;
           xo : out STD_LOGIC_VECTOR (31 downto 0);
           yo : out STD_LOGIC_VECTOR (31 downto 0));
end component;

component align_significand is
    Port ( sig_in : in STD_LOGIC_VECTOR (31 downto 0);
           zero : in STD_LOGIC;
           sa : in STD_LOGIC_VECTOR (4 downto 0);
           sig_out : out STD_LOGIC_VECTOR (31 downto 0);
           g : out STD_LOGIC;
           r : out STD_LOGIC;
           s : out STD_LOGIC);
end component;

component carry_lookahead_adder_32 is
    Port ( x : in STD_LOGIC_VECTOR (31 downto 0);
           y : in STD_LOGIC_VECTOR (31 downto 0);
           cin : in STD_LOGIC;
           s : out STD_LOGIC_VECTOR (31 downto 0);
           cout : out STD_LOGIC);
end component;

component normalize_add is
    Port ( sig_in : in STD_LOGIC_VECTOR (31 downto 0);
           exp_in : in STD_LOGIC_VECTOR (7 downto 0);
           g_in : in STD_LOGIC;
           r_in : in STD_LOGIC;
           s_in : in STD_LOGIC;
           sig_out : out STD_LOGIC_VECTOR (31 downto 0);
           exp_out : out STD_LOGIC_VECTOR;
           r_out : out STD_LOGIC;
           s_out : out STD_LOGIC;
           underflow : out STD_LOGIC;
           overflow : out STD_LOGIC);
end component;

component round_add is
    Port ( sig_in : in STD_LOGIC_VECTOR (31 downto 0);
           exp_in : in STD_LOGIC_VECTOR (7 downto 0);
           r : in STD_LOGIC;
           s : in STD_LOGIC;
           exp_out : out STD_LOGIC_VECTOR (7 downto 0);
           overflow : out STD_LOGIC;
           sig_out : out STD_LOGIC_VECTOR (22 downto 0));
end component;

signal sign_x : std_logic;
signal exponent_x : std_logic_vector (7 downto 0);
signal significand_x : std_logic_vector (23 downto 0);
signal sign_y : std_logic;
signal exponent_y : std_logic_vector (7 downto 0);
signal significand_y : std_logic_vector (23 downto 0);
signal preshift_sa : std_logic_vector (4 downto 0);
signal swap_operands : std_logic;
signal preshift_zero : std_logic;
signal tentative_exponent : std_logic_vector (7 downto 0);
signal complement : std_logic;
signal operand_x : std_logic_vector (31 downto 0);
signal operand_y : std_logic_vector (31 downto 0);
signal aligned_x : std_logic_vector (31 downto 0);
signal guard : std_logic;
signal round : std_logic;
signal sticky : std_logic;
signal sum_sign : std_logic;
signal sum : std_logic_vector (31 downto 0);
signal negated_sum : std_logic_vector (31 downto 0);
signal positive_sum : std_logic_vector (31 downto 0);
signal preround_normalized_sum : std_logic_vector (31 downto 0);
signal preround_tentative_exponent : std_logic_vector (7 downto 0);
signal preround_round : std_logic;
signal preround_sticky : std_logic;
signal preround_underflow : std_logic;
signal preround_overflow : std_logic;
signal postround_exponent : std_logic_vector (7 downto 0);
signal postround_overflow : std_logic;
signal postround_significand : std_logic_vector (22 downto 0);
signal flip_sign : std_logic;
signal final_sign : std_logic;
signal sub_sign_y : std_logic;

signal x: std_logic_vector (31 downto 0);
signal y: std_logic_vector (31 downto 0);
signal sub : std_logic;
signal overflow : std_logic;
signal underflow : std_logic;
signal s : std_logic_vector (31 downto 0);

begin

process
begin
    x <= x"3f800000"; -- 1
    y <= x"bf800000"; -- -1
    sub <= '0';
    -- Result: 00000000 = 0
    wait for 10ns;
    
    x <= x"40490fd0"; -- 3.14159011841
    y <= x"402df84d"; -- 2.71828007698
    sub <= '0';
    -- Result: 40bb840e = 5.85986995697
    wait for 10ns;
    
    x <= x"00800002"; -- 1.17549463108e-38 = second smallest magnitude
    y <= x"00800001"; -- 1.17549449095e-38 = smallest magnitude
    sub <= '1';
    -- Result: underflow
    wait for 10ns;
    
    x <= x"7f7fffff"; -- 3.40282346639e+38 = largest magnitude
    y <= x"7f7fffff"; -- 3.40282346639e+38 = largest magnitude
    sub <= '0';
    -- Result: overflow
    wait for 10ns;
    
    x <= x"ff7fffff"; -- -3.40282346639e+38 = largest magnitude
    y <= x"ff7fffff"; -- -3.40282346639e+38 = largest magnitude
    sub <= '0';
    -- Result: overflow
    wait for 10ns;
    
        
    x <= x"7f7fffff"; -- 3.40282346639e+38 = largest magnitude
    y <= x"ff7fffff"; -- -3.40282346639e+38 = largest magnitude
    sub <= '0';
    -- Result: 0
    wait for 10ns;
   
    x <= x"7f7fffff"; -- 3.40282346639e+38 = largest magnitude
    y <= x"7f7fffff"; -- 3.40282346639e+38 = largest magnitude
    sub <= '1';
    -- Result: 0
    wait for 10ns;
    
    x <= x"00000000"; -- 0
    y <= x"00000000"; -- 0
    sub <= '0';
    -- Result: 0
    wait for 10ns;
     
    x <= x"00000000"; -- 0
    y <= x"00000000"; -- 0
    sub <= '1';
    -- Result: 0
    wait for 10ns;

    wait;
end process;


unpack_inputs: unpack port map(x, y, sign_x, exponent_x, significand_x,
    sign_y, exponent_y, significand_y);
sub_sign_y <= sub xor sign_y;
complement <= sign_x xor sub_sign_y;

exponent_substract: exponent_subtractor port map(exponent_x, exponent_y,
    preshift_sa, swap_operands, preshift_zero);

with swap_operands select
    tentative_exponent <= exponent_y when '0',
                     exponent_x when others;
                     
swap_and_complement: swap_complement port map(significand_x, significand_y,
    swap_operands, complement, operand_x, operand_y);
    
align_operands: align_significand port map(operand_x, preshift_zero, preshift_sa,
    aligned_x, guard, round, sticky);
    
adder: carry_lookahead_adder_32 port map(aligned_x, operand_y, complement, sum);
sum_sign <= sum(31);

with sum_sign select
    negated_sum <= sum when '0',
                    not sum when others;

complementer: carry_lookahead_adder_32 port map(negated_sum, x"00000000", sum_sign,
    positive_sum);
    
normalize_sum: normalize_add port map(positive_sum, tentative_exponent, guard,
    round, sticky, preround_normalized_sum, preround_tentative_exponent,
    preround_round, preround_sticky, preround_underflow, preround_overflow);
 
rounded_sum: round_add port map(preround_normalized_sum, preround_tentative_exponent,
    preround_round, preround_sticky, postround_exponent, postround_overflow,
    postround_significand);
    
flip_sign <= ((not swap_operands) and sign_x) or (swap_operands and sub_sign_y);
final_sign <= ((sum_sign xor flip_sign) and complement) or ((not complement) and sign_x);

process (final_sign, postround_exponent, postround_significand, 
    positive_sum, preround_overflow, postround_overflow, preround_underflow)
begin
    if positive_sum = x"00000000" then
        s <= final_sign & x"00" & b"000" & x"00000";
        overflow <= '0';
        underflow <= '0';
    else
        s <= final_sign & postround_exponent & postround_significand;
        overflow <= preround_overflow or postround_overflow;
        underflow <= preround_underflow;
    end if;
end process;

end Behavioral;
