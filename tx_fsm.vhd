library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity tx_fsm is
    Port ( clk : in STD_LOGIC;
           tx_data : in STD_LOGIC_VECTOR (7 downto 0);
           tx_en : in STD_LOGIC;
           rst : in STD_LOGIC;
           baud_en : in STD_LOGIC;
           tx_rdy : out STD_LOGIC;
           tx : out STD_LOGIC);
end tx_fsm;

architecture arch of tx_fsm is

type state is (st_idle, st_start, st_bit, st_stop);

signal bit_count : std_logic_vector (2 downto 0);
signal current_state : state;
signal next_state : state;

begin

process (clk, rst)
begin
    if rst = '1' then
        current_state <= st_idle;
    elsif rising_edge(clk) then
        if baud_en = '1' then
            current_state <= next_state;
        end if;
    end if;
end process;

process (clk, rst)
begin
    if rst = '1' then
        bit_count <= b"000";
    elsif rising_edge(clk) then
        if baud_en = '1' then
            if current_state = st_bit then
                bit_count <= bit_count + 1;
            end if;
        end if;
    end if;
end process;

process (current_state, tx_en, bit_count)
begin
    case current_state is
        when st_idle =>
            if tx_en = '1' then
                next_state <= st_start;
            else
                next_state <= st_idle;
            end if;
        when st_start =>
            next_state <= st_bit;
        when st_bit =>
            if bit_count = b"111" then
                next_state <= st_stop;
            else
                next_state <= st_bit;
            end if;
        when st_stop =>
            next_state <= st_idle;
        when others =>
            next_state <= st_idle;       
    end case;
end process;

process (current_state, tx_data, bit_count)
begin
    case current_state is
        when st_idle =>
            tx <= '1';
            tx_rdy <= '1';
        when st_start =>
            tx <= '0';
            tx_rdy <= '0';
        when st_bit =>
            tx <= tx_data(conv_integer(bit_count));
            tx_rdy <= '0';
        when st_stop =>
            tx <= '1';
            tx_rdy <= '0';
        when others =>
            tx <= '1';
            tx_rdy <= '1';
    end case;
end process;

end arch;
