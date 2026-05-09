----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/10/2025 08:12:28 AM
-- Design Name: 
-- Module Name: gestion_frequence - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity gestion_frequence is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           CE_affichage : out STD_LOGIC
           );
end gestion_frequence;



architecture Behavioral of gestion_frequence is

signal cpt_affichage : unsigned(15 downto 0) := to_unsigned(0,16);

begin


affichage: process (clk, rst)
begin
   if (rst='1') then
      cpt_affichage <= to_unsigned(0,16);
   elsif clk='1' and clk'event then
      cpt_affichage <= cpt_affichage + 1;
   end if;
end process affichage;



affichage_output: process (cpt_affichage)
begin
   if cpt_affichage = TO_UNSIGNED(33333,16) then
      CE_affichage <= '1';
   else
      CE_affichage <= '0';
   end if;
end process affichage_output;



end Behavioral;
