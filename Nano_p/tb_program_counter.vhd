----------------------------------------------------------------------------------
-- Program Counter Testbench (VHDL-93 Compatible)
-- University of Moratuwa | Team: 240348, 240351, 240347, 240343
--
-- Tests:
--   1. Async reset → PC = 0
--   2. Normal increment (enable=1, load=0)
--   3. Load (jump): PC jumps to arbitrary address
--   4. Enable=0 freezes PC
--   5. Reset mid-count
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_program_counter is
end tb_program_counter;

architecture Behavioral of tb_program_counter is

    component program_counter
        Port (
            clk    : in  STD_LOGIC;
            reset  : in  STD_LOGIC;
            enable : in  STD_LOGIC;
            load   : in  STD_LOGIC;
            pc_in  : in  STD_LOGIC_VECTOR(2 downto 0);
            pc_out : out STD_LOGIC_VECTOR(2 downto 0)
        );
    end component;

    constant CLK_PERIOD : time := 20 ns;

    signal clk    : STD_LOGIC := '0';
    signal reset  : STD_LOGIC := '1';
    signal enable : STD_LOGIC := '0';
    signal load   : STD_LOGIC := '0';
    signal pc_in  : STD_LOGIC_VECTOR(2 downto 0) := "000";
    signal pc_out : STD_LOGIC_VECTOR(2 downto 0);

begin
    clk <= NOT clk after CLK_PERIOD / 2;

    UUT: program_counter
        port map (
            clk    => clk,
            reset  => reset,
            enable => enable,
            load   => load,
            pc_in  => pc_in,
            pc_out => pc_out
        );

    process
    begin
        -------------------------------------------------------
        -- 1. Reset: PC must be 0 immediately (async)
        -------------------------------------------------------
        reset  <= '1';
        enable <= '0';
        load   <= '0';
        wait for 15 ns;  -- check between clock edges
        assert pc_out = "000"
            report "FAIL: Reset did not set PC to 0" severity ERROR;

        -------------------------------------------------------
        -- 2. Release reset, enable increment
        -------------------------------------------------------
        wait until rising_edge(clk);
        reset  <= '0';
        enable <= '1';
        load   <= '0';

        -- Increment 0 → 1
        wait until rising_edge(clk); wait for 1 ns;
        assert pc_out = "001"
            report "FAIL: PC should be 1 after first increment" severity ERROR;

        -- Increment 1 → 2
        wait until rising_edge(clk); wait for 1 ns;
        assert pc_out = "010"
            report "FAIL: PC should be 2" severity ERROR;

        -- Increment 2 → 3
        wait until rising_edge(clk); wait for 1 ns;
        assert pc_out = "011"
            report "FAIL: PC should be 3" severity ERROR;

        -------------------------------------------------------
        -- 3. Load (jump to address 7)
        -------------------------------------------------------
        load  <= '1';
        pc_in <= "111";
        wait until rising_edge(clk); wait for 1 ns;
        assert pc_out = "111"
            report "FAIL: PC load to 7 failed" severity ERROR;

        -- Load to 5
        pc_in <= "101";
        wait until rising_edge(clk); wait for 1 ns;
        assert pc_out = "101"
            report "FAIL: PC load to 5 failed" severity ERROR;

        -------------------------------------------------------
        -- 4. Load=0 now, enable=1 — should increment from 5
        -------------------------------------------------------
        load  <= '0';
        pc_in <= "000";  -- irrelevant now
        wait until rising_edge(clk); wait for 1 ns;
        assert pc_out = "110"
            report "FAIL: PC should increment from 5 to 6" severity ERROR;

        wait until rising_edge(clk); wait for 1 ns;
        assert pc_out = "111"
            report "FAIL: PC should be 7" severity ERROR;

        -- Wrap around: 3-bit counter wraps 7 → 0
        wait until rising_edge(clk); wait for 1 ns;
        assert pc_out = "000"
            report "FAIL: PC 3-bit wrap 7->0 failed" severity ERROR;

        -------------------------------------------------------
        -- 5. Enable = 0 → PC freezes
        -------------------------------------------------------
        enable <= '0';
        wait until rising_edge(clk); wait for 1 ns;
        assert pc_out = "000"
            report "FAIL: PC incremented when enable=0" severity ERROR;
        wait until rising_edge(clk); wait for 1 ns;
        assert pc_out = "000"
            report "FAIL: PC incremented when enable=0 (2nd check)" severity ERROR;

        -------------------------------------------------------
        -- 6. Async reset mid-count
        -------------------------------------------------------
        enable <= '1';
        wait until rising_edge(clk); wait for 1 ns;
        -- PC = 1 now
        reset <= '1';
        wait for 5 ns;  -- async — doesn't need clock
        assert pc_out = "000"
            report "FAIL: Async reset mid-count did not clear PC" severity ERROR;
        reset <= '0';

        -------------------------------------------------------
        -- Done
        -------------------------------------------------------
        report "ALL PROGRAM COUNTER TESTS PASSED" severity NOTE;
        wait;
    end process;

end Behavioral;
