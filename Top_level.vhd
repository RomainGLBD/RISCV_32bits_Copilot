library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Top_level is
	Port (
		clk        : in  STD_LOGIC;
		rst      : in  STD_LOGIC;
		uart_rx    : in  STD_LOGIC;
		tx         : out STD_LOGIC;
		uart_load_enable : in STD_LOGIC;
		led        : out STD_LOGIC
	);
end Top_level;

architecture Structural of Top_level is
    signal reset : STD_LOGIC ;
	signal pc_out_s         : STD_LOGIC_VECTOR(31 downto 0);
	signal pc_plus4_s       : STD_LOGIC_VECTOR(31 downto 0);
	signal pc_next_s        : STD_LOGIC_VECTOR(31 downto 0);
    signal instruction_s    : STD_LOGIC_VECTOR(31 downto 0);
    signal instruction_reg_s: STD_LOGIC_VECTOR(31 downto 0);
    signal pc_instr_s       : STD_LOGIC_VECTOR(31 downto 0);
    signal pc_plus4_instr_s : STD_LOGIC_VECTOR(31 downto 0);
	signal imm_s            : STD_LOGIC_VECTOR(31 downto 0);
	signal br_jal_adr_s     : STD_LOGIC_VECTOR(31 downto 0);
	signal jalr_adr_s       : STD_LOGIC_VECTOR(31 downto 0);

	signal sel_pc_s         : STD_LOGIC_VECTOR(1 downto 0);
	signal pc_we_s          : STD_LOGIC;
	signal ir_we_s          : STD_LOGIC;
	signal rf_wen_s         : STD_LOGIC;
	signal type_imm_s       : STD_LOGIC_VECTOR(2 downto 0);
	signal sel_wb_s         : STD_LOGIC_VECTOR(1 downto 0);
	signal sel_op2_s        : STD_LOGIC;
	signal dmem_we_req_s    : STD_LOGIC;
	signal dmem_wmask_s     : STD_LOGIC_VECTOR(3 downto 0);
	signal dmem_wen_s       : STD_LOGIC_VECTOR(3 downto 0);
	signal opcode_s         : STD_LOGIC_VECTOR(6 downto 0);
	signal func3_s          : STD_LOGIC_VECTOR(2 downto 0);
	signal func7_s          : STD_LOGIC_VECTOR(6 downto 0);

	signal alu_ctrl_s       : STD_LOGIC_VECTOR(3 downto 0);
	signal br_type_s        : STD_LOGIC_VECTOR(2 downto 0);
	signal alu_a_s          : STD_LOGIC_VECTOR(31 downto 0);
	signal alu_b_s          : STD_LOGIC_VECTOR(31 downto 0);
	signal alu_result_s     : STD_LOGIC_VECTOR(31 downto 0);
	signal alu_branch_s     : STD_LOGIC;
	signal branch_to_fsm_s  : STD_LOGIC;
	signal load_sel_s       : STD_LOGIC_VECTOR(2 downto 0);
	signal load_mask_s      : STD_LOGIC_VECTOR(3 downto 0);

	signal rs1_data_s       : STD_LOGIC_VECTOR(31 downto 0);
	signal rs2_data_s       : STD_LOGIC_VECTOR(31 downto 0);
	signal wb_data_s        : STD_LOGIC_VECTOR(31 downto 0);
	signal dmem_out_s       : STD_LOGIC_VECTOR(31 downto 0);
	signal load_data_s      : STD_LOGIC_VECTOR(31 downto 0);

	signal uart_rx_byte_s   : STD_LOGIC_VECTOR(7 downto 0);
	signal uart_rx_valid_s  : STD_LOGIC;
	signal uart_loading_s   : STD_LOGIC;

	signal uart_imem_we_s   : STD_LOGIC;
	signal uart_imem_addr_s : STD_LOGIC_VECTOR(31 downto 0);
	signal uart_imem_data_s : STD_LOGIC_VECTOR(31 downto 0);

	signal uart_dmem_we_s   : STD_LOGIC_VECTOR(3 downto 0);
	signal uart_dmem_addr_s : STD_LOGIC_VECTOR(31 downto 0);
	signal uart_dmem_data_s : STD_LOGIC_VECTOR(31 downto 0);

	signal imem_we_s        : STD_LOGIC;
	signal imem_addr_s      : STD_LOGIC_VECTOR(31 downto 0);
	signal imem_data_s      : STD_LOGIC_VECTOR(31 downto 0);

	signal dmem_addr_s      : STD_LOGIC_VECTOR(31 downto 0);
	signal dmem_data_in_s   : STD_LOGIC_VECTOR(31 downto 0);
	signal cpu_reset_s      : STD_LOGIC;

	signal uart_tx_s        : STD_LOGIC;
