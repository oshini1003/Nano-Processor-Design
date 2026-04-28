library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Adder_3bit is
    Port (
        A    : in  STD_LOGIC_VECTOR(2 downto 0);
        B    : in  STD_LOGIC_VECTOR(2 downto 0);
        Cin  : in  STD_LOGIC;
        Sum  : out STD_LOGIC_VECTOR(2 downto 0);
        Cout : out STD_LOGIC
    );
end Adder_3bit;

architecture Behavioral of Adder_3bit is

    component RCA_4
        Port (
            A0    : in  STD_LOGIC;
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
            C_out : out STD_LOGIC
        );
    end component;

    signal S3_unused : STD_LOGIC;  -- 4th bit output not needed

begin

    RCA_4_0 : RCA_4
        port map (
            -- 3 real input bits
            A0    => A(0),
            A1    => A(1),
            A2    => A(2),
            -- 4th bit tied to '0' (not used)
            A3    => '0',

            -- 3 real input bits
            B0    => B(0),
            B1    => B(1),
            B2    => B(2),
            -- 4th bit tied to '0' (not used)
            B3    => '0',

            C_in  => Cin,

            -- 3 real output bits
            S0    => Sum(0),
            S1    => Sum(1),
            S2    => Sum(2),
            -- 4th bit output not needed
            S3    => S3_unused,

            -- carry out of bit 2 becomes our Cout
            C_out => Cout
        );

end Behavioral;