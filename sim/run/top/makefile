# ============================
# Makefile for simulation
# run in sim/run/top dir
# 1. make help
# 2. make all
# 2. make run tc=xxx
# 3. make gui tc=xxx
# run in sim/rtl_sim/TESTNAME dir
# 1. make sim
# 2. make deb
# ============================

default: all
USERNAME = 'whoami'
PPOJNAME = AJ03A
#BROJNAME = 'cat CVS/Repository / avk -F/ '{print $$1}''

PROJNAME_SIM = $(PROJNAME)_SIM

# ARM Cortex M0 image
TESTNAME = tc
ifdef tc
TESTNAME = $(tc)
endif

rev?=`date +%Y%m%d`
SDF_FILE?='"../../../impl/APR/tapeout/dig_top_max.sdf"

# Debug Tester im
DEBUGTESTER = $(tc)

# Boot Loader image
BOOTLOADER = bootloader

SW_MAKE_OPTIONS = TESTNAME=$(TESTNAME)

TESTLIST = test_i2c test_spi test_reg test_iir test_fifo test_efuse test_sw_mode test_adc test_adc_dbg test_if_mix

ifdef tlist
TESTLIST = $(tlist)
endif

ifeq  ($(dump) ,0)                          
	MCRO_DEFINE= -define NO_DUMP_SHM
else                                        
	MCRO_DEFINE= -define DUMP_SHM      
endif
                                    
ifeq  ($(fsdb) ,1)                          
	MCRO_DEFINE+= -define DUMP_FSDB     
else                                        
	MCRO_DEFINE+= -define NO_DUMP_FSDB
endif

ifeq ($(vcd),l)
	MCRO_DEFINE+= -define vcd

	MCRO_DEFINE+= -define no_vcd
endif

ifeq ($(tcf),l)
	TCF_DEFINE=-input ../../../sim/run/top/dumptcf
else
	TCF_DEFINE=
endif

ifeq ($(cov),1)
	COV_DEFINE=-define COV SIM -coverage all -covdut AJOlA_DIG_TOP \
        -covwork ../../../sim/$(NAME)_sim/coverage/cov_work -covtest $(TESTNAME) \
        -covfile ../../../sim/run/top/chip.ccf -covoverwrite
else
	COV_DEFINE=
endif

ifeq ($(cpf),l)
	CPF_DEFINE=-define CPF_SIM -lps_cpf ../../../impl/clp/cpf/chip_top_sim.cpf \
	-lps_simctrl_on -lps_verbose 4
else
	CPF_DEFINE=
endif



#############

CUR_DIR= $(shell pwd)
SIM= $(CUR_DIR)/../../../sim
CUR_DIR_MODEL= $(realpath ../../../model)
CUR_DIR_SIM = $(realpath ../../../sim)
CUR_DIR_HDL = $(realpath ../../../hdl)

TEST_DIR =$(shell find $(SIM)/tests/ -name $(TESTNAME) -type d)

TBENCH_NC = ../../../sim/run/top/dig_top_tb.f
SIM_DIR = ../../../sim/rtl_sim/$(TESTNAME)
NAME      =  rtl

ifdef fpga
TBENCH_NC = ../../../sim/run/top/dig_top_tb_fpga.f
SIM_DIR = ../../../sim/fpga_sim/$(TESTNAME)
NAME      =  fpga
endif

ifdef fpga_pos
TBENCH_NC = ../../../sim/run/top/dig_top_tb_fpga_pos.f
SIM_DIR = ../../../sim/fpga_posim/$(TESTNAME)
NAME      =  fpga_pos
endif

ifdef pos_min
TBENCH_NC = ../../../sim/run/top/dig_top_tb_pos.f
SIM_DIR = ../../../sim/pos_lt_sim/$(TESTNAME)
NAME      =  pos_min
MCRO_DEFINE += +no_notifier -define pos -define BC  -nowarn CUVWSP -nowarn SDFNCAP -nowarn SDFNET \
				-sdf_verbose -sdfstats sdf_annotation_stats.log
endif

