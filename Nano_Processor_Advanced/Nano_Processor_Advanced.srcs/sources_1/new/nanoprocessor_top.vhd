----------------------------------------------------------------------------------
-- Company  : UOM - CSE'24 - GROUP 45
-- Module   : nanoprocessor_top  (v2.0 — Full ISA)
-- Board    : Digilent Basys 3 (Artix-7 XC7A35T-1CPG236C)
-- Clock    : 100 MHz → divided to ~1 Hz for visual observation
--
-- 3-bit opcode ISA (12-bit instructions):
--   [11:9]=op  [8:6]=RA  [5:3]=RB  [3:0]=imm4(MOVI) / [2:0]=addr(JZR)
--
--   000 ADD Ra,Rb   Ra ← Ra + Rb   (flags: Z,C,Ovf)
--   001 SUB Ra,Rb   Ra ← Ra - Rb   (flags: Z,C,Ovf)
--   010 AND Ra,Rb   Ra ← Ra AND Rb
--   011 OR  Ra,Rb   Ra ← Ra OR  Rb
--   100 XOR Ra,Rb   Ra ← Ra XOR Rb
--   101 SHL/SHR Ra  RB[0]=0→SHL, RB[0]=1→SHR
--   110 MOVI Ra,d   Ra ← d[3:0]
--   111 JZR Ra,addr PC ← addr if Ra==0
--
-- FIXES from v1.0:
--   * 3-bit opcode (was 2-bit) → 8 instructions
--   * Full ALU (was just adder): AND, OR, XOR, SHL, SHR added
--   * SUB is proper Ra−Rb (was NEG = 0−Ra)
--   * Comparator flags now drive LED output (were floating)
--   * Removed unused adder_3bit instantiation (pc_incremented was dead)
--   * Removed unused mux_2way_3bit component
--   * 4-digit 7-seg: PC digit + R1 hex digit + flags
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity nanoprocessor_top is
    port (
        clk       : in  std_logic;                     -- W5: 100 MHz
        reset_btn : in  std_logic;                     -- C12: CPU reset (active high)
        led       : out std_logic_vector(15 downto 0); -- LD0-LD15
        seg       : out std_logic_vector(6 downto 0);  -- a-g segments (active low)
        an        : out std_logic_vector(3 downto 0);  -- digit enables (active low)
        pc_debug  : out std_logic_vector(2 downto 0);  -- PC for debug scope
        r1_debug  : out std_logic_vector(3 downto 0)   -- R1 for debug scope
    );
end nanoprocessor_top;

