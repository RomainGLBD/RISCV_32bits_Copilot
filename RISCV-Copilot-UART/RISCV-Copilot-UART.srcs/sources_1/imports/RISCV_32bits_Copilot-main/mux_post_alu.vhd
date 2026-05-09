library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity mux_post_alu is
    Port ( D : in STD_LOGIC_VECTOR(31 downto 0);
           alu_out : in STD_LOGIC_VECTOR(31 downto 0);
           pc_out : in STD_LOGIC_VECTOR(31 downto 0);
           sel_wb : in STD_LOGIC_VECTOR(1 downto 0);
           WD : out STD_LOGIC_VECTOR(31 downto 0));
end mux_post_alu;

architecture Behavioral of mux_post_alu is
begin
    process(D, alu_out, pc_out, sel_wb)
    begin
        -- This process selects the write data (WD) based on the value of sel_wb.
        -- sel_wb is a 2-bit signal that determines the source of the data to be written.
        -- The selection is as follows:
        -- "00": Write data (WD) is taken from D.
        -- "01": Write data (WD) is taken from alu_out (ALU output).
        -- "10": Write data (WD) is taken from pc_out (Program Counter output).
        -- others: Write data (WD) is set to zero (default case).
        case sel_wb is
            when "00" =>
                WD <= D; 
            when "01" =>
                WD <= alu_out;
            when "10" =>
                WD <= pc_out;
            when others =>
                WD <= (others => '0');
        end case;
    end process;
end Behavioral;
