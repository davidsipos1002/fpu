library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity rx_fsm is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           baud_en : in STD_LOGIC;
           rx : in STD_LOGIC;
           rx_rdy : out STD_LOGIC;
           rx_data : out STD_LOGIC_VECTOR (7 downto 0));
end rx_fsm;

architecture arch of rx_fsm is

type state is (st_idle, st_start, st_bit, st_stop, st_wait);

signal current_state : state;
signal next_state : state;
signal baud_cnt : std_logic_vector (3 downto 0);
signal bit_count : std_logic_vector (3 downto 0);

begin

process (clk, rst)
begin
    if rst = '1' then
        baud_cnt <= x"0";
        bit_count <= x"0";
    elsif rising_edge(clk) then
        if baud_en = '1' then
            if current_state = st_idle then
                bit_count <= x"0";
            elsif (current_state = st_bit) and (baud_cnt = x"7") then
                bit_count <= bit_count + 1;
            end if;
            
            if current_state = st_idle then
                baud_cnt <= x"0";
            else
                baud_cnt <= baud_cnt + 1;
            end if;
        end if;
    end if;
end process;

process (clk, rst)
begin
    if rst = '1' then
        rx_data <= x"00";
    elsif rising_edge(clk) then
        if (current_state = st_bit) and (baud_en = '1') and (baud_cnt = x"7") then
            rx_data(conv_integer(bit_count(2 downto 0))) <= rx;
        end if;
    end if;
end process;

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

process (current_state, rx, baud_cnt, bit_count)
begin
    case current_state is
        when st_idle =>
            if rx = '0' then
                next_state <= st_start;
            else
                next_state <= st_idle;
            end if;
        when st_start =>
            if rx = '1' then
                next_state <= st_idle;
            else
                if baud_cnt = x"7" then
                    next_state <= st_bit;
                else
                    next_state <= st_start;
                end if;
            end if;
       when st_bit =>
            if bit_count < x"8" then
                next_state <= st_bit;
            elsif (bit_count = x"8") and (baud_cnt < x"F") then
                next_state <= st_bit;
            elsif (bit_count = x"8") and (baud_cnt = x"F") then
                next_state <= st_stop;
            else
                next_state <= st_stop;
            end if;
      when st_stop =>
            if baud_cnt < x"F" then
                next_state <= st_stop;
            else
                next_state <= st_wait;
            end if; 
      when st_wait =>
            if baud_cnt < x"7" then
                next_state <= st_wait;
            else
                next_state <= st_idle;
            end if;
      when others =>
            next_state <= st_idle;
    end case;
end process;

process (current_state)
begin
    case current_state is
        when st_wait =>
            rx_rdy <= '1';
        when others =>
            rx_rdy <= '0';
    end case; 
end process;

end arch;
