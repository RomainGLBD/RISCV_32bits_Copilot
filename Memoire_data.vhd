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
        type memory_array is array (0 to 32767) of STD_LOGIC_VECTOR(31 downto 0);
        signal memory : memory_array := (
        
        others => (others => '0'));
        signal word_data_dbg : STD_LOGIC_VECTOR(31 downto 0);
begin

        process(clk)
                variable word_idx  : integer;
                variable word_data : STD_LOGIC_VECTOR(31 downto 0);
        begin
                if rising_edge(clk) then
                        word_idx := to_integer(unsigned(addr(16 downto 2)));
                        if we /= "0000" then
                                -- Use enough address bits to cover full data memory depth.
                                word_data := memory(word_idx);
                                if we(0) = '1' then
                                        word_data(7 downto 0) := data_in(7 downto 0);
                                end if;
                                if we(1) = '1' then
                                        word_data(15 downto 8) := data_in(15 downto 8);
                                end if;
                                if we(2) = '1' then
                                        word_data(23 downto 16) := data_in(23 downto 16);
                                end if;
                                if we(3) = '1' then
                                        word_data(31 downto 24) := data_in(31 downto 24);
                                end if;
                                word_data_dbg <= word_data;
                                memory(word_idx) <= word_data;
                        else
                                data_out <= memory(word_idx);
                        end if;
                end if;
        end process;

end Behavioral;
