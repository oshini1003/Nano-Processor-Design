library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Top_Module_TB is
-- Testbench entities have no input or output ports
end Top_Module_TB;

architecture Behavioral of Top_Module_TB is

    -- Declare the Top_Module component so the testbench knows what it is
    component Top_Module
        Port ( clk            : in  STD_LOGIC;
               reset          : in  STD_LOGIC;
               overflow_final : out STD_LOGIC;
               zero_final     : out STD_LOGIC;
               output         : out STD_LOGIC_VECTOR(3 downto 0);
               Reg7_7seg      : out STD_LOGIC_VECTOR (6 downto 0);
               Anode          : out STD_LOGIC_VECTOR (3 downto 0));
    end component;

    -- Signals to connect to the Top_Module ports
    signal clk_tb            : STD_LOGIC := '0';
    signal reset_tb          : STD_LOGIC := '0';
    signal overflow_final_tb : STD_LOGIC;
    signal zero_final_tb     : STD_LOGIC;
    signal output_tb         : STD_LOGIC_VECTOR(3 downto 0);
    signal Reg7_7seg_tb      : STD_LOGIC_VECTOR(6 downto 0);
    signal Anode_tb          : STD_LOGIC_VECTOR(3 downto 0);

    -- Define the clock period (10 ns = 100 MHz, matching the Basys3 board)
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    UUT: Top_Module 
    Port Map (
        clk            => clk_tb,
        reset          => reset_tb,
        overflow_final => overflow_final_tb,
        zero_final     => zero_final_tb,
        output         => output_tb,
        Reg7_7seg      => Reg7_7seg_tb,
        Anode          => Anode_tb
    );

    -- Process to generate the continuous clock signal
    clk_process : process
    begin
        clk_tb <= '0';
        wait for clk_period/2;
        clk_tb <= '1';
        wait for clk_period/2;
    end process;

    -- Process to apply the test stimuli (Resetting the processor)
    stim_proc: process
    begin        
        -- 1. Hold the processor in reset for the first 100 nanoseconds
        reset_tb <= '1';
        wait for 100 ns;
        
        -- 2. Release the reset and let the processor run freely
        reset_tb <= '0';
        
        -- 3. Wait indefinitely. The simulation stops based on the time you set in Vivado.
        wait;
    end process;

end Behavioral;