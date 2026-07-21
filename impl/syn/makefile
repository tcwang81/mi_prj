# ====================================================================
# ASIC Backend Implementation Flow Makefile (Genus/LEC/Modus/Tempus)
# Run for Logic Synthesis, Formal Verification, ATPG, and STA
# ====================================================================

default: auto

# --------------------------------------------------------------------
# 1. 變數與路徑定義 (Variables & Paths)
# --------------------------------------------------------------------
PJ_NAME      := AJ01A_
PROJNAME     := AJ03A

# 版本日期定義 (優先採用外部輸入，預設為當前系統日期，防止死迴圈)
ifdef rev
    rev := $(rev)
else
    rev := $(shell date +%Y%m%d)
endif

# 實現流程各階段執行路徑
syn_run_dir  := ../../impl/syn/$(rev)
lec_run_dir  := ../../impl/lec/$(rev)
clp_run_dir  := ../../impl/clp/$(rev)
atpg_run_dir := ../../impl/atpg/$(rev)
sta_run_dir  := ../../impl/sta/$(rev)
release_dir  := ../../../../../release/$(rev)

# --------------------------------------------------------------------
# 2. 自動執行管線與整合 (Automation Pipeline)
# --------------------------------------------------------------------
auto: run

run:
	@-rm -rf $(syn_run_dir) $(lec_run_dir) $(clp_run_dir) $(atpg_run_dir) $(sta_run_dir)
	@mkdir -p $(syn_run_dir)
	@mkdir -p $(lec_run_dir)/rpt
	@mkdir -p $(atpg_run_dir)
	@mkdir -p $(sta_run_dir)
	@sed "s/auto: run/auto: syn/g" ./makefile > $(syn_run_dir)/makefile 2>/dev/null || true
	@sed "s/auto: run/auto: r2g/g" ./makefile > $(lec_run_dir)/makefile 2>/dev/null || true
	@sed "s/auto: run/auto: atpg_run/g" ./makefile > $(atpg_run_dir)/makefile 2>/dev/null || true
	@sed "s/auto: run/auto: sta/g" ./makefile > $(sta_run_dir)/makefile 2>/dev/null || true
	cd $(syn_run_dir) && $(MAKE) syn
	$(MAKE) sdc
	$(MAKE) copy
	cd $(lec_run_dir) && $(MAKE) r2g
#	$(MAKE) release

# 複製並更新各式 LEC dofiles 與合成網表
copy:
	sed "s/rev_dir/$(rev)/g; s/\.\/result/\./g; s/threads 1,4/threads 1,16/g;" $(syn_run_dir)/result/rtl2intermediate.lec.do > $(lec_run_dir)/rtl2intermediate.lec.do
	sed "s/rev_dir/$(rev)/g; s/\.\/result/\./g; s/threads 1,4/threads 1,16/g;" $(syn_run_dir)/result/intermediate2final.lec.do > $(lec_run_dir)/intermediate2final.lec.do
	sed "s/rev_dir/$(rev)/g; s/\.\/result/\./g; s/threads 1,4/threads 1,16/g;" $(syn_run_dir)/result/r2g.lec.do > $(lec_run_dir)/r2g.lec.do
	sed "s/rev_dir/$(rev)/g; s/\.\/result/\./g; s/threads 1,4/threads 1,16/g;" $(syn_run_dir)/result/g2p.lec.do > $(lec_run_dir)/g2p.lec.do
	sed "s/rev_dir/$(rev)/g; s/\.\/result/\./g; s/threads 1,4/threads 1,16/g;" $(syn_run_dir)/result/r2p.lec.do > $(lec_run_dir)/r2p.lec.do
	cp -rf $(syn_run_dir)/atpg $(atpg_run_dir)
	cp -rf $(syn_run_dir)/fv $(lec_run_dir)

# 交付物歸檔 (Release Data)
release:
	@mkdir -p $(release_dir)
	cp $(syn_run_dir)/result/dig_top_syn.v $(release_dir)
	cp $(syn_run_dir)/result/dig_top_func.sdc $(release_dir)
	cp $(syn_run_dir)/result/dig_top_shift.sdc $(release_dir)
	cp $(syn_run_dir)/result/dig_top_capture.sdc $(release_dir)
	cp $(syn_run_dir)/report/dig_top_constraint.rpt $(release_dir)
	cp $(syn_run_dir)/result/dig_top_syn.scan.def $(release_dir)

# --------------------------------------------------------------------
# 3. 各階段工具實體指令 (Tool Targets)
# --------------------------------------------------------------------

# --- 邏輯綜合階段 (Logic Synthesis) ---
syn:
	genus -files ../../../impl/syn/script/syn.tcl

dc:
	dc_shell -f ./script/run_dc.tcl | tee dc_syn.log	

