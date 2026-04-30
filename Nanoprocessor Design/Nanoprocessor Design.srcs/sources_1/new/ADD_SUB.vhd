library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Add_Sub_4bit_unit is
    Port ( A : in STD_LOGIC_VECTOR (3 downto 0); B : in STD_LOGIC_VECTOR (3 downto 0);
           Sel : in STD_LOGIC; SUM : out STD_LOGIC_VECTOR (3 downto 0);
           overflow : out STD_LOGIC; ZERO : out STD_LOGIC );
end Add_Sub_4bit_unit;

architecture Behavioral of Add_Sub_4bit_unit is
    signal result : STD_LOGIC_VECTOR(3 downto 0);
begin
    process(A, B, Sel)
    begin
        if Sel = '0' then result <= std_logic_vector(unsigned(A) + unsigned(B));
        else result <= std_logic_vector(unsigned(A) - unsigned(B));
        end if;
    end process;
    SUM <= result;
    ZERO <= '1' when result = "0000" else '0';
    overflow <= (A(3) xnor B(3)) and (A(3) xor result(3));
end Behavioral;