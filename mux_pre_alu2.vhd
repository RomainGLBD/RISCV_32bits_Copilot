library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity mux_pre_alu is
    Port ( D : in STD_LOGIC_VECTOR(31 downto 0);
           alu_out : in STD_LOGIC_VECTOR(31 downto 0);
           pc_out : in STD_LOGIC_VECTOR(31 downto 0);
           sel_wb : in STD_LOGIC_VECTOR(1 downto 0);
           WD : out STD_LOGIC_VECTOR(31 downto 0));
end mux_pre_alu;

architecture Behavioral of mux_pre_alu is
begin
    process(D, alu_out, pc_out, sel_wb)
    begin
        case sel_wb is
            when "00" =>
                WD <= D; // BEGIN: MUX Logic
            when "01" =>
                WD <= alu_out;
            when "10" =>
                WD <= pc_out;
            when others =>
                WD <= (others => '0'); // Default case
        end case; // END: MUX Logic
    end process;
end Behavioral;
