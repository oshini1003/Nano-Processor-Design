----------------------------------------------------------------------------------
-- Program Counter (3-bit)
-- University of Moratuwa | Team: 240348, 240351, 240347, 240343
-- Nanoprocessor Project
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity program_counter is
    Port (
        clk      : in  STD_LOGIC;
        reset    : in  STD_LOGIC;                    -- Async reset to 0
        enable   : in  STD_LOGIC;                    -- Increment enable
        load     : in  STD_LOGIC;                    -- Load jump address
        pc_in    : in  STD_LOGIC_VECTOR(2 downto 0); -- Jump address
        pc_out   : out STD_LOGIC_VECTOR(2 downto 0)  -- Current PC
    );
end program_counter;

architecture Behavioral of program_counter is
    signal pc_reg : STD_LOGIC_VECTOR(2 downto 0) := "000";
begin
    process(clk, reset)
    begin
        if reset = '1' then
            pc_reg <= "000";
        elsif rising_edge(clk) then
            if load = '1' then
                pc_reg <= pc_in;
            elsif enable = '1' then
                pc_reg <= pc_reg + 1;
            end if;
        end if;
    end process;

    pc_out <= pc_reg;
end Behavioral;
