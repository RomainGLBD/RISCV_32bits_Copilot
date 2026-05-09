----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/28/2026 09:25:21 AM
-- Design Name: 
-- Module Name: MUX_SEPT_S - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MUX_SEPT_S is
  Port (   SS1 : in STD_LOGIC_VECTOR (7 downto 0);
           SS2 : in STD_LOGIC_VECTOR (7 downto 0);
           SS3 : in STD_LOGIC_VECTOR (7 downto 0);
           SS4 : in STD_LOGIC_VECTOR (7 downto 0);
           SS5 : in STD_LOGIC_VECTOR (7 downto 0);
           SS6 : in STD_LOGIC_VECTOR (7 downto 0);
           SS7 : in STD_LOGIC_VECTOR (7 downto 0);
           SS8 : in STD_LOGIC_VECTOR (7 downto 0);
           COMMANDE : in STD_LOGIC_VECTOR (2 downto 0);
           
           SSS : out STD_LOGIC_VECTOR (7 downto 0)  -- Sortie Sept Segments
       );
end MUX_SEPT_S;

architecture Behavioral of MUX_SEPT_S is

begin

output: process(COMMANDE)
begin
    case (COMMANDE) is
        when "000" =>
            SSS <= SS4;
        when "001" =>
            SSS <= SS3;
        when "010" =>
            SSS <= SS2;
        when "011" =>
            SSS <= SS1;
        when "100" =>
            SSS <= SS8;
        when "101" =>
            SSS <= SS7;
        when "110" =>
            SSS <= SS6;
        when "111" =>
            SSS <= SS5;
            
        when others =>
    end case;
end process output;

end Behavioral;
