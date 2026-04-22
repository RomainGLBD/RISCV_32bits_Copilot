library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity mux_pre_alu is
    Port ( RD2 : in STD_LOGIC_VECTOR(31 downto 0);
           IMM : in STD_LOGIC_VECTOR(31 downto 0);
           sel_op2 : in STD_LOGIC;
           B : out STD_LOGIC_VECTOR(31 downto 0));
end mux_pre_alu;

architecture Behavioral of mux_pre_alu is
begin
    B <= RD2 when sel_op2 = '0' else IMM;
end Behavioral;
