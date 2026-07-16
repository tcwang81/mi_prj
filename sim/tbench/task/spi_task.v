`timescale 1ns/100ps

module SPI_M(CSB,SCK,MOSI,MISO);

output CSB;
input MISO;
output MOSI,SCK;
reg CSB,MOSI,SCK;
//reg SCK1;
/// SPI interface for SPI task ///
//parameter fsck =10 ; //Mhz
parameter fsck_cyc = 1000/`spi_mhz;
parameter tSCKL =fsck_cyc/2-40 ; //SLCK LOW pulse (ns)
parameter tSCKH =fsck_cyc/2-40  ; //SLCK LOW pulse
parameter tMOSI_setup =20 ; //MOSI setup time
parameter tMOSI_hold =20 ; //MOSI hold time
parameter tSDO_OD =30 ; //SDO/MOSI output delay
parameter tCSB_setup =20 ; //CSB setup time
parameter tCSB_hold =40 ; //CSB hold time

initial begin
CSB=1;
SCK=0;
MOSI=0;
end
wire  #6 SCK1 =  CSB|SCK;
//INTL
task INTL;
begin
  CSB = 1'b1;
  SCK = 1'b0;
  #100  CSB = 1'b1;
end endtask

//GENERATE SCK
task GEN_SCK;
  input [7:0] sclk_bytes;

  reg [7:0] sclk_gen_buf; 
  integer  i;


  begin
    sclk_gen_buf = sclk_bytes;
    for(i=0; i<(sclk_gen_buf*16); i=(i+1)) 
    begin
      SCK = ~SCK;
      #(fsck_cyc/2);
    end
  end
endtask

//GENERATE MOSI/MOSI first MSB
task GEN_MOSI;
  input [7:0] MOSI_data;

  reg [7:0] MOSI_gen_buf; 
  integer i;
  begin
    MOSI_gen_buf = MOSI_data;
    for(i=7; i>=0; i=i-1)
    begin
      @(negedge SCK1) 
       MOSI = MOSI_gen_buf[i];
    end
  end
endtask


//GENERATE MOSI/MOSI first LSB
task GEN_MOSI_B;
  input [7:0] MOSI_data;

  reg [7:0] MOSI_gen_buf; 
  integer j;
  begin
    MOSI_gen_buf = MOSI_data;
    for(j=0; j<=7; j=j+1)
    begin
      @(negedge SCK1) 
       MOSI = MOSI_gen_buf[j];
    end
  end
endtask
//RECV DATA
task RECV_mDATA;
  output   [7:0]   rd_data;
  reg      [7:0]   rd_data;

  integer i;

  begin
    for(i=7; i>=0; i=i-1)
      @(posedge SCK1) rd_data = {rd_data[6:0],MISO}; 
  end 
endtask

//RECV DATA
task RECV_lDATA;
  output   [7:0]   rd_data;
  reg      [7:0]   rd_data;

  integer i;

  begin
    for(i=7; i>=0; i=i-1)
      @(posedge SCK1) rd_data = {MISO,rd_data[7:1]}; 
  end 
endtask

//send start
task send_start;
begin
  	SCK = 1'b0;
	CSB = 1'b0;
end 
endtask

//send stop
task send_stop;
begin
  CSB = 1'b1;
  SCK = 1'b0;
   #((fsck_cyc)/2); SCK = 1'b0;
end 
endtask

//read
task read;
input [7:0] addr; 

reg [7:0] addr_buf;

begin
  addr_buf = addr;
 fork
  	#((fsck_cyc)/2+(fsck_cyc)) 	send_start;
	#((fsck_cyc)*2)  		GEN_SCK(3);
	#((fsck_cyc)/2+(fsck_cyc)) 	GEN_MOSI({addr_buf[5:0],2'b01});
	#((fsck_cyc)*30)  		send_stop;
        join
 end
endtask
//write
task write;
input [7:0] addr;
input [15:0] data_wr;

reg [7:0] addr_buf;
reg [15:0] data_wr_buf;
 begin
 addr_buf =addr;
 data_wr_buf=data_wr;
 //INTL;
 fork
 #((fsck_cyc)*2)		GEN_SCK(3);
 #((fsck_cyc)/2+(fsck_cyc))	send_start;
 #((fsck_cyc)/2+(fsck_cyc))	GEN_MOSI({addr_buf[5:0],2'b00});
 #((fsck_cyc)/2+(fsck_cyc)*9)	GEN_MOSI(data_wr_buf[15:8]);
 #((fsck_cyc)/2+(fsck_cyc)*17)	GEN_MOSI(data_wr_buf[7:0]);
 #((fsck_cyc)*27)		send_stop;
 join
