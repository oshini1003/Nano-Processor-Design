library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Slow_Clk is
    Port ( Clk_in  : in  STD_LOGIC;
           Clk_out : out STD_LOGIC);
end Slow_Clk;

architecture Behavioral of Slow_Clk is

    signal count      : integer   := 1;
    signal Clk_status : STD_LOGIC := '0';

begin
    -- FIX: assign Clk_out CONCURRENTLY outside the process
    -- so it always reflects the CURRENT value of Clk_status
    Clk_out <= Clk_status;

    process (Clk_in) begin
        if rising_edge(Clk_in) then
            if count = 5 then
                Clk_status <= NOT Clk_status;  -- toggle
                count <= 1;                     -- reset counter
            else
                count <= count + 1;
            end if;
        end if;
    end process;

end Behavioral;