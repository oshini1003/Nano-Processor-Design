----------------------------------------------------------------------------------
-- Company: UOM - CSE'24 - GROUP 45
-- Engineer: Kethmika K A D Y
-- 
-- Create Date: 04/30/2026 11:22:30 AM
-- Design Name: 
-- Module Name: program_rom - Behavioral
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

entity program_rom is
    Port (
        addr      : in  STD_LOGIC_VECTOR(2 downto 0);  -- 3-bit address (0-7)
        data_out  : out STD_LOGIC_VECTOR(11 downto 0)  -- 12-bit instruction
    );
end program_rom;

architecture Behavioral of program_rom is
    type rom_array is array (0 to 7) of STD_LOGIC_VECTOR(11 downto 0);
    
    -- SAMPLE PROGRAM: Calculate 10 - 1 = 9
    constant rom_content : rom_array := (
        -- MOVI R1, 10: 10 001 0000 1010
        0 => "100010000101",  -- R1 ? 10
        
        -- MOVI R2, 1: 10 010 0000 0001
        1 => "100100000001",  -- R2 ? 1
        
        -- NEG R2: 01 010 0000 0000
        2 => "010100000000",  -- R2 ? -R2 (now -1)
        
        -- ADD R1, R2: 00 001001010 0000
        3 => "000001010000",  -- R1 ? R1 + R2 (10 + (-1) = 9)
        
        -- JZR R1, 7: 11 001 0000 111
        4 => "110010000111",  -- If R1==0, goto 7 (won't happen)
        
        -- JZR R0, 3: 11 000 0000 011
        5 => "110000000011",  -- If R0==0 (always), goto 3 (loop back)
        
        -- HALT/NOOP: 00 000000000 0000
        6 => "000000000000",  -- NOP (should never reach here)
        
        -- HALT/NOOP: 00 000000000 0000
        7 => "000000000000"   -- End of program
    );
begin
    process(addr)
    begin
        data_out <= rom_content(to_integer(unsigned(addr)));
    end process;
end Behavioral;