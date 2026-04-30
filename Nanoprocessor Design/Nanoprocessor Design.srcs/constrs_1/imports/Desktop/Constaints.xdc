## Clock signal (100 MHz crystal on Basys3)
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## Center Button (Used for Reset)
set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports reset]

## LEDs (Used for Overflow and Zero flags, and binary output)
set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports {overflow_final}]
set_property -dict { PACKAGE_PIN E19   IOSTANDARD LVCMOS33 } [get_ports {zero_final}]
set_property -dict { PACKAGE_PIN U19   IOSTANDARD LVCMOS33 } [get_ports {output[0]}]
set_property -dict { PACKAGE_PIN V19   IOSTANDARD LVCMOS33 } [get_ports {output[1]}]
set_property -dict { PACKAGE_PIN W18   IOSTANDARD LVCMOS33 } [get_ports {output[2]}]
set_property -dict { PACKAGE_PIN U15   IOSTANDARD LVCMOS33 } [get_ports {output[3]}]

## 7-Segment Display (Right-most display)
set_property -dict { PACKAGE_PIN W4    IOSTANDARD LVCMOS33 } [get_ports {Anode[3]}]
set_property -dict { PACKAGE_PIN W7    IOSTANDARD LVCMOS33 } [get_ports {Reg7_7seg[0]}]
set_property -dict { PACKAGE_PIN W6    IOSTANDARD LVCMOS33 } [get_ports {Reg7_7seg[1]}]
set_property -dict { PACKAGE_PIN U8    IOSTANDARD LVCMOS33 } [get_ports {Reg7_7seg[2]}]
set_property -dict { PACKAGE_PIN V8    IOSTANDARD LVCMOS33 } [get_ports {Reg7_7seg[3]}]
set_property -dict { PACKAGE_PIN U5    IOSTANDARD LVCMOS33 } [get_ports {Reg7_7seg[4]}]
set_property -dict { PACKAGE_PIN V5    IOSTANDARD LVCMOS33 } [get_ports {Reg7_7seg[5]}]
set_property -dict { PACKAGE_PIN U7    IOSTANDARD LVCMOS33 } [get_ports {Reg7_7seg[6]}]