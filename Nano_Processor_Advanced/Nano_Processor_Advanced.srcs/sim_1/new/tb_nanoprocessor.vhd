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
            r7_debug  : out std_logic_vector(3 downto 0) -- FIXED: Matches top module port name
        );
    end component;

    -- Test signals
    signal clk       : std_logic := '0';
    signal reset_btn : std_logic := '0';
    signal led       : std_logic_vector(15 downto 0);
    signal seg       : std_logic_vector(6 downto 0);
    signal an        : std_logic_vector(3 downto 0);
    signal pc_debug  : std_logic_vector(2 downto 0);
    signal r7_debug  : std_logic_vector(3 downto 0);
    
    constant CLK_PERIOD : time := 10 ns; 

begin

    -- Instantiate top-level design
    DUT: nanoprocessor_top
        port map (
            clk => clk, 
            reset_btn => reset_btn,
            led => led, 
            seg => seg, 
            an => an,
            pc_debug => pc_debug, 
            r7_debug => r7_debug -- FIXED: Mapping to correct debug port
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
        -- Note: In simulation, the clock divider in the TOP module should be 
        -- bypassed or reduced, otherwise 50 million cycles takes forever.
        -- For this testbench, we assume the slow_clk is toggling.
        procedure check_state(cycle_num : integer; exp_pc : std_logic_vector(2 downto 0)) is
        begin
            -- Wait for the next rising edge of the slow clock (via LED heartbeat or PC change)
            wait until rising_edge(led(12)); 
            wait for 20 ns; -- Small offset to allow signals to settle
            
            report "[T" & integer'image(cycle_num) & "] PC: " & 
                   integer'image(to_integer(unsigned(pc_debug))) & 
                   " | R1 (LEDs): " & integer'image(to_integer(unsigned(led(3 downto 0))));
                   
            assert pc_debug = exp_pc 
                report "PC mismatch at cycle " & integer'image(cycle_num) 
                severity warning;
        end procedure;
        
    begin
        report "Starting Nanoprocessor Simulation...";
        
        -- Initial reset
        reset_btn <= '1';
        wait for 100 ns;
        reset_btn <= '0';
        
        -- Testing the sequence defined in your program ROM
        -- We check the PC and the LEDs (since LED 3:0 shows R1)
        check_state(0, "001"); -- After MOVI R1, 10
        check_state(1, "010"); -- After MOVI R2, 1
        check_state(2, "011"); -- After NEG R2
        check_state(3, "100"); -- After ADD R1, R2
        
        -- Add more checkpoints based on your logic
        report "Loop testing initiated...";
        for i in 4 to 15 loop
            check_state(i, pc_debug);
        end loop;

        report "Simulation finished.";
        wait;
    end process;

end behavioral;