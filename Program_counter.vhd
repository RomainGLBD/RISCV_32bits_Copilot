library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Programm_Counter is
        Port ( clk : in STD_LOGIC;
                   reset : in STD_LOGIC;
                   mux_out : in STD_LOGIC_VECTOR (31 downto 0); -- NEW: Input from the multiplexer for branching
                   pc_out : out STD_LOGIC_VECTOR (31 downto 0));
end Programm_Counter;

architecture Behavioral of Programm_Counter is
        signal pc : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
begin
        process(clk, reset)
        begin
                if reset = '1' then
                        pc <= (others => '0');
                elsif rising_edge(clk) then
                        pc <= mux_out ; 
                end if;
        end process;

        pc_out <= pc;
end Behavioral;
