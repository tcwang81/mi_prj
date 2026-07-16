################################################
#  filename 	: setup.tcl
# Created on 	: 20240930
# Description	: setup script
################################################

################################################
# Stepl: set up top module & verilog files
################################################

set top_module "dig_top"
set op_cond "slow"
set syn_params(syn_defines) {SYN}
set_db common_ui false
set root_dir " ../../.."
set_attr hdl_search_path "."
#set_attr init_hdl_search_path "."
set syn_params(rtl_source_files) "${root_dir}/hdl/dig_top/dig_top_inc.v"
set syn_params(func_sdc_files) "${root_dir}/impl/syn/script/constraint_func.sdc"
set syn_params(shift_sdc_files) "${root_dir}/impl/syn/script/constraint_shift.sdc"
set syn_params(capture_sdc_files) "${root_dir}/impl/syn/script/constraint_capture.sdc"
set syn_params(dft_source_files) "${root_dir}/impl/syn/script/scan_cfg.tcl"
set syn_params(cpf_files) "${root_dir}/impl/clp/cpf/chip_top.cpf"
set syn_params(tcf_files) "${root_dir}/impl/syn/script/chip_top.tcf"
set syn_params(atpg_files) "/mnt/hgfs/project/MI2519/model/verilog/scc018ug_uhd_rvt.v"
set syn_params(atpg_lib_files) "../lib/et_lib.v"

set syn_params(lib_names) "scc018ug_uhd_rvt_ss_v1p08_125c_basic"
################################################
# Step2: set up library
################################################
if {${op_cond} == "typical"} {
	set syn_params(lib_names) "scc018ug_uhd_rvt_ss_v1p08_125c_basic"
	set syn_params(ram_op_cond) "TC"
	set syn_params(stdcell_op_cond) "ss_v1p08_125c"
} elseif {${op_cond} == "fast"} {
	set syn_params(lib_names) "scc018ug_uhd_rvt_ff_v1p98_-40c_basic"
	set syn_params(ram_pp_cond) "BC"
	set syn_params(stdcell_op_cond) "ff_v1p98_-40c"
} else {
	set syn_params(lib_names) "scc018ug_uhd_rvt_ss_v1p08_125c_basic"
	set syn_params(lib_names_pow) ""
	set syn_params(ram_op_cond) "WC"
	set syn_params(stdcell_op_cond) "ss_v1p08_125c"
}

#	set syn_params(timing_libs) "/nfsmount/group/cad/IP/IP_SL0162BCD_oa/SC18_SL0162BCD_silergy_Vl/9T_Vl/lib/ccs_ss lp62_125.1ib"
#	set syn_params (timing_libs) "/nfsmount/group/cad/IP/IP_SL0162BCD_oa/SC18_SL0162BCD_silergy_V2/lib/ccs_ss_vlp62_125c.lib"
#	set syn_params (timing_libs) "/nfsmount/group/cad/IP/IP_SL0162BCD_oa/SC18_SL0162BCD_silergy_V2/lib/ccs_ss_vlp71_150c.lib"
#	set syn_perams (power_libs) "/nfsmount/group/cad/IP/IP_SL0162BCD_oa/SC18_SL0162BCD_silergy_V2/lib/ccs_tt_vlp8_25c.lib"

	set syn_params(timing_libs) "/mnt/hgfs/project/MI2519/model/Lib/smic/1.2v/scc018ug_uhd_rvt_ss_v1p08_125c_basic.lib"
	set syn_params(macrotiming_libs) "/mnt/hgfs/project/MI2519/model/Lib/efuse/S0153GEFUSE_PIPO256B_V0.3.1_ss_V1p62_125C.lib"
	set syn_params(power_libs) "/mnt/hgfs/project/MI2519/model/Lib/smic/1.8v/scc018ug_uhd_rvt_ff_v1p98_-40c_basic.lib"
	set syn_params(wire_load) ""

