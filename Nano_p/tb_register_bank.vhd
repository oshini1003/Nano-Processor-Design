----------------------------------------------------------------------------------
-- Register Bank Testbench (VHDL-93 Compatible)
-- University of Moratuwa | Team: 240348, 240351, 240347, 240343
--
-- Verifies:
--   1. R0 is always 0 (cannot be written)
--   2. Write & read back for all R1–R7
--   3. Synchronous write on rising edge of clock
--   4. Async reset clears R1–R7 to 0
--   5. Simultaneous read of RA and RB
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_register_bank is
end tb_register_bank;

architecture Behavioral of tb_register_bank is

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

    constant CLK_PERIOD : time := 20 ns;  -- 50 MHz test clock

    signal clk      : STD_LOGIC := '0';
    signal reset    : STD_LOGIC := '1';
    signal write_en : STD_LOGIC := '0';
    signal reg_sel  : STD_LOGIC_VECTOR(2 downto 0) := "000";
    signal data_in  : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal ra_sel   : STD_LOGIC_VECTOR(2 downto 0) := "000";
    signal rb_sel   : STD_LOGIC_VECTOR(2 downto 0) := "000";
    signal ra_out   : STD_LOGIC_VECTOR(3 downto 0);
    signal rb_out   : STD_LOGIC_VECTOR(3 downto 0);
    signal reg0_out : STD_LOGIC_VECTOR(3 downto 0);
    signal reg1_out : STD_LOGIC_VECTOR(3 downto 0);
    signal reg2_out : STD_LOGIC_VECTOR(3 downto 0);
    signal reg3_out : STD_LOGIC_VECTOR(3 downto 0);
    signal reg4_out : STD_LOGIC_VECTOR(3 downto 0);
    signal reg5_out : STD_LOGIC_VECTOR(3 downto 0);
    signal reg6_out : STD_LOGIC_VECTOR(3 downto 0);
    signal reg7_out : STD_LOGIC_VECTOR(3 downto 0);

    -- Helper procedure: write a value to a register, then check it
    procedure write_and_check (
        signal   clk_s    : in  STD_LOGIC;
        signal   we_s     : out STD_LOGIC;
        signal   sel_s    : out STD_LOGIC_VECTOR(2 downto 0);
        signal   din_s    : out STD_LOGIC_VECTOR(3 downto 0);
        signal   ra_s     : out STD_LOGIC_VECTOR(2 downto 0);
        signal   ra_out_s : in  STD_LOGIC_VECTOR(3 downto 0);
        constant reg_id   : in  STD_LOGIC_VECTOR(2 downto 0);
        constant value    : in  STD_LOGIC_VECTOR(3 downto 0)
    ) is
    begin
        we_s  <= '1';
        sel_s <= reg_id;
        din_s <= value;
        ra_s  <= reg_id;
        wait until rising_edge(clk_s);
        wait for 1 ns;
        we_s  <= '0';
        assert ra_out_s = value
            report "Write/readback failed for reg " &
                   integer'image(conv_integer(reg_id))
            severity ERROR;
    end procedure;

begin

    -- Clock generator
    clk <= NOT clk after CLK_PERIOD / 2;

    UUT: register_bank
        port map (
            clk      => clk,
            reset    => reset,
            write_en => write_en,
            reg_sel  => reg_sel,
            data_in  => data_in,
            ra_sel   => ra_sel,
            rb_sel   => rb_sel,
            ra_out   => ra_out,
            rb_out   => rb_out,
            reg0_out => reg0_out,
            reg1_out => reg1_out,
            reg2_out => reg2_out,
            reg3_out => reg3_out,
            reg4_out => reg4_out,
            reg5_out => reg5_out,
            reg6_out => reg6_out,
            reg7_out => reg7_out
        );

    stimulus: process
    begin
        -------------------------------------------------------
        -- 1. Apply reset, verify all registers are 0
        -------------------------------------------------------
        reset    <= '1';
        write_en <= '0';
        wait for CLK_PERIOD * 3;
        reset <= '0';
        wait for CLK_PERIOD;

        assert reg0_out = "0000" report "Reset: R0 not 0" severity ERROR;
        assert reg1_out = "0000" report "Reset: R1 not 0" severity ERROR;
        assert reg2_out = "0000" report "Reset: R2 not 0" severity ERROR;
        assert reg3_out = "0000" report "Reset: R3 not 0" severity ERROR;
        assert reg4_out = "0000" report "Reset: R4 not 0" severity ERROR;
        assert reg5_out = "0000" report "Reset: R5 not 0" severity ERROR;
        assert reg6_out = "0000" report "Reset: R6 not 0" severity ERROR;
        assert reg7_out = "0000" report "Reset: R7 not 0" severity ERROR;

        -------------------------------------------------------
        -- 2. Attempt to write R0 — must stay 0
        -------------------------------------------------------
        write_en <= '1';
        reg_sel  <= "000";
        data_in  <= "1111";
        ra_sel   <= "000";
        wait until rising_edge(clk);
        wait for 1 ns;
        write_en <= '0';
        assert reg0_out = "0000" report "FAIL: R0 was written (should be read-only)" severity ERROR;
        assert ra_out   = "0000" report "FAIL: R0 read not 0" severity ERROR;

        -------------------------------------------------------
        -- 3. Write unique values to R1–R7 and read back
        -------------------------------------------------------
        write_and_check(clk, write_en, reg_sel, data_in, ra_sel, ra_out, "001", "1010");
        write_and_check(clk, write_en, reg_sel, data_in, ra_sel, ra_out, "010", "0110");
        write_and_check(clk, write_en, reg_sel, data_in, ra_sel, ra_out, "011", "1100");
        write_and_check(clk, write_en, reg_sel, data_in, ra_sel, ra_out, "100", "0011");
        write_and_check(clk, write_en, reg_sel, data_in, ra_sel, ra_out, "101", "1110");
        write_and_check(clk, write_en, reg_sel, data_in, ra_sel, ra_out, "110", "0001");
        write_and_check(clk, write_en, reg_sel, data_in, ra_sel, ra_out, "111", "1111");

        -------------------------------------------------------
        -- 4. Simultaneous dual read (RA=R1, RB=R7)
        -------------------------------------------------------
        ra_sel <= "001";
        rb_sel <= "111";
        wait for 5 ns;
        assert ra_out = "1010" report "Dual read: RA (R1) wrong" severity ERROR;
        assert rb_out = "1111" report "Dual read: RB (R7) wrong" severity ERROR;

        -------------------------------------------------------
        -- 5. Async reset mid-operation clears all
        -------------------------------------------------------
        reset <= '1';
        wait for 5 ns;
        assert reg1_out = "0000" report "Async reset: R1 not cleared" severity ERROR;
        assert reg7_out = "0000" report "Async reset: R7 not cleared" severity ERROR;
        reset <= '0';

        -------------------------------------------------------
        -- 6. write_en=0 should NOT update register
        -------------------------------------------------------
        write_en <= '0';
        reg_sel  <= "001";
        data_in  <= "1011";
        wait until rising_edge(clk);
        wait for 1 ns;
        assert reg1_out = "0000" report "write_en=0: R1 was incorrectly written" severity ERROR;

        -------------------------------------------------------
        -- Done
        -------------------------------------------------------
        report "ALL REGISTER BANK TESTS PASSED" severity NOTE;
        wait;
    end process;

end Behavioral;
