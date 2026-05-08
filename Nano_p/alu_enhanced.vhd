----------------------------------------------------------------------------------
-- Enhanced ALU (8 Operations)
-- University of Moratuwa | Team: 240348, 240351, 240347, 240343
-- Operations:
--   000 = ADD   A + B
--   001 = SUB   A - B
--   010 = AND   A AND B
--   011 = OR    A OR  B
--   100 = XOR   A XOR B
--   101 = NOT   NOT A
--   110 = SHL   Shift A Left  by 1 (logical)
--   111 = SHR   Shift A Right by 1 (logical)
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity alu_enhanced is
    Port (
        A        : in  STD_LOGIC_VECTOR(3 downto 0);
        B        : in  STD_LOGIC_VECTOR(3 downto 0);
        alu_op   : in  STD_LOGIC_VECTOR(2 downto 0);
        result   : out STD_LOGIC_VECTOR(3 downto 0);
        zero     : out STD_LOGIC;
        overflow : out STD_LOGIC;
        carry    : out STD_LOGIC
    );
end alu_enhanced;

architecture Behavioral of alu_enhanced is
    signal res_int  : STD_LOGIC_VECTOR(3 downto 0);
    signal sum5     : STD_LOGIC_VECTOR(4 downto 0);
    signal b_neg    : STD_LOGIC_VECTOR(3 downto 0);
    signal ovf_add  : STD_LOGIC;
    signal ovf_sub  : STD_LOGIC;
    signal cry_int  : STD_LOGIC;
begin
    b_neg   <= (NOT B) + "0001";           -- 2's complement of B
    sum5    <= ('0' & A) + ('0' & B);      -- ADD extended
    ovf_add <= (A(3) XNOR B(3)) AND (A(3) XOR sum5(3));

    process(A, B, alu_op, sum5, b_neg, ovf_add)
        variable sub5 : STD_LOGIC_VECTOR(4 downto 0);
    begin
        -- defaults
        res_int  <= "0000";
        overflow <= '0';
        carry    <= '0';

        case alu_op is
            when "000" =>  -- ADD
                res_int  <= sum5(3 downto 0);
                carry    <= sum5(4);
                overflow <= ovf_add;

            when "001" =>  -- SUB (A - B)
                sub5     := ('0' & A) + ('0' & b_neg);
                res_int  <= sub5(3 downto 0);
                carry    <= sub5(4);
                -- Signed overflow for subtraction
                overflow <= (A(3) XOR B(3)) AND (A(3) XOR sub5(3));

            when "010" =>  -- AND
                res_int  <= A AND B;

            when "011" =>  -- OR
                res_int  <= A OR B;

            when "100" =>  -- XOR
                res_int  <= A XOR B;

            when "101" =>  -- NOT A
                res_int  <= NOT A;

            when "110" =>  -- SHL (logical shift left by 1)
                res_int  <= A(2 downto 0) & '0';
                carry    <= A(3);

            when "111" =>  -- SHR (logical shift right by 1)
                res_int  <= '0' & A(3 downto 1);
                carry    <= A(0);

            when others =>
                res_int  <= "0000";
        end case;
    end process;

    result <= res_int;
    zero   <= '1' when res_int = "0000" else '0';

end Behavioral;
