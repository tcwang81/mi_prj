vpx set screen display -noprogress
tclmode
set lec_version [regsub {(-)[A-Za-z]} $env(LEC_VERSION) ""]
tcl_set_command_name_echo on
vpxmode

set log file eco.log.$LEC_VERSION -replace
usage -auto -elapse
tclmode
//set_lowpower_option -native_1801
//set_lowpower_option -golden_analysis_style post_synthesis
//set_lowpower_option -revised_analysis_style post_synthesis
vpxmode
set eco option -flat
tclmode
add_search_path -library . /mnt/hgfs/project/mi2523/model/Lib/smic/1.2v/
read_library -statetable -liberty -both \
/mnt/hgfs/project/mi2523/model/Lib/smic/1.2v/scc018ug_uhd_rvt_ss_v1p08_125c_basic.lib

delete_search_path -all -design -revised

//read the PR netlist
read_design -verilog95 -golden -lastmod -noelab ../../APR/final/dig_top_sim.v
elaborate_design -golden -root {dig_top}
//read the new netlist after synthesis
eval read_design -verilog -revised -lastmod -noelab  ../../../hdl/dig_top/dig_top_inc.v
elaborate_design -revised -root {dig_top}
set_root_module dig_top -both
vpxmode
report design data
report black box
flatten -nolibrary -matchhierarchy -use_renaming_rules -revised
uniquify -all -nolibrary -use_renaming_rules -revised

tclmode

set_flatten_model -seq_constant
set_flatten_model -seq_constant_x_to 0
set_flatten_model -nodff_to_dlat_zero
set_flatten_model -nodff_to_dlat_feedback
set_flatten_model -gated_clock
set_flatten_model -hier_seq_merge

set_mapping_method -alias -both
add_renaming_rule rlalias _reg(%w?(/U\\\$%d)*)$ @1 -type dff dlat -both
//add_primary_input u_dig_ctrl_top_wrap/u_dig_ctrl_top/u_loop_ctrl/u_pi/en -both
//add_pin_constraints 0 {ui_dig_ctrl_top_wrap/u_dig_ctrl_top/u_loop_ctrl/u_pi/en} -both

//add_pin_constraints 0 {SCAN_EN} -both

set_compare_effort auto
set_analyze_option -auto -report_map -EFFORT_ANALYZE_ABORT high
vpxmode

//set root module pd_wake -both
set parallel op -threads 16 -info
set compare op -threads 16
set parallel op -tmpdir eco.tmp
set analyze opt -auto -report_map
set system mode lec
check eco setup
report pin constraints > eco.constraints.rpt

analyze hier_compare -doFile hier_analyze.do -replace -eco_aware -verbose

add compared point -all
compare

check eco setup
compare eco hierarchy

check eco setup
report eco hierarchy -noneq -verbose

analyze eco -hierarchical -efFort ultra -ecopin_dofile ecopins.do patch.v -replace

set system mode setup
dofile ecopins.do
apply patch -auto

optimize patch -workdir result \
-library /mnt/hgfs/project/mi2523/model/Lib/smic/1.2v/scc018ug_uhd_rvt_ss_v1p08_125c_basic.lib \
-sdc ../../APR/final/top.sdc.apr \
-instancenaming "EC02inst_%d" -netnaming "EC02net_%d" -sequentialnaming "EC02reg_%s" \
-prelibscript vars_tc.tcl \
-synexec  "genus -legacy_ui" \
-verbose \
-SUPPRESS_SDCError 

report eco change -inn -file eco_changes.script -replace
write eco design -newFile %s.pre.v -replace -report ECOprelogics.rpt
