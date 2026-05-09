library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU_32_bits is
    Port (
        A           : in  std_logic_vector(31 downto 0);
        B           : in  std_logic_vector(31 downto 0);
        ALUCtrl     : in  std_logic_vector(3 downto 0);
        BranchType  : in  std_logic_vector(2 downto 0); -- 3 bits for branch type
        Result      : out std_logic_vector(31 downto 0);
        branchement : out std_logic
    );
end ALU_32_bits;

architecture Behavioral of ALU_32_bits is
begin
    process(A, B, ALUCtrl, BranchType)
        variable res : std_logic_vector(31 downto 0);
        variable branch_cond : std_logic := '0';
    begin
        -- ALU operations
        case ALUCtrl is
            when "0000" => res := A and B;
            when "0001" => res := A or B;
            when "0010" => res := std_logic_vector(signed(A) + signed(B));
            when "0110" => res := std_logic_vector(signed(A) - signed(B));
            when "0011" => res := A xor B;
            when "0100" => res := std_logic_vector(shift_left(unsigned(A), to_integer(unsigned(B(4 downto 0)))));
            when "0101" => res := std_logic_vector(shift_right(unsigned(A), to_integer(unsigned(B(4 downto 0)))));
            when "0111" => -- SLT
                if (signed(A) < signed(B)) then
                    res := (others => '0'); res(0) := '1';
                else
                    res := (others => '0');
                end if;
            when "1000" => -- SLTU
                if (unsigned(A) < unsigned(B)) then
                    res := (others => '0'); res(0) := '1';
                else
                    res := (others => '0');
                end if;
            when "1001" => -- SRA
                res := std_logic_vector(shift_right(signed(A), to_integer(unsigned(B(4 downto 0)))));
            when others => res := (others => '0');
        end case;
        Result <= res;

        -- Branch conditions
        case BranchType is
            when "000" => -- BEQ
                if A = B then branch_cond := '1'; else branch_cond := '0'; end if;
            when "001" => -- BNE
                if A /= B then branch_cond := '1'; else branch_cond := '0'; end if;
            when "100" => -- BLT
                if signed(A) < signed(B) then branch_cond := '1'; else branch_cond := '0'; end if;
            when "101" => -- BGE
                if signed(A) >= signed(B) then branch_cond := '1'; else branch_cond := '0'; end if;
            when "110" => -- BLTU
                if unsigned(A) < unsigned(B) then branch_cond := '1'; else branch_cond := '0'; end if;
            when "111" => -- BGEU
                if unsigned(A) >= unsigned(B) then branch_cond := '1'; else branch_cond := '0'; end if;
            when others =>
                branch_cond := '0';
        end case;
        branchement <= branch_cond;
    end process;
end Behavioral;