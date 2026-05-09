library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Memoire_instructions is
        Port ( clk : in STD_LOGIC;
                   addr : in STD_LOGIC_VECTOR(31 downto 0);
                   data_out : out STD_LOGIC_VECTOR(31 downto 0);
                   data_in : in STD_LOGIC_VECTOR(31 downto 0);
                   we : in STD_LOGIC);
end Memoire_instructions;

architecture Behavioral of Memoire_instructions is
        type memory_array is array (0 to 8191) of STD_LOGIC_VECTOR(31 downto 0);
        signal memory : memory_array :=   (
               
                others => (others => '0'));
                
        signal data_out_reg : STD_LOGIC_VECTOR(31 downto 0);
begin
        process(clk)
        begin
                if rising_edge(clk) then
                        if we = '1' then
                                memory(to_integer(unsigned(addr(14 downto 2)))) <= data_in;
                        else
                                data_out_reg <= memory(to_integer(unsigned(addr(14 downto 2))));
                        end if;
                end if;
        end process;

        data_out <= data_out_reg;
end Behavioral;
