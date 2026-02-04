library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Programm_Counter is
        Port ( clk : in STD_LOGIC;
                   reset : in STD_LOGIC;
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
                        pc <= pc + "00000000000000000000000000000100"; -- Increment PC by 4
                end if;
        end process;

        pc_out <= pc;
end Behavioral;
