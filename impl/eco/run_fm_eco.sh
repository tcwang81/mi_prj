#!/bin/bash

# 1. 取得當前日期 (格式: YYYYMMDD，例如 20260604)
DATE_DIR=${1:-$(date +%Y%m%d)}_fm

# 定義 Log 檔案路徑與名稱 (放在當天目錄的上一層，避免 cd 進去後路徑錯亂，或直接指定路徑)
LOG_FILE="./eco_flow_${DATE_DIR}_fm.log"

# ------------------------------------------------------------------------------
# 使用 exec 與 tee 建立一個神經中樞：
# 接下來腳本內所有的 echo、工具輸出(stdout)、錯誤訊息(stderr)，都會同時倒進 $LOG_FILE 與畫面上
# ------------------------------------------------------------------------------
#exec > >(tee -a "${LOG_FILE}") 2>&1

echo "=================================================="
echo " Starting ECO Auto Flow | Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
echo " Creating directory: ./${DATE_DIR}"
echo " Log file located at: ${LOG_FILE}"
echo "=================================================="

# 2. 建立當天日期的目錄 (如果不存在的話)
mkdir -p ./${DATE_DIR}
cp fm_eco.tcl ./${DATE_DIR}
# 4. 切換進去該日期目錄
cd ./${DATE_DIR}

echo "Launching FM LEC in ./${DATE_DIR}..."
echo "--------------------------------------------------"


### START ####
##lec  -nogui -dofile eco_tc.do -ecogxl -log repot_ecoflow_tc.log
fm_shell -checkout ultra -f fm_eco.tcl | tee fm_eco_run.log

echo "--------------------------------------------------"
echo "=================================================="
echo " ECO Flow Done for Folder: ./${DATE_DIR}"
echo " End Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo "=================================================="
