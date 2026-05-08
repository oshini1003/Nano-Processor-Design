----------------------------------------------------------------------------------
-- 4-bit Comparator (Signed & Unsigned)
-- University of Moratuwa | Team: 240348, 240351, 240347, 240343
-- Bonus hardware component for the competition
-- mode = '0' : unsigned comparison
-- mode = '1' : signed (2's complement) comparison
-- Outputs: eq (A=B), gt (A>B), lt (A<B)
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity comparator_4bit is
    Port (
        A    : in  STD_LOGIC_VECTOR(3 downto 0);
        B    : in  STD_LOGIC_VECTOR(3 downto 0);
        mode : in  STD_LOGIC;   -- '0'=unsigned, '1'=signed
        eq   : out STD_LOGIC;   -- A = B
        gt   : out STD_LOGIC;   -- A > B
        lt   : out STD_LOGIC    -- A < B
    );
end comparator_4bit;

architecture Behavioral of comparator_4bit is
    signal a_s : SIGNED(3 downto 0);
    signal b_s : SIGNED(3 downto 0);
    signal a_u : STD_LOGIC_VECTOR(3 downto 0);
    signal b_u : STD_LOGIC_VECTOR(3 downto 0);
begin
    a_s <= SIGNED(A);
    b_s <= SIGNED(B);
    a_u <= A;
    b_u <= B;

    process(A, B, mode, a_s, b_s, a_u, b_u)
    begin
        if mode = '1' then
            -- Signed comparison
            if a_s = b_s then
                eq <= '1'; gt <= '0'; lt <= '0';
            elsif a_s > b_s then
                eq <= '0'; gt <= '1'; lt <= '0';
            else
                eq <= '0'; gt <= '0'; lt <= '1';
            end if;
        else
            -- Unsigned comparison
            if a_u = b_u then
                eq <= '1'; gt <= '0'; lt <= '0';
            elsif a_u > b_u then
                eq <= '0'; gt <= '1'; lt <= '0';
            else
                eq <= '0'; gt <= '0'; lt <= '1';
            end if;
        end if;
    end process;
end Behavioral;
