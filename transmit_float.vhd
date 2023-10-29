library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity transmit_float is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           transmit : in STD_LOGIC;
           data : in STD_LOGIC_VECTOR (39 downto 0);
           tx : out STD_LOGIC;
           ready : out STD_LOGIC);
end transmit_float;

architecture arch of transmit_float is

component tx_fsm is
    Port ( clk : in STD_LOGIC;
           tx_data : in STD_LOGIC_VECTOR (7 downto 0);
           tx_en : in STD_LOGIC;
           rst : in STD_LOGIC;
           baud_en : in STD_LOGIC;
           tx_rdy : out STD_LOGIC;
           tx : out STD_LOGIC);
end component;

component edge_detector is
    Port ( clk : in STD_LOGIC;
           input : in STD_LOGIC;
           pulse_falling : out STD_LOGIC;
           pulse_rising : out STD_LOGIC);
end component;

type state is (st_idle, st_transmit);

signal current_state : state;
signal next_state : state;
signal byte_cnt : std_logic_vector (2 downto 0);
signal tx_en : std_logic;
signal tx_rdy : std_logic;
signal tx_data : std_logic_vector (7 downto 0);
signal tx_rdy_rise : std_logic;
signal baud_cnt : std_logic_vector (15 downto 0);
signal baud_en : std_logic;

begin

process (clk)
begin
    if rising_edge(clk) then
        if baud_cnt /= x"1457" then
            baud_cnt <= baud_cnt + 1;
        else
            baud_cnt <= x"0000";
        end if;
   end if;
end process;

process (baud_cnt)
begin
    if baud_cnt = x"1457" then
        baud_en <= '1';
    else 
        baud_en <= '0';
    end if;
end process;

edgedetect: edge_detector port map(clk => clk, input => tx_rdy, pulse_rising => tx_rdy_rise);

process (clk, rst)
begin
    if rst = '1' then
        current_state <= st_idle;
    elsif rising_edge(clk) then
        current_state <= next_state;
    end if;
end process;

process (data, byte_cnt)
begin
    case byte_cnt is
        when b"000" => tx_data <= data(7 downto 0);
        when b"001" => tx_data <= data(15 downto 8);
        when b"010" => tx_data <= data(23 downto 16);
        when b"011" => tx_data <= data(31 downto 24);
        when b"100" => tx_data <= data(39 downto 32);
        when others => tx_data <= x"00";
    end case;
end process;

process (clk, rst)
begin
    if rising_edge(clk) then
        if current_state = st_transmit then
            if tx_rdy = '1' then
                if byte_cnt < b"101" then
                    tx_en <= '1';
                    ready <= '0';
                else
                    tx_en <= '0';
                    ready <= '1';
                end if;
            end if;
        else
            tx_en <= '0';
            ready <= '0';
        end if;
   end if;
end process;

process (clk, rst)
begin
    if rst = '1' then
        byte_cnt <= b"000";
    elsif rising_edge(clk) then
        if current_state = st_transmit then
            if tx_rdy_rise = '1' then
                byte_cnt <= byte_cnt + 1;
            end if;
        else
            byte_cnt <= b"000";
        end if;
    end if;
end process;

process (current_state, transmit, byte_cnt)
begin
    case current_state is
        when st_idle =>
            if transmit = '1' then
                next_state <= st_transmit;
            else
                next_state <= st_idle;
            end if;
       when st_transmit =>
            if byte_cnt = b"101" then
                next_state <= st_idle;
            else
                next_state <= st_transmit;
            end if;
       when others => next_state <= st_idle;
   end case;
end process;

transmitter: tx_fsm port map(clk, tx_data, tx_en, rst, baud_en, tx_rdy, tx);

end arch;
