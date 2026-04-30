library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
entity w2_4_MUX_TB is 
-- Port ( ); 
end w2_4_MUX_TB; 
architecture Behavioral of w2_4_MUX_TB is 
component w2_4_MUX 
Port ( Load_Select : in STD_LOGIC; 
Immediate : in STD_LOGIC_VECTOR (3 downto 0); 
S : in STD_LOGIC_VECTOR (3 downto 0); 
Value_In : out STD_LOGIC_VECTOR (3 downto 0)); 
end component; 
signal A_in, B_in, Value_Out : STD_LOGIC_VECTOR(3 downto 0); 
signal S_in : STD_LOGIC; 
begin 
uut: w2_4_MUX port map ( Load_Select => S_in, Immediate => B_in, S => A_in, Value_In => Value_Out ); stim_proc: 
process begin --230356 => 11 1000 0011 1101 0100 
-- First case: 0100 and 1101 
A_in <= "0100"; 
B_in <= "1101"; 
S_in <= '0'; 
wait for 200 ns; 
S_in <= '1'; 
wait for 200 ns; 
S_in <= '0'; 
wait for 100 ns; -- Second case: 0011 and 1000 
A_in <= "0011"; 
B_in <= "1000"; 
S_in <= '1'; 
wait for 200 ns;
S_in <= '0'; wait; 
end process; 
end Behavioral;