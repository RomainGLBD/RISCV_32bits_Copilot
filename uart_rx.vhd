library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity uart_rx is
    port (
        clk        : in  STD_LOGIC;
        reset      : in  STD_LOGIC;
        rx         : in  STD_LOGIC;
        data_byte  : out STD_LOGIC_VECTOR(7 downto 0);
        data_valid : out STD_LOGIC
    );
end uart_rx;

architecture Structural of uart_rx is
begin
    -- Wrapper around legacy UART receiver from the previous project.
    u_legacy_uart_recv: entity work.UART_recv
        port map (
            clk    => clk,
            reset  => reset,
            rx     => rx,
            dat    => data_byte,
            dat_en => data_valid
        );
end Structural;
