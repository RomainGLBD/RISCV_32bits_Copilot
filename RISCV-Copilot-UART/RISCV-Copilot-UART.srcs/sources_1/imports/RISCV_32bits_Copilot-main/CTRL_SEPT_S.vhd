----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/28/2026 08:56:06 AM
-- Design Name: 
-- Module Name: CTRL_SEPT_S - Behavioral
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

entity CTRL_SEPT_S is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           Q : in STD_LOGIC_VECTOR (15 downto 0);
           R : in STD_LOGIC_VECTOR (15 downto 0);
           Q_E : in STD_LOGIC;
           R_E : in STD_LOGIC;
           
           SSS : out STD_LOGIC_VECTOR (7 downto 0);
           sortie_anode : OUT STD_LOGIC_VECTOR (7 downto 0)
           );
end CTRL_SEPT_S;

architecture Behavioral of CTRL_SEPT_S is

SIGNAL S_instr : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
SIGNAL S_CE_affichage : STD_LOGIC;
SIGNAL S_Q1 : STD_LOGIC_VECTOR (3 downto 0);
SIGNAL S_Q2 : STD_LOGIC_VECTOR (3 downto 0);
SIGNAL S_Q3 : STD_LOGIC_VECTOR (3 downto 0);
SIGNAL S_Q4 : STD_LOGIC_VECTOR (3 downto 0);
SIGNAL S_R5 : STD_LOGIC_VECTOR (3 downto 0);
SIGNAL S_R6 : STD_LOGIC_VECTOR (3 downto 0);
SIGNAL S_R7 : STD_LOGIC_VECTOR (3 downto 0);
SIGNAL S_R8 : STD_LOGIC_VECTOR (3 downto 0);
SIGNAL S_sortie_commande_mux : STD_LOGIC_VECTOR (2 downto 0);

SIGNAL S_SS1 : STD_LOGIC_VECTOR (7 downto 0);
SIGNAL S_SS2 : STD_LOGIC_VECTOR (7 downto 0);
SIGNAL S_SS3 : STD_LOGIC_VECTOR (7 downto 0);
SIGNAL S_SS4 : STD_LOGIC_VECTOR (7 downto 0);
SIGNAL S_SS5 : STD_LOGIC_VECTOR (7 downto 0);
SIGNAL S_SS6 : STD_LOGIC_VECTOR (7 downto 0);
SIGNAL S_SS7 : STD_LOGIC_VECTOR (7 downto 0);
SIGNAL S_SS8 : STD_LOGIC_VECTOR (7 downto 0);

begin

-- Capture full 32-bit instruction when either Q_E or R_E (ir_we) is asserted.
proc_capture_instr: process(clk, rst)
begin
       if rst = '1' then
              S_instr <= (others => '0');
       elsif rising_edge(clk) then
              if Q_E = '1' or R_E = '1' then
                     S_instr <= Q & R; -- Q is upper 16 bits, R lower 16 bits
              end if;
       end if;
end process proc_capture_instr;

-- Decompose captured instruction into 8 nibbles (MSB -> LSB)
S_Q1 <= S_instr(31 downto 28);
S_Q2 <= S_instr(27 downto 24);
S_Q3 <= S_instr(23 downto 20);
S_Q4 <= S_instr(19 downto 16);
S_R5 <= S_instr(15 downto 12);
S_R6 <= S_instr(11 downto 8);
S_R7 <= S_instr(7 downto 4);
S_R8 <= S_instr(3 downto 0);

-- Transcodeur: nibble -> 7-seg patterns
TRANS : ENTITY work.TRANSCODEUR     PORT MAP (
          Q1 => S_Q1,
          Q2 => S_Q2,
          Q3 => S_Q3,
          Q4 => S_Q4,
          R5 => S_R5,
          R6 => S_R6,
          R7 => S_R7,
          R8 => S_R8,
          SS1 => S_SS1,
          SS2 => S_SS2,
          SS3 => S_SS3,
          SS4 => S_SS4,
          SS5 => S_SS5,
          SS6 => S_SS6,
          SS7 => S_SS7,
          SS8 => S_SS8
);

-- Frequency generator and multiplexer chain for persistence
GF : ENTITY work.gestion_frequence  PORT MAP (
          clk => clk,
          rst => rst,
          CE_affichage => S_CE_affichage
       );
    
GESTION_SEPT_S : ENTITY work.mod_8  PORT MAP (
          clk => clk,
          clk_enable => S_CE_affichage,
          rst => rst,
          sortie_anode => sortie_anode,
          sortie_commande_mux => S_sortie_commande_mux
       );

multiplexeur_sept_segments : ENTITY work.MUX_SEPT_S       PORT MAP (
          SS1 => S_SS1,
          SS2 => S_SS2,
          SS3 => S_SS3,
          SS4 => S_SS4,
          SS5 => S_SS5,
          SS6 => S_SS6,
          SS7 => S_SS7,
          SS8 => S_SS8,
          COMMANDE => S_sortie_commande_mux,
          SSS => SSS  -- Sortie Sept Segments
       );

end Behavioral;
