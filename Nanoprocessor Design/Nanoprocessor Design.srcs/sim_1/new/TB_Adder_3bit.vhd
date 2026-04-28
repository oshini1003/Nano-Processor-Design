library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_Adder_3bit is
end TB_Adder_3bit;

architecture Behavioral of TB_Adder_3bit is

    component Adder_3bit
        Port (
            A    : in  STD_LOGIC_VECTOR(2 downto 0);
            B    : in  STD_LOGIC_VECTOR(2 downto 0);
            Cin  : in  STD_LOGIC;
            Sum  : out STD_LOGIC_VECTOR(2 downto 0);
            Cout : out STD_LOGIC
        );
    end component;

    signal A_tb, B_tb : STD_LOGIC_VECTOR(2 downto 0) := "000";
    signal Cin_tb     : STD_LOGIC := '0';
    signal Sum_tb     : STD_LOGIC_VECTOR(2 downto 0);
    signal Cout_tb    : STD_LOGIC;

begin

    UUT : Adder_3bit port map (
        A    => A_tb,
        B    => B_tb,
        Cin  => Cin_tb,
        Sum  => Sum_tb,
        Cout => Cout_tb
    );

    process begin
        -- PC increment tests (B always = 001)
        -- PC=0 + 1 = 1
        A_tb <= "000"; B_tb <= "001"; Cin_tb <= '0';
        wait for 100 ns;

        -- PC=1 + 1 = 2
        A_tb <= "001"; B_tb <= "001"; Cin_tb <= '0';
        wait for 100 ns;

        -- PC=5 + 1 = 6
        A_tb <= "101"; B_tb <= "001"; Cin_tb <= '0';
        wait for 100 ns;

        -- PC=7 + 1 = 0 (overflow, 8 locations max)
        A_tb <= "111"; B_tb <= "001"; Cin_tb <= '0';
        wait for 100 ns;

        -- General addition: 3 + 4 = 7
        A_tb <= "011"; B_tb <= "100"; Cin_tb <= '0';
        wait for 100 ns;

        -- With Cin: 3 + 4 + 1 = 8 (Cout=1, Sum=0)
        A_tb <= "011"; B_tb <= "100"; Cin_tb <= '1';
        wait for 100 ns;

        wait;
    end process;

end Behavioral;