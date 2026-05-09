----------------------------------------------------------------------------------
-- Company: UOM - CSE'24 - GROUP 45
-- Module Name: adder_4bit - Behavioral
-- Description: 4-bit ALU. ADD when Sub=0, SUB when Sub=1 (two's complement).
--              Result = A + B       (Sub=0)
--              Result = A - B       (Sub=1, via A + ~B + 1)
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity adder_4bit is
    port (
        A        : in  std_logic_vector(3 downto 0);
        B        : in  std_logic_vector(3 downto 0);
        Sub      : in  std_logic;  -- '1' = subtract, '0' = add
        Result   : out std_logic_vector(3 downto 0);
        Zero     : out std_logic;
        Overflow : out std_logic;
        Carry    : out std_logic
    );
end adder_4bit;

architecture rtl of adder_4bit is
    signal b_comp  : std_logic_vector(3 downto 0);
    signal sum_int : unsigned(4 downto 0);
begin

    -- Two's complement B when subtracting
    b_comp  <= not B when Sub = '1' else B;

    -- FIXED: ("0000" & Sub) adds exactly 1 when Sub='1', 0 when Sub='0'
    sum_int <= unsigned('0' & A) + unsigned('0' & b_comp) + ("0000" & Sub);

    Result <= std_logic_vector(sum_int(3 downto 0));
    Carry  <= sum_int(4);
    Zero   <= '1' when sum_int(3 downto 0) = "0000" else '0';

    -- Signed overflow detection
    process(A, B, Sub, sum_int)
    begin
        if Sub = '0' then
            if (A(3) = '0' and B(3) = '0' and sum_int(3) = '1') or
               (A(3) = '1' and B(3) = '1' and sum_int(3) = '0') then
                Overflow <= '1';
            else
                Overflow <= '0';
            end if;
        else
            if (A(3) /= B(3)) and (sum_int(3) /= A(3)) then
                Overflow <= '1';
            else
                Overflow <= '0';
            end if;
        end if;
    end process;

end rtl;