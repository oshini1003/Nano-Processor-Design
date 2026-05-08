----------------------------------------------------------------------------------
-- Nanoprocessor Top Level — VISIBLE Demo Version
-- University of Moratuwa | Team: 240348, 240351, 240347, 240343
--
-- Same as nanoprocessor_top but with enhanced 7-segment display showing
-- current instruction opcode on left digit and PC on right digit.
-- Adds a "step" LED that pulses every instruction cycle.
-- Runs at ~0.5 Hz for visible instruction execution on hardware.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity nanoprocessor_top_VISIBLE is
    Port (
        clk          : in  STD_LOGIC;    -- 100 MHz onboard
        reset_btn    : in  STD_LOGIC;    -- BTNC

        -- LEDs
        led          : out STD_LOGIC_VECTOR(15 downto 0);

        -- 7-segment (4-digit, active-low common anode Basys3)
        seg_led      : out STD_LOGIC_VECTOR(6 downto 0);
        anode        : out STD_LOGIC_VECTOR(3 downto 0);

        -- Dedicated debug
        zero_flag    : out STD_LOGIC;
        ovf_flag     : out STD_LOGIC;
        pc_out_debug : out STD_LOGIC_VECTOR(2 downto 0)
    );
end nanoprocessor_top_VISIBLE;

