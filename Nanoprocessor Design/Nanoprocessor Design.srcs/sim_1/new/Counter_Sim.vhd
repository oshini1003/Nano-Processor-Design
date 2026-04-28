----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/28/2026 02:02:02 PM
-- Design Name: 
-- Module Name: Counter_Sim - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Counter_Sim is
-- Port ( );
end Counter_Sim;
architecture Behavioral of Counter_Sim is
COMPONENT Counter
Port ( Dir : in STD_LOGIC;
Res : in STD_LOGIC;
Clk : in STD_LOGIC;
Q : out STD_LOGIC_VECTOR (2 downto 0));
END COMPONENT;
SIGNAL dir : std_logic := '0';
SIGNAL res : std_logic := '0';
SIGNAL clk : std_logic := '0';
SIGNAL q : std_logic_vector(2 downto 0);
begin
UUT : Counter PORT MAP(
Dir => dir,
Res => res,
Clk => clk,
Q => q
);
process begin
res <= '1';
wait for 100ns;
res <= '0';
dir <= '1';
wait for 400ns;
dir <= '0';
wait for 400 ns;
wait;
end process;
process begin
clk <= (not clk);
wait for 5ns;
end process;
end Behavioral;