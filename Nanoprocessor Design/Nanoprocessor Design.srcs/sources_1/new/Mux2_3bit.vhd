library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity Mux2_3bit is
Port (
A : in STD_LOGIC_VECTOR(2 downto 0); -- Input 0
B : in STD_LOGIC_VECTOR(2 downto 0); -- Input 1
Sel : in STD_LOGIC; -- Select line
Y : out STD_LOGIC_VECTOR(2 downto 0) -- Output
);
end Mux2_3bit;
architecture Behavioral of Mux2_3bit is
begin
process (A, B, Sel)
begin
if Sel = '0' then
Y <= A;
else
Y <= B;
end if;
end process;
end Behavioral;