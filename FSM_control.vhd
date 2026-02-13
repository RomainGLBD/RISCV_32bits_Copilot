library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FSM_control is
        Port (
                clk : in STD_LOGIC;
                reset : in STD_LOGIC;
                instruction : in STD_LOGIC_VECTOR(31 downto 0);
                branch_control : in STD_LOGIC;
                sel_pc : out STD_LOGIC_VECTOR(1 downto 0);
                rf_wen : out STD_LOGIC;
                type_imm : out STD_LOGIC_VECTOR(2 downto 0);
                sel_wb : out STD_LOGIC_VECTOR(1 downto 0);
                sel_op2 : out STD_LOGIC;
                dmem_wen : out STD_LOGIC;
                opcode_out : out STD_LOGIC_VECTOR(6 downto 0);
                func3_out : out STD_LOGIC_VECTOR(2 downto 0);
                func7_out : out STD_LOGIC_VECTOR(6 downto 0)
        );
end FSM_control;

architecture Behavioral of FSM_control is
        type state_type is (IDLE, FETCH, DECODE, EXECUTE, MEMORY, WRITEBACK);
        signal current_state, next_state: state_type;
        signal opcode : STD_LOGIC_VECTOR(6 downto 0);
        signal func3 : STD_LOGIC_VECTOR(2 downto 0);
        signal func7 : STD_LOGIC_VECTOR(6 downto 0);
begin

        opcode <= instruction(6 downto 0);
        func3 <= instruction(14 downto 12);
        func7 <= instruction(31 downto 25);

        opcode_out <= opcode;
        func3_out <= func3;
        func7_out <= func7;

        process(clk, reset)
        begin
                if reset = '1' then
                        current_state <= IDLE;
                elsif rising_edge(clk) then
                        current_state <= next_state;
                end if;
        end process;

        process(current_state, opcode, branch_control)
        begin
                case current_state is
                        when IDLE =>
                                next_state <= FETCH;
                        when FETCH =>
                                next_state <= DECODE;
                        when DECODE =>
                                case opcode is
                                        when "0000011" => next_state <= MEMORY; -- Load
                                        when "0100011" => next_state <= MEMORY; -- Store
                                        when others => next_state <= EXECUTE;
                                end case;
                        when EXECUTE =>
                                if branch_control = '1' then
                                    next_state <= FETCH; -- Branch taken
                                else
                                    next_state <= WRITEBACK;
                                end if;
                        when MEMORY =>
                                next_state <= WRITEBACK;
                        when WRITEBACK =>
                                next_state <= IDLE;
                end case;
        end process;

        process(current_state, opcode, func3, branch_control)
        begin
                sel_pc <= "11";
                rf_wen <= '0';
                type_imm <= "000";
                sel_wb <= "00";
                sel_op2 <= '0';
                dmem_wen <= '0';

                case opcode is
                        when "0000011" => -- Load
                                type_imm <= "000";
                                sel_op2 <= '1';
                        when "0100011" => -- Store
                                type_imm <= "001";
                                sel_op2 <= '1';
                        when "1100011" => -- Branch
                                type_imm <= "010";
                                sel_op2 <= '0';
                        when "1101111" => -- JAL
                                type_imm <= "100";
                        when "1100111" => -- JALR
                                type_imm <= "000";
                                sel_op2 <= '1';
                        when "0110111" => -- LUI
                                type_imm <= "011";
                                sel_op2 <= '1';
                        when "0010111" => -- AUIPC
                                type_imm <= "011";
                                sel_op2 <= '1';
                        when "0010011" => -- I-type ALU
                                if func3 = "001" or func3 = "101" then
                                        type_imm <= "101"; -- Shamt
                                else
                                        type_imm <= "000";
                                end if;
                                sel_op2 <= '1';
                        when others =>
                                type_imm <= "000";
                                sel_op2 <= '0';
                end case;

                case current_state is
                        when EXECUTE =>
                                if opcode = "1100011" then
                                        if branch_control = '1' then
                                                sel_pc <= "10";
                                        else
                                                sel_pc <= "11";
                                        end if;
                                elsif opcode = "1101111" then
                                        sel_pc <= "01";
                                elsif opcode = "1100111" then
                                        sel_pc <= "00";
                                else
                                        sel_pc <= "11";
                                end if;
                        when MEMORY =>
                                if opcode = "0100011" then
                                        dmem_wen <= '1';
                                end if;
                        when WRITEBACK =>
                                case opcode is
                                        when "0000011" =>
                                                rf_wen <= '1';
                                                sel_wb <= "00";
                                        when "1101111" | "1100111" =>
                                                rf_wen <= '1';
                                                sel_wb <= "10";
                                        when "0110011" | "0010011" | "0110111" | "0010111" =>
                                                rf_wen <= '1';
                                                sel_wb <= "01";
                                        when others =>
                                                rf_wen <= '0';
                                                sel_wb <= "00";
                                end case;
                        when others =>
                                null;
                end case;
        end process;

end Behavioral;
