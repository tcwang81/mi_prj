################################################
#  filename 	: syn.tcl
# Created on 	: 20240930
# Description	: synthesis script
################################################

################################################
# Stepl: set up varibles & librery
################################################

source ../../../impl/syn/script/setup.tcl
#source ../../../impl/syn/script/setup_tsmc.tcl
set_dont_use scc018ug_uhd_rvt_ss_v1p08_125c_basic/SD*
################################################
# Step2: Read and Elaborate RTL
################################################
if { $syn_params(do_lowpower_design) == "true" } {
	read_power_intent -cpf -module $top_module $syn_params(cpf_files)
}
set svf_presto_parameter_naming true
set hdl_undriven_signal_value 0
read_hdl -sv -define $syn_params(syn_defines) $syn_params(rtl_source_files)

elaborate $top_module
uniquify $top_module
#report nets -hierarchical -maxfanout $syn_params(max_fanout) > $syn_params(report)/high_fanout.initial
#report nets -hierarchical -maxfanout 40 > $syn_params(report)/high_fanout.initial

if {$syn_params(gen_temp) == "true"} {
write_hdl > ./$syn_params(result)/${top_module}_after_elaborate.v
}

if { $syn_params(do_lowpower_design) == "true" } {
# appLy the power intent
set clp_treat_errors_as_warnings true
apply_power_intent
report low_power_intent -isolation_rule_only
check_cpf
commit_power_intent
report low_power_cells -isolation_only
verify_power_structure
}


################################################
# Step3: Apply Constraint
################################################
create_mode -default -name NON_DFT_MODE
read_sdc -mode NON_DFT_MODE $syn_params(func_sdc_files)

if {$syn_params(do_dft_scan) == "true"} {
create_mode -name DFT_SHIFT_MODE
create_mode -name DFT_CAPTURE_MODE
#	read_sdc -mode DFT_SHIFT_MODE $syn_params(shift_sdc_files)
#	read_sdc -mode DFT_CAFTURE_MODE $syn_params(capture_sdc_files)
}


################################################
# Step4 : Synthesis
################################################
set_operating_conditions -max ss_v1p08_125c  -max_library scc018ug_uhd_rvt_ss_v1p08_125c_basic \
			-min ff_v1p98_-40c -min_library scc018ug_uhd_rvt_ff_v1p98_-40c_basic
#set_operating_conditions $syn_params(stdcell_op_cond) -library $syn_params(lib_names)
#set_max_fanout $syn_params(max_fanout) $top_module
#set_max_capacitance $syn_paraas(max_cap) $top_module
#set_max_transition $syn_params(max_trans) $top_module

set_attribute max_leakage_power 0 $top_module
set_attribute max_dynamic_power 0 $top_module
#read_tcf $syn_params( tcf_files)

if {$syn_params(dont_touch) != ""} {
	puts "Info: Setting dont_touch attribute before design optimization on instances: $syn_params(dont_touch)"
	if [sizeof_collection [get_cells -hier $syn_params(dont_touch)]] {
	puts "Info: The following raodules were found in the design and will not be touched during compile."
	set dont_touch_str [get_cells -hier $syn_params(dont_touch)]
	puts "$dont_touch_str"
	set_dont_touch [get_cells -hier $syn_params(dont_touch)]
	} else {
		puts "Info: Nothing to dont touch. There are no instances that match the dont_touch parameter."
	}
}

#if [sizeof_collection [get_cells -hier $syn_params(dont_touch) -filter "is_hierarchical==false"]] {
#	set_dont_touch [get cells -hier $syn_params(dont_touch) -filter "is_hierarchical==false"]
#	file delete -force^syn_params(dont_touch_file)
#	foresch_in_collection tt [get_cells -hier $syn_params(dont_touch) -filter "is_hierarchical==false"] {
#	echo [get_object_name $tt] >> $syn_params(dont_touch_file)
#	}
#}

if {$syn_params(dont_touch_net) != ""} {
		puts "Info: Setting dont_touch attribute before design optimization on instances: $syn_params(dont_touch_net)"
	if [sizeof_collection [get_nets -hier $syn_params(dont_touch_net)]] {
		puts "Info: The following nets were found in the design and will not be touched during compile."
		set dont_touch_str_net [get_nets -hier $syn_params(dont_touch_net)]
		puts "$dont_touch_str_net"
		set_dont_touch [get_nets -hier $syn_params(dont_touch_net)]
		foreach_in_collection tt [get_nets -hier $syn_params(dont_touch_net)] {
		echo [get_object_name $tt] >> $syn_params(dont_touch_file)
		}
	} else {
		puts "Info: Nothing to dont touch. There are no nets that match the dont_touch_net parameter."
	}
}

if {$syn_params(do_dft_scan) == "true"} {
	source $syn_params(dft_source_files)
	if {$syn_params(do_dft_scan) == "true"} {
#	create_mode -name DFT_SHIFT_MODE
#	create_mode -name &FT_CAPTURE MODE
	read_sdc -mode DFT_SHIFT_MODE $syn_params(shift_sdc_files)
	read_sdc -mode DFT_CAPTURE_MODE $syn_params(capture_sdc_files)
	}
}

