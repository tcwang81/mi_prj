
source common_setting.tcl -echo -verb
if {$LIB_TYPE == "NLDM"} {
  source read_library.tcl     -echo -verb
}
if {$LIB_TYPE == "CCS"} {
  source read_library_ccs.tcl -echo -verb
}
source ./tools/tool_setting.tcl -echo -verb

alias h history


read_verilog $DATABASE_PATH/$BASE_NAME.v

current_design $BASE_NAME


set_load 0.3 [all_outputs]
set_drive [expr [drive_of */INVVERMX1/O]] [all_inputs]

#set_wire_load_model -name Conservative
set_wire_load_mode top

#set_operating_conditions WCCOM -analysis_type single
set_operating_conditions -analysis_type single

if { $SI_ANALYSIS == "ON" } {
  read_parasitics -complete_with wlm $SPEF -keep_capacitive_coupling -verbose
}
if { $SI_ANALYSIS == "OFF" } {
  read_parasitics -complete_with wlm $SPEF -verbose
}

echo $SPEF
update_timing

if { $STA_ONLY == "false" && $ANALYSIS_MODE == "OFF" } {
  #=======================================================================
  #for verilog simulation
  write_sdf -compress gzip -version 3.0 -context verilog -no_edge ./OUT_files/$BASE_NAME\_sim_$RC\_$CORNER\.sdf.gz
  
  #for STA
  #write_sdf -compress -no_negative_values {timing_checks cell_delays net_delays} ILI9881C_CORE_sta_WC.sdf.gz
  write_sdf -compress gzip -version 3.0 ./OUT_files/$BASE_NAME\_sta_$RC\_$CORNER\.sdf.gz
  
  
  #set_max_transition 1 [current_design]
  
  #source dont_tran_fix.tcl
  report_constraint -max_transition -all        > ./RPT_files/max_transition_violation_$RC\_$CORNER\.rpt
  report_constraint -max_transition -all -verb >> ./RPT_files/max_transition_violation_$RC\_$CORNER\.rpt
  report_constraint -max_transition -all        > ./RPT_files/max_transition_violation_$RC\_$CORNER\.rpt
  report_constraint -max_transition -all -verb >> ./RPT_files/max_transition_violation_$RC\_$CORNER\.rpt
  
  
  report_constraint -max_cap -all        > ./RPT_files/max_cap_violation_$RC\_$CORNER\.rpt
  report_constraint -max_cap -all -verb >> ./RPT_files/max_cap_violation_$RC\_$CORNER\.rpt
  report_constraint -max_cap -all        > ./RPT_files/max_cap_violation_$RC\_$CORNER\.rpt
  report_constraint -max_cap -all -verb >> ./RPT_files/max_cap_violation_$RC\_$CORNER\.rpt
}

#------------------------------------------------
current_design $BASE_NAME
source -echo -verbose $CONSTRAINT_FILE
source -echo -verbose $CONSTRAIN_PATH/false_path.tcl

set_propagated_clock [all_clocks]

set case_analysis_log_file case_log
#------------------------------------------------
update_timing

