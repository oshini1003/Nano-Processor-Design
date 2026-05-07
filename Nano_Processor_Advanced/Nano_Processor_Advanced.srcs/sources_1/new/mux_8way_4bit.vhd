----------------------------------------------------------------------------------
-- Company: UOM - CSE'24 - GROUP 45
-- Engineer: Kethmika K A D Y
-- 
-- Create Date: 05/07/2026 02:32:25 PM
-- Design Name: 
-- Module Name: mux_8way_4bit - Behavioral
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


entity mux_8way_4bit is
    port (
        sel    : in  std_logic_vector(2 downto 0);
        in0    : in  std_logic_vector(3 downto 0);
        in1    : in  std_logic_vector(3 downto 0);
        in2    : in  std_logic_vector(3 downto 0);
        in3    : in  std_logic_vector(3 downto 0);
        in4    : in  std_logic_vector(3 downto 0);
        in5    : in  std_logic_vector(3 downto 0);
        in6    : in  std_logic_vector(3 downto 0);
        in7    : in  std_logic_vector(3 downto 0);
        output : out std_logic_vector(3 downto 0)
    );
end mux_8way_4bit;

architecture rtl of mux_8way_4bit is
begin
    process(sel, in0, in1, in2, in3, in4, in5, in6, in7)
    begin
        case sel is
            when "000"  => output <= in0;
            when "001"  => output <= in1;
            when "010"  => output <= in2;
            when "011"  => output <= in3;
            when "100"  => output <= in4;
            when "101"  => output <= in5;
            when "110"  => output <= in6;
            when "111"  => output <= in7;
            when others => output <= "0000";
        end case;
    end process;

end rtl;
