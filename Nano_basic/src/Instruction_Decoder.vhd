library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.BusDefinitions.all;
use work.constants.all;

entity Instruction_Decoder_TB is
end Instruction_Decoder_TB;

architecture Behavioral of Instruction_Decoder_TB is
    -- Component declaration EXACTLY matching your source entity
    component Instruction_Decoder
        port (
            Instruction             : in  InstructionWord;
            Register_Value_For_Jump  : in  DataBus;
            Register_Enable         : out RegisterSelect;
            Register_Select_A       : out RegisterSelect;
            Register_Select_B       : out RegisterSelect;
            Operation_Select        : out STD_LOGIC;
            Immediate_Value         : out DataBus;
            Jump_Enable             : out STD_LOGIC;
            Jump_Address            : out ProgramCounter;
            Load_Select             : out STD_LOGIC
        );
    end component;
    
    -- Inputs
    signal tb_Instruction : InstructionWord := (others => '0');
    signal tb_Register_Value : DataBus := (others => '0');
    
    -- Outputs
    signal tb_Register_Enable : RegisterSelect;
    signal tb_Register_Select_A : RegisterSelect;
    signal tb_Register_Select_B : RegisterSelect;
    signal tb_Operation_Select : STD_LOGIC;
    signal tb_Immediate_Value : DataBus;
    signal tb_Jump_Enable : STD_LOGIC;
    signal tb_Jump_Address : ProgramCounter;
    signal tb_Load_Select : STD_LOGIC;
    
begin
    -- Instantiate the Unit Under Test (UUT)
    uut: Instruction_Decoder
        port map (
            Instruction => tb_Instruction,
            Register_Value_For_Jump => tb_Register_Value,
            Register_Enable => tb_Register_Enable,
            Register_Select_A => tb_Register_Select_A,
            Register_Select_B => tb_Register_Select_B,
            Operation_Select => tb_Operation_Select,
            Immediate_Value => tb_Immediate_Value,
            Jump_Enable => tb_Jump_Enable,
            Jump_Address => tb_Jump_Address,
            Load_Select => tb_Load_Select
        );
    
    -- Stimulus process using index segments: 1011, 1101, 1010 (4-bit) and 011, 101, 010, 111 (3-bit)
    stim_proc: process
    begin
        wait for 100 ns;
        
        -- 1. Test MOVI R3 (011), Immediate: 1011
        -- Format: [Opcode 10] [Reg 011] [Unused 000] [Imm 1011]
        tb_Instruction <= "10" & "011" & "000" & "1011";
        wait for 20 ns;
        
        -- 2. Test ADD R5 (101), R2 (010)
        -- Format: [Opcode 00] [RegA 101] [RegB 010] [Unused 0000]
        tb_Instruction <= "00" & "101" & "010" & "0000";
        wait for 20 ns;
        
        -- 3. Test NEG R7 (111)
        -- Format: [Opcode 01] [Reg 111] [Unused 0000000]
        tb_Instruction <= "01" & "111" & "0000000";
        wait for 20 ns;
        
        -- 4. Test JZR R3 (011), Jump Address 101 (Condition: Zero)
        -- Format: [Opcode 11] [Reg 011] [Unused 0000] [Addr 101]
        tb_Instruction <= "11" & "011" & "0000" & "101";
        tb_Register_Value <= "0000"; 
        wait for 20 ns;
        
        -- 5. Test JZR R3 (011), Failure (Condition: Non-Zero 1101)
        tb_Register_Value <= "1101"; 
        wait for 20 ns;

        -- 6. Final check with 1010
        -- MOVI R2 (010), Immediate: 1010
        tb_Instruction <= "10" & "010" & "000" & "1010";
        wait for 20 ns;
        
        wait;
    end process;
end Behavioral;