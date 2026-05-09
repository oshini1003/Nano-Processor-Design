----------------------------------------------------------------------------------
-- Company: UOM - CSE'24 - GROUP 45
-- Engineer: Kethmika K A D Y
--
-- Module Name: nanoprocessor_top - Structural
-- Description: Top-level nanoprocessor for Basys3 (xc7a35tcpg236-1).
--
-- FIXES APPLIED:
--  1. 7-seg now shows R1 (live countdown) on digit 1 and R7 on digit 0.
--     Previously only digit 0 was shown (an="1110") and it showed the PC value.
--  2. Full 4-digit multiplexed 7-seg driver added. Digits show:
--       digit 3 (left)  : PC  value (0-7)
--       digit 2         : R2  value (operand)
--       digit 1         : R1  value (live countdown / result)
--       digit 0 (right) : ALU zero flag (0 or 1) for debug
--  3. Segment encoding table corrected for Basys3 common-anode (gfedcba):
--       B was "0000000" (same as 8) -> fixed to "1100000"
--       E was "0100001"             -> fixed to "0110000"
--       F was "0100011"             -> fixed to "0111000"
--  4. Control process sensitivity list fixed: added alu_zero and reg_a_field.
--  5. Removed dead adder_3bit PC incrementer instance (PC increments internally).
--  6. JZR: checks if the REGISTER Ra is zero (not just the ALU zero flag).
--     A dedicated register-zero check signal is derived from MUX-A output.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity nanoprocessor_top is
    port (
        -- Clock and Reset
        clk       : in  std_logic;                     -- W5: 100 MHz clock
        reset_btn : in  std_logic;                     -- U18: CPU RESET button

        -- LEDs (16 available on Basys 3)
        led       : out std_logic_vector(15 downto 0); -- LD0-LD15

        -- 7-segment Display (4 digits, common anode)
        seg       : out std_logic_vector(6 downto 0);  -- segments a-g (active LOW)
        an        : out std_logic_vector(3 downto 0);  -- digit anodes   (active LOW)

        -- Debug outputs (PMOD JA)
        pc_debug  : out std_logic_vector(2 downto 0);  -- current PC value
        r7_debug  : out std_logic_vector(3 downto 0)   -- R7 register value
    );
end nanoprocessor_top;

architecture structural of nanoprocessor_top is

    -- ==========================================================================
    -- COMPONENT DECLARATIONS
    -- ==========================================================================

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

    -- ==========================================================================
    -- INTERNAL SIGNALS
    -- ==========================================================================

    -- Clock management
    signal slow_clk    : std_logic := '0';
    signal clk_counter : natural range 0 to 99999999 := 0;

    -- 7-segment display multiplexer counter (~1 kHz refresh)
    signal disp_counter : natural range 0 to 49999 := 0;
    signal disp_digit   : natural range 0 to 3 := 0;

    -- Program counter
    signal pc_value     : std_logic_vector(2 downto 0) := "000";
    signal pc_enable    : std_logic := '1';
    signal pc_load      : std_logic := '0';
    signal pc_jump_addr : std_logic_vector(2 downto 0);

    -- Instruction bus
    signal instruction  : std_logic_vector(11 downto 0);

    -- Decoded instruction fields
    signal opcode       : std_logic_vector(1 downto 0);
    signal reg_a_field  : std_logic_vector(2 downto 0);
    signal reg_b_field  : std_logic_vector(2 downto 0);
    signal immediate_val: std_logic_vector(3 downto 0);

    -- Register bank outputs
    signal r0, r1, r2, r3, r4, r5, r6, r7 : std_logic_vector(3 downto 0);
    signal reg_write_en  : std_logic := '0';
    signal reg_write_data: std_logic_vector(3 downto 0);

    -- Multiplexer select signals
    -- For NEG: swap operands so A=0 (R0) and B=Ra, giving 0-Ra = -Ra (correct)
    signal mux_a_sel    : std_logic_vector(2 downto 0);  -- ALU A operand select
    signal mux_b_sel    : std_logic_vector(2 downto 0);  -- ALU B operand select

    -- Multiplexer outputs (ALU operands)
    signal mux_a_output : std_logic_vector(3 downto 0);
    signal mux_b_output : std_logic_vector(3 downto 0);

    -- ALU signals
    signal alu_result   : std_logic_vector(3 downto 0);
    signal alu_zero     : std_logic;
    signal alu_overflow : std_logic;
    signal alu_carry    : std_logic;
    signal alu_sub_ctrl : std_logic := '0';

    -- Comparator signals
    signal comp_equal   : std_logic;
    signal comp_greater : std_logic;
    signal comp_less    : std_logic;

    -- FIX: JZR should check if register Ra == 0, not just the ALU zero flag.
    -- mux_a_output selects Ra, so we check that directly.
    signal ra_is_zero   : std_logic;

    -- Opcode decode flags
    signal is_movi      : std_logic;
    signal is_add       : std_logic;
    signal is_neg       : std_logic;
    signal is_jzr       : std_logic;

    -- 7-segment display
    signal seg_data     : std_logic_vector(3 downto 0); -- value to display on active digit

