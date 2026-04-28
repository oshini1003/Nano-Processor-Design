----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/23/2026 09:19:03 PM
-- Design Name: 
-- Module Name: TB_LUT_16_7 - Behavioral
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

entity TB_LUT_16_7 is
--  Port ( );
end TB_LUT_16_7;

architecture Behavioral of TB_LUT_16_7 is
component LUT_16_7
    Port ( address : in STD_LOGIC_VECTOR (3 downto 0);
           data : out STD_LOGIC_VECTOR (6 downto 0));
end component;
signal address : STD_LOGIC_VECTOR (3 downto 0);
signal data : STD_LOGIC_VECTOR (6 downto 0);
begin
    UUT : LUT_16_7 port map(
        address => address,
        data => data
        );
    process begin
--Register Number : 240347
-- Converted Binary Number: 0010 0100 0000 0011 0100 0111 
        address <= "0000"; wait for 100ns;
        address <= "0001"; wait for 100ns;
        address <= "0010"; wait for 100ns; -- Digit 2
        address <= "0011"; wait for 100ns; -- Digit 3
        address <= "0100"; wait for 100ns; -- Digit 4
        address <= "0101"; wait for 100ns;
        address <= "0110"; wait for 100ns;
        address <= "0111"; wait for 100ns; -- Digit 7
        address <= "1000"; wait for 100ns;
        address <= "1001"; wait for 100ns;
        address <= "1010"; wait for 100ns;
        address <= "1011"; wait for 100ns;
        address <= "1100"; wait for 100ns;
        address <= "1101"; wait for 100ns;
        address <= "1110"; wait for 100ns;
        address <= "1111"; wait for 100ns;
        wait;
    end process;

end Behavioral;
