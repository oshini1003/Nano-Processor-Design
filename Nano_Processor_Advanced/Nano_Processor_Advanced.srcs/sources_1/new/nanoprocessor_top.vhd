----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/07/2026 02:37:56 PM
-- Design Name: 
-- Module Name: nanoprocessor_top - Behavioral
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

------------------------------------------------------------------------------
-- File        : nanoprocessor_top.vhd
-- Description : COMPLETE NANOPROCESSOR - TOP LEVEL DESIGN FOR BASYS 3 BOARD
-- Board       : Digilent Basys 3 (Xilinx Artix-7 XC7A35T-1CPG236C)
-- Clock       : 100 MHz onboard oscillator (divided down to ~0.5 Hz)
-- Features    :
--   - 4-bit datapath with 8 general-purpose registers (R0-R7)
--   - 12-bit instruction word (4 instruction types)
--   - Enhanced ALU with status flags (Zero, Carry, Overflow)
--   - 4-bit magnitude comparator (advanced feature)
--   - LED output visualization
--   - 7-segment PC display
-- Team        : 240348, 240351, 240347, 240343
-- Version     : 1.0 Final Production Release
-- Date        : Competition Ready
------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity nanoprocessor_top is
    port (
        -- Clock and Reset (Basys 3 pins)
        clk       : in  std_logic;                      -- W5: 100 MHz clock
        reset_btn : in  std_logic;                      -- C12: CPU RESET button
        
        -- LEDs (16 available on Basys 3, using LD0-LD15)
        led       : out std_logic_vector(15 downto 0);  -- H17..L1
        
        -- 7-segment Display (4 digits, common anode)
        seg       : out std_logic_vector(6 downto 0);   -- W7..W2: segments a-g
        an        : out std_logic_vector(3 downto 0);   -- W4..U2: digit enables
        
        -- Optional debug outputs (can connect to Pmod or unused pins)
        pc_debug  : out std_logic_vector(2 downto 0);   -- PC value for scope
        r1_debug  : out std_logic_vector(3 downto 0)    -- R1 value for scope
    );
end nanoprocessor_top;

