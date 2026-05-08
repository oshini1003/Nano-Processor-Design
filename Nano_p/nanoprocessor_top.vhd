----------------------------------------------------------------------------------
-- Nanoprocessor Top Level (Structural)
-- University of Moratuwa | Team: 240348, 240351, 240347, 240343
--
-- Architecture:
--   ROM → Instruction Decode → Register Bank → ALU → WB
--   PC managed by program_counter with jump logic
--
-- Slow clock: 100 MHz divided to ~0.5 Hz internally
-- Instruction Set:
--   00=ADD RA,RB  01=NEG RA  10=MOVI RA,imm  11=JZR RA,addr
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity nanoprocessor_top is
    Port (
        clk          : in  STD_LOGIC;   -- 100 MHz
        reset_btn    : in  STD_LOGIC;   -- BTNC active high reset

        -- LED outputs
        led          : out STD_LOGIC_VECTOR(7 downto 0);

        -- 7-segment display
        seg_led      : out STD_LOGIC_VECTOR(6 downto 0);  -- a-g (active low)
        anode        : out STD_LOGIC_VECTOR(3 downto 0);  -- active low digit select

        -- Extra debug LEDs (LD14, LD15)
        zero_flag    : out STD_LOGIC;
        ovf_flag     : out STD_LOGIC;

        -- PC debug
        pc_out_debug : out STD_LOGIC_VECTOR(2 downto 0)
    );
end nanoprocessor_top;

architecture Structural of nanoprocessor_top is

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
    -- Clock divider
    signal clk_div    : STD_LOGIC_VECTOR(26 downto 0) := (others => '0');
    signal slow_clk   : STD_LOGIC := '0';

    -- PC
    signal pc_current : STD_LOGIC_VECTOR(2 downto 0);
    signal jump_addr  : STD_LOGIC_VECTOR(2 downto 0);
    signal pc_load    : STD_LOGIC;

    -- Instruction decode
    signal instruction : STD_LOGIC_VECTOR(11 downto 0);
    signal opcode      : STD_LOGIC_VECTOR(1 downto 0);
    signal ra_field    : STD_LOGIC_VECTOR(2 downto 0);
    signal rb_field    : STD_LOGIC_VECTOR(2 downto 0);
    signal imm_field   : STD_LOGIC_VECTOR(3 downto 0);

    -- Register bank
    signal ra_val      : STD_LOGIC_VECTOR(3 downto 0);
    signal rb_val      : STD_LOGIC_VECTOR(3 downto 0);
    signal reg1_data   : STD_LOGIC_VECTOR(3 downto 0);
    signal wb_data     : STD_LOGIC_VECTOR(3 downto 0);
    signal reg_we      : STD_LOGIC;

    -- ALU (adder for ADD/NEG)
    signal alu_b       : STD_LOGIC_VECTOR(3 downto 0);
    signal alu_result  : STD_LOGIC_VECTOR(3 downto 0);
    signal alu_zero    : STD_LOGIC;
    signal alu_ovf     : STD_LOGIC;
    signal alu_carry   : STD_LOGIC;
    signal alu_sub     : STD_LOGIC;

    -- Control signals
    signal is_add      : STD_LOGIC;
    signal is_neg      : STD_LOGIC;
    signal is_movi     : STD_LOGIC;
    signal is_jzr      : STD_LOGIC;
    signal ra_is_zero  : STD_LOGIC;

    -- Unused register outputs
    signal dbg0, dbg2, dbg3, dbg4, dbg5, dbg6, dbg7 : STD_LOGIC_VECTOR(3 downto 0);

begin

    -------------------------------------------------------------------
    -- Clock Divider: 100 MHz → ~0.762 Hz (2^27 / 100e6)
    -- Adjust threshold for exact ~0.5 Hz:  100_000_000 / 2 = 50_000_000
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
    -- Instruction Decode (combinational)
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

    -------------------------------------------------------------------
    -- Control: register write enable
    -- ADD: writes RA  |  NEG: writes RA  |  MOVI: writes RA  |  JZR: no write
    -------------------------------------------------------------------
    reg_we <= is_add OR is_neg OR is_movi;

    -------------------------------------------------------------------
    -- ALU B input: NEG uses 0000 (so result = 0 - RA), ADD uses RB
    -------------------------------------------------------------------
    alu_b   <= "0000" when is_neg = '1' else rb_val;
    alu_sub <= is_neg;   -- NEG = subtract (0 - RA)

    -------------------------------------------------------------------
    -- Write-back data mux
    -- ADD/NEG → alu_result
    -- MOVI    → imm_field
    -------------------------------------------------------------------
    wb_data <= imm_field  when is_movi = '1' else alu_result;

    -------------------------------------------------------------------
    -- Jump logic: JZR — jump if RA = 0
    -------------------------------------------------------------------
    ra_is_zero <= '1' when ra_val = "0000" else '0';
    pc_load    <= is_jzr AND ra_is_zero;

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
    -- Output assignments
    -------------------------------------------------------------------
    -- LD3-0: R1 register (countdown value)
    led(3 downto 0) <= reg1_data;
    -- LD4: Zero flag
    led(4) <= alu_zero;
    -- LD5: Overflow flag
    led(5) <= alu_ovf;
    -- LD6: PC bit 1
    led(6) <= pc_current(1);
    -- LD7: PC bit 2
    led(7) <= pc_current(2);

    -- Extra debug LEDs
    zero_flag <= alu_zero;
    ovf_flag  <= alu_ovf;

    -- PC debug
    pc_out_debug <= pc_current;

    -- Only rightmost digit active (anode active low on Basys3)
    anode <= "1110";

    -- 7-segment: display PC value 0–7 (active low segments, common anode)
    process(pc_current)
    begin
        case pc_current is
            --              abcdefg  (active low)
            when "000" => seg_led <= "1000000";  -- 0
            when "001" => seg_led <= "1111001";  -- 1
            when "010" => seg_led <= "0100100";  -- 2
            when "011" => seg_led <= "0110000";  -- 3
            when "100" => seg_led <= "0011001";  -- 4
            when "101" => seg_led <= "0010010";  -- 5
            when "110" => seg_led <= "0000010";  -- 6
            when "111" => seg_led <= "1111000";  -- 7
            when others => seg_led <= "1111111"; -- blank
        end case;
    end process;

end Structural;
