----------------------------------------------------------------------------------
-- Company: UOM CSE
-- Engineer: 240343T
-- 
-- Create Date: 02/24/2026 03:41:49 PM
-- Design Name: Lab 4
-- Module Name: Program_Counter_3bit - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 3-bit Program Counter with synchronous reset
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

entity Program_Counter_3bit is
    Port ( 
        Mux_out : in  STD_LOGIC_VECTOR(2 downto 0);
        Clk     : in  STD_LOGIC;
        Res     : in  STD_LOGIC;
        Q       : out STD_LOGIC_VECTOR(2 downto 0)
    );
end Program_Counter_3bit;

architecture Behavioral of Program_Counter_3bit is
    signal PC : STD_LOGIC_VECTOR(2 downto 0) := "000";
begin

    process(Clk, Res)
    begin
        if rising_edge(Clk) then
            if Res = '1' then
                PC <= "000";
            else
                PC <= Mux_out;
            end if; 
        end if;
    end process;

    Q <= PC;

end Behavioral;