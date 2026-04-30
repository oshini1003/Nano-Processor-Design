library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity w2_4_MUX is
    Port ( Load_Select : in STD_LOGIC; Immediate : in STD_LOGIC_VECTOR (3 downto 0);
           S : in STD_LOGIC_VECTOR (3 downto 0); Value_In : out STD_LOGIC_VECTOR (3 downto 0));
end w2_4_MUX;

architecture Behavioral of w2_4_MUX is
begin
    process(Load_Select, Immediate, S)
    begin
        if (Load_Select = '0') then Value_In <= S;
        else Value_In <= Immediate;
        end if;
    end process;
end Behavioral;