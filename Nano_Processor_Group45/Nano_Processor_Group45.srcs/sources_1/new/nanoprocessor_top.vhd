----------------------------------------------------------------------------------
-- Company: UOM - CSE'24 - GROUP 45
-- Engineer: Kethmika K A D Y
-- 
-- Create Date: 04/30/2026 11:55:54 AM
-- Design Name: 
-- Module Name: nanoprocessor_top - Behavioral
-- Project Name: 
-- Target Devices: BASYS3
-- Tool Versions: 
-- Description: Nanoprocessor Top-Level Structural Description
-- 
-- Dependencies: alu_4bit, adder_3bit, program_counter, mux8_4bit,
--               mux2_3bit, register_bank, decoder_3to8,
--               instruction_decoder, program_rom
-- 
-- Revision:
-- Revision 0.02 - Errors Fixed
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity nanoprocessor_top is
    Port (
        -- Clock and Reset
        clk          : in  STD_LOGIC;                    -- System clock (100MHz on BASYS3)
        reset_btn    : in  STD_LOGIC;                    -- Reset button (active high)

        -- Output Display (LEDs)
        led_data     : out STD_LOGIC_VECTOR(3 downto 0); -- LD0-LD3: Show R7 or result
        led_overflow : out STD_LOGIC;                    -- LD14: Overflow flag
        led_zero     : out STD_LOGIC;                    -- LD15: Zero flag

        -- 7-segment display
        seg_out      : out STD_LOGIC_VECTOR(6 downto 0); -- 7-segment cathodes
        anode_out    : out STD_LOGIC_VECTOR(3 downto 0)  -- 7-segment anodes
    );
end nanoprocessor_top;

