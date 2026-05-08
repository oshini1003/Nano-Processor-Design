----------------------------------------------------------------------------------
-- Company  : UOM - CSE'24 - GROUP 45
-- Module   : tb_alu_4bit
-- Description: Self-checking testbench for the full ALU.
--   Tests all operations: ADD, SUB, AND, OR, XOR, SHL, SHR.
--   Checks Result, Zero, Carry, and Overflow flags against expected values.
--   A PASS/FAIL message is printed for each test case.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_alu_4bit is
-- Testbench has no ports
end tb_alu_4bit;

architecture sim of tb_alu_4bit is

    -- =========================================================================
    -- Component Under Test
    -- =========================================================================
    component alu_4bit is
        port (
            A       : in  std_logic_vector(3 downto 0);
            B       : in  std_logic_vector(3 downto 0);
            op      : in  std_logic_vector(2 downto 0);
            shift_r : in  std_logic;
            Result  : out std_logic_vector(3 downto 0);
            Zero    : out std_logic;
            Carry   : out std_logic;
            Ovf     : out std_logic
        );
    end component;

    -- Signals
    signal A        : std_logic_vector(3 downto 0) := "0000";
    signal B        : std_logic_vector(3 downto 0) := "0000";
    signal op       : std_logic_vector(2 downto 0) := "000";
    signal shift_r  : std_logic := '0';
    signal Result   : std_logic_vector(3 downto 0);
    signal Zero     : std_logic;
    signal Carry    : std_logic;
    signal Ovf      : std_logic;

    -- Test counters
    shared variable pass_count : integer := 0;
    shared variable fail_count : integer := 0;

    -- =========================================================================
    -- Helper procedure: apply inputs and check outputs
    -- =========================================================================
    procedure check_alu (
        signal s_A      : out std_logic_vector(3 downto 0);
        signal s_B      : out std_logic_vector(3 downto 0);
        signal s_op     : out std_logic_vector(2 downto 0);
        signal s_shft   : out std_logic;
        signal s_result : in  std_logic_vector(3 downto 0);
        signal s_zero   : in  std_logic;
        signal s_carry  : in  std_logic;
        signal s_ovf    : in  std_logic;
        -- inputs
        v_A    : in std_logic_vector(3 downto 0);
        v_B    : in std_logic_vector(3 downto 0);
        v_op   : in std_logic_vector(2 downto 0);
        v_shft : in std_logic;
        -- expected outputs
        exp_result : in std_logic_vector(3 downto 0);
        exp_zero   : in std_logic;
        exp_carry  : in std_logic;
        exp_ovf    : in std_logic;
        test_name  : in string
    ) is
    begin
        s_A    <= v_A;
        s_B    <= v_B;
        s_op   <= v_op;
        s_shft <= v_shft;
        wait for 20 ns;  -- propagation delay

        if s_result = exp_result and s_zero = exp_zero and
           s_carry = exp_carry and s_ovf = exp_ovf then
            report "PASS: " & test_name severity note;
            pass_count := pass_count + 1;
        else
            report "FAIL: " & test_name &
                   "  Got Result=" & to_hstring(s_result) &
                   " Z=" & std_logic'image(s_zero) &
                   " C=" & std_logic'image(s_carry) &
                   " Ovf=" & std_logic'image(s_ovf) &
                   "  Expected Result=" & to_hstring(exp_result) &
                   " Z=" & std_logic'image(exp_zero) &
                   " C=" & std_logic'image(exp_carry) &
                   " Ovf=" & std_logic'image(exp_ovf)
                   severity error;
            fail_count := fail_count + 1;
        end if;
    end procedure;

