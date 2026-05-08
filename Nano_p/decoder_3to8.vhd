----------------------------------------------------------------------------------
-- 3-to-8 Line Decoder
-- University of Moratuwa | Team: 240348, 240351, 240347, 240343
-- Used to generate register write-enable signals from a 3-bit register select
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decoder_3to8 is
    Port (
        en  : in  STD_LOGIC;                      -- Global enable
        sel : in  STD_LOGIC_VECTOR(2 downto 0);   -- Register select
        y   : out STD_LOGIC_VECTOR(7 downto 0)    -- One-hot output
    );
end decoder_3to8;

architecture Behavioral of decoder_3to8 is
begin
    process(en, sel)
    begin
        if en = '0' then
            y <= "00000000";
        else
            case sel is
                when "000"  => y <= "00000001";
                when "001"  => y <= "00000010";
                when "010"  => y <= "00000100";
                when "011"  => y <= "00001000";
                when "100"  => y <= "00010000";
                when "101"  => y <= "00100000";
                when "110"  => y <= "01000000";
                when "111"  => y <= "10000000";
                when others => y <= "00000000";
            end case;
        end if;
    end process;
end Behavioral;
