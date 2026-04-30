----------------------------------------------------------------------------------
-- Company: UOM - CSE'24 - GROUP 45
-- Engineer: Kethmika K A D Y
-- 
-- Create Date: 04/30/2026 11:16:10 AM
-- Design Name: 
-- Module Name: decoder_3to8 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity decoder_3to8 is
    Port (
        en   : in  STD_LOGIC;                          -- Enable signal
        addr : in  STD_LOGIC_VECTOR(2 downto 0);       -- 3-bit address
        dout : out STD_LOGIC_VECTOR(7 downto 0)        -- 8-line output
    );
end decoder_3to8;

architecture Behavioral of decoder_3to8 is
begin
    process(en, addr)
    begin
        if en = '1' then
            case addr is
                when "000" => dout <= "00000001";
                when "001" => dout <= "00000010";
                when "010" => dout <= "00000100";
                when "011" => dout <= "00001000";
                when "100" => dout <= "00010000";
                when "101" => dout <= "00100000";
                when "110" => dout <= "01000000";
                when others=> dout <= "10000000";
            end case;
        else
            dout <= "00000000";
        end if;
    end process;
end Behavioral;