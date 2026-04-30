----------------------------------------------------------------------------------
-- Company: UOM CSE
-- Engineer: 240343T
-- 
-- Create Date: 02/24/2026 03:41:49 PM
-- Design Name: Lab 4
-- Module Name: Program_Counter_3bit_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Testbench for 3-bit Program Counter
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

entity Program_Counter_3bit_tb is
end Program_Counter_3bit_tb;

architecture Behavioral of Program_Counter_3bit_tb is

    component Program_Counter_3bit
        Port ( 
            Mux_out : in  STD_LOGIC_VECTOR(2 downto 0);
            Clk     : in  STD_LOGIC;
            Res     : in  STD_LOGIC;
            Q       : out STD_LOGIC_VECTOR(2 downto 0)
        );
    end component;

    signal Mux_out : STD_LOGIC_VECTOR(2 downto 0) := "000";
    signal Clk     : STD_LOGIC := '0';
    signal Res     : STD_LOGIC := '0';
    signal Q       : STD_LOGIC_VECTOR(2 downto 0);

begin

    uut: Program_Counter_3bit
        port map ( 
            Mux_out => Mux_out,
            Clk     => Clk,
            Res     => Res,
            Q       => Q
        );

    clk_process : process
    begin
        while true loop
            Clk <= '0';
            wait for 5 ns;
            Clk <= '1';
            wait for 5 ns;
        end loop;
    end process;

    stim_proc: process
    begin
        Res <= '1';
        wait for 10 ns;
        Res <= '0';

        Mux_out <= "001";
        wait for 10 ns;

        Mux_out <= "010";
        wait for 10 ns;

        Mux_out <= "011";
        wait for 10 ns;

        Mux_out <= "100";
        wait for 10 ns;

        Mux_out <= "101";
        wait for 10 ns;

        Res <= '1';
        wait for 10 ns;
        Res <= '0';

        Mux_out <= "111";
        wait for 20 ns;

        wait;
    end process;

end Behavioral;