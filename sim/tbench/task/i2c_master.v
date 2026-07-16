
module i2c_master( /*AUTOARG*/ 
//inouts
    scl, 
    sda); 
 inout scl,sda; 
//'include "csr.h"
//'include "reg_deF.inc

`define DACCRADDR  8'h08
`define DACCRWRL    8'h02
`define DACCRRDL    8'hO5fe
parameter DEBUG   = 1;
parameter DEBUG1  = 0;
parameter ENABLE  = 1;

//`define I2C_MASTER_FS_M0DE 
`define I2C_MASTER_STD_M0DE 
`ifdef I2C_MASTER_HS_M0DE

parameter SCL_PERIOD = 294;  
parameter TLOW        160 ; 
parameter THIGH       60 ;  
parameter TSU_STA =   160;  
parameter THD_STA =   160;  
parameter TSU_DAT_SLA = 10; 
parameter THD_DAT_SLA  = 0; 
parameter TSU_DAT_MAS = 10; 
parameter THD_DAT_MAS = 0;  
parameter TSU_STO     160;  
parameter TBUF        1300; //not deFined in hs mode
`endif                      

`ifdef I2C_MASTER_FS_M0DE
parameter SCL_PERIOD  = 2500;	//data From standard mode
parameter TLOW        1300 ; //data From Fast mode
parameter THIGH       600 ;  //data From Fast mode
parameter TSU_STA =   600;   
parameter THD_STA s   600;   
parameter TSU_DAT_SLA = 100  
parameter THD_DAT_SLA = 0;   
parameter TSU_DAT_MAS = 100  
parameter THD_DAT_MAS = 0;   
parameter TSU_STO     600;   
parameter TBUF        1300;  
`endif                        

`ifdef I2C_MASTER_STD_M0DE
parameter  SCL_PERIOD = 10000;  //modiFied by Snow ang, Thu 24 May 2018 
parameter  TLOW = 4700;//data From standard mode
parameter  THIGH = 4000; //data From standard mode
parameter  TSU_STA = 4700;
parameter  THD_STA = 4000;
parameter  TSU_DAT_SLA = 250;  //data From standard mode SDA setup time From slave and For checking by master
parameter  THD_DAT_SLA = 0;  //data From standard mode. SDA hold time From slave and For checking by master 
// parameter THD_DAT_SLA = 100; //data From standard mode. SDA hold time From slave and For checking by master
parameter TSU_DAT_MAS = 250;  //data From standard mode.SDA setup time From master.
parameter THD_DAT_MAS = 0;//data From standard mode.SDA hold time From master. slave assume time = 0
// parameter THD_DAT_MAS = 100;     //data From standard mode.SDA hold time From master. slave assume time = 0
parameter TSU_STO = 4000;  //data From standard mode
parameter TBUF       = 4700;//data From standard mode. Free time between STOP and START
`endif

parameter SLAVE_ID = 7'h40;
parameter SDA_INVALID_STATE = 1'b0; //change this to both 1'b0 and 1'b1 to test the slave response.

parameter ADDR_ROW_MAX = 5'd19; //maximum width of sub-sub address, this may diFFer in different designs.

reg     [6:0]  slave_id;            
reg            addr_lsb;         
reg            dir;                   
reg            write_complete;        
reg            read_complete;         
reg            debug;                 
reg            debug1;                
reg            enable;                
reg            scl_out;               
reg            sda_out;               
reg            sda_eb;                
reg            read_bit;              
reg            write_bit_b;           
reg            snd_bit_st;            
reg            snd_byt_st;            
reg            rcv_ack_st;            
reg            snd_sta_st;            
reg            snd_stp_st;            
reg            snd_rsta_st;           
reg            rcv_bit_st;            
reg            rcv_byt_st;            
reg     [7:0]  wr_data[0:65535];      
reg     [15:0] wr_data_16[0:65535];   
reg     [7:0]  mask[0:255];           
reg     [15:0] mask_16[0:255];        
reg     [7:0]  mb_wr_data[0:255][0:31];
reg     [7:0]  rd_data[0:65535];     
reg     [7:0]  mb_rd_data[0:255][0:31];
reg     [23:0] DacRamWr[8'hF0:0];     
reg     [23:0] DacRamRd[8'hF0:0];     
reg            data_pagesel;          
event          write_done;            
event          read_done;             
event          i2c_read_error;        
event          my_time_event_wr;      
event          my_time_event_rd;      
integer        scl_period;            
integer        thd_sta;               
integer        tsu_sto;               
integer        tsu_sta;               
integer        thd_dat;               
integer        tlow;                  
integer        thigh;                 
integer        tbuf;                  

initial begin 
debug      = DEBUG;           
debug1     = DEBUG1;          
enable     = ENABLE;          
scl_period = SCL_PERIOD;      
thd_sta    = THD_STA;         
tsu_sto    = TSU_STO;         
tsu_sta    = TSU_STA;         
thd_dat    = THD_DAT_MAS;     
tlow           = TLOW;       
thigh          = THIGH;      
tbuf           = TBUF;       
slave_id       = SLAVE_ID;   
addr_lsb       = 1'b0;       
write_complete = 1'b1;       
read_complete  = 1'b1;       
scl_out        = 1'b1;       
sda_out        = 1'b1;       
sda_eb         = 1'b1;       
read_bit       = 1'b1;       
write_bit_b    = 1'b0;       
snd_bit_st     = 1'b0;   
snd_byt_st     = 1'b0;   
rcv_ack_st     = 1'b0;   
snd_sta_st     = 1'b0;   
snd_stp_st     = 1'b0;   
snd_rsta_st    = 1'b0;   
rcv_bit_st     = 1'b0;   
rcv_byt_st     = 1'b0;                
                                                                                                          
data_pagesel  = 8'h0;                                                                                             
end    //initial begin                                                                                        
                                                                                                          
bufif0 (sda,1'b0,sda_eb); 
bufif1(sda_in,sda,sda_eb); //get sda in                                         
                                                                                                          
assign scl=scl_out ? 1'bz:1'b0; //if 1 drive z, if 0 drive O                                              
                                                                                                          
//----------------------------------------------                                                          
always @(write_done)                                                                                      
  begin 
  write_complete = 1'b0;                                                                            
   #1 write_complete = 1'b1; 
   end                                                                           
                                                                                                          
always @(read_done)                                                                                    
 begin 
	read_complete =1'b0;                                                                                      
                                                                                                          
 	#1 read_complete =1'b1; 
 end                                                                                      
                                                                                                          
//-----------------i2c_master   -----------------------                                                                                             
                                                                                                          
//wr_reg_t::                                                                                              
// -reg_address[7:0],data[7:0],numb_bytes                                                                 
//                                                                                                        
//    task sends in DevID then the 2 bytes that are passed in                                             
//    as adress+data pairs. IT numb_bytes is >1, test must                                                
//    supply data for byte2 and later by monitoring                                                       
//    wr_reg_t.NumbBytes                                                                                  
//                                                                                                        
//    so, calling this task with numb_bytes=l  will send 3 bytes                                          
//    ({DevID,write_bit_bJ, RegAddr[7:0], and  Data[7:0]. Every                                           
//    extra byte will can just be sent on the  bus; the DUT will                                          
//    autoincrement the address. The wr_reg_r  user                                                       
// will been to supply new bytes oT data, likely through                                                  
// monitoring when byte_count changes                                                                     
//                                                                                                        
// and to use it to write EQ RAM will take at least 9 bytes 
// (DevID,EQRAddr, EQRLoAddr, EQRLoData,      

// EQRMidAddr,EQRMidData,EQRHiAddr,EQRHiData) Tor single
//    EQRAM write and every extra ram location will add an extra
//    6bytes(sets oT Lo,Mid,Hi Addr+Data Pairs Tor EQRam locations)
//---------------------------------------------------------------------
task send_TM_pattern;         //send TM Pattern 16bit

  reg [15:0]         wr_data_tmp;

  parameter TM_PATTERN = 16'b0101_0101_1010_1010;
  begin
    if(enable)
      begin 
      //if(debug) 
      	wr_data_tmp=TM_PATTERN;
	$display("%t: DEBUG: Send TM pattern: %b",$time,wr_data_tmp); 
	send_sta_bit_t;
	send_8_bit_data_t(wr_data_tmp[15:8]); 
	send_8_bit_data_t(wr_data_tmp[7:0]);
	send_sto_bit_t;



      end
     //if(enable) 
     ->write_done;
   end
endtask
task send_SM_pattern;         //send TM Pattern 16bit

  reg [15:0]         wr_data_tmp;

// parameter SM_PATTERN = 16*bl010_1010_0101_0101; 
parameter SM_PATTERN = 8'b1010_1010; 
begin
    if(enable)
      begin 
      //if(debug) 
	wr_data_tmp=SM_PATTERN;
	send_sta_bit_t;
//            send_8_bit_data_t(wr_data_tmp[15:8]);
	send_8_bit_data_t(wr_data_tmp[7:0]); 
	send_sto_bit_t;
      end
     //iT(enable) 
     ->write_done; 
    end 
endtask

task SMbus_ara;
 // input [7:0]   address;        
 //output [7:0]   returned_data;  //from where the task is called: only the last byte
 reg [7:0]        returned_data;  
 reg              gotten_ack;     

  begin//code
    $display("%t: DEBUG: Send SM bus alert reponse addr cmd ", $time);
    send_sta_bit_t;
    send_8_bit_data_t({7'h0c,read_bit});
    recv_ack_t(gotten_ack);
    recv_8_bit_data_t(returned_data); 
    send_ack_t;
    $display("%t: DEBUG: Slave addr is %h.",$time,returned_data);
    recv_8_bit_data_t(returned_data); 
    send_ack_t;
    recv_8_bit_data_t(returned_data); 
    send_nack_t; 
    send_sto_bit_t;
  end
endtask

task bcast_reset;
  reg  gotten_ack;
  begin
	$display("%t: DEBUG: general call :bc reset ", $time); 
	send_sta_bit_t;
	send_8_bit_data_t(8'h00);
	recv_ack_t(gotten_ack);
	send_8_bit_data_t(8'h06);
	recv_ack_t(gotten_ack);
	send_sto_bit_t;
  end
endtask 

task wr_reg_t_pre;//wr_reg_t(RegAddr[7:0],Dat[7:0],NumbBytes) ;

input   [7:0]   address;      
input   integer numb_bytes;   
reg             gotten_ack;   
reg             running;      
reg     [7:0]   write_address;
reg     [7:0]   write_data;   
integer         byte_count;   
integer         i;         
  begin                         
	if(enable)
  	begin 
  	  if(debug ||(numb_bytes > 1))                                                                       
  	  $display( "%t: DEBUG: Writing %0d Bytes Starting From Reg %h :: %m", $time,numb_bytes,address);     
  	  running=1'b1; 
  	  byte_count=1; 
  	  i={data_pagesel,address};

        	if(debug)
		$display("%t: DEBUG: Writing SlaveID D2....... ::  %m",$time);
		send_sta_bit_t;
		send_8_bit_data_t({7'h6B, write_bit_b}); 
		recv_ack_t(gotten_ack);
		write_address=address;
		send_8_bit_data_t(write_address);
		recv_ack_t(gotten_ack);
		while(running && (byte_count <= numb_bytes))
                begin
                  	write_data=wr_data[write_address];
                  	$display("%t: DEBUG: Writing Register %h, Data=%h",$time,write_address,write_data); 
			send_8_bit_data_t(write_data);
		 	 write_address = write_address +1;
        		i=i+1;
      			byte_count=byte_count+1; //increment(i? need be) before ack to set data 
      			recv_ack_t(gotten_ack);
		end
		 //while
		 send_sto_bit_t; 
		 running=1'b0;
	end
	 //if(enable) 
	 ->write_done;
   end 
endtask //wr_reg_t(RegAddr[7:0],Dat[7:O],NumbBytes);

task wr_reg_t_pre_mby;
  input [7:0]   address;   
  input [39:0]  write_data;
  input integer numb_bytes;

reg gotten_ack;
integer byte_count;

begin
         $display("%t: DEBUG: bJriting Register %h",$time,address); 
         send_sta_bit_t;
	send_8_bit_data_t({slave_id, write_bit_b}); 
	recv_ack_t(gotten_ack);
	send_8_bit_data_t(address); 
	recv_ack_t(gotten_ack);
	byte_count = 0;
		while((byte_count < numb_bytes))
                begin
                  $display("%t: DEBUG: Writing Register %h, byte_nume %0d,Data=%h",$time,address,byte_count,write_data[byte_count*8+:8]);
                  send_8_bit_data_t(write_data[byte_count*8+:8]);
                  byte_count=byte_count+1; //increment(if need be) bePore ack to set data
                  recv_ack_t(gotten_ack);
                end
            send_sto_bit_t;
     ->write_done;
end

endtask

task wr_reg_t_pre_16b;         //task for i2c reg with 16bit data transfer

input   [7:0]   address;       
input   integer numb_bytes;    
reg             gotten_ack;    
reg             running;       
reg     [7:0]   write_address;
reg     [15:0]  write_data;    
integer         byte_count;    
integer         i;             
begin                          
	if(enable)
	   begin
		if(debug || (numb_bytes > 1))
         	$display("%t: DEBUG: Writing %Od Bytes Starting From Reg %h ", $time,numb_bytes,address); running=1'b1;
        	byte_count=1;
        	i={data_pagesel,address};
       // if(debug)
       // $display("%t: DEBUG: Writing SlaveID D2........ :: %m",$time);
            send_sta_bit_t;
            send_8_bit_data_t({slave_id, write_bit_b});
            recv_ack_t(gotten_ack);

            write_address=address;

            send_8_bit_data_t(write_address);
            recv_ack_t(gotten_ack);

            while(running && (byte_count <= numb_bytes))
                 begin
                   write_data=wr_data_16[write_address];
                   $display("%t: DEBUG: Writing Register %h, Data=%h",$time,write_address,write_data); 
                   send_8_bit_data_t(write_data[15:8]);
                   recv_ack_t(gotten_ack);
                   send_8_bit_data_t(write_data[7:0]);
                   write_address = write_address +1;
//                   i=i+1;
                   byte_count=byte_count+1; //increment(iF need be) beFore ack to set data recv_ack_t(gotten_ack);
                 end
//               while
            send_sto_bit_t; 
            running=1'b0; 
          end
     //if(enable) 
     ->write_done; 
    end
endtask                     //wr_reg_t(RegAddr[7:0],Dat[7:0],NumbBytes);


task wr_reg_t_pre_16b_hs;         //task For iZc reg with 16bit data transFer

input   [7:0]   address;     
input   integer numb_bytes;  
reg             gotten_ack;  
reg             running;     
reg     [7:0]   write_address;
reg     [15:0]  write_data;  
integer         byte_count;  
integer         i;           
begin                        
	if(enable)
      	begin
        if(debug ||(numb_bytes > 1))
         $display("%t: DEBUG: Writing %0d Bytes Starting From Reg %h ", $time,numb_bytes,address); 
         running=1'b1; 
         byte_count=1;
        i={data_pagesel,address};
       // if(debug)
       // $display("%t: DEBUG: Writing SlaveID D2........ :: %m",$time);
            send_sta_bit_t;
            send_8_bit_data_t({slave_id, write_bit_b});
            recv_ack_t(gotten_ack);

            write_address=address;

            send_8_bit_data_t(write_address);
            recv_ack_t(gotten_ack);

            while(running && (byte_count <= numb_bytes))
                begin
                   write_data=wr_data_16[write_address];
                   $display("%t: DEBUG: Writing Register %h, Data=%h",$time,write_address,write_data);
                   send_8_bit_data_t(write_data[15:8]);
                   recv_ack_t(gotten_ack);
                   send_8_bit_data_t(write_data[7:0]);

                   write_address = write_address +1;

//                   i=i+1;
                   byte_count=byte_count+1; //increment(iF need be) beFore ack to set data
                   recv_ack_t(gotten_ack);
                end
//               while
            send_fk_sto_bit_t;
            running=1'b0;
      end
     //if(enable)
     ->write_done;
   end
endtask
task wr_reg_t_pre_16b_FS2HS;         //task For i2c reg with 16bit data transFer

input [7:0]   address;     
input integer numb_bytes;  
reg           gotten_ack;  
reg           running;     
reg   [7:0]   write_address;
reg [15:0] write_data;

integer  byte_count;     
integer  i;              
begin
	if(enable)
	begin
	if(debug || (numb_bytes > 1))
	$display("%t: DEBUG: Writing %0d Bytes Starting From Reg %h",$time,numb_bytes,address);
	running=1'b1;
	byte_count=1;
	i={data_pagesel,address};

       // if(debug)
       // $display("%t: DEBUC^ Writing SlaveID D2........ :: %m",$time);

            send_sta_bit_t;
            send_8_bit_data_t(8'h08);
            recv_ack_t(gotten_ack);
         $display("%t: DEBUG: I2C Switch from FS to HS", $time);
            send_rsta_bit_t;
            send_8_bit_data_t({slave_id, write_bit_b});
            recv_ack_t(gotten_ack);
            write_address=address;

            send_8_bit_data_t(write_address);
            recv_ack_t(gotten_ack);

            while(running && (byte_count <= numb_bytes))
            begin
            	write_data=wr_data_16[write_address];
            	$display("%t: DEBUG: Writing Register %h, Data=%h",$time,write_address,write_data);
            	send_8_bit_data_t(write_data[15:8]);
            	recv_ack_t(gotten_ack);
            	send_8_bit_data_t(write_data[7:0]);

                write_address = write_address +1;

//                  i=i+1;
                   byte_count=byte_count+1; //increment(iF need be) before ack to set data
                   recv_ack_t(gotten_ack);
                end
//               while
            send_fk_sto_bit_t;
            running=1'b0;
      end
     //if(enable)
     ->write_done;
   end
endtask                     //wr_reg_t(RegAddr[7:0],Dat[7:0],NumbBytes);
task wr_reg_t_pre_16;         //wr_reg_t(RegAddr[7:0],Dat[7:0],NumbBytes);

input [7:0]   address;      
input integer numb_bytes;   
reg           gotten_ack;   
reg           running;      
reg   [7:0]   write_address;
reg   [7:0]   write_data;   

integer byte_count;
integer  i;  

  begin
    if(enable)
      begin
        if(debug || (numb_bytes > 1))
         $display("%t: DEBUG: Writing %Od Bytes Starting From Reg %h :: %m", $time,numb_bytes,address<<1);
	running=1'b1;
	byte_count=1;
	i={data_pagesel,address};

        //if(debug)
        // $display("%t: DEBUG: Writing SlaveID D2....... :: %m",$time);
            send_sta_bit_t;
            send_8_bit_data_t({slave_id, write_bit_b});
            recv_ack_t(gotten_ack);

            write_address=address;

            send_8_bit_data_t(write_address);
            recv_ack_t(gotten_ack);

            write_address=write_address<<1; //add For 16_bits addr wr_data

            while(running && (byte_count <= numb_bytes))
                 begin
                   write_data=wr_data[write_address];
                   $display("%t: DEBUG: Writing Register %h, Data=%h",$time,write_address,write_data);
                   send_8_bit_data_t(write_data);

                   write_address = write_address +1;

//                   i=i+1;
                   byte_count=byte_count+1; //increment(iF need be) beFore ack to set data
                 recv_ack_t(gotten_ack);
                 end
//               while
            send_sto_bit_t;
            running=1'b0;
      end
     //if(enable)
     ->write_done;
   end
endtask                     //wr_reg_t(RegAddr[7:0],Dat[7:0],NumbBytes);

//-----------------------------------------------------
//mbyte_wr_reg_t::
// -reg_address[7:0],data[7:0],numb_bytes
//
//    task sends in DevID then the 2 bytes that are passed in
//    as adress+data pairs. If numb_bytes is >i, test must
// supply data For byte2 and later by monitoring
// wr_reg_t.NumbBytes
//
//    so, calling this task with numb_bytes=l  will send 3 bytes
//    ({DevID,write_bit_b}, RegAddr[7:0], and  Data[7:0]. Every
//    extra byte will can just be sent on the  bus; the DUT will
// autoincrement the address. The mbyte_wr_reg_r user
// will been to supply new bytes oF data, likely through
// monitoring when byte_count changes
//
// and to use it to write EQ RAM will take at least 9 bytes
// (DevID,EQRAddr, EQRLoAddr, EQRLoData,

// and to use it to write EQ RAM will take at least 9 bytes
//    (DevID,E(^Addr, EQRLoAddr, EQRLoData,
//    EQRMidAddr,EQRMidData,EQRHiAddr,EQRHiData) ^or single
//    EQRAM write and every extra ram location will add an extra
//    6bytes(sets oF Lo,Mid,Hi Addr+Data Pairs for EQRam locations)
//---------------------------------------------------------------------
task mbyte_wr_reg_t_pre;        //mbyte_wr_reg_t(RegAddr[7:0],Dat[7:0],NumbBytes);

input   [7:0]   addr_line;    
input   integer numb_bytes;   
reg             gotten_ack;   
reg             running;      
reg     [7:0]   write_address;
reg     [7:0]   write_data;   
integer         byte_count;   
integer         addr_row;     
begin                         

if(enable)

      begin
        if (debug || (numb_bytes > 1))
         $display("%t: DEBUG: Writing %0d Bytes Starting From Reg %h :: %m", $time,numb_bytes,addr_line);
        running=1'b1;
        byte_count=1;
        addr_row=0;

        if(debug)
         $display("%t: DEBUG: Writing SlaveID D2....... :: %m",$time);
        send_sta_bit_t;
        send_8_bit_data_t({slave_id, write_bit_b});
        recv_ack_t(gotten_ack);

        write_address=addr_line;

        send_8_bit_data_t(write_address);
        recv_ack_t(gotten_ack);

        while(running && (byte_count <= numb_bytes))
            begin
               write_data=mb_wr_data[addr_line][addr_row];
               $display("%t: DEBUG: Writing Register %h, Data=%h",$time,addr_line,write_data);
              send_8_bit_data_t(write_data);
              if(addr_row==ADDR_ROW_MAX)         //If current byte is completed, write to the next byte
                begin
                     addr_row=8'h0;
                     addr_line=addr_line+8'h1;
                end
              else
                addr_row=addr_row+8'h1;
               byte_count=byte_count+1; //increment(iF need be) beFore ack to set data
              recv_ack_t(gotten_ack);
            end
//           while
        send_sto_bit_t;
        running=1'b0;
     end
     //if(enable)
     ->write_done;
    end
endtask  

//---------------------------------------------
//send_8_data_t
//----------------------------
task send_8_bit_data_t;
  input    [7:0]    data;
  integer i;
  begin
    snd_byt_st=1'b1;
    if(debug1)
	$display("%t: INFO: Sending Byte: %2h. ::%m",$time,data);
    	for(i=7;i>=0;i=i-1)
    		begin
    		send_1_bit_data_t(data[i]);
    		end
    	 snd_byt_st=1'b0;
  end      
endtask

//------------------
//send_sta_bit_t: send start bit and lower scl
//--------------------------------------
task send_sta_bit_t;
  begin
    snd_sta_st=1'b1;
    sda_eb=1'b1;        //**Andrew-ensure both SDSA and SCL are high For the setup time
    scl_out=1'b1;
    if(debug1)
    $display("%t: INFO: Sending start bit: ::%m",$time);
               sda_eb=1'b0;
//    tt(20) sda_eb=1'bO;
               scl_out=1'b0;
//    tt(20) scl_out=1'b0;
        //make sure sda does not change For the hold time
    snd_sta_st=1'b0;
  end
endtask

//----------------------------
//send_l_b i t_data_t
//Takes care oF tsu_data thd_data and keeps scl high
//------------------------------------------

//**Andrew - Task starts assuming "a time oF THD_DAT_MAS lapssed ater Falling edge oF SCL"

task send_1_bit_data_t;
  input data;
  begin
    snd_bit_st=1'b1;
    if(debug1)

      $display("%t: INFO: Sending Bit: %0b. :: %m",$time,data);
    sda_eb=SDA_INVALID_STATE; //**Andrew Drive the data line to"invalid state" outside valid
    #(SCL_PERIOD-THIGH - THD_DAT_MAS-TSU_DAT_MAS);     //**Andrew keep high period min, extend
    if(data===1'b0)
    sda_eb=1'b0;
    else
    sda_eb=1'b1;
    #(TSU_DAT_MAS)	scl_out=1'b1;
    #(THIGH)		scl_out=1'b0;
    #(THD_DAT_MAS);
    sda_eb=SDA_INVALID_STATE; //**Andrew Drive the  data line to"invalid state" outside valid
    snd_bit_st=1'b0;
   end
endtask


//---------------------------------
//send l_bit_data_t_wrong
//---------------------------------
task send_l_bit_data_t_wrong;
  input data;
  begin
    snd_bit_st=1'b1;        //**Andrew - Task starts assuming "a time oF THD_DAT_MAS lapssed ater falling edge oF SCL"
    if(debug1)
      $display("%t: INFO: Sending Bit: %0b. :: %m",$time,data);
    sda_eb=SDA_INVALID_STATE; //**Andrew Drive the data line to''invalid state" outside valid window
    #(SCL_PERIOD-THIGH - THD_DAT_MAS-TSU_DAT_MAS); //**Andrew keep high period min, extend low period
    if(data==1'b0)
    sda_eb=1'b0;
    else
    sda_eb=1'b1;
     #(TSU_DAT_MAS) scl_out=1'b1;
     #(THIGH)	    scl_out=1'b1;
     #(THD_DAT_MAS);
    sda_eb=SDA_INVALID_STATE; //**Andrew Drive the data line to "invalid state"outside valid window
    snd_bit_st=1'b0;
   end
endtask


//----------------------------------
//send_sto_bit_t
//-----------------------
task send_sto_bit_t;
  begin
    snd_stp_st=1'b1;
    sda_eb=1'b0;
    scl_out=1'b0;
    #(TLOW)     scl_out=1'b1; //ensure scl has been low long enough after sending a bit or receiving ack
    #(TSU_STO)  sda_eb=1'b1;
// #20
    #(TBUF-THD_STA);
    snd_stp_st=1'b0;
   end
endtask

task send_fk_sto_bit_t;
  begin
    snd_stp_st=1'b1;
    sda_eb=1'b1;
    scl_out=1'b0;
    #(TLOW)     scl_out=1'b1; //ensure scl has been low long enough aTter sending a bit or receiving ack
    #(TSU_STO)   ;//sda_eb=1'b1-
// #20
    #(TBUF-THD_STA) ;
    snd_stp_st=1'b0;
   end
endtask
//-----------------------------
//send_rsta_bit_t
//-----------------------------
task send_rsta_bit_t;
  begin
    snd_rsta_st=1'b1;
    sda_eb=1'b1;          //**andrew-sda goes hi here,scl stays low
    scl_out=1'b0;
    #(TLOW)     scl_out=1'b1;
    #(TSU_STA)  sda_eb=1'b0;
    #(THD_STA)  scl_out=1'b0;
    #(THD_DAT_MAS) sda_eb=1'b1;
    snd_rsta_st=1'b0;
   end
endtask

//-----------------------------
//send_ack_t
//--------------------------
task send_ack_t;
  begin
    send_1_bit_data_t(1'b0);
end
endtask

//-----------------------------
//send_nack_t
//-----------------------------
task send_nack_t;
  begin
send_1_bit_data_t(1'b1);
//    send_1_bit_data_t_wrong(1'b1);
  end
endtask

//---------------------
//send_scl_pulse_t
//----------------------------------
task send_scl_pulse_t;         //not used
  begin
    scl_out=1'b1;
    #(tlow) scl_out=1'b0;
    #(thigh) ;
  end
endtask


//undrive the data line (floats to 1)

//--------------------------
//set_slave_id
// set slave ID. The slave id is 7 bits concatenated with the w_b bit
//--------------------------
task set_slave_id;
  input [6:0] SlaveId;
  begin
    slave_id= SlaveId[6:0];
  end
endtask                //set_slave_id

//read_register_multiple_t:
//read_register_multiplw_t(addr[7:0],numb_bytes, returned_data[7:0])         -=HHess
//****GOTTEN DATA are stored in "rd_data array" at locations startiong from address
//-send start
//-send DevID with write bit
//-send RegAddr
//-send restart
//-send DevID with read bit
//-get data(byte)---<---<------<-
//-increment byte count
//-set returned_data=gotten data
//-if end, send nack, otherwise, send ack -->
//_send stop
//------------------------------------------
//-------------------------
task rd_reg_t_pre;  //rd_reg_t(addr[7:0],numb_bytes, returned_data[7:0])
  input [7:0] address;
input integer numb_bytes;           
input integer check_expected;       
output [7:0]  returned_data;    //From where the task is called: only the last byte    
reg    [7:0]  returned_data;        
reg    [7:0]  data_byte;            
reg           gotten_ack;           
reg           running;              
integer       byte_count;           
reg    [7:0]  curr_addr;            
reg    [15:0] curr_page_addr;       

begin//code
  if(enable)
    begin
  if(debug || (numb_bytes >1))
    $display("%t: DEBUG: Reading %0d Bytes Starting From Reg %h.", $time, numb_bytes, address);
       running=1'b1;
  byte_count=1'b1;
  curr_addr=address;


  send_sta_bit_t;
  send_8_bit_data_t({slave_id,write_bit_b});
  recv_ack_t(gotten_ack);
  send_8_bit_data_t(address); //RegAddr
  recv_ack_t(gotten_ack);

  send_rsta_bit_t;

  send_8_bit_data_t({slave_id,read_bit});
  recv_ack_t(gotten_ack);

  while(running && (byte_count<=numb_bytes))
    begin
      curr_page_addr={data_pagesel,curr_addr};
      recv_8_bit_data_t(data_byte);
      rd_data[curr_addr]=data_byte; //store return in array
      returned_data=data_byte;
      if(check_expected==1)
                      if(returned_data!=(wr_data[curr_page_addr]&mask[curr_page_addr]))
                          begin
                          $display("%t: ERROR: Reading Register %h, Data=%h, Expected=%h.",$time,curr_addr,returned_data,wr_data[curr_page_addr]&mask[curr_page_addr]);
                          -> i2c_read_error;
                          end
                      else
                          $display("%t: DEBUG: Reading Register %h, Data=%h, Expected=%h.",$time,curr_addr,returned_data,wr_data[curr_page_addr]&mask[curr_page_addr]);
       else
                      $display("%t: DEBUG: Reading Register %h, Data=%h.",$time,curr_addr,returned_data);

      curr_addr = curr_addr +1;
      byte_count=byte_count+1;

      if(byte_count<=numb_bytes)
        send_ack_t;
      else
    send_nack_t;
    end
    send_sto_bit_t;
      -> read_done;
      running=1'b0;
      end

//if(enable)
  end //code
endtask //rd_reg_t_pre

task rd_reg_t_pre_mby;//rd_reg_t(addr[7:0],numb_bytes, returned_data[7:0])

input [7:0]     address;      
input integer   numb_bytes1;  
input integer   numb_bytes2;  
input integer   numb_bytes3;  
//output [7:0]  returned_dat;  //from where the task is called: only the last byte
reg   [7:0]     returned_data;
reg   [7:0]     data_byte;    
reg             gotten_ack;   
reg             running;      
integer         byte_count;   
reg   [7:0]     curr_addr;    
reg   [15:0]    curr_page_addr;

  begin//code
      $display("%t: DEBUG: Reading Starting From Reg Xh.", $time, address);
    byte_count=1'b1;
    curr_addr=address;

    send_sta_bit_t;
    send_8_bit_data_t({slave_id,write_bit_b});
    recv_ack_t(gotten_ack);
    send_8_bit_data_t(address); //RegAddr
    recv_ack_t(gotten_ack);

    send_rsta_bit_t;
    send_8_bit_data_t({slave_id,read_bit});
    recv_ack_t(gotten_ack);
    while((byte_count<=numb_bytes1))
      begin
        recv_8_bit_data_t(data_byte);
     // rd_data[curr_addr]=data_byte; //store return in array
        returned_data=data_byte;
           $display("%t: DEBUG: Reading Register %h, byte num:%h byte value:%h.",$time,curr_addr,byte_count,returned_data);
        byte_count=byte_count+1;

        if(byte_count<=numb_bytes1)
          send_ack_t;
        else if(numb_bytes2=='d0)
          send_nack_t;
                else
          send_ack_t;
      end
        curr_addr = curr_addr +1;
                byte_count = 1;
    while( (byte_count<=numb_bytes2))
      begin
        recv_8_bit_data_t(data_byte);
     // rd_data[curr_addr]=data_byte; //store return in array
        returned_data=data_byte;
           $display("%t: DEBUG: Reading Register %h, byte num:%h byte value:%h.",$time,curr_addr,byte_count,returned_data);
        byte_count=byte_count+1;
        if(byte_count<=numb_bytes2)
          send_ack_t;
        else if(numb_bytes3=='d0)
          send_nack_t;
                else
          send_ack_t;
      end
        curr_addr = curr_addr +1;
                byte_count = 1;
    while((byte_count<=numb_bytes3))
      begin
        recv_8_bit_data_t(data_byte);
     // rd_data[curr_addr]=data_byte; //store return in array
        returned_data=data_byte;
           $display("%t: DEBUG: Reading Register %h, byte num:%h byte value:%h.",$time,curr_addr,byte_count,returned_data);
        byte_count=byte_count+1;
        if(byte_count<=numb_bytes3)
          send_ack_t;
        else
          send_nack_t;
      end

      send_sto_bit_t;
  end //code
endtask //rd_reg_t_pre


task rd_reg_dir_t_pre_mby;//rd_reg_t(addr[7:0],numb_bytes, returned_data[7:0])
  input [7:0] address;
  input integer   numb_bytes1;
  //output [7:0] returned_data;//from where the task is called: only the last byte
  reg    [7:0] returned_data;
  reg    [7:0]   data_byte;
  reg   gotten_ack;
  reg running;
  integer   byte_count;
  reg    [7:0]  curr_addr;
  reg    [15:0] curr_page_addr;

  begin//code
      $display("%t: DEBUG: Reading Starting From Reg %h.", $time, address); 
      byte_count=1'b1;
    curr_addr=address;
    send_sta_bit_t;
    //send_8_bit_data_t({slave_id,write_bit_b});
    //recv_ack_t(gotten_ack);
    //send_8_bit_data_t(address); //RegAddr
    //recv_ack_t(gotten_ack);

    //send_rsta_bit_t;

    send_8_bit_data_t({slave_id,read_bit});
    recv_ack_t(gotten_ack);
    while( (byte_count<=numb_bytes1))
      begin
        recv_8_bit_data_t(data_byte);
     // rd_data[curr_addr]=data_byte; //store return in array
        returned_data=data_byte;
           $display("%t: DEBUG: Reading Register Xh, byte num:%h byte value:%h.",$time,curr_addr,byte_count,returned_data);
        byte_count=byte_count+1;

        if(byte_count<=numb_bytes1)
          send_ack_t;
        else //if(numb_bytes2=='d0) 
        send_nack_t;
                //else
        // send_ack_t; 
        end

	send_sto_bit_t;

	end      //code                     
endtask  //rd_reg_t_pre    
         
task rd_reg_t_pre_16b;          //task For i2c reg 16bit read
input    [7:0]      address;       
input    integer    numb_bytes;    
input    integer    check_expected;
output   [15:0]     returned_data; //From where the task is called: only the last byte
reg      [15:0]     returned_data; 
reg      [15:0]     data_byte;     
reg                 gotten_ack;    
reg                 running;       
integer             byte_count;    
reg      [7:0]      curr_addr;     
reg      [15:0]     curr_page_addr;

  begin//code
    if(enable)
      begin
    if(debug ||(numb_bytes >1))
      $display("%t: DEBUG: Reading %0d Bytes Starting From Reg %h.", $time, numb_bytes, address); 
      running=1'b1;
    byte_count=1'b1;
    curr_addr=address;


    send_sta_bit_t; 
    send_8_bit_data_t({slave_id,write_bit_b}); 
    recv_ack_t(gotten_ack);
    send_8_bit_data_t(address); //RegAddr 
    recv_ack_t(gotten_ack);
    send_rsta_bit_t;
    send_8_bit_data_t({slave_id,read_bit}); 
    recv_ack_t(gotten_ack);

    while(running && (byte_count<=numb_bytes))
      begin
        curr_page_addr={data_pagesel,curr_addr}; 
        recv_8_bit_data_t(data_byte[15:8]);
        //rd_data[curr_addr]=data_byte; //store return in array 
        returned_data[15:8]=data_byte[15:8];
        send_ack_t;
        recv_8_bit_data_t(data_byte[7:0]); 
        returned_data[7:0]=data_byte[7:0];
        if(check_expected==1)
                         if(returned_data!=(wr_data_16[curr_page_addr]&mask_16[curr_page_addr])) 
                         begin 
                         $display("%t: ERROR: Reading Register %h, Data=%h, Expected=%h.",$time,curr_addr,returned_data,wr_data_16[curr_page_addr]&mask_16[curr_page_addr]);
                         -> i2c_read_error;
                         end 
                         else
                             $display("%t: DEBUG: Reading Register%h, Data=%h, Expected=%h.",$time,curr_addr,returned_data,wr_data_16[curr_page_addr]&mask_16[curr_page_addr]);
                     else
                         $display("%t: DEBUG: Reading Register %h, Data=%h.",$time,curr_addr,returned_data);

        curr_addr = curr_addr +1; 
        byte_count=byte_count+1;

        if(byte_count<=numb_bytes) 
        send_ack_t;
        else 
        send_nack_t; 
        end
      send_sto_bit_t;
      -> read_done; 
      running=1'b0; 
      end

//if(enable)

  end      //code                     
endtask  //rd_reg_t_pre 
            
task rd_reg_t_pre_16b_hs;       //task for i2c reg 16bit read
input    [7:0]      address;       
input    integer    numb_bytes;    
input    integer    check_expected;
output   [15:0]     returned_data; //from where the task is called: only the last byte
reg      [15:0]     returned_data; 
reg      [15:0]     data_byte;     
reg                 gotten_ack;    
reg                 running;       
integer             byte_count;    
reg      [7:0]      curr_addr;     
reg      [15:0]     curr_page_addr;

  begin//code
    if(enable)
      begin
    if(debug || (numb_bytes >1))
      $display("%t: DEBUG: Reading %0d Bytes Starting From Reg %h.", $time, numb_bytes, address); 
      running=1'b1;
    byte_count=1'b1;
    curr_addr=address;


    send_sta_bit_t;
    send_8_bit_data_t({slave_id,write_bit_b});
    recv_ack_t(gotten_ack);
    send_8_bit_data_t(address); //RegAddr
    recv_ack_t(gotten_ack);

    send_rsta_bit_t;

    send_8_bit_data_t({slave_id,read_bit});
    recv_ack_t(gotten_ack);

    while(running && (byte_count<=numb_bytes))
      begin
        curr_page_addr={data_pagesel,curr_addr}; 
        recv_8_bit_data_t(data_byte[15:8]);
        //rd_data[curr_addr]=data_byte; //store return in array 
        returned_data[15:8]=data_byte[15:8];
        send_ack_t;
        recv_8_bit_data_t(data_byte[7:0]);
        returned_data[7:0]=data_byte[7:0];
        if(check_expected==1)                                 
                         if(returned_data!=(wr_data_16[curr_page_addr]&mask_16[curr_page_addr]))
        		begin
        		$display("%t: ERROR: Reading Register %h, Data=%h, Expected=%h.",$time,curr_addr,returned_data,wr_data_16[curr_page_addr]&mask_16[curr_page_addr]);
        		-> i2c_read_error;
        		end
    		else
       	 	$display("%t: DEBUG: Reading Register %h, Data=%h , Expected=%h. ",$time,curr_addr,returned_data,wr_data_16[curr_page_addr]&mask_16[curr_page_addr]);
       	 	else
    		$display("%t: DEBUG: Reading Register %h, Data=%h.",$time,curr_addr,returned_data);
	curr_addr = curr_addr +1;
	byte_count=byte_count+1;
	if(byte_count<=numb_bytes) 
	send_ack_t;
	else 
	send_nack_t; 
	end 
	send_fk_sto_bit_t; 
	-> read_done; 
	running=1'b0; 
	end
//if(enable)
  end //code
endtask //rd_reg_t_pre

task rd_reg_t_pre_16;//rd_reg_t(addr[7:0],numb_bytes,returned_data[7:0])

input  [7:0]   address;       
input  integer numb_bytes;    
input  integer check_expected;
output [7:0]   returned_data; //from where the task is called: only the last byte
reg    [7:0]   returned_data; 
reg    [7:0]   data_byte;     
reg            gotten_ack;    
reg            running;       
integer        byte_count;    
reg    [7:0]   curr_addr;     
reg    [15:0]  curr_page_addr;

  begin//code
    if(enable)
      begin
    if(debug || (numb_bytes >1))
      $display("%t: DEBUG: Reading %0d Bytes Starting From Reg Xh.", $time, numb_bytes, address<<1); 
      	running=1'b1;
    	byte_count=1'b1;
    	curr_addr=address<<1;
	send_sta_bit_t;
    	send_8_bit_data_t({slave_id,write_bit_b}); 
    	recv_ack_t(gotten_ack);
    	send_8_bit_data_t(address); //RegAddr 
    	recv_ack_t(gotten_ack);

    	send_rsta_bit_t;

    	send_8_bit_data_t({slave_id,read_bit}); 
    	recv_ack_t(gotten_ack);

    while(running && (byte_count<=numb_bytes)) 
    	begin
        curr_page_addr={data_pagesel,curr_addr};
        recv_8_bit_data_t(data_byte);
        rd_data[curr_addr]=data_byte; //store return in array 
        returned_data=data_byte;
        if (check_expected==1)
          begin
             if(returned_data!=wr_data[curr_addr])
          	begin
            		$display("%t: ERROR: Reading Register %h, Data=%h, Expected=%h.",$time,curr_addr,returned_data,wr_data[curr_addr]); 
            		->i2c_read_error;
           	end
          	else
            	begin
           		$display("%t: DEBUG: Reading Register %h, Data=%h, Expected=%h.",$time,curr_addr,returned_data,wr_data[curr_addr]); 
           	end
          end
        else
          $display("%t: DEBUG: Reading Register %h, Data=%h.",$time,curr_addr,returned_data);
        curr_addr = curr_addr +1;
        byte_count=byte_count+1;
        if(byte_count<=numb_bytes) 
        send_ack_t; 
        else
          send_nack_t;
      	end
      send_fk_sto_bit_t;
      -> read_done; 
      running=1'b0; 
      end
//if(enable)
  end //code
endtask //rd_reg_t_pre_16 
//-------------------------------
//read_register_multiple_t: 
//read_register_multiplw_t(addr[7:0],numb_bytes , returned_data[7:0]) 
//****GOTTEN DATA are stored in "rd_data array" at locations startiong from "addess".
//-send start                 
//-send DevID with write bit  
//-send RegAddr               
//-send restart               
//-send DevID with read bit   
//-get data(byte)---<---<-----<--------------<
//-increment byte count                      |
//-set returned_data=gotten data             ^ if byte_count not exausted,keep reading
//-if end, send nack, otherwise, send ack¡X>l
//_send stop 
//----------------------
task mbyte_rd_reg_t_pre;//mbyte_rd_reg_t(addr[7:0],numb_bytes, returned_data[7:0])

input  [7:0]   addr_line;     
input  integer numb_bytes;    
input  integer check_expected;
output [7:0]   returned_data; //from where the task is called: only the last byte
reg    [7:0]   returned_data; 
reg    [7:0]   data_byte;     
reg            gotten_ack;    
reg            running;       
integer        byte_count;    
integer        addr_row;      
reg     [7:0] curr_addr;
reg     [15:0] curr_page_addr;

  begin//code
    if(enable)
      begin
        if(debug || (numb_bytes >1))
          $display("%t: DEBUG: Reading %Od Bytes Starting From Reg %h.", $time, numb_bytes, addr_line);
        running=1'b1;
        byte_count=1'b1;

        send_sta_bit_t;
        send_8_bit_data_t({slave_id,write_bit_b});
        recv_ack_t(gotten_ack);
        send_8_bit_data_t(addr_line); //RegAddr
        recv_ack_t(gotten_ack);

        send_rsta_bit_t;

        send_8_bit_data_t({slave_id,read_bit});
        recv_ack_t(gotten_ack);
        addr_row=0;
        while(running && (byte_count<=numb_bytes))
          begin
            recv_8_bit_data_t(data_byte);
            mb_rd_data[addr_line][addr_row]=data_byte; //store return in array
            returned_data=data_byte;
            curr_addr=addr_line;
            if(check_expected==1)
              begin 
              		if(returned_data!=mb_wr_data[addr_line][addr_row]) begin
                        $display("%t: ERROR: Reading Register %h, Data=%h, Expected=%h.",$time,curr_addr,returned_data,mb_wr_data[addr_line][addr_row]); 
                        -> i2c_read_error;
                    	end
                 	else
                    	begin
                        $display("%t: DEBUG: Reading Register %h, Data=%h, Expected=%h.",$time,curr_addr,returned_data,mb_wr_data[addr_line][addr_row]); 
                        end
              	end
            else
              $display("%t: DEBUG: Reading Register %h, Data=%h.",$time,curr_addr,returned_data); 
              if(addr_row==ADDR_ROW_MAX) //IF current address reading is completed, read the next address 
              	begin
                addr_line=addr_line+1;
                addr_row=8'h0;
            	end
            else
            addr_row=addr_row+8'h1;

            byte_count=byte_count+1;
            if(byte_count<=numb_bytes)
              send_ack_t;
            else
              send_nack_t;
          end
        send_sto_bit_t;
        -> read_done;
        running=1'b0;
      end
//if(enable)

end //code
endtask //rd_reg_t_pre




//recv_8_bit_data_t

task recv_8_bit_data_t;
  output [7:0]      data_byte;
  integer          i;
  reg [7:0]         data_byte;

  begin
    rcv_byt_st=1'b1;
// if(debugl)
// $display("%t INFO: Getting Byte.... : %0h.      :: %m", $time, data_byte)
    for(i=7;i>=0;i=i-1)
      begin 
      recv_1_bit_data_t(data_byte[i]);
      end
    if(debug1)
        $display("%t INFO: Got Byte.... : %2h.   :: %m", $time, data_byte); //move here to give correct value
    rcv_byt_st=1'b0; 
    end
endtask //recv_8_bit_data_t

//---------------------
//recv_l_bit_data_t 
//---------------------
task recv_1_bit_data_t; 
output bit_data;
reg       bit_data;
begin
  	-> my_time_event_rd;//check SDA For hold time
	rcv_bit_st = 1'b1;
	sda_eb = 1'b1; //undrive SDA, SDA_IN=SDA
	#(SCL_PERIOD-THIGH-THD_DAT_SLA-TSU_DAT_SLA);//**Andrew¡X>my_time_event_rd;
	bit_data= sda_in; //check SDA For setup time
	-> my_time_event_rd;//check SDA For hold time

   	#(TSU_DAT_SLA) scl_out= 1'b1; 
   	#(THIGH) scl_out = 1'b0;
    //#(THD_DAT_SLA-l)
    #(THD_DAT_SLA)
    -> my_time_event_rd;             //check SDA For hold time
    if(sda_in!==bit_data)
      begin
        $display("%t: ERROR Read Data Unstable, they're ** %b %b ** :: %m",$time,bit_data,sda_in); 
        bit_data= 1'bx;
      end
    rcv_bit_st = 1'b0;
    #1;                         //added to show diFFerent betweem bits
  end
endtask

//-----------------------------------------------------
//recv_ack_t
//--------------------------------------------------------
task recv_ack_t;
  output         recv_ack;
  reg recv_ack;
  reg   ack;

  begin
    rcv_ack_st=1'b1;
    sda_eb=1'b1;                  //undrive SDSA, SDA_IN=SDA
    #(SCL_PERIOD-THIGH-THD_DAT_MAS-TSU_DAT_SLA); //**Andrew-this always follows send bit
    ->my_time_event_rd;
    ack=sda_in;                     //check SDA for setup time
   #(TSU_DAT_SLA) scl_out= 1'b1; 
   #(THIGH) scl_out = 1'b0; 
   #(THD_DAT_SLA)  ->my_time_event_rd;        //check SDA for hold time
    if((ack!==0) ||(sda_in!==0))
      $display("%t:ERROR Not ACK or ACK Unstable, they*re ** %b %b ** :: %m",$time,ack,sda_in); 
      else 
      recv_ack=0; 
      rcv_ack_st=1'b0;
  end
endtask //rcv_ack_t


//--------------------------------
//tasks contain page access
//-----------------------------
task wr_reg_t;                    // wr_reg_t(RegAddr[15:0],NumbBytes);
  input    [15:0]       address;
  input    integer      numb_bytes;

  begin
    //write PAGE_SEL
    data_pagesel     = 8'h0;
    wr_data[0]       = address[15:8];
    wr_reg_t_pre(8'h0,1);

    data_pagesel     = address[15:8];
    wr_reg_t_pre(address[7:0],numb_bytes);
  end
endtask


task rd_reg_t;	//rd_reg_t(addr[15:0],numb_bytes, returned_data[7:0])
  input   [15:0]     address;                                                                       
  input    integer   numb_bytes;                                                                    
  input    integer   check_expected;                                                                
  output[7:0]        returned_data;             //from where the task is called: onoly the last byte

  begin
    //write PAGE_SEL
    data_pagesel     = 8'h0;
    wr_data[0]       = address[15:8];
    wr_reg_t_pre(8'h0,1);

    data_pagesel     = address[15:8];
    rd_reg_t_pre(address[7:0],numb_bytes,check_expected,returned_data[7:0]); 
    end
endtask

endmodule

//i2c_master




