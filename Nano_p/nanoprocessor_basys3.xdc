## ============================================================
## Basys3 XDC Constraints — 4-bit Nanoprocessor
## University of Moratuwa | Team: 240348, 240351, 240347, 240343
## Target: Digilent Basys3 (Artix-7 XC7A35T-1CPG236C)
## ============================================================

## ---- Clock (100 MHz onboard oscillator) ----
set_property PACKAGE_PIN W5  [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## ---- Reset: Center pushbutton (BTNC) ----
set_property PACKAGE_PIN U18 [get_ports reset_btn]
set_property IOSTANDARD LVCMOS33 [get_ports reset_btn]

## ============================================================
## LEDs
## ============================================================

## LD0 — R1[0]
set_property PACKAGE_PIN U16 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]

## LD1 — R1[1]
set_property PACKAGE_PIN E19 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]

## LD2 — R1[2]
set_property PACKAGE_PIN U19 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]

## LD3 — R1[3]
set_property PACKAGE_PIN V19 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]

## LD4 — Zero flag
set_property PACKAGE_PIN W18 [get_ports {led[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[4]}]

## LD5 — Overflow flag
set_property PACKAGE_PIN U15 [get_ports {led[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[5]}]

## LD6 — PC[1]
set_property PACKAGE_PIN U14 [get_ports {led[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[6]}]

## LD7 — PC[2]
set_property PACKAGE_PIN V14 [get_ports {led[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[7]}]

## ---- Only constrain LD8-LD15 when using nanoprocessor_top_VISIBLE ----
## Uncomment these if synthesizing the VISIBLE version:

## LD8 — slow_clk heartbeat
#set_property PACKAGE_PIN V13 [get_ports {led[8]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[8]}]

## LD9 — PC[0]
#set_property PACKAGE_PIN V3  [get_ports {led[9]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[9]}]

## LD10 — PC[1]
#set_property PACKAGE_PIN W3  [get_ports {led[10]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[10]}]

## LD11 — PC[2]
#set_property PACKAGE_PIN U3  [get_ports {led[11]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[11]}]

## LD12 — opcode[0]
#set_property PACKAGE_PIN P3  [get_ports {led[12]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[12]}]

## LD13 — opcode[1]
#set_property PACKAGE_PIN N3  [get_ports {led[13]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {led[13]}]

## LD14 — zero_flag
set_property PACKAGE_PIN P1  [get_ports zero_flag]
set_property IOSTANDARD LVCMOS33 [get_ports zero_flag]

## LD15 — ovf_flag
set_property PACKAGE_PIN L1  [get_ports ovf_flag]
set_property IOSTANDARD LVCMOS33 [get_ports ovf_flag]

## ============================================================
## 7-Segment Display (Common Anode, Active Low)
## ============================================================

## Segments: seg_led[0]=CA, [1]=CB, [2]=CC, [3]=CD,
##           [4]=CE, [5]=CF, [6]=CG
set_property PACKAGE_PIN W7  [get_ports {seg_led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_led[0]}]

set_property PACKAGE_PIN W6  [get_ports {seg_led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_led[1]}]

set_property PACKAGE_PIN U8  [get_ports {seg_led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_led[2]}]

set_property PACKAGE_PIN V8  [get_ports {seg_led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_led[3]}]

set_property PACKAGE_PIN U5  [get_ports {seg_led[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_led[4]}]

set_property PACKAGE_PIN V5  [get_ports {seg_led[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_led[5]}]

set_property PACKAGE_PIN U7  [get_ports {seg_led[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_led[6]}]

## Anode select (active low): anode[3:0]
set_property PACKAGE_PIN U2  [get_ports {anode[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {anode[0]}]

set_property PACKAGE_PIN U4  [get_ports {anode[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {anode[1]}]

set_property PACKAGE_PIN V4  [get_ports {anode[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {anode[2]}]

set_property PACKAGE_PIN W4  [get_ports {anode[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {anode[3]}]

## ============================================================
## PC Debug Output — map to PMOD JA if needed (optional)
## ============================================================
## Uncomment below to route pc_out_debug to PMOD JA header pins

#set_property PACKAGE_PIN J1  [get_ports {pc_out_debug[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {pc_out_debug[0]}]

#set_property PACKAGE_PIN L2  [get_ports {pc_out_debug[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {pc_out_debug[1]}]

#set_property PACKAGE_PIN J2  [get_ports {pc_out_debug[2]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {pc_out_debug[2]}]

## ============================================================
## Configuration / Bitstream Properties
## ============================================================
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
