
reg [31:0] rd_da;
integer i,err;

initial begin
force MI2523_tb.sdo_pad=0; //I2C DEV_ID  SEL:0=26h  1=27h
`ifdef fpga
`elsif fpga_pos
`else 
force MI2523_tb.xMI2523_TOP.xAFE_TOP.int_di=0;
`endif

wait (MI2523_tb.xMI2523_TOP.xdig_top.efuse_load_done);
#1000;
`I2C.i2c_rd8(7'h26,8'h01,rd_da[7:0]);
#100000;
`I2C.i2c_rd16(7'h26,8'h00,rd_da[15:0]);
#100000;
`I2C.i2c_rd32(7'h26,8'h06,rd_da[31:0]);
//ODR
#100000;
`I2C.i2c_wr8(7'h26,8'h10,8'h0b);
#100000;
`I2C.i2c_wr16(7'h26,8'h10,16'h0b0a);
#100000;
`I2C.i2c_wr32(7'h26,8'h10,32'h0d0c0b0a);
#100000;
`I2C.i2c_rd8(7'h26,8'h10,rd_da);
//PWR_ON
`I2C.i2c_wr8(7'h26,8'h11,8'h1e);
`I2C.i2c_rd8(7'h26,8'h11,rd_da);
//TM MODE 
`I2C.i2c_wr8(7'h26,8'h7F,8'h83);
`I2C.i2c_wr8(7'h26,8'h7F,8'h69);
`I2C.i2c_wr8(7'h26,8'h7F,8'hbd);
#1000;
`I2C.i2c_wr8(7'h26,8'hcb,8'h52);
`I2C.i2c_wr8(7'h26,8'h14,8'h90);


`I2C.i2c_wr8(7'h26,8'h39,{1'b1,1'b0,2'b11,2'b10,2'b01});
#1000000;
force MI2523_tb.sdo_pad=1; //I2C DEV_ID  SEL:0=26h  1=27h
#1000;
`I2C.i2c_rd8(7'h27,8'h01,rd_da);
//ODR
`I2C.i2c_wr8(7'h27,8'h10,8'h0b);
`I2C.i2c_rd8(7'h27,8'h10,rd_da);
//PWR_ON
`I2C.i2c_wr8(7'h27,8'h11,8'h1e);
`I2C.i2c_rd8(7'h27,8'h11,rd_da);
//TM MODE 
`I2C.i2c_wr8(7'h27,8'h7F,8'h83);
`I2C.i2c_wr8(7'h27,8'h7F,8'h69);
`I2C.i2c_wr8(7'h27,8'h7F,8'hbd);
#1000;
`I2C.i2c_wr8(7'h27,8'hcb,8'h52);
`I2C.i2c_wr8(7'h27,8'h14,8'h90);


`I2C.i2c_wr8(7'h27,8'h39,{1'b1,1'b0,2'b11,2'b10,2'b01});
#1000;
`I2C.endi2c;
#100000;
////////////////////////////////////////////
release  MI2523_tb.sdo_pad;


`SPI.spi_rd_msb(2'b10,13'h0,rd_da);
`SPI.spi_rd_msb(2'b10,13'h1,rd_da);
`SPI.spi_rd_msb(2'b10,13'hff,rd_da);



for (i=15;i<18;i=i+1) begin
`SPI.spi_wr_msb(1'b0,2'b11,i,$random());
//`SPI.spi_rd_msb(2'b00,i,rd_da);
//`SPI.spi_rd_msb(2'b01,i,rd_da);
//`SPI.spi_rd_msb(2'b10,i,rd_da);
`SPI.spi_rd_msb(2'b11,i,rd_da);
end

for (i=20;i<27;i=i+1) begin
`SPI.spi_wr_msb(1'b0,2'b11,i,$random());
//`SPI.spi_rd_msb(2'b00,i,rd_da);
//`SPI.spi_rd_msb(2'b01,i,rd_da);
//`SPI.spi_rd_msb(2'b10,i,rd_da);
`SPI.spi_rd_msb(2'b11,i,rd_da);
end

for (i=32;i<40;i=i+1) begin
`SPI.spi_wr_msb(1'b0,2'b11,i,i);
//`SPI.spi_rd_msb(2'b00,i,rd_da);
//`SPI.spi_rd_msb(2'b01,i,rd_da);
//`SPI.spi_rd_msb(2'b10,i,rd_da);
`SPI.spi_rd_msb(2'b11,i,rd_da);
end

for (i=145;i<203;i=i+1) begin
`SPI.spi_wr_msb(1'b0,2'b11,i,$random());
//`SPI.spi_rd_msb(2'b00,i,rd_da);
//`SPI.spi_rd_msb(2'b01,i,rd_da);
//`SPI.spi_rd_msb(2'b10,i,rd_da);
`SPI.spi_rd_msb(2'b11,i,rd_da);
end
#10000;
`SPI.spi_wr_msb(1'b0,2'b00,13'h000,8'hc1);
for (i=2;i<27;i=i+1) begin
`SPI.spi_wr_lsb(1'b0,2'b00,i,i);
`SPI.spi_rd_lsb(2'b00,i,rd_da);
`SPI.spi_rd_lsb(2'b11,i,rd_da);
end
for (i=0;i<27;i=i+1) begin
`SPI.spi_rd_lsb(2'b11,i,rd_da);
end

#10000;


$finish;
end
