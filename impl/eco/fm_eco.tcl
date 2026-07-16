# ========================================================================
# 1. Global Path & Design Configurations
# ========================================================================
set DESIGN_NAME      "dig_top"
set SEARCH_PATH      ". /mnt/hgfs/project/mi2523/model/Lib/smic/1.2v/"

# 目標工藝庫 (.v 格式) / Target Technology Library (.v format)
# 修正：直接指定 Standard Cell 的 Verilog 仿真模型檔案路徑
set TARGET_LIBS_V    "/mnt/hgfs/project/mi2523/model/verilog/scc018ug_uhd_rvt.v"

# 設計網表文件 / Design Netlist Files
set REF_NETLIST      "../../../hdl/dig_top/dig_top_inc.v" ;# 新綜合網表 / New Synthesis Netlist (Revised)
set IMP_NETLIST      "../../APR/final/dig_top_sim.v"      ;# 舊 P&R 網表 / Old P&R Netlist (Golden)

# 最終輸出的 ICC2 ECO 腳本名稱 / Final Output TCL Script for ICC2
set ECO_OUTPUT_TCL   "./result/eco_to_icc.tcl"

# ========================================================================
# 2. Formality Environment & Optimization Settings
# ========================================================================
set sh_source_logging true
set_app_var search_path "$SEARCH_PATH"

# ? 確保這行確實存在，且使用標準的 set 宣告 (開啟 Formality Ultra ECO 引擎)
set eco_enable_ultra true

set sh_num_processors 16
set verification_set_gated_clock true
set_app_var verification_constant_prop_mode "TARGET"
set synopsys_auto_link_disable true
set_app_var hdlin_unresolved_modules "black_box"

# 壓制先前報錯的 RTL 解釋警告
suppress_message FMR_ELAB-059
# ========================================================================
# 3. Load Technology Libraries (直接讀入 Standard Cell Verilog)
# ========================================================================
puts "FM_INFO: Loading SMIC target libraries from Verilog simulation models..."

# 使用 -technology_library 參數告知 Formality 這些 Verilog 檔案是用作工藝庫底層，而非設計本身
# Use '-technology_library' switch to tell Formality these are technology cells, not design logic.
foreach lib_v $TARGET_LIBS_V {
    read_verilog -technology_library $lib_v
}

# ========================================================================
# 4. Load Reference Design (新修改的綜合網表 - 原 Revised)
# ========================================================================
puts "FM_INFO: Reading Reference Design (New Synthesis Netlist)..."
read_verilog -r $REF_NETLIST
set_top r:/WORK/$DESIGN_NAME

# ========================================================================
# 5. Load Implementation Design (舊的 P&R 網表 - 原 Golden)
# ========================================================================
puts "FM_INFO: Reading Implementation Design (P&R Netlist)..."
read_verilog -i $IMP_NETLIST
set_top i:/WORK/$DESIGN_NAME

# ========================================================================
# 6. Name Matching & Renaming Rules
# ========================================================================
puts "FM_INFO: Setting renaming rules and matching..."
match

# ========================================================================
# 7. Verification & ECO Analysis
# ========================================================================
puts "FM_INFO: Running Verification..."
if { [verify] == 0 } {
    puts "FM_INFO: Verification FAILED as expected. Formulating ECO Patch..."
} else {
    puts "FM_WARNING: Verification PASSED! Designs are identical. No ECO changes needed."
    exit
}

# 修正：刪除或註解掉不被當前版本支援的 analyze_eco 指令
# Fix: Comment out analyze_eco as it is not required/supported in this version
# analyze_eco


# ========================================================================
# 8. Post-Mask Spare Cells Configuration (免 Ultra 授權改寫)
# ========================================================================
puts "FM_INFO: Bypassing internal spare cell mapping due to tool license limits..."
# 註解掉不支援的指令
# set_spare_cells -cells [get_cells -hierarchical *xspare_*/*spare_*]

# ========================================================================
# 9. Export Final ECO Script for ICC2 (絕對落地版 / Absolute Path Output)
# ========================================================================
puts "FM_INFO: Writing Logic Changes..."

# 修正：直接在當前執行目錄下生成檔案（不建立新資料夾，避開 Linux 權限或相對路徑問題）
# 1. 導出所有 Failing 比對點（那 20 個錯誤點）的詳細邏輯錐差異
report_failing_points > fm_failing_points.rpt

# 2. 導出最精準的錯誤候選邏輯更動報告（直接指明哪些邏輯門接錯了）
report_error_candidates > fm_eco_error_candidates.rpt

puts "FM_INFO: SUCCESS! Logic difference has been exported successfully."
puts "FM_INFO: Check files in current folder: fm_failing_points.rpt and fm_eco_error_candidates.rpt"
exit
