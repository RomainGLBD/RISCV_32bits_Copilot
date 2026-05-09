----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/09/2021 06:37:26 PM
-- Design Name: 
-- Module Name: byte_2_word - behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - file Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity byte_2_word is
    port (
        rst     : in  std_logic;
        clk     : in  std_logic;
        byte_dv : in  std_logic;
        byte    : in  std_logic_vector(7 downto 0);
        word_dv : out std_logic;
        word    : out std_logic_vector(15 downto 0)
    );
end entity byte_2_word;

architecture behavioral of byte_2_word is

    signal byte_reg    : std_logic_vector(7 downto 0);
    signal byte_reg2   : std_logic_vector(7 downto 0);
    signal byte_dv_dly : std_logic;
    signal byte_count  : unsigned(1 downto 0);

begin

    process(rst, clk)
    begin
        if (rst = '1') then
            byte_reg  <= (others => '0');
            byte_reg2 <= (others => '0');
        elsif (rising_edge(clk)) then
            if (byte_dv = '1') then
                byte_reg  <= byte;
                byte_reg2 <= byte_reg;
            end if;
        end if;
    end process;

    process(rst, clk)
    begin
        if (rst = '1') then
            byte_dv_dly <= '0';
        elsif (rising_edge(clk)) then
            byte_dv_dly <= byte_dv;
        end if;
    end process;

    process(rst, clk)
    begin
        if (rst = '1') then
            byte_count <= (others => '0');
        elsif (rising_edge(clk)) then
            if (byte_dv = '1') then
                byte_count <= byte_count + to_unsigned(1, 2);
            end if;
        end if;
    end process;

    word_dv <= '1' when (byte_count(0) = '0' and byte_dv_dly = '1') else '0';
    word    <= byte_reg & byte_reg2;

end architecture behavioral;