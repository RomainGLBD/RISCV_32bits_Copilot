library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gen_imm is
    port(
        -- Entrées
        Instr      : in  std_logic_vector(31 downto 0);  -- Instruction 32 bits
        type_imm   : in  std_logic_vector(2 downto 0);   -- Type d'immédiat (de la FSM)
        
        -- Sortie
        imm_out    : out std_logic_vector(31 downto 0)   -- Immédiat généré 32 bits (signé étendus)
    );
end entity gen_imm;

architecture rtl of gen_imm is
begin
    
    process(Instr, type_imm)
        variable imm_signed : signed(31 downto 0);
    begin
        
        case type_imm is
            
            -- Type I: I-type immediate (lw, addi, etc.)
            -- imm = sign_extend(instr[31:20])
            when "000" =>
                imm_signed := resize(signed(Instr(31 downto 20)), 32);
                imm_out <= std_logic_vector(imm_signed);
            
            -- Type S: S-type immediate (sw, etc.)
            -- imm = sign_extend({instr[31:25], instr[11:7]})
            when "001" =>
                imm_signed := resize(signed(Instr(31 downto 25) & Instr(11 downto 7)), 32);
                imm_out <= std_logic_vector(imm_signed);
            
            -- Type B: B-type immediate (beq, bne, etc.)
            -- imm = sign_extend({instr[31], instr[7], instr[30:25], instr[11:8], 0})
            when "010" =>
                imm_signed := resize(signed(Instr(31) & Instr(7) & Instr(30 downto 25) & Instr(11 downto 8) & '0'), 32);
                imm_out <= std_logic_vector(imm_signed);
            
            -- Type U: U-type immediate (lui, auipc, etc.)
            -- imm = {instr[31:12], 12'b0}
            when "011" =>
                imm_out <= Instr(31 downto 12) & "000000000000";
            
            -- Type J: J-type immediate (jal, etc.)
            -- imm = sign_extend({instr[31], instr[19:12], instr[20], instr[30:21], 0})
            when "100" =>
                imm_signed := resize(signed(Instr(31) & Instr(19 downto 12) & Instr(20) & Instr(30 downto 21) & '0'), 32);
                imm_out <= std_logic_vector(imm_signed);
            
            -- Type Shamt: Shamt immediate (slli, srli, etc.)
            -- imm = zero_extend(instr[24:20])
            when "101" =>
                imm_out <= (31 downto 5 => '0') & Instr(24 downto 20);
            
            -- Immédiat nul (par défaut)
            when others =>
                imm_out <= (others => '0');
                
        end case;
        
    end process;
    
end architecture rtl;
