----------------------------------------------------------------------------------
-- Company: UOM
-- Engineer: Kethmika K A D Y
-- 
-- Create Date: 
-- Design Name: 
-- Module Name: Instruction_Decoder - Behavioral
-- Project Name: nanoprocessor design competition
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

entity Instruction_Decoder is
    Port ( Instruction_bus : in STD_LOGIC_VECTOR (11 downto 0);
           Check : in STD_LOGIC_VECTOR (3 downto 0) ;
           add_sub_select:out STD_LOGIC;
           register_enable:out STD_LOGIC_VECTOR(2 downto 0);
           load_select:out STD_LOGIC ;
           jzr_flag:out STD_LOGIC :='0';
           jzr_address:out STD_LOGIC_VECTOR (2 downto 0);
          
           register1 : out STD_LOGIC_VECTOR (2 downto 0);
           register2 : out STD_LOGIC_VECTOR (2 downto 0);
           value : out STD_LOGIC_VECTOR (3 downto 0));
end Instruction_Decoder;

architecture Behavioral of Instruction_Decoder is

 
begin

process (Instruction_bus, Check)
variable opcode : std_logic_vector(1 downto 0);
variable reg1 : std_logic_vector(2 downto 0);
variable reg2 : std_logic_vector(2 downto 0);
variable immediate_val : std_logic_vector(3 downto 0);
variable jmp_addrs : std_logic_vector(2 downto 0); 
 


begin
--extract values from the instruction input to the variables
    opcode := instruction_bus(11 downto 10);
    reg1 := instruction_bus(9 downto 7);
    reg2 := instruction_bus(6 downto 4);
    immediate_val := instruction_bus(3 downto 0);
    jmp_addrs := instruction_bus(2 downto 0);
    
 --assign default values to the outputs
    register_enable <= (others => '0') ;
    load_select <= '0' ;
    register1 <= (others => '0') ;
    register2 <= (others => '0') ;
    add_sub_select <= '0' ;
    value <= (others => '0') ;
    jzr_address <= (others => '0') ;
    jzr_flag <= '0' ;
    
-- activating relevant output signals for each instruction type   
    case opcode is
   
        when "10" => --MOVI R,d
            register_enable <= reg1;
            load_select <= '1';
            value <= immediate_val;
            
        when "00" => --ADD Ra,Rb
            register_enable <= reg1;
            register1 <= reg1;
            register2 <= reg2;
            add_sub_select <= '0';
            
        when "01" => --NEG R
            register_enable <= reg1;
            register1 <= "000" ;
            register2 <= reg1;
            add_sub_select <= '1';
            
        when "11" => --JZR R,d
            register1<= reg1;
            jzr_address <= jmp_addrs;
            if Check = "0000" then
                jzr_flag <= '1';
            else
                jzr_flag <= '0';
            end if;
            
        when others => 
            null;
            
    end case;
            
end process;

        




end Behavioral;