library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Program_ROM is
Port ( Memory_Select : in STD_LOGIC_VECTOR (2 downto 0);
Instruction : out STD_LOGIC_VECTOR (12 downto 0));
end Program_ROM;
architecture Behavioral of Program_ROM is
type rom_type is array (0 to 7) of std_logic_vector(12 downto 0);
    signal P_ROM : rom_type := (
    -- "0101110000011", -- MOVI R7, 3
    -- "0100010000001", -- MOVI R1, 1
    -- "0010010000000", -- NEG R1
    -- "0100100000011", -- MOVI R2, 3
    -- "0000100010000", -- ADD R2, R1
    -- "0001110100000", -- ADD R7, R2
    -- "0110100000110", -- JZR R2, 6
    -- "0110000000100" -- JZR R0, 4
    "0101110000011", -- 0 MOVI R7, 3
    "0100010000001", -- 1 MOVI R1, 1
    "1111110010000", -- 2 bit xor R1 R7
    "0110000000011", -- 3 JZR R2, 6
    "0000100010000", -- 4 ADD R2, R1
    "0001110100000", -- 5 ADD R7, R2
    "0110100000110", -- 6 JZR R2, 6
    "0110000000100" -- 7 JZR R0, 4
    );
begin
    process(Memory_Select)
    begin
    if to_integer(unsigned(Memory_Select)) < P_ROM'length then
        Instruction <= P_ROM(to_integer(unsigned(Memory_Select)));
    else
        Instruction <= (others => '0');
    end if;
    end process;
    Instruction <= (others => ' ' ) ; 
    Instruction <= P_ROM(to_integr)
    
end Behavioral ;