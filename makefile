# 預設目標：顯示說明
.PHONY: help up up-file up-branch

help:
	@echo "===== Git 自動更新工具 ====="
	@echo "使用說明："
	@echo "  make up                 -> 整個 branch 更新 (fetch + pull)"
	@echo "  make up-file F=<檔名>    -> 單獨只更新（覆蓋）某個檔案"
	@echo "  make up-branch B=<分支> -> 切換並更新到指定的另一個分支"

# 1. 整個當前 Branch 更新
up:
	@echo "正在從遠端同步當前分支..."
	git fetch origin
	git pull

# 2. 單獨針對某個檔案更新 (從遠端的當前分支強制拉取最新檔案覆蓋本地)
# 使用範例：make up-file F=hdl/top.v
up-file:
	@ifndef F
		@echo "錯誤：請指定檔案名稱！範例：make up-file F=hdl/top.v"
		@exit 1
	@endif
	@echo "正在從遠端更新檔案: $(F) ..."
	git fetch origin
	git checkout origin/$(shell git branch --show-current) -- $(F)

# 3. 針對整個特定的 BRANCH 進行切換與更新
# 使用範例：make up-branch B=no_fuse_PR
up-branch:
	@ifndef B
		@echo "錯誤：請指定分支名稱！範例：make up-branch B=no_fuse_PR"
		@exit 1
	@endif
	@echo "正在切換並同步至分支: $(B) ..."
	git fetch origin
	git checkout $(B)
	git pull origin $(B)
