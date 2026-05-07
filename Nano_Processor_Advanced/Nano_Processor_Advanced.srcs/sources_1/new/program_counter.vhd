----------------------------------------------------------------------------------
-- Company: UOM - CSE'24 - GROUP 45
-- Engineer: Kethmika K A D Y
-- 
-- Create Date: 05/07/2026 02:29:10 PM
-- Design Name: 
-- Module Name: program_counter - Behavioral
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

entity program_counter is
    port (
        clk    : in  std_logic;
        reset  : in  std_logic;  -- Synchronous reset (active high)
        enable : in  std_logic;  -- Enable counting
        load   : in  std_logic;  -- Load jump address (overrides increment)
        input  : in  std_logic_vector(2 downto 0);  -- Jump target address
        output : out std_logic_vector(2 downto 0)   -- Current PC value
    );
end program_counter;

architecture rtl of program_counter is
    signal pc_reg : std_logic_vector(2 downto 0) := "000";
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                pc_reg <= "000";
            elsif load = '1' then
                pc_reg <= input;  -- Load jump address
            elsif enable = '1' then
                pc_reg <= std_logic_vector(unsigned(pc_reg) + 1);  -- Increment
            end if;
        end if;
    end process;
    
    output <= pc_reg;

end rtl;
