----------------------------------------------------------------------------------
-- Company: UOM - CSE'24 - GROUP 45
-- Engineer: Kethmika K A D Y
-- 
-- Create Date: 04/30/2026 11:17:59 AM
-- Design Name: 
-- Module Name: instruction_decoder - Behavioral
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

entity instruction_decoder is
    Port (
        instruction : in  STD_LOGIC_VECTOR(11 downto 0); -- Full 12-bit instruction
        
        -- Control outputs
        reg_write_en   : out STD_LOGIC;                  -- Enable register writing
        reg_dest_addr  : out STD_LOGIC_VECTOR(2 downto 0); -- Destination register address
        reg_src_a_addr : out STD_LOGIC_VECTOR(2 downto 0); -- Source A register address
        reg_src_b_addr : out STD_LOGIC_VECTOR(2 downto 0); -- Source B register address
        alu_op         : out STD_LOGIC;                  -- ALU operation (0=Add, 1=Sub/Neg)
        imm_val        : out STD_LOGIC_VECTOR(3 downto 0); -- Immediate value
        jump_flag      : out STD_LOGIC;                  -- Jump condition flag
        jump_addr      : out STD_LOGIC_VECTOR(2 downto 0); -- Jump target address
        use_imm        : out STD_LOGIC;                  -- Use immediate value instead of register
        pc_load        : out STD_LOGIC                   -- Load new PC value
    );
end instruction_decoder;

architecture Behavioral of instruction_decoder is
    signal opcode : STD_LOGIC_VECTOR(1 downto 0);
begin
    -- Extract opcode (bits 11-10)
    opcode <= instruction(11 downto 10);
    
    -- Decode instruction based on opcode
    process(instruction, opcode)
    begin
        -- Default values
        reg_write_en   <= '0';
        reg_dest_addr  <= "000";
        reg_src_a_addr <= "000";
        reg_src_b_addr <= "000";
        alu_op         <= '0';
        imm_val        <= "0000";
        jump_flag      <= '0';
        jump_addr      <= "000";
        use_imm        <= '0';
        pc_load        <= '0';
        
        case opcode is
            -- ADD Ra, Rb: 00 RaRaRaRbRbRb0000
            when "00" =>
                reg_write_en   <= '1';
                reg_dest_addr  <= instruction(9 downto 7);   -- Ra
                reg_src_a_addr <= instruction(9 downto 7);   -- Ra (source)
                reg_src_b_addr <= instruction(6 downto 4);   -- Rb
                alu_op         <= '0';                        -- Addition
                pc_load        <= '1';                        -- Always increment PC
                
            -- NEG R: 01 RRRR00000000
            when "01" =>
                reg_write_en   <= '1';
                reg_dest_addr  <= instruction(9 downto 7);   -- R
                reg_src_a_addr <= instruction(9 downto 7);   -- R (source)
                reg_src_b_addr <= "000";                      -- R0 (always 0)
                alu_op         <= '1';                        -- Subtraction (for negation)
                pc_load        <= '1';                        -- Always increment PC
                
            -- MOVI R, d: 10 RRR 0000 dddd
            when "10" =>
                reg_write_en   <= '1';
                reg_dest_addr  <= instruction(9 downto 7);   -- R
                use_imm        <= '1';                        -- Use immediate value
                imm_val        <= instruction(3 downto 0);   -- d (immediate)
                pc_load        <= '1';                        -- Always increment PC
                
            -- JZR R, d: 11 RRRR0000dddd
            when "11" =>
                reg_src_a_addr <= instruction(9 downto 7);   -- R (register to test)
                jump_addr      <= instruction(2 downto 0);   -- d (jump address)
                jump_flag      <= '1';                        -- Set jump flag
                pc_load        <= '1';                        -- Will be conditional
                
            when others =>
                null;
        end case;
    end process;
end Behavioral;