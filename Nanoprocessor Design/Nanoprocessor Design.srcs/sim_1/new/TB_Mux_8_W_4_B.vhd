library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity TB_Mux_8_W_4_B is
end TB_Mux_8_W_4_B;
architecture Behavioral of TB_Mux_8_W_4_B is
component Mux_8_W_4_B
Port (
    A0 : in STD_LOGIC_VECTOR (3 downto 0);
    A1 : in STD_LOGIC_VECTOR (3 downto 0);
    A2 : in STD_LOGIC_VECTOR (3 downto 0);
    A3 : in STD_LOGIC_VECTOR (3 downto 0);
    A4 : in STD_LOGIC_VECTOR (3 downto 0);
    A5 : in STD_LOGIC_VECTOR (3 downto 0);
    A6 : in STD_LOGIC_VECTOR (3 downto 0);
    A7 : in STD_LOGIC_VECTOR (3 downto 0);
    C_OUT : out STD_LOGIC_VECTOR (3 downto 0);
    S : in STD_LOGIC_VECTOR (2 downto 0)
    );
end component;
-- Signals to connect to the UUT

signal A0, A1, A2, A3, A4, A5, A6, A7 : STD_LOGIC_VECTOR(3 downto 0);
signal C_OUT : STD_LOGIC_VECTOR(3 downto 0);
signal S : STD_LOGIC_VECTOR(2 downto 0);
begin

-- Instantiate the Unit Under Test (UUT)
UUT: Mux_8_W_4_B
port map (
        A0 => A0,
        A1 => A1,
        A2 => A2,
        A3 => A3,
        A4 => A4,
        A5 => A5,
        A6 => A6,
        A7 => A7,
        C_OUT => C_OUT,
        S => S
        );
-- Stimulus process to drive the inputs
process
    begin
    -- Set all input values
    A0 <= "0011"; -- 3
    A1 <= "0000"; -- 0
    A2 <= "1000"; -- 8
    A3 <= "1111"; -- F
    A4 <= "0101"; -- 5
    A5 <= "1101"; -- D
    A6 <= "0111"; -- 7
    A7 <= "1100"; -- C
    -- Test all selector inputs
    S <= "000"; wait for 100 ns; -- Expect C_OUT = A0 = 0011
    S <= "001"; wait for 100 ns; -- Expect C_OUT = A1 = 0000
    S <= "010"; wait for 100 ns; -- Expect C_OUT = A2 = 1000
    S <= "011"; wait for 100 ns; -- Expect C_OUT = A3 = 1111
    S <= "100"; wait for 100 ns; -- Expect C_OUT = A4 = 0101
    S <= "101"; wait for 100 ns; -- Expect C_OUT = A5 = 1101
    S <= "110"; wait for 100 ns; -- Expect C_OUT = A6 = 0111
    S <= "111"; wait for 100 ns; -- Expect C_OUT = A7 = 1100
    wait; -- Stop simulation
end process;
end Behavioral;