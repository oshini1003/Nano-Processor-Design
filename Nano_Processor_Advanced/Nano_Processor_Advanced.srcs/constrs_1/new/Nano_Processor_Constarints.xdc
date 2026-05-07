## CLOCK INPUT

# 100 MHz system clock (pin E3 on Artix-7)
set_property -dict {PACKAGE_PIN W5 IOSTANDARD LVCMOS33} [get_ports clk]

## PUSHBUTTON INPUTS
## ========================================================================

# CPU Reset button (BTNC - center button, pin C12)
# Active HIGH when pressed (has external pull-down resistor)
set_property -dict {PACKAGE_PIN C12 IOSTANDARD LVCMOS33} [get_ports reset_btn]

## LED OUTPUTS (16 LEDs total: LD0-LD15)
## ========================================================================

# Lower 8 LEDs (LD0-LD7) - Right side of board
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports {led[0]}]   # LD0
set_property -dict {PACKAGE_PIN K15 IOSTANDARD LVCMOS33} [get_ports {led[1]}]   # LD1
set_property -dict {PACKAGE_PIN J13 IOSTANDARD LVCMOS33} [get_ports {led[2]}]   # LD2
set_property -dict {PACKAGE_PIN N14 IOSTANDARD LVCMOS33} [get_ports {led[3]}]   # LD3
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33} [get_ports {led[4]}]   # LD4
set_property -PACKAGE_PIN V17 -IOSTANDARD LVCMOS33 [get_ports {led[5]}]        # LD5
set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVCMOS33} [get_ports {led[6]}]   # LD6
set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS33} [get_ports {led[7]}]   # LD7

# Upper 8 LEDs (LD8-LD15) - Left side of board
set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports {led[8]}]   # LD8
set_property -dict {PACKAGE_PIN T15 IOSTANDARD LVCMOS33} [get_ports {led[9]}]   # LD9
set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports {led[10]}]  # LD10
set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS33} [get_ports {led[11]}]  # LD11
set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS33} [get_ports {led[12]}]  # LD12
set_property -dict {PACKAGE_PIN M13 IOSTANDARD LVCMOS33} [get_ports {led[13]}]  # LD13
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports {led[14]}]  # LD14
set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS33} [get_ports {led[15]}]  # LD15

## 7-SEGMENT DISPLAY (4-digit common anode)
## ========================================================================

# Segment cathodes (active LOW - illuminate when driven low)
# Segments: a=W7, b=W6, c=U2, d=U3, e=V3, f=V4, g=U1
set_property -dict {PACKAGE_PIN W7  IOSTANDARD LVCMOS33} [get_ports {seg[6]}]   # Segment a (top)
set_property -dict {PACKAGE_PIN W6  IOSTANDARD LVCMOS33} [get_ports {seg[5]}]   # Segment b (upper right)
set_property -dict {PACKAGE_PIN U2  IOSTANDARD LVCMOS33} [get_ports {seg[4]}]   # Segment c (lower right)
set_property -dict {PACKAGE_PIN U3  IOSTANDARD LVCMOS33} [get_ports {seg[3]}]   # Segment d (bottom)
set_property -dict {PACKAGE_PIN V3  IOSTANDARD LVCMOS33} [get_ports {seg[2]}]   # Segment e (lower left)
set_property -dict {PACKAGE_PIN V4  IOSTANDARD LVCMOS33} [get_ports {seg[1]}]   # Segment f (upper left)
set_property -dict {PACKAGE_PIN U1  IOSTANDARD LVCMOS33} [get_ports {seg[0]}]   # Segment g (middle)

# Digit anode controls (active LOW - digit enabled when driven low)
set_property -dict {PACKAGE_PIN W4  IOSTANDARD LVCMOS33} [get_ports {an[0]}]    # Digit 0 (rightmost)
set_property -dict {PACKAGE_PIN V4  IOSTANDARD LVCMOS33} [get_ports {an[1]}]    # Digit 1
set_property -dict {PACKAGE_PIN U4  IOSTANDARD LVCMOS33} [get_ports {an[2]}]    # Digit 2
# Note: Digit 3 anode conflicts with segment f above - using alternative mapping
set_property -dict {PACKAGE_PIN U2  IOSTANDARD LVCMOS33} [get_ports {an[3]}]    # Digit 3 (leftmost)


## OPTIONAL DEBUG OUTPUTS (for oscilloscope/logic analyzer)
## Connect these to Pmod headers or spare pins if needed
## ========================================================================

# PC value output (3 bits)
set_property -dict {PACKAGE_PIN J1  IOSTANDARD LVCMOS33} [get_ports {pc_debug[0]}]
set_property -dict {PACKAGE_PIN L1  IOSTANDARD LVCMOS33} [get_ports {pc_debug[1]}]
set_property -dict {PACKAGE_PIN M2  IOSTANDARD LVCMOS33} [get_ports {pc_debug[2]}]

# R1 value output (4 bits)
set_property -dict {PACKAGE_PIN K2  IOSTANDARD LVCMOS33} [get_ports {r1_debug[0]}]
set_property -dict {PACKAGE_PIN H1  IOSTANDARD LVCMOS33} [get_ports {r1_debug[1]}]
set_property -dict {PACKAGE_PIN E2  IOSTANDARD LVCMOS33} [get_ports {r1_debug[2]}]
set_property -dict {PACKAGE_PIN F2  IOSTANDARD LVCMOS33} [get_ports {r1_debug[3]}]

## ========================================================================
## TIMING CONSTRAINTS (important for reliable operation)
## ========================================================================

# Primary clock constraint: 100 MHz onboard oscillator
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} [get_ports clk]

## ========================================================================
## END OF CONSTRAINT FILE
## ============================================================================