ifdef pos_max
TBENCH_NC = ../../../sim/run/top/dig_top_tb_pos.f
SIM_DIR = ../../../sim/pos_wc_sim/$(TESTNAME)
NAME      = pos_max
MCRO_DEFINE += +no_notifier -define pos -define WC  -nowarn CUVWSP -nowarn SDFNCAP -nowarn SDFNET \
                                 -sdf_verbose -sdfstats sdf_annotation_stats.log
endif

ifdef pos_typ
TBENCH_NC = ../../../sim/run/top/dig_top_tb_pos.f
SIM_DIR = ../../../sim/pos_typ_sim/$(TESTNAME)
NAME      = pos_typ
MCRO_DEFINE += +no_notifier -define pos -define TP -tfile ../../../sim/run/top/chip_top.tcheck -nowarn CUVWSP -nowarn SDFNCAP -nowarn SDFNET \
                           -sdf_verbose -sdfstats sdf_annotation_stats.log
endif

ifdef gate
TBENCH_NC = ../../../sim/run/top/dig_top_tb_gate.f
SIM_DIR = ../../../sim/gate_sim/$(TESTNAME)
NAME      =  gate
endif

auto: run
#### run in sim/run/top dir
all:
	for thistest in $(TESTLIST); do \
		echo $$thistest; \
		make run tc=$$thistest $(NAME)=1; \
	done
	make check

