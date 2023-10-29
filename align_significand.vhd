library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity align_significand is
    Port ( sig_in : in STD_LOGIC_VECTOR (31 downto 0);
           zero : in STD_LOGIC;
           sa : in STD_LOGIC_VECTOR (4 downto 0);
           sig_out : out STD_LOGIC_VECTOR (31 downto 0);
           g : out STD_LOGIC;
           r : out STD_LOGIC;
           s : out STD_LOGIC);
end align_significand;

architecture arch of align_significand is

component barrel_shifter_right is
    Port ( x : in STD_LOGIC_VECTOR (31 downto 0);
           sa : in STD_LOGIC_VECTOR (4 downto 0);
           o : out STD_LOGIC_VECTOR (31 downto 0));
end component;

signal shifted : std_logic_vector (31 downto 0);
signal guard : std_logic;
signal round : std_logic;
signal mask : std_logic_vector (23 downto 0);
signal sticky_bits : std_logic_vector (23 downto 0);
signal sticky : std_logic;

begin

shift: barrel_shifter_right port map(sig_in, sa, shifted);

with sa select
guard <= '0' when b"00000",
        sig_in(0) when b"00001",
        sig_in(1) when b"00010",
        sig_in(2) when b"00011",
        sig_in(3) when b"00100",
        sig_in(4) when b"00101",
        sig_in(5) when b"00110",
        sig_in(6) when b"00111",
        sig_in(7) when b"01000",
        sig_in(8) when b"01001",
        sig_in(9) when b"01010",
        sig_in(10) when b"01011",
        sig_in(11) when b"01100",
        sig_in(12) when b"01101",
        sig_in(13) when b"01110",
        sig_in(14) when b"01111",
        sig_in(15) when b"10000",
        sig_in(16) when b"10001",
        sig_in(17) when b"10010",
        sig_in(18) when b"10011",
        sig_in(19) when b"10100",
        sig_in(20) when b"10101",
        sig_in(21) when b"10110",
        sig_in(22) when b"10111",
        '0' when others;

with sa select
round <= '0' when b"00000",
        '0' when b"00001",
        sig_in(0) when b"00010",
        sig_in(1) when b"00011",
        sig_in(2) when b"00100",
        sig_in(3) when b"00101",
        sig_in(4) when b"00110",
        sig_in(5) when b"00111",
        sig_in(6) when b"01000",
        sig_in(7) when b"01001",
        sig_in(8) when b"01010",
        sig_in(9) when b"01011",
        sig_in(10) when b"01100",
        sig_in(11) when b"01101",
        sig_in(12) when b"01110",
        sig_in(13) when b"01111",
        sig_in(14) when b"10000",
        sig_in(15) when b"10001",
        sig_in(16) when b"10010",
        sig_in(17) when b"10011",
        sig_in(18) when b"10100",
        sig_in(19) when b"10101",
        sig_in(20) when b"10110",
        sig_in(21) when b"10111",
        '0' when others;

with sa select
mask <= x"000000" when b"00000",
      x"000000" when b"00001",
      x"000000" when b"00010",
      x"000001" when b"00011",
      x"000003" when b"00100",
      x"000007" when b"00101",
      x"00000f" when b"00110",
      x"00001f" when b"00111",
      x"00003f" when b"01000",
      x"00007f" when b"01001",
      x"0000ff" when b"01010",
      x"0001ff" when b"01011",
      x"0003ff" when b"01100",
      x"0007ff" when b"01101",
      x"000fff" when b"01110",
      x"001fff" when b"01111",
      x"003fff" when b"10000",
      x"007fff" when b"10001",
      x"00ffff" when b"10010",
      x"01ffff" when b"10011",
      x"03ffff" when b"10100",
      x"07ffff" when b"10101",
      x"0fffff" when b"10110",
      x"1fffff" when b"10111",
      x"000000" when others;
      
sticky_bits <= sig_in(23 downto 0) and mask;

with zero select
    sig_out <= shifted when '0',
               x"00000000" when others;

with zero select
    g <= guard when '0',
         '0' when others;

with zero select
    r <= round when '0',
         '0' when others;

with zero select 
    s <= sticky_bits(23) or sticky_bits(22) or 
         sticky_bits(21) or sticky_bits(20) or 
         sticky_bits(19) or sticky_bits(18) or 
         sticky_bits(17) or sticky_bits(16) or 
         sticky_bits(15) or sticky_bits(14) or 
         sticky_bits(13) or sticky_bits(12) or 
         sticky_bits(11) or sticky_bits(10) or 
         sticky_bits(9) or sticky_bits(8) or 
         sticky_bits(7) or sticky_bits(6) or 
         sticky_bits(5) or sticky_bits(4) or 
         sticky_bits(3) or sticky_bits(2) or 
         sticky_bits(1) or sticky_bits(0) when '0',
         '0' when others;
         
end arch;
