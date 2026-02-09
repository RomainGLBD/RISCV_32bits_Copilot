library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity FSM_control is
        Port ( clk : in STD_LOGIC;
                   reset : in STD_LOGIC;
                   opcode : in STD_LOGIC_VECTOR(6 downto 0);
                   branch_control : in STD_LOGIC; -- NEW: Control signal for branching
                   instruction : in STD_LOGIC_VECTOR(31 downto 0); -- NEW: Instruction from memory
                   state : out STD_LOGIC_VECTOR(2 downto 0));
end FSM_control;

architecture Behavioral of FSM_control is
        type state_type is (IDLE, FETCH, DECODE, EXECUTE, MEMORY, WRITEBACK);
        signal current_state, next_state: state_type;
begin

        process(clk, reset)
        begin
                if reset = '1' then
                        current_state <= IDLE;
                elsif rising_edge(clk) then
                        current_state <= next_state;
                end if;
        end process;

        process(current_state, opcode, branch_control) // BEGIN:
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
        end process; // END:

        process(current_state)
        begin
                case current_state is
                        when IDLE => state <= "000";
                        when FETCH => state <= "001";
                        when DECODE => state <= "010";
                        when EXECUTE => state <= "011";
                        when MEMORY => state <= "100";
                        when WRITEBACK => state <= "101";
                end case;
        end process;

end Behavioral;