architecture Behavioral of nanoprocessor_top_VISIBLE is

    -------------------------------------------------------------------
    -- Component declarations
    -------------------------------------------------------------------
    component program_counter
        Port (
            clk    : in  STD_LOGIC;
            reset  : in  STD_LOGIC;
            enable : in  STD_LOGIC;
            load   : in  STD_LOGIC;
            pc_in  : in  STD_LOGIC_VECTOR(2 downto 0);
            pc_out : out STD_LOGIC_VECTOR(2 downto 0)
        );
    end component;

    component program_rom
        Port (
            address  : in  STD_LOGIC_VECTOR(2 downto 0);
            data_out : out STD_LOGIC_VECTOR(11 downto 0)
        );
    end component;

    component register_bank
        Port (
            clk      : in  STD_LOGIC;
            reset    : in  STD_LOGIC;
            write_en : in  STD_LOGIC;
            reg_sel  : in  STD_LOGIC_VECTOR(2 downto 0);
            data_in  : in  STD_LOGIC_VECTOR(3 downto 0);
            ra_sel   : in  STD_LOGIC_VECTOR(2 downto 0);
            rb_sel   : in  STD_LOGIC_VECTOR(2 downto 0);
            ra_out   : out STD_LOGIC_VECTOR(3 downto 0);
            rb_out   : out STD_LOGIC_VECTOR(3 downto 0);
            reg0_out : out STD_LOGIC_VECTOR(3 downto 0);
            reg1_out : out STD_LOGIC_VECTOR(3 downto 0);
            reg2_out : out STD_LOGIC_VECTOR(3 downto 0);
            reg3_out : out STD_LOGIC_VECTOR(3 downto 0);
            reg4_out : out STD_LOGIC_VECTOR(3 downto 0);
            reg5_out : out STD_LOGIC_VECTOR(3 downto 0);
            reg6_out : out STD_LOGIC_VECTOR(3 downto 0);
            reg7_out : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    component adder_4bit
        Port (
            A        : in  STD_LOGIC_VECTOR(3 downto 0);
            B        : in  STD_LOGIC_VECTOR(3 downto 0);
            sub      : in  STD_LOGIC;
            result   : out STD_LOGIC_VECTOR(3 downto 0);
            zero     : out STD_LOGIC;
            overflow : out STD_LOGIC;
            carry    : out STD_LOGIC
        );
    end component;

    -------------------------------------------------------------------
    -- Internal signals
    -------------------------------------------------------------------
    signal clk_div   : STD_LOGIC_VECTOR(26 downto 0) := (others => '0');
    signal slow_clk  : STD_LOGIC := '0';

    -- 7-seg multiplexing counter
    signal seg_ctr   : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal seg_digit : STD_LOGIC_VECTOR(1 downto 0) := "00";

    -- PC
    signal pc_current : STD_LOGIC_VECTOR(2 downto 0);
    signal jump_addr  : STD_LOGIC_VECTOR(2 downto 0);
    signal pc_load    : STD_LOGIC;

    -- Instruction
    signal instruction : STD_LOGIC_VECTOR(11 downto 0);
    signal opcode      : STD_LOGIC_VECTOR(1 downto 0);
    signal ra_field    : STD_LOGIC_VECTOR(2 downto 0);
    signal rb_field    : STD_LOGIC_VECTOR(2 downto 0);
    signal imm_field   : STD_LOGIC_VECTOR(3 downto 0);

    -- Registers
    signal ra_val     : STD_LOGIC_VECTOR(3 downto 0);
    signal rb_val     : STD_LOGIC_VECTOR(3 downto 0);
    signal reg1_data  : STD_LOGIC_VECTOR(3 downto 0);
    signal wb_data    : STD_LOGIC_VECTOR(3 downto 0);
    signal reg_we     : STD_LOGIC;

    -- ALU
    signal alu_b      : STD_LOGIC_VECTOR(3 downto 0);
    signal alu_result : STD_LOGIC_VECTOR(3 downto 0);
    signal alu_zero   : STD_LOGIC;
    signal alu_ovf    : STD_LOGIC;
    signal alu_carry  : STD_LOGIC;
    signal alu_sub    : STD_LOGIC;

    -- Decode
    signal is_add     : STD_LOGIC;
    signal is_neg     : STD_LOGIC;
    signal is_movi    : STD_LOGIC;
    signal is_jzr     : STD_LOGIC;
    signal ra_is_zero : STD_LOGIC;

    -- Debug reg outputs (unused in LED, just to connect)
    signal dbg0, dbg2, dbg3, dbg4, dbg5, dbg6, dbg7 : STD_LOGIC_VECTOR(3 downto 0);

    -- 7-seg digit encoding (helper function result)
    signal seg_pc   : STD_LOGIC_VECTOR(6 downto 0);
    signal seg_op   : STD_LOGIC_VECTOR(6 downto 0);
    signal seg_r1_h : STD_LOGIC_VECTOR(6 downto 0); -- R1 high nibble (always 0 for 4-bit)
    signal seg_r1_l : STD_LOGIC_VECTOR(6 downto 0); -- R1 low nibble

begin

    -------------------------------------------------------------------
    -- Slow clock: 100 MHz → ~0.5 Hz
    -------------------------------------------------------------------
    process(clk, reset_btn)
    begin
        if reset_btn = '1' then
            clk_div  <= (others => '0');
            slow_clk <= '0';
        elsif rising_edge(clk) then
            if clk_div = 49999999 then
                clk_div  <= (others => '0');
                slow_clk <= NOT slow_clk;
            else
                clk_div <= clk_div + 1;
            end if;
        end if;
    end process;

    -------------------------------------------------------------------
    -- Instruction decode
    -------------------------------------------------------------------
    opcode    <= instruction(11 downto 10);
    ra_field  <= instruction(9 downto 7);
    rb_field  <= instruction(6 downto 4);
    imm_field <= instruction(3 downto 0);
    jump_addr <= instruction(2 downto 0);

    is_add  <= '1' when opcode = "00" else '0';
    is_neg  <= '1' when opcode = "01" else '0';
    is_movi <= '1' when opcode = "10" else '0';
    is_jzr  <= '1' when opcode = "11" else '0';

    reg_we    <= is_add OR is_neg OR is_movi;
    alu_b     <= "0000" when is_neg = '1' else rb_val;
    alu_sub   <= is_neg;
    wb_data   <= imm_field when is_movi = '1' else alu_result;
    ra_is_zero <= '1' when ra_val = "0000" else '0';
    pc_load   <= is_jzr AND ra_is_zero;

    -------------------------------------------------------------------
    -- Component instantiations
    -------------------------------------------------------------------
    U_PC : program_counter
        port map (
            clk    => slow_clk,
            reset  => reset_btn,
            enable => '1',
            load   => pc_load,
            pc_in  => jump_addr,
            pc_out => pc_current
        );

    U_ROM : program_rom
        port map (
            address  => pc_current,
            data_out => instruction
        );

    U_REGS : register_bank
        port map (
            clk      => slow_clk,
            reset    => reset_btn,
            write_en => reg_we,
            reg_sel  => ra_field,
            data_in  => wb_data,
            ra_sel   => ra_field,
            rb_sel   => rb_field,
            ra_out   => ra_val,
            rb_out   => rb_val,
            reg0_out => dbg0,
            reg1_out => reg1_data,
            reg2_out => dbg2,
            reg3_out => dbg3,
            reg4_out => dbg4,
            reg5_out => dbg5,
            reg6_out => dbg6,
            reg7_out => dbg7
        );

    U_ALU : adder_4bit
        port map (
            A        => ra_val,
            B        => alu_b,
            sub      => alu_sub,
            result   => alu_result,
            zero     => alu_zero,
            overflow => alu_ovf,
            carry    => alu_carry
        );

    -------------------------------------------------------------------
    -- LED assignments (16 LEDs on Basys3)
    -- LD3-0  : R1 value (countdown)
    -- LD4    : Zero flag
    -- LD5    : Overflow flag
    -- LD6    : PC[1]
    -- LD7    : PC[2]
    -- LD8    : slow_clk heartbeat
    -- LD11-9 : PC full value
    -- LD13-12: opcode
    -- LD14   : zero flag (duplicate for visibility)
    -- LD15   : overflow flag (duplicate for visibility)
    -------------------------------------------------------------------
    led(3 downto 0)   <= reg1_data;
    led(4)            <= alu_zero;
    led(5)            <= alu_ovf;
    led(6)            <= pc_current(1);
    led(7)            <= pc_current(2);
    led(8)            <= slow_clk;           -- heartbeat
    led(11 downto 9)  <= pc_current;
    led(13 downto 12) <= opcode;
    led(14)           <= alu_zero;
    led(15)           <= alu_ovf;

    zero_flag    <= alu_zero;
    ovf_flag     <= alu_ovf;
    pc_out_debug <= pc_current;

    -------------------------------------------------------------------
    -- 7-segment digit ROM (common anode, active low)
    -- Digit 0 (rightmost): PC value  0-7
    -- Digit 1: opcode letter index  0-3
    -- Digit 2: R1 value units digit (decimal is shown as hex 0-F)
    -- Digit 3: R1 high nibble (always 0 for 4-bit processor)
    -------------------------------------------------------------------

    -- PC digit
    process(pc_current)
    begin
        case pc_current is
            when "000" => seg_pc <= "1000000"; -- 0
            when "001" => seg_pc <= "1111001"; -- 1
            when "010" => seg_pc <= "0100100"; -- 2
            when "011" => seg_pc <= "0110000"; -- 3
            when "100" => seg_pc <= "0011001"; -- 4
            when "101" => seg_pc <= "0010010"; -- 5
            when "110" => seg_pc <= "0000010"; -- 6
            when "111" => seg_pc <= "1111000"; -- 7
            when others => seg_pc <= "1111111";
        end case;
    end process;

    -- Opcode digit: A=ADD E=NEG I=MOVI J=JZR (approximate 7-seg glyphs)
    process(opcode)
    begin
        case opcode is
            when "00" => seg_op <= "0001000"; -- A (ADD)
            when "01" => seg_op <= "0000110"; -- E (NEG)
            when "10" => seg_op <= "0001111"; -- I-like (MOVI)
            when "11" => seg_op <= "1110001"; -- J (JZR)
            when others => seg_op <= "1111111";
        end case;
    end process;

    -- R1 value as hex digit (lower nibble)
    process(reg1_data)
    begin
        case reg1_data is
            when "0000" => seg_r1_l <= "1000000"; -- 0
            when "0001" => seg_r1_l <= "1111001"; -- 1
            when "0010" => seg_r1_l <= "0100100"; -- 2
            when "0011" => seg_r1_l <= "0110000"; -- 3
            when "0100" => seg_r1_l <= "0011001"; -- 4
            when "0101" => seg_r1_l <= "0010010"; -- 5
            when "0110" => seg_r1_l <= "0000010"; -- 6
            when "0111" => seg_r1_l <= "1111000"; -- 7
            when "1000" => seg_r1_l <= "0000000"; -- 8
            when "1001" => seg_r1_l <= "0010000"; -- 9
            when "1010" => seg_r1_l <= "0001000"; -- A (10)
            when "1011" => seg_r1_l <= "0000011"; -- b (11)
            when "1100" => seg_r1_l <= "1000110"; -- C (12)
            when "1101" => seg_r1_l <= "0100001"; -- d (13)
            when "1110" => seg_r1_l <= "0000110"; -- E (14)
            when "1111" => seg_r1_l <= "0001110"; -- F (15)
            when others => seg_r1_l <= "1111111";
        end case;
    end process;

    seg_r1_h <= "1000000"; -- Always "0" (high nibble of 4-bit register)

    -------------------------------------------------------------------
    -- 7-seg multiplexer: cycle through 4 digits at ~1 kHz
    -- Using fast clock (100 MHz / 65536 ≈ 1526 Hz refresh)
    -------------------------------------------------------------------
    process(clk, reset_btn)
    begin
        if reset_btn = '1' then
            seg_ctr   <= (others => '0');
            seg_digit <= "00";
        elsif rising_edge(clk) then
            seg_ctr <= seg_ctr + 1;
            if seg_ctr = 0 then
                if seg_digit = "11" then
                    seg_digit <= "00";
                else
                    seg_digit <= seg_digit + 1;
                end if;
            end if;
        end if;
    end process;

    -- Mux segments and anodes
    process(seg_digit, seg_pc, seg_op, seg_r1_l, seg_r1_h)
    begin
        case seg_digit is
            when "00" =>
                anode   <= "1110";   -- Digit 0 (rightmost): PC
                seg_led <= seg_pc;
            when "01" =>
                anode   <= "1101";   -- Digit 1: opcode glyph
                seg_led <= seg_op;
            when "10" =>
                anode   <= "1011";   -- Digit 2: R1 low nibble
                seg_led <= seg_r1_l;
            when "11" =>
                anode   <= "0111";   -- Digit 3: R1 high nibble
                seg_led <= seg_r1_h;
            when others =>
                anode   <= "1111";
                seg_led <= "1111111";
        end case;
    end process;

end Behavioral;
