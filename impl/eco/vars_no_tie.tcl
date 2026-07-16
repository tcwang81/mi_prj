# 1. 舊版 UI 真正對應的「禁止刪除未使用暫存器/優化常數」設定
set_attribute delete_unloaded_seqs false /
set_attribute hdl_preserve_unused_registers true /
set_attribute optimize_constant_0_flops false /
set_attribute optimize_constant_1_flops false /

# 2. 舊版最底層常數網路控制（避免長出新的 Tie Cells）
set_attribute use_tiehilo_for_const none /
