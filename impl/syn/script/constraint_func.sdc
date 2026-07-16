set_attr lp_clock_tree_leaf_max_fanout 30 $top_module
#set_case_analysis 0 [get_pins u_dig_top/u_pad_ctrl/scan_mode]
###########################################################
# Create Clock
###########################################################
set MARGIN 0.9
#set MARGIN 1.176
create_clock -name  {clk_1m} -period [expr 1000*$MARGIN] [get_ports OSC_OUT]
create_clock -name  {clk_250k} -period [expr 4000*$MARGIN] [get_ports CK250K]
create_clock -name  {clk_32k} -period [expr 32000*$MARGIN] [get_ports LOSC_OUT]
create_clock -name  {clk_i2c} -period [expr 1000*$MARGIN] [get_ports scl_di]



set_clock_uncertainty 0.4 [get_clocks *]

############################################
##  set input Delay
############################################

#set_driving_cell -lib_cell $syn_params(driving_cell) -pin $syn_params(driving_cell_pin) -libaray $syn_params(lib_names) [all_inputs]
#set HIGH_TRAN_OUTPORT [get_ports {DLL_SEL_FS_EN_* PHS_SET_*}]
set_load 0.35 [all_outputs]

set_input_delay 1 -clock clk_i2c [get_ports sdio_di]
set_input_delay 400 -clock clk_250k [get_ports CV_DONE]


############################################
##  set Output Delay
############################################
#set CLK_500K_PORT [get_ports {POLAR EN_CH* EN_V* RST_INT EN_SH_* EN_GAIN2}]
#set CLK_1M_PORT [get_ports {ADR_EFUSE_* STROBE PGENB NR}]

#set_output_delay 800 -clock clk_500k_dly [remove_from_collection [all_ports] "$CLK_500K_PORT $CLK_1M_PORT"]
#set_output_delay 800 -clock clk_500k [getl_ports $CLK_500K_PORT]
#set_output_delay 400 -clock clk_1m [getl_ports $CLK_1M_PORT]
############################################
##  set CLOCK Group
############################################
set_clock_groups -asynchronous -group {clk_1m} \
			       -group {clk_i2c} \
			       -group {clk_250k} \
			       -group {clk_32k} 

############################################
##  set False path
############################################	
#set_false_path -from  [get_register  *]  -to [get_ports *]
#set_false_path -from  [get_cells * ]  
#set_false_path -through  [get_pins * ]  
#set_false_path -to  [list [get_pins *] ]

############################################
##  set Multicycle path
############################################	


	
############################################
##  set Maximum fanout
############################################
set_max_fanout 50 $top_module
set_max_transition 2 $top_module

	
############################################
##  set Maximum Delay
############################################


############################################
##  set Minimum Delay
############################################
#tcwang ADD 20260205 for LATCH auto add delay
set_min_delay 0.4 -from [get_pins xadc_ctrl/PWR_OFF] -to [get_pins xadc_ctrl/ANAEN] 
set_min_delay 0.4 -from [get_pins xadc_ctrl/PWR_OFF] -to [get_pins xadc_ctrl/HOSC_ENB]
set_min_delay 0.4 -from [get_pins xefuse_ctrl/porb] -to [get_pins xefuse_ctrl/dvddenb_fuse]

	
############################################
##  set Input transition
############################################
#set_case_analysis 0 [get_pins u_TM_gen/SCAN_MODE_LV]
