library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity control_fsm is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           tx : out STD_LOGIC;
           rx : in STD_LOGIC;
           tx_data : in STD_LOGIC_VECTOR (39 downto 0);
           instr_type: out STD_LOGIC_VECTOR (3 downto 0);
           instr_reg0 : out STD_LOGIC_VECTOR (4 downto 0);
           instr_reg1 : out STD_LOGIC_VECTOR (4 downto 0);
           instr_imm : out STD_LOGIC_VECTOR (31 downto 0);
           source: out STD_LOGIC_VECTOR (3 downto 0);
           sub: out STD_LOGIC;
           write : out STD_LOGIC);
end control_fsm;

architecture arch of control_fsm is

component edge_detector is
    Port ( clk : in STD_LOGIC;
           input : in STD_LOGIC;
           pulse_falling : out STD_LOGIC;
           pulse_rising : out STD_LOGIC);
end component;

component receive_instr is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           rx : in STD_LOGIC;
           ready : out STD_LOGIC;
           instr : out STD_LOGIC_VECTOR (47 downto 0));
end component;

component transmit_float is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           transmit : in STD_LOGIC;
           data : in STD_LOGIC_VECTOR (39 downto 0);
           tx : out STD_LOGIC;
           ready : out STD_LOGIC);
end component;

type state is (st_receive, st_decode, st_write, st_fetch, 
    st_tx_begin, st_tx_wait, st_add, st_sub, st_write_sub, st_mul);

signal current_state : state;
signal next_state : state;
signal instruction : std_logic_vector (47 downto 0);
signal rx_rdy : std_logic;
signal rx_rdy_falling : std_logic;
signal tx_en : std_logic;
signal tx_rdy : std_logic;
signal tx_rdy_falling : std_logic;
signal i_type : std_logic_vector (3 downto 0);

begin

edge_detect_rx: edge_detector port map(clk, rx_rdy, rx_rdy_falling);
edge_detect_tx: edge_detector port map(clk, tx_rdy, tx_rdy_falling);
instr_recv: receive_instr port map(clk, rst, rx, rx_rdy, instruction);
tx_float: transmit_float port map(clk, rst, tx_en, tx_data, tx, tx_rdy); 

process (clk, rst)
begin
    if rst = '1' then
        current_state <= st_receive;
    elsif rising_edge(clk) then
        current_state <= next_state;
    end if;
end process;

process (current_state, rx_rdy_falling, tx_rdy_falling, i_type)
begin
    case current_state is
        when st_receive =>
            if rx_rdy_falling = '1' then
                next_state <= st_decode;
            else
                next_state <= st_receive;
            end if;
       when st_decode =>
                if i_type = b"0000" then
                   next_state <= st_write;
                else
                    next_state <= st_fetch;
                end if;
       when st_write =>
            next_state <= st_receive;
       when st_fetch =>
            case i_type is
                when b"0001" =>
                    next_state <= st_tx_begin;
                when b"0010" =>
                    next_state <= st_write;
                when b"0011" =>
                    next_state <= st_add;
                when b"0100" =>
                    next_state <= st_sub;
                when b"0101" =>
                    next_state <= st_mul;
                when others=>
                    next_state <= st_receive;
            end case;
       when st_tx_begin =>
            next_state <= st_tx_wait;
       when st_tx_wait =>
            if tx_rdy_falling = '1' then
                next_state <= st_receive;
            else
                next_state <= st_tx_wait;
            end if;
       when st_add =>
            next_state <= st_write;
       when st_sub =>
            next_state <= st_write_sub;
       when st_write_sub =>
            next_state <= st_receive;
       when st_mul =>
            next_state <= st_write;
       when others =>
            next_state <= st_receive;
    end case;
end process;

with i_type select
     source <= b"0000" when b"0000",
               b"0001" when b"0010",
               b"0010" when b"0011",
               b"0010" when b"0100",
               b"0011" when b"0101",
               b"0000" when others;

process (current_state, i_type)
begin
    case current_state is      
       when st_write =>
            write <= '1';
            tx_en <= '0';
            sub <= '0';
       when st_write_sub =>
            write <= '1';
            tx_en <= '0';
            sub <= '1';
       when st_tx_begin =>
            write <= '0';
            tx_en <= '1';
            sub <= '0';
       when st_add =>
            sub <= '0';
            write <= '0';
            tx_en <= '0';
       when st_sub =>
            write <= '0';
            tx_en <= '0';
            sub <= '1';
       when others => 
            write <= '0';
            tx_en <= '0';
            sub <= '0';
    end case;
end process;

i_type <= instruction(40 downto 37);
instr_type <= i_type;
instr_reg0 <= instruction(36 downto 32);
instr_reg1 <= instruction(4 downto 0);
instr_imm <= instruction(31 downto 0);

end arch;
