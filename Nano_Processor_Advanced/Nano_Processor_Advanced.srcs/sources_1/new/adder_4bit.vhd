----------------------------------------------------------------------------------
-- Company: UOM - CSE'24 - GROUP 45
-- Engineer: Kethmika K A D Y
-- 
-- Create Date: 05/07/2026 02:20:13 PM
-- Design Name: 
-- Module Name: adder_4bit - Behavioral
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

entity adder_4bit is
    port (
        A        : in  std_logic_vector(3 downto 0);
        B        : in  std_logic_vector(3 downto 0);
        Sub      : in  std_logic;  -- '1' = subtract, '0' = add
        Result   : out std_logic_vector(3 downto 0);
        Zero     : out std_logic;
        Overflow : out std_logic;
        Carry    : out std_logic
    );
end adder_4bit;

architecture rtl of adder_4bit is
    signal b_comp   : std_logic_vector(3 downto 0);
    signal sum_int  : unsigned(4 downto 0);
begin
    
    -- Two's complement B when subtracting
    b_comp <= not B when Sub = '1' else B;
    
    -- Perform addition/subtraction
    -- When Sub='1', effectively computes A + (~B) + 1 = A - B
    sum_int <= unsigned('0' & A) + unsigned(b_comp) + (Sub & Sub & Sub & Sub & Sub);
    
    -- Output assignments
    Result   <= std_logic_vector(sum_int(3 downto 0));
    Carry    <= sum_int(4);
    Zero     <= '1' when sum_int(3 downto 0) = "0000" else '0';
    
    -- Overflow detection for signed numbers
    process(A, B, Sub, sum_int)
    begin
        if Sub = '0' then
            -- Addition overflow: (+) + (+) = (-) or (-) + (-) = (+)
            if (A(3) = '0' and B(3) = '0' and sum_int(3) = '1') or 
               (A(3) = '1' and B(3) = '1' and sum_int(3) = '0') then
                Overflow <= '1';
            else
                Overflow <= '0';
            end if;
        else
            -- Subtraction overflow: signs of operands differ from result
            if (A(3) /= B(3)) and (sum_int(3) /= A(3)) then
                Overflow <= '1';
            else
                Overflow <= '0';
            end if;
        end if;
    end process;

end rtl;