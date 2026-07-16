../../../sim/run/top/fpga_define.v
../../../model/fpga/cycloneive_atoms.v
-v ../../../model/fpga/altera_mf.v
-v ../../../model/fpga/altera_primitives.v
//==================================
// Design
//==================================
../../../hdl/dig_top/dig_top_inc_fpga.v
../../../sim/tbench/models/MI2523_TOP.v
../../../fpga/AFE_TOP/i2c_def.v
../../../fpga/AFE_TOP/afe.v
../../../fpga/AFE_TOP/SPI_Master_With_Single_CS.v
../../../fpga/AFE_TOP/SPI_Master.v
../../../fpga/AFE_TOP/i2c_slave.v
../../../fpga/AFE_TOP/afe_wrap.v
../../../fpga/AFE_TOP/adder.v
../../../fpga/sda.v
../../../fpga/pll.v
../../../fpga/BDIO.v

//=================================
// Tbench
//=================================
../../../sim/tbench/task/i2c_task.v
../../../sim/tbench/task/spi_task.v
../../../sim/tbench/task/i2c_master.v
../../../sim/tbench/task/spi_master.v
../../../sim/tbench/models/MI2523_tb.v
