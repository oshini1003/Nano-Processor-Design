library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.BusDefinitions.all;

entity Add_Sub_4_bit is
    Port(
        Input_A    : in  DataBus;
        Input_B    : in  DataBus;
        Mode_Sel   : in  STD_LOGIC;
        Result     : out DataBus;
        Zero_Flag  : out STD_LOGIC;
        Overflow_Flag : out STD_LOGIC
    );
end Add_Sub_4_bit;

architecture Behavioral of Add_Sub_4_bit is
    signal Temp_Result : DataBus;
begin
    process (Input_A, Input_B, Mode_Sel)
        variable A_S, B_S, R_S : signed(3 downto 0);
    begin
        A_S := signed(Input_A);
        B_S := signed(Input_B);

        if Mode_Sel = '0' then
            R_S := A_S + B_S;
        else
            R_S := A_S - B_S;
        end if;

        Temp_Result <= std_logic_vector(R_S);
    end process;
    
    -- Process to determine if result is zero
    process (Temp_Result)
    begin
        if Temp_Result = "0000" then
            Zero_Flag <= '1';
        else
            Zero_Flag <= '0';
        end if;
    end process;

    -- True overflow detection for both addition and subtraction
    -- For addition: Overflow occurs when adding two numbers of the same sign results in a different sign
    -- For subtraction: Overflow occurs when subtracting two numbers of different signs results in a sign not matching A
    process (Input_A, Input_B, Temp_Result, Mode_Sel)
    begin
        if Mode_Sel = '0' then
            -- Addition overflow: same-sign operands, different-sign result
            Overflow_Flag <= (not (Input_A(3) xor Input_B(3))) and (Input_A(3) xor Temp_Result(3));
        else
            -- Subtraction overflow: different-sign operands, result sign differs from A
            Overflow_Flag <= (Input_A(3) xor Input_B(3)) and (Input_A(3) xor Temp_Result(3));
        end if;
    end process;
    
    -- Transfer temporary result to output
    Result <= Temp_Result;
end Behavioral;
