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
        type memory_array is array (0 to 4095) of STD_LOGIC_VECTOR(31 downto 0);
        signal memory : memory_array := (
                 others => x"00000001");
        signal word_data_dbg : STD_LOGIC_VECTOR(31 downto 0);
begin

        process(clk)
        begin
                if rising_edge(clk) then
                        if we /= "0000" then
                                case we is
                                        when "0001" => -- SB at byte lane 0
                                                memory(to_integer(unsigned(addr(13 downto 2))))(7 downto 0) <= data_in(7 downto 0);
                                        when "0010" => -- SB at byte lane 1
                                                memory(to_integer(unsigned(addr(13 downto 2))))(15 downto 8) <= data_in(7 downto 0);
                                        when "0100" => -- SB at byte lane 2
                                                memory(to_integer(unsigned(addr(13 downto 2))))(23 downto 16) <= data_in(7 downto 0);
                                        when "1000" => -- SB at byte lane 3
                                                memory(to_integer(unsigned(addr(13 downto 2))))(31 downto 24) <= data_in(7 downto 0);
                                        when "0011" => -- SH at low halfword
                                                memory(to_integer(unsigned(addr(13 downto 2))))(7 downto 0) <= data_in(7 downto 0);
                                                memory(to_integer(unsigned(addr(13 downto 2))))(15 downto 8) <= data_in(15 downto 8);
                                        when "1100" => -- SH at high halfword
                                                memory(to_integer(unsigned(addr(13 downto 2))))(23 downto 16) <= data_in(7 downto 0);
                                                memory(to_integer(unsigned(addr(13 downto 2))))(31 downto 24) <= data_in(15 downto 8);
                                        when "1111" => -- SW
                                                memory(to_integer(unsigned(addr(13 downto 2)))) <= data_in;
                                        when others =>
                                                null;
                                end case;
                                word_data_dbg <= memory(to_integer(unsigned(addr(13 downto 2))));
                        else
                                data_out <= memory(to_integer(unsigned(addr(13 downto 2))));
                        end if;
                end if;
        end process;

end Behavioral;
