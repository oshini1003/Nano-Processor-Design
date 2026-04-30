# Basys 3 Constraint File for Nanoprocessor
# ==========================================

# Clock (100 MHz oscillator)
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

# Reset Button (BTNC - center button)
set_property PACKAGE_PIN U18 [get_ports reset_btn]
set_property IOSTANDARD LVCMOS33 [get_ports reset_btn]

# LEDs for Data Output (LD0-LD3)
set_property PACKAGE_PIN U16 [get_ports {led_data[0]}]
set_property PACKAGE_PIN E19 [get_ports {led_data[1]}]
set_property PACKAGE_PIN U19 [get_ports {led_data[2]}]
set_property PACKAGE_PIN V19 [get_ports {led_data[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_data[*]}]

# LED14 - Overflow Flag
set_property PACKAGE_PIN W18 [get_ports led_overflow]
set_property IOSTANDARD LVCMOS33 [get_ports led_overflow]

# LED15 - Zero Flag  
set_property PACKAGE_PIN U15 [get_ports led_zero]
set_property IOSTANDARD LVCMOS33 [get_ports led_zero]

# 7-Segment Display (Anodes)
set_property PACKAGE_PIN W7 [get_ports {anode_out[0]}]
set_property PACKAGE_PIN W6 [get_ports {anode_out[1]}]
set_property PACKAGE_PIN U8 [get_ports {anode_out[2]}]
set_property PACKAGE_PIN V8 [get_ports {anode_out[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {anode_out[*]}]

# 7-Segment Display (Cathodes - segments A-G)
set_property PACKAGE_PIN U7 [get_ports {seg_out[0]}]   # A
set_property PACKAGE_PIN V5 [get_ports {seg_out[1]}]   # B
set_property PACKAGE_PIN U5 [get_ports {seg_out[2]}]   # C
set_property PACKAGE_PIN V4 [get_ports {seg_out[3]}]   # D
set_property PACKAGE_PIN U4 [get_ports {seg_out[4]}]   # E
set_property PACKAGE_PIN V3 [get_ports {seg_out[5]}]   # F
set_property PACKAGE_PIN W3 [get_ports {seg_out[6]}]   # G
set_property IOSTANDARD LVCMOS33 [get_ports {seg_out[*]}]

# Timing constraint for clock
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} [get_ports clk]