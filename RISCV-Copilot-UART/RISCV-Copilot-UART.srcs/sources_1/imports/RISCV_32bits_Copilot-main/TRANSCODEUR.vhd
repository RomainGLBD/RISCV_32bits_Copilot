library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- TRANSCODEUR: convertit 8 nybbles (4 bits chacun) en 8 motifs 7-segments
-- Ports nommés pour correspondre à l'instanciation existante dans CTRL_SEPT_S
-- Convention: segments = "gfedcba" + dp as LSB/MSB ordering chosen here as
-- output(7 downto 0) = (dp, g, f, e, d, c, b, a)
-- Active low segments: '0' allume le segment (compatible avec multiplexage anode active low)

entity TRANSCODEUR is
    port (
        Q1  : in  STD_LOGIC_VECTOR(3 downto 0);
        Q2  : in  STD_LOGIC_VECTOR(3 downto 0);
        Q3  : in  STD_LOGIC_VECTOR(3 downto 0);
        Q4  : in  STD_LOGIC_VECTOR(3 downto 0);
        R5  : in  STD_LOGIC_VECTOR(3 downto 0);
        R6  : in  STD_LOGIC_VECTOR(3 downto 0);
        R7  : in  STD_LOGIC_VECTOR(3 downto 0);
        R8  : in  STD_LOGIC_VECTOR(3 downto 0);

        SS1 : out STD_LOGIC_VECTOR(7 downto 0);
        SS2 : out STD_LOGIC_VECTOR(7 downto 0);
        SS3 : out STD_LOGIC_VECTOR(7 downto 0);
        SS4 : out STD_LOGIC_VECTOR(7 downto 0);
        SS5 : out STD_LOGIC_VECTOR(7 downto 0);
        SS6 : out STD_LOGIC_VECTOR(7 downto 0);
        SS7 : out STD_LOGIC_VECTOR(7 downto 0);
        SS8 : out STD_LOGIC_VECTOR(7 downto 0)
    );
end TRANSCODEUR;

architecture rtl of TRANSCODEUR is

    signal SS1_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal SS2_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal SS3_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal SS4_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal SS5_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal SS6_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal SS7_sig : STD_LOGIC_VECTOR(7 downto 0);
    signal SS8_sig : STD_LOGIC_VECTOR(7 downto 0);

