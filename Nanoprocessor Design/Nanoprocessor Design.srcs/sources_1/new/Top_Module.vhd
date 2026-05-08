library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Top_Module is
   Port ( clk            : in  STD_LOGIC;
          reset          : in  STD_LOGIC;
          overflow_final : out STD_LOGIC;
          zero_final     : out STD_LOGIC;
          output         : out STD_LOGIC_VECTOR(3 downto 0);
          Reg7_7seg      : out STD_LOGIC_VECTOR (6 downto 0);
          Anode          : out STD_LOGIC_VECTOR (3 downto 0) := "1110"
   );
end Top_Module;

architecture Behavioral of Top_Module is

    component Counter
        Port ( Dir : in STD_LOGIC; Res : in STD_LOGIC; Clk : in STD_LOGIC; Q : out STD_LOGIC_VECTOR (2 downto 0));
    end component;

    component Instruction_Decoder
        Port ( Instruction_bus  : in  STD_LOGIC_VECTOR (11 downto 0);
               Check            : in  STD_LOGIC_VECTOR (3 downto 0);
               add_sub_select   : out STD_LOGIC;
               register_enable  : out STD_LOGIC_VECTOR(2 downto 0);
               load_select      : out STD_LOGIC;
               jzr_flag         : out STD_LOGIC;
               jzr_address      : out STD_LOGIC_VECTOR (2 downto 0);
               register1        : out STD_LOGIC_VECTOR (2 downto 0);
               register2        : out STD_LOGIC_VECTOR (2 downto 0);
               value            : out STD_LOGIC_VECTOR (3 downto 0));
    end component;

    component Register_Memory
        Port ( Write_Data      : in  STD_LOGIC_VECTOR (3 downto 0);
               reset            : in  STD_LOGIC;
               Register_Enable  : in  STD_LOGIC_VECTOR (2 downto 0);
               clk              : in  STD_LOGIC;
               out0             : out STD_LOGIC_VECTOR (3 downto 0);
               out1             : out STD_LOGIC_VECTOR (3 downto 0);
               out2             : out STD_LOGIC_VECTOR (3 downto 0);
               out3             : out STD_LOGIC_VECTOR (3 downto 0);
               out4             : out STD_LOGIC_VECTOR (3 downto 0);
               out5             : out STD_LOGIC_VECTOR (3 downto 0);
               out6             : out STD_LOGIC_VECTOR (3 downto 0);
               out7             : out STD_LOGIC_VECTOR (3 downto 0));
    end component;

    component Mux_8_W_4_B
        Port ( A0 : in STD_LOGIC_VECTOR (3 downto 0); A1 : in STD_LOGIC_VECTOR (3 downto 0);
               A2 : in STD_LOGIC_VECTOR (3 downto 0); A3 : in STD_LOGIC_VECTOR (3 downto 0);
               A4 : in STD_LOGIC_VECTOR (3 downto 0); A5 : in STD_LOGIC_VECTOR (3 downto 0);
               A6 : in STD_LOGIC_VECTOR (3 downto 0); A7 : in STD_LOGIC_VECTOR (3 downto 0);
               C_OUT : out STD_LOGIC_VECTOR (3 downto 0); S : in STD_LOGIC_VECTOR (2 downto 0));
    end component;

    component Add_Sub_4bit_unit
        Port ( A : in  STD_LOGIC_VECTOR (3 downto 0); B : in  STD_LOGIC_VECTOR (3 downto 0);
               Sel : in  STD_LOGIC; SUM : out STD_LOGIC_VECTOR (3 downto 0);
               overflow : out STD_LOGIC; ZERO : out STD_LOGIC );
    end component;

    component w2_4_MUX
        Port ( Load_Select : in STD_LOGIC; Immediate : in STD_LOGIC_VECTOR (3 downto 0);
               S : in STD_LOGIC_VECTOR (3 downto 0); Value_In : out STD_LOGIC_VECTOR (3 downto 0));
    end component;

    component LUT_7Seg
        Port ( Address : in  STD_LOGIC_VECTOR(3 DOWNTO 0); Data : out STD_LOGIC_VECTOR(6 DOWNTO 0));
    end component;

    signal memory_select    : STD_LOGIC_VECTOR(2 DOWNTO 0);
    
    -- CHANGED BACK TO SIGNAL: So the internal ROM can change it on every clock tick
    signal instruction      : STD_LOGIC_VECTOR (11 downto 0);
    
    signal jzr_address      : STD_LOGIC_VECTOR (2 downto 0);
    signal jzr_flag         : STD_LOGIC;
    signal register1        : STD_LOGIC_VECTOR (2 downto 0);
    signal register2        : STD_LOGIC_VECTOR (2 downto 0);
    signal out0             : STD_LOGIC_VECTOR (3 downto 0);
    signal out1             : STD_LOGIC_VECTOR (3 downto 0);
    signal out2             : STD_LOGIC_VECTOR (3 downto 0);
    signal out3             : STD_LOGIC_VECTOR (3 downto 0);
    signal out4             : STD_LOGIC_VECTOR (3 downto 0);
    signal out5             : STD_LOGIC_VECTOR (3 downto 0);
    signal out6             : STD_LOGIC_VECTOR (3 downto 0);
    signal out7             : STD_LOGIC_VECTOR (3 downto 0);
    signal regA             : STD_LOGIC_VECTOR (3 downto 0);
    signal regB             : STD_LOGIC_VECTOR (3 downto 0);
    signal A0               : STD_LOGIC_VECTOR (3 downto 0);
    signal Write_Data       : STD_LOGIC_VECTOR (3 downto 0);
    signal register_enable  : STD_LOGIC_VECTOR(2 downto 0);
    signal add_sub_select   : STD_LOGIC;
    signal load_select      : STD_LOGIC;
    signal value            : STD_LOGIC_VECTOR (3 downto 0);
    signal overflow         : STD_LOGIC;
    signal ZERO             : STD_LOGIC;
    signal Data             : STD_LOGIC_VECTOR(6 downto 0);

