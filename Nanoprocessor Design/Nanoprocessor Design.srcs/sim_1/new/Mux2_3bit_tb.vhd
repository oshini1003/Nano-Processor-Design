library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity Mux2_3bit_tb is
end Mux2_3bit_tb;
architecture Behavioral of Mux2_3bit_tb is
-- Component declaration
component Mux2_3bit
Port (
A : in STD_LOGIC_VECTOR(2 downto 0);
B : in STD_LOGIC_VECTOR(2 downto 0);
Sel : in STD_LOGIC;
Y : out STD_LOGIC_VECTOR(2 downto 0)
);
end component;
-- Testbench signals
signal A_tb, B_tb, Y_tb : STD_LOGIC_VECTOR(2 downto 0);
signal Sel_tb : STD_LOGIC;
begin
-- Instantiate the Unit Under Test (UUT)
uut: Mux2_3bit
port map (
A => A_tb,
B => B_tb,
Sel => Sel_tb,
Y => Y_tb
);
-- Stimulus process
stim_proc: process
begin
-- Test 1: Select A
A_tb <= "000"; B_tb <= "111"; Sel_tb <= '0';
wait for 10 ns;
-- Test 2: Select B
Sel_tb <= '1';
wait for 10 ns;
-- Test 3: Change inputs
A_tb <= "101"; B_tb <= "010"; Sel_tb <= '0';
wait for 10 ns;
Sel_tb <= '1';
wait for 10 ns;
-- Test 4: Same values on A and B
A_tb <= "011"; B_tb <= "011"; Sel_tb <= '0';
wait for 10 ns;
Sel_tb <= '1';
wait for 10 ns;
-- End simulation
wait;
end process;
end Behavioral;