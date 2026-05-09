library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_gen_imm is
end tb_gen_imm;

architecture behavior of tb_gen_imm is
    component gen_imm
        port(
            Instr    : in  std_logic_vector(31 downto 0);
            type_imm : in  std_logic_vector(2 downto 0);
            imm_out  : out std_logic_vector(31 downto 0)
        );
    end component;

    signal Instr    : std_logic_vector(31 downto 0) := (others => '0');
    signal type_imm : std_logic_vector(2 downto 0) := (others => '0');
    signal imm_out  : std_logic_vector(31 downto 0);

    subtype reg_t is std_logic_vector(4 downto 0);

    function sign_ext(v : std_logic_vector) return std_logic_vector is
    begin
        return std_logic_vector(resize(signed(v), 32));
    end function;

    function slv_signed(val : integer; width : natural) return std_logic_vector is
    begin
        return std_logic_vector(to_signed(val, width));
    end function;

    function make_i(
        imm12  : std_logic_vector(11 downto 0);
        rs1    : reg_t;
        rd     : reg_t;
        funct3 : std_logic_vector(2 downto 0)
    ) return std_logic_vector is
    begin
        return imm12 & rs1 & funct3 & rd & "0000000"; -- opcode bits unused by gen_imm
    end function;

    function make_s(
        imm12  : std_logic_vector(11 downto 0);
        rs1    : reg_t;
        rs2    : reg_t;
        funct3 : std_logic_vector(2 downto 0)
    ) return std_logic_vector is
        variable v : std_logic_vector(31 downto 0);
    begin
        v := (others => '0');
        v(31 downto 25) := imm12(11 downto 5);
        v(24 downto 20) := rs2;
        v(19 downto 15) := rs1;
        v(14 downto 12) := funct3;
        v(11 downto 7)  := imm12(4 downto 0);
        return v;
    end function;

    function make_b(
        imm13  : std_logic_vector(12 downto 0);
        rs1    : reg_t;
        rs2    : reg_t;
        funct3 : std_logic_vector(2 downto 0)
    ) return std_logic_vector is
        variable v : std_logic_vector(31 downto 0);
    begin
        v := (others => '0');
        v(31)           := imm13(12);
        v(30 downto 25) := imm13(10 downto 5);
        v(24 downto 20) := rs2;
        v(19 downto 15) := rs1;
        v(14 downto 12) := funct3;
        v(11 downto 8)  := imm13(4 downto 1);
        v(7)            := imm13(11);
        return v;
    end function;

    function make_u(
        imm20 : std_logic_vector(19 downto 0);
        rd    : reg_t
    ) return std_logic_vector is
    begin
        return imm20 & rd & "0000000";
    end function;

    function make_j(
        imm21 : std_logic_vector(20 downto 0);
        rd    : reg_t
    ) return std_logic_vector is
        variable v : std_logic_vector(31 downto 0);
    begin
        v := (others => '0');
        v(31)           := imm21(20);
        v(30 downto 21) := imm21(10 downto 1);
        v(20)           := imm21(11);
        v(19 downto 12) := imm21(19 downto 12);
        v(11 downto 7)  := rd;
        return v;
    end function;

    function make_shamt(shamt : std_logic_vector(4 downto 0)) return std_logic_vector is
        variable v : std_logic_vector(31 downto 0);
    begin
        v := (others => '0');
        v(24 downto 20) := shamt;
        v(19 downto 15) := "10101";
        v(11 downto 7)  := "01010";
        return v;
    end function;

    procedure check_case(
        signal instr_sig : out std_logic_vector(31 downto 0);
        signal type_sig  : out std_logic_vector(2 downto 0);
        constant name    : in string;
        constant instr_in: in std_logic_vector(31 downto 0);
        constant typ_in  : in std_logic_vector(2 downto 0);
        constant expected: in std_logic_vector(31 downto 0)
    ) is
    begin
        instr_sig <= instr_in;
        type_sig  <= typ_in;
        wait for 1 ns;
        assert imm_out = expected
            report "FAIL: " & name
            severity error;
    end procedure;

    constant T_I   : std_logic_vector(2 downto 0) := "000";
    constant T_S   : std_logic_vector(2 downto 0) := "001";
    constant T_B   : std_logic_vector(2 downto 0) := "010";
    constant T_U   : std_logic_vector(2 downto 0) := "011";
    constant T_J   : std_logic_vector(2 downto 0) := "100";
    constant T_SH  : std_logic_vector(2 downto 0) := "101";
    constant T_X0  : std_logic_vector(2 downto 0) := "110";
    constant T_X1  : std_logic_vector(2 downto 0) := "111";

