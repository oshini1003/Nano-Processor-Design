----------------------------------------------------------------------------------
-- Company: UOM - CSE'24 - Group 45
-- Engineer: Kethmika  K A D Y
-- 
-- Create Date: 04/30/2026 10:53:19 AM
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
    Port (
        clk    : in  STD_LOGIC;                        -- Clock input
        reset  : in  STD_LOGIC;                        -- Reset (active high)
        load   : in  STD_LOGIC;                        -- Load enable
        data_in: in  STD_LOGIC_VECTOR(2 downto 0);     -- Input data (jump address or PC+1)
        pc_out : out STD_LOGIC_VECTOR(2 downto 0)      -- Current PC value
    );
end program_counter;

architecture Behavioral of program_counter is
    signal pc_reg : STD_LOGIC_VECTOR(2 downto 0) := "000";
begin
    process(clk, reset)
    begin
        if reset = '1' then
            pc_reg <= "000";                           -- Reset to 0
        elsif rising_edge(clk) then
            if load = '1' then
                pc_reg <= data_in;                     -- Load new value
            end if;
        end if;
    end process;
    
    pc_out <= pc_reg;
end Behavioral;