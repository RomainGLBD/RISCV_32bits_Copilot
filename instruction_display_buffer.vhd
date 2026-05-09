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
        display_valid   : out STD_LOGIC := '0';  -- High when a valid instr is being displayed
        instr_changed   : out STD_LOGIC := '0';  -- Pulse (1 cycle) when moving to next instruction
        
        -- Debug: expose FIFO count and write signal
        fifo_count_out  : out INTEGER range 0 to 32 := 0;
        imem_we_out     : out STD_LOGIC := '0'
    );
end instruction_display_buffer;

architecture Behavioral of instruction_display_buffer is

    -- FIFO: 32 instructions deep, 32 bits each
    type fifo_array is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
    signal fifo : fifo_array := (others => (others => '0'));
    
    signal wr_ptr : INTEGER range 0 to 31 := 0;
    signal rd_ptr : INTEGER range 0 to 31 := 0;
    signal fifo_count : INTEGER range 0 to 32 := 0;
    
    -- Display timing
    signal cycle_counter : UNSIGNED(25 downto 0) := (others => '0');  -- ~26 bits for 1s at 50 MHz
    constant CYCLES_1S : UNSIGNED(25 downto 0) := to_unsigned(50_000_000, 26);
    
    signal current_instr : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal display_active : STD_LOGIC := '0';
    signal prev_fifo_count : INTEGER range 0 to 32 := 0;
    signal first_capture : STD_LOGIC := '1';

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
            fifo <= (others => (others => '0'));
            prev_fifo_count <= 0;
            first_capture <= '1';
        elsif rising_edge(clk) then
            
            -- Capture incoming instruction into FIFO
            if imem_we = '1' and fifo_count < 32 then
                fifo(wr_ptr) <= imem_data;
                wr_ptr <= (wr_ptr + 1) mod 32;
                fifo_count <= fifo_count + 1;
            end if;
            
            -- Display state machine
            if fifo_count > 0 then
                display_active <= '1';
                
                -- Capture first instruction immediately
                if first_capture = '1' then
                    current_instr <= fifo(rd_ptr);
                    first_capture <= '0';
                    cycle_counter <= (others => '0');
                -- Subsequent instructions: wait 1 second per instruction
                elsif cycle_counter >= CYCLES_1S then
                    rd_ptr <= (rd_ptr + 1) mod 32;
                    fifo_count <= fifo_count - 1;
                    -- Pre-load next instruction
                    current_instr <= fifo((rd_ptr + 1) mod 32);
                    cycle_counter <= (others => '0');
                else
                    cycle_counter <= cycle_counter + 1;
                end if;
            else
                -- FIFO empty: display stays frozen on last instruction
                -- (keep current_instr, display_active, cycle_counter as is)
                -- Ready for new sequence when instructions arrive
                if display_active = '1' then
                    first_capture <= '1';  -- Ready to capture next batch
                end if;
            end if;
            
            prev_fifo_count <= fifo_count;
        end if;
    end process;
    
    -- Generate 1-cycle pulse when instruction changes
    instr_changed <= '1' when ((first_capture = '0' and cycle_counter = CYCLES_1S and fifo_count > 0) or
                              (first_capture = '1' and fifo_count > 0 and prev_fifo_count = 0)) else '0';
    
    display_instr <= current_instr;
    display_valid <= display_active;
    
    -- Debug outputs
    fifo_count_out <= fifo_count;
    imem_we_out <= imem_we;

end Behavioral;
