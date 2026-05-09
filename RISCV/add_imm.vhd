library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity add_imm is
        Port ( 
                IMM : in STD_LOGIC_VECTOR(31 downto 0);
                pc_out : in STD_LOGIC_VECTOR(31 downto 0);
                br_jal_adr : out STD_LOGIC_VECTOR(31 downto 0)
        );
end add_imm;

architecture Behavioral of add_imm is
begin
        br_jal_adr <= std_logic_vector(unsigned(IMM) + unsigned(pc_out));
end Behavioral;
