library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Memoire_instructions is
        Port ( clk : in STD_LOGIC;
                   addr : in STD_LOGIC_VECTOR(31 downto 0);
                   data_out : out STD_LOGIC_VECTOR(31 downto 0);
                   data_in : in STD_LOGIC_VECTOR(31 downto 0); // BEGIN: New data input
                   we : in STD_LOGIC);
end Memoire_instructions;

architecture Behavioral of Memoire_instructions is
        type memory_array is array (0 to 1023) of STD_LOGIC_VECTOR(31 downto 0);
        signal memory : memory_array := (others => (others => '0'));
begin
        process(clk)
        begin
                if rising_edge(clk) then
                        if we = '1' then
                                memory(to_integer(unsigned(addr(11 downto 2)))) <= data_in; // BEGIN: Write operation
                        end if;
                end if;
        end process;

        -- BEGIN: Combinatorial read operation
        data_out <= memory(to_integer(unsigned(addr(11 downto 2)))); // END: Combinatorial read operation
end Behavioral;
