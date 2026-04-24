library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Decode is
	Port (
		opcode          : in  STD_LOGIC_VECTOR(6 downto 0);
		func3           : in  STD_LOGIC_VECTOR(2 downto 0);
		func7           : in  STD_LOGIC_VECTOR(6 downto 0);
		addr_lsb        : in  STD_LOGIC_VECTOR(1 downto 0);
		sel_fnct_alu    : out STD_LOGIC_VECTOR(3 downto 0);
		sel_fnct_br_alu : out STD_LOGIC_VECTOR(2 downto 0);
		dmem_wmask      : out STD_LOGIC_VECTOR(3 downto 0);
		load_sel        : out STD_LOGIC_VECTOR(2 downto 0);
		load_mask       : out STD_LOGIC_VECTOR(3 downto 0)
	);
end Decode;

architecture Behavioral of Decode is
begin
	process(opcode, func3, func7, addr_lsb)
	begin
		-- Defaults
		sel_fnct_alu    <= "0010"; -- ADD
		sel_fnct_br_alu <= "000"; -- BEQ (unused when not branching)
		dmem_wmask      <= "0000";
		load_sel        <= "000"; -- LW / no byte or halfword extraction
		load_mask       <= "1111"; -- LW default

		case opcode is
			-- R-type
			when "0110011" =>
				case func3 is
					when "000" =>
						if func7 = "0100000" then
							sel_fnct_alu <= "0110"; -- SUB
						else
							sel_fnct_alu <= "0010"; -- ADD
						end if;
					when "111" => sel_fnct_alu <= "0000"; -- AND
					when "110" => sel_fnct_alu <= "0001"; -- OR
					when "100" => sel_fnct_alu <= "0011"; -- XOR
					when "001" => sel_fnct_alu <= "0100"; -- SLL
					when "101" =>
						if func7 = "0100000" then
							sel_fnct_alu <= "1001"; -- SRA
						else
							sel_fnct_alu <= "0101"; -- SRL
						end if;
					when "010" => sel_fnct_alu <= "0111"; -- SLT
					when "011" => sel_fnct_alu <= "1000"; -- SLTU
					when others => sel_fnct_alu <= "0010";
				end case;

			-- I-type arithmetic
			when "0010011" =>
				case func3 is
					when "000" => sel_fnct_alu <= "0010"; -- ADDI
					when "111" => sel_fnct_alu <= "0000"; -- ANDI
					when "110" => sel_fnct_alu <= "0001"; -- ORI
					when "100" => sel_fnct_alu <= "0011"; -- XORI
					when "001" => sel_fnct_alu <= "0100"; -- SLLI
					when "101" =>
						if func7 = "0100000" then
							sel_fnct_alu <= "1001"; -- SRAI
						else
							sel_fnct_alu <= "0101"; -- SRLI
						end if;
					when "010" => sel_fnct_alu <= "0111"; -- SLTI
					when "011" => sel_fnct_alu <= "1000"; -- SLTIU
					when others => sel_fnct_alu <= "0010";
				end case; 

			-- Loads use base+imm address calculation in ALU (ADD)
			when "0000011" =>
				sel_fnct_alu <= "0010";
				case func3 is
					when "000" =>
						load_sel  <= "001"; -- LB
						case addr_lsb is
							when "00" => load_mask <= "0001";
							when "01" => load_mask <= "0010";
							when "10" => load_mask <= "0100";
							when others => load_mask <= "1000";
						end case;
					when "001" =>
						load_sel <= "010"; -- LH
						if addr_lsb(1) = '0' then
							load_mask <= "0011";
						else
							load_mask <= "1100";
						end if;
					when "100" =>
						load_sel  <= "011"; -- LBU
						case addr_lsb is
							when "00" => load_mask <= "0001";
							when "01" => load_mask <= "0010";
							when "10" => load_mask <= "0100";
							when others => load_mask <= "1000";
						end case;
					when "101" =>
						load_sel <= "100"; -- LHU
						if addr_lsb(1) = '0' then
							load_mask <= "0011";
						else
							load_mask <= "1100";
						end if;
					when others =>
						load_sel  <= "000"; -- LW (and default fall-back)
						load_mask <= "1111";
				end case;

			-- S-type (stores) use ADD
			when "0100011" =>
				sel_fnct_alu <= "0010";
				case func3 is
					when "000" => -- SB
						case addr_lsb is
							when "00" => dmem_wmask <= "0001";
							when "01" => dmem_wmask <= "0010";
							when "10" => dmem_wmask <= "0100";
							when others => dmem_wmask <= "1000";
						end case;
					when "001" => -- SH
						if addr_lsb(1) = '0' then
							dmem_wmask <= "0011";
						else
							dmem_wmask <= "1100";
						end if;
					when "010" => -- SW
						dmem_wmask <= "1111";
					when others =>
						dmem_wmask <= "0000";
				end case;

			-- AUIPC / LUI / JAL / JALR use ADD
			when "0010111" | "0110111" | "1101111" | "1100111" =>
				sel_fnct_alu <= "0010";

			-- Branches
			when "1100011" =>
				case func3 is
					when "000" => sel_fnct_br_alu <= "000"; -- BEQ
					when "001" => sel_fnct_br_alu <= "001"; -- BNE
					when "100" => sel_fnct_br_alu <= "100"; -- BLT
					when "101" => sel_fnct_br_alu <= "101"; -- BGE
					when "110" => sel_fnct_br_alu <= "110"; -- BLTU
					when "111" => sel_fnct_br_alu <= "111"; -- BGEU
					when others => sel_fnct_br_alu <= "000";
				end case;

			when others =>
				sel_fnct_alu    <= "0010";
				sel_fnct_br_alu <= "000";
		end case;
	end process;
end Behavioral;
