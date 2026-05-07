----------------------------------------------------------------------------------
-- Company: UOM - CSE'24 - GROUP 45
-- Engineer: Kethmika K A D Y
-- 
-- Create Date: 05/07/2026 02:36:28 PM
-- Design Name: 
-- Module Name: program_rom - Behavioral
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

entity program_rom is
    port (
        address : in  std_logic_vector(2 downto 0);
        data    : out std_logic_vector(11 downto 0)
    );
end program_rom;

architecture rtl of program_rom is
    type rom_array_t is array (0 to 7) of std_logic_vector(11 downto 0);

    -- PROGRAM: Demonstrate all instructions with countdown loop

    -- Address 0: MOVI R1, 10   ; Initialize R1 = 10 (decimal)
    -- Address 1: MOVI R2, 1    ; Initialize R2 = 1
    -- Address 2: NEG R2        ; Negate R2 -> R2 = -1 (1111 binary)
    -- Address 3: ADD R1, R2    ; R1 = R1 + R2 (decrement by 1)
    -- Address 4: JZR R1, 7     ; If R1==0, jump to address 7 (end)
    -- Address 5: JZR R0, 3     ; If R0==0 (always true!), loop back to 3
    -- Address 6: (unused/reachable only via error)
    -- Address 7: NOP/HALT      ; End of program

    
    constant ROM_CONTENTS : rom_array_t := (
        0  => "100010000010",  -- MOVI R1, 10  (opcode=10, RA=001, imm=1010)
        1  => "100100000001",  -- MOVI R2, 1   (opcode=10, RA=010, imm=0001)
        2  => "010010000000",  -- NEG R2       (opcode=01, RA=010)
        3  => "000010010000",  -- ADD R1,R2    (opcode=00, RA=001, RB=010)
        4  => "110010000111",  -- JZR R1,7     (opcode=11, RA=001, addr=111)
        5  => "110000000011",  -- JZR R0,3     (opcode=11, RA=000, addr=011)
        6  => "000000000000",  -- NOP (padding)
        7  => "000000000000"   -- NOP / HALT point
    );

begin
    process(address)
    begin
        case address is
            when "000" => data <= ROM_CONTENTS(0);
            when "001" => data <= ROM_CONTENTS(1);
            when "010" => data <= ROM_CONTENTS(2);
            when "011" => data <= ROM_CONTENTS(3);
            when "100" => data <= ROM_CONTENTS(4);
            when "101" => data <= ROM_CONTENTS(5);
            when "110" => data <= ROM_CONTENTS(6);
            when "111" => data <= ROM_CONTENTS(7);
            when others => data <= "000000000000";
        end case;
    end process;

end rtl;