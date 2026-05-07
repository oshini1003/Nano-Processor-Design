----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/07/2026 02:49:40 PM
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity register_bank is
    port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        write_en    : in  std_logic;                      -- Global write enable
        reg_select  : in  std_logic_vector(2 downto 0);  -- Which register to write
        data_in     : in  std_logic_vector(3 downto 0);  -- Data to write
        r0_out      : out std_logic_vector(3 downto 0);  -- R0 output (always 0000)
        r1_out      : out std_logic_vector(3 downto 0);  -- R1 output
        r2_out      : out std_logic_vector(3 downto 0);  -- R2 output
        r3_out      : out std_logic_vector(3 downto 0);  -- R3 output
        r4_out      : out std_logic_vector(3 downto 0);  -- R4 output
        r5_out      : out std_logic_vector(3 downto 0);  -- R5 output
        r6_out      : out std_logic_vector(3 downto 0);  -- R6 output
        r7_out      : out std_logic_vector(3 downto 0)   -- R7 output
    );
end register_bank;

architecture rtl of register_bank is
    type reg_array_t is array (0 to 7) of std_logic_vector(3 downto 0);
    signal registers : reg_array_t := (others => "0000");
begin
    
    -- R0 is always zero (hardwired, not stored in array)
    r0_out <= "0000";
    
    -- Read outputs from register array
    r1_out <= registers(1);
    r2_out <= registers(2);
    r3_out <= registers(3);
    r4_out <= registers(4);
    r5_out <= registers(5);
    r6_out <= registers(6);
    r7_out <= registers(7);
    
    -- Write process (synchronous)
    process(clk, reset)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                registers <= (others => "0000");
            elsif write_en = '1' then
                case reg_select is
                    when "001"   => registers(1) <= data_in;
                    when "010"   => registers(2) <= data_in;
                    when "011"   => registers(3) <= data_in;
                    when "100"   => registers(4) <= data_in;
                    when "101"   => registers(5) <= data_in;
                    when "110"   => registers(6) <= data_in;
                    when "111"   => registers(7) <= data_in;
                    when others => null;  -- R0 cannot be written (read-only)
                end case;
            end if;
        end if;
    end process;

end rtl;