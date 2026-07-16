# ==============================================================================
# Genus ECO Synthesis Configuration (Post-Link Stage)
# ==============================================================================
puts "INFO: Executing lock_spares.tcl - Post-Link ECO Environment Setup..."

# 1. 此時設計已 Link 完成，可以安全設定全域 ECO 屬性
catch { set_db / .design_is_eco true }
catch { set_db / .eco_honor_leave_connect true }

# 2. 擴大搜尋範圍，精準撈取當前網表內所有的 Spare Instances
set my_spares [get_db instances -if {.name == $ECO_SPARE_PATTERN}]

if {$my_spares ne ""} {
    # 徹底凍結全設計（預防工具去 size-up 或改動現有的非 spare 門電路）
    set_db / .is_dont_touch true
    
    # 把你要用的 Spare Cells 的 dont_touch 解除，Genus 才能拿去接線
    set_db $my_spares .is_dont_touch false
    
    # 限制 Genus 的 ECO 引擎只能吃這些 Instance
    set_db / .eco_spare_cells $my_spares
    puts "SUCCESS: Successfully bound [llength $my_spares] spare cells to Genus ECO engine."
} else {
    error "CRITICAL ERROR: No instances matching '$ECO_RESERVED_PATTERN' found after Link! Aborting."
}