begin

    -- Combinatorial process: map each 4-bit nibble to 7-seg pattern using signals
    process(Q1, Q2, Q3, Q4, R5, R6, R7, R8)
    begin
        -- Q1
        case to_integer(unsigned(Q1)) is
            when 0  => SS1_sig <= "10000001";
            when 1  => SS1_sig <= "11001111";
            when 2  => SS1_sig <= "10010010";
            when 3  => SS1_sig <= "10000110";
            when 4  => SS1_sig <= "11001100";
            when 5  => SS1_sig <= "10100100";
            when 6  => SS1_sig <= "10100000";
            when 7  => SS1_sig <= "10001111";
            when 8  => SS1_sig <= "10000000";
            when 9  => SS1_sig <= "10000100";
            when 10 => SS1_sig <= "10001000"; -- A
            when 11 => SS1_sig <= "11100000"; -- b
            when 12 => SS1_sig <= "10110001"; -- C
            when 13 => SS1_sig <= "11000010"; -- d
            when 14 => SS1_sig <= "10110000"; -- E
            when 15 => SS1_sig <= "10111000"; -- F
            when others => SS1_sig <= (others => '1');
        end case;

        -- Q2
        case to_integer(unsigned(Q2)) is
            when 0  => SS2_sig <= "10000001";
            when 1  => SS2_sig <= "11001111";
            when 2  => SS2_sig <= "10010010";
            when 3  => SS2_sig <= "10000110";
            when 4  => SS2_sig <= "11001100";
            when 5  => SS2_sig <= "10100100";
            when 6  => SS2_sig <= "10100000";
            when 7  => SS2_sig <= "10001111";
            when 8  => SS2_sig <= "10000000";
            when 9  => SS2_sig <= "10000100";
            when 10 => SS2_sig <= "10001000";
            when 11 => SS2_sig <= "11100000";
            when 12 => SS2_sig <= "10110001";
            when 13 => SS2_sig <= "11000010";
            when 14 => SS2_sig <= "10110000";
            when 15 => SS2_sig <= "10111000";
            when others => SS2_sig <= (others => '1');
        end case;

        -- Q3
        case to_integer(unsigned(Q3)) is
            when 0  => SS3_sig <= "10000001";
            when 1  => SS3_sig <= "11001111";
            when 2  => SS3_sig <= "10010010";
            when 3  => SS3_sig <= "10000110";
            when 4  => SS3_sig <= "11001100";
            when 5  => SS3_sig <= "10100100";
            when 6  => SS3_sig <= "10100000";
            when 7  => SS3_sig <= "10001111";
            when 8  => SS3_sig <= "10000000";
            when 9  => SS3_sig <= "10000100";
            when 10 => SS3_sig <= "10001000";
            when 11 => SS3_sig <= "11100000";
            when 12 => SS3_sig <= "10110001";
            when 13 => SS3_sig <= "11000010";
            when 14 => SS3_sig <= "10110000";
            when 15 => SS3_sig <= "10111000";
            when others => SS3_sig <= (others => '1');
        end case;

        -- Q4
        case to_integer(unsigned(Q4)) is
            when 0  => SS4_sig <= "10000001";
            when 1  => SS4_sig <= "11001111";
            when 2  => SS4_sig <= "10010010";
            when 3  => SS4_sig <= "10000110";
            when 4  => SS4_sig <= "11001100";
            when 5  => SS4_sig <= "10100100";
            when 6  => SS4_sig <= "10100000";
            when 7  => SS4_sig <= "10001111";
            when 8  => SS4_sig <= "10000000";
            when 9  => SS4_sig <= "10000100";
            when 10 => SS4_sig <= "10001000";
            when 11 => SS4_sig <= "11100000";
            when 12 => SS4_sig <= "10110001";
            when 13 => SS4_sig <= "11000010";
            when 14 => SS4_sig <= "10110000";
            when 15 => SS4_sig <= "10111000";
            when others => SS4_sig <= (others => '1');
        end case;

        -- R5
        case to_integer(unsigned(R5)) is
            when 0  => SS5_sig <= "10000001";
            when 1  => SS5_sig <= "11001111";
            when 2  => SS5_sig <= "10010010";
            when 3  => SS5_sig <= "10000110";
            when 4  => SS5_sig <= "11001100";
            when 5  => SS5_sig <= "10100100";
            when 6  => SS5_sig <= "10100000";
            when 7  => SS5_sig <= "10001111";
            when 8  => SS5_sig <= "10000000";
            when 9  => SS5_sig <= "10000100";
            when 10 => SS5_sig <= "10001000";
            when 11 => SS5_sig <= "11100000";
            when 12 => SS5_sig <= "10110001";
            when 13 => SS5_sig <= "11000010";
            when 14 => SS5_sig <= "10110000";
            when 15 => SS5_sig <= "10111000";
            when others => SS5_sig <= (others => '1');
        end case;

        -- R6
        case to_integer(unsigned(R6)) is
            when 0  => SS6_sig <= "10000001";
            when 1  => SS6_sig <= "11001111";
            when 2  => SS6_sig <= "10010010";
            when 3  => SS6_sig <= "10000110";
            when 4  => SS6_sig <= "11001100";
            when 5  => SS6_sig <= "10100100";
            when 6  => SS6_sig <= "10100000";
            when 7  => SS6_sig <= "10001111";
            when 8  => SS6_sig <= "10000000";
            when 9  => SS6_sig <= "10000100";
            when 10 => SS6_sig <= "10001000";
            when 11 => SS6_sig <= "11100000";
            when 12 => SS6_sig <= "10110001";
            when 13 => SS6_sig <= "11000010";
            when 14 => SS6_sig <= "10110000";
            when 15 => SS6_sig <= "10111000";
            when others => SS6_sig <= (others => '1');
        end case;

        -- R7
        case to_integer(unsigned(R7)) is
            when 0  => SS7_sig <= "10000001";
            when 1  => SS7_sig <= "11001111";
            when 2  => SS7_sig <= "10010010";
            when 3  => SS7_sig <= "10000110";
            when 4  => SS7_sig <= "11001100";
            when 5  => SS7_sig <= "10100100";
            when 6  => SS7_sig <= "10100000";
            when 7  => SS7_sig <= "10001111";
            when 8  => SS7_sig <= "10000000";
            when 9  => SS7_sig <= "10000100";
            when 10 => SS7_sig <= "10001000";
            when 11 => SS7_sig <= "11100000";
            when 12 => SS7_sig <= "10110001";
            when 13 => SS7_sig <= "11000010";
            when 14 => SS7_sig <= "10110000";
            when 15 => SS7_sig <= "10111000";
            when others => SS7_sig <= (others => '1');
        end case;

        -- R8
        case to_integer(unsigned(R8)) is
            when 0  => SS8_sig <= "10000001";
            when 1  => SS8_sig <= "11001111";
            when 2  => SS8_sig <= "10010010";
            when 3  => SS8_sig <= "10000110";
            when 4  => SS8_sig <= "11001100";
            when 5  => SS8_sig <= "10100100";
            when 6  => SS8_sig <= "10100000";
            when 7  => SS8_sig <= "10001111";
            when 8  => SS8_sig <= "10000000";
            when 9  => SS8_sig <= "10000100";
            when 10 => SS8_sig <= "10001000";
            when 11 => SS8_sig <= "11100000";
            when 12 => SS8_sig <= "10110001";
            when 13 => SS8_sig <= "11000010";
            when 14 => SS8_sig <= "10110000";
            when 15 => SS8_sig <= "10111000";
            when others => SS8_sig <= (others => '1');
        end case;

    end process;

    -- assign internal signals to outputs
    SS1 <= SS1_sig;
    SS2 <= SS2_sig;
    SS3 <= SS3_sig;
    SS4 <= SS4_sig;
    SS5 <= SS5_sig;
    SS6 <= SS6_sig;
    SS7 <= SS7_sig;
    SS8 <= SS8_sig;

end rtl;
