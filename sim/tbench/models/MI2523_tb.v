`timescale 1ns/100ps

`define DISPLAY_ACK 1'b0

`define I2C MI2523_tb.xI2C_M
`define SPI MI2523_tb.xSPI_M

module MI2523_tb();
 
//output 
wire 	GND,GND_IO,VDD;
wire	INT1,INT2;
wire	SDO;
wire sdo_pad;
//input
wire	CSB,SCL,SCK,SDA,SDI;
wire	SCL_SCK;
//INOUT
wire	SDA_SDI; 
reg rstn,pad_scan;

reg clk_i;  //for FPGA
 initial begin
 	clk_i=0;
	forever #10 clk_i=~clk_i;
 end 
 	
//pullup(SDA_SDI); 
`ifdef fpga_pos
//wire i2c_oe = xMI2523_TOP.xdig_top.sdio_doe;
wire i2c_oe=~MI2523_tb.xI2C_M.EO ;
`else
wire i2c_oe = xMI2523_TOP.xdig_top.sdio_doe;
`endif
assign	SCL_SCLK = CSB ? SCL : SCK;

assign	SDA_SDI = CSB&!i2c_oe? SDA : 
		  ~CSB&!i2c_oe ? SDI:1'bz;
assign	SDA =CSB&i2c_oe ? SDA_SDI:1'bz;
wire #8 csb_pad =CSB;
/*
wire sda;
assign #8 SDA=sda;
nmos nmos_sda(sda,1'b0,~SDA_SDI);
pullup(weak1) pullup_scl(SCL);
pullup(weak1) pullup_sda(SDA);
*/
assign	SDO= ~CSB&i2c_oe ?SDA_SDI:sdo_pad;
//////////////// SUB BLOCK ////////////////////////////

SPI_M xSPI_M(//oatputs
	.CSB(CSB),
	.SCK(SCK),
	.MOSI(SDI),
	//inputs
	.MISO(SDO)
	);

I2C_M xI2C_M(
	.SCLo(SCL),
	.SDA(SDA)
	); 

MI2523_TOP xMI2523_TOP (
	//output
//	.sdo_pad(sdo_pad),
//	.int2_pad(),
	.int_pad(),
`ifdef FPGA
	.w_SPI_Clk(w_SPI_Clk),
	.w_SPI_MISO(w_SPI_MISO),
	.w_SPI_MOSI(w_SPI_MOSI),
	.w_SPI_CS_n(w_SPI_CS_n),
	//.scl(scl),
	//.sda(sda),
	.clk_i(clk_i),
	.rstn(rstn),
`endif
//	.csb_pad(csb_pad),		
	.scl_pad(SCL_SCLK),
	.sdio_pad(SDA_SDI)

 );

 
//FOR Initial & RESET
initial begin
	rstn=0;
	pad_scan=1;
#100	rstn=1;
	end
	

`include "test.v"

// Dump Waveforms
`ifdef  DUMP_FSDB
initial begin
	$fsdbDumpfile("MI2523_presim.fsdb");
	$fsdbDumpvars(0, MI2523_tb); 
	end
`endif

`ifdef DUMP_SHM
initial begin
  $shm_open("wave.shm"); 
  $shm_probe(MI2523_tb,"ACMTF");
end
`endif

// Back Annotate for Post Simulation
`ifdef pos_max
 initial begin
     `ifdef SDF_FILE
        $sdf_annotate(`SDF_FILE, u_tb.u_chip.u_core);
    `else
	$sdf_annotate("../../../impl/APR/final/dig_top_multi_corner.sdf",MI2523_tb.xMI2523_TOP.xdig_top,,"MI2523_max.sdf.log","MAXIMUM",,);
    `endif
 end
`elsif pos_min
 initial begin
    `ifdef SDF_FILE
        $sdf_annotate(`SDF_FILE, u_tb.u_chip.u_core);
    `else
	$sdf_annotate("../../../impl/APR/final/dig_top_multi_corner.sdf",MI2523_tb.xMI2523_TOP.xdig_top,,"MI2523_min.sdf.log","MINIMUM",,);
    `endif
 end
`elsif pos_typ
 initial begin
     `ifdef SDF_FILE
        $sdf_annotate(`SDF_FILE, u_tb.u_chip.u_core);
    `else
    	$sdf_annotate("../../../impl/APR/final/dig_top_multi_corner.sdf",MI2523_tb.xMI2523_TOP.xdig_top,,"MI2523_min.sdf.log","TYPICAL",,);
    `endif
 end
`elsif fpgaposim
 initial begin
	$sdf_annotate("../fpga/simulation/questa/mi2523_v.sdo",MI2523_tb.xMI2523_TOP,,"MI2523_fpga.sdf.log","TYPICAL",,);
 end
`endif


endmodule
