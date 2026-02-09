library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity add_four is
    Port ( pc_out : in STD_LOGIC_VECTOR(31 downto 0);
           pc_plus4 : out STD_LOGIC_VECTOR(31 downto 0));
end add_four;

architecture Behavioral of add_four is
begin
    process(pc_out)
    begin
        pc_plus4 <= pc_out + "00000000000000000000000000000100"; -- Ajoute 4
    end process;
end Behavioral;
