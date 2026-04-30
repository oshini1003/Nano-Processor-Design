----------------------------------------------------------------------------------
-- Company: UOM CSE
-- Engineer: 240343T
-- 
-- Create Date: 02/24/2026 03:41:49 PM
-- Design Name: Lab 4
-- Module Name: Reg - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 4-bit Register with Enable and Synchronous Reset
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

entity Reg is
    Port ( 
        D   : in  STD_LOGIC_VECTOR(3 downto 0);
        En  : in  STD_LOGIC;
        Clk : in  STD_LOGIC;
        Res : in  STD_LOGIC;
        Q   : out STD_LOGIC_VECTOR(3 downto 0)
    );
end Reg;

architecture Behavioral of Reg is
begin
    process(Clk)
    begin
        if rising_edge(Clk) then
            if Res = '1' then       -- Synchronous Reset added
                Q <= "0000";
            elsif En = '1' then     -- Enable check
                Q <= D;
            end if;
        end if;
    end process;
end Behavioral;