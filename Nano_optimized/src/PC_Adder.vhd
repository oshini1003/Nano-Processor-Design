library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.BusDefinitions.ProgramCounter;

entity PC_Adder is
    port (
        current_address : in  ProgramCounter;  -- Current program counter value
        next_address    : out ProgramCounter   -- Next program counter value (current + 1)
    );
end PC_Adder;

architecture Behavioral of PC_Adder is
begin
    next_address <= std_logic_vector(unsigned(current_address) + 1);
end Behavioral;
