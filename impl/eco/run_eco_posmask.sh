#!/bin/bash

# 1. 取得當前日期 (格式: YYYYMMDD，例如 20260604)
DATE_DIR=${1:-$(date +%Y%m%d)}

# 定義 Log 檔案路徑與名稱 (放在當天目錄的上一層，避免 cd 進去後路徑錯亂，或直接指定路徑)
LOG_FILE="./eco_flow_${DATE_DIR}.log"

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
mkdir -p ./${DATE_DIR}/eco_patch
# 3. 將 Conformal 必要的腳本與設定檔複製/連結到日期目錄下
cp eco_posmask.do ./${DATE_DIR}/
cp vars_no_tie.tcl ./${DATE_DIR}/

# 4. 切換進去該日期目錄
cd ./${DATE_DIR}

# 🌟 關鍵新增：直接指明鎖定授權的實體檔案路徑
export CDS_LIC_FILE=/EDA/lic/cadence_lic.dat

# 5. 在該日期目錄下啟動 Conformal LEC (帶上正確的 -ECO 授權)
echo "Launching Conformal LEC in ./${DATE_DIR}..."
echo "--------------------------------------------------"

# 執行工具（因為前面用了 exec tee，這裡不需要再手動重導向，它會自動被記錄）
lec -nogui -dofile ../eco_posmask.do -ecogxl -log repot_ecoflow.log

echo "--------------------------------------------------"
echo "=================================================="
echo " ECO Flow Done for Folder: ./${DATE_DIR}"
echo " End Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo "=================================================="