begin

    -- 1. Program Counter
    PC : Counter port map( Dir => '0', Res => reset, Clk => clk, Q => memory_select );

    -- 2. INTERNAL INSTRUCTION ROM (Replaces the missing file)
    -- This feeds the correct 12-bit instruction to the decoder based on the Counter
    process(memory_select)
    begin
        case memory_select is
            when "000" => instruction <= "100001000010"; -- MOVI R1, 2
            when "001" => instruction <= "100100000011"; -- MOVI R2, 3
            when "010" => instruction <= "000011001000"; -- ADD R3, R1 (R3 = 0 + 2)
            when "011" => instruction <= "000011010000"; -- ADD R3, R2 (R3 = 2 + 3)
            when "100" => instruction <= "110000000100"; -- JZR R0, 4 (Infinite loop, because R0 is always 0)
            when others => instruction <= "000000000000";
        end case;
    end process;

    -- 3. Instruction Decoder
    Instruction_Decorder1 : Instruction_Decoder port map(
        Instruction_bus => instruction, add_sub_select => add_sub_select, jzr_address => jzr_address,
        jzr_flag => jzr_flag, load_select => load_select, register1 => register1, register2 => register2,
        value => value, register_enable => register_enable, Check => regA );
         
    -- 4. MUXes
    MUX_8_W_4_B1 : Mux_8_W_4_B port map(
        A0 => out0, A1 => out1, A2 => out2, A3 => out3, A4 => out4, A5 => out5, A6 => out6, A7 => out7,
        C_OUT => regA, S => register1 );
           
    MUX_8_W_4_B2 : Mux_8_W_4_B port map(
        A0 => out0, A1 => out1, A2 => out2, A3 => out3, A4 => out4, A5 => out5, A6 => out6, A7 => out7,
        C_OUT => regB, S => register2 );
             
    -- 5. Register Memory
    Register_Memory1 : Register_Memory port map(
        clk => clk, reset => reset, Register_Enable => register_enable, Write_Data => Write_Data,
        out0 => out0, out1 => out1, out2 => out2, out3 => out3, out4 => out4, out5 => out5, out6 => out6, out7 => out7 );
       
    -- 6. ALU
    Add_Sub_unit1 : Add_Sub_4bit_unit port map(
        A => regA, B => regB, SUM => A0, overflow => overflow, ZERO => ZERO, Sel => add_sub_select );
         
    -- 7. Load MUX
    w2_4_MUX1 : w2_4_MUX port map(
        Load_Select => load_select, Immediate => value, S => A0, Value_In => Write_Data );
        
    -- 8. 7-Segment Display
    LUT_7Seg1 : LUT_7Seg port map( Address => out7, Data => Data );

    -- Final Outputs
    overflow_final <= overflow;
    zero_final <= ZERO;
    output <= out7;
    Reg7_7seg <= Data;

end Behavioral;