if { $syn_params(do_clock_gating) == "true" } {
	set_attribute lp_clock_gating_max_flops $syn_params(lp_clock_gating_max_flops) $top_module
	set_attribute lp_clock_gating_min_flops $syn_params(lp_clock_gating_min_flops) $top_module
}

if {$syn_params(flatten_before_syn) != "false"} {
	puts "Info: Flattening specified modules."
	foreach design_to_flat $syn_params(flatten_before_syn) {
	puts "Info: Flattening module = $design_to_flat"
	current_design $design_to_flat
	ungroup -all -flatten
	}
	current_design $top_module
}

set_wire_load_mode enclosed
if [info exists syn_params(wire_load)] {
	set_wire_load_model -name $syn_params(wire_load)
	set_attribute force_wireload $syn_params(wire_load) [find / -design -subdesign *]
}

check_design -all -vname > ./$syn_params(report)/check_design.initial
#syn to generste
synthesize -to_generic -eff $syn_params(syn_eff)
puts "Runtime & Meraory after 'synthesize -to_generic'"
timestat GENERIC
if {$syn_params(gen_temp) == "true"} {
	write_db -to_file ./$syn_params(result)/${top_module}_after_generic.db
	write_hdl > ./$syn_params(result)/${top_module}_after_generic.v
}

if {$syn_params(do_dft_scan) == "true"} {
	check_dft_rules > ./$syn_params(report)/dft_drc_initial.rpt
	report dft_registers > ./$syn_params(report)/dft_regs.rpt
}

#syn to mapped
synthesize -to_mapped -eff $syn_params(map_eff) -no_incr -auto_identify_shift_register
puts "Runtime & Meraory after 'synthesize -to_map -no_incr'"
timestat MAPPED
if {$syn_params(gen_temp) == "true"} {
	write_db -to_file ./$syn_params(result)/${top_module}_after_map.db
	write_hdl > ./$syn_params(result)/${top_module}_after_map.v
}

if {$syn_params(do_dft_scan) == "true"} {
	set_attribute lp_clock_gating_test_signal scan_enable $top_module
	clock_gating connect_test
	check_dft_rules > ./$syn_params(report)/dft_drc_mapped.rpt
# suspend
	if {$syn_params(add_tp) == "true"} {
	set_attribute ui_respects_preserve false
	#insert_dft rrfa_test_points -atpg \
	#-library ../../$syn_params(atpg) /1ib/et_1ib.v \
	#-directory ./$syn_params (atpg) / \
	#-rrfa_effort high \
	#-share_observation_flop 8 \
	#-test_control scan_mode \
	#-test_clock_pin SCLK_LV \
	#-gate_clock -gate_clock_test_control scan_mode
	insert_dft rrfa_test_points -ltbrary ../../$syn_params(atpg)/lib/et_lib.v -directory ./$syn_params(atpg)/ -output_tp_file ./$syn_params(atpg)/myfile.tp
	insert_dft rrfa_test_points -max_number_of_testpoints 40 \
	-test_control scan_mode \
	-test_clock_pin A0 \
	-gate_clock -gate clock_test_control scan_mode \
	-input_tp_file ./$syn_params(atpg)/myfile.tp
	set_attribute ui_respects_preserve true
	check_dft_rules > ./$syn_params(report)/dft_drc_aftertp.rpt
	}
	connect_scan_chains
	read_sdc -mode DFT_SHIFT_MODE $syn_params(shift_sdc_files)
	read_sdc -mode DFT_CAPTURE_MODE 5syn_params(capture_sdc_files)
	uniquify $top_module
	remove_assigns_without_optimization -dont_skip_unconstrained_paths -use_inverted_signal -verbose
	report dft_chains > ./$syn_params(report)/dft_chains.rpt
	report dft_registers -dont_scan > ./$syn_params(report)/dft_dont_scan_regs.rpt
	check_dft_rules > ./$syn_params(report)/dft_drc_final.rpt
	#fix_dft_violations -clock -test_control scan_mode -test_clock_pzn SCAN_CLK
	#check_dft_rules > ./$syn_params(report)/dft_drc_afterfix.rpt
	check_dft_rules -advanced >> ./$syn_params(report)/dft_drc_final.adv.rpt
	check_design -undriven -report_scan_pins -vname > ./$syn_params(report)/dft_undriven.rpt
}
if {$syn_params(do_lowpower_design) == "true" } {
commit_power_intent
}
if {$syn_params(gen_lec_script) == "true"} {
	write_hdl -lec > ./$syn_params(result)/${top_module}_intermediate.v
	write_do_lec -revised_design ../../../impl/syn/rev_dir/$syn_params(result)/${top_module}_intermediate.v -logfile ./rtl2intermediate.lec.log \
	> ./$syn_params(result)/rtl2intermediate.lec.do
}
#syn to mapped incr
synthesize -to_mapped -eff $syn_params(map_eff) -incr
puts "Runtime & Memory after incremental synthesis"
timestat INCREMENTAL
remove_assigns_without_optimization -dont_skip_unconstrained_paths -use_inverted_signal -verbose
################################################
#  Step5: write result & report
################################################

