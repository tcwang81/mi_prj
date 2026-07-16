`timescale 1ns/100ps
`define DISPLAY_ACK 1'b0

module MI2523_test();
 
//output 
wire 	GND,GND_IO,VDD;
wire	INT1,INT2;
wire	SDO;

//input
wire	CSB;
wire	SCL_SCLK;
//INOUT
wire	SDA_SDI; 
 

SPI_M xSPI_M(
	.CSB(CSB),
	.SCK(SCL_SCLK),
	.SDI(SDA_SDI),
	.SDO(SDO)
	);


I2C_M xI2C_M(
	.SCL(SCL_SCLK),
	.SDA(SDA_SDI)
	); 


MI2523_TOP xMI2523_TOP (
	//output
	.GND(),.GND_IO(),
	.VDD(),
	.INT1(INT1),
	.INT2(INT2),
	.SDO(SDO),
	//input
	CSB(CSB),
	.SCL_SCLK(SCL_SCLK),
	//INOUT
	.SDA_SDI(SDA_SDI)
	);


pullup(SDA_SDI); 
 
//FOR Initial & RESET
initial begin
	rstn=0;
	pad_scan=1;
	end
 
`include "test.v"

// Dump Waveforms
`ifdef  DUMP_FSDB
initial begin
	`ifdef fpgasim
  	$fsdbDumpfile("./waves/cq02a_fpga.fsdb");
	`elsif presim
  	$fsdbDumpfile("./waves/cq02a_presim.fsdb");
	`elsif posim
  	$fsdbDumpfile("./waves/cq02a_posim.fsdb");
	`elsif fpgaposim
	$fsdbDumpfile("./waves/cq02a_fpgaposim.fsdb");
	`endif
  $fsdbDumpvars(0, cq02a_test); 
end
`elsif DUMP_SHM
initial begin
  $shm_open("../waves/wave.shm"); 
  $shm_probe(cq02a_test, "ACM");

end
`endif

// Back Annotate for Post Simulation
`ifdef SDF_TM_MAX
 initial begin
	$sdf_annotate("../syn/apr/CQ02_MIN_MAX.sdf",cq02a_test.xCQ02A_CHIPTOP.xDTOP,,,"MAXIMUM",,"CQ02_max.sdf.log");
 end
`elsif SDF_TM_TYP
 initial begin
	$sdf_annotate("../syn/apr/CQ02_MIN_MAX.sdf",cq02a_test.xCQ02A_CHIPTOP.xDTOP,,,"MINIMUM",,"CQ02_min.sdf.log");
 end
`elsif SDF_TM_TYP
 initial begin
	$sdf_annotate("../syn/apr/CQ02_postsim.sdf",cq02a_test.xCQ02A_CHIPTOP.xDTOP,,,"TYPICAL",,"CQ02_typ.sdf.log");
 end
`elsif fpgaposim
 initial begin
	$sdf_annotate("../fpga/simulation/custom/CQ02A_FPGA_v.sdo",cq02a_test.xCQ02A_CHIPTOP,,"CQ02_fpga.sdf.log");
 end
`endif


endmodule
