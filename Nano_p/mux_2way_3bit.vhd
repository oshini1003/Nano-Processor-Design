----------------------------------------------------------------------------------
-- 2-to-1 MUX (3-bit wide)
-- University of Moratuwa | Team: 240348, 240351, 240347, 240343
-- Used to select between PC+1 (next) and jump address
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_2way_3bit is
    Port (
        in0  : in  STD_LOGIC_VECTOR(2 downto 0);  -- PC + 1 (normal)
        in1  : in  STD_LOGIC_VECTOR(2 downto 0);  -- Jump address
        sel  : in  STD_LOGIC;                      -- '1' = take jump
        y    : out STD_LOGIC_VECTOR(2 downto 0)
    );
end mux_2way_3bit;

architecture Behavioral of mux_2way_3bit is
begin
    y <= in1 when sel = '1' else in0;
end Behavioral;
