library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_Slow_Clk is  
end TB_Slow_Clk;       

architecture Behavioral of TB_Slow_Clk is

    component Slow_clock is
        Port ( 
            Clk_in  : in  STD_LOGIC;
            Clk_out : out STD_LOGIC
        );
    end component;

    signal Clk_in  : STD_LOGIC := '0';
    signal Clk_out : STD_LOGIC;
    constant Clk_period : time := 10 ns;

begin

    uut: Slow_clock 
        port map (
            Clk_in  => Clk_in,
            Clk_out => Clk_out
        );

    clk_gen : process
    begin
        Clk_in <= '0';
        wait for Clk_period / 2;
        Clk_in <= '1';
        wait for Clk_period / 2;
    end process;

    stim_proc : process
    begin
        wait for 1.2 sec;
        wait;
    end process;

end Behavioral;