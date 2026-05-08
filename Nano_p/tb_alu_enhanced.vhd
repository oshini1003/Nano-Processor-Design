----------------------------------------------------------------------------------
-- ALU Enhanced Testbench (VHDL-93 Compatible)
-- University of Moratuwa | Team: 240348, 240351, 240347, 240343
-- Tests all 8 ALU operations with known input/output pairs
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_alu_enhanced is
end tb_alu_enhanced;

architecture Behavioral of tb_alu_enhanced is

    component alu_enhanced
        Port (
            A        : in  STD_LOGIC_VECTOR(3 downto 0);
            B        : in  STD_LOGIC_VECTOR(3 downto 0);
            alu_op   : in  STD_LOGIC_VECTOR(2 downto 0);
            result   : out STD_LOGIC_VECTOR(3 downto 0);
            zero     : out STD_LOGIC;
            overflow : out STD_LOGIC;
            carry    : out STD_LOGIC
        );
    end component;

    signal A, B     : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal alu_op   : STD_LOGIC_VECTOR(2 downto 0) := "000";
    signal result   : STD_LOGIC_VECTOR(3 downto 0);
    signal zero     : STD_LOGIC;
    signal overflow : STD_LOGIC;
    signal carry    : STD_LOGIC;

begin
    UUT: alu_enhanced
        port map (A=>A, B=>B, alu_op=>alu_op,
                  result=>result, zero=>zero, overflow=>overflow, carry=>carry);

    process
    begin
        -- ===== ADD =====
        alu_op <= "000";
        A <= "0011"; B <= "0101"; wait for 20 ns;
        -- Expected: result=1000, zero=0, carry=0, ovf=0
        assert result = "1000" report "ADD 3+5 failed" severity ERROR;

        A <= "0111"; B <= "0001"; wait for 20 ns;
        -- 7+1=8 => signed overflow (pos+pos=neg)
        assert result = "1000" report "ADD 7+1 result failed" severity ERROR;
        assert overflow = '1' report "ADD 7+1 overflow flag failed" severity ERROR;

        A <= "1001"; B <= "0111"; wait for 20 ns;
        -- 9+7=16 => carry out, result=0000 in 4-bit
        assert carry = '1' report "ADD carry flag failed" severity ERROR;

        -- ===== SUB =====
        alu_op <= "001";
        A <= "1000"; B <= "0011"; wait for 20 ns;
        -- Expected: 8-3=5 = 0101
        assert result = "0101" report "SUB 8-3 failed" severity ERROR;

        A <= "0000"; B <= "0001"; wait for 20 ns;
        -- 0-1 = -1 = 1111 in 2's complement
        assert result = "1111" report "SUB 0-1 failed" severity ERROR;

        -- ===== AND =====
        alu_op <= "010";
        A <= "1100"; B <= "1010"; wait for 20 ns;
        assert result = "1000" report "AND failed" severity ERROR;

        -- ===== OR =====
        alu_op <= "011";
        A <= "1100"; B <= "1010"; wait for 20 ns;
        assert result = "1110" report "OR failed" severity ERROR;

        -- ===== XOR =====
        alu_op <= "100";
        A <= "1100"; B <= "1010"; wait for 20 ns;
        assert result = "0110" report "XOR failed" severity ERROR;

        A <= "1111"; B <= "1111"; wait for 20 ns;
        assert result = "0000" report "XOR self failed" severity ERROR;
        assert zero   = '1'   report "XOR zero flag failed" severity ERROR;

        -- ===== NOT A =====
        alu_op <= "101";
        A <= "1010"; B <= "0000"; wait for 20 ns;
        assert result = "0101" report "NOT failed" severity ERROR;

        A <= "0000"; B <= "0000"; wait for 20 ns;
        assert result = "1111" report "NOT 0 failed" severity ERROR;

        -- ===== SHL =====
        alu_op <= "110";
        A <= "0101"; B <= "0000"; wait for 20 ns;
        -- Expected: 1010, carry=0
        assert result = "1010" report "SHL failed" severity ERROR;
        assert carry = '0' report "SHL carry failed" severity ERROR;

        A <= "1101"; B <= "0000"; wait for 20 ns;
        -- MSB shifted out into carry
        assert carry = '1' report "SHL carry out failed" severity ERROR;

        -- ===== SHR =====
        alu_op <= "111";
        A <= "1010"; B <= "0000"; wait for 20 ns;
        assert result = "0101" report "SHR failed" severity ERROR;
        assert carry = '0' report "SHR carry failed" severity ERROR;

        A <= "0101"; B <= "0000"; wait for 20 ns;
        assert carry = '1' report "SHR carry out failed" severity ERROR;

        -- ===== Zero flag =====
        alu_op <= "000"; A <= "0000"; B <= "0000"; wait for 20 ns;
        assert zero = '1' report "Zero flag ADD 0+0 failed" severity ERROR;

        report "ALL ALU TESTS PASSED" severity NOTE;
        wait;
    end process;

end Behavioral;
