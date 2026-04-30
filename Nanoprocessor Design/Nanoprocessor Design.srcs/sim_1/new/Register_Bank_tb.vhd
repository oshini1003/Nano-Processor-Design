----------------------------------------------------------------------------------
-- Company: UOM CSE
-- Engineer: 
-- 
-- Create Date: 02/24/2026 03:41:49 PM
-- Design Name: Lab 4
-- Module Name: Register_Bank_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Testbench for 8x 4-bit Register Bank
-- 
-- Dependencies: Register_Bank
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Register_Bank_tb is
end Register_Bank_tb;

architecture Behavioral of Register_Bank_tb is

    -- Component Declaration for the Unit Under Test (UUT)
    component Register_Bank
        Port ( 
            Value_In : in  STD_LOGIC_VECTOR(3 downto 0);
            Clk      : in  STD_LOGIC;
            Reg_En   : in  STD_LOGIC_VECTOR(2 downto 0);
            Res      : in  STD_LOGIC;
            R0       : out STD_LOGIC_VECTOR(3 downto 0);
            R1       : out STD_LOGIC_VECTOR(3 downto 0);
            R2       : out STD_LOGIC_VECTOR(3 downto 0);
            R3       : out STD_LOGIC_VECTOR(3 downto 0);
            R4       : out STD_LOGIC_VECTOR(3 downto 0);
            R5       : out STD_LOGIC_VECTOR(3 downto 0);
            R6       : out STD_LOGIC_VECTOR(3 downto 0);
            R7       : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    -- Signals for connection
    signal Value_In : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal Clk      : STD_LOGIC := '0';
    signal Reg_En   : STD_LOGIC_VECTOR(2 downto 0) := "000";
    signal Res      : STD_LOGIC := '0';
    
    signal R0       : STD_LOGIC_VECTOR(3 downto 0);
    signal R1       : STD_LOGIC_VECTOR(3 downto 0);
    signal R2       : STD_LOGIC_VECTOR(3 downto 0);
    signal R3       : STD_LOGIC_VECTOR(3 downto 0);
    signal R4       : STD_LOGIC_VECTOR(3 downto 0);
    signal R5       : STD_LOGIC_VECTOR(3 downto 0);
    signal R6       : STD_LOGIC_VECTOR(3 downto 0);
    signal R7       : STD_LOGIC_VECTOR(3 downto 0);

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: Register_Bank
        port map ( 
            Value_In => Value_In,
            Clk      => Clk,
            Reg_En   => Reg_En,
            Res      => Res,
            R0       => R0,
            R1       => R1,
            R2       => R2,
            R3       => R3,
            R4       => R4,
            R5       => R5,
            R6       => R6,
            R7       => R7
        );

    -- Clock generation process (10 ns period)
    clk_process : process
    begin
        while true loop
            Clk <= '0';
            wait for 5 ns;
            Clk <= '1';
            wait for 5 ns;
        end loop;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Step 1: Apply reset (All registers should become "0000")
        Res <= '1';
        wait for 10 ns;
        Res <= '0';
        
        -- Step 2: Load "1010" into R1 (Reg_En = "001")
        Value_In <= "1010";
        Reg_En   <= "001";
        wait for 10 ns;
        
        -- Step 3: Load "0011" into R3 (Reg_En = "011")
        Value_In <= "0011";
        Reg_En   <= "011";
        wait for 10 ns;
        
        -- Step 4: Load "1111" into R7 (Reg_En = "111")
        Value_In <= "1111";
        Reg_En   <= "111";
        wait for 10 ns;
        
        -- Step 5: Change Value_In but don't change Reg_En 
        -- (Registers should hold their previous values)
        Value_In <= "0000";
        Reg_En   <= "000"; -- Selecting R0, which is hardwired to 0 anyway
        wait for 10 ns;
        
        -- Step 6: Apply reset again (All registers should clear to "0000")
        Res <= '1';
        wait for 10 ns;
        Res <= '0';
        
        -- Step 8: Load "1100" into R5 to verify it works after reset
        Value_In <= "1100";
        Reg_En   <= "101";
        wait for 20 ns;

        -- Stop simulation
        wait;
    end process;

end Behavioral;