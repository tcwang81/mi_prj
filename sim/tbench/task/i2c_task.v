`timescale 1ns/100ps

module I2C_M(SCLo,SDA);

output SCLo;
inout SDA;

reg SCL,SDAo,EO,sack;
parameter clkp = 1000/`i2cmhz;	//i2cmhz :I2C clock speed
parameter c2duty = 0.25;

wire SDAi;

//pulldown(SDA);
//wire	OE_D=jt08_test.xJT08_CHIPTOP.sda_oeb;
wire SDA = EO ? SDAo : 1'bz;
wire SCLo=SCL;
wire ACK = !EO ? (SDA):1'bz;

pullup(weak1) pullup_sda(SDA); 
//pullup(weak1) pullup_scl(SCLo); 


initial begin
 SCL=0;
 #10 SCL=1;
 SDAo=0;
 EO=1;
end


task startb;
	begin
	#0 			SCL=1;SDAo=1;EO=1;
	#(clkp*c2duty) 		SCL=1;SDAo=0;	
	#(clkp*c2duty*3) 	SCL=0; 
	#(clkp*c2duty);
	end
endtask

task stoptb;
	begin
	#0 			SCL=0;SDAo=0;EO=1;
	#(clkp*c2duty) 		SCL=1;
	#(clkp*c2duty) 		SDAo=1;
	#(clkp*c2duty) 		SCL=1;
	end
endtask
task endi2c;
	begin
	#0 		SCL=0;SDAo=0;	
	#100;	
	end
endtask


task i2c_id_rw;
input [6:0] id;
input rw;
	begin
	#0 			SDAo=id[6];
	#(clkp*c2duty) 		SCL=1;
	#(clkp*c2duty*2)	SCL=0;
	#(clkp*c2duty)		SDAo=id[5];
	#(clkp*c2duty) 		SCL=1;
	#(clkp*c2duty*2)	SCL=0;
	#(clkp*c2duty)		SDAo=id[4];
	#(clkp*c2duty) 		SCL=1;
	#(clkp*c2duty*2)	SCL=0;
	#(clkp*c2duty)		SDAo=id[3];
	#(clkp*c2duty) 		SCL=1;
	#(clkp*c2duty*2)	SCL=0;
	#(clkp*c2duty)		SDAo=id[2];
	#(clkp*c2duty) 		SCL=1;
	#(clkp*c2duty*2)	SCL=0;
	#(clkp*c2duty)		SDAo=id[1];
	#(clkp*c2duty) 		SCL=1;
	#(clkp*c2duty*2)	SCL=0;
	#(clkp*c2duty)		SDAo=id[0];
	#(clkp*c2duty) 		SCL=1;
	#(clkp*c2duty*2)	SCL=0;
	#(clkp*c2duty)		SDAo=rw;	//write :0
	#(clkp*c2duty) 		SCL=1;
	#(clkp*c2duty*2)	SCL=0;
	#(clkp*c2duty) 		EO=0;  SDAo=1'bz; //For ACK
	#(clkp*c2duty) 		SCL=1;
`ifdef DISPLAY_ACK
	if (ACK) begin
	$display("When ACK is Low,No Ack is High ......write Data_8 Now Slave Ack is =>NO_Ack %b" ,ACK);
	end
	sack=ACK;
`endif
	#(clkp*c2duty*2)	SCL=0;
	#(clkp*c2duty) EO=1;
	end
endtask


task i2c_wdata8;
input [7:0] din;
	begin
	#0 			SDAo=din[7];
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;
	#(clkp*c2duty)		SDAo=din[6];
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;	
	#(clkp*c2duty)		SDAo=din[5];
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;		
	#(clkp*c2duty)		SDAo=din[4];
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;		
	#(clkp*c2duty)		SDAo=din[3];
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;	
	#(clkp*c2duty)		SDAo=din[2];
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;		
	#(clkp*c2duty)		SDAo=din[1];
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;		
	#(clkp*c2duty)		SDAo=din[0];
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;
	#(clkp*c2duty) 		EO=0;  SDAo=1'bz; //FOR ACK
	#(clkp*c2duty) 		SCL=1; 
