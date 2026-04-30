library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Register_4_bit is
    Port ( D : in STD_LOGIC_VECTOR (3 downto 0); Res : in STD_LOGIC; EN : in STD_LOGIC; Clk : in STD_LOGIC; Q : out STD_LOGIC_VECTOR (3 downto 0));
end Register_4_bit;

architecture Behavioral of Register_4_bit is
begin
    process(Clk, Res)
    begin
        if Res = '1' then Q <= "0000";
        elsif rising_edge(Clk) then if EN = '1' then Q <= D; end if;
        end if;
    end process;
end Behavioral;