# 修正 SDC 中的總線匯流排格式命名 (數字由大到小替換，防止 1 污染 10~19 等兩位數)
sdc:
	@echo "Optimizing SDC bus naming architecture..."
	@sed "s/_69]/[69]]/g; s/_68]/[68]]/g; s/_67]/[67]]/g; s/_66]/[66]]/g; s/_66]/[66]]/g; s/_65]/[65]]/g; \
	      s/_64]/[64]]/g; s/_63]/[63]]/g; s/_62]/[62]]/g; s/_61]/[61]]/g; s/_60]/[60]]/g; s/_59]/[59]]/g; \
	      s/_58]/[58]]/g; s/_57]/[57]]/g; s/_58]/[58]]/g; s/_57]/[57]]/g; s/_56]/[56]]/g; s/_55]/[55]]/g; \
	      s/_54]/[54]]/g; s/_53]/[53]]/g; s/_52]/[52]]/g; s/_51]/[51]]/g; s/_50]/[50]]/g; s/_49]/[49]]/g; \
	      s/_48]/[48]]/g; s/_47]/[47]]/g; s/_46]/[46]]/g; s/_45]/[45]]/g; s/_44]/[44]]/g; s/_43]/[43]]/g; \
	      s/_42]/[42]]/g; s/_41]/[41]]/g; s/_40]/[40]]/g; s/_39]/[39]]/g; s/_38]/[38]]/g; s/_37]/[37]]/g; \
	      s/_36]/[36]]/g; s/_35]/[35]]/g; s/_34]/[34]]/g; s/_33]/[33]]/g; s/_32]/[32]]/g; s/_31]/[31]]/g; \
	      s/_30]/[30]]/g; s/_29]/[29]]/g; s/_28]/[28]]/g; s/_27]/[27]]/g; s/_26]/[26]]/g; s/_25]/[25]]/g; \
	      s/_24]/[24]]/g; s/_23]/[23]]/g; s/_22]/[22]]/g; s/_21]/[21]]/g; s/_20]/[20]]/g; s/_19]/[19]]/g; \
	      s/_18]/[18]]/g; s/_17]/[17]]/g; s/_16]/[16]]/g; s/_15]/[15]]/g; s/_14]/[14]]/g; s/_13]/[13]]/g; \
	      s/_12]/[12]]/g; s/_11]/[11]]/g; s/_10]/[10]]/g; s/_9]/[9]]/g;   s/_8]/[8]]/g;   s/_7]/[7]]/g; \
	      s/_6]/[6]]/g;   s/_5]/[5]]/g;   s/_4]/[4]]/g;   s/_3]/[3]]/g;   s/_2]/[2]]/g;   s/_1]/[1]]/g; \
	      s/_0]/[0]]/g;" $(syn_run_dir)/result/dig_top_func.sdc > $(syn_run_dir)/result/dig_top_func.sdc.tmp
	@mv $(syn_run_dir)/result/dig_top_func.sdc.tmp $(syn_run_dir)/result/dig_top_func.sdc

# --- 形式驗證階段 (Formal Verification - LEC) ---
r2g:
	lec -lpxl -d r2g.lec.do -nogui | tee lec_r2g.log
g2p:
	lec -lpxl -d g2p.lec.do -nogui | tee lec_g2p.log
r2p:
	lec -lpxl -d r2p.lec.do -nogui | tee lec_r2p.log
lec_gui:
	lec -lpxl &

# --- 低功耗靜態驗證 (Conformal Low Power - CLP) ---
clp:
	@mkdir -p $(atpg_run_dir)/log
	lec -lpxl -verify -d clp.do -nogui | tee clp_pre.log
clp_pos:
	lec -lpxl -verify -d clp_pos.do -nogui | tee clp_pos.log
clp_gui:
	lec -lpxl -verify &

# --- 可測試性設計與測試向量生成 (ATPG) ---
atpg_run:
	modus -files ./atpg/runmodus.atpg.tcl | tee modus.log
atpg_sim:
	./atpg/run_fullscan_sira
atpg_pos_run:
	et -e ./atpg_pos/runet.atpg | tee et_pos.log
atpg_pos_sim: pos_min_sim pos_max_sim

pos_min_sim:
	rm -rf ./atpg_pos/Inca*
	./atpg_pos/run_fullscan_pos_min_sim
pos_max_sim:
	rm -rf ./atpg_pos/Inca*
	./atpg_pos/run_fullscan_pos_max_sim
atpg_sim_gui:
	simvision simvision.shm &

# --- 功耗動態/靜態分析 (Power Analysis) ---
power:	
	cd $(syn_run_dir) && genus -files ../../../impl/syn/script/power.tcl | tee power.log 
	@if [ `grep -c Error $(syn_run_dir)/power.log` -gt 6 ] ; then \
		echo "Synthesis Error count exceeded limitation!"; exit 1; \
	fi

# --- 靜態時序分析 (Static Timing Analysis - Tempus) ---
sta: func shift capture

