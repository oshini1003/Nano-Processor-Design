library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.BusDefinitions.all;

entity Load_Selector is
    Port (
        RegisterValue  : in  DataBus;           -- Input from register (for ADD/NEG)
        ImmediateValue : in  DataBus;           -- Immediate value (for MOVI)
        LoadSelect     : in  STD_LOGIC;         -- Selection control from instruction decoder
        OutputData     : out DataBus            -- Selected output to ALU
    );
end Load_Selector;

architecture Behavioral of Load_Selector is
begin
    OutputData <= ImmediateValue when LoadSelect = '0' else RegisterValue;
end Behavioral;