begin

    -- =========================================================================
    -- Instantiate DUT
    -- =========================================================================
    DUT: alu_4bit
        port map (
            A       => A,
            B       => B,
            op      => op,
            shift_r => shift_r,
            Result  => Result,
            Zero    => Zero,
            Carry   => Carry,
            Ovf     => Ovf
        );

    -- =========================================================================
    -- Stimulus Process
    -- =========================================================================
    stim_proc: process
    begin
        report "========================================" severity note;
        report "   ALU 4-BIT TESTBENCH STARTING" severity note;
        report "========================================" severity note;
        wait for 10 ns;

        -- ----------------------------------------------------------------
        -- ADD (op = "000")
        -- ----------------------------------------------------------------
        report "--- ADD Tests ---" severity note;

        -- 5 + 3 = 8  (0101 + 0011 = 1000): Z=0, C=0, Ovf=0
        check_alu(A,B,op,shift_r, Result,Zero,Carry,Ovf,
                  "0101","0011","000",'0',
                  "1000",'0','0','0', "ADD: 5+3=8");

        -- 0 + 0 = 0 : Z=1, C=0, Ovf=0
        check_alu(A,B,op,shift_r, Result,Zero,Carry,Ovf,
                  "0000","0000","000",'0',
                  "0000",'1','0','0', "ADD: 0+0=0 (Zero flag)");

        -- 9 + 9 = 18 → lower 4-bits=2, C=1 (0001_0010)
        check_alu(A,B,op,shift_r, Result,Zero,Carry,Ovf,
                  "1001","1001","000",'0',
                  "0010",'0','1','0', "ADD: 9+9 unsigned carry");

        -- Signed overflow: 7 + 1 = 8 (0111 + 0001 = 1000) → positive+positive=negative → Ovf=1
        check_alu(A,B,op,shift_r, Result,Zero,Carry,Ovf,
                  "0111","0001","000",'0',
                  "1000",'0','0','1', "ADD: 7+1 signed overflow");

        -- ----------------------------------------------------------------
        -- SUB (op = "001")
        -- ----------------------------------------------------------------
        report "--- SUB Tests ---" severity note;

        -- 5 - 3 = 2  (0101 - 0011 = 0010): Z=0, C=1(no borrow), Ovf=0
        check_alu(A,B,op,shift_r, Result,Zero,Carry,Ovf,
                  "0101","0011","001",'0',
                  "0010",'0','1','0', "SUB: 5-3=2");

        -- 3 - 3 = 0 : Z=1, C=1, Ovf=0
        check_alu(A,B,op,shift_r, Result,Zero,Carry,Ovf,
                  "0011","0011","001",'0',
                  "0000",'1','1','0', "SUB: 3-3=0 (Zero flag)");

        -- 3 - 5 = -2 (0011 - 0101) = 1110: C=0(borrow), Ovf=0
        check_alu(A,B,op,shift_r, Result,Zero,Carry,Ovf,
                  "0011","0101","001",'0',
                  "1110",'0','0','0', "SUB: 3-5=-2 (borrow)");

        -- Signed overflow: -8 - 1 → 1000 - 0001 = 0111: neg-pos=pos → Ovf=1
        check_alu(A,B,op,shift_r, Result,Zero,Carry,Ovf,
                  "1000","0001","001",'0',
                  "0111",'0','0','1', "SUB: -8-1 signed overflow");

        -- ----------------------------------------------------------------
        -- AND (op = "010")
        -- ----------------------------------------------------------------
        report "--- AND Tests ---" severity note;

        -- 5 AND 3 = 0101 AND 0011 = 0001
        check_alu(A,B,op,shift_r, Result,Zero,Carry,Ovf,
                  "0101","0011","010",'0',
                  "0001",'0','0','0', "AND: 5 AND 3 = 1");

        -- F AND F = F
        check_alu(A,B,op,shift_r, Result,Zero,Carry,Ovf,
                  "1111","1111","010",'0',
                  "1111",'0','0','0', "AND: F AND F = F");

        -- 5 AND 0 = 0 (Zero flag)
        check_alu(A,B,op,shift_r, Result,Zero,Carry,Ovf,
                  "0101","0000","010",'0',
                  "0000",'1','0','0', "AND: 5 AND 0 = 0 (Zero)");

        -- ----------------------------------------------------------------
        -- OR (op = "011")
        -- ----------------------------------------------------------------
        report "--- OR Tests ---" severity note;

        -- 5 OR 3 = 0101 OR 0011 = 0111 = 7
        check_alu(A,B,op,shift_r, Result,Zero,Carry,Ovf,
                  "0101","0011","011",'0',
                  "0111",'0','0','0', "OR: 5 OR 3 = 7");

        -- 0 OR 0 = 0 (Zero flag)
        check_alu(A,B,op,shift_r, Result,Zero,Carry,Ovf,
                  "0000","0000","011",'0',
                  "0000",'1','0','0', "OR: 0 OR 0 = 0 (Zero)");

        -- A OR 5 = 1010 OR 0101 = 1111 = F
        check_alu(A,B,op,shift_r, Result,Zero,Carry,Ovf,
                  "1010","0101","011",'0',
                  "1111",'0','0','0', "OR: A OR 5 = F");

        -- ----------------------------------------------------------------
        -- XOR (op = "100")
        -- ----------------------------------------------------------------
        report "--- XOR Tests ---" severity note;

        -- 5 XOR 3 = 0101 XOR 0011 = 0110 = 6
        check_alu(A,B,op,shift_r, Result,Zero,Carry,Ovf,
                  "0101","0011","100",'0',
                  "0110",'0','0','0', "XOR: 5 XOR 3 = 6");

        -- R XOR R = 0 (Zero flag, useful for clearing a register)
        check_alu(A,B,op,shift_r, Result,Zero,Carry,Ovf,
                  "1010","1010","100",'0',
                  "0000",'1','0','0', "XOR: A XOR A = 0 (Zero)");

        -- F XOR F = 0 (NOT via XOR with 1111 pattern)
        check_alu(A,B,op,shift_r, Result,Zero,Carry,Ovf,
                  "0101","1111","100",'0',
                  "1010",'0','0','0', "XOR: 5 XOR F = A (bitwise NOT 5)");

        -- ----------------------------------------------------------------
        -- SHL (op = "101", shift_r = '0')
        -- ----------------------------------------------------------------
        report "--- SHL Tests ---" severity note;

        -- 0101 (5) SHL 1 = 1010 (10)
        check_alu(A,B,op,shift_r, Result,Zero,Carry,Ovf,
                  "0101","000"&'0',"101",'0',
                  "1010",'0','0','0', "SHL: 5 << 1 = 10 (0xA)");

        -- 0001 (1) SHL 1 = 0010 (2)
        check_alu(A,B,op,shift_r, Result,Zero,Carry,Ovf,
                  "0001","0000","101",'0',
                  "0010",'0','0','0', "SHL: 1 << 1 = 2");

        -- 1000 (8) SHL 1 = 0000 (MSB lost, zero result)
        check_alu(A,B,op,shift_r, Result,Zero,Carry,Ovf,
                  "1000","0000","101",'0',
                  "0000",'1','0','0', "SHL: 8 << 1 = 0 (MSB lost, Zero=1)");

        -- ----------------------------------------------------------------
        -- SHR (op = "101", shift_r = '1')
        -- ----------------------------------------------------------------
        report "--- SHR Tests ---" severity note;

        -- 1010 (10) SHR 1 = 0101 (5)
        check_alu(A,B,op,shift_r, Result,Zero,Carry,Ovf,
                  "1010","0000","101",'1',
                  "0101",'0','0','0', "SHR: A >> 1 = 5");

        -- 0001 (1) SHR 1 = 0000 (LSB lost, zero)
        check_alu(A,B,op,shift_r, Result,Zero,Carry,Ovf,
                  "0001","0000","101",'1',
                  "0000",'1','0','0', "SHR: 1 >> 1 = 0 (LSB lost, Zero=1)");

        -- 1111 (F) SHR 1 = 0111 (7)
        check_alu(A,B,op,shift_r, Result,Zero,Carry,Ovf,
                  "1111","0000","101",'1',
                  "0111",'0','0','0', "SHR: F >> 1 = 7");

        -- ----------------------------------------------------------------
        -- Summary
        -- ----------------------------------------------------------------
        wait for 20 ns;
        report "========================================" severity note;
        report "RESULTS: " &
               integer'image(pass_count) & " PASSED, " &
               integer'image(fail_count) & " FAILED"
               severity note;
        if fail_count = 0 then
            report "ALL TESTS PASSED ✓" severity note;
        else
            report "SOME TESTS FAILED ✗" severity failure;
        end if;
        report "========================================" severity note;

        wait; -- Stop simulation
    end process;

end sim;
