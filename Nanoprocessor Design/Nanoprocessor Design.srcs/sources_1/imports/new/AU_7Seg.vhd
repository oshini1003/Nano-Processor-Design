----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/23/2026 10:03:38 PM
-- Design Name: 
-- Module Name: AU_7Seg - Behavioral
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

entity AU_7Seg is
    Port ( A : in STD_LOGIC_VECTOR (3 downto 0);
           Clk : in STD_LOGIC;
           RegSel : in STD_LOGIC;
           S_LED : out STD_LOGIC_VECTOR (3 downto 0);
           S_7Seg : out STD_LOGIC_VECTOR (6 downto 0);
           Carry : out STD_LOGIC;
           Zero : out STD_LOGIC);
end AU_7Seg;

architecture Behavioral of AU_7Seg is
component AU
    Port ( A : in STD_LOGIC_VECTOR (3 downto 0);
           Clk : in STD_LOGIC;
           RegSel : in STD_LOGIC;
           S : out STD_LOGIC_VECTOR (3 downto 0);
           Carry : out STD_LOGIC;
           Zero : out STD_LOGIC);
end component;

component LUT_16_7
    Port ( address : in STD_LOGIC_VECTOR (3 downto 0);
           data : out STD_LOGIC_VECTOR (6 downto 0));
end component;

signal AU_S,address : std_logic_vector(3 downto 0);
signal AU_Zero,AU_Carry : std_logic;
signal LUT_7_Seg_Out : std_logic_vector(6 downto 0);
begin
    AU_0 : AU
        port map(
        A => A,
        RegSel => RegSel,
        Clk => Clk,
        S => AU_S,
        Zero => AU_Zero,
        Carry => AU_Carry
        );
    LUT_16_7_0 : LUT_16_7
        port map(
        address => AU_S,
        data => LUT_7_Seg_Out
        );
        Zero <= AU_Zero;
        Carry <= AU_Carry;
        S_LED <= AU_S;
        S_7Seg <= LUT_7_Seg_Out;

end Behavioral;
