library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ADD_SUB_TB is
end ADD_SUB_TB;

architecture Behavioral of ADD_SUB_TB is

    component ADD_SUB
        Port ( 
            A             : in  STD_LOGIC_VECTOR (3 downto 0);
            B             : in  STD_LOGIC_VECTOR (3 downto 0);
            AddSub_Select : in  STD_LOGIC;
            Overflow      : out STD_LOGIC;
            Zero          : out STD_LOGIC;
            S             : out STD_LOGIC_VECTOR (3 downto 0)
        );
    end component;

    signal A_tb             : STD_LOGIC_VECTOR (3 downto 0) := "0000";
    signal B_tb             : STD_LOGIC_VECTOR (3 downto 0) := "0000";
    signal AddSub_Select_tb : STD_LOGIC := '0';
    signal Overflow_tb      : STD_LOGIC;
    signal Zero_tb          : STD_LOGIC;
    signal S_tb             : STD_LOGIC_VECTOR (3 downto 0);

begin
    UUT : ADD_SUB port map (
        A             => A_tb,
        B             => B_tb,
        AddSub_Select => AddSub_Select_tb,
        Overflow      => Overflow_tb,
        Zero          => Zero_tb,
        S             => S_tb
    );

    stim_proc: process
    begin
        -- ============================================
        -- ADDITION TESTS (AddSub_Select = '0')
        -- ============================================

        -- Test 1: 1101 + 0110 = 13 + 6 = 19
        -- Expected: S=0011, Overflow=1, Zero=0
        A_tb <= "1101";
        B_tb <= "0110";
        AddSub_Select_tb <= '0';
        wait for 100 ns;

        -- Test 2: 0011 + 1000 = 3 + 8 = 11
        -- Expected: S=1011, Overflow=0, Zero=0
        A_tb <= "0011";
        B_tb <= "1000";
        AddSub_Select_tb <= '0';
        wait for 100 ns;

        -- Test 3: 0000 + 0000 = 0
        -- Expected: S=0000, Overflow=0, Zero=1
        A_tb <= "0000";
        B_tb <= "0000";
        AddSub_Select_tb <= '0';
        wait for 100 ns;

        -- ============================================
        -- SUBTRACTION TESTS (AddSub_Select = '1')
        -- ============================================

        -- Test 4: 1000 - 1111 = 8 - 15 = -7
        -- Expected: S=1001 (2's comp -7), Overflow=0, Zero=0
        A_tb <= "1000";
        B_tb <= "1111";
        AddSub_Select_tb <= '1';
        wait for 100 ns;

        -- Test 5: 1111 - 0111 = 15 - 7 = 8
        -- Expected: S=1000, Overflow=1, Zero=0
        A_tb <= "1111";
        B_tb <= "0111";
        AddSub_Select_tb <= '1';
        wait for 100 ns;

        -- Test 6: ZERO FLAG TEST - 0110 - 0110 = 6 - 6 = 0
        -- Expected: S=0000, Overflow=1, Zero=1
        A_tb <= "0110";
        B_tb <= "0110";
        AddSub_Select_tb <= '1';
        wait for 100 ns;

        -- Test 7: 1111 - 0000 = 15 - 0 = 15
        -- Expected: S=1111, Overflow=1, Zero=0
        A_tb <= "1111";
        B_tb <= "0000";
        AddSub_Select_tb <= '1';
        wait for 100 ns;

        wait;
    end process;

end Behavioral;