----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/09/2021 06:57:40 PM
-- Design Name: 
-- Module Name: word_2_byte - behavioral
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

entity word_2_byte is
    port (
        rst     : in  std_logic;
        clk     : in  std_logic;
        word_dv : in  std_logic;
        word    : in  std_logic_vector(15 downto 0);
        byte_dv : out std_logic;
        byte    : out std_logic_vector(7 downto 0)
    );
end entity word_2_byte;

architecture behavioral of word_2_byte is

    signal word_dv_dly  : std_logic;
    signal word_dv_dly2 : std_logic;
    signal word_reg     : std_logic_vector(15 downto 0);

begin

    process(rst, clk)
    begin
        if (rst = '1') then
            word_dv_dly  <= '0';
            word_dv_dly2 <= '0';
            word_reg     <= (others => '0');
        elsif (rising_edge(clk)) then
            word_dv_dly  <= word_dv;
            word_dv_dly2 <= word_dv_dly;
            word_reg     <= word;
        end if;
    end process;

    process(word_dv_dly, word_dv_dly2, word_reg)
    begin
        if (word_dv_dly = '1') then
            byte <= word_reg(7 downto 0);
        elsif (word_dv_dly2 = '1') then
            byte <= word_reg(15 downto 8);
        else
            byte <= (others => '0');
        end if;
    end process;

    byte_dv <= word_dv_dly or word_dv_dly2;

end architecture behavioral;