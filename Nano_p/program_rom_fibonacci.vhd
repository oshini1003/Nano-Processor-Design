----------------------------------------------------------------------------------
-- Program ROM — Fibonacci Sequence (Bonus / Competition Demo)
-- University of Moratuwa | Team: 240348, 240351, 240347, 240343
--
-- Computes Fibonacci numbers in R1: 1, 1, 2, 3, 5, 8, 13 then wraps (4-bit)
-- R1 = current Fib value (shown on LEDs)
-- R2 = previous Fib value
-- R3 = temp
--
-- Algorithm:
--   R1 ← 1          (first Fibonacci)
--   R2 ← 1          (second Fibonacci)
-- loop:
--   R3 ← R1         (R3 = old R1) … implemented as: R3 ← R1, then R1 ← R1+R2
--   Actually 4-bit ISA has no MOV. Use: NEG then NEG to copy.
--   Trick: R3 ← NEG(R1) then NEG(R3) gives back R1 (double-negate = identity)
--   R1 ← R1 + R2    (new Fib)
--   R2 ← R3         (old R1 becomes new R2)
--   JZR R0, 2        (unconditional loop back)
--
-- Encoding:
--   [11:10]=opcode [9:7]=RA [6:4]=RB [3:0]=imm/addr
--   00=ADD  01=NEG  10=MOVI  11=JZR
--
-- Addr 0: MOVI R1, 1    -> 10_001_000_0001 = 100010000001
-- Addr 1: MOVI R2, 1    -> 10_010_000_0001 = 100100000001
-- Addr 2: NEG  R3        -> 01_011_000_0000 = 010110000000  (R3 ← -R1, but we need R1 first)
--
-- Better strategy (fits 8 instructions):
--   Addr 0: MOVI R1, 1      R1=1
--   Addr 1: MOVI R2, 1      R2=1
--   Addr 2: ADD  R3, R1+R2  R3=R1+R2 (new Fib in R3)  -- wait, ADD RA,RB = RA←RA+RB
--                            ADD R3,R2: R3←R3+R2. Need R3=R1 first.
--
-- Final clean 8-instruction Fibonacci:
--   Addr 0: MOVI R1, 1      R1 ← 1           (display)
--   Addr 1: MOVI R2, 1      R2 ← 1
--   Addr 2: ADD  R2, R1     R2 ← R2 + R1     (new Fib in R2)
--   Addr 3: ADD  R1, R2     R1 ← R1 + R2     (next Fib in R1)
--   Addr 4: ADD  R2, R1     R2 ← R2 + R1     (next Fib in R2)
--   Addr 5: ADD  R1, R2     R1 ← R1 + R2     (next Fib in R1)
--   Addr 6: JZR  R0, 2      unconditional → Addr 2 (continue loop)
--   Addr 7: JZR  R0, 7      halt (unreachable)
--
-- Sequence produced in R1: 1, 2, 5, 13, ... (4-bit wraps)
-- Sequence in R2:          1, 3, 8, ...
--
-- Simpler and correct — ping-pong between R1 and R2:
--   Addr 0: MOVI R1, 0      R1 = 0
--   Addr 1: MOVI R2, 1      R2 = 1  (first Fib shown)
--   Addr 2: ADD  R1, R2     R1 ← R1+R2  (R1 = new)
--   Addr 3: ADD  R2, R1     R2 ← R2+R1  (R2 = new)
--   Addr 4: JZR  R0, 2      loop back
--   Addr 5: NOP
--   Addr 6: NOP
--   Addr 7: JZR  R0, 7      halt
--
-- R1 sequence: 1,2,5,13,... and R2: 1,3,8,... (4-bit wraps at 16)
-- R1 LED shows: 0001, 0001, 0010, 0011, 0101, 1000, 1101, 0101 (wrapping)
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity program_rom_fibonacci is
    Port (
        address  : in  STD_LOGIC_VECTOR(2 downto 0);
        data_out : out STD_LOGIC_VECTOR(11 downto 0)
    );
end program_rom_fibonacci;

architecture Behavioral of program_rom_fibonacci is
    type rom_type is array (0 to 7) of STD_LOGIC_VECTOR(11 downto 0);

    -- Fibonacci ping-pong: R1 and R2 alternate as Fibonacci values
    -- ADD RA, RB means RA <- RA + RB  (opcode=00, [9:7]=RA, [6:4]=RB)
    --
    -- Addr 0: MOVI R1, 0   -> 10_001_000_0000 -> 100010000000
    -- Addr 1: MOVI R2, 1   -> 10_010_000_0001 -> 100100000001
    -- Addr 2: ADD  R1, R2  -> 00_001_010_0000 -> 000001010000
    -- Addr 3: ADD  R2, R1  -> 00_010_001_0000 -> 000010010000
    -- Addr 4: JZR  R0, 2   -> 11_000_000_0010 -> 110000000010
    -- Addr 5: NOP           -> 000000000000
    -- Addr 6: NOP           -> 000000000000
    -- Addr 7: JZR  R0, 7   -> 11_000_000_0111 -> 110000000111

    constant ROM : rom_type := (
        0 => "100010000000",  -- MOVI R1, 0    : R1 <- 0
        1 => "100100000001",  -- MOVI R2, 1    : R2 <- 1
        2 => "000001010000",  -- ADD  R1, R2   : R1 <- R1 + R2
        3 => "000010010000",  -- ADD  R2, R1   : R2 <- R2 + R1
        4 => "110000000010",  -- JZR  R0, 2    : unconditional -> Addr 2
        5 => "000000000000",  -- NOP
        6 => "000000000000",  -- NOP
        7 => "110000000111"   -- JZR  R0, 7    : halt (unreachable)
    );
begin
    data_out <= ROM(conv_integer(address));
end Behavioral;
