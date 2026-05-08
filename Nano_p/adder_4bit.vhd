----------------------------------------------------------------------------------
-- 4-bit Adder/Subtractor with Flags
-- University of Moratuwa | Team: 240348, 240351, 240347, 240343
-- Computes: result = A + B (add) or A - B (sub via 2's complement)
-- Flags: Zero, Overflow (signed), Carry (unsigned)
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity adder_4bit is
    Port (
        A        : in  STD_LOGIC_VECTOR(3 downto 0);
        B        : in  STD_LOGIC_VECTOR(3 downto 0);
        sub      : in  STD_LOGIC;                     -- 0=Add, 1=Subtract
        result   : out STD_LOGIC_VECTOR(3 downto 0);
        zero     : out STD_LOGIC;
        overflow : out STD_LOGIC;
        carry    : out STD_LOGIC
    );
end adder_4bit;

architecture Behavioral of adder_4bit is
    signal b_eff    : STD_LOGIC_VECTOR(3 downto 0);
    signal sum5     : STD_LOGIC_VECTOR(4 downto 0);  -- 5-bit for carry
    signal res4     : STD_LOGIC_VECTOR(3 downto 0);
begin
    -- Invert B for subtraction
    b_eff <= NOT B when sub = '1' else B;

    -- 5-bit addition (carry-extended): add sub bit as carry-in for subtraction
    sum5  <= ('0' & A) + ('0' & b_eff) + (sub & "0000");

    res4  <= sum5(3 downto 0);
    result <= res4;

    -- Zero flag
    zero  <= '1' when res4 = "0000" else '0';

    -- Carry out (unsigned overflow)
    carry <= sum5(4);

    -- Signed overflow: occurs when signs of A and B_eff are the same
    -- but the result sign differs
    overflow <= (A(3) XNOR b_eff(3)) AND (A(3) XOR res4(3));

end Behavioral;