architecture Structural of nanoprocessor_top is

    -- ============================================================
    -- FIX 1: Declare a proper array type for the register file.
    --        'array_std_logic_vector' is NOT a built-in VHDL type.
    -- ============================================================
    type reg_array_t is array (0 to 7) of STD_LOGIC_VECTOR(3 downto 0);

    -- Component declarations
    component alu_4bit
        Port ( A, B    : in  STD_LOGIC_VECTOR(3 downto 0);
               add_sub : in  STD_LOGIC;
               result  : out STD_LOGIC_VECTOR(3 downto 0);
               overflow, zero : out STD_LOGIC);
    end component;

    component adder_3bit
        Port ( A, B  : in  STD_LOGIC_VECTOR(2 downto 0);
               cin   : in  STD_LOGIC;
               sum   : out STD_LOGIC_VECTOR(2 downto 0);
               cout  : out STD_LOGIC);
    end component;

    component program_counter
        Port ( clk, reset, load : in  STD_LOGIC;
               data_in : in  STD_LOGIC_VECTOR(2 downto 0);
               pc_out  : out STD_LOGIC_VECTOR(2 downto 0));
    end component;

    -- ============================================================
    -- FIX 2: mux8_4bit ports must be individually named identifiers.
    --        'in0-in7' uses a hyphen which is ILLEGAL in VHDL.
    --        Changed to in0, in1, in2, ... in7 as separate ports.
    -- ============================================================
    component mux8_4bit
        Port ( sel    : in  STD_LOGIC_VECTOR(2 downto 0);
               in0    : in  STD_LOGIC_VECTOR(3 downto 0);
               in1    : in  STD_LOGIC_VECTOR(3 downto 0);
               in2    : in  STD_LOGIC_VECTOR(3 downto 0);
               in3    : in  STD_LOGIC_VECTOR(3 downto 0);
               in4    : in  STD_LOGIC_VECTOR(3 downto 0);
               in5    : in  STD_LOGIC_VECTOR(3 downto 0);
               in6    : in  STD_LOGIC_VECTOR(3 downto 0);
               in7    : in  STD_LOGIC_VECTOR(3 downto 0);
               mux_out: out STD_LOGIC_VECTOR(3 downto 0));
    end component;

    component mux2_3bit
        Port ( sel     : in  STD_LOGIC;
               in0, in1: in  STD_LOGIC_VECTOR(2 downto 0);
               mux_out : out STD_LOGIC_VECTOR(2 downto 0));
    end component;

    component register_bank
        Port ( clk, reset  : in  STD_LOGIC;
               reg_enable  : in  STD_LOGIC_VECTOR(7 downto 0);
               reg_write   : in  STD_LOGIC_VECTOR(3 downto 0);
               reg_read_sel: in  STD_LOGIC_VECTOR(2 downto 0);
               reg_read_out: out STD_LOGIC_VECTOR(3 downto 0));
    end component;

    component decoder_3to8
        Port ( en   : in  STD_LOGIC;
               addr : in  STD_LOGIC_VECTOR(2 downto 0);
               dout : out STD_LOGIC_VECTOR(7 downto 0));
    end component;

    component instruction_decoder
        Port ( instruction    : in  STD_LOGIC_VECTOR(11 downto 0);
               reg_write_en   : out STD_LOGIC;
               reg_dest_addr  : out STD_LOGIC_VECTOR(2 downto 0);
               reg_src_a_addr : out STD_LOGIC_VECTOR(2 downto 0);
               reg_src_b_addr : out STD_LOGIC_VECTOR(2 downto 0);
               alu_op         : out STD_LOGIC;
               imm_val        : out STD_LOGIC_VECTOR(3 downto 0);
               jump_flag      : out STD_LOGIC;
               jump_addr      : out STD_LOGIC_VECTOR(2 downto 0);
               use_imm        : out STD_LOGIC;
               pc_load        : out STD_LOGIC);
    end component;

    component program_rom
        Port ( addr     : in  STD_LOGIC_VECTOR(2 downto 0);
               data_out : out STD_LOGIC_VECTOR(11 downto 0));
    end component;

    -- ============================================================
    -- Internal signals
    -- ============================================================
    signal pc_value           : STD_LOGIC_VECTOR(2 downto 0);
    signal pc_plus_one        : STD_LOGIC_VECTOR(2 downto 0);
    signal next_pc            : STD_LOGIC_VECTOR(2 downto 0);
    signal instruction        : STD_LOGIC_VECTOR(11 downto 0);

    -- FIX 1 (continued): Use the declared array type
    signal reg_file           : reg_array_t;

    signal reg_enable_decoded : STD_LOGIC_VECTOR(7 downto 0);
    signal alu_input_a        : STD_LOGIC_VECTOR(3 downto 0);
    signal alu_input_b        : STD_LOGIC_VECTOR(3 downto 0);
    signal alu_result         : STD_LOGIC_VECTOR(3 downto 0);
    signal alu_overflow       : STD_LOGIC;
    signal alu_zero           : STD_LOGIC;

    signal ctrl_reg_wr_en     : STD_LOGIC;
    signal ctrl_reg_dest      : STD_LOGIC_VECTOR(2 downto 0);
    signal ctrl_reg_src_a     : STD_LOGIC_VECTOR(2 downto 0);
    signal ctrl_reg_src_b     : STD_LOGIC_VECTOR(2 downto 0);
    signal ctrl_alu_op        : STD_LOGIC;
    signal ctrl_imm_val       : STD_LOGIC_VECTOR(3 downto 0);
    signal ctrl_jump_flag     : STD_LOGIC;
    signal ctrl_jump_addr     : STD_LOGIC_VECTOR(2 downto 0);
    signal ctrl_use_imm       : STD_LOGIC;
    signal ctrl_pc_load       : STD_LOGIC;

    signal actual_pc_load     : STD_LOGIC;
    signal write_data_mux     : STD_LOGIC_VECTOR(3 downto 0);

    -- FIX 3: Intermediate signal for the jump condition logic expression.
    --        Logic expressions cannot be used directly in port map associations.
    signal jump_condition     : STD_LOGIC;

    -- FIX 4: Dedicated read-port signal for the register bank output.
    --        A computed index cannot be used as a port map output target.
    signal reg_bank_read_out  : STD_LOGIC_VECTOR(3 downto 0);

