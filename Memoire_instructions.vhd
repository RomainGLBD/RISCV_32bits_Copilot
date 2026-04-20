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
                                -- Self-check program for critical fixes:
                                -- mem[10]: JAL link test   (1=pass, 2=fail)
                                -- mem[11]: JALR link test  (1=pass, 2=fail)
                                -- mem[12]: AUIPC test      (1=pass, 2=fail)
                                -- mem[13]: LUI test        (1=pass, 2=fail)
                                0  => x"02800A93", -- addi x21, x0, 40
                                1  => x"00100F93", -- addi x31, x0, 1
                                2  => x"00200F13", -- addi x30, x0, 2
                                3  => x"01EAA023", -- sw x30, 0(x21)
                                4  => x"01EAA223", -- sw x30, 4(x21)
                                5  => x"01EAA423", -- sw x30, 8(x21)
                                6  => x"01EAA623", -- sw x30, 12(x21)
                                7  => x"00C002EF", -- jal x5, jal_target
                                8  => x"00000013", -- nop
                                9  => x"0700006F", -- jal x0, end
                                10 => x"02000313", -- jal_target: addi x6, x0, 32
                                11 => x"00628463", -- beq x5, x6, jal_pass
                                12 => x"00C0006F", -- jal x0, test2_setup
                                13 => x"01FAA023", -- jal_pass: sw x31, 0(x21)
                                14 => x"0040006F", -- jal x0, test2_setup
                                15 => x"05000393", -- test2_setup: addi x7, x0, 80
                                16 => x"00038467", -- jalr x8, 0(x7)
                                17 => x"0200006F", -- jal x0, test3_setup
                                18 => x"00000013", -- nop
                                19 => x"00000013", -- nop
                                20 => x"04400493", -- target_jalr: addi x9, x0, 68
                                21 => x"00940463", -- beq x8, x9, jalr_pass
                                22 => x"00C0006F", -- jal x0, test3_setup
                                23 => x"01FAA223", -- jalr_pass: sw x31, 4(x21)
                                24 => x"0040006F", -- jal x0, test3_setup
                                25 => x"00000617", -- test3_setup: auipc x12, 0
                                26 => x"06400693", -- addi x13, x0, 100
                                27 => x"00D60463", -- beq x12, x13, auipc_pass
                                28 => x"00C0006F", -- jal x0, test4_setup
                                29 => x"01FAA423", -- auipc_pass: sw x31, 8(x21)
                                30 => x"0040006F", -- jal x0, test4_setup
                                31 => x"12345737", -- test4_setup: lui x14, 0x12345
                                32 => x"02400793", -- addi x15, x0, 36
                                33 => x"0007A803", -- lw x16, 0(x15)
                                34 => x"01070463", -- beq x14, x16, lui_pass
                                35 => x"0080006F", -- jal x0, end
                                36 => x"01FAA623", -- lui_pass: sw x31, 12(x21)
                                37 => x"0000006F", -- end: jal x0, end

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
