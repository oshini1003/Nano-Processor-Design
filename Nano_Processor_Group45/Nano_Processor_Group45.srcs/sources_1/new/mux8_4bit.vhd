----------------------------------------------------------------------------------
-- Company: UOM - CSE'24 - GROUP 45
-- Engineer: Kethmika K A D Y
-- 
-- Create Date: 04/30/2026 10:56:45 AM
-- Design Name: 
-- Module Name: mux8_4bit - Behavioral
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


entity mux8_4bit is
    Port (
        sel    : in  STD_LOGIC_VECTOR(2 downto 0);     -- Select lines (3 bits for 8 registers)
        in0    : in  STD_LOGIC_VECTOR(3 downto 0);     -- Register R0
        in1    : in  STD_LOGIC_VECTOR(3 downto 0);     -- Register R1
        in2    : in  STD_LOGIC_VECTOR(3 downto 0);     -- Register R2
        in3    : in  STD_LOGIC_VECTOR(3 downto 0);     -- Register R3
        in4    : in  STD_LOGIC_VECTOR(3 downto 0);     -- Register R4
        in5    : in  STD_LOGIC_VECTOR(3 downto 0);     -- Register R5
        in6    : in  STD_LOGIC_VECTOR(3 downto 0);     -- Register R6
        in7    : in  STD_LOGIC_VECTOR(3 downto 0);     -- Register R7
        mux_out: out STD_LOGIC_VECTOR(3 downto 0)      -- Selected output
    );
end mux8_4bit;

architecture Behavioral of mux8_4bit is
begin
    with sel select
        mux_out <= in0 when "000",
                   in1 when "001",
                   in2 when "010",
                   in3 when "011",
                   in4 when "100",
                   in5 when "101",
                   in6 when "110",
                   in7 when others;                    -- "111"
end Behavioral;