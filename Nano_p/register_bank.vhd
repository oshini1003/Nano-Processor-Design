----------------------------------------------------------------------------------
-- Register Bank (8 x 4-bit)
-- University of Moratuwa | Team: 240348, 240351, 240347, 240343
-- R0 is hardwired to 0000 (cannot be written)
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity register_bank is
    Port (
        clk      : in  STD_LOGIC;
        reset    : in  STD_LOGIC;
        write_en : in  STD_LOGIC;
        reg_sel  : in  STD_LOGIC_VECTOR(2 downto 0);  -- Destination register
        data_in  : in  STD_LOGIC_VECTOR(3 downto 0);  -- Data to write
        -- Read ports (combinational)
        ra_sel   : in  STD_LOGIC_VECTOR(2 downto 0);  -- Source A select
        rb_sel   : in  STD_LOGIC_VECTOR(2 downto 0);  -- Source B select
        ra_out   : out STD_LOGIC_VECTOR(3 downto 0);
        rb_out   : out STD_LOGIC_VECTOR(3 downto 0);
        -- Debug: expose all registers
        reg0_out : out STD_LOGIC_VECTOR(3 downto 0);
        reg1_out : out STD_LOGIC_VECTOR(3 downto 0);
        reg2_out : out STD_LOGIC_VECTOR(3 downto 0);
        reg3_out : out STD_LOGIC_VECTOR(3 downto 0);
        reg4_out : out STD_LOGIC_VECTOR(3 downto 0);
        reg5_out : out STD_LOGIC_VECTOR(3 downto 0);
        reg6_out : out STD_LOGIC_VECTOR(3 downto 0);
        reg7_out : out STD_LOGIC_VECTOR(3 downto 0)
    );
end register_bank;

architecture Behavioral of register_bank is
    type reg_array is array (0 to 7) of STD_LOGIC_VECTOR(3 downto 0);
    signal regs : reg_array := (others => "0000");
begin
    -- R0 is always 0
    regs(0) <= "0000";

    -- Write process (synchronous, R0 protected)
    process(clk, reset)
    begin
        if reset = '1' then
            regs(1) <= "0000";
            regs(2) <= "0000";
            regs(3) <= "0000";
            regs(4) <= "0000";
            regs(5) <= "0000";
            regs(6) <= "0000";
            regs(7) <= "0000";
        elsif rising_edge(clk) then
            if write_en = '1' and reg_sel /= "000" then
                regs(conv_integer(reg_sel)) <= data_in;
            end if;
        end if;
    end process;

    -- Combinational read
    ra_out <= regs(conv_integer(ra_sel));
    rb_out <= regs(conv_integer(rb_sel));

    -- Debug outputs
    reg0_out <= regs(0);
    reg1_out <= regs(1);
    reg2_out <= regs(2);
    reg3_out <= regs(3);
    reg4_out <= regs(4);
    reg5_out <= regs(5);
    reg6_out <= regs(6);
    reg7_out <= regs(7);

end Behavioral;
