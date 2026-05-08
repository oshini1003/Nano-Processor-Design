----------------------------------------------------------------------------------
-- 8-to-1 MUX (4-bit wide)
-- University of Moratuwa | Team: 240348, 240351, 240347, 240343
-- Used to select one of the 8 register outputs for the ALU
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity mux_8way_4bit is
    Port (
        in0  : in  STD_LOGIC_VECTOR(3 downto 0);
        in1  : in  STD_LOGIC_VECTOR(3 downto 0);
        in2  : in  STD_LOGIC_VECTOR(3 downto 0);
        in3  : in  STD_LOGIC_VECTOR(3 downto 0);
        in4  : in  STD_LOGIC_VECTOR(3 downto 0);
        in5  : in  STD_LOGIC_VECTOR(3 downto 0);
        in6  : in  STD_LOGIC_VECTOR(3 downto 0);
        in7  : in  STD_LOGIC_VECTOR(3 downto 0);
        sel  : in  STD_LOGIC_VECTOR(2 downto 0);
        y    : out STD_LOGIC_VECTOR(3 downto 0)
    );
end mux_8way_4bit;

architecture Behavioral of mux_8way_4bit is
begin
    process(sel, in0, in1, in2, in3, in4, in5, in6, in7)
    begin
        case sel is
            when "000"  => y <= in0;
            when "001"  => y <= in1;
            when "010"  => y <= in2;
            when "011"  => y <= in3;
            when "100"  => y <= in4;
            when "101"  => y <= in5;
            when "110"  => y <= in6;
            when "111"  => y <= in7;
            when others => y <= "0000";
        end case;
    end process;
end Behavioral;
