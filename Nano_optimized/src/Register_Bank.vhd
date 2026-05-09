library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.BusDefinitions.all;

entity Register_Bank is
    Port (
        Data             : in  DataBus;          -- Data input to write to registers
        Reset            : in  STD_LOGIC;        -- Asynchronous reset signal
        Reg_En           : in  RegisterSelect;   -- Register selection address
        Clock            : in  STD_LOGIC;        -- System clock signal
        Register_Outputs : out RegisterFile      -- Array of all register contents
    );
end Register_Bank;

architecture Behavioral of Register_Bank is
    type GPRegisterFile is array (7 downto 1) of DataBus;
    signal Registers_1_to_7 : GPRegisterFile := (others => (others => '0'));
begin
    process (Clock, Reset)
    begin
        if Reset = '1' then
            Registers_1_to_7 <= (others => (others => '0'));
        elsif rising_edge(Clock) then
            case Reg_En is
                when "001" => Registers_1_to_7(1) <= Data;
                when "010" => Registers_1_to_7(2) <= Data;
                when "011" => Registers_1_to_7(3) <= Data;
                when "100" => Registers_1_to_7(4) <= Data;
                when "101" => Registers_1_to_7(5) <= Data;
                when "110" => Registers_1_to_7(6) <= Data;
                when "111" => Registers_1_to_7(7) <= Data;
                when others => null; -- "000" keeps R0 hardwired to zero / no write
            end case;
        end if;
    end process;

    Register_Outputs(0) <= (others => '0');
    Register_Outputs(1) <= Registers_1_to_7(1);
    Register_Outputs(2) <= Registers_1_to_7(2);
    Register_Outputs(3) <= Registers_1_to_7(3);
    Register_Outputs(4) <= Registers_1_to_7(4);
    Register_Outputs(5) <= Registers_1_to_7(5);
    Register_Outputs(6) <= Registers_1_to_7(6);
    Register_Outputs(7) <= Registers_1_to_7(7);
end Behavioral;
