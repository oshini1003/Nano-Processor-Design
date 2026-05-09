----------------------------------------------------------------------------------
-- Company  : UOM - CSE'24 - GROUP 45
-- Module   : comparator_4bit
-- Description: Structural (gate-level) 4-bit magnitude comparator.
--   Supports both signed and unsigned comparison.
--   Pure combinational logic — no integer arithmetic, synthesizes to simple gates.
--   A_eq_B : XNOR all bit pairs, AND together
--   A_gt_B : unsigned ripple from MSB; signed: account for sign-bit inversion
--   A_lt_B : NOT(A_eq_B OR A_gt_B)  — saves gates vs separate chain
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity comparator_4bit is
    port (
        A           : in  std_logic_vector(3 downto 0);
        B           : in  std_logic_vector(3 downto 0);
        signed_mode : in  std_logic;  -- '1'=signed, '0'=unsigned
        A_eq_B      : out std_logic;
        A_gt_B      : out std_logic;
        A_lt_B      : out std_logic
    );
end comparator_4bit;

architecture structural of comparator_4bit is

    -- XNOR pairs: '1' when bits match
    signal eq3, eq2, eq1, eq0 : std_logic;

    -- Effective sign bits (inverted for signed comparison)
    signal a_msb, b_msb : std_logic;

    -- Greater-than cascade signals (from MSB down)
    -- gt_n = '1' if A > B considering bits [3:n]
    signal gt3, gt2, gt1, gt0 : std_logic;

    signal eq_all : std_logic;
    signal gt_all : std_logic;

begin

    -- ----------------------------------------------------------------
    -- Equality: all bit pairs must match (XNOR = equality comparator)
    -- ----------------------------------------------------------------
    eq3 <= not (A(3) xor B(3));
    eq2 <= not (A(2) xor B(2));
    eq1 <= not (A(1) xor B(1));
    eq0 <= not (A(0) xor B(0));

    eq_all <= eq3 and eq2 and eq1 and eq0;

    -- ----------------------------------------------------------------
    -- Signed mode: MSB is sign bit; treat as unsigned after inverting
    -- both MSBs so that negative numbers compare correctly.
    -- For signed: -8(1000) < 7(0111) → invert MSB → 0000 < 1111 ✓
    -- ----------------------------------------------------------------
    a_msb <= A(3) xor signed_mode;   -- invert MSB when signed
    b_msb <= B(3) xor signed_mode;

    -- ----------------------------------------------------------------
    -- Greater-than: ripple from MSB
    -- gt_n = A[n]>B[n]  OR  (A[n]=B[n] AND A[n-1..0] > B[n-1..0])
    -- ----------------------------------------------------------------
    gt3 <= a_msb and (not b_msb);

    gt2 <= (A(2) and (not B(2))) or
           (eq2 and gt3);

    gt1 <= (A(1) and (not B(1))) or
           (eq1 and gt2);

    gt0 <= (A(0) and (not B(0))) or
           (eq0 and gt1);

    -- After ripple, final greater result considers MSB with signed correction
    gt_all <= gt3 or (eq3 and gt2);

    -- ----------------------------------------------------------------
    -- Outputs (A_lt_B saves one chain: not(eq OR gt))
    -- ----------------------------------------------------------------
    A_eq_B <= eq_all;
    A_gt_B <= gt_all and (not eq_all);
    A_lt_B <= (not gt_all) and (not eq_all);

end structural;