`ifdef DISPLAY_ACK
	if (ACK) begin
	$display("When ACK is Low,No Ack is High ......write Data_8 Now Slave Ack is =>NO_Ack %b" ,ACK);
	end
`endif	
	#(clkp*c2duty*2)	SCL=0;
	#(clkp*c2duty) EO=1;
	end
endtask
task i2c_wdata16;
input [15:0] din;
	begin
	#0 			SDAo=din[15];
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;
	#(clkp*c2duty)		SDAo=din[14];
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;	
	#(clkp*c2duty)		SDAo=din[13];
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;		
	#(clkp*c2duty)		SDAo=din[12];
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;		
	#(clkp*c2duty)		SDAo=din[11];
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;	
	#(clkp*c2duty)		SDAo=din[10];
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;		
	#(clkp*c2duty)		SDAo=din[9];
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;		
	#(clkp*c2duty)		SDAo=din[8];
	#(clkp*c2duty) 		SCL=1; 	
	#(clkp*c2duty*2)	SCL=0;
	#(clkp*c2duty) 		EO=0;  SDAo=1'bz; //FOR ACK
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;EO=1;	
	#(clkp*c2duty) 		SDAo=din[7];
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;
	#(clkp*c2duty)		SDAo=din[6];
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;	
	#(clkp*c2duty)		SDAo=din[5];
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;		
	#(clkp*c2duty)		SDAo=din[4];
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;		
	#(clkp*c2duty)		SDAo=din[3];
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;	
	#(clkp*c2duty)		SDAo=din[2];
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;		
	#(clkp*c2duty)		SDAo=din[1];
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;		
	#(clkp*c2duty)		SDAo=din[0];
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;
	#(clkp*c2duty) 		EO=0;  SDAo=1'bz; //FOR ACK
	#(clkp*c2duty) 		SCL=1; 
`ifdef DISPLAY_ACK
	if (ACK) begin
	$display("When ACK is Low,No Ack is High ......write Data_8 Now Slave Ack is =>NO_Ack %b" ,ACK);
	end
`endif	
	#(clkp*c2duty*2)	SCL=0;
	#(clkp*c2duty) EO=1;
	end
endtask

task i2c_cmd;
input [7:0] din;
	begin
	#0 			SDAo=din[7];
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;
	#(clkp*c2duty)		SDAo=din[6];
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;	
	#(clkp*c2duty)		SDAo=din[5];
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;		
	#(clkp*c2duty)		SDAo=din[4];
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;		
	#(clkp*c2duty)		SDAo=din[3];
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;	
	#(clkp*c2duty)		SDAo=din[2];
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;		
	#(clkp*c2duty)		SDAo=din[1];
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;		
	#(clkp*c2duty)		SDAo=din[0];
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;
	#(clkp*c2duty) 		EO=0;  SDAo=1'bz;   //FOR ACK
	#(clkp*c2duty) 		SCL=1; 
`ifdef DISPLAY_ACK
	if (ACK) begin
	$display("When ACK is Low,No Ack is High ......write Data_8 Now Slave Ack is =>NO_Ack %b" ,ACK);
	end
`endif	
	#(clkp*c2duty*2)	SCL=0;
	#(clkp*c2duty) EO=1;
	end
endtask


task i2c_rdata8;
output [7:0] dout;
	begin
	#0 			EO=0;dout[7]=SDA;
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;
	#(clkp*c2duty)		dout[6]=SDA;
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;	
	#(clkp*c2duty)		dout[5]=SDA;
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;		
	#(clkp*c2duty)		dout[4]=SDA;
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;		
	#(clkp*c2duty)		dout[3]=SDA;
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;	
	#(clkp*c2duty)		dout[2]=SDA;
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;		
	#(clkp*c2duty)		dout[1]=SDA;
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;		
	#(clkp*c2duty)		dout[0]=SDA;
	#(clkp*c2duty) 		SCL=1; 
	#(clkp*c2duty*2)	SCL=0;
	#(clkp*c2duty) 		EO=1;  SDAo=1'b0; //FOR ACK
	#(clkp*c2duty) 		SCL=1; 
