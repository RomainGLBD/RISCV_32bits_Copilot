----------------------------------------------------------------------------------
-- Module: instruction_display_buffer
-- Purpose: Capture loaded instructions into a FIFO and display them one-by-one
--          with 1-second intervals on 7-segment display. Non-blocking to CPU.
-- Clock: 50 MHz
-- Delay: ~1 second per instruction (50,000,000 cycles)
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity instruction_display_buffer is
    Port (
        clk             : in  STD_LOGIC;
        rst             : in  STD_LOGIC;
        
        -- IMEM write signals (from uart_mem_loader or CPU)
        imem_we         : in  STD_LOGIC;
        imem_data       : in  STD_LOGIC_VECTOR(31 downto 0);
        
        -- Display output (8-char hex instruction)
        display_instr   : out STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
        display_valid   : out STD_LOGIC := '0';
        instr_changed   : out STD_LOGIC := '0';
        
        -- Debug: expose FIFO count and write signal
        fifo_count_out  : out INTEGER range 0 to 128 := 0;
        imem_we_out     : out STD_LOGIC := '0'
    );
end instruction_display_buffer;

architecture Behavioral of instruction_display_buffer is

    -- FIFO depth intentionally larger than the current program size.
    -- This avoids a practical limit when the instruction file grows.
    constant FIFO_DEPTH : integer := 128;

    type fifo_array is array (0 to FIFO_DEPTH - 1) of STD_LOGIC_VECTOR(31 downto 0);
    signal fifo : fifo_array := (others => (others => '0'));

    signal wr_ptr : integer range 0 to FIFO_DEPTH - 1 := 0;
    signal rd_ptr : integer range 0 to FIFO_DEPTH - 1 := 0;
    signal fifo_count : integer range 0 to FIFO_DEPTH := 0;

    -- 50 MHz clock => 50,000,000 cycles per second.
    signal cycle_counter : UNSIGNED(25 downto 0) := (others => '0');
    constant CYCLES_1S : UNSIGNED(25 downto 0) := to_unsigned(50_000_000 - 1, 26);

    signal current_instr : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal display_active : STD_LOGIC := '0';
    signal current_loaded : STD_LOGIC := '0';

begin

    process(clk, rst)
    begin
        if rst = '1' then
            wr_ptr <= 0;
            rd_ptr <= 0;
            fifo_count <= 0;
            cycle_counter <= (others => '0');
            current_instr <= (others => '0');
            display_active <= '0';
            current_loaded <= '0';
            fifo <= (others => (others => '0'));
        elsif rising_edge(clk) then
            -- Capture incoming instruction into FIFO.
            if imem_we = '1' and fifo_count < FIFO_DEPTH then
                fifo(wr_ptr) <= imem_data;
                if wr_ptr = FIFO_DEPTH - 1 then
                    wr_ptr <= 0;
                else
                    wr_ptr <= wr_ptr + 1;
                end if;
                fifo_count <= fifo_count + 1;
            end if;

            -- If nothing is currently displayed, start with the next queued instruction.
            if current_loaded = '0' then
                if fifo_count > 0 then
                    current_instr <= fifo(rd_ptr);
                    if rd_ptr = FIFO_DEPTH - 1 then
                        rd_ptr <= 0;
                    else
                        rd_ptr <= rd_ptr + 1;
                    end if;
                    fifo_count <= fifo_count - 1;
                    current_loaded <= '1';
                    display_active <= '1';
                    cycle_counter <= (others => '0');
                    instr_changed <= '1';
                else
                    display_active <= '0';
                    instr_changed <= '0';
                    cycle_counter <= (others => '0');
                end if;
            else
                display_active <= '1';
                instr_changed <= '0';

                if cycle_counter = CYCLES_1S then
                    cycle_counter <= (others => '0');

                    if fifo_count > 0 then
                        current_instr <= fifo(rd_ptr);
                        if rd_ptr = FIFO_DEPTH - 1 then
                            rd_ptr <= 0;
                        else
                            rd_ptr <= rd_ptr + 1;
                        end if;
                        fifo_count <= fifo_count - 1;
                        instr_changed <= '1';
                    else
                        -- No pending instruction: keep the last one visible.
                        current_loaded <= '0';
                    end if;
                else
                    cycle_counter <= cycle_counter + 1;
                end if;
            end if;
        end if;
    end process;

    display_instr <= current_instr;
    display_valid <= display_active;
    fifo_count_out <= fifo_count;
    imem_we_out <= imem_we;

end Behavioral;
