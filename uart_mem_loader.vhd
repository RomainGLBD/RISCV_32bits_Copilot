library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_mem_loader is
    port (
        clk            : in  STD_LOGIC;
        reset          : in  STD_LOGIC;
        rx_data        : in  STD_LOGIC_VECTOR(7 downto 0);
        rx_data_valid  : in  STD_LOGIC;

        loading_active : out STD_LOGIC;

        imem_we        : out STD_LOGIC;
        imem_addr      : out STD_LOGIC_VECTOR(31 downto 0);
        imem_data      : out STD_LOGIC_VECTOR(31 downto 0);

        dmem_we        : out STD_LOGIC_VECTOR(3 downto 0);
        dmem_addr      : out STD_LOGIC_VECTOR(31 downto 0);
        dmem_data      : out STD_LOGIC_VECTOR(31 downto 0)
    );
end uart_mem_loader;

architecture rtl of uart_mem_loader is
    type byte_array_t is array (0 to 9) of STD_LOGIC_VECTOR(7 downto 0);
    signal frame_s      : byte_array_t := (others => (others => '0'));
    signal byte_index_s : natural range 0 to 9 := 0;
    signal loading_s    : STD_LOGIC := '1';

    constant CMD_IMEM : STD_LOGIC_VECTOR(7 downto 0) := x"49"; -- 'I'
    constant CMD_DMEM : STD_LOGIC_VECTOR(7 downto 0) := x"44"; -- 'D'
    constant CMD_RUN  : STD_LOGIC_VECTOR(7 downto 0) := x"52"; -- 'R'
begin
    loading_active <= loading_s;

    process(clk, reset)
        variable checksum_v : STD_LOGIC_VECTOR(7 downto 0);
    begin
        if reset = '1' then
            frame_s       <= (others => (others => '0'));
            byte_index_s  <= 0;
            loading_s     <= '1';
            imem_we       <= '0';
            imem_addr     <= (others => '0');
            imem_data     <= (others => '0');
            dmem_we       <= (others => '0');
            dmem_addr     <= (others => '0');
            dmem_data     <= (others => '0');
        elsif rising_edge(clk) then
            imem_we <= '0';
            dmem_we <= (others => '0');

            if rx_data_valid = '1' then
                frame_s(byte_index_s) <= rx_data;

                if byte_index_s = 9 then
                    byte_index_s <= 0;

                    checksum_v := (others => '0');
                    for i in 0 to 8 loop
                        checksum_v := checksum_v xor frame_s(i);
                    end loop;

                    if checksum_v = rx_data then
                        if frame_s(0) = CMD_IMEM then
                            imem_we   <= '1';
                            imem_addr <= frame_s(4) & frame_s(3) & frame_s(2) & frame_s(1);
                            imem_data <= frame_s(8) & frame_s(7) & frame_s(6) & frame_s(5);
                        elsif frame_s(0) = CMD_DMEM then
                            dmem_we   <= "1111";
                            dmem_addr <= frame_s(4) & frame_s(3) & frame_s(2) & frame_s(1);
                            dmem_data <= frame_s(8) & frame_s(7) & frame_s(6) & frame_s(5);
                        elsif frame_s(0) = CMD_RUN then
                            loading_s <= '0';
                        end if;
                    end if;
                else
                    byte_index_s <= byte_index_s + 1;
                end if;
            end if;
        end if;
    end process;
end rtl;
