
reg [7:0] rd_da;
integer i,err;

initial begin
force MI2523_tb.sdo_pad=0; //I2C DEV_ID  SEL:0=26h  1=27h
//force MI2523_tb.xMI2523_TOP.xAFE_TOP.int_di=0;
err=0;
wait (MI2523_tb.xMI2523_TOP.xdig_top.DIG_POR);
wait (MI2523_tb.xMI2523_TOP.xdig_top.efuse_load_done);
#100;
`I2C.i2c_wr8(7'h27,8'h00,8'h04);
#500;
wait (MI2523_tb.xMI2523_TOP.xdig_top.efuse_load_done);
#100000;
//// enter TM mode /// check data seq for TM////
`I2C.i2c_wr8(7'h27,8'h7f,8'h83);
`I2C.i2c_wr8(7'h27,8'ha4,8'h69); // test into TM mode for fail cmd
`I2C.i2c_wr8(7'h27,8'h7f,8'hbd);

`I2C.i2c_wr8(7'h27,8'h7f,8'h69);
`I2C.i2c_wr8(7'h27,8'h7f,8'hbd);

`I2C.i2c_wr8(7'h27,8'h7f,8'h83); // check corrent cmd for TM mode
`I2C.i2c_wr8(7'h27,8'h7f,8'h69);
`I2C.i2c_wr8(7'h27,8'h7f,8'hbd);

/////////////////////////////////////

///for efuse reload 
`I2C.i2c_wr8(7'h27,8'ha4,8'h69);
wait (MI2523_tb.xMI2523_TOP.xdig_top.efuse_load_done);
//////Efuse ptm mode for efuse pgm phase time///////
`I2C.i2c_wr8(7'h27,8'ha0,8'h08); 

///////Efuse PGM mode ///////////
`I2C.i2c_wr8(7'h27,8'ha3,8'h98);
for (i=0;i<256;i=i+2) begin
`I2C.i2c_wr8(7'h27,8'ha1,i);
`I2C.i2c_wr8(7'h27,8'ha3,8'h99);
wait (!MI2523_tb.xMI2523_TOP.xdig_top.from_dig_PGMEN);
end
///////////for reload after PGM finish ////////////////
#300000;
`I2C.i2c_wr8(7'h27,8'ha3,8'h00);
`I2C.i2c_wr8(7'h27,8'ha4,8'h69);
wait (MI2523_tb.xMI2523_TOP.xdig_top.efuse_load_done);
/*
//for check efuse reload data 32address///
for (i=0;i<32;i=i+1) begin
@(negedge MI2523_tb.xMI2523_TOP.xdig_top.xS0153GEFUSE_PIPO256B.AEN);
	if ((MI2523_tb.xMI2523_TOP.xdig_top.xS0153GEFUSE_PIPO256B.D!=8'hff)&(i%2==0)) begin 
	err=err+1 ;
	$display("eFuse err has..... %d number",err);
	end
	if ((MI2523_tb.xMI2523_TOP.xdig_top.xS0153GEFUSE_PIPO256B.D!=8'h00)&(i%2==1)) begin 
	err=err+1 ;
	$display("eFuse err has..... %d number",err);
	end
end
	
if(err==0) $display("###### eFuse write & read & reload func => PASS #######");
*/
#100000;//ALLOTPMODE
`I2C.i2c_wr8(7'h27,8'ha0,8'h88);
`I2C.i2c_wr8(7'h27,8'ha3,8'h98);
wait (!MI2523_tb.xMI2523_TOP.xdig_top.xefuse_ctrl.allotp_pgmmode);
#10000;//BYTEMODE
`I2C.i2c_wr8(7'h27,8'ha1,8'h11); 
`I2C.i2c_wr8(7'h27,8'ha0,8'h48); 
wait (!MI2523_tb.xMI2523_TOP.xdig_top.otp_bytemode);
`I2C.i2c_wr8(7'h27,8'ha1,8'h12);
`I2C.i2c_wr8(7'h27,8'ha0,8'h48); 
wait (!MI2523_tb.xMI2523_TOP.xdig_top.otp_bytemode);
`I2C.i2c_wr8(7'h27,8'ha1,8'h0d);
`I2C.i2c_wr8(7'h27,8'ha0,8'h48); 
wait (!MI2523_tb.xMI2523_TOP.xdig_top.otp_bytemode);
`I2C.i2c_wr8(7'h27,8'ha1,8'h0e);
`I2C.i2c_wr8(7'h27,8'ha0,8'h48); 
wait (!MI2523_tb.xMI2523_TOP.xdig_top.otp_bytemode);
#1000; //CUS_PGMMODE
`I2C.i2c_wr8(7'h27,8'ha0,8'h08); 
`I2C.i2c_wr8(7'h27,8'ha3,8'h00);
`I2C.i2c_wr8(7'h27,8'h7f,8'h5a); // check corrent cmd for TM mode
#10000;//BYTEMODE
`I2C.i2c_wr8(7'h27,8'h45,8'ha9); 
wait (!MI2523_tb.xMI2523_TOP.xdig_top.xmi_regfile.cus_start_pgm);

#50000;
`I2C.i2c_wr8(7'h27,8'h7f,8'h83); // check corrent cmd for TM mode
`I2C.i2c_wr8(7'h27,8'h7f,8'h69);
`I2C.i2c_wr8(7'h27,8'h7f,8'hbd);
`I2C.i2c_wr8(7'h27,8'ha3,8'h00);
#50000;


$finish;
end