if { $ANALYSIS_MODE == "OFF" } {
  if {[string match $CORNER "SS_125"] && [string match $RC cworst]} {
    write_sdc -nosplit ./OUT_files/whole_mode1.sdc
    source ~/work/count_VT_Innopower55.tcl
    printvar > pt_shell_var
  }

  if { $SI_ANALYSIS == "ON" } {
    source -echo -verbose ./tools/tool_setting_SI.tcl
    update_timing
    report_si_double_switching -nosplit -rise -fall ./RPT_files/si_double_switching_$RC\_$CORNER\.rpt
  }
  if { $OCV_ANALYSIS == "ON" } {
    source -echo -verbose $CONSTRAIN_PATH/derate.tcl
    update_timing
  }

  report_constraint                	      >  ./RPT_files/timing_$RC\_$CORNER\.rpt
  report_constraint -all_violators	      >> ./RPT_files/timing_$RC\_$CORNER\.rpt
  report_constraint -all_violators -verbose   >> ./RPT_files/timing_$RC\_$CORNER\.rpt

  report_analysis_coverage                    >  ./RPT_files/summary_$RC\_$CORNER\.rpt
  report_bottleneck                           >  ./RPT_files/bottleneck_$RC\_$CORNER\.rpt
 
  report_power                   > ./RPT_files/power_$RC\_$CORNER\.rpt
  report_power -hierarchy -leaf >> ./RPT_files/power_$RC\_$CORNER\.rpt

  set list {BUFVELMX0P4 BUFVELMX0P7 BUFVELMX1 BUFVELMX16 BUFVELMX2 BUFVELMX20 BUFVELMX3 BUFVELMX4 BUFVELMX6 BUFVELMX8 BUFVERMX0P4 BUFVERMX0P7 BUFVERMX1 BUFVERMX16 BUFVERMX2 BUFVERMX20 BUFVERMX3 BUFVERMX4 BUFVERMX6 BUFVERMX8}

  if { $TIMING_FIX == "ON" } {
    if {[string match $CORNER "SS_125"] && [string match $RC cworst]} {

      fix_eco_drc -type max_tran -buffer_list $list
      fix_eco_timing -type setup -methods size_cell
      fix_eco_timing -type hold  -methods {size_cell insert_buffer} -buffer_list $list
    
      write_changes -format icctcl -output ./OUT_files/fix_tran.tcl
      write_changes -format  dctcl -output ./OUT_files/dc_fix_tran.tcl

      if [file exist ./OUT_files/fix_tran.tcl] { 
        update_timing

        report_constraint                	      >  ./RPT_files/timing_$RC\_$CORNER\_fix.rpt
        report_constraint -all_violators	      >> ./RPT_files/timing_$RC\_$CORNER\_fix.rpt
        report_constraint -all_violators -verbose   >> ./RPT_files/timing_$RC\_$CORNER\_fix.rpt  
  
        report_analysis_coverage                    >  ./RPT_files/summary_$RC\_$CORNER\_fix.rpt
      }
    }
    
    if {![string match $CORNER "SS_125"] || ![string match $RC cworst]} {
      if [file exist ./OUT_files/fix_tran.tcl] {
        source ./OUT_files/fix_tran.tcl
    
        #fix_eco_drc -type max_tran -buffer_list $list
        #fix_eco_timing -type setup -methods size_cell
        #fix_eco_timing -type hold  -methods {size_cell insert_buffer} -buffer_list $list
        # 
        #write_changes -format icctcl -output ./OUT_files/fix_tran.tcl
        update_timing
    
        report_constraint                	      >  ./RPT_files/timing_$RC\_$CORNER\_fix.rpt
        report_constraint -all_violators	      >> ./RPT_files/timing_$RC\_$CORNER\_fix.rpt
        report_constraint -all_violators -verbose   >> ./RPT_files/timing_$RC\_$CORNER\_fix.rpt  
 
        report_analysis_coverage                    >  ./RPT_files/summary_$RC\_$CORNER\_fix.rpt
      }
    }
  }

  if { $IR_TIMING == "ON" } {
    source pt2timing.tcl
    getSTA * 
  }

exit
}




############################<<<<<<<<<<<<<  read_library.tcl     >>>>>>>>>>>>>###################################
set search_path         [list . ${synopsys_root}/libraries/syn /project/ILI7820_AA/lib/STD_RVT/synopsys/csm /project/ILI7820_AA/lib/STD_LVT/synopsys/csm ../for_syn]

#############################################################
# Library Corner SS
#############################################################

if {$CORNER == "SS_125"} {
  set link_path {* \
                 isfcv_ers_generic_core_ss1p08v125c.ccdb \
                 isfcv_els_generic_core_ss1p08v125c.ccdb \
                 LB1112_TOP_ILI7820_AA_isfcv_ers_generic_core_ss1p08v125c.db \
                 LB21_26_TOP_ILI7820_AA_isfcv_ers_generic_core_ss1p08v125c.db \
                 LB56_TOP_ILI7820_AA_isfcv_ers_generic_core_ss1p08v125c.db \
                 LB78_TOP_ILI7820_AA_isfcv_ers_generic_core_ss1p08v125c.db \
                 LBA_TOP_ILI7820_AA_isfcv_ers_generic_core_ss1p08v125c.db \
                 TOP_RBRAM_ILI7820_AA_isfcv_ers_generic_core_ss1p08v125c.db \
                }
}
if {$CORNER == "SS_-40"} {
  set link_path {* \
                 isfcv_ers_generic_core_ss1p08vm40c.ccdb \
                 isfcv_els_generic_core_ss1p08vm40c.ccdb \
                 LB1112_TOP_ILI7820_AA_isfcv_ers_generic_core_ss1p08v125c.db \
                 LB21_26_TOP_ILI7820_AA_isfcv_ers_generic_core_ss1p08v125c.db \
                 LB56_TOP_ILI7820_AA_isfcv_ers_generic_core_ss1p08v125c.db \
                 LB78_TOP_ILI7820_AA_isfcv_ers_generic_core_ss1p08v125c.db \
                 LBA_TOP_ILI7820_AA_isfcv_ers_generic_core_ss1p08v125c.db \
                 TOP_RBRAM_ILI7820_AA_isfcv_ers_generic_core_ss1p08v125c.db \
                }
}

#############################################################
# Library Corner TT
#############################################################