architecture structural of nanoprocessor_top is

    --- =====================================================================
    -- COMPONENT DECLARATIONS
    -- =====================================================================
    
    component program_counter is
        port (
            clk    : in  std_logic;
            reset  : in  std_logic;
            enable : in  std_logic;
            load   : in  std_logic;
            input  : in  std_logic_vector(2 downto 0);
            output : out std_logic_vector(2 downto 0)
        );
    end component;
    
    component program_rom is
        port (
            address : in  std_logic_vector(2 downto 0);
            data    : out std_logic_vector(11 downto 0)
        );
    end component;
    
    component register_bank is
        port (
            clk        : in  std_logic;
            reset      : in  std_logic;
            write_en   : in  std_logic;
            reg_select : in  std_logic_vector(2 downto 0);
            data_in    : in  std_logic_vector(3 downto 0);
            r0_out     : out std_logic_vector(3 downto 0);
            r1_out     : out std_logic_vector(3 downto 0);
            r2_out     : out std_logic_vector(3 downto 0);
            r3_out     : out std_logic_vector(3 downto 0);
            r4_out     : out std_logic_vector(3 downto 0);
            r5_out     : out std_logic_vector(3 downto 0);
            r6_out     : out std_logic_vector(3 downto 0);
            r7_out     : out std_logic_vector(3 downto 0)
        );
    end component;
    
    component mux_8way_4bit is
        port (
            sel    : in  std_logic_vector(2 downto 0);
            in0    : in  std_logic_vector(3 downto 0);
            in1    : in  std_logic_vector(3 downto 0);
            in2    : in  std_logic_vector(3 downto 0);
            in3    : in  std_logic_vector(3 downto 0);
            in4    : in  std_logic_vector(3 downto 0);
            in5    : in  std_logic_vector(3 downto 0);
            in6    : in  std_logic_vector(3 downto 0);
            in7    : in  std_logic_vector(3 downto 0);
            output : out std_logic_vector(3 downto 0)
        );
    end component;
    
    component adder_4bit is
        port (
            A        : in  std_logic_vector(3 downto 0);
            B        : in  std_logic_vector(3 downto 0);
            Sub      : in  std_logic;
            Result   : out std_logic_vector(3 downto 0);
            Zero     : out std_logic;
            Overflow : out std_logic;
            Carry    : out std_logic
        );
    end component;
    
    component comparator_4bit is
        port (
            A           : in  std_logic_vector(3 downto 0);
            B           : in  std_logic_vector(3 downto 0);
            signed_mode : in  std_logic;
            A_eq_B      : out std_logic;
            A_gt_B      : out std_logic;
            A_lt_B      : out std_logic
        );
    end component;
    
    component adder_3bit is
        port (
            A   : in  std_logic_vector(2 downto 0);
            B   : in  std_logic_vector(2 downto 0);
            Cin : in  std_logic;
            Sum : out std_logic_vector(2 downto 0);
            Cout: out std_logic
        );
    end component;

    -- =====================================================================
    -- INTERNAL SIGNALS
    -- =====================================================================
    
    -- Clock management
    signal slow_clk      : std_logic := '0';
    signal clk_counter   : natural range 0 to 99999999 := 0;  -- Divides 100MHz to ~1Hz
    
    -- Program counter signals
    signal pc_value      : std_logic_vector(2 downto 0) := "000";
    signal pc_enable     : std_logic := '1';
    signal pc_load       : std_logic := '0';
    signal pc_jump_addr  : std_logic_vector(2 downto 0);
    signal pc_incremented: std_logic_vector(2 downto 0);
    signal pc_carry      : std_logic;
    
    -- Instruction bus
    signal instruction   : std_logic_vector(11 downto 0);
    
    -- Decoded instruction fields
    signal opcode        : std_logic_vector(1 downto 0);
    signal reg_a_field   : std_logic_vector(2 downto 0);
    signal reg_b_field   : std_logic_vector(2 downto 0);
    signal immediate_val : std_logic_vector(3 downto 0);
    
    -- Register bank signals
    signal r0, r1, r2, r3, r4, r5, r6, r7 : std_logic_vector(3 downto 0);
    signal reg_write_en  : std_logic := '0';
    signal reg_write_data: std_logic_vector(3 downto 0);
    
    -- Multiplexer outputs
    signal mux_a_output  : std_logic_vector(3 downto 0);
    signal mux_b_output  : std_logic_vector(3 downto 0);
    
    -- ALU signals
    signal alu_result    : std_logic_vector(3 downto 0);
    signal alu_zero      : std_logic;
    signal alu_overflow  : std_logic;
    signal alu_carry     : std_logic;
    signal alu_sub_ctrl  : std_logic := '0';
    
    -- Comparator signals (advanced feature)
    signal comp_equal    : std_logic;
    signal comp_greater  : std_logic;
    signal comp_less     : std_logic;
    
    -- Control signal generation
    signal is_movi       : std_logic;
    signal is_add        : std_logic;
    signal is_neg        : std_logic;
    signal is_jzr        : std_logic;
    
    -- 7-segment display driver
    signal seg_data      : std_logic_vector(3 downto 0);

