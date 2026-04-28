----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/28/2026 09:54:38 AM
-- Design Name: 
-- Module Name: TB_FA - Behavioral
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

entity TB_FA is
--  Port ( );
end TB_FA;

architecture Behavioral of TB_FA is
       component FA
            port( A: in std_logic;
                  B: in std_logic;
                  C_in: in std_logic;
                  S: out std_logic;
                  C_out: out std_logic);
        end component;
        
        signal A : std_logic;
        signal B : std_logic;
        signal C_in : std_logic;
        signal S : std_logic;
        signal C_out : std_logic;
        
begin   
   UUT: FA
      port map(
          A => A,
          B => B,
          C_in => C_in,
          S => S,
          C_out => C_out);
          
    process 
    begin
       A <='0'; B <='0'; C_in <='0';
       wait for 100 ns;
       
       A <='0'; B <='0'; C_in <='1';
       wait for 100 ns;
       
       A <='0'; B <='1'; C_in <='0';
       wait for 100 ns;
       
       A <='0'; B <='1'; C_in <='1';
       wait for 100 ns;
       
       A <='1'; B <='0'; C_in <='0';
       wait for 100 ns;
       
       A <='1'; B <='0'; C_in <='1';
       wait for 100 ns;
       
       A <='1'; B <='1'; C_in <='0';
       wait for 100 ns;
       
       A <='1'; B <='1'; C_in <='1';
       wait for 100 ns;
       
       wait;
    end process;

end behavioral;
