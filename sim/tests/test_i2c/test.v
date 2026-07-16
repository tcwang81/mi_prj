
reg [7:0] rd_da;
integer i,err;

initial begin
err=0;
`ifdef fpgaposim
wait (MI2523_tb.xMI2523_TOP.xdig_top.xefuse_ctrl.efuse_load_done1);
`else
wait (MI2523_tb.xMI2523_TOP.xdig_top.efuse_load_done);
`endif
#100;
`I2C.i2c_wr8(7'h27,8'h42,8'h42);
`I2C.i2c_wr8(7'h27,8'h43,8'h43);
`I2C.i2c_wr8(7'h27,8'h44,8'h44);
`I2C.i2c_rd8(7'h27,8'h42,rd_da);
`I2C.i2c_rd8(7'h27,8'h43,rd_da);
`I2C.i2c_rd8(7'h27,8'h44,rd_da);

`I2C.i2c_wr8(7'h27,8'h00,8'ha5);
`I2C.i2c_rd8(7'h27,8'h10,rd_da);
`I2C.i2c_rd8(7'h27,8'h10,rd_da);


`I2C.i2c_wr8(7'h27,8'h7f,8'h83);
`I2C.i2c_wr8(7'h27,8'h7f,8'h69);
`I2C.i2c_wr8(7'h27,8'h7f,8'hbd);

//////CHANGE I2C ID ADDRESS ////
`I2C.i2c_wr8(7'h27,8'hC7,8'hbd);
`I2C.i2c_rd8(7'hbd,8'hC7,rd_da);
#10000;
`I2C.i2c_wr8(7'hbd,8'hC7,8'h27);
#10000;
//////Efuse write mode///////
`I2C.i2c_wr8(7'h27,8'ha0,8'h0a);
///////Efuse write ///////////
`I2C.i2c_wr8(7'h27,8'ha3,8'h98);
for (i=0;i<256;i=i+2) begin
`I2C.i2c_wr8(7'h27,8'ha1,i);
`I2C.i2c_wr8(7'h27,8'ha3,8'h99);
`ifdef FPGA
wait (!MI2523_tb.xMI2523_TOP.xdig_top.xefuse_ctrl.efuse_pgmen);
`else
wait (!MI2523_tb.xMI2523_TOP.xdig_top.PGMEN);
`endif
end
///////////////////////////
#10000;
`I2C.i2c_wr8(7'h27,8'ha3,8'h00);
`I2C.i2c_wr8(7'h27,8'ha4,8'h69);

`ifdef FPGA
`else
//for check efuse reload data 32address///
for (i=0;i<32;i=i+1) begin
@(negedge MI2523_tb.xMI2523_TOP.xdig_top.xefuse_ctrl.efuse_aen);
	if ((MI2523_tb.xMI2523_TOP.xdig_top.efuse_din!=8'hff)&(i%2==0)) begin 
	err=err+1 ;
	$display("eFuse err has..... %d number",err);
	end
	if ((MI2523_tb.xMI2523_TOP.xdig_top.efuse_din!=8'h00)&(i%2==1)) begin 
	err=err+1 ;
	$display("eFuse err has..... %d number",err);
	end
end
	
if(err==0) $display("###### eFuse write & read & reload func => PASS #######");
#1000;
`endif
$finish;
end
