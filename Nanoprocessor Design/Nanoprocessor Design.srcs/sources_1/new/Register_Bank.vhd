


----------------------------------------------------------------------------------
-- Company: UOM CSE
-- Engineer: 240343T
-- 
-- Create Date: 02/24/2026 03:41:49 PM
-- Design Name: Lab 4
-- Module Name: Register_Bank - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 8x 4-bit Register Bank with 3-to-8 Decoder addressing
-- 
-- Dependencies: Decoder_3_to_8, Reg
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Register_Bank is
    Port ( 
        Value_In : in  STD_LOGIC_VECTOR(3 downto 0);
        Clk      : in  STD_LOGIC;
        Reg_En   : in  STD_LOGIC_VECTOR(2 downto 0);
        Reset    : in  STD_LOGIC;
        R0       : out STD_LOGIC_VECTOR(3 downto 0);
        R1       : out STD_LOGIC_VECTOR(3 downto 0);
        R2       : out STD_LOGIC_VECTOR(3 downto 0);
        R3       : out STD_LOGIC_VECTOR(3 downto 0);
        R4       : out STD_LOGIC_VECTOR(3 downto 0);
        R5       : out STD_LOGIC_VECTOR(3 downto 0);
        R6       : out STD_LOGIC_VECTOR(3 downto 0);
        R7       : out STD_LOGIC_VECTOR(3 downto 0)
    );
end Register_Bank;

architecture Behavioral of Register_Bank is

    component Decoder_3_to_8
        Port(
            I  : in  STD_LOGIC_VECTOR(2 downto 0);
            EN : in  STD_LOGIC;
            Y  : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    component Reg
        Port ( 
            D   : in  STD_LOGIC_VECTOR(3 downto 0);
            En  : in  STD_LOGIC;
            Clk : in  STD_LOGIC;
            Res : in  STD_LOGIC;
            Q   : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    signal reg_en_out : STD_LOGIC_VECTOR(7 downto 0);

begin

    Decode_3_to_8_0 : Decoder_3_to_8
        Port map ( 
            I  => Reg_En,
            EN => '1',
            Y  => reg_en_out
        );

    Reg_0 : Reg
        Port map ( D => "0000",    En => '1',           Clk => Clk, Res => Reset, Q => R0 );

    Reg_1 : Reg
        Port map ( D => Value_In,  En => reg_en_out(1), Clk => Clk, Res => Reset, Q => R1 );

    Reg_2 : Reg
        Port map ( D => Value_In,  En => reg_en_out(2), Clk => Clk, Res => Reset, Q => R2 );

    Reg_3 : Reg
        Port map ( D => Value_In,  En => reg_en_out(3), Clk => Clk, Res => Reset, Q => R3 );

    Reg_4 : Reg
        Port map ( D => Value_In,  En => reg_en_out(4), Clk => Clk, Res => Reset, Q => R4 );

    Reg_5 : Reg
        Port map ( D => Value_In,  En => reg_en_out(5), Clk => Clk, Res => Reset, Q => R5 );

    Reg_6 : Reg
        Port map ( D => Value_In,  En => reg_en_out(6), Clk => Clk, Res => Reset, Q => R6 );

    Reg_7 : Reg
        Port map ( D => Value_In,  En => reg_en_out(7), Clk => Clk, Res => Reset, Q => R7 );

end Behavioral;