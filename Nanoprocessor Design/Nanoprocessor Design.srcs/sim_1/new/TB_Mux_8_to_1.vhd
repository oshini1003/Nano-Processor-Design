----------------------------------------------------------------------------------
-- Company:UOM CSE 
-- Engineer: 240343T
-- 
-- Create Date: 02/24/2026 04:01:06 PM
-- Design Name: Lab 4
-- Module Name: TB_Mux_8_to_1 - Behavioral
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

entity TB_Mux_8_to_1 is
--  Port ( );
end TB_Mux_8_to_1;

architecture Behavioral of TB_Mux_8_to_1 is
COMPONENT Mux_8_to_1
Port (
    S : IN std_logic_vector (2 downto 0);
    D : IN std_logic_vector (7 downto 0);
    EN : IN STD_LOGIC;
    Y : OUT STD_LOGIC
);
END COMPONENT;
SIGNAL S : std_logic_vector (2 downto 0);
SIGNAL D : std_logic_vector (7 downto 0);
SIGNAL EN : STD_LOGIC;
SIGNAL Y : STD_LOGIC;

begin
UUT : Mux_8_to_1 PORT MAP (
    D => D,
    S => S,
    EN => EN,
    Y => Y
);
process
    begin
    D <= "10101011"; --selected using last 8 digits of binary number of 240343
    S <= "001";
     EN <= '1';
     wait for 100 ns;
     D <= "11101010";  --selected using first 8 digits of binary number of 240343
     S <= "010";
     wait for 100 ns;
     D <= "00001100"; --Random inputs according to truth table 
     S <= "011";
     wait for 100 ns;
     D <= "00010001";
     S <= "100";
     wait for 100 ns;
     D <= "00100010";
     S <= "101";
     wait for 100 ns;
     D <= "01000011";
     S <= "110";
     wait for 100 ns;
     D <= "10000000";
     S <= "111";
     wait for 100 ns;
     D <= "00000001";
     S <= "000";
     wait for 100 ns;
     D <= "10000001";
     EN <= '0';
     S <= "000";
     wait for 100 ns;
     D <= "00110001";
     S <= "010";
     wait;
     end process;

end Behavioral;