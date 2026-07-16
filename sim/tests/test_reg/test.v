
reg [31:0] rd_da;
integer i,err;

initial begin
force MI2523_tb.sdo_pad=0; //I2C DEV_ID  SEL:0=26h  1=27h
//force MI2523_tb.xMI2523_TOP.xAFE_TOP.sync_sig=0;
wait (MI2523_tb.xMI2523_TOP.xdig_top.efuse_load_done);
#1000;
`I2C.i2c_wr8(7'h27,8'h42,8'h42);
`I2C.i2c_wr8(7'h27,8'h43,8'h43);
`I2C.i2c_wr8(7'h27,8'h44,8'h44);
`I2C.i2c_rd8(7'h27,8'h42,rd_da);
`I2C.i2c_rd8(7'h27,8'h43,rd_da);
`I2C.i2c_rd8(7'h27,8'h44,rd_da);

`I2C.i2c_wr8(7'h27,8'h00,8'ha0);
`I2C.i2c_rd8(7'h27,8'h10,rd_da);
`I2C.i2c_rd8(7'h27,8'h10,rd_da);

#80000;
//wait (MI2523_tb.xMI2523_TOP.xdig_top.efuse_load_done);
`I2C.i2c_wr8(7'h27,8'h00,8'ha0);
`I2C.i2c_rd8(7'h27,8'h10,rd_da);
`I2C.i2c_rd8(7'h27,8'h10,rd_da);
//#10000;
//wait (MI2523_tb.xMI2523_TOP.xdig_top.efuse_load_done);
`I2C.i2c_wr8(7'h27,8'h00,8'ha5);
`I2C.i2c_rd8(7'h27,8'h10,rd_da);
`I2C.i2c_rd8(7'h27,8'h10,rd_da);
//OSR
`I2C.i2c_wr8(7'h27,8'h11,8'h01);
//TM MODE 
`I2C.i2c_wr8(7'h27,8'h7F,8'h83);
`I2C.i2c_wr8(7'h27,8'h7F,8'h69);
`I2C.i2c_wr8(7'h27,8'h7F,8'hbd); 
#100000;
for (i=0;i<205;i=i+4) begin
`I2C.i2c_rd32(7'h27,i,rd_da);
end

//OSR
`I2C.i2c_wr8(7'h27,8'h11,8'h41);
////////////////////////////////////// CHANGE ID ///////////////////////////////
#10000;
`I2C.i2c_wr8(7'h27,8'hc7,8'hc7); 
//`I2C.i2c_wr8(7'h47,8'h00,8'ha1);
//TM MODE 
`I2C.i2c_wr8(7'h47,8'h7F,8'h83);
`I2C.i2c_wr8(7'h47,8'h7F,8'h69);
`I2C.i2c_wr8(7'h47,8'h7F,8'hbd); 
`I2C.i2c_wr8(7'h47,8'h7F,8'hdb); 

for (i=1;i<205;i=i+3) begin
`I2C.i2c_wr8(7'h47,i,i);
end
//OSR
`I2C.i2c_wr8(7'h47,8'h11,8'h11);
for (i=1;i<205;i=i+3) begin
`I2C.i2c_rd8(7'h47,i,rd_da);
end
`I2C.i2c_wr8(7'h47,8'h10,8'h09);
#1500000;
//OSR
`I2C.i2c_wr8(7'h47,8'h11,8'h51);
`I2C.i2c_wr8(7'h47,8'h10,8'h05);
#2500000;

$finish;
end
