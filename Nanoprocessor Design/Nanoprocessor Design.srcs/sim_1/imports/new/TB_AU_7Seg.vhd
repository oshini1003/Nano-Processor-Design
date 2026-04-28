----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/23/2026 10:05:09 PM
-- Design Name: 
-- Module Name: TB_AU_7Seg - Behavioral
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

entity TB_AU_7Seg is
--  Port ( );
end TB_AU_7Seg;

architecture Behavioral of TB_AU_7Seg is
component AU_7Seg
    Port ( A : in STD_LOGIC_VECTOR (3 downto 0);
           Clk : in STD_LOGIC;
           RegSel : in STD_LOGIC;
           S_LED : out STD_LOGIC_VECTOR (3 downto 0);
           S_7Seg : out STD_LOGIC_VECTOR (6 downto 0);
           Carry : out STD_LOGIC;
           Zero : out STD_LOGIC);
end component;

signal A,S_LED : std_logic_vector(3 downto 0);
signal RegSel, Zero, Carry : std_logic;
signal S_7Seg : std_logic_vector(6 downto 0);
signal Clk : std_logic := '0';

begin
    UUT : AU_7Seg
        port map(
        A => A,
        RegSel => RegSel,
        Clk => Clk,
        Zero => Zero,
        S_LED =>S_LED,
        S_7Seg => S_7Seg,
        Carry => Carry
        );
    process begin
        wait for 1 ns;
        Clk <= not(Clk);
    end process;
    
    process begin
        wait for 140ns;
        RegSel <= '0';
        A <= "1100";
        
        wait for 80ns;
        RegSel <= '1';
        A <= "1110";
        
        wait for 80ns;
        A <= "0001";
        
        wait for 80ns;
        A <= "0100";
        
        wait for 80ns;
        A <= "1110";
        
        wait for 80ns;
        A <= "0001";
        
        wait for 80ns;
        A <= "0100";
        
        wait for 80ns;
        A <= "0100";
        wait;
    end process;

end Behavioral;
