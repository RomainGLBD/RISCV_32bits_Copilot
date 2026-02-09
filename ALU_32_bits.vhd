library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ALU_32_bits is
        Port ( A       : in  STD_LOGIC_VECTOR (31 downto 0);
                   B       : in  STD_LOGIC_VECTOR (31 downto 0);
                   ALUOp   : in  STD_LOGIC_VECTOR (3 downto 0);
                   Result   : out STD_LOGIC_VECTOR (31 downto 0);
                   Zero     : out STD_LOGIC);
end ALU_32_bits;

architecture Behavioral of ALU_32_bits is
begin
        process(A, B, ALUOp)
        begin
                case ALUOp is
                        when "0000" => Result <= A and B;  -- AND
                        when "0001" => Result <= A or B;   -- OR
                        when "0010" => Result <= A xor B;  -- XOR
                        when "0011" => Result <= A + B;     -- ADD
                        when "0100" => Result <= A - B;     -- SUB
                        when "0101" => Result <= A sll 1;   -- SLL
                        when "0110" => Result <= A srl 1;   -- SRL
                        when "0111" => Result <= A sra 1;   -- SRA
                        when others => Result <= (others => '0'); -- Default case
                end case;

                -- Set Zero flag
                if Result = (others => '0') then
                        Zero <= '1';
                else
                        Zero <= '0';
                end if;
        end process;
end Behavioral;
