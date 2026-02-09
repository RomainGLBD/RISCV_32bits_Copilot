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
    process(RD2, IMM, sel_op2)
    begin
        // BEGIN: Multiplexeur logique
        -- This conditional statement checks the value of the selection signal 'sel_op2'.
        -- If 'sel_op2' is equal to '0', the corresponding operation or data path will be executed.
        if sel_op2 = '0' then
            B <= RD2;
        else
            B <= IMM;
        // END: Multiplexeur logique
        end if;
    end process;
end Behavioral;
