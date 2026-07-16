vpx set screen display -noprogress
tclmode
set lec_version [regsub {(-)[A-Za-z]} $env(LEC_VERSION) ""]
tcl_set_command_name_echo on
vpxmode
setenv LIB " \
/nFsmount/group/cad/IP/IP_SL016ZBCD_oa/SC18_SL0162BCD_silergy_VZ/lib/ccs_ss_vlp7^150c.lib /nfsmount/group/cad/IP/IP_SL0162BCD_oa/SC18_SL0162BCD_silergy_V2/lib/ccs_tt_vlp8_25c.lib \
"
set log file eco.log.$LEC_VERSION -replace
usage -auto -elapse
tclmode
//set_lowpower_option -native_1801
//set_lowpower_option -golden_analysis_style post_synthesis
//set_lowpower_option -revised_analysis_style post_synthesis
vpxmode
set eco option -flat
tclmode
add_search_path -library . /nrsmount/group/cad/IP/IP_SL0162BCD_oa/SC18_SL0162BCD_silergy_V2/lib/
read_library -statetable -liberty -both \
/nrsmount/group/cad/IP/IP_SL0162BCD_oa/SC18_SL0162BCD_silergy_V2/lib/ccs_ss_vlp71_150c.lib /nfsmount/group/cad/IP/IP_SL0162BC0_oa/SC18_SL0162BCD_silergy_V2/lib/ccs_tt_vlp8_25c.lib

delete_search_path -all -design -revised

//read the PR netlist
read_design -verilog95 -golden -lastmod -noelab ./DT60A_DIG.v.gz
elaborate_design -golden -root {DT60A_DIG}
//read the new netlist after synthesis
read_design -verilog95 -revised -lastmod -noelab /rhome/ind/groups/degrp_sh/proj/0T60A/asicdsgn/co/DT60A/impl/syn/1227/result/DT60A_0IG_syn.v
elaborate_design -revised -root {DT60A_DIG}
set_root_module DT60A_DIG -both
vpxmode
report design data
report black box
flatten -nolibrary -matchhierarchy -use_renaming_rules -revised
uniquify -all -nolibrary -use_renaming_rules -revised

tclmode

set_flatten_model -seq_constant
set_flatten_model -seq_constant_x_to 0
set_Flatten_model -nodfr_to_d1at_zero
set_Flatten_model -nodrr_to_dlat_Feedback
set_flatten_model -hier_seq_merge
set_flatten_model -gated_clock

set_mapping_method -alias -both
add_renaming_rule rlalias _reg(%w?(/U\\\$%d)*)$ @1 -type dff dlat -both
add_primary_input u_dig_ctrl_top_wrap/u_dig_ctrl_top/u_loop_ctrl/u_pi/en -both
add_pin_constraints 0 {ui_dig_ctrl_top_wrap/u_dig_ctrl_top/u_loop_ctrl/u_pi/en} -both

add_pin_constraints 0 {SCAN_EN} -both

set_compare_eFfort auto
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
-library $LIB \
-sdc /rhome/ind/groups/degrp_sh/prQj/DT60A/asicdsgn/co/DT60A/impl/syn/1227/result/DT60A_DIG_func.sdc \
-INStancenaming "EC02inst_%d" -NETnaming "EC02net_%d" -SEQuentialnaming "EC02reg_%s" \
-prelibscript vars.tcl \
-synexec "genus -legacy_ui" \
-VERbose \
-SUPPRESS_SDCError \
-map swapcells.tcl \

report eco change -inn -file eco_changes.script -replace
write eco design -newFile %s.pre.v -replace -report ECOprelogics.rpt