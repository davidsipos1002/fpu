library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity edge_detector is
    Port ( clk : in STD_LOGIC;
           input : in STD_LOGIC;
           pulse_falling : out STD_LOGIC;
           pulse_rising : out STD_LOGIC);
end edge_detector;

architecture arch of edge_detector is

signal q0 : std_logic;
signal q1 : std_logic;

begin

process (clk)
begin
    if rising_edge(clk) then
        q1 <= q0;
        q0 <= input;
    end if;
end process;

pulse_falling <= (not q0) and q1;
pulse_rising <= q0 and (not q1);
end arch;
