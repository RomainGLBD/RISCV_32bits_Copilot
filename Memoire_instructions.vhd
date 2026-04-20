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
        type memory_array is array (0 to 16383) of STD_LOGIC_VECTOR(31 downto 0);
        signal memory : memory_array := (
                            0    => x"000015b7",
                            1    => x"00001617",
                            2    => x"40b60633",
                            3    => x"01460613",
                            4    => x"00060067",
                            5    => x"00300593",
                            6    => x"06400693",
                            7    => x"00008067",

                others => (others => '0'));
                
        signal data_out_reg : STD_LOGIC_VECTOR(31 downto 0);
begin
        process(clk)
        begin
                if rising_edge(clk) then
                        if we = '1' then
                                memory(to_integer(unsigned(addr(15 downto 2)))) <= data_in;
                        else
                                data_out_reg <= memory(to_integer(unsigned(addr(15 downto 2))));
                        end if;
                end if;
        end process;

        data_out <= data_out_reg;
end Behavioral;
