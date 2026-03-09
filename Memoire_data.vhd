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
        type memory_array is array (0 to 65536) of STD_LOGIC_VECTOR(31 downto 0);
        signal memory : memory_array := (
                                0  => x"0FF000FF",
                                1  => x"00000000",
                                2  => x"00000000",
                                3  => x"00000000",
                                4  => x"0FF000FF",
                                5  => x"00000000",
                                6  => x"00000000",
                                7  => x"00000000",
                                8  => x"FF0000FF",
                                9  => x"F00F0FF0",
                                10 => x"00000000",
                                11 => x"00000000",
                                12 => x"FF0000FF",
                                13 => x"F00F0FF0",
                                14 => x"00000000",
                                15 => x"00000000",
                                16 => x"00FF00FF",
                                17 => x"FF00FF00",
                                18 => x"0FF00FF0",
                                19 => x"F00FF00F",
                                20 => x"EFEFEFEF",
                                21 => x"EFEFEFEF",
                                22 => x"0000EFEF",
                                23 => x"00000000",
                                24 => x"BEEFBEEF",
                                25 => x"BEEFBEEF",
                                26 => x"BEEFBEEF",
                                27 => x"BEEFBEEF",
                                28 => x"BEEFBEEF",
                                29 => x"00000000",
                                30 => x"00000000",
                                31 => x"00000000",
                                32 => x"DEADBEEF",
                                33 => x"DEADBEEF",
                                34 => x"DEADBEEF",
                                35 => x"DEADBEEF",
                                36 => x"DEADBEEF",
                                37 => x"DEADBEEF",
                                38 => x"DEADBEEF",
                                39 => x"DEADBEEF",
                                40 => x"DEADBEEF",
                                41 => x"DEADBEEF",
                                42 => x"00000000",
                                43 => x"00000000",
        
        others => (others => '0'));
        signal word_data_dbg : STD_LOGIC_VECTOR(31 downto 0);
begin

        process(clk)
                variable word_idx  : unsigned(16 downto 0);
                variable word_data : STD_LOGIC_VECTOR(31 downto 0);
        begin
                if rising_edge(clk) then
                        word_idx := shift_left(resize(unsigned(addr(16 downto 2)), 17), 2);
                        if we /= "0000" then
                                -- Use enough address bits to cover full data memory depth.
                                word_data := memory(to_integer(word_idx));
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
                                memory(to_integer(word_idx)) <= word_data;
                        else
                                data_out <= memory(to_integer(word_idx));
                        end if;
                end if;
        end process;

end Behavioral;
