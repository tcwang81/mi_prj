# 1. Get the current date in YYYYMMDD format (e.g., 20260701)
DATE_DIR := $(shell date +%Y%m%d)

.PHONY: cdc clean

cdc:
	@echo "==> Creating daily directory: $(DATE_DIR) <=="
	# 2. Create the subdirectory named after the current date
	mkdir -p $(DATE_DIR)
	
	# 3. Copy cdc.do to the daily directory so Conformal can locate it
	cp cdc.do $(DATE_DIR)/
	
	# 4. Change directory to the daily folder and run ccd. 
	#    This ensures all generated logs and temporary files stay organized inside it.
	cd $(DATE_DIR) && ccd -xl -d cdc.do

clean:
	@echo "==> Cleaning logs <=="
	rm -f *.log
	# Optional: Uncomment the line below if you want to remove the daily directory during clean
	# rm -rf $(DATE_DIR)
