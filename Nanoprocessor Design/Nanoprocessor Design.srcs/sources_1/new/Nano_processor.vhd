library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Nano_processor is
    Port ( clk            : in STD_LOGIC;
           reset          : in STD_LOGIC;
           overflow_final : out STD_LOGIC;
           zero_final     : out STD_LOGIC;
           output         : out STD_LOGIC_VECTOR(3 downto 0);
           Reg7_7seg      : out STD_LOGIC_VECTOR (6 downto 0);
           Anode          : out STD_LOGIC_VECTOR (3 downto 0) );
end Nano_processor;

architecture Behavioral of Nano_processor is
    Component Top_Module
       Port ( clk            : in STD_LOGIC;
              reset          : in STD_LOGIC;
              overflow_final : out STD_LOGIC;
              zero_final     : out STD_LOGIC;
              output         : out STD_LOGIC_VECTOR(3 downto 0);
              Reg7_7seg      : out STD_LOGIC_VECTOR (6 downto 0);
              Anode          : out STD_LOGIC_VECTOR (3 downto 0) );
    end Component;
begin
    top_module_nanoprocessor : Top_Module
       Port map( clk            => clk,
                 reset          => reset,
                 overflow_final => overflow_final,
                 zero_final     => zero_final,
                 output         => output,
                 Reg7_7seg      => Reg7_7seg,
                 Anode          => Anode );    
end Behavioral;