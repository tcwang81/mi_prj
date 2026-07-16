
reg [7:0] rd_da;
integer i,err;

initial begin
force MI2523_tb.sdo_pad=0; //I2C DEV_ID  SEL:0=26h  1=27h
//force MI2523_tb.xMI2523_TOP.INT1=0;
wait (MI2523_tb.xMI2523_TOP.xdig_top.efuse_load_done);
#100;

/////////////////////////////////////////////////

`I2C.i2c_wr8(7'h27,8'h10,8'h0a);
`I2C.i2c_wr8(7'h27,8'h11,8'h8e);
`I2C.i2c_wr8(7'h27,8'h17,8'h10);
`I2C.i2c_wr8(7'h27,8'h1a,8'h01);
`I2C.i2c_wr8(7'h27,8'h20,8'h01);
`I2C.i2c_wr8(7'h27,8'h11,8'h0e);

wait (MI2523_tb.xMI2523_TOP.int_do);
#10000;

`I2C.i2c_rd8(7'h27,8'h07,rd_da);
`I2C.i2c_wr8(7'h27,8'h21,8'h01);
#1000;
wait (MI2523_tb.xMI2523_TOP.xdig_top.xalgorithm_top_2523.i_intlatch.int1_n);
wait (!MI2523_tb.xMI2523_TOP.xdig_top.xalgorithm_top_2523.i_intlatch.int1_n);
#1000;
wait (MI2523_tb.xMI2523_TOP.xdig_top.xalgorithm_top_2523.i_intlatch.int1_n);
#1000;
wait (MI2523_tb.xMI2523_TOP.int_do);
`I2C.i2c_rd8(7'h27,8'h07,rd_da);
`I2C.i2c_wr8(7'h27,8'h21,8'h09);
#1000;
wait (MI2523_tb.xMI2523_TOP.xdig_top.xalgorithm_top_2523.i_intlatch.int1_n);
wait (!MI2523_tb.xMI2523_TOP.xdig_top.xalgorithm_top_2523.i_intlatch.int1_n);
#1000;
wait (MI2523_tb.xMI2523_TOP.xdig_top.xalgorithm_top_2523.i_intlatch.int1_n);
#1000;
wait (MI2523_tb.xMI2523_TOP.int_do);
`I2C.i2c_rd8(7'h27,8'h07,rd_da);
`I2C.i2c_wr8(7'h27,8'h21,8'h0d);
#1000;
wait (MI2523_tb.xMI2523_TOP.xdig_top.xalgorithm_top_2523.i_intlatch.int1_n);
wait (!MI2523_tb.xMI2523_TOP.xdig_top.xalgorithm_top_2523.i_intlatch.int1_n);
#1000;
wait (MI2523_tb.xMI2523_TOP.xdig_top.xalgorithm_top_2523.i_intlatch.int1_n);
#1000;
wait (MI2523_tb.xMI2523_TOP.int_do);
`I2C.i2c_rd8(7'h27,8'h07,rd_da);
`I2C.i2c_wr8(7'h27,8'h21,8'h03);
#1000;
wait (MI2523_tb.xMI2523_TOP.xdig_top.xalgorithm_top_2523.i_intlatch.int1_n);
wait (!MI2523_tb.xMI2523_TOP.xdig_top.xalgorithm_top_2523.i_intlatch.int1_n);
#1000;
wait (MI2523_tb.xMI2523_TOP.xdig_top.xalgorithm_top_2523.i_intlatch.int1_n);
#1000;
wait (MI2523_tb.xMI2523_TOP.int_do);
`I2C.i2c_rd8(7'h27,8'h07,rd_da);

$finish;
end
