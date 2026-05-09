library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
 
entity tb_Instruction_Decoder is 
end tb_Instruction_Decoder; 
 
architecture Behavioral of tb_Instruction_Decoder is 
 
    -- Component declaration matching your source file
    component Instruction_Decoder 
        Port ( 
            Instruction     : in  STD_LOGIC_VECTOR(12 downto 0); 
            Reg_Check_Zero  : in  STD_LOGIC_VECTOR(3 downto 0); 
            Reg_Enable      : out STD_LOGIC_VECTOR(2 downto 0); 
            Load_Select     : out STD_LOGIC; 
            Immediate       : out STD_LOGIC_VECTOR(3 downto 0); 
            MUX_A_Select    : out STD_LOGIC_VECTOR(2 downto 0); 
            MUX_B_Select    : out STD_LOGIC_VECTOR(2 downto 0); 
            AddSub_Select   : out STD_LOGIC; 
            Jump_Flag       : out STD_LOGIC; 
            Jump_Address    : out STD_LOGIC_VECTOR(2 downto 0); 
            Bit_Select      : out STD_LOGIC_VECTOR(1 downto 0); 
            Mode            : out STD_LOGIC 
        ); 
    end component; 
 
    -- Signals for inputs 
    signal Instruction     : STD_LOGIC_VECTOR(12 downto 0) := (others => '0'); 
    signal Reg_Check_Zero  : STD_LOGIC_VECTOR(3 downto 0) := "0000"; 
 
    -- Signals for outputs 
    signal Reg_Enable      : STD_LOGIC_VECTOR(2 downto 0); 
    signal Load_Select     : STD_LOGIC; 
    signal Immediate       : STD_LOGIC_VECTOR(3 downto 0); 
    signal MUX_A_Select    : STD_LOGIC_VECTOR(2 downto 0); 
    signal MUX_B_Select    : STD_LOGIC_VECTOR(2 downto 0); 
    signal AddSub_Select   : STD_LOGIC; 
    signal Jump_Flag       : STD_LOGIC; 
    signal Jump_Address    : STD_LOGIC_VECTOR(2 downto 0); 
    signal Bit_Select      : STD_LOGIC_VECTOR(1 downto 0); 
    signal Mode            : STD_LOGIC; 
 
begin 
 
    -- Instantiate the Unit Under Test (UUT) 
    uut: Instruction_Decoder 
        Port Map ( 
            Instruction     => Instruction, 
            Reg_Check_Zero  => Reg_Check_Zero, 
            Reg_Enable      => Reg_Enable, 
            Load_Select     => Load_Select, 
            Immediate       => Immediate, 
            MUX_A_Select    => MUX_A_Select, 
            MUX_B_Select    => MUX_B_Select, 
            AddSub_Select   => AddSub_Select, 
            Jump_Flag       => Jump_Flag, 
            Jump_Address    => Jump_Address, 
            Bit_Select      => Bit_Select, 
            Mode            => Mode 
        ); 
 
    -- Stimulus process 
    stim_proc: process 
    begin 
        -- Initial Reset State
        wait for 100 ns;

        -- 1. MOVI R3, 1011 (Opcode: 010, Reg: 011, Imm: 1011)
        -- Result: Reg_Enable="011", Load_Select='0', Immediate="1011"
        Instruction <= "0100110001011"; 
        wait for 20 ns; 
 
        -- 2. ADD R5, R2 (Opcode: 000, RegA: 101, RegB: 010)
        -- Result: MUX_A="101", MUX_B="010", AddSub_Select='0'
        Instruction <= "0001010100000"; 
        wait for 20 ns; 
 
        -- 3. NEG R7 (Opcode: 001, Reg: 111)
        -- Result: AddSub_Select='1', Reg_Enable="111"
        Instruction <= "0011110000000"; 
        wait for 20 ns; 
 
        -- 4. JZR R3, Address 111 (Opcode: 011, Reg: 011, Addr: 111)
        -- Condition: Zero (Register input is 0000)
        -- Result: Jump_Flag='1', Jump_Address="111"
        Instruction <= "0110110000111"; 
        Reg_Check_Zero <= "0000";  
        wait for 20 ns; 
 
        -- 5. JZR R3, Address 111 (Failure Case)
        -- Condition: Non-Zero (Register input is 1101)
        -- Result: Jump_Flag='0'
        Reg_Check_Zero <= "1101"; 
        wait for 20 ns; 
 
        -- 6. Bitwise AND R2, R7 (Opcode: 101, Ra: 010, Rb: 111)
        -- Result: Opcode 101 decoded, MUXs set
        Instruction <= "1010101110000"; 
        wait for 20 ns; 
 
        -- 7. Bitwise XOR R1, 1010 (Opcode: 111, Ra: 001, Imm: 1010)
        -- Result: Opcode 111 decoded, Immediate="1010"
        Instruction <= "1110010001010"; 
        wait for 20 ns; 
 
        wait; 
    end process; 
 
end Behavioral;