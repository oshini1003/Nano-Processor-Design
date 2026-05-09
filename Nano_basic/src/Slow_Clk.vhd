library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Slow_Clk is
    Port ( Clk_in  : in  STD_LOGIC;
           Clk_out : out STD_LOGIC);
end Slow_Clk;

architecture Behavioral of Slow_Clk is

    signal count      : integer   := 0;
    signal clk_status : std_logic := '0';

begin
    -- Drive output continuously from clk_status (avoids latch inference)
    Clk_out <= clk_status;

    process (Clk_in)
    begin
        if rising_edge(Clk_in) then
            if count = 49999999 then
                clk_status <= not clk_status;  -- Toggle every 0.5s at 100MHz
                count      <= 0;
            else
                count <= count + 1;
            end if;
        end if;
    end process;

end Behavioral;