`ifdef DISPLAY_ACK
	if (ACK) begin
	$display("When ACK is Low,No Ack is High ......write Data_8 Now Slave Ack is =>NO_Ack %b" ,ACK);
	end
`endif	
	#(clkp*c2duty*2)	SCL=0;
	#(clkp*c2duty) EO=0;	
	end
endtask


task i2c_rdata8_nack;
output [7:0] dout;
	begin
	#0 			EO=0;
	#(clkp*c2duty) 		SCL=1; dout[7]=SDA;
	#(clkp*c2duty*2)	SCL=0;
	#(clkp*c2duty)		
	#(clkp*c2duty) 		SCL=1; dout[6]=SDA;
	#(clkp*c2duty*2)	SCL=0;	
	#(clkp*c2duty)		
	#(clkp*c2duty) 		SCL=1; dout[5]=SDA;
	#(clkp*c2duty*2)	SCL=0;		
	#(clkp*c2duty)		
	#(clkp*c2duty) 		SCL=1; dout[4]=SDA;
	#(clkp*c2duty*2)	SCL=0;		
	#(clkp*c2duty)		
	#(clkp*c2duty) 		SCL=1; dout[3]=SDA;
	#(clkp*c2duty*2)	SCL=0;	
	#(clkp*c2duty)		
	#(clkp*c2duty) 		SCL=1; dout[2]=SDA;
	#(clkp*c2duty*2)	SCL=0;		
	#(clkp*c2duty)		
	#(clkp*c2duty) 		SCL=1; dout[1]=SDA;
	#(clkp*c2duty*2)	SCL=0;		
	#(clkp*c2duty)		
	#(clkp*c2duty) 		SCL=1; dout[0]=SDA;
	#(clkp*c2duty*2)	SCL=0;
	#(clkp*c2duty) 		EO=1;  SDAo=1'b1; //FOR ACK
	#(clkp*c2duty) 		SCL=1; 
`ifdef DISPLAY_ACK
	if (ACK) begin
	$display("When ACK is Low,No Ack is High ......write Data_8 Now Slave Ack is =>NO_Ack %b" ,ACK);
	end
`endif	
	#(clkp*c2duty*2)	SCL=0;
	#(clkp*c2duty) EO=0;	
	end
endtask
task i2c_rdata16;
output [15:0] dout;
	begin
	i2c_rdata8_nack(dout[15:8]);
	i2c_rdata8(dout[7:0]);
	end
endtask

task i2c_scanidx;

