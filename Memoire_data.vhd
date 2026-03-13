library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Memoire_data is
        Port ( clk : in STD_LOGIC;
                   we : in STD_LOGIC_VECTOR (3 downto 0); -- Byte write enable
                   addr : in STD_LOGIC_VECTOR (31 downto 0); -- Address
                   data_in : in STD_LOGIC_VECTOR (31 downto 0); -- Data input
                   data_out : out STD_LOGIC_VECTOR (31 downto 0) -- Data output
                 );
end Memoire_data;

architecture Behavioral of Memoire_data is
        type memory_array is array (0 to 2047) of STD_LOGIC_VECTOR(31 downto 0);
        signal memory : memory_array := (
                                
        others => (others => '0'));
        signal word_data_dbg : STD_LOGIC_VECTOR(31 downto 0);
begin

        process(clk)
                variable word_idx  : unsigned(11 downto 0);
                variable word_data : STD_LOGIC_VECTOR(31 downto 0);
        begin
                if rising_edge(clk) then
                        word_idx := resize(unsigned(addr(11 downto 2)), 12);
                        if we /= "0000" then
                                -- Use enough address bits to cover full data memory depth.
                                word_data := memory(to_integer(word_idx));
                                case we is
                                        when "0001" => -- SB at byte lane 0
                                                word_data(7 downto 0) := data_in(7 downto 0);
                                        when "0010" => -- SB at byte lane 1
                                                word_data(15 downto 8) := data_in(7 downto 0);
                                        when "0100" => -- SB at byte lane 2
                                                word_data(23 downto 16) := data_in(7 downto 0);
                                        when "1000" => -- SB at byte lane 3
                                                word_data(31 downto 24) := data_in(7 downto 0);
                                        when "0011" => -- SH at low halfword
                                                word_data(7 downto 0) := data_in(7 downto 0);
                                                word_data(15 downto 8) := data_in(15 downto 8);
                                        when "1100" => -- SH at high halfword
                                                word_data(23 downto 16) := data_in(7 downto 0);
                                                word_data(31 downto 24) := data_in(15 downto 8);
                                        when "1111" => -- SW
                                                word_data := data_in;
                                        when others =>
                                                null;
                                end case;
                                word_data_dbg <= word_data;
                                memory(to_integer(word_idx)) <= word_data;
                        else
                                data_out <= memory(to_integer(word_idx));
                        end if;
                end if;
        end process;

end Behavioral;
