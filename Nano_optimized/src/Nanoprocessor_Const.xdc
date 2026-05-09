## ============================================================
## Nanoprocessor Constraints File - Basys3 (xc7a35tcpg236-1)
## Port names must match NanoProcessor.vhd entity exactly
## ============================================================

## Clock signal (W5 = 100MHz onboard oscillator)
set_property PACKAGE_PIN W5      [get_ports Clock]
set_property IOSTANDARD LVCMOS33 [get_ports Clock]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports Clock]


## LEDs (Data output = Register 7 contents, 4-bit)
set_property PACKAGE_PIN U16     [get_ports {Data[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Data[0]}]
set_property PACKAGE_PIN E19     [get_ports {Data[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Data[1]}]
set_property PACKAGE_PIN U19     [get_ports {Data[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Data[2]}]
set_property PACKAGE_PIN V19     [get_ports {Data[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Data[3]}]

## Zero and Overflow flags on LEDs
set_property PACKAGE_PIN P1      [get_ports Zero]
set_property IOSTANDARD LVCMOS33 [get_ports Zero]
set_property PACKAGE_PIN L1      [get_ports Overflow]
set_property IOSTANDARD LVCMOS33 [get_ports Overflow]


## 7-Segment Display - Cathode segments (active LOW)
set_property PACKAGE_PIN W7      [get_ports {S_7Seg[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {S_7Seg[0]}]
set_property PACKAGE_PIN W6      [get_ports {S_7Seg[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {S_7Seg[1]}]
set_property PACKAGE_PIN U8      [get_ports {S_7Seg[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {S_7Seg[2]}]
set_property PACKAGE_PIN V8      [get_ports {S_7Seg[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {S_7Seg[3]}]
set_property PACKAGE_PIN U5      [get_ports {S_7Seg[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {S_7Seg[4]}]
set_property PACKAGE_PIN V5      [get_ports {S_7Seg[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {S_7Seg[5]}]
set_property PACKAGE_PIN U7      [get_ports {S_7Seg[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {S_7Seg[6]}]

## 7-Segment Display - Digit anodes (active LOW)
set_property PACKAGE_PIN U2      [get_ports {anode[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {anode[0]}]
set_property PACKAGE_PIN U4      [get_ports {anode[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {anode[1]}]
set_property PACKAGE_PIN V4      [get_ports {anode[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {anode[2]}]
set_property PACKAGE_PIN W4      [get_ports {anode[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {anode[3]}]


## Buttons
## Center button = Reset (U18)
set_property PACKAGE_PIN U18     [get_ports Reset]
set_property IOSTANDARD LVCMOS33 [get_ports Reset]
