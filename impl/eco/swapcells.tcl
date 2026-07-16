# ====================================================================
# Genus Common UI - swapcells.tcl (Fuzzy Pattern Matching)
# ====================================================================

# 1. 先將所有元件設為不可使用
set_db [get_db lib_cells *] .avoid true

# 2. 只允許名字中包含 "SPARE" 或 "SP" 的元件參與 ECO 優化
set_db [get_db lib_cells **/*spare_*] .avoid false