end
endtask

//GEN TM pattern
task GEN_TM_PAT;

reg	[15:0] tm_reg;
integer i;
 begin
 	tm_reg=16'b0101_0101_1010_1010;
 	for(i=15; i>=0; i=i-1)
 	 begin
 	  MOSI = tm_reg[15];
 	  @(negedge SCK)
 	  tm_reg={tm_reg[14:0],1'b0};
 	 end
 end
 endtask
 
task send_tm_pat;
  fork 
   #((fsck_cyc))		send_start;
   #((fsck_cyc)*2)		GEN_SCK(2);
   #((fsck_cyc)/2+(fsck_cyc))	GEN_TM_PAT;
   #((fsck_cyc)*20)		send_stop;
  join
endtask


//////////////////////////////////////
task spi_wr_msb;
input spi_rw;
input [1:0] spi_w;
input [12:0] spi_header;
input [31:0] spi_wdata;
reg [7:0] header;
reg [7:0] rd_data1,rd_data2,rd_data3,rd_data4;
integer cnt;
begin
cnt =spi_w+3;
header ={spi_rw,spi_w[1:0],spi_header[12:8]};
 fork
   #((fsck_cyc))	send_start;
   #((fsck_cyc)*2)	GEN_SCK(cnt);
   #((fsck_cyc)/2)	GEN_MOSI(header);
   #((fsck_cyc)*9)	GEN_MOSI(spi_header[7:0]); 
   #((fsck_cyc)*17) begin
   	if (spi_w==0) begin
   			if(spi_rw) begin
				RECV_mDATA(rd_data1); 
				$display("spi read addr=%h ,data1=%h",spi_header[7:0],rd_data1);
				end
			else GEN_MOSI(spi_wdata[7:0]); 
   			#((fsck_cyc)*2)	send_stop;
			$display("spi write addr=%h ,spi_wdata=%h",spi_header[7:0],spi_wdata[31:0]);
   			end
   	if (spi_w==1) GEN_MOSI(spi_wdata[15:8]);
   	if (spi_w==2) GEN_MOSI(spi_wdata[23:16]);
   	if (spi_w==3) GEN_MOSI(spi_wdata[31:24]); 
   		end
   #((fsck_cyc)*25)  begin
   	if (spi_w==1) begin
   			if(spi_rw)  begin
					RECV_mDATA(rd_data2); 
					$display("spi read addr=%h ,data2=%h",spi_header[7:0],rd_data2);
				   end	
			else GEN_MOSI(spi_wdata[7:0]); 
   			#((fsck_cyc)*2)	send_stop;
			$display("spi write addr=%h ,spi_wdata=%h",spi_header[7:0],spi_wdata[31:0]);
   			end
   	if (spi_w==2) GEN_MOSI(spi_wdata[15:8]);
   	if (spi_w==3) GEN_MOSI(spi_wdata[23:16]); 
   		end
   #((fsck_cyc)*33) begin
   	if (spi_w==2) begin
   			if(spi_rw)  begin
					RECV_mDATA(rd_data3); 
					$display("spi read addr=%h ,data3=%h",spi_header[7:0],rd_data3);
					end	
			else GEN_MOSI(spi_wdata[7:0]); 
   			#((fsck_cyc)*2)	send_stop;
			$display("spi write addr=%h ,spi_wdata=%h",spi_header[7:0],spi_wdata[31:0]);
   			end
   	if (spi_w==3) GEN_MOSI(spi_wdata[15:8]);  
   		end
   #((fsck_cyc)*41) begin
   	if (spi_w==3) begin
   			if(spi_rw)  begin
				RECV_mDATA(rd_data4); 
				$display("spi read addr=%h ,data4=%h",spi_header[7:0],rd_data4);
				end
			else GEN_MOSI(spi_wdata[7:0]); 
   			#((fsck_cyc)*2)	send_stop;
			$display("spi write addr=%h ,spi_wdata=%h",spi_header[7:0],spi_wdata[31:0]);
   			end
   		end
   join
end
endtask

task spi_wr_lsb;
input spi_rw;
input [1:0] spi_w;
input [12:0] spi_header;
input [31:0] spi_wdata;
reg [7:0] header;
reg [7:0] rd_data1,rd_data2,rd_data3,rd_data4;
integer cnt;
begin
cnt =spi_w+3;
header ={spi_rw,spi_w[1:0],spi_header[12:8]};
 fork
   #((fsck_cyc))		send_start;
   #((fsck_cyc)*2)		GEN_SCK(cnt);
   #((fsck_cyc)/2)	GEN_MOSI_B(spi_header[7:0]);
   #((fsck_cyc)*9)	GEN_MOSI_B(header);
   #((fsck_cyc)*17) begin
   	if (spi_w==0) begin
			if(spi_rw) begin
				RECV_lDATA(rd_data1); 
				$display("spi read addr=%h ,data1=%h",spi_header[7:0],rd_data1);
				end
			else 
   			GEN_MOSI_B(spi_wdata[7:0]); 
   			#((fsck_cyc)*2)	send_stop;
   			end
   	if (spi_w==1) GEN_MOSI_B(spi_wdata[7:0]);
   	if (spi_w==2) GEN_MOSI_B(spi_wdata[7:0]);
   	if (spi_w==3) GEN_MOSI_B(spi_wdata[7:0]);
	end
   #((fsck_cyc)*25)begin
   	if (spi_w==1) begin
			if(spi_rw) begin
				RECV_lDATA(rd_data2); 
				$display("spi read addr=%h ,data2=%h",spi_header[7:0],rd_data2);
				end
			else 
   			GEN_MOSI_B(spi_wdata[15:8]); 
   			#((fsck_cyc)*2)	send_stop;
   			end
   	if (spi_w==2) GEN_MOSI_B(spi_wdata[15:8]);
   	if (spi_w==3) GEN_MOSI_B(spi_wdata[15:8]);
	end
   #((fsck_cyc)*33)begin
   	if (spi_w==2) begin
			if(spi_rw) begin
				RECV_lDATA(rd_data3); 
				$display("spi read addr=%h ,data3=%h",spi_header[7:0],rd_data3);
				end
			else 
   			GEN_MOSI_B(spi_wdata[23:16]); 
   			#((fsck_cyc)*2)	send_stop;
   			end
   	if (spi_w==3) GEN_MOSI_B(spi_wdata[23:16]);
	end
   #((fsck_cyc)*41)begin
   	if (spi_w==3) begin
			if(spi_rw) begin
				RECV_lDATA(rd_data4); 
				$display("spi read addr=%h ,data4=%h",spi_header[7:0],rd_data4);
				end
			else 
   			GEN_MOSI_B(spi_wdata[31:24]); 
   			#((fsck_cyc)*2)	send_stop;
   			end
		end	
   join
end
endtask

///////////////////////READ /////
task spi_rd_msb;

input [1:0] spi_w;
input [12:0] spi_header;
output [31:0] spi_rdata;
reg [7:0] header;
reg [31:0] spi_rdata;

integer cnt;

begin
spi_rdata=0;
cnt =spi_w+3;
header ={1'b1,spi_w[1:0],spi_header[12:8]};
 fork
   #((fsck_cyc))	send_start;
   #((fsck_cyc)*2)	GEN_SCK(cnt);
  	GEN_MOSI(header);
   #((fsck_cyc)*9)	GEN_MOSI(spi_header[7:0]); 
   #((fsck_cyc)*18) begin
   	if (spi_w==0) begin
			RECV_mDATA(spi_rdata[7:0]); 
			$display("spi read addr=%h ,rdata=%h",spi_header[7:0],spi_rdata[31:0]);
			//#((fsck_cyc))	send_stop;
			end
   	if (spi_w==1) begin
			RECV_mDATA(spi_rdata[7:0]); 
			RECV_mDATA(spi_rdata[15:8]); 
			$display("spi read addr=%h ,rdata=%h",spi_header[7:0],spi_rdata[31:0]);
   			//#((fsck_cyc))	send_stop;
   			end
   	if (spi_w==2) begin
			RECV_mDATA(spi_rdata[7:0]); 
			RECV_mDATA(spi_rdata[15:8]); 	
			RECV_mDATA(spi_rdata[23:16]); 
			$display("spi read addr=%h ,rdata=%h",spi_header[7:0],spi_rdata[31:0]);
			//#((fsck_cyc))	send_stop;
   			end
   	if (spi_w==3) begin
			RECV_mDATA(spi_rdata[7:0]); 
			RECV_mDATA(spi_rdata[15:8]); 	
			RECV_mDATA(spi_rdata[23:16]);
			RECV_mDATA(spi_rdata[31:24]); 
			$display("spi read addr=%h ,rdata=%h",spi_header[7:0],spi_rdata[31:0]);
   			//#((fsck_cyc))	send_stop;
   			end
   		end
	#((fsck_cyc)*((spi_w+1)*8+18))	send_stop;		
   join
end
endtask

task spi_rd_lsb;

input [1:0] spi_w;
input [12:0] spi_header;
output [31:0] spi_rdata;
reg [7:0] header;
reg [31:0] spi_rdata;

integer cnt;

begin
spi_rdata=0;
cnt =spi_w+3;
header ={1'b1,spi_w[1:0],spi_header[12:8]};
 fork
   #((fsck_cyc))	send_start;
   #((fsck_cyc)*2)	GEN_SCK(cnt);
  	GEN_MOSI_B(spi_header[7:0]);
   #((fsck_cyc)*9)	 GEN_MOSI_B(header);
   #((fsck_cyc)*18) begin
   	if (spi_w==0) begin
			RECV_lDATA(spi_rdata[7:0]); 
			$display("spi read addr=%h ,rdata=%h",spi_header[7:0],spi_rdata[31:0]);
			//#((fsck_cyc))	send_stop;
			end
   	if (spi_w==1) begin
			RECV_lDATA(spi_rdata[7:0]); 
			RECV_lDATA(spi_rdata[15:8]); 
			$display("spi read addr=%h ,rdata=%h",spi_header[7:0],spi_rdata[31:0]);
   			//#((fsck_cyc))	send_stop;
   			end
   	if (spi_w==2) begin
			RECV_lDATA(spi_rdata[7:0]); 
			RECV_lDATA(spi_rdata[15:8]); 	
			RECV_lDATA(spi_rdata[23:16]); 
			$display("spi read addr=%h ,rdata=%h",spi_header[7:0],spi_rdata[31:0]);
			//#((fsck_cyc))	send_stop;
   			end
   	if (spi_w==3) begin
			RECV_lDATA(spi_rdata[7:0]); 
			RECV_lDATA(spi_rdata[15:8]); 	
			RECV_lDATA(spi_rdata[23:16]);
			RECV_lDATA(spi_rdata[31:24]); 
			$display("spi read addr=%h ,rdata=%h",spi_header[7:0],spi_rdata[31:0]);
   			//#((fsck_cyc))	send_stop;
   			end
   		end
	#((fsck_cyc)*((spi_w+1)*8+18))	send_stop;		
   join
end
endtask



task spi_rd_msb_NB;
input [12:0] spi_header;
input integer j,k;
output [7:0] spi_rdata;
reg [7:0] header;
reg [7:0] spi_rdata;

integer cnt;

begin
spi_rdata=0;
cnt =j+2;
header ={1'b1,2'b11,spi_header[12:8]};
 fork
   #((fsck_cyc))	send_start;
   #((fsck_cyc)*2)	GEN_SCK(cnt);
  	GEN_MOSI(header);
   #((fsck_cyc)*9)	GEN_MOSI(spi_header[7:0]); 
   #((fsck_cyc)*18) begin
   			for (k=0;k<j;k=k+1) begin
			RECV_mDATA(spi_rdata); 
			$display("spi read addr=%h , multiByte=%h, rdata=%h",spi_header[7:0]-k,k,spi_rdata[7:0]);
			end
   		end
	#((fsck_cyc)*(j*8+18))	send_stop;		
   join
end
endtask


task spi_rd_lsb_NB;

input [12:0] spi_header;
input integer j,k;
output [7:0] spi_rdata;
reg [7:0] header;
reg [7:0] spi_rdata;

integer cnt;

begin
spi_rdata=0;
cnt =j+2;
header ={1'b1,2'b11,spi_header[12:8]};
 fork
   #((fsck_cyc))	send_start;
   #((fsck_cyc)*2)	GEN_SCK(cnt);
  	GEN_MOSI_B(spi_header[7:0]);
   #((fsck_cyc)*9)	 GEN_MOSI_B(header);
   #((fsck_cyc)*18) begin
   			for (k=0;k<j;k=k+1) begin
			RECV_lDATA(spi_rdata); 
			$display("spi read addr=%h , multiByte=%h, rdata=%h",spi_header[7:0]+k,k,spi_rdata[7:0]);
			end
   		end
	#((fsck_cyc)*(j*8+18))	send_stop;		
   join
end
endtask


endmodule
