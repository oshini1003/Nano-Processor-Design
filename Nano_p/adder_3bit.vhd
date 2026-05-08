----------------------------------------------------------------------------------
-- 3-bit Adder (for PC increment)
-- University of Moratuwa | Team: 240348, 240351, 240347, 240343
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity adder_3bit is
    Port (
        A      : in  STD_LOGIC_VECTOR(2 downto 0);
        B      : in  STD_LOGIC_VECTOR(2 downto 0);
        result : out STD_LOGIC_VECTOR(2 downto 0);
        carry  : out STD_LOGIC
    );
end adder_3bit;

architecture Behavioral of adder_3bit is
    signal sum4 : STD_LOGIC_VECTOR(3 downto 0);
begin
    sum4   <= ('0' & A) + ('0' & B);
    result <= sum4(2 downto 0);
    carry  <= sum4(3);
end Behavioral;
