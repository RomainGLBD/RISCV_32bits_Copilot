library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity File_de_registres is
    Port (
        clk         : in  STD_LOGIC; -- Clock signal
        we          : in  STD_LOGIC; -- Write enable
        wr_addr     : in  STD_LOGIC_VECTOR(4 downto 0); -- Write address (5 bits for 32 registers)
        wr_data     : in  STD_LOGIC_VECTOR(31 downto 0); -- Write data (32 bits)
        rd_addr1    : in  STD_LOGIC_VECTOR(4 downto 0); -- Read address 1
        rd_addr2    : in  STD_LOGIC_VECTOR(4 downto 0); -- Read address 2
        rd_data1    : out STD_LOGIC_VECTOR(31 downto 0); -- Read data 1
        rd_data2    : out STD_LOGIC_VECTOR(31 downto 0)  -- Read data 2
    );
end File_de_registres;

architecture Behavioral of File_de_registres is
    type reg_file_type is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
    signal reg_file : reg_file_type := (others => (others => '0')); -- Initialize registers to 0
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                reg_file(to_integer(unsigned(wr_addr))) <= wr_data;
            end if;
        end if;
    end process;

    rd_data1 <= (others => '0') when rd_addr1 = "00000" else reg_file(to_integer(unsigned(rd_addr1)));
    rd_data2 <= (others => '0') when rd_addr2 = "00000" else reg_file(to_integer(unsigned(rd_addr2)));

end Behavioral;
