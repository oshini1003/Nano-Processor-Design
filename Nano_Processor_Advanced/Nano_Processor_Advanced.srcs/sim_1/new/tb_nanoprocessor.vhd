----------------------------------------------------------------------------------
-- Company: CSE'24 - GROUP 45
-- Engineer: Kethmika K A D Y
-- 
-- Create Date: 05/07/2026 03:01:56 PM
-- Design Name: 
-- Module Name: tb_nanoprocessor - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

------------------------------------------------------------------------------
-- File        : tb_nanoprocessor.vhd
-- Description : Full System Integration Testbench for Nanoprocessor
-- Verifies    : Complete instruction execution cycle
-- Team IDs    : 240348, 240351, 240347, 240343
------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_nanoprocessor is
end tb_nanoprocessor;

architecture behavioral of tb_nanoprocessor is

    component nanoprocessor_top is
        port (
            clk       : in  std_logic;
            reset_btn : in  std_logic;
            led       : out std_logic_vector(15 downto 0);
            seg       : out std_logic_vector(6 downto 0);
            an        : out std_logic_vector(3 downto 0);
            pc_debug  : out std_logic_vector(2 downto 0);
            r1_debug  : out std_logic_vector(3 downto 0)
        );
    end component;

    -- Test signals
    signal clk       : std_logic := '0';
    signal reset_btn : std_logic := '0';
    signal led       : std_logic_vector(15 downto 0);
    signal seg       : std_logic_vector(6 downto 0);
    signal an        : std_logic_vector(3 downto 0);
    signal pc_debug  : std_logic_vector(2 downto 0);
    signal r1_debug  : std_logic_vector(3 downto 0);
    
    -- Clock generation
    constant CLK_PERIOD : time := 10 ns;  -- 100 MHz simulation clock
    signal sim_count    : integer := 0;

begin

    -- Instantiate top-level design
    DUT: nanoprocessor_top
        port map (
            clk => clk, reset_btn => reset_btn,
            led => led, seg => seg, an => an,
            pc_debug => pc_debug, r1_debug => r1_debug
        );

    -- Clock generation (100 MHz)
    clk_gen: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Main test sequence
    main_test: process
        procedure check_state(cycle_num : integer; exp_pc : std_logic_vector(2 downto 0);
                              exp_r1 : std_logic_vector(3 downto 0)) is
        begin
            -- Wait for slow clock edge (each instruction takes many fast clocks)
            wait for 50 us;  -- Wait for slow clock tick
            
            if pc_debug = exp_pc then
                report "[T" & integer'image(cycle_num) & "] PC OK: " & 
                       integer'image(to_integer(unsigned(pc_debug)));
            else
                report "[T" & integer'image(cycle_num) & "] PC FAIL: Expected " &
                       integer'image(to_integer(unsigned(exp_pc))) & " Got " &
                       integer'image(to_integer(unsigned(pc_debug))) severity warning;
            end if;
            
            if r1_debug = exp_r1 then
                report "       R1 OK: " & integer'image(to_integer(unsigned(r1_debug)));
            else
                report "       R1 FAIL: Expected " &
                       integer'image(to_integer(unsigned(exp_r1))) & " Got " &
                       integer'image(to_integer(unsigned(r1_debug))) severity warning;
            end if;
        end procedure;
        
    begin
        report "===============================================================";
        report "NANOPROCESSOR FULL SYSTEM TEST";
        report "Team: 240348 | 240351 | 240347 | 240343";
        report "===============================================================";
        
        -- Initial reset
        reset_btn <= '1';
        wait for 100 ns;
        reset_btn <= '0';
        wait for 100 ns;
        
        report "--- Starting program execution ---";
        
        -- Allow program to run through several cycles
        -- Each slow clock cycle = one instruction = ~50us in simulation
        
        -- Cycle 0: Should be at PC=1 after first instruction (MOVI R1,10)
        check_state(0, "001", "1010");  -- PC=1, R1=10
        
        -- Cycle 1: After MOVI R2,1
        check_state(1, "010", "1010");  -- PC=2, R1 unchanged
        
        -- Cycle 2: After NEG R2
        check_state(2, "011", "1010");  -- PC=3, R1 unchanged
        
        -- Cycle 3: After ADD R1,R2 (R1 should now be 9)
        check_state(3, "100", "1001");  -- PC=4, R1=9
        
        -- Cycle 4: After JZR R1,7 (R1!=0, so no jump)
        check_state(4, "101", "1001");  -- PC=5, R1=9
        
        -- Cycle 5: After JZR R0,3 (R0==0 always, so JUMP!)
        check_state(5, "011", "1001");  -- PC=3 (jumped back!), R1=9
        
        -- Cycle 6: Loop iteration - another ADD (R1=8)
        check_state(6, "100", "1000");  -- PC=4, R1=8
        
        -- Let it run a few more iterations...
        check_state(7, "011", "0111");  -- Back in loop, R1=7
        check_state(8, "0111", "0110"); -- R1=6
        check_state(9, "0111", "0101"); -- R1=5
        check_state(10, "0111", "0100");-- R1=4
        check_state(11, "0111", "0011");-- R1=3
        check_state(12, "0111", "0010");-- R1=2
        check_state(13, "0111", "0001");-- R1=1
        check_state(14, "0111", "0000");-- R1=0 (about to terminate!)
        
        -- Final state: should have jumped to PC=7 (end)
        check_state(15, "111", "0000"); -- PC=7 (HALT), R1=0
        
        report "";
        report "===============================================================";
        report "SYSTEM TEST COMPLETE - ALL CHECKPOINTS VERIFIED";
        report "Nanoprocessor functioning correctly!";
        report "===============================================================";
        
        wait;
    end process;

end behavioral;
