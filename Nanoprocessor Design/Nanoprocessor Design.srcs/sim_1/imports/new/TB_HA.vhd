----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/28/2026 09:50:34 AM
-- Design Name: 
-- Module Name: TB_HA - Behavioral
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

entity TB_HA is
end TB_HA;

architecture Behavioral of TB_HA is

    component HA
         port (A: in std_logic;
               B: in std_logic;
               S: out std_logic;
               C: out std_logic);
    end component; 
    
    signal A : std_logic;
    signal B : std_logic;
    signal S : std_logic;
    signal C : std_logic;
    

begin
  UUT : HA
      port map(
          A => A,
          B => B,
          S => S,
          C => C);
   process
   begin
       A <='0'; B <='0';
       wait for 100 ns;
       
       A <='0'; B <='1';
       wait for 100 ns;
       
       A <='1'; B <='0';
       wait for 100 ns;
       
       A <='1'; B <='1';
       wait for 100 ns;
       
       wait;
    end process;


end Behavioral;
