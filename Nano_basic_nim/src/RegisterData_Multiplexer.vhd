library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.BusDefinitions.all;

entity RegisterData_Multiplexer is
    Port ( 
        DataSources   : in  RegisterFile;
        SelectAddress : in  RegisterSelect;
        OutputData    : out DataBus
    );
end RegisterData_Multiplexer;

architecture Behavioral of RegisterData_Multiplexer is
begin
    -- Direct indexed selection: synthesizes to an efficient mux (typically LUT-based)
    OutputData <= DataSources(to_integer(unsigned(SelectAddress)));
end Behavioral;