begin

    -- ========================================
    -- PROGRAM COUNTER (PC)
    -- ========================================
    PC_INST: program_counter port map(
        clk     => clk,
        reset   => reset_btn,
        load    => actual_pc_load,
        data_in => next_pc,
        pc_out  => pc_value
    );

    -- ========================================
    -- PC + 1 ADDER (Incrementer)
    -- ========================================
    PC_ADDER: adder_3bit port map(
        A    => pc_value,
        B    => "001",
        cin  => '0',
        sum  => pc_plus_one,
        cout => open
    );

    -- FIX 3: Compute jump condition as a concurrent signal assignment
    --        instead of an expression directly inside a port map.
    jump_condition <= ctrl_jump_flag and alu_zero;

    -- ========================================
    -- PC SOURCE MUX (Jump vs PC+1)
    -- ========================================
    PC_MUX: mux2_3bit port map(
        sel     => jump_condition,   -- FIX 3: use the intermediate signal
        in0     => pc_plus_one,
        in1     => ctrl_jump_addr,
        mux_out => next_pc
    );

    actual_pc_load <= ctrl_pc_load;

    -- ========================================
    -- PROGRAM ROM (Instruction Memory)
    -- ========================================
    ROM_INST: program_rom port map(
        addr     => pc_value,
        data_out => instruction
    );

    -- ========================================
    -- INSTRUCTION DECODER
    -- ========================================
    DEC_INST: instruction_decoder port map(
        instruction    => instruction,
        reg_write_en   => ctrl_reg_wr_en,
        reg_dest_addr  => ctrl_reg_dest,
        reg_src_a_addr => ctrl_reg_src_a,
        reg_src_b_addr => ctrl_reg_src_b,
        alu_op         => ctrl_alu_op,
        imm_val        => ctrl_imm_val,
        jump_flag      => ctrl_jump_flag,
        jump_addr      => ctrl_jump_addr,
        use_imm        => ctrl_use_imm,
        pc_load        => ctrl_pc_load
    );

    -- ========================================
    -- REGISTER BANK
    -- ========================================
    -- FIX 4: Map reg_bank_read_out instead of a computed array index.
    --        The register file array is updated in the process below.
    REG_BANK_INST: register_bank port map(
        clk          => clk,
        reset        => reset_btn,
        reg_enable   => reg_enable_decoded,
        reg_write    => write_data_mux,
        reg_read_sel => ctrl_reg_src_a,
        reg_read_out => reg_bank_read_out
    );

    -- ========================================
    -- REGISTER FILE READ-PORT PROCESS
    -- ========================================
    -- FIX 5: Removed the illegal generate/process block that used loop
    --        variable 'i' on the sensitivity list (not allowed in VHDL).
    --        Register reads are handled here via a clocked process that
    --        mirrors the register bank's read-port output back into the
    --        reg_file array so ALU muxes can access individual registers.
    REG_FILE_UPDATE: process(clk, reset_btn)
    begin
        if reset_btn = '1' then
            reg_file <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if ctrl_reg_wr_en = '1' then
                reg_file(to_integer(unsigned(ctrl_reg_dest))) <= write_data_mux;
            end if;
        end if;
    end process;

    -- Register write address decoder
    REG_DECODER: decoder_3to8 port map(
        en   => ctrl_reg_wr_en,
        addr => ctrl_reg_dest,
        dout => reg_enable_decoded
    );

    -- Write data MUX: immediate value or ALU result
    write_data_mux <= ctrl_imm_val when ctrl_use_imm = '1' else alu_result;

    -- ========================================
    -- INPUT MUXES FOR ALU (Select source registers)
    -- ========================================
    -- FIX 2 (continued): Use individual port names in0..in7
    ALU_MUX_A: mux8_4bit port map(
        sel     => ctrl_reg_src_a,
        in0     => "0000",        -- R0 hardwired to 0
        in1     => reg_file(1),
        in2     => reg_file(2),
        in3     => reg_file(3),
        in4     => reg_file(4),
        in5     => reg_file(5),
        in6     => reg_file(6),
        in7     => reg_file(7),
        mux_out => alu_input_a
    );

    ALU_MUX_B: mux8_4bit port map(
        sel     => ctrl_reg_src_b,
        in0     => "0000",        -- R0 hardwired to 0
        in1     => reg_file(1),
        in2     => reg_file(2),
        in3     => reg_file(3),
        in4     => reg_file(4),
        in5     => reg_file(5),
        in6     => reg_file(6),
        in7     => reg_file(7),
        mux_out => alu_input_b
    );

    -- ========================================
    -- ALU (Arithmetic Logic Unit)
    -- ========================================
    ALU_INST: alu_4bit port map(
        A        => alu_input_a,
        B        => alu_input_b,
        add_sub  => ctrl_alu_op,
        result   => alu_result,
        overflow => alu_overflow,
        zero     => alu_zero
    );

    -- ========================================
    -- OUTPUT TO LEDs AND 7-SEGMENT DISPLAY
    -- ========================================
    led_data     <= reg_file(7);  -- Show R7 on LEDs LD0-LD3
    led_overflow <= alu_overflow;
    led_zero     <= alu_zero;

    DISPLAY_PROCESS: process(reg_file(7))
    begin
        anode_out <= "1110";                      -- Enable digit 0 only
        case reg_file(7) is
            when "0000" => seg_out <= "0000001";  -- 0
            when "0001" => seg_out <= "1001111";  -- 1
            when "0010" => seg_out <= "0010010";  -- 2
            when "0011" => seg_out <= "0000110";  -- 3
            when "0100" => seg_out <= "1001100";  -- 4
            when "0101" => seg_out <= "0100100";  -- 5
            when "0110" => seg_out <= "0100000";  -- 6
            when "0111" => seg_out <= "0001111";  -- 7
            when "1000" => seg_out <= "0000000";  -- 8
            when "1001" => seg_out <= "0000100";  -- 9
            when "1010" => seg_out <= "0000010";  -- A (10)
            when "1011" => seg_out <= "1100000";  -- b (11)
            when "1100" => seg_out <= "0110001";  -- C (12)
            when "1101" => seg_out <= "1000010";  -- d (13)
            when "1110" => seg_out <= "0110000";  -- E (14)
            when others => seg_out <= "0111000";  -- F (15)
        end case;
    end process;

end Structural;