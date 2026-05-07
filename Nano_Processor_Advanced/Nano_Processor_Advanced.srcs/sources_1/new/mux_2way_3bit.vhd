----------------------------------------------------------------------------------
-- Company: UOM - CSE'24 - GROUP 45
-- Engineer: Kethmika K A D Y
-- 
-- Create Date: 05/07/2026 02:34:03 PM
-- Design Name: 
-- Module Name: mux_2way_3bit - Behavioral
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

entity mux_2way_3bit is
    port (
        sel    : in  std_logic;                       -- Select line
        in0    : in  std_logic_vector(2 downto 0);    -- Input 0 (PC+1)
        in1    : in  std_logic_vector(2 downto 0);    -- Input 1 (jump addr)
        output : out std_logic_vector(2 downto 0)
    );
end mux_2way_3bit;

architecture rtl of mux_2way_3bit is
begin
    output <= in0 when sel = '0' else in1;

end rtl;