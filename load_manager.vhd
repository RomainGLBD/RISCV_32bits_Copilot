library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity load_manager is
    Port (
        dmem_out  : in  STD_LOGIC_VECTOR(31 downto 0);
        load_sel  : in  STD_LOGIC_VECTOR(2 downto 0);
        load_mask : in  STD_LOGIC_VECTOR(3 downto 0);
        load_data : out STD_LOGIC_VECTOR(31 downto 0)
    );
end load_manager;

architecture Behavioral of load_manager is
    signal byte_val_s : STD_LOGIC_VECTOR(7 downto 0);
    signal half_val_s : STD_LOGIC_VECTOR(15 downto 0);
begin
    byte_val_s <= dmem_out(7 downto 0)   when load_mask = "0001" else
                  dmem_out(15 downto 8)  when load_mask = "0010" else
                  dmem_out(23 downto 16) when load_mask = "0100" else
                  dmem_out(31 downto 24) when load_mask = "1000" else
                  dmem_out(7 downto 0);

    half_val_s <= dmem_out(15 downto 0)  when load_mask = "0011" else
                  dmem_out(31 downto 16) when load_mask = "1100" else
                  dmem_out(15 downto 0);

    with load_sel select
        load_data <= std_logic_vector(resize(signed(byte_val_s), 32))  when "001",
                     std_logic_vector(resize(signed(half_val_s), 32))  when "010",
                     std_logic_vector(resize(unsigned(byte_val_s), 32)) when "011",
                     std_logic_vector(resize(unsigned(half_val_s), 32)) when "100",
                     dmem_out when others;
end Behavioral;
