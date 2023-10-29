library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity mono_pulse is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           en : out STD_LOGIC_VECTOR (4 downto 0));
end mono_pulse;

architecture arch of mono_pulse is

signal enable : std_logic;
signal cnt : std_logic_vector (15 downto 0);
signal q1 : std_logic_vector (4 downto 0);
signal q2 : std_logic_vector (4 downto 0);
signal q3 : std_logic_vector (4 downto 0);

begin

process (cnt)
begin
    if cnt = x"7FFF" then
        enable <= '1';
    else
        enable <= '0';
    end if;
end process;

process (clk)
begin
    if rising_edge(clk) then
        cnt <= cnt + 1;
     end if;
end process;

process (clk)
begin
    if rising_edge(clk) then
        if enable = '1' then
            q1 <= btn;
        end if;
   end if;
end process;

process (clk)
begin
    if rising_edge(clk) then
        q2 <= q1;
        q3 <= q2;
    end if;
end process;

en <= q2 and (not q3);
end arch;
