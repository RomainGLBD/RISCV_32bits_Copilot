-- FILEPATH: testbench_file_de_registres.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_File_de_registres is
end tb_File_de_registres;

architecture behavior of tb_File_de_registres is

    -- Component Declaration for the Unit Under Test (UUT)
    component File_de_registres
    Port (
        clk         : in  STD_LOGIC;
        we          : in  STD_LOGIC;
        wr_addr     : in  STD_LOGIC_VECTOR(4 downto 0);
        wr_data     : in  STD_LOGIC_VECTOR(31 downto 0);
        rd_addr1    : in  STD_LOGIC_VECTOR(4 downto 0);
        rd_addr2    : in  STD_LOGIC_VECTOR(4 downto 0);
        rd_data1    : out STD_LOGIC_VECTOR(31 downto 0);
        rd_data2    : out STD_LOGIC_VECTOR(31 downto 0)
    );
    end component;

    -- Signals for the testbench
    signal clk         : STD_LOGIC := '0';
    signal we          : STD_LOGIC;
    signal wr_addr     : STD_LOGIC_VECTOR(4 downto 0);
    signal wr_data     : STD_LOGIC_VECTOR(31 downto 0);
    signal rd_addr1    : STD_LOGIC_VECTOR(4 downto 0);
    signal rd_addr2    : STD_LOGIC_VECTOR(4 downto 0);
    signal rd_data1    : STD_LOGIC_VECTOR(31 downto 0);
    signal rd_data2    : STD_LOGIC_VECTOR(31 downto 0);

    -- Clock period definition
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: File_de_registres
    Port map (
        clk => clk,
        we => we,
        wr_addr => wr_addr,
        wr_data => wr_data,
        rd_addr1 => rd_addr1,
        rd_addr2 => rd_addr2,
        rd_data1 => rd_data1,
        rd_data2 => rd_data2
    );

    -- Clock process
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize Inputs
        we <= '0';
        wr_addr <= (others => '0');
        wr_data <= (others => '0');
        rd_addr1 <= (others => '0');
        rd_addr2 <= (others => '0');
        wait for 20 ns;

        -- Test Case 1: Write to register 0
        we <= '1';
        wr_addr <= "00000"; -- Writing to register 0
        wr_data <= "00000000000000000000000000000001"; -- Writing value 1
        wait for clk_period;

        -- Test Case 2: Read from register 0
        we <= '0';
        rd_addr1 <= "00000"; -- Reading from register 0
        wait for clk_period;
        assert rd_data1 = "00000000000000000000000000000001" report "Error: Register 0 did not return expected value." severity error;

        -- Test Case 3: Write to register 1
        we <= '1';
        wr_addr <= "00001"; -- Writing to register 1
        wr_data <= "00000000000000000000000000000010"; -- Writing value 2
        wait for clk_period;

        -- Test Case 4: Read from register 1
        we <= '0';
        rd_addr1 <= "00001"; -- Reading from register 1
        wait for clk_period;
        assert rd_data1 = "00000000000000000000000000000010" report "Error: Register 1 did not return expected value." severity error;

        -- Test Case 5: Read from register 0 again
        rd_addr2 <= "00000"; -- Reading from register 0
        wait for clk_period;
        assert rd_data2 = "00000000000000000000000000000001" report "Error: Register 0 did not return expected value." severity error;

        -- End simulation
        wait;
    end process;

end behavior;