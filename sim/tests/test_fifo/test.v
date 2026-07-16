`define spi_mhz 4	//10Mhz
reg [31:0] rd_da;
integer i,err;

initial begin
force MI2523_tb.sdo_pad=0; //I2C DEV_ID  SEL:0=26h  1=27h
force MI2523_tb.xMI2523_TOP.xAFE_TOP.int_di=0;
//force MI2523_tb.xMI2523_TOP.xdig_top.xfifo_x.read=1;
wait (MI2523_tb.xMI2523_TOP.xdig_top.efuse_load_done);
#1000;
/////// TEST  mode
`I2C.i2c_wr8(7'h26,8'h7f,8'h83);
`I2C.i2c_wr8(7'h26,8'h7f,8'h69);
`I2C.i2c_wr8(7'h26,8'h7f,8'hbd);
//fine set =default otp 0x1FH
`I2C.i2c_wr8(7'h26,8'hca,8'h92);

`I2C.i2c_rd32(7'h26,8'h08,rd_da);
//pwron set =default 9EH
`I2C.i2c_wr8(7'h26,8'h11,8'h1E);
//set ODR
`I2C.i2c_wr8(7'h26,8'h10,8'h0d);
//adc slot set=default 1BH
`I2C.i2c_wr8(7'h26,8'h39,8'h1b);

`I2C.i2c_wr8(7'h26,8'h7f,8'hdb);

//FIFO MODE set =00H {fifomode[1:0],fifo_clr,watermark_sample[4:0]
`I2C.i2c_wr8(7'h26,8'h14,8'h00);
#10000000;
`I2C.i2c_rd32(7'h26,8'h02,rd_da[31:0]);
#100000;
`SPI.spi_rd_msb(2'b11,8'h02,rd_da);
#100000;
//FIFO MODE set =00H {fifomode[1:0],fifo_clr,watermark_sample[4:0]
`I2C.i2c_wr8(7'h26,8'h14,8'h40);
#50000000;
/*
force MI2523_tb.xMI2523_TOP.xdig_top.lsb_first=1;
`I2C.i2c_rd32(7'h26,8'h02,rd_da);
`I2C.i2c_rd32(7'h26,8'h02,rd_da);
`I2C.i2c_rd32(7'h26,8'h02,rd_da);
`I2C.i2c_rd32(7'h26,8'h02,rd_da);
`I2C.i2c_rd32(7'h26,8'h02,rd_da);
`I2C.i2c_rd32(7'h26,8'h02,rd_da);
`I2C.i2c_rd32(7'h26,8'h02,rd_da);
`I2C.i2c_rd32(7'h26,8'h02,rd_da);
`I2C.i2c_rd32(7'h26,8'h02,rd_da);
`I2C.i2c_rd32(7'h26,8'h02,rd_da);
`I2C.i2c_rd32(7'h26,8'h02,rd_da);
`I2C.i2c_rd32(7'h26,8'h02,rd_da);
`I2C.i2c_rd32(7'h26,8'h02,rd_da);
`I2C.i2c_rd32(7'h26,8'h02,rd_da);
release MI2523_tb.xMI2523_TOP.xdig_top.lsb_first;
*/
#50000000;
`SPI.spi_rd_msb(2'b11,8'h07,rd_da);
`SPI.spi_rd_msb(2'b11,8'h07,rd_da);
`SPI.spi_rd_msb(2'b11,8'h07,rd_da);
`SPI.spi_rd_msb(2'b11,8'h07,rd_da);
`SPI.spi_rd_msb(2'b11,8'h07,rd_da);
`SPI.spi_rd_msb(2'b11,8'h07,rd_da);
`SPI.spi_rd_msb(2'b11,8'h07,rd_da);
`SPI.spi_rd_msb(2'b11,8'h07,rd_da);
`SPI.spi_rd_msb(2'b11,8'h07,rd_da);
`SPI.spi_rd_msb(2'b11,8'h07,rd_da);

#1000000;
`SPI.spi_rd_msb(2'b11,8'h07,rd_da);
`SPI.spi_rd_msb(2'b11,8'h07,rd_da);
`SPI.spi_rd_msb(2'b11,8'h07,rd_da);
`SPI.spi_rd_msb(2'b11,8'h07,rd_da);
`SPI.spi_rd_msb(2'b11,8'h07,rd_da);
`SPI.spi_rd_msb(2'b11,8'h07,rd_da);
`SPI.spi_rd_msb(2'b11,8'h07,rd_da);
`SPI.spi_rd_msb(2'b11,8'h07,rd_da);
`SPI.spi_rd_msb(2'b11,8'h07,rd_da);
`SPI.spi_rd_msb(2'b11,8'h07,rd_da);
`SPI.spi_rd_msb(2'b11,8'h07,rd_da);

#1000000;
`SPI.spi_rd_msb(2'b11,8'h07,rd_da);
`SPI.spi_rd_msb(2'b11,8'h07,rd_da);
`SPI.spi_rd_msb(2'b11,8'h07,rd_da);
`SPI.spi_rd_msb(2'b11,8'h07,rd_da);
`SPI.spi_rd_msb(2'b11,8'h07,rd_da);
`SPI.spi_rd_msb(2'b11,8'h07,rd_da);
`SPI.spi_rd_msb(2'b11,8'h07,rd_da);
`SPI.spi_rd_msb(2'b11,8'h07,rd_da);
`SPI.spi_rd_msb(2'b11,8'h07,rd_da);
`SPI.spi_rd_msb(2'b11,8'h07,rd_da);


#10000000;

//FIFO MODE set =00H {fifomode[1:0],fifo_clr,watermark_sample[4:0]
`I2C.i2c_wr8(7'h26,8'h14,8'h80);
#10000000;
`SPI.spi_rd_msb(2'b11,8'h02,rd_da);
#100000;
`SPI.spi_rd_msb(2'b11,8'h02,rd_da);
#100000;

//FIFO MODE set =00H {fifomode[1:0],fifo_clr,watermark_sample[4:0]
`SPI.spi_rd_msb(2'b11,8'h02,rd_da);
#10000000;
`SPI.spi_rd_msb(2'b11,8'h02,rd_da);
#100000;
`SPI.spi_rd_msb(2'b11,8'h02,rd_da);
#100000;
$finish;
end