begin

    -- =====================================================================
    -- CLOCK DIVIDER: 100 MHz -> ~0.5 Hz (2 second period)
    -- Allows visual observation of each instruction execution
    -- =====================================================================
    process(clk)
    begin
        if rising_edge(clk) then
            if reset_btn = '1' then
                clk_counter <= 0;
                slow_clk <= '0';
            else
                if clk_counter = 50000000 then  -- Count 50M cycles = 0.5 sec
                    clk_counter <= 0;
                    slow_clk <= not slow_clk;   -- Toggle -> 1Hz period
                else
                    clk_counter <= clk_counter + 1;
                end if;
            end if;
        end if;
    end process;

    -- =====================================================================
    -- INSTRUCTION DECODING
    -- Extract fields from 12-bit instruction word:
    -- Bits [11:10] = Opcode
    -- Bits [9:7]   = Register A (destination/operand)
    -- Bits [6:4]   = Register B (source operand)
    -- Bits [3:0]   = Immediate value / Jump address
    -- =====================================================================
    opcode        <= instruction(11 downto 10);
    reg_a_field   <= instruction(9 downto 7);
    reg_b_field   <= instruction(6 downto 4);
    immediate_val <= instruction(3 downto 0);
    
    -- Opcode decode signals
    is_movi <= '1' when opcode = "10" else '0';
    is_add  <= '1' when opcode = "00" else '0';
    is_neg  <= '1' when opcode = "01" else '0';
    is_jzr  <= '1' when opcode = "11" else '0';

    --n=====================================================================
    -- CONTROL UNIT: Generate control signals based on decoded opcode
    --=====================================================================
    control_process: process(opcode, alu_zero, immediate_val)
    begin
        -- Default values
        reg_write_en <= '0';
        alu_sub_ctrl <= '0';
        pc_load <= '0';
        pc_jump_addr <= immediate_val(2 downto 0);
        
        case opcode is
            when "00" =>   -- ADD Ra, Rb
                reg_write_en <= '1';
                alu_sub_ctrl <= '0';  -- Addition mode
                
            when "01" =>   -- NEG R (negate register: R <- 0 - R)
                reg_write_en <= '1';
                alu_sub_ctrl <= '1';  -- Subtraction mode (from R0=0)
                
            when "10" =>   -- MOVI R, d (move immediate)
                reg_write_en <= '1';
                -- ALU bypassed for MOVI
                
            when "11" =>   -- JZR R, d (jump if register == 0)
                if alu_zero = '1' then
                    pc_load <= '1';  -- Take the jump!
                end if;
                
            when others =>
                null;
        end case;
    end process;

    -- =====================================================================
    -- DATA PATH MULTIPLEXING: Determine what gets written to register
    -- =====================================================================
    -- For MOVI: write immediate value directly
    -- For ADD/NEG: write ALU result
    reg_write_data <= immediate_val when is_movi = '1' else alu_result;

    -- =====================================================================
    -- COMPONENT INSTANTIATIONS
    -- =====================================================================

    -- 1. PROGRAM COUNTER
    PC_INST: program_counter
        port map (
            clk    => slow_clk,
            reset  => reset_btn,
            enable => pc_enable,
            load   => pc_load,
            input  => pc_jump_addr,
            output => pc_value
        );
        
    -- Export PC for debugging
    pc_debug <= pc_value;

    -- 2. PROGRAM ROM
    ROM_INST: program_rom
        port map (
            address => pc_value,
            data    => instruction
        );

    -- 3. REGISTER BANK
    REG_BANK_INST: register_bank
        port map (
            clk        => slow_clk,
            reset      => reset_btn,
            write_en   => reg_write_en,
            reg_select => reg_a_field,
            data_in    => reg_write_data,
            r0_out     => r0,
            r1_out     => r1,
            r2_out     => r2,
            r3_out     => r3,
            r4_out     => r4,
            r5_out     => r5,
            r6_out     => r6,
            r7_out     => r7
        );
        
    -- Export R1 for debugging
    r1_debug <= r1;

    -- 4. MUX-A: Selects operand A for ALU (from RA field)
    MUX_A_INST: mux_8way_4bit
        port map (
            sel    => reg_a_field,
            in0    => r0,
            in1    => r1,
            in2    => r2,
            in3    => r3,
            in4    => r4,
            in5    => r5,
            in6    => r6,
            in7    => r7,
            output => mux_a_output
        );

    -- 5. MUX-B: Selects operand B for ALU (from RB field)
    MUX_B_INST: mux_8way_4bit
        port map (
            sel    => reg_b_field,
            in0    => r0,
            in1    => r1,
            in2    => r2,
            in3    => r3,
            in4    => r4,
            in5    => r5,
            in6    => r6,
            in7    => r7,
            output => mux_b_output
        );

    -- 6. ARITHMETIC LOGIC UNIT (ALU)
    ALU_INST: adder_4bit
        port map (
            A        => mux_a_output,
            B        => mux_b_output,
            Sub      => alu_sub_ctrl,
            Result   => alu_result,
            Zero     => alu_zero,
            Overflow => alu_overflow,
            Carry    => alu_carry
        );

    -- 7. COMPARATOR (Advanced Feature - runs in parallel with ALU)
    COMP_INST: comparator_4bit
        port map (
            A           => mux_a_output,
            B           => mux_b_output,
            signed_mode => '0',  -- Unsigned comparison
            A_eq_B      => comp_equal,
            A_gt_B      => comp_greater,
            A_lt_B      => comp_less
        );

    -- 8. PC INCREMENTER (computes PC + 1 for sequential execution)
    PC_ADDER_INST: adder_3bit
        port map (
            A   => pc_value,
            B   => "001",  -- Add 1
            Cin => '0',
            Sum => pc_incremented,
            Cout=> pc_carry
        );

    -- =====================================================================
    -- OUTPUT VISUALIZATION FOR BASYS 3 BOARD
    -- =====================================================================

    -- ================================================================
    -- LED ASSIGNMENT STRATEGY (LD0 through LD15):
    --
    -- LD0-LD3  : R1 Register Content (the main working register)
    -- LD4      : Zero Flag (Z) - indicates result was zero
    -- LD5      : Overflow Flag (O) - indicates arithmetic overflow
    -- LD6      : Comparator Equal Flag (A == B)
    -- LD7      : Comparator Greater Flag (A > B)
    -- LD8-LD11 : R2 Register Content (secondary register)
    -- LD12     : Running indicator (toggles with clock)
    -- LD13     : Write Enable indicator (shows when writing to regs)
    -- LD14     : PC bit 1 (helps track program location)
    -- LD15     : PC bit 2 (MSB of PC, shows addresses 4-7)
    -- ================================================================

    led(3 downto 0)  <= r1;              -- Show R1 on lower 4 LEDs
    led(4)           <= alu_zero;        -- Zero flag
    led(5)           <= alu_overflow;    -- Overflow flag
    led(6)           <= comp_equal;      -- Comparator equal
    led(7)           <= comp_greater;    -- Comparator greater than
    led(11 downto 8) <= r2;             -- Show R2 on next 4 LEDs
    led(12)          <= slow_clk;        -- Running indicator (blinks at 0.5Hz)
    led(13)          <= reg_write_en;    -- Shows when register write happens
    led(14)          <= pc_value(1);     -- PC bit 1
    led(15)          <= pc_value(2);     -- PC bit 2 (MSB)

    -- ================================================================
    -- 7-SEGMENT DISPLAY DRIVER
    -- Shows current PC value (0-7) on rightmost digit (digit 0)
    -- Uses simple binary-to-7-segment decoder
    -- Common Anode display: segment active LOW
    -- ================================================================

    -- Prepare 4-bit data for display (pad PC with leading zero)
    seg_data <= "000" & pc_value;
    
    -- Segment decoder (active low for common anode)
    process(seg_data)
    begin
        case seg_data is
            when "0000" => seg <= "0000001";  -- 0
            when "0001" => seg <= "1001111";  -- 1
            when "0010" => seg <= "0010010";  -- 2
            when "0011" => seg <= "0000110";  -- 3
            when "0100" => seg <= "1001100";  -- 4
            when "0101" => seg <= "0100100";  -- 5
            when "0110" => seg <= "0100000";  -- 6
            when "0111" => seg <= "0001111";  -- 7
            when "1000" => seg <= "0000000";  -- 8
            when "1001" => seg <= "0000100";  -- 9
            when "1010" => seg <= "0000010";  -- A (hex)
            when "1011" => seg <= "0000000";  -- B
            when "1100" => seg <= "0110001";  -- C
            when "1101" => seg <= "0000101";  -- D
            when "1110" => seg <= "0100001";  -- E
            when "1111" => seg <= "0100011";  -- F
            when others => seg <= "1111111";  -- Blank (all off)
        end case;
    end process;
    
    -- Activate only digit 0 (rightmost), turn off others (active low)
    an <= "1110";  -- Digit 0 ON, Digits 1-3 OFF

end structural;