architecture structural of nanoprocessor_top is

    -- =========================================================================
    -- COMPONENT DECLARATIONS
    -- =========================================================================

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

    component alu_4bit is
        port (
            A       : in  std_logic_vector(3 downto 0);
            B       : in  std_logic_vector(3 downto 0);
            op      : in  std_logic_vector(2 downto 0);
            shift_r : in  std_logic;
            Result  : out std_logic_vector(3 downto 0);
            Zero    : out std_logic;
            Carry   : out std_logic;
            Ovf     : out std_logic
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

    -- =========================================================================
    -- INTERNAL SIGNALS
    -- =========================================================================

    -- Clock divider: 100 MHz → 1 Hz (toggle every 50 M cycles)
    signal slow_clk    : std_logic := '0';
    signal clk_counter : natural range 0 to 99999999 := 0;

    -- Program counter
    signal pc_value    : std_logic_vector(2 downto 0) := "000";
    signal pc_load     : std_logic;
    signal pc_jump_addr: std_logic_vector(2 downto 0);

    -- Instruction bus
    signal instruction  : std_logic_vector(11 downto 0);

    -- Decoded fields (new 3-bit opcode layout)
    signal opcode       : std_logic_vector(2 downto 0);  -- [11:9]
    signal reg_a_field  : std_logic_vector(2 downto 0);  -- [8:6]  RA
    signal reg_b_field  : std_logic_vector(2 downto 0);  -- [5:3]  RB
    signal immediate_val: std_logic_vector(3 downto 0);  -- [3:0]  imm4 (MOVI)
    signal jump_addr    : std_logic_vector(2 downto 0);  -- [2:0]  addr (JZR)

    -- Register bank outputs
    signal r0,r1,r2,r3,r4,r5,r6,r7 : std_logic_vector(3 downto 0);

    -- Register write-back
    signal reg_write_en  : std_logic;
    signal reg_write_data: std_logic_vector(3 downto 0);

    -- MUX outputs → ALU operands
    signal mux_a_out : std_logic_vector(3 downto 0);
    signal mux_b_out : std_logic_vector(3 downto 0);

    -- ALU outputs
    signal alu_result : std_logic_vector(3 downto 0);
    signal alu_zero   : std_logic;
    signal alu_carry  : std_logic;
    signal alu_ovf    : std_logic;

    -- Shift direction: LSB of RB field (instruction bit 3)
    signal shift_dir  : std_logic;

    -- Comparator outputs (shown on LEDs)
    signal comp_eq    : std_logic;
    signal comp_gt    : std_logic;
    signal comp_lt    : std_logic;

    -- 7-segment display multiplexer state
    signal seg_refresh : std_logic_vector(1 downto 0) := "00";
    signal seg_counter : natural range 0 to 99999 := 0;   -- ~1 kHz refresh
    signal seg_data    : std_logic_vector(3 downto 0);

begin

    -- =========================================================================
    -- CLOCK DIVIDER: 100 MHz → 1 Hz slow_clk (one instruction per second)
    -- =========================================================================
    process(clk)
    begin
        if rising_edge(clk) then
            if reset_btn = '1' then
                clk_counter <= 0;
                slow_clk    <= '0';
            elsif clk_counter = 49999999 then
                clk_counter <= 0;
                slow_clk    <= not slow_clk;
            else
                clk_counter <= clk_counter + 1;
            end if;
        end if;
    end process;

    -- =========================================================================
    -- INSTRUCTION DECODE (3-bit opcode)
    -- =========================================================================
    opcode        <= instruction(11 downto 9);
    reg_a_field   <= instruction(8  downto 6);
    reg_b_field   <= instruction(5  downto 3);
    immediate_val <= instruction(3  downto 0);   -- 4-bit imm for MOVI
    jump_addr     <= instruction(2  downto 0);   -- 3-bit addr for JZR
    shift_dir     <= reg_b_field(0);             -- RB[0]: 0=SHL, 1=SHR

    -- =========================================================================
    -- CONTROL UNIT
    -- =========================================================================
    control_proc: process(opcode, alu_zero, jump_addr)
    begin
        -- Defaults
        reg_write_en  <= '0';
        pc_load       <= '0';
        pc_jump_addr  <= jump_addr;

        case opcode is
            when "000" =>   -- ADD Ra, Rb
                reg_write_en <= '1';
            when "001" =>   -- SUB Ra, Rb
                reg_write_en <= '1';
            when "010" =>   -- AND Ra, Rb
                reg_write_en <= '1';
            when "011" =>   -- OR  Ra, Rb
                reg_write_en <= '1';
            when "100" =>   -- XOR Ra, Rb
                reg_write_en <= '1';
            when "101" =>   -- SHL/SHR Ra  (shift direction from shift_dir)
                reg_write_en <= '1';
            when "110" =>   -- MOVI Ra, imm4
                reg_write_en <= '1';
            when "111" =>   -- JZR Ra, addr
                if alu_zero = '1' then
                    pc_load <= '1';
                end if;
            when others =>
                null;
        end case;
    end process;

    -- =========================================================================
    -- WRITE-BACK MUX: MOVI bypasses ALU; all other ops use ALU result
    -- =========================================================================
    reg_write_data <= immediate_val when opcode = "110" else alu_result;

    -- =========================================================================
    -- COMPONENT INSTANTIATIONS
    -- =========================================================================

    -- 1. Program Counter
    PC_INST: program_counter
        port map (
            clk    => slow_clk,
            reset  => reset_btn,
            enable => '1',
            load   => pc_load,
            input  => pc_jump_addr,
            output => pc_value
        );

    -- 2. Program ROM
    ROM_INST: program_rom
        port map (
            address => pc_value,
            data    => instruction
        );

    -- 3. Register Bank
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

    -- 4. MUX-A: operand A (reads RA field — accumulator model)
    MUX_A_INST: mux_8way_4bit
        port map (
            sel => reg_a_field,
            in0 => r0, in1 => r1, in2 => r2, in3 => r3,
            in4 => r4, in5 => r5, in6 => r6, in7 => r7,
            output => mux_a_out
        );

    -- 5. MUX-B: operand B (reads RB field)
    MUX_B_INST: mux_8way_4bit
        port map (
            sel => reg_b_field,
            in0 => r0, in1 => r1, in2 => r2, in3 => r3,
            in4 => r4, in5 => r5, in6 => r6, in7 => r7,
            output => mux_b_out
        );

    -- 6. Full ALU (NEW: replaces bare adder_4bit)
    ALU_INST: alu_4bit
        port map (
            A       => mux_a_out,
            B       => mux_b_out,
            op      => opcode,
            shift_r => shift_dir,
            Result  => alu_result,
            Zero    => alu_zero,
            Carry   => alu_carry,
            Ovf     => alu_ovf
        );

    -- 7. Comparator (structural gate-level, runs in parallel with ALU)
    COMP_INST: comparator_4bit
        port map (
            A           => mux_a_out,
            B           => mux_b_out,
            signed_mode => '0',
            A_eq_B      => comp_eq,
            A_gt_B      => comp_gt,
            A_lt_B      => comp_lt
        );

    -- Debug outputs
    pc_debug <= pc_value;
    r1_debug <= r1;

    -- =========================================================================
    -- LED ASSIGNMENTS (LD0-LD15)
    -- LD0-LD3  : R1 (main working register)
    -- LD4      : Zero flag
    -- LD5      : Carry flag
    -- LD6      : Overflow flag
    -- LD7      : Comparator Equal (A==B)
    -- LD8      : Comparator Greater (A>B)
    -- LD9      : Comparator Less    (A<B)
    -- LD10     : slow_clk heartbeat (blinks at 1 Hz)
    -- LD11     : reg_write_en (pulses when register written)
    -- LD12-LD15: R2 (secondary register)
    -- =========================================================================
    led(3  downto 0) <= r1;
    led(4)           <= alu_zero;
    led(5)           <= alu_carry;
    led(6)           <= alu_ovf;
    led(7)           <= comp_eq;
    led(8)           <= comp_gt;
    led(9)           <= comp_lt;
    led(10)          <= slow_clk;
    led(11)          <= reg_write_en;
    led(15 downto 12)<= r2;

    -- =========================================================================
    -- 7-SEGMENT DISPLAY (4 digits, multiplexed at ~1 kHz)
    --
    -- Digit 3 (leftmost)  : opcode hex nibble (0-7)
    -- Digit 2             : R2 lower nibble
    -- Digit 1             : R1 lower nibble (active result)
    -- Digit 0 (rightmost) : PC value (0-7)
    -- =========================================================================

    -- Segment refresh counter: divide 100 MHz → ~1 kHz per digit
    process(clk)
    begin
        if rising_edge(clk) then
            if reset_btn = '1' then
                seg_counter <= 0;
                seg_refresh <= "00";
            elsif seg_counter = 24999 then   -- 100MHz/25000=4kHz → /4 digits = 1kHz each
                seg_counter <= 0;
                seg_refresh <= std_logic_vector(unsigned(seg_refresh) + 1);
            else
                seg_counter <= seg_counter + 1;
            end if;
        end if;
    end process;

    -- Digit select and data mux
    process(seg_refresh, pc_value, r1, r2, opcode)
    begin
        case seg_refresh is
            when "00" =>   -- Digit 0: PC value
                an       <= "1110";
                seg_data <= "0" & pc_value;
            when "01" =>   -- Digit 1: R1 (result register)
                an       <= "1101";
                seg_data <= r1;
            when "10" =>   -- Digit 2: R2
                an       <= "1011";
                seg_data <= r2;
            when others => -- Digit 3: current opcode
                an       <= "0111";
                seg_data <= "0" & opcode;
        end case;
    end process;

    -- 7-segment decoder (common anode: segment active LOW)
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
            when "1010" => seg <= "0000010";  -- A
            when "1011" => seg <= "1100000";  -- b
            when "1100" => seg <= "0110001";  -- C
            when "1101" => seg <= "1000010";  -- d
            when "1110" => seg <= "0110000";  -- E
            when "1111" => seg <= "0111000";  -- F
            when others => seg <= "1111111";  -- blank
        end case;
    end process;

end structural;
