#=====================================================================
# File Name : pt_signoff_sdf.tcl
# Function  : Generate Combined MAX/MIN SDF for Gate-Level Simulation
#=====================================================================

set TOP_DESIGN "dig_top"

# 1.  Search Path ()
set search_path [list . \
                      ../APR/final/ \
                      ../../model/Lib/efuse/ \
                      ../../model/Lib/smic/1.2v/ \
                      ../../model/Lib/smic/1.8v/ \
                      /mnt/hgfs/project/mi2523/model/Lib/efuse/ \
                      /mnt/hgfs/project/mi2523/model/Lib/smic/1.2v/ \
                      /mnt/hgfs/project/mi2523/model/Lib/smic/1.8v/ \
                      /mnt/hgfs/project/mi2523/impl/APR/final/]

#  SDC 
set NETLIST   "/mnt/hgfs/project/mi2523/impl/APR/final/dig_top_sim.v"
set CNST_SDC  "/mnt/hgfs/project/mi2523/impl/APR/final/top.sdc.apr"

# 
sh mkdir -p ./reports
sh mkdir -p ./sdf_out

#---------------------------------------------------------------------
# 2.  Corner 
#---------------------------------------------------------------------
# Corner 1: Max (Setup) 
set db_max   [list scc018ug_uhd_rvt_ss_v1p08_125c_basic.db S0153GEFUSE_PIPO256B_V0.3.1_ss_V1p62_125C_2013.db]
set spef_max "/mnt/hgfs/project/mi2523/impl/APR/final/dig_top.SPEF.max"

# Corner 2: Min (Hold) ——   FF 
set db_min   [list scc018ug_uhd_rvt_ff_v1p98_-40c_basic.db S0153GEFUSE_PIPO256B_V0.3.1_ss_V1p62_125C_2016.db]
set spef_min "/mnt/hgfs/project/mi2523/impl/APR/final/dig_top.SPEF.min"

#---------------------------------------------------------------------
# 3.  Corner  SDF
#---------------------------------------------------------------------
foreach corner {max min} {
    echo "========================================="
    echo "  Running STA for Corner: [string toupper $corner]"
    echo "========================================="
    
    if {$corner == "max"} {
        set target_library $db_max
        set spef_file      $spef_max
    } else {
        set target_library $db_min
        set spef_file      $spef_min
    }
    set link_library [concat "*" $target_library]

    #  Netlist 
    read_verilog $NETLIST
    current_design $TOP_DESIGN
    link
    
    # 
    read_sdc -echo $CNST_SDC
    read_parasitics $spef_file
    
    #  Corner  Timing 
    report_constraint -all_violators > ./reports/violators_${corner}.rpt
    report_timing -delay_type [expr {$corner == "max" ? "max" : "min"}] > ./reports/timing_${corner}.rpt
    
    #  SDF 
    write_sdf -version 3.0 ./sdf_out/dig_top_${corner}.sdf
    
    # 
    remove_design -all
    remove_lib -all
}

#---------------------------------------------------------------------
# 4.  CMD-003  SEL-005 
#---------------------------------------------------------------------
echo "========================================="
echo "  Merging MAX and MIN Delays into Final SDF"
echo "========================================="

#  Max 
set target_library $db_max
set link_library [concat "*" $target_library]
read_verilog $NETLIST
current_design $TOP_DESIGN
link

#  read_sdf  -max_file  -min_file
#  PT 
read_sdf -max_file ./sdf_out/dig_top_max.sdf -min_file ./sdf_out/dig_top_min.sdf

#  MIN  MAX  Sign-off SDF 
write_sdf -version 3.0 /mnt/hgfs/project/mi2523/impl/APR/final/dig_top_multi_corner.sdf

# 
#sh rm -rf ./sdf_out/dig_top_max.sdf ./sdf_out/dig_top_min.sdf
echo "Sign-off SDF Generation Done Successfully!"
exit