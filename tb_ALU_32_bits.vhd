library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_ALU_32_bits is
end tb_ALU_32_bits;

architecture behavior of tb_ALU_32_bits is
    component ALU_32_bits
        Port (
            A           : in  std_logic_vector(31 downto 0);
            B           : in  std_logic_vector(31 downto 0);
            ALUCtrl     : in  std_logic_vector(3 downto 0);
            BranchType  : in  std_logic_vector(2 downto 0);
            Result      : out std_logic_vector(31 downto 0);
            branchement : out std_logic
        );
    end component;

    signal A           : std_logic_vector(31 downto 0) := (others => '0');
    signal B           : std_logic_vector(31 downto 0) := (others => '0');
    signal ALUCtrl     : std_logic_vector(3 downto 0) := (others => '0');
    signal BranchType  : std_logic_vector(2 downto 0) := (others => '0');
    signal Result      : std_logic_vector(31 downto 0);
    signal branchement : std_logic;

    function slv_signed(val : integer) return std_logic_vector is
    begin
        return std_logic_vector(to_signed(val, 32));
    end function;

    function slv_unsigned(val : integer) return std_logic_vector is
    begin
        return std_logic_vector(to_unsigned(val, 32));
    end function;

    procedure check_case(
        signal a_sig   : out std_logic_vector(31 downto 0);
        signal b_sig   : out std_logic_vector(31 downto 0);
        signal alu_sig : out std_logic_vector(3 downto 0);
        signal br_sig  : out std_logic_vector(2 downto 0);
        constant name  : in string;
        constant a_in  : in std_logic_vector(31 downto 0);
        constant b_in  : in std_logic_vector(31 downto 0);
        constant alu   : in std_logic_vector(3 downto 0);
        constant br    : in std_logic_vector(2 downto 0);
        constant exp_r : in std_logic_vector(31 downto 0);
        constant exp_b : in std_logic
    ) is
    begin
        a_sig <= a_in;
        b_sig <= b_in;
        alu_sig <= alu;
        br_sig <= br;
        wait for 1 ns;
        assert Result = exp_r
            report "FAIL: " & name & " (Result)"
            severity error;
        assert branchement = exp_b
            report "FAIL: " & name & " (Branch)"
            severity error;
    end procedure;

