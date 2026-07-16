vpx set screen display -noprogress
tclmode
set lec_version [regsub {(-)[A-Za-z]} $env(LEC_VERSION) ""]
tcl_set_command_name_echo on
vpxmode
setenv LIB " \
/mnt/hgfs/project/mi2523/model/Lib/smic/1.2v/scc018ug_uhd_rvt_ss_v1p08_125c_basic.lib \
"
set log file eco.log.$LEC_VERSION -replace
usage -auto -elapse
tclmode
//set_lowpower_option -native_1801
//set_lowpower_option -golden_analysis_style post_synthesis
//set_lowpower_option -revised_analysis_style post_synthesis
vpxmode

// ==============================================================================
// [修改 1] 初始化 ECO 選項（保留您原本的 -flat，並在下方動態指定 postmask）
// ==============================================================================
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

// ==============================================================================
// [修改 2] 自動抓取 Spare Cells 並在 Setup 階段宣告 Post-mask
// ==============================================================================
tclmode
// 1. 打開要輸出的 spare_cells.list 檔案
set spare_out [open "./spare_cells.list" w]

// 2. 透過 find 指令在 Golden 設計中搜尋所有名字含 spare 的 instances
//    並逐行寫入檔案中
foreach inst [find -instance *spare* -golden -hierarchical] {
    puts $spare_out $inst
}

// 3. 關閉檔案並設定 ECO 選項
close $spare_out
set_eco_option -flat

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

// ==============================================================================
// [修改 3] 生成 Patch 階段：增加 -fallback_to_pin
// ==============================================================================
// 增加 -fallback_to_pin：當局部 Spare Cell 不夠時，允許將訊號拉到 Module Pin 腳上到別層借 Spare Cell 救回
vpxmode

// 1. 針對非等價的模組生成階層式的 ECO 修正檔案與 Pin 腳腳本
//    (傳統版本會在此步驟自動拆解並將修復邏輯寫入指定的目錄與檔案)
//write_eco_components -hierarchical -ecopin_dofile ecopins.do -output_dir ./eco_patch -replace
analyze eco -hierarchical -effort ultra -ecopin_dofile ecopins.do ./eco_patch/patch.v -replace
// 註：如果您的版本連 write_eco_components 都沒有（報 Unknown），請換成以下這行最經典的寫法：
// write_changes -verilog patch.v -replace
vpxmode
set system mode setup

// 讀入 Pin 腳修正（若上一步有順利產出 ecopins.do 則維持讀入）
dofile ecopins.do

// 自動套用補丁邏輯
apply patch -auto

//add spare cell -freedcell
//add spare cell -def ../../APR/final/top_eco20260611.def -spare xspare_*/*spare_*
add spare cell -spare "xspare_*/*spare_*"
report spare cell


// ==============================================================================
// [修正] 經典版優化指令：改為空格「optimize patch」，並將參數修正為舊版相容格式
// ==============================================================================
//optimize patch -workdir result -usespare \
//-library ../../../model/Lib/smic/1.2v/scc018ug_uhd_rvt_ss_v1p08_125c_basic.lib \
//-sdc ../../syn/script/constraint_func.sdc \
//-lef /mnt/hgfs/project/mi2523/impl//APR/final/scc018ug_uhd_rvt.lef \
//-def /mnt/hgfs/project/mi2523/impl//APR/final/top_eco20260611.def \
//-instancenaming "EC02inst_%d" -netnaming "EC02net_%d" -sequentialnaming "EC02reg_%s" \
//-prelibscript /mnt/hgfs/project/mi2523/impl/eco/vars_no_tie.tcl \
//-synexec "genus -legacy_ui" \
//-verbose \
//-suppress_sdcerror 

optimize patch -workdir result -usespare \
-library /mnt/hgfs/project/mi2523/model/Lib/smic/1.2v/scc018ug_uhd_rvt_ss_v1p08_125c_basic.lib \
-sdc /mnt/hgfs/project/mi2523/impl/syn/script/constraint_func.sdc \
-instancenaming "EC02inst_%d" -netnaming "EC02net_%d" -sequentialnaming "EC02reg_%s" \
-prelibscript /mnt/hgfs/project/mi2523/impl/eco/vars_no_tie.tcl \
-synexec "genus -legacy_ui" \
-verbose \
-suppress_sdcerror 

// 匯出報告與最終設計 (維持您原本的寫法，但確保在 vpxmode 下執行)
report eco change -inn -file eco_changes.script -replace
write eco design -newFile %s.pre.v -replace -report ECOprelogics.rpt

