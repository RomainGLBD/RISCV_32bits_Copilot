library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mod_8 is
    Port ( CLK : in STD_LOGIC;
           CLK_enable : in STD_LOGIC;
           RST : in STD_LOGIC;
           sortie_anode : out STD_LOGIC_VECTOR (7 downto 0);
           sortie_commande_mux : out STD_LOGIC_VECTOR (1 downto 0));
end mod_8;

architecture Behavioral of mod_8 is

signal compteur : unsigned (2 downto 0) := to_unsigned(0, 3);

begin

process (CLK, RST)
begin
    if (RST = '1') then
        compteur <= to_unsigned(0, 3);
    elsif (CLK='1' and CLK'event) then
        if (CLK_enable='1') then
            if (compteur = to_unsigned(7, 3)) then
                compteur <= to_unsigned(0, 3);
            else
                compteur <= compteur + to_unsigned(1, 3);
            end if;      
       end if;
   end if;
end process;

output: process(compteur)
begin
    sortie_commande_mux <= STD_LOGIC_VECTOR(compteur);
    case (compteur) is
        when "000" =>
            sortie_anode <= "01111111";
        when "001" =>
            sortie_anode <= "10111111";
        when "010" =>
            sortie_anode <= "11011111";
        when "011" =>
            sortie_anode <= "11101111";
        when "100" =>
            sortie_anode <= "11110111";
        when "101" =>
            sortie_anode <= "11111011";
        when "110" =>
            sortie_anode <= "11111101";
        when "111" =>
            sortie_anode <= "11111110";
            
        when others =>
    end case;
end process output;
end Behavioral;
