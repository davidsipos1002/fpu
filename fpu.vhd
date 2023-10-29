library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity fpu is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0);
           dp : out STD_LOGIC;
           tx : out STD_LOGIC;
           rx : in STD_LOGIC);
end fpu;

architecture arch of fpu is

component mono_pulse is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           en : out STD_LOGIC_VECTOR (4 downto 0));
end component;

component register_file is
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
end component;

component fp_adder is
    Port ( x : in STD_LOGIC_VECTOR (31 downto 0);
           y : in STD_LOGIC_VECTOR (31 downto 0);
           sub : in STD_LOGIC;
           overflow : out STD_LOGIC;
           underflow : out STD_LOGIC;
           s : out STD_LOGIC_VECTOR (31 downto 0));
end component;

component fp_mul is
    Port ( x : in STD_LOGIC_VECTOR (31 downto 0);
           y : in STD_LOGIC_VECTOR (31 downto 0);
           p : out STD_LOGIC_VECTOR (31 downto 0);
           overflow : out STD_LOGIC;
           underflow : out STD_LOGIC);
end component;

component control_fsm is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           tx : out STD_LOGIC;
           rx : in STD_LOGIC;
           tx_data : in STD_LOGIC_VECTOR (39 downto 0);
           instr_type: out STD_LOGIC_VECTOR (3 downto 0);
           instr_reg0 : out STD_LOGIC_VECTOR (4 downto 0);
           instr_reg1 : out STD_LOGIC_VECTOR (4 downto 0);
           instr_imm : out STD_LOGIC_VECTOR (31 downto 0);
           source : out STD_LOGIC_VECTOR (3 downto 0);
           sub : out STD_LOGIC;
           write : out STD_LOGIC);
end component;

component seven_seg is  
    Port ( clk : in STD_LOGIC;
           data : in STD_LOGIC_VECTOR(31 downto 0);
           an : out STD_LOGIC_VECTOR(7 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0));
end component;

signal btn_enable : std_logic_vector (4 downto 0);
signal reset : std_logic;
signal ssd : std_logic_vector (31 downto 0);
signal instr_type : std_logic_vector (3 downto 0);
signal instr_reg0 : std_logic_vector (4 downto 0);
signal instr_reg1 : std_logic_vector (4 downto 0);
signal instr_imm : std_logic_vector (31 downto 0);
signal register_contents0 : std_logic_vector (39 downto 0);
signal register_contents1 : std_logic_vector (39 downto 0);
signal register_inspect : std_logic_vector (39 downto 0);
signal register_source : std_logic_vector (3 downto 0);
signal register_write : std_logic;
signal register_data : std_logic_vector (39 downto 0);
signal adder_sub : std_logic;
signal adder_sum : std_logic_vector (31 downto 0);
signal product : std_logic_vector (31 downto 0);
signal overflow_add : std_logic;
signal underflow_add : std_logic;
signal overflow_mul : std_logic;
signal underflow_mul : std_logic;
signal div_clk : std_logic;

begin

process (clk)
begin
    if rising_edge(clk) then
        div_clk <= not div_clk;
    end if;
end process;

debounce: mono_pulse port map(div_clk, btn, btn_enable);
reset <= btn_enable(0);

with register_source select
    register_data <= register_contents1 when b"0001",
                     b"000000" & overflow_add & underflow_add & adder_sum when b"0010",
                     b"000000" & overflow_mul & underflow_mul & product when b"0011",
                     x"00" & instr_imm when others;

registers: register_file port map(div_clk, reset, instr_reg0, instr_reg1, sw(4 downto 0),
    register_write, register_data, register_contents0, register_contents1,
    register_inspect);

adder: fp_adder port map(x => register_contents0(31 downto 0), y => register_contents1(31 downto 0), 
    sub => adder_sub, overflow => overflow_add, underflow => underflow_add, s => adder_sum);

mul: fp_mul port map(x => register_contents0(31 downto 0), y => register_contents1(31 downto 0), 
    p => product, overflow => overflow_mul, underflow => underflow_mul);

control: control_fsm port map(div_clk, reset, tx, rx, register_contents0,
    instr_type, instr_reg0, instr_reg1, instr_imm, register_source, adder_sub, register_write);

ssd <= register_inspect(31 downto 0);
seven: seven_seg port map(clk, ssd, an, cat);
led <= x"00"  & register_inspect(39 downto 32);
dp <= '1';

end arch;
