----------------------------------------------------------------------------------
-- Company: UOM - CSE'24 - GROUP 45
-- Module Name: program_rom - Behavioral
--
-- PROGRAM: Sequential demo - shows ADD then subtraction, then HALTS.
--
--   Addr 0: MOVI R1, 5    -> R1 = 5
--   Addr 1: MOVI R2, 3    -> R2 = 3
--   Addr 2: ADD  R1, R2   -> R1 = 5 + 3 = 8   (ADDITION)
--   Addr 3: MOVI R3, 8    -> R3 = 8            (save result)
--   Addr 4: NEG  R2       -> R2 = -3 = F       (NEGATION)
--   Addr 5: ADD  R3, R2   -> R3 = 8 + (-3) = 5 (SUBTRACTION)
--   Addr 6: JZR  R0, 6    -> HALT forever
--   Addr 7: NOP
--
-- Display at HALT (left to right): [ PC=6 | R3=5 | R1=8 | R2=F ]
-- Instruction format: opcode[11:10] | RA[9:7] | RB[6:4] | imm[3:0]
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity program_rom is
    port (
        address : in  std_logic_vector(2 downto 0);
        data    : out std_logic_vector(11 downto 0)
    );
end program_rom;

architecture rtl of program_rom is
    type rom_array_t is array (0 to 7) of std_logic_vector(11 downto 0);

    constant ROM_CONTENTS : rom_array_t := (
        -- op    RA    RB    imm4
        0 => "10" & "001" & "000" & "0101",  -- MOVI R1, 5
        1 => "10" & "010" & "000" & "0011",  -- MOVI R2, 3
        2 => "00" & "001" & "010" & "0000",  -- ADD  R1, R2  -> 5+3=8
        3 => "10" & "011" & "000" & "1000",  -- MOVI R3, 8
        4 => "01" & "010" & "000" & "0000",  -- NEG  R2      -> R2=-3=F
        5 => "00" & "011" & "010" & "0000",  -- ADD  R3, R2  -> 8+(-3)=5
        6 => "11" & "000" & "000" & "0110",  -- JZR  R0, 6   -> HALT
        7 => "00" & "000" & "000" & "0000"   -- NOP
    );

begin
    process(address)
    begin
        case address is
            when "000" => data <= ROM_CONTENTS(0);
            when "001" => data <= ROM_CONTENTS(1);
            when "010" => data <= ROM_CONTENTS(2);
            when "011" => data <= ROM_CONTENTS(3);
            when "100" => data <= ROM_CONTENTS(4);
            when "101" => data <= ROM_CONTENTS(5);
            when "110" => data <= ROM_CONTENTS(6);
            when "111" => data <= ROM_CONTENTS(7);
            when others => data <= "000000000000";
        end case;
    end process;

end rtl;