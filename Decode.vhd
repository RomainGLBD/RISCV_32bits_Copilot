library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Decode is
	Port (
		opcode          : in  STD_LOGIC_VECTOR(6 downto 0);
		func3           : in  STD_LOGIC_VECTOR(2 downto 0);
		func7           : in  STD_LOGIC_VECTOR(6 downto 0);
		sel_fnct_alu    : out STD_LOGIC_VECTOR(3 downto 0);
		sel_fnct_br_alu : out STD_LOGIC_VECTOR(2 downto 0)
	);
end Decode;

architecture Behavioral of Decode is
begin
	process(opcode, func3, func7)
		variable alu_sel : STD_LOGIC_VECTOR(3 downto 0);
		variable br_sel  : STD_LOGIC_VECTOR(2 downto 0);
	begin
		-- Defaults
		alu_sel := "0010"; -- ADD
		br_sel  := "000"; -- BEQ (unused when not branching)

		case opcode is
			-- R-type
			when "0110011" =>
				case func3 is
					when "000" =>
						if func7 = "0100000" then
							alu_sel := "0110"; -- SUB
						else
							alu_sel := "0010"; -- ADD
						end if;
					when "111" => alu_sel := "0000"; -- AND
					when "110" => alu_sel := "0001"; -- OR
					when "100" => alu_sel := "0011"; -- XOR
					when "001" => alu_sel := "0100"; -- SLL
					when "101" =>
						if func7 = "0100000" then
							alu_sel := "1001"; -- SRA
						else
							alu_sel := "0101"; -- SRL
						end if;
					when "010" => alu_sel := "0111"; -- SLT
					when "011" => alu_sel := "1000"; -- SLTU
					when others => alu_sel := "0010";
				end case;

			-- I-type arithmetic
			when "0010011" =>
				case func3 is
					when "000" => alu_sel := "0010"; -- ADDI
					when "111" => alu_sel := "0000"; -- ANDI
					when "110" => alu_sel := "0001"; -- ORI
					when "100" => alu_sel := "0011"; -- XORI
					when "001" => alu_sel := "0100"; -- SLLI
					when "101" =>
						if func7 = "0100000" then
							alu_sel := "1001"; -- SRAI
						else
							alu_sel := "0101"; -- SRLI
						end if;
					when "010" => alu_sel := "0111"; -- SLTI
					when "011" => alu_sel := "1000"; -- SLTIU
					when others => alu_sel := "0010";
				end case; 

			-- Loads: distinguish LB/LH/LW
			when "0000011" =>
				case func3 is
					when "000" => alu_sel := "1010"; -- LB
					when "001" => alu_sel := "1011"; -- LH
					when "010" => alu_sel := "1100"; -- LW
					when others => alu_sel := "0010"; -- default ADD
				end case;

			-- S-type (stores) use ADD
			when "0100011" =>
				alu_sel := "0010";

			-- AUIPC / LUI / JAL / JALR use ADD
			when "0010111" | "0110111" | "1101111" | "1100111" =>
				alu_sel := "0010";

			-- Branches
			when "1100011" =>
				case func3 is
					when "000" => br_sel := "000"; -- BEQ
					when "001" => br_sel := "001"; -- BNE
					when "100" => br_sel := "100"; -- BLT
					when "101" => br_sel := "101"; -- BGE
					when "110" => br_sel := "110"; -- BLTU
					when "111" => br_sel := "111"; -- BGEU
					when others => br_sel := "000";
				end case;

			when others =>
				alu_sel := "0010";
				br_sel  := "000";
		end case;

		sel_fnct_alu    <= alu_sel;
		sel_fnct_br_alu <= br_sel;
	end process;
end Behavioral;
