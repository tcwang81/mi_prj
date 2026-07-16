####################################################################
##   Setup DFT Ruler Checker
###################################################################

set_attr dft_scan_style muxed_scan /

set_attribute dft_prefix DFT_ /

set_attribute dft_identify_top_level_test_clocks false /
set_attribute dft_identify_test_signals false /

set_attribute dft_identify_internal_test_clocks false /
set_attribute use_scan_seqs_for_non_dft false /

set_attribute dft_scan_map_mode tdrc_pass "/designs/$top_module"
set_attribute dft_connect_shift_enable_during_mapping tie_off  "/designs/$top_module"
set_attribute dft_connect_scan_data_pins_during_mapping loopback  "/designs/$top_module"
set_attribute dft_scan_output_preference auto  "/designs/$top_module"
set_attribute dft_lockup_element_type preferred_level_sensitive  "/designs/$top_module"
set_attribute dft_mix_clock_edges_in_scan_chains true  "/designs/$top_module"
set_attribute dft_max_length_of_scan_chains 10000 "/designs/$top_module"
###################################################################
set_attribute dft_dont_scan true [find -instance u_TM_gen/scan_mode_dig*]
set_attribute dft_verify_test_signal_hookup false /

#############################################
###  Force signals during scan mode 
#############################################
define_dft test_mode -name scan_mode -active high u_TM_gen/SCAN_MODE_LV
define_dft test_mode -name scan_rst_n -active high SCL -scan_shift
define_dft shift_enable -name scan_enable -active high SDA -hookup_pin u_scan_wrap/dont_touch_mux_scanen/Z

define_dft test_clock -name scan_clk -period 100 A0
define_dft scan_chain -name chain0 -sdi SCAN_PIN_IN -sdo ALERT_IN_LV -shared_output

set_attribute lp_clock_gating_test_signal scan_enable /design/$top_module

