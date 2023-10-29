library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity register_file is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           addr0 : in STD_LOGIC_VECTOR (4 downto 0);
           addr1 : in STD_LOGIC_VECTOR (4 downto 0);
           insp_addr : in STD_LOGIC_VECTOR (4 downto 0);
           write : in STD_LOGIC;
           data : in STD_LOGIC_VECTOR (39 downto 0);
           reg0 : out STD_LOGIC_VECTOR (39 downto 0);
           reg1 : out STD_LOGIC_VECTOR (39 downto 0);
           insp_reg : out STD_LOGIC_VECTOR (39 downto 0));
end register_file;

architecture arch of register_file is

type registers is array(0 to 31) of std_logic_vector (39 downto 0);

signal reg_file : registers;

begin

process (clk)
begin
    if rising_edge(clk) then
        if reset = '1' then
            for i in 0 to 31 loop
                reg_file(conv_integer(i)) <= x"0000000000";
            end loop;
        elsif write = '1' then
            reg_file(conv_integer(addr0)) <= data;
        end if;
    end if;
end process;

reg0 <= reg_file(conv_integer(addr0));
reg1 <= reg_file(conv_integer(addr1));
insp_reg <= reg_file(conv_integer(insp_addr));

end arch;
