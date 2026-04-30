----------------------------------------------------------------------------------
-- Company: UOM - CSE'24 - Group 45
-- Engineer: Kethmika K A D Y
-- 
-- Create Date: 04/30/2026 01:05:39 AM
-- Design Name: 
-- Module Name: alu_4bit - Behavioral
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

-- File: alu_4bit.vhd
-- Description: 4-bit Arithmetic Logic Unit
-- Functions: Addition and Subtraction using 2's complement
-- Inputs: A[3:0], B[3:0], add_sub (0=Add, 1=Sub)
-- Outputs: Result[3:0], Overflow, Zero

entity alu_4bit is
    Port (
        A       : in  STD_LOGIC_VECTOR(3 downto 0);  -- Input A
        B       : in  STD_LOGIC_VECTOR(3 downto 0);  -- Input B
        add_sub : in  STD_LOGIC;                      -- 0=Add, 1=Subtract
        result  : out STD_LOGIC_VECTOR(3 downto 0);   -- Result output
        overflow: out STD_LOGIC;                      -- Overflow flag
        zero    : out STD_LOGIC                       -- Zero flag
    );
end alu_4bit;

architecture Behavioral of alu_4bit is
    signal B_comp : STD_LOGIC_VECTOR(3 downto 0);
    signal sum    : STD_LOGIC_VECTOR(4 downto 0);     -- 5-bit for overflow detection
begin
    -- 2's complement for subtraction
    B_comp <= (not B) when add_sub = '1' else B;
    
    -- Perform addition/subtraction
    sum <= std_logic_vector(unsigned('0' & A) + unsigned('0' & B_comp) + (add_sub & ""));
    
    -- Output result (lower 4 bits)
    result <= sum(3 downto 0);
    
    -- Overflow detection: XOR of last two carry bits
    overflow <= (A(3) xor B_comp(3)) and (sum(3) xor A(3));
    
    -- Zero flag
    zero <= '1' when sum(3 downto 0) = "0000" else '0';
end Behavioral;
