----------------------------------------------------------------------------------
-- Company: UOM - CSE'24 - GROUP 45
-- Engineer: Kethmika K A D Y
-- 
-- Create Date: 05/07/2026 02:22:41 PM
-- Design Name: 
-- Module Name: comparator_4bit - Behavioral
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

entity comparator_4bit is
    port (
        A           : in  std_logic_vector(3 downto 0);
        B           : in  std_logic_vector(3 downto 0);
        signed_mode : in  std_logic;  -- '1'=signed, '0'=unsigned
        A_eq_B      : out std_logic;  -- A equals B
        A_gt_B      : out std_logic;  -- A greater than B
        A_lt_B      : out std_logic   -- A less than B
    );
end comparator_4bit;

architecture rtl of comparator_4bit is
begin
    process(A, B, signed_mode)
        variable a_val : integer;
        variable b_val : integer;
    begin
        if signed_mode = '1' then
            a_val := to_integer(signed(A));
            b_val := to_integer(signed(B));
        else
            a_val := to_integer(unsigned(A));
            b_val := to_integer(unsigned(B));
        end if;
        
        if a_val = b_val then
            A_eq_B <= '1'; A_gt_B <= '0'; A_lt_B <= '0';
        elsif a_val > b_val then
            A_eq_B <= '0'; A_gt_B <= '1'; A_lt_B <= '0';
        else
            A_eq_B <= '0'; A_gt_B <= '0'; A_lt_B <= '1';
        end if;
    end process;

end rtl;
