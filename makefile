.PHONY: help update sync push gui update-file force-reset

CURRENT_BRANCH := $(shell git branch --show-current 2>/dev/null || echo "main")
GITEA_URL := $(shell git config --get remote.origin.url 2>/dev/null | sed -E 's/git@([^:]+):/https:\/\/\1\//' | sed 's/\.git$$//')

help:
	@echo "=================================================================="
	@echo "                     Gitea / Git 免維護自動化工具                  "
	@echo "=================================================================="
	@echo " ? 目前分支: [$(CURRENT_BRANCH)]"
	@echo "------------------------------------------------------------------"
	@echo " make gui                  -> 啟動 Linux gitk 圖形介面 (看差異)"
	@echo " make update               -> [下載] 正常獲取雲端狀態並更新"
	@echo " make update-file file=路徑 -> [特定] 單獨強制下載更新某個檔案"
	@echo " make sync                 -> [一鍵] 自動更新雲端進度 + 自動上傳修改"
	@echo " make force-reset          -> [大絕] 放棄本地修改，強制刷成雲端最新"
	@echo "=================================================================="

gui:
	@if [ -z "$$DISPLAY" ] && [ -z "$$WAYLAND_DISPLAY" ]; then echo "? 錯誤：請在視窗環境下執行！"; exit 1; fi
	@if command -v gitk >/dev/null 2>&1; then gitk --all & else echo "? 錯誤：未安裝 gitk！"; exit 1; fi

update:
	git fetch --all --tags --prune
	git pull origin $(CURRENT_BRANCH) --rebase

update-file:
	@if [ -z "$(file)" ]; then echo "? 錯誤：請指定檔案路徑！範例: make update-file file=main.c"; exit 1; fi
	git fetch origin $(CURRENT_BRANCH)
	git checkout origin/$(CURRENT_BRANCH) -- $(file)

push:
	git add .
	@if [ -n "$$(git status --porcelain)" ]; then \
		git commit -m "Auto-sync: $$(date '+%Y-%m-%d %H:%M:%S')"; \
		git push origin $(CURRENT_BRANCH); \
	else \
		echo "沒有發現變更，無需上傳。"; \
	fi

sync: update push

force-reset:
	@echo "? 警告：這將會徹底刪除您本地所有未上傳的修改！"
	@read -p "您確定要強制還原整個專案嗎？[y/N]: " ans; \
	if [ "$$ans" = "y" ] || [ "$$ans" = "Y" ]; then \
		git fetch --all --tags --prune; \
		git reset --hard origin/$(CURRENT_BRANCH); \
		git clean -fd; \
		echo "? 成功！專案已強制同步為雲端最新狀態！"; \
	else \
		echo "已取消操作。"; \
	fi
