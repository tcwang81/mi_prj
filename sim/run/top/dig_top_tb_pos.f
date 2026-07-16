../../../sim/run/top/posim_define.v
//==================================
// Design
//==================================
../../../impl/APR/$rev/dig_top_sim.v
../../../sim/tbench/models/MI2523_TOP-PR-nonfuse.v
../../../sim/tbench/models/AFE_TOP-PR-nonfuse.v
../../../sim/tbench/models/ana_model.v
//=================================
// Tbench
//=================================
-v  ../../../model/verilog/scc018ug_uhd_rvt.v
../../../sim/tbench/models/S0153GEFUSE_PIPO256B_V0.3.1.v
../../../sim/tbench/task/i2c_task.v
../../../sim/tbench/task/spi_task.v
../../../sim/tbench/task/i2c_master.v
../../../sim/tbench/task/spi_master.v
-sv ../../../sim/tbench/models/MI2523_tb.v