if {$CORNER == "TT_125"} {
  set link_path {* \
                 isfcv_ers_generic_core_tt1p2v125c.ccdb \
                 isfcv_els_generic_core_tt1p2v125c.ccdb \
                 LB1112_TOP_ILI7820_AA_isfcv_ers_generic_core_tt1p2v25c.db \
                 LB21_26_TOP_ILI7820_AA_isfcv_ers_generic_core_tt1p2v25c.db \
                 LB56_TOP_ILI7820_AA_isfcv_ers_generic_core_tt1p2v25c.db \
                 LB78_TOP_ILI7820_AA_isfcv_ers_generic_core_tt1p2v25c.db \
                 LBA_TOP_ILI7820_AA_isfcv_ers_generic_core_tt1p2v25c.db \
                 TOP_RBRAM_ILI7820_AA_isfcv_ers_generic_core_tt1p2v25c.db \
                }
}
if {$CORNER == "TT_25"} {
  set link_path {* \
                 isfcv_ers_generic_core_tt1p2v25c.ccdb \
                 isfcv_els_generic_core_tt1p2v25c.ccdb \
                 LB1112_TOP_ILI7820_AA_isfcv_ers_generic_core_tt1p2v25c.db \
                 LB21_26_TOP_ILI7820_AA_isfcv_ers_generic_core_tt1p2v25c.db \
                 LB56_TOP_ILI7820_AA_isfcv_ers_generic_core_tt1p2v25c.db \
                 LB78_TOP_ILI7820_AA_isfcv_ers_generic_core_tt1p2v25c.db \
                 LBA_TOP_ILI7820_AA_isfcv_ers_generic_core_tt1p2v25c.db \
                 TOP_RBRAM_ILI7820_AA_isfcv_ers_generic_core_tt1p2v25c.db \
                }
}

#############################################################
# Library Corner FF
#############################################################

if {$CORNER == "FF_-40"} {
  set link_path {* \
                 isfcv_ers_generic_core_ff1p32vm40c.ccdb \
                 isfcv_els_generic_core_ff1p32vm40c.ccdb \
                 LB1112_TOP_ILI7820_AA_isfcv_ers_generic_core_ff1p32vm40c.db \
                 LB21_26_TOP_ILI7820_AA_isfcv_ers_generic_core_ff1p32vm40c.db \
                 LB56_TOP_ILI7820_AA_isfcv_ers_generic_core_ff1p32vm40c.db \
                 LB78_TOP_ILI7820_AA_isfcv_ers_generic_core_ff1p32vm40c.db \
                 LBA_TOP_ILI7820_AA_isfcv_ers_generic_core_ff1p32vm40c.db \
                 TOP_RBRAM_ILI7820_AA_isfcv_ers_generic_core_ff1p32vm40c.db \
                }
}
if {$CORNER == "FF_0"} {
  set link_path {* \
                 isfcv_ers_generic_core_ff1p32v0c.ccdb \
                 isfcv_els_generic_core_ff1p32v0c.ccdb \
                 LB1112_TOP_ILI7820_AA_isfcv_ers_generic_core_ff1p32vm40c.db \
                 LB21_26_TOP_ILI7820_AA_isfcv_ers_generic_core_ff1p32vm40c.db \
                 LB56_TOP_ILI7820_AA_isfcv_ers_generic_core_ff1p32vm40c.db \
                 LB78_TOP_ILI7820_AA_isfcv_ers_generic_core_ff1p32vm40c.db \
                 LBA_TOP_ILI7820_AA_isfcv_ers_generic_core_ff1p32vm40c.db \
                 TOP_RBRAM_ILI7820_AA_isfcv_ers_generic_core_ff1p32vm40c.db \
                }
}
if {$CORNER == "FF_125"} {
  set link_path {* \
                 isfcv_ers_generic_core_ff1p32v125c.ccdb \
                 isfcv_els_generic_core_ff1p32v125c.ccdb \
                 LB1112_TOP_ILI7820_AA_isfcv_ers_generic_core_ff1p32vm40c.db \
                 LB21_26_TOP_ILI7820_AA_isfcv_ers_generic_core_ff1p32vm40c.db \
                 LB56_TOP_ILI7820_AA_isfcv_ers_generic_core_ff1p32vm40c.db \
                 LB78_TOP_ILI7820_AA_isfcv_ers_generic_core_ff1p32vm40c.db \
                 LBA_TOP_ILI7820_AA_isfcv_ers_generic_core_ff1p32vm40c.db \
                 TOP_RBRAM_ILI7820_AA_isfcv_ers_generic_core_ff1p32vm40c.db \
                }
}





#############################################################
# SPEF selection
#############################################################

