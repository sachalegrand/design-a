
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name sensor -dir "H:/12s2/COMP3601/Project/sensor/planAhead_run_1" -part xc3s400ft256-5
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property top sensor $srcset
set_param project.paUcfFile  "sensor.ucf"
set hdlfile [add_files [list {../clk_div/clk_div.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {sensor.vhd}]]
set_property file_type VHDL $hdlfile
set_property library work $hdlfile
add_files "sensor.ucf" -fileset [get_property constrset [current_run]]
open_rtl_design -part xc3s400ft256-5
