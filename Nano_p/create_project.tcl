## ============================================================
## Vivado TCL Script — Auto-create Nanoprocessor Project
## University of Moratuwa | Team: 240348, 240351, 240347, 240343
##
## USAGE (Vivado Tcl Console):
##   cd C:/Users/DELL/Desktop/Nano_p
##   source create_project.tcl
##
## This script will:
##   1. Create a new Vivado project targeting Basys3
##   2. Add all VHDL source files
##   3. Add the XDC constraints
##   4. Set the top-level module
##   5. Ready to Run Synthesis → Implementation → Generate Bitstream
## ============================================================

# ---- Project Settings ----
set proj_name   "nanoprocessor"
set proj_dir    [pwd]
set part_number "xc7a35tcpg236-1"

# ---- Create Project ----
create_project $proj_name $proj_dir/$proj_name -part $part_number -force

# Set simulator language
set_property simulator_language VHDL [current_project]
set_property target_language    VHDL [current_project]

# ---- Add Source Files ----
add_files -norecurse {
    program_counter.vhd
    program_rom.vhd
    register_bank.vhd
    adder_4bit.vhd
    adder_3bit.vhd
    alu_enhanced.vhd
    comparator_4bit.vhd
    mux_8way_4bit.vhd
    mux_2way_3bit.vhd
    decoder_3to8.vhd
    nanoprocessor_top.vhd
    nanoprocessor_top_VISIBLE.vhd
}

# ---- Add Simulation Sources ----
add_files -fileset sim_1 -norecurse {
    tb_alu_enhanced.vhd
    tb_nanoprocessor.vhd
}

# ---- Add Constraints ----
add_files -fileset constrs_1 -norecurse {
    nanoprocessor_basys3.xdc
}

# ---- Set Top-Level Module ----
# Use nanoprocessor_top for basic demo
# Use nanoprocessor_top_VISIBLE for full 4-digit 7-seg competition demo
set_property top nanoprocessor_top [current_fileset]

# ---- Set Simulation Top ----
set_property top tb_nanoprocessor [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

# ---- Update compile order ----
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts ""
puts "============================================"
puts " Project created: $proj_name"
puts " Part:            $part_number (Basys3)"
puts " Top:             nanoprocessor_top"
puts ""
puts " To switch to VISIBLE version, run:"
puts "   set_property top nanoprocessor_top_VISIBLE \[current_fileset\]"
puts ""
puts " To run ALU testbench:"
puts "   set_property top tb_alu_enhanced \[get_filesets sim_1\]"
puts "   launch_simulation"
puts ""
puts " Next steps:"
puts "   1. Run Synthesis   (Flow > Run Synthesis)"
puts "   2. Run Impl        (Flow > Run Implementation)"
puts "   3. Generate Bitstream"
puts "   4. Program Device  (plug in Basys3)"
puts "============================================"