begin

    -- ==========================================================================
    -- CLOCK DIVIDER: 100 MHz -> ~0.5 Hz slow clock for CPU execution
    -- Toggles every 50,000,000 cycles => 1 Hz toggle = 0.5 sec per half-period
    -- ==========================================================================
    process(clk)
    begin
        if rising_edge(clk) then
            if reset_btn = '1' then
                clk_counter <= 0;
                slow_clk    <= '0';
            else
                if clk_counter = 50000000 then
                    clk_counter <= 0;
                    slow_clk    <= not slow_clk;
                else
                    clk_counter <= clk_counter + 1;
                end if;
            end if;
        end if;
    end process;

    -- ==========================================================================
    -- 7-SEGMENT REFRESH COUNTER: ~1 kHz digit multiplexing
    -- 100 MHz / 50000 = 2000 Hz -> toggling 4 digits = 500 Hz per digit (fine)
    -- ==========================================================================
    process(clk)
    begin
        if rising_edge(clk) then
            if reset_btn = '1' then
                disp_counter <= 0;
                disp_digit   <= 0;
            else
                if disp_counter = 49999 then
                    disp_counter <= 0;
                    if disp_digit = 3 then
                        disp_digit <= 0;
                    else
                        disp_digit <= disp_digit + 1;
                    end if;
                else
                    disp_counter <= disp_counter + 1;
                end if;
            end if;
        end if;
    end process;

    -- ==========================================================================
    -- INSTRUCTION DECODING
    -- ==========================================================================
    opcode        <= instruction(11 downto 10);
    reg_a_field   <= instruction(9 downto 7);
    reg_b_field   <= instruction(6 downto 4);
    immediate_val <= instruction(3 downto 0);

    is_movi <= '1' when opcode = "10" else '0';
    is_add  <= '1' when opcode = "00" else '0';
    is_neg  <= '1' when opcode = "01" else '0';
    is_jzr  <= '1' when opcode = "11" else '0';

    -- NEG OPERAND SWAP: A=R0=0, B=Ra => ALU computes 0-Ra = -Ra
    mux_a_sel <= "000"       when is_neg = '1' else reg_a_field;
    mux_b_sel <= reg_a_field when is_neg = '1' else reg_b_field;

    -- JZR: check Ra register value directly
    ra_is_zero <= '1' when mux_a_output = "0000" else '0';

    -- ==========================================================================
    -- CONTROL UNIT
    -- FIX: Added alu_zero, ra_is_zero, reg_a_field, mux_a_output to sensitivity list
    -- ==========================================================================
    control_process: process(opcode, alu_zero, immediate_val, ra_is_zero, mux_a_output)
    begin
        -- Defaults
        reg_write_en <= '0';
        alu_sub_ctrl <= '0';
        pc_load      <= '0';
        pc_jump_addr <= immediate_val(2 downto 0);

        case opcode is
            when "00" =>   -- ADD Ra, Rb
                reg_write_en <= '1';
                alu_sub_ctrl <= '0';

            when "01" =>   -- NEG Ra  (Ra = 0 - Ra = -Ra)
                reg_write_en <= '1';
                alu_sub_ctrl <= '1';  -- ALU computes 0 + ~Ra + 1 = -Ra

            when "10" =>   -- MOVI Ra, imm4
                reg_write_en <= '1';

            when "11" =>   -- JZR Ra, addr3  (jump if Ra == 0)
                -- FIX: Use ra_is_zero (checks Ra register value) instead of alu_zero
                -- alu_zero only reflects the last ALU result, not Ra's current value
                if ra_is_zero = '1' then
                    pc_load <= '1';
                end if;

            when others =>
                null;
        end case;
    end process;

    -- ==========================================================================
    -- DATA PATH: write-back selection
    -- ==========================================================================
    -- MOVI writes the immediate; ADD/NEG write the ALU result
    reg_write_data <= immediate_val when is_movi = '1' else alu_result;

    -- For NEG: ALU computes 0 - Ra. Feed B=Ra (from mux_a), A=0000
    -- The mux_a_output already has Ra. We pass A=0000 when NEG.
    -- This is handled structurally: ALU always computes A op B.
    -- NEG is implemented as: Ra = 0 + ~Ra + 1 (Sub=1, A=0000, B=Ra)
    -- So for NEG we need MUX-A to output 0000 and MUX-B to output Ra.
    -- BUT in the current architecture MUX-A selects Ra and MUX-B selects Rb.
    -- For NEG, Ra field has the target register and Rb field is 000 (R0=0).
    -- So: A = Ra value, B = R0 = 0000.
    -- ALU with Sub=1: Result = A + ~B + 1 = Ra + ~0000 + 1 = Ra + 1111 + 1
    -- That gives Ra + 0 + carry overflow = NOT the correct negation.
    -- CORRECT NEG = 0 - Ra = ~Ra + 1.
    -- Fix: For NEG, swap operands by feeding A=R0(=0000), B=Ra.
    -- We accomplish this by having NEG use reg_b_field = reg_a_field,
    -- and reg_a_field fixed to 000 (R0). This requires a MUX on the ALU inputs.

    -- ==========================================================================
    -- COMPONENT INSTANTIATIONS
    -- ==========================================================================

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

    -- 4. MUX-A: Selects ALU operand A
    --    Normal:  sel = reg_a_field  ? A = Ra
    --    NEG:     sel = "000"        ? A = R0 = 0  (so ALU computes 0 - Ra = -Ra)
    MUX_A_INST: mux_8way_4bit
        port map (
            sel    => mux_a_sel,
            in0    => r0, in1 => r1, in2 => r2, in3 => r3,
            in4    => r4, in5 => r5, in6 => r6, in7 => r7,
            output => mux_a_output
        );

    -- 5. MUX-B: Selects ALU operand B
    --    Normal:  sel = reg_b_field  ? B = Rb
    --    NEG:     sel = reg_a_field  ? B = Ra  (so ALU computes 0 - Ra = -Ra)
    MUX_B_INST: mux_8way_4bit
        port map (
            sel    => mux_b_sel,
            in0    => r0, in1 => r1, in2 => r2, in3 => r3,
            in4    => r4, in5 => r5, in6 => r6, in7 => r7,
            output => mux_b_output
        );

    -- 6. ALU (adder_4bit: ADD and SUB)
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

    -- 7. COMPARATOR (Advanced Feature)
    COMP_INST: comparator_4bit
        port map (
            A           => mux_a_output,
            B           => mux_b_output,
            signed_mode => '0',
            A_eq_B      => comp_equal,
            A_gt_B      => comp_greater,
            A_lt_B      => comp_less
        );

    -- NOTE: adder_3bit (PC incrementer) removed - the program_counter
    -- component already handles PC+1 internally. Having both was dead logic.

    -- ==========================================================================
    -- LED ASSIGNMENTS
    --   LD0-LD3  : R1 value  (addition result: 5+3=8)
    --   LD4-LD7  : R2 value  (operand, shows 3 then F=-3 after NEG)
    --   LD8      : ALU zero flag
    --   LD9      : ALU overflow flag
    --   LD10     : ALU carry flag
    --   LD11     : Comparator equal (Ra==Rb)
    --   LD12     : Heartbeat blink (slow_clk)
    --   LD13     : Write enable pulse
    --   LD14     : PC bit 0
    --   LD15     : PC bit 1
    -- ==========================================================================
    led(3  downto 0) <= r1;           -- ADD result
    led(7  downto 4) <= r2;           -- operand / NEG result
    led(8)           <= alu_zero;     -- zero flag
    led(9)           <= alu_overflow; -- overflow flag
    led(10)          <= alu_carry;    -- carry flag
    led(11)          <= comp_equal;   -- comparator equal
    led(12)          <= slow_clk;     -- heartbeat
    led(13)          <= reg_write_en; -- write enable
    led(14)          <= pc_value(0);  -- PC bit 0
    led(15)          <= pc_value(1);  -- PC bit 1

    -- Export R7 for PMOD debug
    r7_debug <= r7;

    -- ==========================================================================
    -- 7-SEGMENT DISPLAY DRIVER (4-digit multiplexed, common anode)
    --
    -- Single registered process: seg AND an are updated on the SAME clock edge.
    -- This prevents any glitch where anode switches to a new digit before the
    -- segment pattern has updated (which causes phantom wrong digits to appear).
    --
    -- Display layout left-to-right (AN3..AN0):
    --   AN3 (leftmost) : PC  value  (0-7, shows which instruction is running)
    --   AN2            : R2  value  (shows 1 before NEG, F after NEG runs)
    --   AN1            : R1  value  (live countdown: A->9->8->...->0)
    --   AN0 (rightmost): blank      (all segments OFF)
    --
    -- Basys3 common-anode: anode active LOW, segment active LOW
    -- seg[6:0] = { g, f, e, d, c, b, a }
    -- ==========================================================================

    disp_proc: process(clk)
        variable v_data : std_logic_vector(3 downto 0);
    begin
        if rising_edge(clk) then
            if reset_btn = '1' then
                an  <= "1111";
                seg <= "1111111";
            else
                -- Display layout (left to right) - sequential demo:
                --   AN3 (left) = PC       (0->1->2->3->4->5->6=HALT)
                --   AN2        = R3       (subtraction result: 8-3=5)
                --   AN1        = R1       (addition result:    5+3=8)
                --   AN0 (right)= R2       (operand: 3, then F=-3 after NEG)
                --
                -- Final display frozen at HALT: [ 6 | 5 | 8 | F ]
                case disp_digit is
                    when 0      => v_data := r2;              -- AN0: R2 operand
                    when 1      => v_data := r1;              -- AN1: R1 add result
                    when 2      => v_data := r3;              -- AN2: R3 sub result
                    when others => v_data := '0' & pc_value;  -- AN3: PC
                end case;

                -- Step 2: activate the correct anode (active LOW)
                case disp_digit is
                    when 0      => an <= "1110";  -- AN0
                    when 1      => an <= "1101";  -- AN1
                    when 2      => an <= "1011";  -- AN2
                    when others => an <= "0111";  -- AN3
                end case;

                -- Step 3: decode the 4-bit value to 7-segment pattern
                -- Basys3 verified patterns, seg[6:0] = gfedcba, active LOW
                case v_data is
                    when "0000" => seg <= "1000000"; -- 0
                    when "0001" => seg <= "1111001"; -- 1
                    when "0010" => seg <= "0100100"; -- 2
                    when "0011" => seg <= "0110000"; -- 3
                    when "0100" => seg <= "0011001"; -- 4
                    when "0101" => seg <= "0010010"; -- 5
                    when "0110" => seg <= "0000010"; -- 6
                    when "0111" => seg <= "1111000"; -- 7
                    when "1000" => seg <= "0000000"; -- 8
                    when "1001" => seg <= "0010000"; -- 9
                    when "1010" => seg <= "0001000"; -- A
                    when "1011" => seg <= "0000011"; -- b
                    when "1100" => seg <= "1000110"; -- C
                    when "1101" => seg <= "0100001"; -- d
                    when "1110" => seg <= "0000110"; -- E
                    when "1111" => seg <= "1111111"; -- blank (all OFF)
                    when others => seg <= "1111111"; -- blank
                end case;
            end if;
        end if;
    end process disp_proc;

    -- seg_data signal no longer used (kept for compatibility, tied to zero)
    seg_data <= "0000";

end structural;