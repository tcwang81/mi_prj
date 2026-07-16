# ==============================================================================
# Cadence Genus ECO Environment (vars.tcl) - Common UI Fix
# ==============================================================================
# 使用符合 Common UI 規範且帶有明確階層的 set_db 語法
if {[current_design] != ""} {
    set_db [current_design] .eco_spare_cell_pattern "*xspare_*"
    set_db [current_design] .eco_honor_leaf_connect true
} else {
    set_db / .eco_spare_cell_pattern "*xspare_*"
    set_db / .eco_honor_leaf_connect true
}

catch { suppress_message {SYNTH-10 TUI-182 TUI-183 TUI-509 MESG-10} }
# ==============================================================================

# ? 註冊掛鉤：指派給 Genus ECO 合成優化前置點
set_db eco_architecture_patch "do_hierarchical_pin_patch"
puts "SUCCESS: Common UI vars.tcl template loaded smoothly."