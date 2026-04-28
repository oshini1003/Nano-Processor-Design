----------------------------------------------------------------------------------
-- Company: UOM CSE
-- Engineer: 240343T
-- 
-- Create Date: 02/24/2026 02:23:26 PM
-- Design Name: Lab 4
-- Module Name: TB_Decoder_2_to_4 - Behavioral
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

entity TB_Decoder_2_to_4 is
--  Port ( );
end TB_Decoder_2_to_4;

architecture Behavioral of TB_Decoder_2_to_4 is
COMPONENT Decoder_2_to_4
Port(
    I : IN std_logic_vector(1 downto 0);
    EN : IN STD_LOGIC;
    Y : OUT std_logic_vector(3 downto 0)
);
END COMPONENT;
SIGNAL I : std_logic_vector(1 downto 0);
SIGNAL EN : STD_LOGIC;
SIGNAL Y : std_logic_vector(3 downto 0);

begin
UUT : Decoder_2_to_4 PORT MAP(
    I => I,
    EN => EN,
    Y => Y);
process
    begin
    I <= "00";
    EN <='1';
    wait for 100ns;
    
    I <= "01";
    EN <='1';
    wait for 100ns;
    
    I <= "10";
    EN <='1';
    wait for 100ns;
    
    I <= "11";
    EN <='1';
    wait for 100ns;
    
    I <= "00";
    EN <='0';
    wait for 100ns;
    
    I <= "01";
    EN <='0';
    wait for 100ns;
    
    I <= "10";
    EN <='0';
    wait for 100ns;
    
    I <= "11";
    EN <='0';
    wait;
END process;

end Behavioral;