input [6:0] id;
	begin
	startb;
	i2c_id_rw(id,1'b0);
	//stoptb;
	end
endtask

task i2c_scanid;

input [6:0] id;
	begin
	startb;
	i2c_id_rw(id,1'b0);
	if (!sack) begin
		stoptb;
	end
	end
endtask
task i2c_wr8;

input [6:0] id;
input [7:0] radr;
input [7:0] rdin;

	begin
	startb;
	i2c_id_rw(id,1'b0);
	i2c_cmd(radr);
	i2c_wdata8(rdin);
	stoptb;
	end
endtask

task i2c_wr16;

input [6:0] id;
input [7:0] radr;
input [15:0] rdin;

	begin
	startb;
	i2c_id_rw(id,1'b0);
	i2c_cmd(radr);
	i2c_wdata16(rdin);
	stoptb;
	end
endtask
task i2c_wr32;

input [6:0] id;
input [7:0] radr;
input [31:0] rdin;

	begin
	startb;
	i2c_id_rw(id,1'b0);
	i2c_cmd(radr);
	i2c_wdata8(rdin[31:24]);
	i2c_wdata8(rdin[23:16]);
	i2c_wdata8(rdin[15:8]);
	i2c_wdata8(rdin[7:0]);		
	stoptb;
	end
endtask



task i2c_rd8;

input [6:0] id;
input [7:0] radr;
output [7:0] rdo;

	begin
	startb;
	i2c_id_rw(id,0); //write : rw=0
	i2c_cmd(radr);	
	startb;
	i2c_id_rw(id,1'b1); //read : rw=1
	i2c_rdata8_nack(rdo);
	$display("i2c read address=%h ,rdata=%h",radr,rdo);
	stoptb;
	end
endtask


task i2c_rd16;

input [6:0] id;
input [7:0] radr;
output [15:0] rdo;

	begin
	startb;
	i2c_id_rw(id,1'b0); //write : rw=0
	i2c_cmd(radr);
	startb;
	i2c_id_rw(id,1'b1); //read : rw=1
	i2c_rdata8(rdo[15:8]);
	i2c_rdata8_nack(rdo[7:0]);
	$display("i2c read address=%h ,rdata=%h",radr,rdo);
	stoptb;
	end
endtask

task i2c_rd32;

input [6:0] id;
input [7:0] radr;
output [31:0] rdo;

	begin
	startb;
	i2c_id_rw(id,1'b0); //write : rw=0
	i2c_cmd(radr);
	startb;
	i2c_id_rw(id,1'b1); //read : rw=1
	i2c_rdata8(rdo[31:24]);
	i2c_rdata8(rdo[23:16]);
	i2c_rdata8(rdo[15:8]);
	i2c_rdata8_nack(rdo[7:0]);	
	$display("i2c read address=%h ,rdata=%h",radr,rdo);
	stoptb;
	end
endtask

task i2c_rd_Nbyte;

input [6:0] id;
input [7:0] radr;
input integer i;
output [7:0] rdo;

	begin
	startb;
	i2c_id_rw(id,1'b0); //write : rw=0
	i2c_cmd(radr);
	startb;
	i2c_id_rw(id,1'b1); //read : rw=1
	repeat (i) i2c_rdata8(rdo);
	i2c_rdata8_nack(rdo);
	$display("i2c read address=%h ,rdata=%h",radr,rdo);
	stoptb;
	end
endtask

task i2c_cadr_rd;

input [6:0] id;
input integer i;
output [7:0] rdo;

	begin
	startb;
	i2c_id_rw(id,1'b1); //read : rw=1
	repeat (i) i2c_rdata8(rdo);
	i2c_rdata8_nack(rdo[7:0]);
	stoptb;
	end
endtask


task i2c_randm_rd;

input [6:0] id;
input [7:0] radr;
input integer i;
output [7:0] rdo;

	begin
	startb;
	i2c_id_rw(id,1'b0); //write : rw=0
	i2c_cmd(radr);
	startb;
	i2c_id_rw(id,1'b1); //read : rw=1
	repeat (i) i2c_rdata8(rdo);
	stoptb;
	end
endtask

task i2c_data_wr;

input [6:0] id;
input [7:0] radr;
input integer n;
input [31:0] rdin;


integer i,h,l;
	begin
	startb;
	i2c_id_rw(id,1'b0); //write : rw=0
	i2c_cmd(radr);
	
	if(n==1) begin 
		i2c_wdata8(rdin[7:0]); 	end
	else if(n==2) begin 
		i2c_wdata8(rdin[7:0]); 
		i2c_wdata8(rdin[15:8]);	end
	else if(n==3) begin 
		i2c_wdata8(rdin[7:0]); 
		i2c_wdata8(rdin[15:8]);	
		i2c_wdata8(rdin[23:16]);end
	else if(n==4) begin 
		i2c_wdata8(rdin[7:0]); 
		i2c_wdata8(rdin[15:8]);	
		i2c_wdata8(rdin[23:16]);
		i2c_wdata8(rdin[31:24]);end
		
	stoptb;
	end
	
endtask

task i2c_regadr_wr;

input [6:0] id;
input [7:0] radr;

	begin
	startb;
	i2c_id_rw(id,1'b0); //write : rw=0
	i2c_cmd(radr);	
	stoptb;
	end
	
endtask


endmodule