func:
	@echo -e "set sdc_cond func\nset op_cond wcl\nset spef_cond cworst\n" > sta_cfg.tcl 
	tempus -no_gui -file ../../../impl/sta/script/sta.tcl | tee sta_func_wcl_cworst.log 
	@echo -e "set sdc_cond func\nset op_cond wcl\nset spef_cond cbest\n" > sta_cfg.tcl 
	tempus -no_gui -file ../../../impl/sta/script/sta.tcl | tee sta_func_wcl_cbest.log 
	@echo -e "set sdc_cond func\nset op_cond wc\nset spef_cond cworst\n" > sta_cfg.tcl 
	tempus -no_gui -file ../../../impl/sta/script/sta.tcl | tee sta_func_wc_cworst.log 
	@echo -e "set sdc_cond func\nset op_cond wc\nset spef_cond cbest\n" > sta_cfg.tcl 
	tempus -no_gui -file ../../../impl/sta/script/sta.tcl | tee sta_func_wc_cbest.log 
	@echo -e "set sdc_cond func\nset op_cond bc\nset spef_cond cworst\n" > sta_cfg.tcl 
	tempus -no_gui -file ../../../impl/sta/script/sta.tcl | tee sta_func_bc_cworst.log 
	@echo -e "set sdc_cond func\nset op_cond bc\nset spef_cond cbest\n" > sta_cfg.tcl 
	tempus -no_gui -file ../../../impl/sta/script/sta.tcl | tee sta_func_bc_cbest.log

shift:	
	@echo -e "set sdc_cond shift\nset op_cond wcl\nset spef_cond cworst\n" > sta_cfg.tcl 
	tempus -no_gui -file ../../../impl/sta/script/sta.tcl | tee sta_shift_wcl_cworst.log 
	@echo -e "set sdc_cond shift\nset op_cond wcl\nset spef_cond cbest\n" > sta_cfg.tcl 
	tempus -no_gui -file ../../../impl/sta/script/sta.tcl | tee sta_shift_wcl_cbest.log 
	@echo -e "set sdc_cond shift\nset op_cond wc\nset spef_cond cworst\n" > sta_cfg.tcl 
	tempus -no_gui -file ../../../impl/sta/script/sta.tcl | tee sta_shift_wc_cworst.log 
	@echo -e "set sdc_cond shift\nset op_cond wc\nset spef_cond cbest\n" > sta_cfg.tcl 
	tempus -no_gui -file ../../../impl/sta/script/sta.tcl | tee sta_shift_wc_cbest.log 
	@echo -e "set sdc_cond shift\nset op_cond bc\nset spef_cond cworst\n" > sta_cfg.tcl 
	tempus -no_gui -file ../../../impl/sta/script/sta.tcl | tee sta_shift_bc_cworst.log 
	@echo -e "set sdc_cond shift\nset op_cond bc\nset spef_cond cbest\n" > sta_cfg.tcl 
	tempus -no_gui -file ../../../impl/sta/script/sta.tcl | tee sta_shift_bc_cbest.log

capture:	
	@echo -e "set sdc_cond capture\nset op_cond wcl\nset spef_cond cworst\n" > sta_cfg.tcl 
	tempus -no_gui -file ../../../impl/sta/script/sta.tcl | tee sta_capture_wcl_cworst.log 
	@echo -e "set sdc_cond capture\nset op_cond wcl\nset spef_cond cbest\n" > sta_cfg.tcl 
	tempus -no_gui -file ../../../impl/sta/script/sta.tcl | tee sta_capture_wcl_cbest.log 
	@echo -e "set sdc_cond capture\nset op_cond wc\nset spef_cond cworst\n" > sta_cfg.tcl 
	tempus -no_gui -file ../../../impl/sta/script/sta.tcl | tee sta_capture_wc_cworst.log 
	@echo -e "set sdc_cond capture\nset op_cond wc\nset spef_cond cbest\n" > sta_cfg.tcl 
	tempus -no_gui -file ../../../impl/sta/script/sta.tcl | tee sta_capture_wc_cbest.log 
	@echo -e "set sdc_cond capture\nset op_cond bc\nset spef_cond cworst\n" > sta_cfg.tcl 
	tempus -no_gui -file ../../../impl/sta/script/sta.tcl | tee sta_capture_bc_cworst.log 
	@echo -e "set sdc_cond capture\nset op_cond bc\nset spef_cond cbest\n" > sta_cfg.tcl 
	tempus -no_gui -file ../../../impl/sta/script/sta.tcl | tee sta_capture_bc_cbest.log	

# --- 獨立打包打包前端代碼用網表 ---
dc_net:
	cat ../../hdl/i2c/i2c.v \
	    ../../hdl/spi/spi_slave.v \
	    ../../hdl/sync.v \
	    ../../hdl/fifo/fifo.v \
	    ../../hdl/efuse/efuse_ctrl.v \
	    ../../hdl/regfile_define.v \
	    ../../hdl/rst_sync.v

# --- 清理暫存檔案 ---
clean:
	rm -rf rc* libscore_work fv sta_cfg.tcl log
