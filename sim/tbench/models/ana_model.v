
`timescale 1ns/100ps
module	HOSC(
	//output
	output reg OSC_OUT,

	//input
	input HOSC_ENB,
	input ANAEN,
	input POR
	);
reg osc_2m,osc_rstn_tmp;

initial begin
	osc_2m=0;
	forever #250 osc_2m= ~osc_2m&POR;
	end

always @(*) begin
	if(!POR)osc_rstn_tmp <=0;
  	else osc_rstn_tmp <=  #33000 ANAEN|~HOSC_ENB;
 end
wire osc_rstn = osc_rstn_tmp &~HOSC_ENB;
always @(posedge osc_2m or negedge osc_rstn)
	if(!osc_rstn) OSC_OUT <=0;
	else OSC_OUT= ~OSC_OUT;

endmodule


module	LOSC ( 
	//output
	output reg LOSC_OUT,
	//input
	input LOSC_ENB,
	input [3:0] TR_LOSC
	);


	initial begin
	LOSC_OUT=0;
	forever #(500/`losc_mhz) LOSC_OUT= ~LOSC_OUT;
	end

endmodule



module	CKGEN( 
	//output
	output CK250K,
	output reg qnb0,
	//input
	input OSC_OUT,
	input RSTN_ADC,
	input POR
	);

     reg qnb1;
     wire rstn = POR;
always @(posedge OSC_OUT or  negedge rstn)
	if(!rstn) qnb1 <=0;
	else qnb1 <= ~qnb1;
     
always @(posedge qnb1 or  negedge rstn)
	if(!rstn) qnb0 <=0;
	else qnb0<= ~qnb0;
         
assign   CK250K=qnb0  ;
    
     
endmodule
     
module  POR_DL ( 
	//output
	output reg DIG_POR, 
	output LOSC_OUT, 
	//input
	input	ANAEN,
	input	HOSC_ENB,
	output reg POR
	);


       always @(posedge LOSC_OUT or negedge POR)
       	if(!POR) DIG_POR<=0;
	else DIG_POR <=POR;

initial begin
	POR=0;
	#2000; POR=1;
	end

endmodule

     
module iopad_65 (
	//output
	output csb_di,
	output scl_di,
	output sdo_di,
	output sdio_di,
	//input
	inout  sdo_pad,
	input  csb_pad,
	input  scl_pad,
	input  sdio_do,
	input  sdo_do,
	input  sdo_doe,
	input  sdio_doe,
	input  csb_enph,
	input  scl_enph,
	//inout
	inout  sdio_pad
	);
	
     //SPI
    wire csb_padx,scl_padx;
//pullup(csb_pad);
//pullup(scl_pad);


     assign sdo_pad = sdo_doe& ~csb_pad? sdo_do :1'bz;
     assign sdo_di=sdo_pad;
     assign csb_di=csb_pad;
     
     //I2C
     assign scl_di=scl_pad;
     

     assign sdio_di = sdio_pad;
     assign sdio_pad = sdio_doe ? sdio_do :1'bz;
     
     
endmodule
     
module MC_A6_ADC( 
	//output
	output reg [9:0] ADCOUT_LSB, 
	output reg [5:0] ADCOUT_MSB, 
	output reg CV_DONE,
	//input
     	input OSC_OUT, 
	input ADC_EN, 
	input RSTN_ADC
	);
     
reg	[7:0] sdm_cnt,sar_cnt,adch_cnt,adcl_cnt;
initial begin
	adch_cnt<=0;
	adcl_cnt<=0;
	end
        always@(posedge OSC_OUT or negedge RSTN_ADC)begin
                if(!RSTN_ADC)  begin
				ADCOUT_MSB<=0;
				sdm_cnt <=0;
				//adch_cnt <=0;
				end
                else if (ADC_EN) begin
		 		if(CV_DONE)  sdm_cnt <=0;
				else if(sdm_cnt=='d38) 
					begin
					CV_DONE <=1;
					ADCOUT_MSB <=adch_cnt;
					adch_cnt<=(adcl_cnt[0])?adch_cnt+2 :adch_cnt;
					end
				else	sdm_cnt <=sdm_cnt+1;
				end

		end

        always@(posedge OSC_OUT or negedge RSTN_ADC)begin
                if(!RSTN_ADC)  begin
				ADCOUT_LSB <= 0;
				sar_cnt <=0;
				CV_DONE <=0;
				//adcl_cnt<=0;
				end
                else if (ADC_EN) begin
				if(CV_DONE)  sar_cnt<=0;
				else if(sar_cnt=='d38) 
					begin
					CV_DONE <=1;
					ADCOUT_LSB <= 20+adcl_cnt;
					adcl_cnt<=adcl_cnt+1;
					end
				else 	sar_cnt <=sar_cnt+1;

				end

		end			 
     
     
endmodule
