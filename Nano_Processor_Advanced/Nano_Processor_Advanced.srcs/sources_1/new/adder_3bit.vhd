----------------------------------------------------------------------------------
-- Company: UOM - CSE'24 - GROUP 45
-- Engineer: Kethmika K A D Y
-- 
-- Create Date: 05/07/2026 02:35:06 PM
-- Design Name: 
-- Module Name: adder_3bit - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity adder_3bit is
    port (
        A   : in  std_logic_vector(2 downto 0);
        B   : in  std_logic_vector(2 downto 0);
        Cin : in  std_logic;
        Sum : out std_logic_vector(2 downto 0);
        Cout: out std_logic
    );
end adder_3bit;

architecture rtl of adder_3bit is
    signal sum_ext : unsigned(3 downto 0);
begin
    sum_ext <= unsigned('0' & A) + unsigned('0' & B) + ("000" & Cin);
    Sum  <= std_logic_vector(sum_ext(2 downto 0));
    Cout <= sum_ext(3);

end rtl;
