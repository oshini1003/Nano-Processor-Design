----------------------------------------------------------------------------------
-- Company  : UOM - CSE'24 - GROUP 45
-- Module   : alu_4bit  (NEW)
-- Description: Full 4-bit ALU supporting:
--   000 = ADD Ra,Rb      (Ra + Rb)
--   001 = SUB Ra,Rb      (Ra - Rb, two's complement)
--   010 = AND Ra,Rb
--   011 = OR  Ra,Rb
--   100 = XOR Ra,Rb
--   101 = SHIFT Ra        (shift_r='0' → SHL, shift_r='1' → SHR)
--   110,111 = pass A      (MOVI/JZR bypasses ALU in top level)
--
-- Flags: Zero (result=0), Carry (ADD/SUB only), Ovf (signed overflow ADD/SUB)
-- Gate-efficient: single adder shared by ADD and SUB.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu_4bit is
    port (
        A       : in  std_logic_vector(3 downto 0);  -- Operand A (from RA reg)
        B       : in  std_logic_vector(3 downto 0);  -- Operand B (from RB reg)
        op      : in  std_logic_vector(2 downto 0);  -- ALU opcode (= instr opcode)
        shift_r : in  std_logic;                      -- '0'=SHL, '1'=SHR
        Result  : out std_logic_vector(3 downto 0);
        Zero    : out std_logic;
        Carry   : out std_logic;
        Ovf     : out std_logic
    );
end alu_4bit;

architecture rtl of alu_4bit is
    signal do_sub  : std_logic;
    signal b_mux   : std_logic_vector(3 downto 0);
    signal sum_ext : unsigned(4 downto 0);
    signal res_int : std_logic_vector(3 downto 0);
begin

    -- Subtraction control
    do_sub <= '1' when op = "001" else '0';

    -- B complement for SUB; pass-through for ADD
    b_mux <= not B when do_sub = '1' else B;

    -- Shared 5-bit adder (ADD and SUB)
    sum_ext <= unsigned('0' & A) + unsigned('0' & b_mux) + ("0000" & do_sub);

    -- Result multiplexer
    process(op, A, B, sum_ext, shift_r)
    begin
        case op is
            when "000" =>                              -- ADD
                res_int <= std_logic_vector(sum_ext(3 downto 0));
            when "001" =>                              -- SUB
                res_int <= std_logic_vector(sum_ext(3 downto 0));
            when "010" =>                              -- AND
                res_int <= A and B;
            when "011" =>                              -- OR
                res_int <= A or B;
            when "100" =>                              -- XOR
                res_int <= A xor B;
            when "101" =>                              -- SHIFT
                if shift_r = '0' then
                    res_int <= A(2 downto 0) & '0';   -- SHL: fill 0 at LSB
                else
                    res_int <= '0' & A(3 downto 1);   -- SHR: fill 0 at MSB
                end if;
            when others =>
                res_int <= A;                          -- Pass-through (MOVI/JZR bypass)
        end case;
    end process;

    Result <= res_int;
    Zero   <= '1' when res_int = "0000" else '0';

    -- Carry: meaningful only for ADD/SUB
    process(op, sum_ext)
    begin
        if op = "000" or op = "001" then
            Carry <= sum_ext(4);
        else
            Carry <= '0';
        end if;
    end process;

    -- Signed overflow: meaningful only for ADD/SUB
    process(op, A, b_mux, sum_ext)
    begin
        if op = "000" or op = "001" then
            if (A(3) = '0' and b_mux(3) = '0' and sum_ext(3) = '1') or
               (A(3) = '1' and b_mux(3) = '1' and sum_ext(3) = '0') then
                Ovf <= '1';
            else
                Ovf <= '0';
            end if;
        else
            Ovf <= '0';
        end if;
    end process;

end rtl;
