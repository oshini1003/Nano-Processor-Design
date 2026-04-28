----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/28/2026 01:56:57 PM
-- Design Name: 
-- Module Name: D_FF_Sim - Behavioral
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

entity D_FF_Sim is
--  Port ( );
end D_FF_Sim;

architecture Behavioral of D_FF_Sim is
COMPONENT D_FF
Port ( D : in STD_LOGIC;
Res : in STD_LOGIC;
Clk : in STD_LOGIC;
Q : out STD_LOGIC;
Qbar : out STD_LOGIC);
END COMPONENT;
signal D, Res : STD_LOGIC ;
signal Q, Qbar : STD_LOGIC;
signal Clk :STD_LOGIC :='0';
begin
UUT:D_FF PORT MAP (
D => D,
Res => Res,
Clk => Clk,
Q => Q,
Qbar => Qbar);
process
begin
Clk<=NOT(Clk);
wait for 20 ns; -- Half clock period
end process;
process
begin
D<='0';
Res<='1'; wait for 50 ns;
Res<='0';
D<='0'; wait for 50 ns;
D<='1'; wait for 50 ns;
D<='0'; wait for 50 ns;
end process;


end Behavioral;
