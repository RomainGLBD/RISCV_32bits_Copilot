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
                0 => x"02000093", -- addi x1, x0, 32
                1 => x"07F00113", -- addi x2, x0, 127
                2 => x"0020A023", -- sw x2, 0(x1)
                3 => x"00408093", -- addi x1, x1, 4
                4 => x"FFF00113", -- addi x2, x0, -1
                5 => x"0020A023", -- sw x2, 0(x1)
                6 => x"00408093", -- addi x1, x1, 4
                7 => x"0000A023", -- sw x0, 0(x1)
                8 => x"01100113", -- addi x2, x0, 17
                9 => x"00208023", -- sb x2, 0(x1)
                10 => x"02200113", -- addi x2, x0, 34
                11 => x"002080A3", -- sb x2, 1(x1)
                12 => x"03300113", -- addi x2, x0, 51
                13 => x"00208123", -- sb x2, 2(x1)
                14 => x"04400113", -- addi x2, x0, 68
                15 => x"002081A3",  -- sb x2, 3(x1)
                16 => x"00408093", -- addi x1, x1, 4
                17 => x"0000A023", -- sw x0, 0(x1)
                18 => x"00005137", -- lui x2, 0x5
                19 => x"56610113", -- addi x2, x2, 0x566
                20 => x"00209023", -- sh x2, 0(x1)
                21 => x"00408093", -- addi x1, x1, 4
                22 => x"0000A023", -- sw x0, 0(x1)
                23 => x"0000B137", -- lui x2, 0xB
                24 => x"ABB10113", -- addi x2, x2, -1349
                25 => x"00209123", -- sh x2, 2(x1)
                26 => x"FF00A283", -- lw x5, -16(x1)
                27 => x"FF40A303", -- lw x6, -12(x1)
                28 => x"FF80A383", -- lw x7, -8(x1)
                29 => x"FFC0A403", -- lw x8, -4(x1)
                30 => x"0000A483", -- lw x9, 0(x1)
                31 => x"FF808503", -- lb x10, -8(x1)
                32 => x"FF908583", -- lb x11, -7(x1)
                33 => x"FFA08603", -- lb x12, -6(x1)
                34 => x"FFB08683", -- lb x13, -5(x1)
                35 => x"FFC09703", -- lh x14, -4(x1)
                36 => x"00209783", -- lh x15, 2(x1)
                37 => x"0000006F", -- jal x0, 0

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
