library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Register_Memory is
    Port ( Write_Data : in STD_LOGIC_VECTOR (3 downto 0); reset:in STD_LOGIC;
           Register_Enable : in STD_LOGIC_VECTOR (2 downto 0); clk : in STD_LOGIC;
           out0 : out STD_LOGIC_VECTOR (3 downto 0); out1 : out STD_LOGIC_VECTOR (3 downto 0);
           out2 : out STD_LOGIC_VECTOR (3 downto 0); out3 : out STD_LOGIC_VECTOR (3 downto 0);
           out4 : out STD_LOGIC_VECTOR (3 downto 0); out5 : out STD_LOGIC_VECTOR (3 downto 0);
           out6 : out STD_LOGIC_VECTOR (3 downto 0); out7 : out STD_LOGIC_VECTOR (3 downto 0));
end Register_Memory;

architecture Behavioral of Register_Memory is
    component Register_4_bit Port ( D : in STD_LOGIC_VECTOR (3 downto 0); Res : in STD_LOGIC; EN : in STD_LOGIC; Clk : in STD_LOGIC; Q : out STD_LOGIC_VECTOR (3 downto 0)); end component;
    component Decoder_3_to_8 Port ( I : in STD_LOGIC_VECTOR (2 downto 0); EN : in STD_LOGIC ; Y : out STD_LOGIC_VECTOR (7 downto 0)); end component;
    signal dec_y: STD_LOGIC_VECTOR (7 downto 0); signal en :STD_LOGIC := '1';
begin
    Decoder_3_to_8_0: Decoder_3_to_8 port map( I=>Register_Enable, EN =>en, Y=>dec_y);
    Reg_0 :Register_4_bit port map( D => "0000", Res => reset, EN => dec_y(0), Clk => Clk, Q => out0);
    Reg_1 :Register_4_bit port map( D => Write_Data, Res =>reset, EN => dec_y(1), Clk => Clk, Q => out1); 
    Reg_2 :Register_4_bit port map( D => Write_Data, Res =>reset, EN => dec_y(2), Clk => Clk, Q => out2); 
    Reg_3 :Register_4_bit port map( D => Write_Data, Res =>reset, EN => dec_y(3), Clk => Clk, Q => out3); 
    Reg_4 :Register_4_bit port map( D => Write_Data, Res => reset, EN => dec_y(4), Clk => Clk, Q => out4); 
    Reg_5 :Register_4_bit port map( D => Write_Data, Res => reset, EN => dec_y(5), Clk => Clk, Q => out5);
    Reg_6 :Register_4_bit port map( D => Write_Data, Res => reset, EN => dec_y(6), Clk => Clk, Q => out6); 
    Reg_7 :Register_4_bit port map( D => Write_Data, Res => reset, EN => dec_y(7), Clk => Clk, Q => out7); 
end Behavioral;