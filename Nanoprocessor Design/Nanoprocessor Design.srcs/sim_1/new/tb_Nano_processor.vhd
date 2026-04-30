library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_Nano_processor is
-- Testbench entities are always empty
end tb_Nano_processor;

architecture Behavioral of tb_Nano_processor is

    -- Declare the component you are testing (Unit Under Test)
    component Nano_processor
        Port ( clk            : in  STD_LOGIC;
               reset          : in  STD_LOGIC;
               overflow_final : out STD_LOGIC;
               zero_final     : out STD_LOGIC;
               output         : out STD_LOGIC_VECTOR(3 downto 0);
               Reg7_7seg      : out STD_LOGIC_VECTOR (6 downto 0);
               Anode          : out STD_LOGIC_VECTOR (3 downto 0) );
    end component;

    -- Define signals to connect to the Nano_processor
    signal clk_tb            : STD_LOGIC := '0';
    signal reset_tb          : STD_LOGIC := '1'; -- Start with reset active
    signal overflow_final_tb : STD_LOGIC;
    signal zero_final_tb     : STD_LOGIC;
    signal output_tb         : STD_LOGIC_VECTOR(3 downto 0);
    signal Reg7_7seg_tb      : STD_LOGIC_VECTOR(6 downto 0);
    signal Anode_tb          : STD_LOGIC_VECTOR(3 downto 0);

    -- Define the clock period for the testbench
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Nano_processor
    uut: Nano_processor 
    Port map(
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

    -- Process to provide the stimulus (reset toggling)
    stim_proc: process
    begin        
        -- Hold the processor in reset for a few clock cycles
        wait for 100 ns;  
        
        -- Release the reset and let the processor run
        reset_tb <= '0';
        
        -- Let it run freely to observe behaviour
        wait for 1000 ns; 
        
        -- Stop the simulation
        wait;
    end process;

end Behavioral;