create_library_domain { timing_domain power_domain}
set_attribute library $syn_params(macrotiming_libs) [find /libraries -library_domain timing_domain]
set_attribute library $syn_params(power_libs) [find /libraries -library_domain power_domain]
set_attribute library $syn_params(timing_libs) [find /libraries -library_domain timing_domain]
set_attribute power_library [find /libraries -library_domain power_domain] [find /libraries -library_domain timing_domain]
set_attribute default true timing_domain

set syn_params(driving_cell) INUHDV1
set syn_params(driving_cell_pin) ZN

################################################
# Step2: set up syntheszze options
################################################
set syn_params(max_fanout) "40"
set syn_params(max_trans) "1.0"
set syn_params(max_cap) "1.0"
set syn_params(dont_touch) {dont_touch* *spare_*}
set syn_params(dont_touch_net) {dont_touch* int_reg* efuse_din_*}
set syn_params(flatten_before_syn) "false"
set syn_params(syn_eff) "medium"
set syn_params(map_eff) "medium"
#set syn_params (add_tp) "false"
set syn_params(add_tp) "true"
set syn_params(gen_temp) "false"
set syn_params(do_clock_gating) "true"
#set syn_params(do_clock_gating) "false"
set syn_params(do_dft_scan) "false"
#set syn_params(do_dft_scan) "true"
set syn_params(do_lowpower_design) "false"
#set syn_params(do_lowpower_design) "true"
set syn_params(gen_lec_script) "true"
set syn_params(gen_cdc_script) "true"
#set syn_params(gen_cdc_script) "false"
set syn_params(gen_dft_sdc) "false"
if { $syn_params(do_clock_gating) == "true" } {
	set_attribute lp_insert_clock_gating true
	set_attribute lp_clock_gating_exceptions_aware true /
	set_attribute lp_clock_gating_prefix "" /
	set_attribute lp_clock_gating_exceptions_aware true /
	set syn_params(exclude_clock_gating) ""
	set syn_params(connect_cg_testport) "scan_enable"
	set syn_params(lp_clock_gating_max_flops) 1024
	set syn_params(lp_clock_gating_min_flops) 3
}
set_attr hdl_track_filename_row_col true /
set_attribute lp_power_unit nW /
#set_attribute avoid true [get_libcells -name *DEL*]


################################################
# Step3: mkdir & common options (should not be modified)
################################################
set syn_params(report) "report"
set syn_params(result) "result"
set syn_params(atpg) "atpg"
set syn_params(log) "log"
set syn_params(dont_touch_file) "./report/dont_touch.list"

exec mkdir -p $syn_params(report)
exec mkdir -p $syn_params(result)
exec mkdir -p $syn_params(atpg)
exec mkdir -p $syn_params(log)

#set_host_options -max_cores 1
set_attribute information_level 9 /
set_attribute hdl_track_filename_row_col true /
set_attribute lp_power_analysis_effort high /
set_attribute auto_ungroup none
set_attribute max_cpus_per_server 128 /
set_attribute auto_super_thread true /
set_attribute source_verbose true /
set_attribute hdl_array_naming_style %s\_%d\_
set_attribute bus_naming_style %s_%d
set_attribute hdl_bus_wire_naming_style %s_%d
set_attribute hdl_parameter_naming_style ""
#set_attribute hdl_generate_index_styie %s_%d
set_attribute hdl_generate_separator _
set_attribute hdl_track_filename_row_col true
set_attribute hdl_max_loop_limit 10000 /
set_attribute severity Error messages/CDFG/CDFG-562
set_attribute severity Error messages/TUI/TUI-273
set_attribute severity Error messages/ELABUTL/ELABUTL-127
#set_attribute severity Warning messages/ELABUTL/ELABUTL-127
set_attribute severity Warning messages/ELABUTL/ELABUTL-124
set_attribute severity Warning messages/CDFG/CDFG-772
set_attribute dft_apply_sdc_constraints false /
set_attribute optimize_constant_0_flops true
read_sdc ${root_dir}/impl/syn/script/dont_use.tcl
suppress_messages CDFG-818 CDFG-472
######tcwang
#set_attribute hdl_latch_keep_feedback true
