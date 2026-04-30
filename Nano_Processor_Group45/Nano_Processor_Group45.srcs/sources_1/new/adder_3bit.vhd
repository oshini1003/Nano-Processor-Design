----------------------------------------------------------------------------------
-- Company: UOM-CSE'24-group 45
-- Engineer: Kethmika K A D Y
-- 
-- Create Date: 04/30/2026 01:17:32 AM
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
    Port (
        A     : in  STD_LOGIC_VECTOR(2 downto 0);
        B     : in  STD_LOGIC_VECTOR(2 downto 0);
        cin   : in  STD_LOGIC;
        sum   : out STD_LOGIC_VECTOR(2 downto 0);
        cout  : out STD_LOGIC
    );
end adder_3bit;

architecture Behavioral of adder_3bit is
    signal full_sum : STD_LOGIC_VECTOR(3 downto 0);
begin
    full_sum <= std_logic_vector(unsigned('0' & A) + unsigned('0' & B) + ("" & cin));
    sum      <= full_sum(2 downto 0);
    cout     <= full_sum(3);
end Behavioral;