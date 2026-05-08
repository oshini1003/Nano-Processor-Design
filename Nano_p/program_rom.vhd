----------------------------------------------------------------------------------
-- Program ROM (8 x 12-bit)
-- University of Moratuwa | Team: 240348, 240351, 240347, 240343
-- Program: Countdown R1 from 10 to 0, then halt
--
-- Instruction Encoding:
--   [11:10] = opcode  [9:7] = RA  [6:4] = RB  [3:0] = imm/addr
--   Opcodes: 00=ADD  01=NEG  10=MOVI  11=JZR
--
-- Addr 0: MOVI R1, 10  -> 10 001 000 1010 -> 100010001010
-- Addr 1: MOVI R2,  1  -> 10 010 000 0001 -> 100100000001
-- Addr 2: NEG  R2      -> 01 010 000 0000 -> 010100000000
-- Addr 3: ADD  R1, R2  -> 00 001 010 0000 -> 000001010000  <-- corrected RB
-- Addr 4: JZR  R1, 7   -> 11 001 000 0111 -> 110010000111
-- Addr 5: JZR  R0, 3   -> 11 000 000 0011 -> 110000000011
-- Addr 6: NOP (ADD R0,R0) -> 00 000 000 0000 -> 000000000000
-- Addr 7: JZR  R0, 7   -> 11 000 000 0111 -> 110000000111  (halt)
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity program_rom is
    Port (
        address  : in  STD_LOGIC_VECTOR(2 downto 0);
        data_out : out STD_LOGIC_VECTOR(11 downto 0)
    );
end program_rom;

architecture Behavioral of program_rom is
    type rom_type is array (0 to 7) of STD_LOGIC_VECTOR(11 downto 0);
    constant ROM : rom_type := (
        0 => "100010001010",  -- MOVI R1, 10   : R1 <- 10
        1 => "100100000001",  -- MOVI R2,  1   : R2 <- 1
        2 => "010100000000",  -- NEG  R2        : R2 <- -1 (0xF = 1111)
        3 => "000001010000",  -- ADD  R1, R2    : R1 <- R1 + R2 (R1--)
        4 => "110010000111",  -- JZR  R1, 7    : if R1=0 goto 7
        5 => "110000000011",  -- JZR  R0, 3    : unconditional goto 3
        6 => "000000000000",  -- NOP
        7 => "110000000111"   -- JZR  R0, 7    : halt (loop forever)
    );
begin
    data_out <= ROM(conv_integer(address));
end Behavioral;
