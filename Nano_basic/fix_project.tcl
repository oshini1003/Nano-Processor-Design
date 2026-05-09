# ============================================================
# fix_project.tcl - Run this in Vivado's Tcl Console to fix
# the source files and constraints for Nano_basic_nim project
# 
# HOW TO USE:
#   In Vivado: Tools > Tcl Console
#   Then type: source {C:/Users/USER/Downloads/Nano_basic_nim/fix_project.tcl}
# ============================================================

set src_dir [file normalize [file join [file dirname [info script]] "src"]]
puts "Source directory: $src_dir"

# ---- Remove all old/stale source files from sources_1 ----
puts "Removing old source files..."
set old_files [get_files -of_objects [get_filesets sources_1] -quiet]
if {[llength $old_files] > 0} {
    remove_files -fileset sources_1 $old_files
}

# ---- Remove old constraint files ----
puts "Removing old constraint files..."
set old_constrs [get_files -of_objects [get_filesets constrs_1] -quiet]
if {[llength $old_constrs] > 0} {
    remove_files -fileset constrs_1 $old_constrs
}

# ---- Add Package / Type definition files first (compile order matters) ----
puts "Adding package files..."
add_files -fileset sources_1 -norecurse [file join $src_dir "Package Files" "BusDefinitions.vhd"]
add_files -fileset sources_1 -norecurse [file join $src_dir "Package Files" "constants.vhd"]
set_property file_type VHDL [get_files [file join $src_dir "Package Files" "BusDefinitions.vhd"]]
set_property file_type VHDL [get_files [file join $src_dir "Package Files" "constants.vhd"]]

# ---- Add primitive/building-block files ----
puts "Adding building block files..."
set bb_files {
    "imports/HA.vhd"
    "imports/FA.vhd"
    "imports/RCA_3.vhd"
    "imports/RCA_4.vhd"
    "imports/Decoder_2_to_4.vhd"
    "imports/Decoder_3_to_8.vhd"
    "imports/Reg.vhd"
    "imports/reg_3bit.vhd"
    "imports/Mux_2way_3bit.vhd"
    "imports/Mux_2way_4bit.vhd"
    "imports/Mux_8way_4bit.vhd"
}
foreach f $bb_files {
    set fpath [file join $src_dir $f]
    if {[file exists $fpath]} {
        add_files -fileset sources_1 -norecurse $fpath
        set_property file_type VHDL [get_files $fpath]
        puts "  Added: $fpath"
    } else {
        puts "  WARNING: File not found: $fpath"
    }
}

# ---- Add main design source files ----
puts "Adding main source files..."
set src_files {
    "Slow_Clk.vhd"
    "PC_Adder.vhd"
    "Program_Counter.vhd"
    "Address_Selector.vhd"
    "Program_ROM.vhd"
    "Instruction_Decoder.vhd"
    "Load_Selector.vhd"
    "Register_Bank.vhd"
    "RegisterData_Multiplexer.vhd"
    "Add_Sub_4.vhd"
    "LUT_16_7.vhd"
    "NanoProcessor.vhd"
}
foreach f $src_files {
    set fpath [file join $src_dir $f]
    if {[file exists $fpath]} {
        add_files -fileset sources_1 -norecurse $fpath
        set_property file_type VHDL [get_files $fpath]
        puts "  Added: $fpath"
    } else {
        puts "  WARNING: File not found: $fpath"
    }
}

# ---- Set NanoProcessor as top module ----
puts "Setting top module..."
set_property top NanoProcessor [get_filesets sources_1]
update_compile_order -fileset sources_1

# ---- Add constraints file ----
puts "Adding constraints file..."
set xdc_path [file join $src_dir "Nanoprocessor_Const.xdc"]
add_files -fileset constrs_1 -norecurse $xdc_path
set_property file_type XDC [get_files $xdc_path]

# ---- Reset synthesis and implementation runs ----
puts "Resetting synthesis run..."
reset_run synth_1

puts ""
puts "============================================"
puts "Project fixed successfully!"
puts "Next steps:"
puts "  1. Run Synthesis  (Flow > Run Synthesis)"
puts "  2. Run Implementation"
puts "  3. Generate Bitstream"
puts "============================================"
