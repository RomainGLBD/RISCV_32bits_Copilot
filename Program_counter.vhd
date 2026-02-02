library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Program_Counter is
        Port ( clk : in STD_LOGIC;
                   reset : in STD_LOGIC;
                   br_adr : in STD_LOGIC_VECTOR (31 downto 0); -- Nouvelle entrée pour les branchements
                   sel_pc : in STD_LOGIC_VECTOR (1 downto 0); -- Signal de sélection pour le multiplexeur
                   pc_out : out STD_LOGIC_VECTOR (31 downto 0));
end Program_Counter;

architecture Behavioral of Program_Counter is
        signal pc : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
        signal next_pc : STD_LOGIC_VECTOR (31 downto 0); -- Signal pour le prochain PC
begin
        process(sel_pc, br_adr, pc)
        begin
                case sel_pc is
                        when "00" =>
                                next_pc <= pc + "00000000000000000000000000000001"; -- Increment PC by 1
                        when "01" =>
                                next_pc <= br_adr; -- Utiliser l'adresse de branchement
                        when others =>
                                next_pc <= pc; -- Valeur par défaut
                end case;
        end process;

        process(clk, reset)
        begin
                if reset = '1' then
                        pc <= (others => '0');
                elsif rising_edge(clk) then
                        pc <= next_pc; -- Mettre à jour le PC
                end if;
        end process;

        pc_out <= pc;
end Behavioral;
