#####THIS is DC_SHELL SDC file by TCwang#### 
set synopsys_dc_setup_file 1
set hdlin_enable_vpp true 
set verilogout_no_tri true 
set write_name_nets_same_as_ports true 


set top_module dig_top
####search LIB PATH ######
set search_path "$search_path ../../model/Lib/efuse/ ../../model/Lib/smic/1.2v/ ."
set target_library scc018ug_uhd_rvt_ss_v1p08_125c_basic.db
set target_library2 S0153GEFUSE_PIPO256B_V0.3.1_ss_V1p62_125C_2013.db
set synthetic_library dw_foundation.sldb

set link_library [concat "*"  /mnt/hgfs/project/MI2519/model/Lib/smic/1.2v/$target_library /mnt/hgfs/project/MI2519/model/Lib/efuse/$target_library2 /EDA/tools/Synopsys/syn_2013.03-SP5-4/libraries/syn/$synthetic_library]

set link_library "* $target_library $synthetic_library $target_library2"

##### read verilog netlist ######

#read_verilog  oc8051_ram_256x8_two_bist.v
read_verilog  mi2519_digtop.v
##foreach active_files $files {read_verilog $active_files}

##### DC scripts ######
current_design  ${top_module}
set_dont_use scc018ug_uhd_rvt_ss_v1p08_125c_basic/SD*
link > dc_report/${top_module}.link_lib.rpt 
uniquify

#set_operating_conditions -max ss_v1p08_125c -max_library scc018ug_uhd_rvt_ss_v1p08_125c_basic -min ff_v1p98_-40c -min_library  scc018ug_uhd_rvt_ff_v1p98_-40c_basic
set_operating_conditions -max ss_v1p08_125c -max_library scc018ug_uhd_rvt_ss_v1p08_125c_basic 
set_wire_load_mode  enclosed 

#####source  constrain ######
source ./script/constraint_func.sdc

##### set dont touch  #####
set_dont_touch_network [all_clocks]
#set_dont_touch *spare_*
#####  set driver size #####
set_driving_cell -library scc018ug_uhd_rvt_ss_v1p08_125c_basic -lib_cell INUHDV1 -pin ZN [all_inputs] 
set output_load [expr 32.0 * [load_of scc018ug_uhd_rvt_ss_v1p08_125c_basic/INUHDV1/I]]
set_load $output_load [all_outputs]
#set_clock_uncertainty 0.5 [all_clocks]
set_max_transition 1 [list [all_inputs] [all_outputs]]
set design_max_cap [expr 32.0 * [load_of scc018ug_uhd_rvt_ss_v1p08_125c_basic/INUHDV1/ZN]]
set_max_capacitance $design_max_cap [current_design]
set_max_fanout 16 [current_design]


#####check design #####
check_design > dc_report/${top_module}.check_design.rpt 
check_timing > dc_report/${top_module}.check_timing.rpt 
set_fix_multiple_port_nets -all -buffer_constants 


#compile 
compile -map_effort medium -area_effort medium
#compile -incremental_mapping


#### report timing ######
report_clock_gating  -hier > dc_report/${top_module}.clock_gating.rpt 
report_design > dc_report/${top_module}.design.rpt 
report_area > dc_report/${top_module}.area.rpt 
report_reference > dc_report/${top_module}.ref.rpt 
report_cell  > dc_report/${top_module}.cell.rpt 
report_constraints  > dc_report/${top_module}.constraints.rpt 
report_timing -net -input -transition_time -capacitance -max_paths 300 > dc_report/${top_module}.timing.rpt 
report_area >  dc_report/${top_module}.dc_area.rpt 

change_names -rules verilog -hierarchy
#####  write gatelevel  netlist ######
write -format verilog -hierarchy -output  dc_report/result/${top_module}_syn.v
write_sdc   dc_report/result/${top_module}.dc.sdc 
write_sdf -context verilog dc_report/result/${top_module}.dc.sdf 
#report_bottleneck -cost_type path_count > ./dc_report/$TOP.bottleneck.log 


###################################################FOR CHIPTOP############################################3

