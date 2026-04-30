----------------------------------------------------------------------------------
-- Company: UOM - CSE'24 - GROUP 45
-- Engineer: Kethmika K A D Y
-- 
-- Create Date: 04/30/2026 11:13:48 AM
-- Design Name: 
-- Module Name: register_bank - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
entity register_bank is
    Port (
        clk         : in  STD_LOGIC;                    -- Clock
        reset       : in  STD_LOGIC;                    -- Reset
        reg_enable  : in  STD_LOGIC_VECTOR(7 downto 0); -- Write enable for each register
        reg_write   : in  STD_LOGIC_VECTOR(3 downto 0); -- Data to write
        reg_read_sel: in  STD_LOGIC_VECTOR(2 downto 0); -- Which register to read
        reg_read_out: out STD_LOGIC_VECTOR(3 downto 0)  -- Read data output
    );
end register_bank;

architecture Behavioral of register_bank is
    type reg_array is array (0 to 7) of STD_LOGIC_VECTOR(3 downto 0);
    signal registers : reg_array := (others => "0000");
begin
    -- Write process
    process(clk, reset)
    begin
        if reset = '1' then
            registers <= (others => "0000");
        elsif rising_edge(clk) then
            for i in 0 to 7 loop
                if reg_enable(i) = '1' and i /= 0 then  -- R0 cannot be written
                    registers(i) <= reg_write;
                end if;
            end loop;
        end if;
    end process;
    
    -- Read process (combinational)
    process(reg_read_sel, registers)
    begin
        case reg_read_sel is
            when "000" => reg_read_out <= "0000";       -- R0 always reads as 0
            when "001" => reg_read_out <= registers(1);
            when "010" => reg_read_out <= registers(2);
            when "011" => reg_read_out <= registers(3);
            when "100" => reg_read_out <= registers(4);
            when "101" => reg_read_out <= registers(5);
            when "110" => reg_read_out <= registers(6);
            when others=> reg_read_out <= registers(7);
        end case;
    end process;
end Behavioral;