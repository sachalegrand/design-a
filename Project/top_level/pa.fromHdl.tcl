
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name top_level -dir "H:/12s2/COMP3601/Project/top_level/planAhead_run_1" -part xc3s400ft256-5
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property top top_level $srcset
set_param project.paUcfFile  "top_level.ucf"
set hdlfile [add_files [list {../DisplayDecoder/DisplayDecoder.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../LedDisplay/LedDisplay.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {top_level.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
add_files "top_level.ucf" -fileset [get_property constrset [current_run]]
open_rtl_design -part xc3s400ft256-5
