library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity boot_loader is
    generic (
        RAM_ADR_WIDTH : integer := 6;
        RAM_SIZE      : integer := 64);
    port (
        rst         : in  std_logic;
        clk         : in  std_logic;
        rx          : in  std_logic;
        tx          : out std_logic;
        boot        : out std_logic;
        scan_memory : in  std_logic;
        ram_out     : in  std_logic_vector(15 downto 0);
        ram_rw      : out std_logic;
        ram_adr     : out std_logic_vector(RAM_ADR_WIDTH - 1 downto 0);
        ram_in      : out std_logic_vector(15 downto 0));
end boot_loader;

architecture Behavioral of boot_loader is

    component UART_recv is
        port (
            clk    : in  std_logic;
            reset  : in  std_logic;
            rx     : in  std_logic;
            dat    : out std_logic_vector (7 downto 0);
            dat_en : out std_logic);
    end component;

    component byte_2_word is
        port (
            rst     : in  std_logic;
            clk     : in  std_logic;
            byte_dv : in  std_logic;
            byte    : in  std_logic_vector (7 downto 0);
            word_dv : out std_logic;
            word    : out std_logic_vector (15 downto 0));
    end component;

    component word_2_byte is
        port (
            rst     : in  std_logic;
            clk     : in  std_logic;
            word_dv : in  std_logic;
            word    : in  std_logic_vector (15 downto 0);
            byte_dv : out std_logic;
            byte    : out std_logic_vector (7 downto 0));
    end component;

    component UART_fifoed_send is
        generic (
            fifo_size             : integer := 4096;
            fifo_almost           : integer := 4090;
            drop_oldest_when_full : boolean := false;
            asynch_fifo_full      : boolean := true;
            baudrate              : integer := 921600; -- [bps]
            clock_frequency       : integer := 100000000 -- [Hz]
        );
        port (
            clk_100MHz : in  std_logic;
            reset      : in  std_logic;
            dat_en     : in  std_logic;
            dat        : in  std_logic_vector (7 downto 0);
            TX         : out std_logic;
            fifo_empty : out std_logic;
            fifo_afull : out std_logic;
            fifo_full  : out std_logic
        );
    end component;

    signal rx_byte, tx_byte                  : std_logic_vector(7 downto 0);
    signal rx_data_valid, rx_data_valid_dly : std_logic;
    signal tx_data_valid                    : std_logic;
    signal rx_word_valid                    : std_logic;

    signal rx_byte_reg, rx_byte_reg2        : std_logic_vector(7 downto 0);
    signal rx_word                          : std_logic_vector(15 downto 0);
    signal byte_count                       : unsigned(1 downto 0);
    signal rx_byte_count                    : unsigned(RAM_ADR_WIDTH - 1 downto 0);
    signal enable_rx_byte_counter           : std_logic;
    signal init_byte_counter                : std_logic;

    type t_state is (INIT, WAIT_RX_BYTE, INCR_RX_BYTE_COUNTER, WRITE_RX_BYTE, WAIT_SCAN_MEM, READ_TX_BYTE, INCR_TX_BYTE_COUNTER, ENABLE_TX, WAIT_8K_CYCLE, OVER);
    signal current_state, future_state      : t_state;

    signal tx_cycle_count                   : unsigned(14 downto 0);
    signal init_tx_cycle_count              : std_logic;
    signal tx_cycle_count_over              : std_logic;
    signal tx_data_valid_dly                : std_logic;
    signal tx_word_valid                    : std_logic;