begin
    uut: ALU_32_bits
        port map (
            A => A,
            B => B,
            ALUCtrl => ALUCtrl,
            BranchType => BranchType,
            Result => Result,
            branchement => branchement
        );

    stim_proc: process
    begin
        -- AND
        check_case(A, B, ALUCtrl, BranchType, "AND basic",
            x"F0F0F0F0", x"0FF00FF0", "0000", "000", x"F0F000F0", '0');

        -- OR
        check_case(A, B, ALUCtrl, BranchType, "OR basic",
            x"F0F0F0F0", x"0FF00FF0", "0001", "000", x"FFF0FFF0", '0');

        -- XOR
        check_case(A, B, ALUCtrl, BranchType, "XOR basic",
            x"AAAA5555", x"0F0F0F0F", "0011", "000", x"A5A55A5A", '0');

        -- ADD
        check_case(A, B, ALUCtrl, BranchType, "ADD 1+2",
            slv_signed(1), slv_signed(2), "0010", "000", slv_signed(3), '0');

        check_case(A, B, ALUCtrl, BranchType, "ADD -1+1",
            slv_signed(-1), slv_signed(1), "0010", "000", slv_signed(0), '0');

        check_case(A, B, ALUCtrl, BranchType, "ADD max+1 wrap",
            slv_signed(2147483647), slv_signed(1), "0010", "000", x"80000000", '0');

        -- SUB
        check_case(A, B, ALUCtrl, BranchType, "SUB 5-3",
            slv_signed(5), slv_signed(3), "0110", "000", slv_signed(2), '0');

        check_case(A, B, ALUCtrl, BranchType, "SUB 0-1",
            slv_signed(0), slv_signed(1), "0110", "000", slv_signed(-1), '0');

        -- SLL
        check_case(A, B, ALUCtrl, BranchType, "SLL shamt=0",
            slv_unsigned(1), slv_unsigned(0), "0100", "000", slv_unsigned(1), '0');

        check_case(A, B, ALUCtrl, BranchType, "SLL shamt=1",
            slv_unsigned(1), slv_unsigned(1), "0100", "000", slv_unsigned(2), '0');

        check_case(A, B, ALUCtrl, BranchType, "SLL shamt=31",
            slv_unsigned(1), x"0000001F", "0100", "000", x"80000000", '0');

        -- SRL
        check_case(A, B, ALUCtrl, BranchType, "SRL shamt=1",
            x"80000000", slv_unsigned(1), "0101", "000", x"40000000", '0');

        check_case(A, B, ALUCtrl, BranchType, "SRL shamt=31",
            x"80000000", x"0000001F", "0101", "000", x"00000001", '0');

        -- SLT (signed)
        check_case(A, B, ALUCtrl, BranchType, "SLT -1 < 1",
            slv_signed(-1), slv_signed(1), "0111", "000", x"00000001", '0');

        check_case(A, B, ALUCtrl, BranchType, "SLT 1 < -1 false",
            slv_signed(1), slv_signed(-1), "0111", "000", x"00000000", '0');

        -- SLTU (unsigned)
        check_case(A, B, ALUCtrl, BranchType, "SLTU 0 < 1",
            slv_unsigned(0), slv_unsigned(1), "1000", "000", x"00000001", '0');

        check_case(A, B, ALUCtrl, BranchType, "SLTU FFFFFFFF < 1 false",
            x"FFFFFFFF", slv_unsigned(1), "1000", "000", x"00000000", '0');

        -- SRA
        check_case(A, B, ALUCtrl, BranchType, "SRA shamt=1",
            x"80000000", slv_unsigned(1), "1001", "000", x"C0000000", '0');

        check_case(A, B, ALUCtrl, BranchType, "SRA shamt=31",
            x"80000000", x"0000001F", "1001", "000", x"FFFFFFFF", '0');

        -- Default ALUCtrl
        check_case(A, B, ALUCtrl, BranchType, "ALU default",
            x"12345678", x"9ABCDEF0", "1111", "000", x"00000000", '0');

        -- Branch conditions (BEQ/BNE)
        check_case(A, B, ALUCtrl, BranchType, "BEQ true",
            x"00000001", x"00000001", "0000", "000", x"00000001", '1');

        check_case(A, B, ALUCtrl, BranchType, "BEQ false",
            x"00000001", x"00000002", "0000", "000", x"00000000", '0');

        check_case(A, B, ALUCtrl, BranchType, "BNE true",
            x"00000001", x"00000002", "0000", "001", x"00000000", '1');

        check_case(A, B, ALUCtrl, BranchType, "BNE false",
            x"00000001", x"00000001", "0000", "001", x"00000001", '0');

        -- Signed branches
        check_case(A, B, ALUCtrl, BranchType, "BLT true",
            slv_signed(-1), slv_signed(1), "0000", "100", x"FFFFFFFF", '1');

        check_case(A, B, ALUCtrl, BranchType, "BLT false",
            slv_signed(1), slv_signed(-1), "0000", "100", x"00000000", '0');

        check_case(A, B, ALUCtrl, BranchType, "BGE true",
            slv_signed(1), slv_signed(-1), "0000", "101", x"00000000", '1');

        check_case(A, B, ALUCtrl, BranchType, "BGE false",
            slv_signed(-1), slv_signed(1), "0000", "101", x"FFFFFFFF", '0');

        -- Unsigned branches
        check_case(A, B, ALUCtrl, BranchType, "BLTU true",
            slv_unsigned(1), x"00000002", "0000", "110", x"00000003", '1');

        check_case(A, B, ALUCtrl, BranchType, "BLTU false",
            x"FFFFFFFF", slv_unsigned(1), "0000", "110", x"00000000", '0');

        check_case(A, B, ALUCtrl, BranchType, "BGEU true",
            x"FFFFFFFF", slv_unsigned(1), "0000", "111", x"00000000", '1');

        check_case(A, B, ALUCtrl, BranchType, "BGEU false",
            slv_unsigned(1), x"00000002", "0000", "111", x"00000003", '0');

        -- Branch default
        check_case(A, B, ALUCtrl, BranchType, "BR default",
            x"00000001", x"00000002", "0000", "010", x"00000000", '0');

        report "All ALU tests passed." severity note;
        wait;
    end process;
end behavior;
