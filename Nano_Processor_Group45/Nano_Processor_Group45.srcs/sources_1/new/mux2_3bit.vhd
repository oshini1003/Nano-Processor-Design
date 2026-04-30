----------------------------------------------------------------------------------
-- Company: UOM - CSE'24 - GROUP 45
-- Engineer: Kethmika K A D Y
-- 
-- Create Date: 04/30/2026 10:58:54 AM
-- Design Name: 
-- Module Name: mux2_3bit - Behavioral
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

entity mux2_3bit is
    Port (
        sel    : in  STD_LOGIC;                        -- Select line (0=PC+1, 1=Jump address)
        in0    : in  STD_LOGIC_VECTOR(2 downto 0);     -- Input 0: PC+1 from adder
        in1    : in  STD_LOGIC_VECTOR(2 downto 0);     -- Input 1: Jump address from instruction
        mux_out: out STD_LOGIC_VECTOR(2 downto 0)      -- Output to PC
    );
end mux2_3bit;

architecture Behavioral of mux2_3bit is
begin
    mux_out <= in0 when sel = '0' else in1;
end Behavioral;