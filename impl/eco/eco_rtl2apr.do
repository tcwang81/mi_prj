// ==============================================================================
// Cadence Conformal LEC - Full Automatic RTL-to-Gate ECO Do File (Optimized)
// ==============================================================================
vpx set screen display -noprogress
tclmode

// ------------------------------------------------------------------------------
// 1. 載入獨立的 Config 設定檔
// ------------------------------------------------------------------------------
if {[file exists lec_config.tcl]} {
    puts "INFO: Loading configuration from lec_config.tcl..."
    source lec_config.tcl
} else {
    puts "ERROR: Cannot find lec_config.tcl! Process aborted."
    exit
}

// 安全取得版本資訊，防止環境變數未定義崩潰
if {[info exists env(LEC_VERSION)]} {
    set lec_version [regsub {(-)[A-Za-z]} $env(LEC_VERSION) ""]
} else {
    set lec_version "unknown"
}
tcl_set_command_name_echo on

// 將 Library 變數傳遞給環境變數，供後續 optimize patch 使用
setenv LIB $LIB_FILES

vpxmode
// 定義 Log 檔案
set log file eco_rtl2gate.log.$lec_version -replace
usage -auto -elapse

// 設定 ECO 基礎模式
set eco option -flat

tclmode
// ------------------------------------------------------------------------------
// 2. 讀取並載入 Standard Cell Library
// ------------------------------------------------------------------------------
add_search_path -library . $LIB_SEARCH_PATH
eval read_library -statetable -liberty -both $LIB_FILES

delete_search_path -all -design -revised

// ------------------------------------------------------------------------------
// 3. 讀取設計
// ------------------------------------------------------------------------------
// ---- [Golden] 讀取 APR 後的實體網表 ----
puts "INFO: Reading Golden design (APR Netlist)..."
eval read_design -verilog95 -golden -lastmod -noelab $GOLDEN_NETLIST
elaborate_design -golden -root "$TOP_MODULE"

// ---- [Revised] 讀取新修訂的 RTL Filelist (.f) ----
puts "INFO: Reading Revised design (New RTL Filelist)..."
eval read_design -verilog -revised -lastmod -noelab $REVISED_FILE_LIST
elaborate_design -revised -root "$TOP_MODULE"

// ---- [Setup Top] ----
set_root_module $TOP_MODULE -both

// 切換至 Native 進行 Flatten
vpxmode

// 報告基本設計資訊與 Black Box
report design data
report black box

// 忽略不對等階層與實體單元化簡
flatten -nolibrary -matchhierarchy -use_renaming_rules -revised
uniquify -all -nolibrary -use_renaming_rules -revised

tclmode
// ------------------------------------------------------------------------------
// 4. 建模優化與 Pin 腳約束設定
// ------------------------------------------------------------------------------
set_flatten_model -seq_constant
set_flatten_model -seq_constant_x_to 0
set_flatten_model -hier_seq_merge
set_flatten_model -gated_clock

// 啟用進階命名比對規則
set_mapping_method -alias -both
add_renaming_rule rlalias _reg(%w?(/U\\\$%d)*)$ @1 -type dff dlat -both

// 自動套用 Config 內定義的所有 Pin Constraints
foreach {pin val} $PIN_CONSTRAINTS {
    puts "INFO: Applying Pin Constraint -> $pin = $val"
    add_pin_constraints $val $pin -both
}

set_compare_effort auto
set_analyze_option -auto -report_map -EFFORT_ANALYZE_ABORT high

// ==============================================================================
// 5. 運行 LEC 比對與階層式 ECO 分析
// ==============================================================================
vpxmode
// 【修正】此時預設即為 Setup 模式，若需手動加 Pin，直接在此處下達（不需切換 system mode）
// add eco pin int_latch_2523 rdclr_int -revised -input

// 1. 進入 LEC 比對模式
set system mode lec

// 2. 加入比對點並執行主比對
add compared point -all
compare

// 3. 執行階層式 ECO 預分析
analyze hier_compare -eco_aware

// 4. 檢查 ECO 設定狀態
report eco check

// 5. 分析 ECO 並產生 Patches 【修正：明確指定 -patch_file 參數確保語法相容性】
analyze eco -hierarchical -effort ultra -ecopin_dofile ecopins.do patch.v -replace

// ==============================================================================
// 6. 套用 ECO 補丁與 Genus 邏輯合成優化 (解耦破陣完全體)
// ==============================================================================
tclmode

# 變數清洗與對齊
set CLEAN_LIB [string trim $LIB_FILES]
set CLEAN_SDC [string trim $SDC_FILE]
set system mode setup
# ? 發射：前台不使用任何會被 lock 的指令，直接啟動後台優化器
vpx optimize patch -workdir . "-library $CLEAN_LIB \
-sdc $CLEAN_SDC \
-instancenaming ECO2inst_%d \
-netnaming ECO2net_%d \
-sequentialnaming ECO2reg_%s \
-prelibscript ./vars.tcl \
-synexec  "genus -legacy_ui"  \
-verbose \
-SUPPRESS_SDCError"

// ==============================================================================
// 7. 輸出最終 ECO 結果
// ==============================================================================
vpxmode

// A. 寫出給 Innovus 用的改線腳本
write eco changes -innovus ./eco_changes_innovus.tcl -replace

// B. 寫出給 ICC2 用的改線腳本
write eco changes -icc2 ./eco_changes_icc2.tcl -replace

// B2. 寫出通用改線腳本
write eco changes ./eco_changes.tcl -replace

// C. 寫出網表
write eco design -newFile ./MI2523_ECO_final.v -replace

// D. 將 Summary 報告導出到檔案
report eco changes -summary -file ./ECO_summary.rpt -replace

tclmode
puts "=================================================================="
puts "SUCCESS: Final ECO gate netlist and ICC/Innovus scripts generated successfully."
puts "=================================================================="
exit -f