check:
	@echo "*** Check the simulation result! please view check.$(NAME).rpt! ***"
	@echo "############## PASSED: ##############   > check.$(NAME).rpt
	@grep -1 "TEST PASSED" ../../$(NAME _sim/*/irun.log | sed "s/irun.log//g" >> check.$(NAME).rpt
	@echo "############## FAILED: ##############   >> check.$(NAME).rpt
	@grep -L "TEST PASSED" ../../$(NAME)_sim/*/irun.log | sed "s/irun.log//g" >> check.$(NAME).rpt
	@echo "############## CODE FAILED: ##############" >> check.$(NAME).rpt
	@grep -l "Problem reading hex file" ../../S(NAME)_sim/*/code.log | sed "s/code.log//g" >> check.$(NAME).rpt
	@echo "############## SUMMARY: ##############" >> check.S(NAME).rpt
	@echo "total : 'ls ../../$(NAME)_sim/*/image.mif | wc -l'" >> check.$(NAME).rpt
	@echo "finished: 'grep -l "Test Ended\|TEST PASSED" ../../$(NAME)_sim/*/irun.log | wc -l'" >> check.$(NAME).rpt
	@echo "passed : 'grep -l "TEST PASSED" ../../$(NAME)_sim/*/irun.log | wc -l'" >> check.S(NAME).rpt
	@echo "failed : 'grep -L "TEST PASSED" ../../$(NAME)_sim/*/irun.log | wc -l'" >> check.$(NAME).rpt
	@echo "code failed : 'grep -l "Problem reading hex file" ../../$(NAME)_sim/*/code.log | wc -l'" >> check.$(NAME).rpt
	@more check.$(NAME).rpt

# Compile debugtester
# Note : The use of ls after compile allows the computing server to sync up
debugtester:
	@if [ I -d $(SIM_DIR) ) ; then \
                 mkdir -p $(SIM_DIR); \
	fi
	@cd ../../soft/debug_tester ;\
	make all $(SW_MAKE_OPTION) ;\
	echo Compile done ;\
        ls > /dev/null ;\
        echo Copy $(DEBUGTESTER)_le.hex ;\
        if [ -e $(DEBUGTESTER)_le.hex ] ; then \
		cp $(DEBUGTESTER)_le.hex $(SIM_DIR)/debugtester_le.hex ;\
        else \
        echo Wait for hex file ...;\
        ls > /dev/null ;\
        sleep 5 ; \
        if [ -e $(DEBUGTESTER)_le.hex ] ; then \
        cp $(DEBUGTESTER)_le.hex $(SIM_DIR)/debugtester_le.hex ;\
        fi;\
        fi ;\
        echo Copy $(DEBUGTESTER)_be.hex ;\
        if ( -e $(DEBUGTESTER)_be.hex ] ; then \
          cp $(DEBUGTESTER)_be.hex ../../run/debugtester_be.hex ;\
        else \
          echo Wait for hex file ...;\
          ls > /dev/null ;\
          sleep 5 ; \
          if [ -e $(DEBUGTESTER)_be.hex ) ; then \
            cp $(DEBUGTESTER) be.hex ../../run/debugtester_be.hex ;\
          fi ;\
		fi;\
        if [ | -e $(DEBUGTESTER)_le.hex ] && [ | -e $(DEBUGTESTER)_be.hex ]
		echo Problem reading hex file ;\
		exit 1 ;\
        fi


run :
        #&-rm -rf $(SIM_DIR)/INCA_libs;
	@-rm -rf $(SIM_DIR)/xcelium.d;
	@if [ ! -d $(SIM_DIR) ] ; then \
		mkdir -p $(SIM_DIR); \
	fi
	sed "s/TESTNAME - test_ce/TESTNAME = $(TESTNAME)/g" ./makefile > $(SIM_DIR)/makefile
	#@make code tc=$(TESTNAME) / tee $(SIM_DIR)/code.log;
	#@if test $(findstring tpga,$(NAME)) ; then \
	#       ln -f -s ../../../hdl/mem/fpga/sdmadc/*.mif S(SIM_DIR) ;\
        #fi
	@cd $(SIM_DIR) && make sim tc=$(TESTNAME);
	cd $(CUR_DIR);

### run in sim/$(TESTNAME) dir
################
# compi1e code
################
code:

	ifeq ($(TESTNAME), )
	$(error Please specify TESTNAME on the make command line)
	endif
	@if [ -d "../../../sim/soft/testcodes/$(TESTCASE)" ] ; then \
		cd ../../../sim/soft/testcodes: \
		make all $(SW_MAKE_OPTIONS) ; \
	echo Compile done ;\
		ls > /dev/null ;\
	echo Copy $(TESTNAME)/$(TESTNAME).hex ;\
	if [ -e $(TESTNAME)/$(TESTNAME).hex ] ; then \
		cp $(TESTNAME)/$(TESTNAME).hex $(SIM_DIR)/image.hex ; \
		cp $(TESTNAME)/$(TESTNAME).mif $(SIM_DIR)/image.mif ; \
	else \
	echo Wait for hex file ...; \
		ls > /dev/null ;\
	sleep 5 ; \
	if [ -e $(TESTNAME)/$(TESTNAME).hex ] ; then \
		cp $(TESTNAME)/$(TESTNAME).hex $(SIM_DIR)/image.hex ; \
		cp $(TESTNAME)/$(TESTNAME).mif $(SIM_DIR)/image.mif ; \
	else \
	echo Problem reading hex file ;\
		exit 1; \
	fi;\
	fi;\
	cd ../../../sim/run/top;\
	ln -f -s $(CUR_DIR)/bootloader.hex $(SIM_DIR)/bootloader.hex ; \
	ln -f -s $(CUR_DIR)/bootloader.mif $(SIM_DIR)/bootloader.mif ; \
	cp ./info.hex S(SIM_DIR)/info.hex ; \
	else \
	echo "ERROR: invalid TESTNAME value ( $(TESTNAME) )" ;\
	exit 1 ;\
	fi ;\
################
# simulation
################

NCSIM_OPTION = -incdir $(TEST_DIR) \
	+neg_tchk -access rwc -vlog_ext .v,.vo,.inc \
        -f $(TBENCH_NC) -define $(NAME) $(MCRO_DEFINE) $(TCF_DEFINE) $(COV_DEFINE) $(CPF_DEFINE) +TESTNAME=$(TESTNAME) -fsmdebug

VERDI_OPTION = -incdir $(TEST_DIR) \
		+access+rwc  -define $(NAME)  +TESTNAME=$(TESTNAME) \
		-f $(TBENCH_NC) 


# ====================================================================
# Makefile for simulation
# Run in sim/run/top dir
# 1. make help
# 2. make all
# 3. make run tc=xxx
# 4. make gui tc=xxx
# Run in sim/rtl_sim/TESTNAME dir
# 1. make sim
# 2. make deb
# ====================================================================

default: all

USERNAME   := $(shell whoami)
PROJNAME   := AJ03A
# 如需啟用可取消註解: BROJNAME := $(shell cat CVS/Repository 2>/dev/null | awk -F/ '{print $$1}')

PROJNAME_SIM := $(PROJNAME)_SIM

# ARM Cortex M0 image
TESTNAME := tc
ifdef tc
    TESTNAME := $(tc)
endif

rev          ?= $(shell date +%Y%m%d)
SDF_FILE     ?= "../../../impl/APR/tapeout/dig_top_max.sdf"

# Debug Tester image
DEBUGTESTER  := $(TESTNAME)

# Boot Loader image
BOOTLOADER   := bootloader

SW_MAKE_OPTIONS := TESTNAME=$(TESTNAME)

TESTLIST := test_i2c test_spi test_reg test_iir test_fifo test_efuse test_sw_mode test_adc test_adc_dbg test_if_mix
ifdef tlist
    TESTLIST := $(tlist)
endif

# --- Macro Definitions ---
ifeq ($(dump),0)                          
    MCRO_DEFINE := -define NO_DUMP_SHM
else                                        
    MCRO_DEFINE := -define DUMP_SHM      
endif
                                    
ifeq ($(fsdb),1)                          
    MCRO_DEFINE += -define DUMP_FSDB     
else                                        
    MCRO_DEFINE += -define NO_DUMP_FSDB
endif

ifeq ($(vcd),1)
    MCRO_DEFINE += -define vcd
else
    MCRO_DEFINE += -define no_vcd
endif

ifeq ($(tcf),1)
    TCF_DEFINE := -input ../../../sim/run/top/dumptcf
else
    TCF_DEFINE :=
endif

ifeq ($(cov),1)
    COV_DEFINE := -define COV_SIM -coverage all -covdut AJ01A_DIG_TOP \
                  -covwork ../../../sim/$(NAME)_sim/coverage/cov_work -covtest $(TESTNAME) \
                  -covfile ../../../sim/run/top/chip.ccf -covoverwrite
else
    COV_DEFINE :=
endif

ifeq ($(cpf),1)
    CPF_DEFINE := -define CPF_SIM -lps_cpf ../../../impl/clp/cpf/chip_top_sim.cpf \
                  -lps_simctrl_on -lps_verbose 4
else
    CPF_DEFINE :=
endif

# --- Directory Paths ---
CUR_DIR       := $(shell pwd)
SIM           := $(CUR_DIR)/../../../sim
CUR_DIR_MODEL := $(realpath ../../../model)
CUR_DIR_SIM   := $(realpath ../../../sim)
CUR_DIR_HDL   := $(realpath ../../../hdl)

TEST_DIR      := $(shell find $(SIM)/tests/ -name $(TESTNAME) -type d 2>/dev/null)

TBENCH_NC     := ../../../sim/run/top/dig_top_tb.f
SIM_DIR       := ../../../sim/rtl_sim/$(TESTNAME)
NAME          := rtl

ifdef fpga
    TBENCH_NC := ../../../sim/run/top/dig_top_tb_fpga.f
    SIM_DIR   := ../../../sim/fpga_sim/$(TESTNAME)
    NAME      := fpga
endif

ifdef fpga_pos
    TBENCH_NC := ../../../sim/run/top/dig_top_tb_fpga_pos.f
    SIM_DIR   := ../../../sim/fpga_posim/$(TESTNAME)
    NAME      := fpga_pos
endif

ifdef pos_min
    TBENCH_NC   := ../../../sim/run/top/dig_top_tb_pos.f
    SIM_DIR     := ../../../sim/pos_lt_sim/$(TESTNAME)
    NAME        := pos_min
    MCRO_DEFINE += +no_notifier -define pos -define BC -nowarn CUVWSP -nowarn SDFNCAP -nowarn SDFNET \
                   -sdf_verbose -sdfstats sdf_annotation_stats.log
endif

ifdef pos_max
    TBENCH_NC   := ../../../sim/run/top/dig_top_tb_pos.f
    SIM_DIR     := ../../../sim/pos_wc_sim/$(TESTNAME)
    NAME        := pos_max
    MCRO_DEFINE += +no_notifier -define pos -define WC -nowarn CUVWSP -nowarn SDFNCAP -nowarn SDFNET \
                   -sdf_verbose -sdfstats sdf_annotation_stats.log
endif

ifdef pos_typ
    TBENCH_NC   := ../../../sim/run/top/dig_top_tb_pos.f
    SIM_DIR     := ../../../sim/pos_typ_sim/$(TESTNAME)
    NAME        := pos_typ
    MCRO_DEFINE += +no_notifier -define pos -define TP -tfile ../../../sim/run/top/chip_top.tcheck \
                   -nowarn CUVWSP -nowarn SDFNCAP -nowarn SDFNET -sdf_verbose -sdfstats sdf_annotation_stats.log
endif

ifdef gate
    TBENCH_NC := ../../../sim/run/top/dig_top_tb_gate.f
    SIM_DIR   := ../../../sim/gate_sim/$(TESTNAME)
    NAME      := gate
endif

auto: run

# --- Targets (Run in sim/run/top dir) ---
all:
	@for thistest in $(TESTLIST); do \
		echo "Running test: $$thistest"; \
		$(MAKE) run tc=$$thistest $(NAME)=1; \
	done
	$(MAKE) check

check:
	@echo "*** Check the simulation result! please view check.$(NAME).rpt! ***"
	@echo "############## PASSED: ##############" > check.$(NAME).rpt
	@grep -H "TEST PASSED" ../../$(NAME)_sim/*/irun.log | sed "s/irun.log//g" >> check.$(NAME).rpt 2>/dev/null || true
	@echo "############## FAILED: ##############" >> check.$(NAME).rpt
	@grep -L "TEST PASSED" ../../$(NAME)_sim/*/irun.log | sed "s/irun.log//g" >> check.$(NAME).rpt 2>/dev/null || true
	@echo "############## CODE FAILED: ##############" >> check.$(NAME).rpt
	@grep -l "Problem reading hex file" ../../$(NAME)_sim/*/code.log | sed "s/code.log//g" >> check.$(NAME).rpt 2>/dev/null || true
	@echo "############## SUMMARY: ##############" >> check.$(NAME).rpt
	@echo "total : `ls ../../$(NAME)_sim/*/image.mif 2>/dev/null | wc -l`" >> check.$(NAME).rpt
	@echo "finished: `grep -l -E "Test Ended|TEST PASSED" ../../$(NAME)_sim/*/irun.log 2>/dev/null | wc -l`" >> check.$(NAME).rpt
	@echo "passed : `grep -l "TEST PASSED" ../../$(NAME)_sim/*/irun.log 2>/dev/null | wc -l`" >> check.$(NAME).rpt
	@echo "failed : `grep -L "TEST PASSED" ../../$(NAME)_sim/*/irun.log 2>/dev/null | wc -l`" >> check.$(NAME).rpt
	@echo "code failed : `grep -l "Problem reading hex file" ../../$(NAME)_sim/*/code.log 2>/dev/null | wc -l`" >> check.$(NAME).rpt
	@cat check.$(NAME).rpt

debugtester:
	@if [ ! -d $(SIM_DIR) ]; then \
		mkdir -p $(SIM_DIR); \
	fi
	@cd ../../soft/debug_tester && $(MAKE) all $(SW_MAKE_OPTIONS)
	@echo "Compile done"
	@ls > /dev/null
	@echo "Copy $(DEBUGTESTER)_le.hex"
	@if [ -e ../../soft/debug_tester/$(DEBUGTESTER)_le.hex ]; then \
		cp ../../soft/debug_tester/$(DEBUGTESTER)_le.hex $(SIM_DIR)/debugtester_le.hex; \
	else \
		echo "Wait for hex file ..."; sleep 5; \
		if [ -e ../../soft/debug_tester/$(DEBUGTESTER)_le.hex ]; then \
			cp ../../soft/debug_tester/$(DEBUGTESTER)_le.hex $(SIM_DIR)/debugtester_le.hex; \
		fi; \
	fi
	@echo "Copy $(DEBUGTESTER)_be.hex"
	@if [ -e ../../soft/debug_tester/$(DEBUGTESTER)_be.hex ]; then \
		cp ../../soft/debug_tester/$(DEBUGTESTER)_be.hex ../../run/debugtester_be.hex; \
	else \
		echo "Wait for hex file ..."; sleep 5; \
		if [ -e ../../soft/debug_tester/$(DEBUGTESTER)_be.hex ]; then \
			cp ../../soft/debug_tester/$(DEBUGTESTER)_be.hex ../../run/debugtester_be.hex; \
		fi; \
	fi
	@if [ ! -e ../../soft/debug_tester/$(DEBUGTESTER)_le.hex ] && [ ! -e ../../soft/debug_tester/$(DEBUGTESTER)_be.hex ]; then \
		echo "Problem reading hex file"; \
		exit 1; \
	fi

run:
	@-rm -rf $(SIM_DIR)/xcelium.d
	@if [ ! -d $(SIM_DIR) ]; then \
		mkdir -p $(SIM_DIR); \
	fi
	@sed "s/TESTNAME - test_ce/TESTNAME = $(TESTNAME)/g" ./makefile > $(SIM_DIR)/makefile
	@cd $(SIM_DIR) && $(MAKE) sim tc=$(TESTNAME)
	@cd $(CUR_DIR)

code:
	@if [ -z "$(TESTNAME)" ]; then \
		echo "? Please specify TESTNAME on the make command line"; \
		exit 1; \
	fi
	@if [ -d "../../../sim/soft/testcodes/$(TESTNAME)" ]; then \
		cd ../../../sim/soft/testcodes && $(MAKE) all $(SW_MAKE_OPTIONS); \
		echo "Compile done"; \
		ls > /dev/null; \
		echo "Copy $(TESTNAME)/$(TESTNAME).hex"; \
		if [ -e $(TESTNAME)/$(TESTNAME).hex ]; then \
			cp $(TESTNAME)/$(TESTNAME).hex $(SIM_DIR)/image.hex; \
			cp $(TESTNAME)/$(TESTNAME).mif $(SIM_DIR)/image.mif; \
		else \
			echo "Wait for hex file ..."; sleep 5; \
			if [ -e $(TESTNAME)/$(TESTNAME).hex ]; then \
				cp $(TESTNAME)/$(TESTNAME).hex $(SIM_DIR)/image.hex; \
				cp $(TESTNAME)/$(TESTNAME).mif $(SIM_DIR)/image.mif; \
			else \
				echo "Problem reading hex file"; exit 1; \
			fi; \
		fi; \
		cd ../../../sim/run/top; \
		ln -f -s $(CUR_DIR)/bootloader.hex $(SIM_DIR)/bootloader.hex; \
		ln -f -s $(CUR_DIR)/bootloader.mif $(SIM_DIR)/bootloader.mif; \
		cp ./info.hex $(SIM_DIR)/info.hex; \
	else \
		echo "ERROR: invalid TESTNAME value ( $(TESTNAME) )"; \
		exit 1; \
	fi

# --- Tool Option Definitions ---
NCSIM_OPTION := -incdir $(TEST_DIR) \
	+neg_tchk -access rwc -vlog_ext .v,.vo,.inc \
	-f $(TBENCH_NC) -define $(NAME) $(MCRO_DEFINE) $(TCF_DEFINE) $(COV_DEFINE) $(CPF_DEFINE) +TESTNAME=$(TESTNAME) -fsmdebug

VERDI_OPTION := -incdir $(TEST_DIR) \
	+access+rwc -define $(NAME) +TESTNAME=$(TESTNAME) \
	-f $(TBENCH_NC)

# --- New Targets from part 2 ---

sim_link:
	@mkdir -p /sim/ind/$(USERNAME)/proj/$(PROJNAME_SIM)/sim_results/rtl_sim
	@mkdir -p /sim/ind/$(USERNAME)/proj/$(PROJNAME_SIM)/sim_results/fpga_sim
	@mkdir -p /sim/ind/$(USERNAME)/proj/$(PROJNAME_SIM)/sim_results/gate_sim
	@mkdir -p /sim/ind/$(USERNAME)/proj/$(PROJNAME_SIM)/sim_results/pos_wc_sim
	@mkdir -p /sim/ind/$(USERNAME)/proj/$(PROJNAME_SIM)/sim_results/pos_wcl_sim
	@mkdir -p /sim/ind/$(USERNAME)/proj/$(PROJNAME_SIM)/sim_results/pos_lt_sim
	@mkdir -p /sim/ind/$(USERNAME)/proj/$(PROJNAME_SIM)/sim_results/pos_ml_sim
	@cd ../../ && ln -f -s /sim/ind/$(USERNAME)/proj/$(PROJNAME_SIM)/sim_results/rtl_sim
	@cd ../../ && ln -f -s /sim/ind/$(USERNAME)/proj/$(PROJNAME_SIM)/sim_results/fpga_sim
	@cd ../../ && ln -f -s /sim/ind/$(USERNAME)/proj/$(PROJNAME_SIM)/sim_results/gate_sim
	@cd ../../ && ln -f -s /sim/ind/$(USERNAME)/proj/$(PROJNAME_SIM)/sim_results/pos_wc_sim
	@cd ../../ && ln -f -s /sim/ind/$(USERNAME)/proj/$(PROJNAME_SIM)/sim_results/pos_wcl_sim
	@cd ../../ && ln -f -s /sim/ind/$(USERNAME)/proj/$(PROJNAME_SIM)/sim_results/pos_lt_sim
	@cd ../../ && ln -f -s /sim/ind/$(USERNAME)/proj/$(PROJNAME_SIM)/sim_results/pos_ml_sim
	@rm -f /sim/ind/$(USERNAME)/proj/$(PROJNAME_SIM)/sim
	@rm -f /sim/ind/$(USERNAME)/proj/$(PROJNAME_SIM)/hdl
	@ln -f -s $(CUR_DIR_SIM) /sim/ind/$(USERNAME)/proj/$(PROJNAME_SIM)/sim
	@ln -f -s $(CUR_DIR_HDL) /sim/ind/$(USERNAME)/proj/$(PROJNAME_SIM)/hdl

sim:
	irun $(NCSIM_OPTION) -log irun.log 

verdi:
	verdi $(VERDI_OPTION) &

gui:
	xrun $(NCSIM_OPTION) -gui -simvisargs "-layout rtldesign" -l xrun.log &

deb:
	simvision waves &

clean:
	rm -rf INCA_libs xcelium.d xrun.key xrun.log waves irun.key irun.log

help:
	@echo "========================================================================================"
	@echo " "
	@echo "USAGE: % make TARGET tc="
	@echo " "
	@echo "-------------------TARGETS---------------------------"
	@echo "run                => Create TESTNAME dir, copy makefile, compile the c pattern,"
	@echo "code               => compile the c pattern"
	@echo "sim                => Run the simulation"
	@echo "clean              => Clean the intermediate files"
	@echo "gui                => Open Simvision GUI in"@echo " "
	@echo "---------------------OPTIONS-------------------------------"
	@echo " "
	@echo "tc                  Name of software test to be executed"
	@echo "tlist               List of tests available"
	@echo "fpga                fpga=1 run fpga simulation"
	@echo "gate                gate=1 run gate simulation"
	@echo "pos                 pos=1 run pos simulation"
	@echo "dump                dump=0 disable dump waveform, default dump waveform"
	@echo " "
	@echo "-----------------ADMINISTRATIVE TARGETS------------------------"
	@echo "help               -> Display this message"
	@echo " "
	@echo "e.g. make help     => make help"
	@echo "e.g. make          => run all test"
	@echo "e.g. make run tc=hello"
	@echo "e.g. make run tc=hello fpga=1 dump=0"
	@echo " "
	@echo "-----------------DEBUGTESTER SIMULATION------------------------"
	@echo "e.g. make debugtester DEBUGTESTER=debug_tests_forceswd_at_resetb0"
	@echo "e.g. make code        tc=debug_tests_forceswd_at_resetb0"
	@echo "e.g. make run         tc=debug_tests_forceswd_at_resetb0"
	@echo "========================================================================================"