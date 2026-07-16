'define SCK_TOSC 100
module spi_master(//oatputs
	CSB,
	SCK,
	MOSI,
	//inputs
	MISO);

//outputs	
output output output	CSB; SCK; MOSI;

//inputs	
input	MISO;
reg	CSB;
reg	SCK;
reg	MOSI;
wire MISO;

//initial	
//begin //	ZNTL;
//	#5us;
//	reed(8 'h00);
//	#5us;
//	write (8 'h01,16 *hA5A5) ;
//	#5us;
//	read(8 'h01);
//	45us;
//	read(8 'hO9);
//	#5us;
//	wri te (8 ' hl 2,16 'hC000) ;
//	45us;
//	send_ tm_pat;
//	#5us;
//	write (8 'hl3,16'h0404);
//end	
//INTL
task INTL;
begin
CSB = l'bl;
SCK = l'b0;
end
endtask

//GENERATE SCK
task GEN SCK:
input T?:0] sclk_bytes;
reg [7:0] sclk_gen_buf;
integer i;

begin
sclk_gen_buf =sclk_bytes;
for(i=0; i<(sclk_gen_buf*16)i=(i+i))
	begin
	SCK = -SCK;
	('SCK_TOSC/2) ;
	end
end
endtask


//GENERATE SDI/MOS1
task GEN SDI:
input [7:0] sdi_data;
reg [7:0] sdi_gen_buf;
integer	i;
 begin
	sdi_gen_buf = sdi_data;
	for(i=7; i>=0; i=i-l)
	begin
	©(posedge SCK)
	MOSI = sdi_gen_buf[i);
 end
end
endtask

//RECV DATA
task RECV DATA:
output	[39:0]	rd_data;
reg	[39:0]	rd_data;
integer i;
 begin
	for(i=39; i>=0; i=i-l)
	@(negedge SCK)
	rd_data = (rd_data[38:0],MISO};
 end
endtask

//send start
task send_start;
begin
	CSB = l'b0;
end
endtask

//send stop
task send_stop;
begin
	CSB = l'bl;
	SCK = l'b0;
	#500;
end
endtask

//read
task read:
input [7:0] addr;
reg [7:0] addr_buf;
begin
	addr_buf = addr;
	//INTL;
	case(addr)
	//CONFIG 16bits
		8'h00,8'h01,8'h02,8'h03,8'h06,8'h0b,8'h0c,8'h0d,8'h0e,8'h0f,\
		8'h10,8'h11,8'h12,8'h13,8'h14,8'h15,8'h016,8'h17,8'h18,8'h019,\
		8'h10a,8'h1b,8'h1c: fork
			#((`SCK_TOSC)/2+('SCK_TOSC) ) send_start;
			#(		('SCK_TOSC)*2 ) GEN_SCK(3);
			#((`SCK_TOSC)/2+('SCK_TOSC) ) GEN_SDI({addr_buf[5:0],2'b01});
			#(		('SCK_TOSC)*30 ) send_stop;
			join
		8'h04,8'h05,8'h07,8'h08,8'h1d,8'h20: fork
			#((`SCK_TOSC)/2+('SCK_TOSC) ) send_start;
			#(		('SCK_TOSC)*2 ) GEN_SCK(4);
			#((`SCK_TOSC)/2+('SCK_TOSC) ) GEN_SDI({addr_buf[5:0],2'b01});
			#(		('SCK_TOSC)*30 ) send_stop;
			join
		8'h09,8'h0a: fork
			#((`SCK_TOSC)/2+('SCK_TOSC) ) send_start;
			#(		('SCK_TOSC)*2 ) GEN_SCK(6);
			#((`SCK_TOSC)/2+('SCK_TOSC) ) GEN_SDI({addr_buf[5:0],2'b01});
			#(		('SCK_TOSC)*30 ) send_stop;
			join
		default: ;
	endscase
end
endtask	
	
//write
task write;
input	[7:0]	addr;
input	[15:0]	data_wr;
reg	[7:0]	addr_buf;
reg	[15:0] data_wr_buf;

begin
addr_buf	=	addr;
data_wr_buf	=	data_wr;
//INTL;	
	fork
	#(('SCK_TOSC*2)			GEN_SCK(3);
	#(('SCK_TOSC /2+('SCK_TOSC)) 	send start;
	#(('SCK_TOSC /2+('SCK_TOSC))	GEN_SDI({addr_buf[5:0],2'b00});
	#(('SCK_TOSC /2+('SCK_TOSC)*9)	GEN_SDI(data_wr_buf[15:8]);
	#(('SCK_TOSC /2+('SCK_TOSC)*17) GEN_SDI(data_wr_buf[7:0]);
	#(('SCK_TOSC*2)			send_stop;
	join
end
endtask

//gen tm_pattern
task GEN_TM_PAT;
reg [15:0] tm_reg;
integer	i;
begin
tm_reg = 16'b0101_0101_1010_1010;
	for(i=15; i>=0; i=i-l)
	 begin
		MOSI = tm_reg[15];
		©(negedge SCK)
		tm_reg = {tm_reg[14:0],l'b0};
	 end
end
endtask

task send tm pat;
fork
	#('SCK_TOSC)	send_start;
	#(('SCK_TOSC)*2) GEN_SCK(2);
	#(('SCK_TOSC)/2+('SCK_TOSC)) GEN_TM_PAT;
	#(('SCK_TOSC)*20) send_stop;
join
endtask
endnodule