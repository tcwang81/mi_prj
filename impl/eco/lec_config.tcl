# ==============================================================================
# MI2523 LEC ECO Configuration File
# ==============================================================================
set PROJECT_NAME    "MI2523"
set TOP_MODULE      "dig_top"
set THREAD_NUM      16
set WORK_DIR        "./result"
set TMP_DIR         "./eco.tmp"

# Standard Cell Library 設定
set LIB_SEARCH_PATH "/mnt/hgfs/project/mi2523/model/Lib/smic/1.2v/"
set LIB_FILES " \
    /mnt/hgfs/project/mi2523/model/Lib/smic/1.2v/scc018ug_uhd_rvt_ss_v1p08_125c_basic.lib "

# 設計檔案與 SDC 路徑
set GOLDEN_NETLIST  "../../APR/final/dig_top_sim.v"
set SDC_FILE        "../../syn/script/constraint_func.sdc"

# 新 RTL 的 Filelist 指向 (.f 檔內每行寫一個 RTL 檔案路徑即可)
set REVISED_FILE_LIST "../../../hdl/dig_top/dig_top_inc.v"

# 常數約束 (Scan 鏈關閉)
set PIN_CONSTRAINTS [list \
    "SCAN_EN" "0" \
]
