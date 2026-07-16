
reg [7:0] rd_da;
integer i,err;

initial begin
err=0;
wait (MI2523_tb.xMI2523_TOP.xdig_top.DIG_POR);
wait (MI2523_tb.xMI2523_TOP.xdig_top.efuse_load_done);
#100;
/////////////////////////////////////

///// for reg write & read /////
for (i=0;i<256;i=i+1) begin
`SPI.spi_wr_msb(1'b0,2'b00,i,i);
end
///////////////////////////////
#100000;
`SPI.spi_wr_msb(1'b0,2'b00,13'h00,32'hc1); //for lsb spi
#10000;
`SPI.spi_wr_lsb(1'b0,2'b10,13'h7f,32'hbd6983);
`SPI.spi_wr_lsb(1'b0,2'b00,13'h7f,8'h69);
`SPI.spi_wr_lsb(1'b0,2'b00,13'h7f,8'hbd);
///for efuse reload 
`SPI.spi_wr_lsb(1'b0,2'b00,13'ha4,32'h69);
#10000;
wait (MI2523_tb.xMI2523_TOP.xdig_top.efuse_load_done);
//////Efuse ptm mode for efuse pgm phase time///////
`SPI.spi_wr_lsb(1'b0,2'b00,13'ha0,32'h0a); 

///////Efuse PGM mode ///////////
`SPI.spi_wr_lsb(1'b0,2'b00,13'ha3,32'h98);
for (i=0;i<256;i=i+2) begin
`SPI.spi_wr_lsb(1'b0,2'b00,13'ha1,i);
`SPI.spi_wr_lsb(1'b0,2'b00,13'ha3,32'h99);
#5000;
wait (!MI2523_tb.xMI2523_TOP.xdig_top.PGMEN);
end
///////////for reload after PGM finish ////////////////
#10000;
`SPI.spi_wr_lsb(1'b0,2'b00,13'ha3,32'h00);
`SPI.spi_wr_lsb(1'b0,2'b00,13'ha4,32'h69);

//for check efuse reload data 32address///
for (i=0;i<32;i=i+1) begin
@(negedge MI2523_tb.xMI2523_TOP.xdig_top.efuse_aen);
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

wait (MI2523_tb.xMI2523_TOP.xdig_top.efuse_load_done);

$finish;
end
