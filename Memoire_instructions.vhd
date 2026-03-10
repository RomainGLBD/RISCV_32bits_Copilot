library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Memoire_instructions is
        Port ( clk : in STD_LOGIC;
                   addr : in STD_LOGIC_VECTOR(31 downto 0);
                   data_out : out STD_LOGIC_VECTOR(31 downto 0);
                   data_in : in STD_LOGIC_VECTOR(31 downto 0);
                   we : in STD_LOGIC);
end Memoire_instructions;

architecture Behavioral of Memoire_instructions is
        type memory_array is array (0 to 16383) of STD_LOGIC_VECTOR(31 downto 0);
        signal memory : memory_array := (
                0 => x"00300613",
                1 => x"008000EF",
                2 => x"00008067",
                3 => x"FF410113",
                4 => x"00112423",
                5 => x"00812223",
                6 => x"00000513",
                7 => x"02060663",
                8 => x"00150513",
                9 => x"02A60263",
                10 => x"FFF60613",
                11 => x"00C12023",
                12 => x"FDDFF0EF",
                13 => x"00012603",
                14 => x"FFF60613",
                15 => x"00050433",
                16 => x"FCDFF0EF",
                17 => x"00850533",
                18 => x"00412403",
                19 => x"00812083",
                20 => x"00C10113",
                21 => x"00008067",
                others => (others => '0'));
        signal data_out_reg : STD_LOGIC_VECTOR(31 downto 0);
begin
        process(clk)
        begin
                if rising_edge(clk) then
                        if we = '1' then
                                memory(to_integer(unsigned(addr(15 downto 2)))) <= data_in;
                        else
                                data_out_reg <= memory(to_integer(unsigned(addr(15 downto 2))));
                        end if;
                end if;
        end process;

        data_out <= data_out_reg;
end Behavioral;
