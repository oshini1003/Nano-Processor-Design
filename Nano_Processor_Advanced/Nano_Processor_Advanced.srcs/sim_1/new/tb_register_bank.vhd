----------------------------------------------------------------------------------
-- Company: UOM - CSE'24 - GROUP 45
-- Engineer: Kethmika K A D Y
-- 
-- Create Date: 05/07/2026 03:03:29 PM
-- Design Name: 
-- Module Name: tb_register_bank - Behavioral
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


entity tb_register_bank is
end tb_register_bank;

architecture behavioral of tb_register_bank is

    component register_bank
        port (
            clk        : in  std_logic;
            reset      : in  std_logic;
            write_en   : in  std_logic;
            reg_select : in  std_logic_vector(2 downto 0);
            data_in    : in  std_logic_vector(3 downto 0);
            r0_out     : out std_logic_vector(3 downto 0);
            r1_out     : out std_logic_vector(3 downto 0);
            r2_out     : out std_logic_vector(3 downto 0);
            r3_out     : out std_logic_vector(3 downto 0);
            r4_out     : out std_logic_vector(3 downto 0);
            r5_out     : out std_logic_vector(3 downto 0);
            r6_out     : out std_logic_vector(3 downto 0);
            r7_out     : out std_logic_vector(3 downto 0)
        );
    end component;

    signal clk, reset, wr_en : std_logic := '0';
    signal sel : std_logic_vector(2 downto 0) := "000";
    signal din : std_logic_vector(3 downto 0) := "0000";
    signal r0, r1, r2, r3, r4, r5, r6, r7 : std_logic_vector(3 downto 0);
    
    constant TCLK : time := 10 ns;

begin

    UUT: register_bank port map(
        clk=>clk, reset=>reset, write_en=>wr_en, reg_select=>sel, data_in=>din,
        r0_out=>r0, r1_out=>r1, r2_out=>r2, r3_out=>r3,
        r4_out=>r4, r5_out=>r5, r6_out=>r6, r7_out=>r7
    );

    clk <= not clk after TCLK/2;

    stimulus: process
    begin
        report "=== REGISTER BANK TEST - Team 240348/240351/240347/240343 ===";
        
        -- Reset
        reset <= '1'; wait for TCLK*2; reset <= '0';
        
        -- Verify all zeros after reset
        assert (r0="0000" and r1="0000" and r7="0000") 
            report "Reset failed" severity error;
        report "[PASS] Reset verified - all registers zero";
        
        -- Test R0 is read-only (hardwired to 0)
        sel <= "000"; din <= "1111"; wr_en <= '1';
        wait for TCLK; wr_en <= '0';
        assert r0 = "0000" report "R0 should be read-only!" severity error;
        report "[PASS] R0 is correctly read-only (always 0000)";
        
        -- Write to R1
        sel <= "001"; din <= "1010"; wr_en <= '1';
        wait for TCLK; wr_en <= '0';
        assert r1 = "1010" report "R1 write failed" severity error;
        report "[PASS] R1 written correctly (value=10)";
        
        -- Write to R2
        sel <= "010"; din <= "0001"; wr_en <= '1';
        wait for TCLK; wr_en <= '0';
        assert r2 = "0001" report "R2 write failed" severity error;
        assert r1 = "1010" report "R1 corrupted!" severity error;
        report "[PASS] R2 written, R1 preserved";
        
        -- Overwrite R1
        sel <= "001"; din <= "1111"; wr_en <= '1';
        wait for TCLK; wr_en <= '0';
        assert r1 = "1111" report "R1 overwrite failed" severity error;
        report "[PASS] R1 overwritten correctly";
        
        -- Test R7
        sel <= "111"; din <= "1001"; wr_en <= '1';
        wait for TCLK; wr_en <= '0';
        assert r7 = "1001" report "R7 write failed" severity error;
        report "[PASS] R7 written correctly (value=9)";
        
        -- Reset again
        reset <= '1'; wait for TCLK*2; reset <= '0';
        assert (r1="0000" and r7="0000") report "Reset failed again" severity error;
        report "[PASS] Second reset successful";
        
        report "=== ALL REGISTER BANK TESTS PASSED ===";
        wait;
    end process;

end behavioral;
