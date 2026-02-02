library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Memoire_data is
        Port ( clk : in STD_LOGIC;
                   we : in STD_LOGIC; -- Write enable
                   addr : in STD_LOGIC_VECTOR (31 downto 0); -- Address
                   data_in : in STD_LOGIC_VECTOR (31 downto 0); -- Data input
                   data_out : out STD_LOGIC_VECTOR (31 downto 0) -- Data output
                 );
end Memoire_data;

architecture Behavioral of Memoire_data is
        type memory_array is array (0 to 1023) of STD_LOGIC_VECTOR(31 downto 0);
        signal memory : memory_array := (others => (others => '0'));
begin

        process(clk)
        begin
                if falling_edge(clk) then 
                        if we = '1' then
                                memory(to_integer(unsigned(addr(11 downto 2)))) <= data_in;
                        end if;
                end if;
                
                if rising_edge(clk) then 
                        data_out <= memory(to_integer(unsigned(addr(11 downto 2))));
                end if;
        end process;

end Behavioral;
