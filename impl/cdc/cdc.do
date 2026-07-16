// Cadence Encounter(R) RTL Compiler RC14.28 - vl4.20-s067_l
// DoFile Generated on Thu Feb 13 16:26:47 +0800 2020

set log file ./cdc.log -replace
set dofile abort exit


read library -statetable -liberty \
/mnt/hgfs/project/MI2519/model/Lib/smic/1.2v/scc018ug_uhd_rvt_ss_v1p08_125c_basic.lib
add search path -design .
add search path -design ../../hdl


//read design -verilog2k -deFine ASIC ../../hdl/dig_top/dig_top_inc.v -lastmod -noelab
read design -sv -deFine ASIC ../../../hdl/dig_top/dig_top_inc.v -lastmod -noelab
    
elaborate design -root dig_top

report design data
report black box
report Floating signal
usage

read sdc -replace ../../syn/script/constraint_func.sdc

set system mode verify

report clock group
commit clock
Add fifo instance -default
Report fifo instance -verbose
Commit fifo
add rule set -File ccd_default_cdc_ruleset.tcl
run rule check cdc_def_rs/*
report rule check -status fail -severity error -verbose
Report rule check cdc_def_rs/*
//exit -Force