begin
    reset <= rst ;
	-- Connect outputs
	tx <= uart_tx_s;
	led <= uart_loading_s;

	-- Keep branch feedback active only for branch opcodes to avoid false branching.
	branch_to_fsm_s <= alu_branch_s when opcode_s = "1100011" else '0';
	jalr_adr_s <= alu_result_s(31 downto 1) & '0';
	dmem_wen_s <= uart_dmem_we_s when (uart_load_enable = '1' and uart_loading_s = '1') else
		      dmem_wmask_s when dmem_we_req_s = '1' else
		      (others => '0');
	dmem_addr_s <= uart_dmem_addr_s when (uart_load_enable = '1' and uart_loading_s = '1') else alu_result_s;
	dmem_data_in_s <= uart_dmem_data_s when (uart_load_enable = '1' and uart_loading_s = '1') else rs2_data_s;

	imem_we_s <= uart_imem_we_s when (uart_load_enable = '1' and uart_loading_s = '1') else '0';
	imem_addr_s <= uart_imem_addr_s when (uart_load_enable = '1' and uart_loading_s = '1') else pc_out_s;
	imem_data_s <= uart_imem_data_s when (uart_load_enable = '1' and uart_loading_s = '1') else (others => '0');

	cpu_reset_s <= reset or (uart_load_enable and uart_loading_s);

	-- RV32I ALU A source selection.
	-- AUIPC: PC + imm, LUI: 0 + imm, others: rs1 (+ op2)
	with opcode_s select alu_a_s <=
		pc_instr_s      when "0010111", -- AUIPC
		(others => '0') when "0110111", -- LUI
		rs1_data_s      when others;

	u_pc: entity work.Programm_Counter
		port map (
			clk     => clk,
			reset   => cpu_reset_s,
				pc_we   => pc_we_s,
			mux_out => pc_next_s,
			pc_out  => pc_out_s
		);

	    u_uart_rx: entity work.UART_recv
		    port map (
			clk    => clk,
			reset  => reset,
			rx     => uart_rx,
			dat    => uart_rx_byte_s,
			dat_en => uart_rx_valid_s
		);

	u_uart_mem_loader: entity work.uart_mem_loader
		port map (
			clk            => clk,
			reset          => reset,
			rx_data        => uart_rx_byte_s,
			rx_data_valid  => uart_rx_valid_s,
			loading_active => uart_loading_s,
			imem_we        => uart_imem_we_s,
			imem_addr      => uart_imem_addr_s,
			imem_data      => uart_imem_data_s,
			dmem_we        => uart_dmem_we_s,
			dmem_addr      => uart_dmem_addr_s,
			dmem_data      => uart_dmem_data_s
		);

	u_add4: entity work.add_four
		port map (
			pc_out   => pc_out_s,
			pc_plus4 => pc_plus4_s
		);

	u_add_imm: entity work.add_imm
		port map (
			IMM        => imm_s,
			pc_out     => pc_instr_s,
			br_jal_adr => br_jal_adr_s
		);

	u_mux_pc: entity work.mux_pc
		port map (
			jalr_adr   => jalr_adr_s,
			jr_jal_adr => br_jal_adr_s,
			br_jal_adr => br_jal_adr_s,
			pc_plus4   => pc_plus4_s,
			sel_pc     => sel_pc_s,
			mux_out    => pc_next_s
		);

	u_imem: entity work.Memoire_instructions
		port map (
			clk      => clk,
			addr     => imem_addr_s,
			data_out => instruction_s,
			data_in  => imem_data_s,
			we       => imem_we_s
		);

	process(clk, cpu_reset_s)
	begin
		if cpu_reset_s = '1' then
				instruction_reg_s <= (others => '0');
			pc_instr_s <= (others => '0');
			pc_plus4_instr_s <= (others => '0');
		elsif rising_edge(clk) then
				if ir_we_s = '1' then
						instruction_reg_s <= instruction_s;
				pc_instr_s <= pc_out_s;
				pc_plus4_instr_s <= pc_plus4_s;
				end if;
		end if;
	end process;

	u_fsm: entity work.FSM_control
		port map (
			clk            => clk,
			reset          => cpu_reset_s,
				instruction    => instruction_reg_s,
			branch_control => branch_to_fsm_s,
			sel_pc         => sel_pc_s,
			pc_we          => pc_we_s,
			ir_we          => ir_we_s,
			rf_wen         => rf_wen_s,
			type_imm       => type_imm_s,
			sel_wb         => sel_wb_s,
			sel_op2        => sel_op2_s,
			dmem_wen       => dmem_we_req_s,
			opcode_out     => opcode_s,
			func3_out      => func3_s,
			func7_out      => func7_s
		);

	u_decode: entity work.Decode
		port map (
			opcode          => opcode_s,
			func3           => func3_s,
			func7           => func7_s,
			addr_lsb        => alu_result_s(1 downto 0),
			sel_fnct_alu    => alu_ctrl_s,
			sel_fnct_br_alu => br_type_s,
			dmem_wmask      => dmem_wmask_s,
			load_sel        => load_sel_s,
			load_mask       => load_mask_s
		);

	u_rf: entity work.File_de_registres
		port map (
			clk      => clk,
			we       => rf_wen_s,
				wr_addr  => instruction_reg_s(11 downto 7),
			wr_data  => wb_data_s,
				rd_addr1 => instruction_reg_s(19 downto 15),
				rd_addr2 => instruction_reg_s(24 downto 20),
			rd_data1 => rs1_data_s,
			rd_data2 => rs2_data_s
		);

	u_imm_gen: entity work.gen_imm
		port map (
				Instr    => instruction_reg_s,
			type_imm => type_imm_s,
			imm_out  => imm_s
		);

	u_mux_pre_alu: entity work.mux_pre_alu
		port map (
			RD2     => rs2_data_s,
			IMM     => imm_s,
			sel_op2 => sel_op2_s,
			B       => alu_b_s
		);

	u_alu: entity work.ALU_32_bits
		port map (
			A           => alu_a_s,
			B           => alu_b_s,
			ALUCtrl     => alu_ctrl_s,
			BranchType  => br_type_s,
			Result      => alu_result_s,
			branchement => alu_branch_s
		);

	u_dmem: entity work.Memoire_data
		port map (
			clk      => clk,
			we       => dmem_wen_s,
			addr     => dmem_addr_s,
			data_in  => dmem_data_in_s,
			data_out => dmem_out_s
		);

		u_load_manager: entity work.load_manager
			port map (
				dmem_out  => dmem_out_s,
				load_sel  => load_sel_s,
				load_mask => load_mask_s,
				load_data => load_data_s
			);

	u_mux_wb: entity work.mux_post_alu
		port map (
			D       => load_data_s,
			alu_out => alu_result_s,
			pc_out  => pc_plus4_instr_s,
			sel_wb  => sel_wb_s,
			WD      => wb_data_s
		);

	u_uart_tx: entity work.UART_fifoed_send
		generic map (
			baudrate        => 115200,
			clock_frequency => 100000000
		)
		port map (
			clk_100MHz => clk,
			reset      => reset,
			dat_en     => '0',
			dat        => (others => '0'),
			TX         => uart_tx_s,
			fifo_empty => open,
			fifo_afull => open,
			fifo_full  => open
		);

end Structural;
