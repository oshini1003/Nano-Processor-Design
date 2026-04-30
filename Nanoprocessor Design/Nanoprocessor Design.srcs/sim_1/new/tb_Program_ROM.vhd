library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity tb_Program_ROM is
end tb_Program_ROM;
architecture Behavioral of tb_Program_ROM is
-- Component Declaration
component Program_ROM
Port (
    Memory_Select : in STD_LOGIC_VECTOR (2 downto 0);
    Instruction : out STD_LOGIC_VECTOR (12 downto 0)
    );
end component;
-- Testbench Signals
signal Memory_Select : STD_LOGIC_VECTOR(2 downto 0) := "000";
signal Instruction : STD_LOGIC_VECTOR(12 downto 0);

begin
    -- Instantiate the Program ROM
    uut: Program_ROM
    port map (
        Memory_Select => Memory_Select,
        Instruction => Instruction
        );
    -- Stimulus process
    stim_proc: process
    begin
-- Go through all ROM locations from 0 to 7
        for i in 0 to 7 loop
            Memory_Select <= std_logic_vector(to_unsigned(i, 3));
            wait for 10 ns;
        end loop;
        wait;
    end process;
end Behavioral;