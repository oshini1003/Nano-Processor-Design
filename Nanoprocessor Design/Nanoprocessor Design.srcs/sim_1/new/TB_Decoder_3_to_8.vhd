----------------------------------------------------------------------------------
-- Company: UOM CSE
-- Engineer: 240343T
-- 
-- Create Date: 02/24/2026 02:53:22 PM
-- Design Name: Lab 4
-- Module Name: TB_Decoder_3_to_8 - Behavioral
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

entity TB_Decoder_3_to_8 is
--  Port ( );
end TB_Decoder_3_to_8;

architecture Behavioral of TB_Decoder_3_to_8 is
COMPONENT Decoder_3_to_8
Port (
    I : IN std_logic_vector(2 downto 0);
    EN : IN STD_LOGIC;
    Y : OUT std_logic_vector(7 downto 0)
);
END COMPONENT;
SIGNAL I : std_logic_vector(2 downto 0);
SIGNAL EN : STD_LOGIC ;
SIGNAL Y : std_logic_vector(7 downto 0);

begin
UUT : Decoder_3_to_8 PORT MAP (
    I => I,
    EN => EN,
    Y => Y
);
process
    begin
    --Registration number - 240343T - 111 010 100 010 101 011
    I <= "011";
    EN <= '1';
    wait for 100ns;
    
    I <= "101";
    EN <= '1';
    wait for 100ns;
    
    I <= "010";
    EN <= '1';
    wait for 100ns;
    
    I <= "100";
    EN <= '1';
    wait for 100ns;
    
    I <= "111";
    EN <= '1';
    wait for 100ns;
    
    --Inputed random numbers
    
    I <= "001";
    EN <= '1';
    wait for 100ns;
    
    I <= "011";
    EN <= '0';
    wait for 100ns;
    
    I <= "110";
    EN <= '0';
    wait;
END process;
    

end Behavioral;