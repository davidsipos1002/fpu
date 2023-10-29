library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity receive_instr is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           rx : in STD_LOGIC;
           ready : out STD_LOGIC;
           instr : out STD_LOGIC_VECTOR (47 downto 0));
end receive_instr;

architecture arch of receive_instr is

component rx_fsm is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           baud_en : in STD_LOGIC;
           rx : in STD_LOGIC;
           rx_rdy : out STD_LOGIC;
           rx_data : out STD_LOGIC_VECTOR (7 downto 0));
end component;

component edge_detector is
    Port ( clk : in STD_LOGIC;
           input : in STD_LOGIC;
           pulse_falling : out STD_LOGIC;
           pulse_rising : out STD_LOGIC);
end component;

type instr_bytes is array(0 to 5) of std_logic_vector (7 downto 0);

signal rx_rdy: std_logic;
signal rx_data : std_logic_vector (7 downto 0);
signal instruction : instr_bytes;
signal byte_en : std_logic;
signal byte_cnt : std_logic_vector (2 downto 0);
signal baud_cnt : std_logic_vector (15 downto 0);
signal baud_en : std_logic;

begin

process (clk)
begin
    if rising_edge(clk) then
        if baud_cnt /= x"0145" then
            baud_cnt <= baud_cnt + 1;
        else
            baud_cnt <= x"0000";
        end if;
   end if;
end process;

process (baud_cnt)
begin
    if baud_cnt = x"0145" then
        baud_en <= '1';
    else 
        baud_en <= '0';
    end if;
end process;

receive: rx_fsm port map(clk, rst, baud_en, rx, rx_rdy, rx_data);

process (clk)
begin
    if rising_edge(clk) then
        if rx_rdy = '1' then
            instruction(conv_integer(byte_cnt)) <= rx_data;
        end if;
    end if;
end process;

edge_detect: edge_detector port map(clk, rx_rdy, byte_en);

process (clk, rst)
begin
    if rst = '1' then
        byte_cnt <= b"000";
        ready <= '0';
    elsif rising_edge(clk) then
        if byte_en = '1' then
            if byte_cnt = b"101" then
                byte_cnt <= b"000";
                ready <= '1';
            else
                byte_cnt <= byte_cnt + 1;
                ready <= '0';
            end if;
        else
            ready <= '0';
        end if;
    end if;
end process;

instr <= instruction(5) & instruction(4) & instruction(3) & 
         instruction(2) & instruction(1) & instruction(0);

end arch;
