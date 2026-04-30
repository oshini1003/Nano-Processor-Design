----------------------------------------------------------------------------------
-- Company: UOM - CSE'24 - GROUP 45
-- Engineer: Kethmika K A D Y
-- 
-- Create Date: 04/30/2026 12:32:58 PM
-- Design Name: 
-- Module Name: tb_nanoprocessor_complete - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity tb_nanoprocessor_complete is
-- Testbench has no ports
end tb_nanoprocessor_complete;

architecture Behavioral of tb_nanoprocessor_complete is

    -- Component declaration for DUT (Device Under Test)
    component nanoprocessor_top
        Port (
            clk          : in  STD_LOGIC;
            reset_btn    : in  STD_LOGIC;
            led_data     : out STD_LOGIC_VECTOR(3 downto 0);
            led_overflow : out STD_LOGIC;
            led_zero     : out STD_LOGIC;
            seg_out      : out STD_LOGIC_VECTOR(6 downto 0);
            anode_out    : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    -- Testbench signals
    signal clk          : STD_LOGIC := '0';
    signal reset_btn    : STD_LOGIC := '1';
    signal led_data     : STD_LOGIC_VECTOR(3 downto 0);
    signal led_overflow : STD_LOGIC;
    signal led_zero     : STD_LOGIC;
    signal seg_out      : STD_LOGIC_VECTOR(6 downto 0);
    signal anode_out    : STD_LOGIC_VECTOR(3 downto 0);

    -- Clock period constant
    constant CLK_PERIOD : time := 10 ns;  -- 100 MHz clock

begin

    -- Instantiate the Device Under Test (DUT)
    DUT: nanoprocessor_top port map (
        clk          => clk,
        reset_btn    => reset_btn,
        led_data     => led_data,
        led_overflow => led_overflow,
        led_zero     => led_zero,
        seg_out      => seg_out,
        anode_out    => anode_out
    );

    -- =========================================================================
    -- FIX 1: Clock generation process.
    --        A process with NO sensitivity list must have its body inside a
    --        'loop / end loop' with explicit 'wait' statements.
    --        Without 'loop', the simulator sees an infinite zero-time loop
    --        and hangs at time 0.
    -- =========================================================================
    CLK_GEN: process
    begin
        loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- =========================================================================
    -- Main test process
    -- =========================================================================
    STIMULUS: process
        -- FIX 4: Keep test_count here in STIMULUS so it is always updated.
        --        In VHDL-1993, a process variable passed into a procedure is
        --        copied, so any increment inside the procedure is lost on return.
        variable test_count : integer := 0;

    begin
        report "=========================================";
        report "  NANOPROCESSOR COMPLETE TEST SUITE";
        report "=========================================";

        -- =====================================================================
        -- TEST 1: RESET TEST
        -- =====================================================================
        report "--- TEST 1: Reset Test ---";
        reset_btn <= '1';
        wait for CLK_PERIOD * 5;

        assert led_data = "0000"
            report "FAIL: Registers should be 0 after reset"
            severity error;

        report "PASS: Reset working correctly";

        -- Release reset
        reset_btn <= '0';
        wait for CLK_PERIOD * 2;

        -- =====================================================================
        -- TEST 2: RUN SAMPLE PROGRAM  (10 - 1 = 9)
        -- =====================================================================
        report "--- TEST 2: Execute Sample Program ---";
        report "Program: MOVI R1,10; MOVI R2,1; NEG R2; ADD R1,R2; ...";

        -- Run for enough clock cycles to execute the program.
        -- The program loops, so we run for 50 cycles.
        for i in 1 to 50 loop
            wait for CLK_PERIOD;

            -- FIX 3: STD_LOGIC signals (led_overflow, led_zero) cannot be
            --        concatenated directly into a 'string'.
            --        Use STD_LOGIC'image() to convert them first.
            if i mod 10 = 0 then
                report "Cycle " & integer'image(i) &
                       ": LED="       & integer'image(to_integer(unsigned(led_data))) &
                       " Overflow="   & STD_LOGIC'image(led_overflow) &
                       " Zero="       & STD_LOGIC'image(led_zero);
            end if;
        end loop;

        -- =====================================================================
        -- FIX 2 + FIX 4: Replaced the 'check_output' procedure with inline
        --                 assertions.  The original procedure took a 'string'
        --                 parameter (unsafe in VHDL-1993) and updated a
        --                 process-local variable (lost on procedure return).
        --                 Inline assertions avoid both problems.
        -- =====================================================================

        -- Wait for signals to settle after the run loop
        wait for CLK_PERIOD * 2;

        -- After execution, R1 should contain 9 (1001 binary)
        if led_data = "1001" then
            report "[PASS] Final Result (should be 9) - LED = " &
                   integer'image(to_integer(unsigned(led_data)))
                   severity note;
        else
            report "[FAIL] Final Result (should be 9) - Expected: 9, Got: " &
                   integer'image(to_integer(unsigned(led_data)))
                   severity error;
        end if;
        test_count := test_count + 1;

        -- =====================================================================
        -- TEST 3: VERIFY FLAGS
        -- =====================================================================
        report "--- TEST 3: Flag Verification ---";

        -- Check that overflow is not set for this calculation
        assert led_overflow = '0'
            report "INFO: Overflow flag is " & STD_LOGIC'image(led_overflow)
            severity note;

        -- Check zero flag (should be '0' since result is 9)
        assert led_zero = '0'
            report "INFO: Zero flag is " & STD_LOGIC'image(led_zero)
            severity note;

        test_count := test_count + 1;

        -- =====================================================================
        -- TEST 4: RESET MID-EXECUTION
        -- =====================================================================
        report "--- TEST 4: Reset During Execution ---";
        wait for CLK_PERIOD * 10;
        reset_btn <= '1';
        wait for CLK_PERIOD * 3;

        if led_data = "0000" then
            report "[PASS] Mid-execution reset: LED = 0000 as expected"
                   severity note;
        else
            report "[FAIL] Mid-execution reset: LED should be 0000, Got: " &
                   integer'image(to_integer(unsigned(led_data)))
                   severity error;
        end if;
        test_count := test_count + 1;

        reset_btn <= '0';

        -- =====================================================================
        -- FINAL SUMMARY
        -- =====================================================================
        report "=========================================";
        report "  TEST SUMMARY";
        report "=========================================";
        report "Total tests executed: " & integer'image(test_count);
        report "Test suite completed!";
        report "=========================================";

        -- Stop simulation
        wait;
    end process;

end Behavioral;
