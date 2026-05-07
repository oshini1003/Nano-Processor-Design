----------------------------------------------------------------------------------
-- Company: UOM - CSE'24 - GROUP 45
-- Engineer: Kethmika K A D Y
-- Module Name: tb_adder_4bit - Behavioral
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_adder_4bit is
end tb_adder_4bit;

architecture behavioral of tb_adder_4bit is

    component adder_4bit
        port (
            A        : in  std_logic_vector(3 downto 0);
            B        : in  std_logic_vector(3 downto 0);
            Sub      : in  std_logic;
            Result   : out std_logic_vector(3 downto 0);
            Zero     : out std_logic;
            Overflow : out std_logic;
            Carry    : out std_logic
        );
    end component;

    signal A, B   : std_logic_vector(3 downto 0) := (others => '0');
    signal Sub     : std_logic := '0';
    signal Result  : std_logic_vector(3 downto 0);
    signal Z, O, C : std_logic;

    constant CLK_PERIOD : time := 10 ns;

begin

    UUT: adder_4bit
        port map (
            A => A, B => B, Sub => Sub,
            Result => Result, Zero => Z, Overflow => O, Carry => C
        );

    stimulus: process

        -- Use VARIABLES (not signals) so counts update immediately
        variable test_count : integer := 0;
        variable pass_count : integer := 0;
        variable fail_count : integer := 0;

        procedure check(test_name : string;
                        exp_res   : std_logic_vector(3 downto 0);
                        exp_z, exp_o, exp_c : std_logic) is
        begin
            wait for CLK_PERIOD;  -- single wait here; no extra wait before calling check
            test_count := test_count + 1;

            if Result = exp_res and Z = exp_z and O = exp_o and C = exp_c then
                report "[PASS] " & test_name &
                       ": R=" & integer'image(to_integer(unsigned(Result))) &
                       " Z=" & std_logic'image(Z) &
                       " O=" & std_logic'image(O) &
                       " C=" & std_logic'image(C);
                pass_count := pass_count + 1;
            else
                report "[FAIL] " & test_name &
                       ": Expected R=" & integer'image(to_integer(unsigned(exp_res))) &
                       " Z=" & std_logic'image(exp_z) &
                       " O=" & std_logic'image(exp_o) &
                       " C=" & std_logic'image(exp_c) &
                       " | Got R=" & integer'image(to_integer(unsigned(Result))) &
                       " Z=" & std_logic'image(Z) &
                       " O=" & std_logic'image(O) &
                       " C=" & std_logic'image(C)
                       severity error;
                fail_count := fail_count + 1;
            end if;
        end procedure;

    begin
        report "=============================================================";
        report "4-BIT ALU TESTSUITE";
        report "Team Indexes: 240348 | 240351 | 240347 | 240343";
        report "=============================================================";

        ----------------------------------------------------------------
        -- TEST GROUP 1: ADDITION
        ----------------------------------------------------------------
        report "--- TEST GROUP 1: ADDITION ---";

        A <= "0000"; B <= "0000"; Sub <= '0';
        check("ADD 0+0", "0000", '1', '0', '0');

        A <= "0001"; B <= "0010"; Sub <= '0';
        check("ADD 1+2", "0011", '0', '0', '0');

        A <= "0111"; B <= "0001"; Sub <= '0';
        check("ADD 7+1 (signed overflow)", "1000", '0', '1', '0');

        A <= "1111"; B <= "0001"; Sub <= '0';
        check("ADD 15+1 (carry)", "0000", '1', '0', '1');

        A <= "0100"; B <= "0111"; Sub <= '0';
        check("ADD 4+7 (team indexes)", "1011", '0', '0', '0');

        ----------------------------------------------------------------
        -- TEST GROUP 2: SUBTRACTION
        ----------------------------------------------------------------
        report "--- TEST GROUP 2: SUBTRACTION ---";

        A <= "0101"; B <= "0011"; Sub <= '1';
        check("SUB 5-3", "0010", '0', '0', '0');

        A <= "0011"; B <= "0101"; Sub <= '1';
        check("SUB 3-5 (negative)", "1110", '0', '0', '1');

        A <= "0000"; B <= "0001"; Sub <= '1';
        check("SUB 0-1 (negate)", "1111", '0', '0', '1');

        A <= "1010"; B <= "1010"; Sub <= '1';
        check("SUB 10-10 (zero)", "0000", '1', '0', '0');

        A <= "1000"; B <= "0001"; Sub <= '1';
        check("SUB -8-1 (overflow)", "0111", '0', '1', '1');

        ----------------------------------------------------------------
        -- TEST GROUP 3: BOUNDARY CASES
        ----------------------------------------------------------------
        report "--- TEST GROUP 3: BOUNDARY CASES ---";

        A <= "1111"; B <= "1111"; Sub <= '0';
        check("ADD 15+15", "1110", '0', '0', '1');

        A <= "1000"; B <= "1000"; Sub <= '0';
        check("ADD -8+-8", "0000", '1', '1', '1');

        A <= "0111"; B <= "1000"; Sub <= '1';
        check("SUB 7-(-8)", "1111", '0', '1', '0');

        ----------------------------------------------------------------
        -- SUMMARY  (integer-only arithmetic — no real'image)
        ----------------------------------------------------------------
        report "=============================================================";
        report "TEST SUMMARY: 240348, 240351, 240347, 240343";
        report "Total : " & integer'image(test_count);
        report "Passed: " & integer'image(pass_count);
        report "Failed: " & integer'image(fail_count);
        report "=============================================================";

        if fail_count = 0 then
            report "STATUS: ALL TESTS PASSED";
        else
            report "STATUS: " & integer'image(fail_count) & " TEST(S) FAILED"
                severity failure;
        end if;

        wait;
    end process;

end behavioral;