library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_Top_level is
end tb_Top_level;

architecture Behavioral of tb_Top_level is
    signal clk        : STD_LOGIC := '0';
    signal rst      : STD_LOGIC := '1';
    signal uart_rx    : STD_LOGIC := '1';
    signal uart_load_enable : STD_LOGIC := '0';

    constant CLK_PERIOD   : time := 10 ns;
    constant RESET_CYCLES : natural := 4;
    constant RUN_CYCLES   : natural := 50000;

    function has_unknown(s : STD_LOGIC_VECTOR) return boolean is
    begin
        for i in s'range loop
            if (s(i) /= '0') and (s(i) /= '1') then
                return true;
            end if;
        end loop;
        return false;
    end function;
begin
    -- Free-running clock for the full simulation.
    clk <= not clk after CLK_PERIOD / 2;

    uut: entity work.Top_level
        port map (
            clk        => clk,
            rst      => rst,
            uart_rx    => uart_rx,
            uart_load_enable => uart_load_enable
        );

    stim_proc: process
    begin
        -- Hold reset for a few cycles, then let the CPU run normally.
        for i in 1 to RESET_CYCLES loop
            wait until rising_edge(clk);
        end loop;
        rst <= '0';

        -- Run long enough to observe program flow and memory activity.
        for i in 1 to RUN_CYCLES loop
            wait until rising_edge(clk);

        end loop;

        report "Top_level simulation completed successfully" severity note;
        wait;
    end process;
end Behavioral;