change_names -instance -restricted {:} -replace {_}
#change_names -rules verilog -hierarchy
write_design -basename ./$syn_params(result)/${top_module}_syn
write_db -to_file ./$syn_params(result)/${top_module}_syn.db
write_hdl -lec > ./$syn_params(result)/${top_module}_syn.lec.v
write_sdc -mode NON_DFT_MODE > ./$syn_params(result)/${top_module}_func.sdc
if { $syn_params(do_dft_scan) == "true" } {
	write_sdc -mode DFT_SHIFT_MODE > ./$syn_params(result)/${top_module}_shift.sdc
	write_sdc -mode DFT_CAPTURE_MODE > ./$syn_params(result)/${top_module}_capture.sdc
	}
write_encounter design $top_module -basename ./$syn_params(result)/${top_module}_syn

if {$syn_params(gen_cdc_script) == "true"} {
write_do_ccd cdc -design ${top_module} -sdc $syn_params(func_sdc_files) > ./$syn_params(result)/cdc.do
}

if {$syn_params(gen_lec_script) == "true"} {
	write_do_lec -golden_design ../../../impl/syn/rev_dir/$syn_params(result)/${top_module}_intermediate.v \
			-revised_design ../../../impl/syn/rev_dir/$syn_params(result)/${top_module}_syn.v \
			-logfile ./intermediate2final.lec.log > ./$syn_params(result)/intermediate2final.lec.do

	write_do_lec  -revised_design ../../../impl/syn/rev_dir/$syn_params(result)/${top_module}_syn.v \
			-logfile ./r2g.lec.log > ./$syn_params(result)/r2g.lec.do
			
	write_do_lec  -revised_design ../../../impl/APR/final/${top_module}_sim.v \
			-logfile ./r2g.lec.log > ./$syn_params(result)/r2p.lec.do
			
	write_do_lec -golden_design ../../../impl/syn/rev_dir/$syn_params(result)/${top_module}_syn.v \
			-revised_design ../../../impl/syn/rev_dir/$syn_params(result)/${top_module}.v.gz \
			-logfile ./g2p.lec.log > ./$syn_params(result)/g2p.lec.do
}

if {$syn_params(do_lowpower_design) == "true" } {
	write_power_intent -cpf -base_name ./$syn_params(result) -design $top_module
	write_do_clp -design ${top_module} -netlist ../../../impl/syn/rev_dir/$syn_params(result)/${top_module}_syn.v \
	-cpf_file ../../../impl/clp/cpf/${top_module}.cpf -logfile ./log/clp.do.log > ./$syn_params(result)/clp.do
	}
if {$syn_params(do_dft_scan) == "true"} {
	write_et_atpg -ncsim_library $syn_params(atpg_files) \
	-library $syn_params(atpg_lib_files) -directory ./$syn_params(atpg)/${top_module}
}

report clock_gating > ./$syn_params(report)/${top_module}_clockgating.rpt
#reed_tcf $syn_params(tcf_files)
report power -hier > ./$syn_params(report)/${top_module}_power.rpt
#report power -hier -mode DFT_SHIFT_MODE > ./$syn_par&ms(report)/${top_module}_power.SHZFT.rpt
#report power -hier -mode DFT_CAPTURE_MODE > ./$syn_parems(report)/${top_module}_power.CAPTURE.rpt
#report power -unit mW -by_hierarchy > ./$syn_params(report)/${top_module}_power_hier.rpt
report gates -power > ./$syn_params(report)/${top_module}_gates_power.rpt
report area > ./$syn_params(report)/${top_module}_area_all.rpt
report area -depth 3 >> ./$syn_params(report)/${top_module}_area.rpt
report datapath > ./$syn_params(report)/${top_module}_datapath_incr.rpt
report messages > ./$syn_params(report)/${top_module}_messages.rpt
report_timing	> ./$syn_params(report)/${top_module}_timing.rpt
report_timing -summary >> ./$syn_params(report)/${top_module}_timing.rpt
report_timing -lint -verbose >> ./$syn_params(report)/${top_module}_lint.rpt
report_timing -slack_limit 0 -endpoints -num_paths 100 > ./$syn_params(report)/${top_module}_constraint.rpt
report_timing -mode NON_DFT_MODE -num_paths 100 > ./$syn_params(report)/${top_module}_constraint.func.rpt
if {$syn_params(do_dft_scan) == "true"} {
	report_timing -mode DFT_SHIFT_MODE -num_paths 100 -slack_limit 0 > ./$syn_params(report)/${top_module}_constrain.shift.rpt
	report_timing -mode DFT_CAPTURE_MODE -num_paths 100 -slack_limit 0 > ./$syn_params(report)/${top_module}_constrain.capture.rpt
}
report clocks -generated > ./$syn_params(report)/${top_module}_clocks.rpt
report design_rules  ${top_module} > ./$syn_params(report)/${top_module}_design_rulers_violation.rpt

exit