begin
    uut: gen_imm
        port map(
            Instr    => Instr,
            type_imm => type_imm,
            imm_out  => imm_out
        );

    stim_proc: process
        variable imm12 : std_logic_vector(11 downto 0);
        variable imm13 : std_logic_vector(12 downto 0);
        variable imm20 : std_logic_vector(19 downto 0);
        variable imm21 : std_logic_vector(20 downto 0);
        variable instr_word : std_logic_vector(31 downto 0);
        variable exp : std_logic_vector(31 downto 0);
    begin
        -- I-type
        imm12 := x"000";
        instr_word := make_i(imm12, "00010", "00001", "000");
        exp := sign_ext(imm12);
        check_case(Instr, type_imm, "I imm=0", instr_word, T_I, exp);

        imm12 := x"001";
        instr_word := make_i(imm12, "00010", "00001", "000");
        exp := sign_ext(imm12);
        check_case(Instr, type_imm, "I imm=1", instr_word, T_I, exp);

        imm12 := x"7FF";
        instr_word := make_i(imm12, "00010", "00001", "000");
        exp := sign_ext(imm12);
        check_case(Instr, type_imm, "I imm=2047", instr_word, T_I, exp);

        imm12 := x"800";
        instr_word := make_i(imm12, "00010", "00001", "000");
        exp := sign_ext(imm12);
        check_case(Instr, type_imm, "I imm=-2048", instr_word, T_I, exp);

        imm12 := x"FFF";
        instr_word := make_i(imm12, "00010", "00001", "000");
        exp := sign_ext(imm12);
        check_case(Instr, type_imm, "I imm=-1", instr_word, T_I, exp);

        -- S-type
        imm12 := x"000";
        instr_word := make_s(imm12, "00010", "00011", "010");
        exp := sign_ext(imm12);
        check_case(Instr, type_imm, "S imm=0", instr_word, T_S, exp);

        imm12 := x"123";
        instr_word := make_s(imm12, "00010", "00011", "010");
        exp := sign_ext(imm12);
        check_case(Instr, type_imm, "S imm=0x123", instr_word, T_S, exp);

        imm12 := x"7FF";
        instr_word := make_s(imm12, "00010", "00011", "010");
        exp := sign_ext(imm12);
        check_case(Instr, type_imm, "S imm=2047", instr_word, T_S, exp);

        imm12 := x"800";
        instr_word := make_s(imm12, "00010", "00011", "010");
        exp := sign_ext(imm12);
        check_case(Instr, type_imm, "S imm=-2048", instr_word, T_S, exp);

        imm12 := x"FFF";
        instr_word := make_s(imm12, "00010", "00011", "010");
        exp := sign_ext(imm12);
        check_case(Instr, type_imm, "S imm=-1", instr_word, T_S, exp);

        -- B-type (imm[0] must be 0)
        imm13 := slv_signed(0, 13);
        instr_word := make_b(imm13, "00010", "00011", "000");
        exp := sign_ext(imm13);
        check_case(Instr, type_imm, "B imm=0", instr_word, T_B, exp);

        imm13 := slv_signed(4, 13);
        instr_word := make_b(imm13, "00010", "00011", "000");
        exp := sign_ext(imm13);
        check_case(Instr, type_imm, "B imm=+4", instr_word, T_B, exp);

        imm13 := slv_signed(-4, 13);
        instr_word := make_b(imm13, "00010", "00011", "000");
        exp := sign_ext(imm13);
        check_case(Instr, type_imm, "B imm=-4", instr_word, T_B, exp);

        imm13 := slv_signed(4094, 13);
        instr_word := make_b(imm13, "00010", "00011", "000");
        exp := sign_ext(imm13);
        check_case(Instr, type_imm, "B imm=+4094", instr_word, T_B, exp);

        imm13 := slv_signed(-4096, 13);
        instr_word := make_b(imm13, "00010", "00011", "000");
        exp := sign_ext(imm13);
        check_case(Instr, type_imm, "B imm=-4096", instr_word, T_B, exp);

        -- U-type
        imm20 := x"00000";
        instr_word := make_u(imm20, "00001");
        exp := imm20 & x"000";
        check_case(Instr, type_imm, "U imm=0", instr_word, T_U, exp);

        imm20 := x"00001";
        instr_word := make_u(imm20, "00001");
        exp := imm20 & x"000";
        check_case(Instr, type_imm, "U imm=1", instr_word, T_U, exp);

        imm20 := x"ABCDE";
        instr_word := make_u(imm20, "00001");
        exp := imm20 & x"000";
        check_case(Instr, type_imm, "U imm=0xABCDE", instr_word, T_U, exp);

        imm20 := x"80000";
        instr_word := make_u(imm20, "00001");
        exp := imm20 & x"000";
        check_case(Instr, type_imm, "U imm=0x80000", instr_word, T_U, exp);

        -- J-type (imm[0] must be 0)
        imm21 := slv_signed(0, 21);
        instr_word := make_j(imm21, "00001");
        exp := sign_ext(imm21);
        check_case(Instr, type_imm, "J imm=0", instr_word, T_J, exp);

        imm21 := slv_signed(4, 21);
        instr_word := make_j(imm21, "00001");
        exp := sign_ext(imm21);
        check_case(Instr, type_imm, "J imm=+4", instr_word, T_J, exp);

        imm21 := slv_signed(-4, 21);
        instr_word := make_j(imm21, "00001");
        exp := sign_ext(imm21);
        check_case(Instr, type_imm, "J imm=-4", instr_word, T_J, exp);

        imm21 := slv_signed(1048574, 21);
        instr_word := make_j(imm21, "00001");
        exp := sign_ext(imm21);
        check_case(Instr, type_imm, "J imm=+1048574", instr_word, T_J, exp);

        imm21 := slv_signed(-1048576, 21);
        instr_word := make_j(imm21, "00001");
        exp := sign_ext(imm21);
        check_case(Instr, type_imm, "J imm=-1048576", instr_word, T_J, exp);

        -- Shamt
        instr_word := make_shamt("00000");
        exp := (31 downto 5 => '0') & "00000";
        check_case(Instr, type_imm, "SH shamt=0", instr_word, T_SH, exp);

        instr_word := make_shamt("00001");
        exp := (31 downto 5 => '0') & "00001";
        check_case(Instr, type_imm, "SH shamt=1", instr_word, T_SH, exp);

        instr_word := make_shamt("11111");
        exp := (31 downto 5 => '0') & "11111";
        check_case(Instr, type_imm, "SH shamt=31", instr_word, T_SH, exp);

        -- Others: force zero
        instr_word := (others => '1');
        exp := (others => '0');
        check_case(Instr, type_imm, "OTHERS type=110", instr_word, T_X0, exp);
        check_case(Instr, type_imm, "OTHERS type=111", instr_word, T_X1, exp);

        report "All gen_imm tests passed." severity note;
        wait;
    end process;
end behavior;