if {$RC == "cworst"} {
    if {$CORNER == "SS_125"} {set SPEF $DATABASE_PATH/$BASE_NAME\.cworst.SS.125.spef.gz}
    if {$CORNER == "SS_-40"} {set SPEF $DATABASE_PATH/$BASE_NAME\.cworst.SS.-40.spef.gz}
    if {$CORNER == "TT_125"} {set SPEF $DATABASE_PATH/$BASE_NAME\.cworst.SS.125.spef.gz}
    if {$CORNER == "TT_25" } {set SPEF $DATABASE_PATH/$BASE_NAME\.cworst.SS.25.spef.gz}
}
if {$RC == "rcworst"} {
    if {$CORNER == "SS_125"} {set SPEF $DATABASE_PATH/$BASE_NAME\.rcworst.SS.125.spef.gz}
    if {$CORNER == "SS_-40"} {set SPEF $DATABASE_PATH/$BASE_NAME\.rcworst.SS.-40.spef.gz}
    if {$CORNER == "TT_125"} {set SPEF $DATABASE_PATH/$BASE_NAME\.rcworst.SS.125.spef.gz}
    if {$CORNER == "TT_25" } {set SPEF $DATABASE_PATH/$BASE_NAME\.rcworst.SS.25.spef.gz}
}

if {$RC == "cbest"} {
    if {$CORNER == "FF_-40"} {set SPEF $DATABASE_PATH/$BASE_NAME\.cbest.FF.-40.spef.gz}
    if {$CORNER == "FF_0"  } {set SPEF $DATABASE_PATH/$BASE_NAME\.cbest.FF.0.spef.gz}
    if {$CORNER == "FF_125"} {set SPEF $DATABASE_PATH/$BASE_NAME\.cbest.FF.125.spef.gz}
}
if {$RC == "rcbest"} {
    if {$CORNER == "FF_-40"} {set SPEF $DATABASE_PATH/$BASE_NAME\.rcbest.FF.-40.spef.gz}
    if {$CORNER == "FF_0"  } {set SPEF $DATABASE_PATH/$BASE_NAME\.rcbest.FF.0.spef.gz}
    if {$CORNER == "FF_125"} {set SPEF $DATABASE_PATH/$BASE_NAME\.rcbest.FF.125.spef.gz}
}

if {$RC == "typical"} {
    if {$CORNER == "TT_125"} {set SPEF $DATABASE_PATH/$BASE_NAME\.typical.TT.125.spef.gz}
    if {$CORNER == "TT_25" } {set SPEF $DATABASE_PATH/$BASE_NAME\.typical.TT.25.spef.gz}
}

############################<<<<<<<<<<<<<  tool_setting.tcl      >>>>>>>>>>>>>###################################

set timing_input_port_default_clock "false"
set timing_disable_recovery_removal_checks false
set timing_disable_clock_gating_checks false
set timing_remove_clock_reconvergence_pessimism true
set timing_report_unconstrained_paths true
set timing_gclock_source_network_num_master_registers 1
set timing_clock_gating_propagate_enable true
set timing_reduce_parallel_cell_arcs false
set power_enable_analysis true
set timing_enable_multiple_clocks_per_reg true
set timing_reduce_parallel_cell_arcs false
set timing_dynamic_loop_breaking true
set timing_keep_loop_breaking_disabled_arcs true

#alias rpt "report_timing -transition_time -capacitance -nets"
alias rpt   "report_timing -transition_time"
alias rptn  "rpt -nosplit"
alias rptf  "rpt -path_type full_clock_expanded"
alias rptnf "rptn -path_type full_clock_expanded"

alias rpc  "report_constraint"
alias rpcn "report_constraint -nosplit"

alias fix_hold "insert_buffer -new_cell_names $PREFIX"

alias single_w "set_operating_conditions WORST -analysis_type single"
alias single_b "set_operating_conditions BEST  -analysis_type single"
alias bcwc     "set_operating_conditions -min BEST -max WORST -analysis_type bc_wc"

alias list_hold "rpcn -min_delay -all > aa; rpcn -removal -all >> aa"
alias list_hold_all "rpcn -min_delay -removal -all -verb > aa"

alias rpcgen "rpc > max.rpt; rpc -all >> max.rpt; rpc -all -verb >> max.rpt"



############################<<<<<<<<<<<<<  derate.tcl     >>>>>>>>>>>>>###################################
#############################################################
# Library Corner SS
#############################################################

if {$CORNER == "SS_125"} {
  set_timing_derate -cell_delay -clock -early 0.93
}
if {$CORNER == "SS_-40"} {
  set_timing_derate -cell_delay -clock -early 0.93
}

#############################################################
# Library Corner TT
#############################################################

if {$CORNER == "TT_125"} {
}
if {$CORNER == "TT_25"} {
}

#############################################################
# Library Corner FF
#############################################################

if {$CORNER == "FF_-40"} {
  set_timing_derate -cell_delay -clock -late  1.1
}
if {$CORNER == "FF_0"} {
}
if {$CORNER == "FF_125"} {
}







