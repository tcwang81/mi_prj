# 新版使用 set_db 統一控制根目錄屬性
set_db compile_delete_unloaded_seqs false
set_db compile_delete_unloaded_insts false

# 或是針對特定執行個體加上 preserve 屬性
#set_db [get_db insts <inst_name>] .preserve size_ok
# 阻止網表中的常數被替換為新的 tie cells
set_db use_tiehilo_for_const none
