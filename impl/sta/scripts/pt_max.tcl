
#=====================================================================
# File Name : pt.tcl
# PrimeTime shell : pt_shell  # in EDA Cloud : Rpt_shell
# GUI : primetime             # in EDA Cloud : Rprimetime
#=====================================================================
# set PrimeTime environment
#=====================================================================
#source .synopsys_dc.setup
#####THIS is DC_SHELL SDC file by TCwang#### 
set synopsys_dc_setup_file 1
set hdlin_enable_vpp true 
set verilogout_no_tri true 
set write_name_nets_same_as_ports true 


set TOP dig_top
####search LIB PATH ######
set search_path "$search_path ../../model/Lib/efuse/ ../../model/Lib/smic/1.2v/ ."
set target_library scc018ug_uhd_rvt_ss_v1p08_125c_basic.db
set target_library2 S0153GEFUSE_PIPO256B_V0.3.1_ss_V1p62_125C.db
#set synthetic_library dw_foundation.sldb

set link_library [concat "*"  ../../model/Lib/smic/1.2v/$target_library ../../model/Lib/efuse/$target_library2 ]

set link_library "* $target_library $target_library2"
#=====================================================================
#main_pt file setup region
# CORE - specify top module name
# NETLIST - specify all synthesized netlist Verilog file names
# SDF_FILE - specify SDF file file names from synthesis result
# CNST_SDC - specify timing constraints TCL file
# CLK_INFO - specify clock information report file
# TIME_RPT - specify timing check information report file
#=====================================================================
# set string variables
#=====================================================================
set CHIP "dig_top"
set NETLIST [list ../APR/final/dig_top_sim.v]
#set DRIVE0_PORT [list clk rst_n]
set SDF_FILE "dig_top_max.sdf"
set SPEF_FILE "../APR/final/dig_top.SPEF.max"
set CNST_SDC "../APR/final/top.sdc.apr"
set CLK_INFO "./CHIP_clock_pt_max.rpt"
set TIME_RPT "./CHIP_timing_pt_max.rpt"
#set BEST_OP "fast"
#set WRST_OP "ff_v1p08_125c"
set WRST_OP "slow"
set WRST_OP "ss_v1p08_125c"

#set RST "rst_n"
#set VCD_FILE "../run/CHIP.vcd"
#set INST_NAME "CHIP_beh/u0"
#====================================================================
# Reading in Synthesized Netlist Verilog design
#====================================================================
read_file -format verilog $NETLIST
current_design $CHIP
link 
#====================================================================
# SDF information from the synthesis result
#====================================================================
current_design $CHIP
read_parasitics $SPEF_FILE
write_sdf -version 3.0 ../APR/final/dig_top_max.sdf 
read_sdf $SDF_FILE 
report_annotated_check 
read_sdc -echo $CNST_SDC
#set_drive 0 $DRIVE0_PORT
#set_drive 0 [get_port $RST*]
# Input drive is 0 on signals without timing analysis
#set_false_path -from [get_ports $RST*]
#get_design *
#current_design $CHIP
#====================================================================
# Report Clock Information Post false-path settings
#====================================================================
echo "reporting clock information post set"
report_clock > $CLK_INFO
report_port -input_delay >> $CLK_INFO
report_port -output_delay >> $CLK_INFO
check_timing >> $CLK_INFO
#====================================================================
# Report All Violation & Timing Path Post false-path settings
#====================================================================
echo "reporting timing check information post set"
#report_constraint -all_violators > $TIME_RPT
report_timing > $TIME_RPT
report_timing -nets -transition_time -capacitance >> $TIME_RPT
report_timing -nworst 10 -path_type summary >> $TIME_RPT
#====================================================================
# Remove everything before exiting
#====================================================================
echo "removing design & lib"
#remove_design -all
#remove_lib -all
echo "end of compilation"
#exit
