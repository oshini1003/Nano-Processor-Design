library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Add_Sub_4_bit_TB is
-- Test bench doesn't have ports
end Add_Sub_4_bit_TB;

architecture Behavioral of Add_Sub_4_bit_TB is
    -- Component declaration for the Unit Under Test (UUT)
    COMPONENT Add_Sub_4_bit
        Port(
            Input_A       : in  STD_LOGIC_VECTOR (3 DOWNTO 0);
            Input_B       : in  STD_LOGIC_VECTOR (3 DOWNTO 0);
            Mode_Sel      : in  STD_LOGIC;
            Result        : out STD_LOGIC_VECTOR(3 DOWNTO 0);
            Zero_Flag     : out STD_LOGIC;
            Overflow_Flag : out STD_LOGIC
        );
    END COMPONENT;
    
    -- Signals
    signal Input_A        : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal Input_B        : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal Mode_Sel       : STD_LOGIC := '0';
    signal Result         : STD_LOGIC_VECTOR(3 downto 0);
    signal Zero_Flag      : STD_LOGIC;
    signal Overflow_Flag  : STD_LOGIC;
    
    -- Clock signal
    signal clk        : STD_LOGIC := '0';
    constant clk_period : time := 10 ns;
    
begin
    -- Instantiate the Unit Under Test
    uut: Add_Sub_4_bit PORT MAP (
        Input_A       => Input_A,
        Input_B       => Input_B,
        Mode_Sel      => Mode_Sel,
        Result        => Result,
        Zero_Flag     => Zero_Flag,
        Overflow_Flag => Overflow_Flag
    );
    
    -- Clock process
    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    -- Test stimulus process
    stim_proc: process
    begin
        -- Wait for initialization
        wait for 100 ns;
        
        -------------------------------------
        -- Addition Tests (Mode_Sel = '0')
        
        --Index number 240343 - 11 1010 1010 1101 0111
        
        -- 1010 = -6,  1101 = -3,  0111 = +7
        -------------------------------------
        Mode_Sel <= '0';
        
        -- Test 1: 1010 + 1101 => (-6) + (-3) = -9, OVERFLOW => wraps to 0111
        Input_A <= "1010";
        Input_B <= "1101";
        wait for clk_period;
        report "Test 1: 1010 + 1101 = " & integer'image(to_integer(signed(Result))) &
               ", Overflow = " & std_logic'image(Overflow_Flag);
        
        -- Test 2: 1010 + 0111 => (-6) + (+7) = +1, no overflow
        Input_A <= "1010";
        Input_B <= "0111";
        wait for clk_period;
        report "Test 2: 1010 + 0111 = " & integer'image(to_integer(signed(Result))) &
               ", Overflow = " & std_logic'image(Overflow_Flag);
        
        -- Test 3: 1101 + 0111 => (-3) + (+7) = +4, no overflow
        Input_A <= "1101";
        Input_B <= "0111";
        wait for clk_period;
        report "Test 3: 1101 + 0111 = " & integer'image(to_integer(signed(Result))) &
               ", Overflow = " & std_logic'image(Overflow_Flag);
        
        -------------------------------------
        -- Subtraction Tests (Mode_Sel = '1')
        -------------------------------------
        Mode_Sel <= '1';
        
        -- Test 4: 0111 - 1101 => (+7) - (-3) = +10, OVERFLOW => wraps to 1010
        Input_A <= "0111";
        Input_B <= "1101";
        wait for clk_period;
        report "Test 4: 0111 - 1101 = " & integer'image(to_integer(signed(Result))) &
               ", Overflow = " & std_logic'image(Overflow_Flag);
        
        -- Test 5: 0111 - 1010 => (+7) - (-6) = +13, OVERFLOW => wraps to 1101
        Input_A <= "0111";
        Input_B <= "1010";
        wait for clk_period;
        report "Test 5: 0111 - 1010 = " & integer'image(to_integer(signed(Result))) &
               ", Overflow = " & std_logic'image(Overflow_Flag);
        
        -- Test 6: 1101 - 1010 => (-3) - (-6) = +3, no overflow
        Input_A <= "1101";
        Input_B <= "1010";
        wait for clk_period;
        report "Test 6: 1101 - 1010 = " & integer'image(to_integer(signed(Result))) &
               ", Overflow = " & std_logic'image(Overflow_Flag);
        
        -- Test 7: 1010 - 1101 => (-6) - (-3) = -3, no overflow
        Input_A <= "1010";
        Input_B <= "1101";
        wait for clk_period;
        report "Test 7: 1010 - 1101 = " & integer'image(to_integer(signed(Result))) &
               ", Overflow = " & std_logic'image(Overflow_Flag);
        
        -- Test 8: 1010 - 0111 => (-6) - (+7) = -13, OVERFLOW => wraps to 0011
        Input_A <= "1010";
        Input_B <= "0111";
        wait for clk_period;
        report "Test 8: 1010 - 0111 = " & integer'image(to_integer(signed(Result))) &
               ", Overflow = " & std_logic'image(Overflow_Flag);
        
        -- Test 9: 1101 - 0111 => (-3) - (+7) = -10, OVERFLOW => wraps to 0110
        Input_A <= "1101";
        Input_B <= "0111";
        wait for clk_period;
        report "Test 9: 1101 - 0111 = " & integer'image(to_integer(signed(Result))) &
               ", Overflow = " & std_logic'image(Overflow_Flag);
        
        -- End the simulation
        report "All tests completed";
        wait;
    end process;
end Behavioral;