#########################################
#  Shift SDC
########################################

set sdc_version 1.7


##### set the current design #######
current_design $top_module

set_case_analysis 1 [get_pins SCAN_MODE]
set_case_analysis 1 [get_ports SDA]

set period 100

create_clock -name "scan_clk" -period $period -waveform {0 50} [get_ports A0]

set_clock_transition 0.4 [get_clocks scan_clk]

set_clock_uncertainty -setup 0.3 [get_clocks scan_clk]
set_clock_uncertainty -hold 0.4 [get_clocks scan_clk]

set_clock_gating_check -setup 0.0

set_dont_touch_network [get_clocks *]

set_max_fanout 30 $top_module
set_max_transition 2 $top_module
 
