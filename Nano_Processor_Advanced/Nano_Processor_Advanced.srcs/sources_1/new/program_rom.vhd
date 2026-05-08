----------------------------------------------------------------------------------
-- Company  : UOM - CSE'24 - GROUP 45
-- Module   : program_rom
-- Description: 8-word × 12-bit ROM demonstrating all 8 ISA instructions.
--
-- New ISA (3-bit opcode):
--   [11:9] = opcode  [8:6] = RA  [5:3] = RB  [2:0] = addr/imm-upper
--   MOVI uses [3:0] as 4-bit immediate.
--
-- Opcode table:
--   000=ADD  001=SUB  010=AND  011=OR  100=XOR
--   101=SHIFT(RB[0]:0=SHL,1=SHR)  110=MOVI  111=JZR
--
-- Demo program:
--   0: MOVI R1, 5    ; R1 = 5        (0101)
--   1: MOVI R2, 3    ; R2 = 3        (0011)
--   2: ADD  R3,R1,R2 ; R3 = 8 (5+3)
--   3: SUB  R4,R1,R2 ; R4 = 2 (5-3)
--   4: AND  R5,R1,R2 ; R5 = 1 (5 AND 3 = 0101 AND 0011)
--   5: OR   R6,R1,R2 ; R6 = 7 (5 OR  3 = 0101 OR  0011)
--   6: SHL  R1       ; R1 = 10 (5<<1)
--   7: JZR  R0, 0    ; R0 always 0 → loop to address 0
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

    -- Encoding key:
    --   MOVI Ra, imm4 : 110_RA_000_imm4(lower3) with full imm4 in [3:0]
    --     [11:9]=110  [8:6]=RA  [5:4]=00  [3:0]=imm4
    --   ADD  Ra,Rb    : 000_RA_RB_000
    --   SUB  Ra,Rb    : 001_RA_RB_000
    --   AND  Ra,Rb    : 010_RA_RB_000
    --   OR   Ra,Rb    : 011_RA_RB_000
    --   XOR  Ra,Rb    : 100_RA_RB_000
    --   SHL  Ra       : 101_RA_000_000   (RB=000 → SHL)
    --   SHR  Ra       : 101_RA_001_000   (RB=001 → SHR)
    --   JZR  Ra,addr  : 111_RA_000_addr3

    --  Addr | Binary          | Hex   | Instruction
    --  -----+-----------------+-------+-------------------
    --    0  | 110_001_00_0101 | C85   | MOVI R1, 5
    --    1  | 110_010_00_0011 | CA3   | MOVI R2, 3  -- wait let me recalculate
    --
    -- Let me be very precise:
    -- MOVI R1, 5 : op=110, RA=001, [5:4]=00, imm4=0101
    --   bit11=1 bit10=1 bit9=0  bit8=0 bit7=0 bit6=1  bit5=0 bit4=0  bit3=0 bit2=1 bit1=0 bit0=1
    --   = "110_001_00_0101" = "110001000101" = x"C45"
    -- MOVI R2, 3 : op=110, RA=010, imm4=0011
    --   = "110_010_00_0011" = "110010000011" = x"C83"
    -- ADD R3,R1,R2 : op=000, RA=011, RB=001, lower=000... wait RA should be dest
    --   ADD R3,R1,R2 means R3=R1+R2, RA=R3 (dest), but MUX A reads RA (R3??)
    --
    -- IMPORTANT NOTE on the datapath:
    -- MUX_A selects from reg_a_field → the DESTINATION register.
    -- MUX_B selects from reg_b_field → the SOURCE B register.
    -- For ADD R3,R1,R2: we need A=R1, B=R2, dest=R3.
    -- But MUX_A reads reg_a_field = R3 (destination), NOT R1.
    -- This means ADD reads the destination register as operand A!
    -- This is the original design's ISA: ADD Ra,Rb → Ra = Ra + Rb
    -- (accumulate into Ra, Ra is both source A and destination)
    --
    -- So the ISA is: ADD Ra,Rb → Ra ← Ra + Rb  (Ra is source AND dest)
    -- This matches original design. Demo adjusted accordingly:

    --   0: MOVI R1, 5    ; R1 = 5
    --   1: MOVI R2, 3    ; R2 = 3
    --   2: ADD  R1, R2   ; R1 = R1+R2 = 8 (LEDs show 8)
    --   3: MOVI R1, 5    ; R1 = 5 (restore)
    --   4: SUB  R1, R2   ; R1 = R1-R2 = 2
    --   5: AND  R2, R1   ; R2 = R2 AND R1 = 3 AND 2 = 2
    --   6: SHL  R1       ; R1 = 2<<1 = 4
    --   7: JZR  R0, 0    ; always loop (R0=0)

    constant ROM_CONTENTS : rom_array_t := (
        -- 0: MOVI R1, 5  → 110_001_00_0101
        0 => "110001000101",

        -- 1: MOVI R2, 3  → 110_010_00_0011
        1 => "110010000011",

        -- 2: ADD R1, R2  → 000_001_010_000  (R1=R1+R2)
        2 => "000001010000",

        -- 3: MOVI R1, 5  → 110_001_00_0101 (restore R1=5)
        3 => "110001000101",

        -- 4: SUB R1, R2  → 001_001_010_000  (R1=R1-R2=5-3=2)
        4 => "001001010000",

        -- 5: AND R2, R1  → 010_010_001_000  (R2=R2 AND R1=3 AND 2=2)
        5 => "010010001000",

        -- 6: SHL R1      → 101_001_000_000  (R1=2<<1=4)
        6 => "101001000000",

        -- 7: JZR R0, 0   → 111_000_000_000  (R0=0 always → jump to 0)
        7 => "111000000000"
    );

begin
    process(address)
    begin
        case address is
            when "000"  => data <= ROM_CONTENTS(0);
            when "001"  => data <= ROM_CONTENTS(1);
            when "010"  => data <= ROM_CONTENTS(2);
            when "011"  => data <= ROM_CONTENTS(3);
            when "100"  => data <= ROM_CONTENTS(4);
            when "101"  => data <= ROM_CONTENTS(5);
            when "110"  => data <= ROM_CONTENTS(6);
            when "111"  => data <= ROM_CONTENTS(7);
            when others => data <= "000000000000";
        end case;
    end process;

end rtl;