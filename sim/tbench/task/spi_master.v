
`define SCK_TOSC 100

module spi_master(//outputs
                   CSB,
                   SCK, 
                   MOSI, 
                   //inputs 
                   MISO);


//outputs 
output CSB; 
output SCK; 
output MOSI;

//inputs    
input MISO;
reg   CSB; 
reg   SCK; 
reg   MOSI;

wire MISO;

//initial                     
//begin                      
//      INTLl                
//      #5us ;               
//      read(8'h00);         
//      #5us ;               
//      write(8'h01,16'hA5A5)
//      #5us ;              
//      read(8'h01);         
//      #5us ;               
//      read(8'h09);         
//      #5us ;              
//      write(8'h12,16'hC000)
//      #5us ;              
//      send_tm_pat;         
//      #5us ;              
//      write(8'h13,16'h0404)
//end                        

//INTL
task INTL;
begin
  CSB = 1'b1;
  SCK = 1'b0;
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
      #(`SCK_TOSC/2);
    end
  end
endtask

//GENERATE SDI/MOSI 
task GEN_SDI;
  input [7:0] sdi_data;

  reg [7:0] sdi_gen_buf; 
  integer i;

  begin
    sdi_gen_buf = sdi_data;
    for(i=7; i>=0; i=i-1)
    begin
      @(posedge SCK) 
      MOSI = sdi_gen_buf[i];
    end
  end
endtask

//RECV DATA
task RECV_DATA;
  output   [39:0]   rd_data;
  reg      [39:0]   rd_data;

  integer i;

  begin
    for(i=39; i>=0; i=i-1)
      @(negedge SCK) rd_data = {rd_data[38:0],MISO}; 
  end 
endtask

//send start
task send_start;
begin
  CSB = 1'b0;
end 
endtask

//send stop
task send_stop;
begin
  CSB = 1'b1;
  SCK = 1'b0;
   #500;
end 
endtask

//read
task read;
input [7:0] addr; 

reg [7:0] addr_buf;

begin
  addr_buf = addr;
  //INTL;
  case(addr) //CONFIG 16bits 
  8'h00: fork
  	#((`SCK_TOSC)/2+(`SCK_TOSC)) 	send_start;
	#((`SCK_TOSC)*2)  		GEN_SCK(3);
	#((`SCK_TOSC)/2+(`SCK_TOSC)) 	GEN_SDI({addr_buf[5:0],2'b01});
	#((`SCK_TOSC)*30)  		send_stop;
        join

//ADC_CONFIG 16bits 8*h01: fork
  8'h01: fork
  	#((`SCK_TOSC)/2+(`SCK_TOSC)) 	send_start;
	#((`SCK_TOSC)*2)  		GEN_SCK(3);
	#((`SCK_TOSC)/2+(`SCK_TOSC)) 	GEN_SDI({addr_buf[5:0],2'b01});
	#((`SCK_TOSC)*30)  		send_stop;
        join

//SHUNT_CAL 16bits 8'hO2: fork
  8'h02: fork
  	#((`SCK_TOSC)/2+(`SCK_TOSC)) 	send_start;
	#((`SCK_TOSC)*2)  		GEN_SCK(3);
	#((`SCK_TOSC)/2+(`SCK_TOSC)) 	GEN_SDI({addr_buf[5:0],2'b01});
	#((`SCK_TOSC)*30)  		send_stop;
        join

//SHUNT_TEMPCO 16bits 8'hO3: fork
  8'h03: fork
  	#((`SCK_TOSC)/2+(`SCK_TOSC)) 	send_start;
	#((`SCK_TOSC)*2)  		GEN_SCK(3);
	#((`SCK_TOSC)/2+(`SCK_TOSC)) 	GEN_SDI({addr_buf[5:0],2'b01});
	#((`SCK_TOSC)*30)  		send_stop;
        join


//VSHUNT 24bits 8'h04: fork
  8'h04: fork
  	#((`SCK_TOSC)/2+(`SCK_TOSC)) 	send_start;
	#((`SCK_TOSC)*2)  		GEN_SCK(4);
	#((`SCK_TOSC)/2+(`SCK_TOSC)) 	GEN_SDI({addr_buf[5:0],2'b01});
	#((`SCK_TOSC)*40)  		send_stop;
        join
	default : ;
   endcase
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
 #((`SCK_TOSC)*2)		GEN_SCK(3);
 #((`SCK_TOSC)/2+(`SCK_TOSC))	send_start;
 #((`SCK_TOSC)/2+(`SCK_TOSC))	GEN_SDI({addr_buf[5:0],2'b00});
 #((`SCK_TOSC)/2+(`SCK_TOSC)*9)	GEN_SDI(data_wr_buf[15:8]); 
 #((`SCK_TOSC)/2+(`SCK_TOSC)*17)GEN_SDI(data_wr_buf[7:0]); 
 #((`SCK_TOSC)*30)		send_stop;
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
   #((`SCK_TOSC))		send_start;
   #((`SCK_TOSC)*2)		GEN_SCK(2);
   #((`SCK_TOSC)/2+(`SCK_TOSC))	GEN_TM_PAT;
   #((`SCK_TOSC)*20)		send_stop;
  join
endtask

endmodule