begin

    ram_adr <= std_logic_vector(rx_byte_count);
    ram_in <= rx_word;

    inst_uart_recv : UART_recv
    port map(
        clk => clk,
        reset => rst,
        rx => rx,
        dat => rx_byte,
        dat_en => rx_data_valid);

    inst_uart_send : UART_fifoed_send
    generic map(
        fifo_size => 4,
        fifo_almost => 2,
        drop_oldest_when_full => false,
        asynch_fifo_full => true,
        baudrate => 115200,
        clock_frequency => 100000000)
    port map(
        clk_100MHz => clk,
        reset => rst,
        dat_en => tx_word_valid,
        dat => tx_byte,
        TX => tx,
        fifo_empty => open,
        fifo_afull => open,
        fifo_full => open);
    ---------------------
    -- rx_byte_register
    ---------------------

    b2w : byte_2_word
    port map(
        rst => rst,
        clk => clk,
        byte_dv => rx_data_valid,
        byte => rx_byte,
        word_dv => rx_word_valid,
        word => rx_word);
    ---------------------
    -- rx_byte_counter
    ---------------------

    process (rst, clk)
    begin
        if (rst = '1') then
            rx_byte_count <= (others => '0');
        elsif (rising_edge(clk)) then
            if (init_byte_counter = '1') then
                rx_byte_count <= (others => '0');
            elsif (enable_rx_byte_counter = '1') then
                if (rx_byte_count = to_unsigned(RAM_SIZE - 1, RAM_ADR_WIDTH)) then
                    rx_byte_count <= (others => '0');
                else
                    rx_byte_count <= rx_byte_count + to_unsigned(1, RAM_ADR_WIDTH);
                end if;
            end if;
        end if;
    end process;

    w2b : word_2_byte
    port map(
        rst => rst,
        clk => clk,
        word_dv => tx_data_valid,
        word => ram_out,
        byte_dv => tx_word_valid,
        byte => tx_byte);

    ---------------------
    -- tx_cycle_counter
    ---------------------

    process (rst, clk)
    begin
        if (rst = '1') then
            tx_cycle_count <= (others => '0');
        elsif (rising_edge(clk)) then
            if (init_tx_cycle_count = '1') then
                tx_cycle_count <= (others => '0');
                tx_cycle_count_over <= '0';
            elsif (tx_cycle_count = to_unsigned(18000, 15)) then
                tx_cycle_count_over <= '1';
                tx_cycle_count <= (others => '0');
            else
                tx_cycle_count <= tx_cycle_count + to_unsigned(1, 15);
                tx_cycle_count_over <= '0';
            end if;
        end if;
    end process;

    ---------------------
    -- fsm
    ---------------------

    state_register : process (rst, clk)
    begin
        if (rst = '1') then
            current_state <= INIT;
        elsif (rising_edge (clk)) then
            current_state <= future_state;
        end if;
    end process;

    next_state_compute : process (current_state, rx_word_valid, rx_byte_count, scan_memory, tx_cycle_count_over)
    begin
        case current_state is
            when INIT =>
                future_state <= WAIT_RX_BYTE;
            when WAIT_RX_BYTE =>
                if (rx_word_valid = '1') then
                    future_state <= WRITE_RX_BYTE;
                else
                    future_state <= WAIT_RX_BYTE;
                end if;
            when WRITE_RX_BYTE =>
                if (rx_byte_count = to_unsigned(RAM_SIZE - 1, RAM_ADR_WIDTH)) then
                    future_state <= WAIT_SCAN_MEM;
                else
                    future_state <= INCR_RX_BYTE_COUNTER;
                end if;
            when INCR_RX_BYTE_COUNTER =>
                future_state <= WAIT_RX_BYTE;
            when WAIT_SCAN_MEM =>
                if (scan_memory = '1') then
                    future_state <= READ_TX_BYTE;
                else
                    future_state <= WAIT_SCAN_MEM;
                end if;
            when INCR_TX_BYTE_COUNTER =>
                future_state <= WAIT_8K_CYCLE;
            when WAIT_8K_CYCLE =>
                if (tx_cycle_count_over = '0') then
                    future_state <= WAIT_8K_CYCLE;
                else
                    future_state <= READ_TX_BYTE;
                end if;
            when READ_TX_BYTE =>
                future_state <= ENABLE_TX;
            when ENABLE_TX =>
                if (rx_byte_count = to_unsigned(RAM_SIZE - 1, RAM_ADR_WIDTH)) then
                    future_state <= OVER;
                else
                    future_state <= INCR_TX_BYTE_COUNTER;
                end if;
            when OVER =>
                future_state <= OVER;
        end case;
    end process;
    output_compute : process (current_state)
    begin
        case current_state is
            when INIT =>
                ram_rw <= '0';
                tx_data_valid <= '0';
                enable_rx_byte_counter <= '0';
                boot <= '1';
                init_byte_counter <= '1';
                init_tx_cycle_count <= '1';
            when WAIT_RX_BYTE =>
                ram_rw <= '0';
                tx_data_valid <= '0';
                enable_rx_byte_counter <= '0';
                boot <= '1';
                init_byte_counter <= '0';
                init_tx_cycle_count <= '1';
            when WRITE_RX_BYTE =>
                ram_rw <= '1';
                tx_data_valid <= '0';
                enable_rx_byte_counter <= '0';
                boot <= '1';
                init_byte_counter <= '0';
                init_tx_cycle_count <= '1';
            when INCR_RX_BYTE_COUNTER =>
                ram_rw <= '0';
                tx_data_valid <= '0';
                enable_rx_byte_counter <= '1';
                boot <= '1';
                init_byte_counter <= '0';
                init_tx_cycle_count <= '1';
            when WAIT_SCAN_MEM =>
                ram_rw <= '0';
                tx_data_valid <= '0';
                enable_rx_byte_counter <= '0';
                boot <= '0';
                init_byte_counter <= '1';
                init_tx_cycle_count <= '1';
            when READ_TX_BYTE =>
                ram_rw <= '0';
                tx_data_valid <= '0';
                enable_rx_byte_counter <= '0';
                boot <= '1';
                init_byte_counter <= '0';
                init_tx_cycle_count <= '1';
            when ENABLE_TX =>
                ram_rw <= '0';
                tx_data_valid <= '1';
                enable_rx_byte_counter <= '0';
                boot <= '1';
                init_byte_counter <= '0';
                init_tx_cycle_count <= '1';
            when INCR_TX_BYTE_COUNTER =>
                ram_rw <= '0';
                tx_data_valid <= '0';
                enable_rx_byte_counter <= '1';
                boot <= '1';
                init_byte_counter <= '0';
                init_tx_cycle_count <= '1';
            when WAIT_8K_CYCLE =>
                ram_rw <= '0';
                tx_data_valid <= '0';
                enable_rx_byte_counter <= '0';
                boot <= '1';
                init_byte_counter <= '0';
                init_tx_cycle_count <= '0';
            when OVER =>
                ram_rw <= '0';
                tx_data_valid <= '0';
                enable_rx_byte_counter <= '0';
                boot <= '0';
                init_byte_counter <= '0';
                init_tx_cycle_count <= '1';
        end case;
    end process;

end Behavioral;