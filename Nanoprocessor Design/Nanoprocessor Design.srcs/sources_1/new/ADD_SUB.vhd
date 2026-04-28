library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ADD_SUB is
    Port ( A          : in  STD_LOGIC_VECTOR (3 downto 0);
           B          : in  STD_LOGIC_VECTOR (3 downto 0);
           AddSub_Select : in  STD_LOGIC;
           S          : out STD_LOGIC_VECTOR (3 downto 0);
           Overflow   : out STD_LOGIC;
           Zero       : out STD_LOGIC);
end ADD_SUB;

architecture Behavioral of ADD_SUB is

    component RCA_4
        Port ( A0    : in  STD_LOGIC;
               A1    : in  STD_LOGIC;
               A2    : in  STD_LOGIC;
               A3    : in  STD_LOGIC;
               B0    : in  STD_LOGIC;
               B1    : in  STD_LOGIC;
               B2    : in  STD_LOGIC;
               B3    : in  STD_LOGIC;
               C_in  : in  STD_LOGIC;
               S0    : out STD_LOGIC;
               S1    : out STD_LOGIC;
               S2    : out STD_LOGIC;
               S3    : out STD_LOGIC;
               C_out : out STD_LOGIC);
    end component;

    signal B_XOR : STD_LOGIC_VECTOR(3 downto 0);
    signal S_int : STD_LOGIC_VECTOR(3 downto 0);

begin
    -- AddSub_Sel=0: ADD ? B unchanged,  C_in=0
    -- AddSub_Sel=1: SUB ? B inverted,   C_in=1  (2's complement)
    B_XOR(0) <= B(0) XOR AddSub_Select;
    B_XOR(1) <= B(1) XOR AddSub_Select;
    B_XOR(2) <= B(2) XOR AddSub_Select;
    B_XOR(3) <= B(3) XOR AddSub_Select;

    RCA_4_0 : RCA_4
        port map (
            A0    => A(0),
            A1    => A(1),
            A2    => A(2),
            A3    => A(3),
            B0    => B_XOR(0),
            B1    => B_XOR(1),
            B2    => B_XOR(2),
            B3    => B_XOR(3),
            C_in  => AddSub_Select,   -- 0=add, 1=subtract
            S0    => S_int(0),
            S1    => S_int(1),
            S2    => S_int(2),
            S3    => S_int(3),
            C_out => Overflow
        );

    S    <= S_int;
    Zero <= NOT (S_int(0) OR S_int(1) OR S_int(2) OR S_int(3));

end Behavioral;