library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Slow_clock is
    Port ( Clk_in  : in  STD_LOGIC;
           Clk_out : out STD_LOGIC);
end Slow_clock;

architecture Behavioral of Slow_clock is
    signal counter : integer := 0;
    signal temp_clk : STD_LOGIC := '0';
begin
    process(Clk_in)
    begin
        if rising_edge(Clk_in) then
            -- Divides 100MHz clock to roughly 1Hz (adjust if needed)
            if counter = 50000000 then
                counter <= 0;
                temp_clk <= NOT temp_clk;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;
    Clk_out <= temp_clk;
end Behavioral;