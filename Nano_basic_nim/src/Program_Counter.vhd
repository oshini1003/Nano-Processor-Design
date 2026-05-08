library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.BusDefinitions.all;  

entity Program_Counter is
    Port (
        PC_Next    : in  ProgramCounter; 
        Res        : in  STD_LOGIC;
        Clk        : in  STD_LOGIC;
        PC_Current : out ProgramCounter
    );
end Program_Counter;

architecture Behavioral of Program_Counter is
begin
    process (Clk, Res)
    begin
        if Res = '1' then
            PC_Current <= (others => '0');
        elsif rising_edge(Clk) then
            PC_Current <= PC_Next;
        end if;
    end process;
end Behavioral;
