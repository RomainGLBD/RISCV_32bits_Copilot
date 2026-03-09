library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Memoire_data is
        Port ( clk : in STD_LOGIC;
                   we : in STD_LOGIC; -- Write enable
                   addr : in STD_LOGIC_VECTOR (31 downto 0); -- Address
                   data_in : in STD_LOGIC_VECTOR (31 downto 0); -- Data input
                   data_out : out STD_LOGIC_VECTOR (31 downto 0) -- Data output
                 );
end Memoire_data;

architecture Behavioral of Memoire_data is
        type memory_array is array (0 to 1023) of STD_LOGIC_VECTOR(31 downto 0);
        signal memory : memory_array := (
                0x0ff000ff,
                0x00000000,
                0x00000000,
                0x00000000,
                0x0ff000ff,
                0x00000000,
                0x00000000,
                0x00000000,
                0xff0000ff,
                0xf00f0ff0,
                0x00000000,
                0x00000000,
                0xff0000ff,
                0xf00f0ff0,
                0x00000000,
                0x00000000,
                0x00ff00ff,
                0xff00ff00,
                0x0ff00ff0,
                0xf00ff00f,
                0xefefefef,
                0xefefefef,
                0x0000efef,
                0x00000000,
                0xbeefbeef,
                0xbeefbeef,
                0xbeefbeef,
                0xbeefbeef,
                0xbeefbeef,
                0x00000000,
                0x00000000,
                0x00000000,
                0xdeadbeef,
                0xdeadbeef,
                0xdeadbeef,
                0xdeadbeef,
                0xdeadbeef,
                0xdeadbeef,
                0xdeadbeef,
                0xdeadbeef,
                0xdeadbeef,
                0xdeadbeef,
                0x00000000,
                0x00000000,
        
        others => (others => '0'));
begin

        process(clk)
        begin
                if falling_edge(clk) then 
                        if we = '1' then
                                memory(to_integer(unsigned(addr(11 downto 2)))) <= data_in;
                        end if;
                end if;
                
                if rising_edge(clk) then 
                        data_out <= memory(to_integer(unsigned(addr(11 downto 2))));
                end if;
        end process;

end Behavioral;
