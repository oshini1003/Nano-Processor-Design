library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.BusDefinitions.ProgramCounter;

entity Address_Selector is
    port (
        Sequential_Address : in  ProgramCounter; -- PC+1 address for sequential execution
        Jump_Address       : in  ProgramCounter; -- Target address when jump occurs
        Jump_Enable        : in  std_logic;      -- Jump control signal (1=Jump, 0=Continue)
        Selected_Address   : out ProgramCounter  -- Address selected for next execution
    );
end entity Address_Selector;

architecture Behavioral of Address_Selector is
begin
    Selected_Address <= Sequential_Address when Jump_Enable = '0' else Jump_Address;
end architecture Behavioral;
