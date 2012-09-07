
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name timer -dir "H:/12s2/COMP3601/Project/timer/planAhead_run_1" -part xc3s400ft256-5
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property top timer $srcset
set_param project.paUcfFile  "timer.ucf"
set hdlfile [add_files [list {../clk_div/clk_div.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {timer.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
add_files "timer.ucf" -fileset [get_property constrset [current_run]]
open_rtl_design -part xc3s400ft256-5
