library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity mux_pc is
        Port ( 
                jalr_adr : in STD_LOGIC_VECTOR(31 downto 0);
                jr_jal_adr : in STD_LOGIC_VECTOR(31 downto 0);
                br_jal_adr : in STD_LOGIC_VECTOR(31 downto 0);
                pc_plus4 : in STD_LOGIC_VECTOR(31 downto 0);
                sel_pc : in STD_LOGIC_VECTOR(1 downto 0);
                mux_out : out STD_LOGIC_VECTOR(31 downto 0)
        );
end mux_pc;

architecture Behavioral of mux_pc is
begin
        process(jalr_adr, jr_jal_adr, br_jal_adr, pc_plus4, sel_pc)
        begin
                case sel_pc is
                        when "00" =>
                                mux_out <= jalr_adr;
                        when "01" =>
                                mux_out <= jr_jal_adr;
                        when "10" =>
                                mux_out <= br_jal_adr;
                        when "11" =>
                                mux_out <= pc_plus4;
                        when others =>
                                mux_out <= (others => '0'); -- Valeur par défaut
                end case;
        end process;
end Behavioral;
