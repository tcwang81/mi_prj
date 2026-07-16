//`define FPGA

module MI2523_TOP (
inout  int_pad,
`ifdef FPGA
input int1_i,
output w_SPI_Clk,
input w_SPI_MISO,
output w_SPI_MOSI,
output w_SPI_CS_n,
input clk_i,
input rstn,
output losc_o,
output hosc_o,
output clk400k_o,
output ADC_EN_o,
output clk_sys_o,
output ANAEN_o,
output if_busy_o,
`endif
input  scl_pad,
inout  sdio_pad
 );


//////////////////////////////////////
//wire  CK250K; 			//250~400KHz
//wire  LOSC_OUT;		//32KHz
//wire  OSC_OUT;			//1~1.6MHz
wire  [9:0]  ADCOUT_LSB;	//see. adder
wire  [5:0]  ADCOUT_MSB;	//
wire  CV_DONE; 
wire  ANAEN;
wire  ENXCH;
wire  ENYCH;
wire  ENZCH;
wire  HOSC_ENB;
wire  RSTN_ADC;

wire  DIG_POR;			// power on reset
wire  [2:0]  IBT;  		//0x8d<5:3>
wire  [3:0]  TR_LOSC;		//0x8e<7:4>
wire  [2:0]  VRT;		//0x8d<2:0>
wire  [1:0]  TP_SEL;		// test mode
wire  [2:0]  OP3INGAIN;		//0xd1<2:0>;0xd1<5:3>;{0x8c<3>;0xd1<7:6>}
wire  [4:0]  OFFSET_CTRL;	//0x83<4:0>;0x84<4:0>;0x85<4:0>(xyz channel)
wire  [1:0]  STG1CMFB;		//0x8c<5:4>(xyz channel)
wire  [1:0]  TEMPH_DAC;		//0x89<>;0x8a<>;0x8b<>(xyz channel)
wire  [3:0]  TEMPL_DAC;		//0x89<>;0x8a<>;0x8b<>(xyz channel)
wire  [3:0]  TR_HOSC;		//0x8e<3:0>
wire  ADC_EN;

wire  EN_CVC;
wire  PDVCOMBUF;

wire  OFFSET_PNSWAP;		//0x83<5>;0x84<5>;0x85<5>(xyz channel)
wire  OFFSET_TRIMX2;		//{not(0x8c<2:1>);1'b1}(xyz channel)
wire  OP1CFB;			//0x8c<2:0>(xyz channel)
wire  OP3CFB;			//
wire  ADC_GAIN;			//
wire  SEL_MGND;			//0x8f<2>
wire  SWXYN;			//0x8f<5> 
wire  TEMPC_PNSWAP;		//0x89<>;0x8a<>;0x8b<>(xyz channel)
wire  LDOAENLARG;
wire  [7:0] TM_MODE;
wire sync_sel;
wire sync_mode;
//iopad
wire  int_aoe;
wire  int_do;
wire  int_en_pushpull;

wire  scl_enph;			//0x8f<1>
wire  sdio_do;
wire  sdio_doe;
wire  sdio_en_pushpull;
wire  bypass_deglitch; 
wire  fuse_wen;			//fuse write = 1 else =0
//analog 
wire  avdd_fuse; 
wire  VCOM;
wire  VDDA;
wire  VDD3V;
wire  VDDIO;
wire  GND;
wire  int_ana;
//
//MEMS
wire  MGND; 
wire  TP;
wire  VMZ;
wire  VCAX;
wire  VCAY;
wire  VCAZ;
wire  VCBX;
wire  VCBY;
wire  VCBZ;

wire  sdio_di;
wire  scl_di;
wire  CK250K; 			//250~400KHz
wire  LOSC_OUT;		//32KHz
wire  OSC_OUT;			//1~1.6MHz
wire [7:0] from_dig_A;
wire [7:0] to_dig_D;
/////////////////////////////////////
`ifdef FPGA
wire POR_READY;
assign ADC_EN_o=ADC_EN;
assign clk_sys_o=OSC_OUT;
assign ANAEN_o=ANAEN;
assign DIG_POR = rstn & POR_READY;
assign losc_o=LOSC_OUT;
assign hosc_o=OSC_OUT;
assign clk400k_o=CK250K;
wire int_di,int1_di;

assign int_di=sync_mode?int1_di:1'b0;

BDIO_iobuf_bidir_30p iint1
	( 
	.datain(int_do),
	.dataio(int_pad),
	.dataout(int1_di),
	.oe(~sync_mode)) ;


pll ipll(
	clk_i,
	c0,c1);
//c0:75MHz ;c1:1MHz
	
	
	
wire	scl_pad_buf;
reg scl_reg,scl_reg1;
reg sdio_reg,sdio_reg1,sdio_reg2;

assign scl_di = scl_reg1|scl_reg;
assign sdio_di = sdio_reg2;

//always@(posedge c0 or negedge rstn)begin
always@(posedge clk_i or negedge rstn)begin
	if(!rstn)begin
		scl_reg<=1;
		sdio_reg<=1;	
		scl_reg1<=1;
		sdio_reg1<=1;	
		sdio_reg2<=1;
	end else begin
		sdio_reg2<=sdio_reg|sdio_reg1;
		scl_reg1<=scl_reg;
		sdio_reg1<=sdio_reg;	
		scl_reg<=scl_pad;
		sdio_reg<=sdio_pad;
	end
end

`endif
///////////////////////////////////////

// DIG_TOP
dig_top xdig_top(
	//ADC
	.ADCOUT_LSB	(ADCOUT_LSB	),	//see. adder
	.ADCOUT_MSB	(ADCOUT_MSB	),	//

	.CV_DONE	(CV_DONE	), 
	.DIG_POR	(DIG_POR	),	// power on reset
	.IBT		(IBT		),  	//0x8d<5:3>
	.TR_LOSC	(TR_LOSC	),	//0x8e<7:4>
	.VRT		(VRT		),	//0x8d<2:0>
	.OP3INGAIN	(OP3INGAIN	),	//0xd1<2:0>(),0xd1<5:3>(),{0x8c<3>(),0xd1<7:6>}
	.OFFSET_CTRL	(OFFSET_CTRL	),	//0x83<4:0>(),0x84<4:0>(),0x85<4:0>(xyz channel)
	.STG1CMFB	(STG1CMFB	),	//0x8c<5:4>(xyz channel)
	.TEMPH_DAC	(TEMPH_DAC	),	//0x89<>(),0x8a<>(),0x8b<>(xyz channel)
	.TEMPL_DAC	(TEMPL_DAC	),	//0x89<>(),0x8a<>(),0x8b<>(xyz channel)
	.TR_HOSC	(TR_HOSC	),	//0x8e<3:0>
	.ADC_EN		(ADC_EN		),
	.ANAEN		(ANAEN		),
	.ENXCH		(ENXCH		),
	.ENYCH		(ENYCH		),
	.ENZCH		(ENZCH		),
	.HOSC_ENB	(HOSC_ENB	),
	.EN_CVC		(EN_CVC		),
	.PDVCOMBUF	(PDVCOMBUF	),
	.RSTN_ADC	(RSTN_ADC	),
	.OFFSET_PNSWAP	(OFFSET_PNSWAP	),	//0x83<5>(),0x84<5>(),0x85<5>(xyz channel)
	.OFFSET_TRIMX2	(OFFSET_TRIMX2	),	//{not(0x8c<2:1>)(),1'b1}(xyz channel)
     	.OP1CFB		(OP1CFB		),	//0x8c<2:0>(xyz channel)
	.OP3CFB		(OP3CFB		),			//
	.ADC_GAIN	(ADC_GAIN	),			//
	.SEL_MGND	(SEL_MGND	),	//0x8f<2>
	.SWXYN		(SWXYN		),	//0x8f<5> 
    	.TEMPC_PNSWAP	(TEMPC_PNSWAP	),	//0x89<>(),0x8a<>(),0x8b<>(xyz channel)
	.LDOAENLARG	(LDOAENLARG	),
	.TM_MODE	(TM_MODE	),
	//.sync_sel(),
	.sync_mode(sync_mode),
	//clock
	.CK250K		(CK250K		), 	//250~400KHz
	.LOSC_OUT	(LOSC_OUT	),	//32KHz
	.OSC_OUT	(OSC_OUT	),	//1~1.6MHz
	//.qnb0		(qnb0		), 	//250~400KHz RSTN_ADC=0 will stop
	//iopad
	//.csb_di		(csb_di		), 
	//.csb_enph	(	),	//0x8c<7>
	//.int2_aoe	(	),
	//.int2_do	(	),
    	//.int2_en_pushpull(),
	//.int_aoe	(int_aoe	),
	.int_do		(int_do		),
	.int_en_pushpull(int_en_pushpull),
	.sync_sig     (int_di),
	.scl_di		(scl_di		),
	.scl_enph	(scl_enph	),	//0x8f<1>
	.sdio_di	(sdio_di	),
     	.sdio_do	(sdio_do	),
	.sdio_doe	(sdio_doe	),
	.sdio_en_pushpull(sdio_en_pushpull),
	//.sdo_di		(sdo_di		),
	//.sdo_do		(		),
	//.sdo_doe	(	),			
     	//.sdo_en_pushpull(),
     	.bypass_deglitch(bypass_deglitch), 
	//.avdd_fuse	(avdd_fuse	),
	.dvddenb_fuse	(dvddenb_fuse),
	//.dvdd_fuse	(~dvddenb_fuse),
	.from_dig_A(from_dig_A),
	.to_dig_D(to_dig_D),
	.from_dig_AEN(from_dig_AEN),
	.from_dig_RDEN(from_dig_RDEN),
	.from_dig_PGMEN(from_dig_PGMEN),
	.fuse_wen	(fuse_wen	) //	//fuse write = 1 else =0
	//.DVSS(1'b0)
	//add if_busy for test
`ifdef FPGA
	,.clk_i(clk_i)
	,.if_busy_o(if_busy_o)
`endif
	//end
    );

`ifdef FPGA
     assign sdio_pad = (sdio_doe&!sdio_do) ?1'b0:1'bz;
	  wire Is16g;
	  assign Is16g= ~ADC_GAIN & OP3CFB;
afe xafe(
	.rstn_i(rstn), 	//asyn low reset 
	.clk_i(clk_i), 	// 
	.int1_i(int1_i),
	.w_SPI_Clk(w_SPI_Clk),
	.w_SPI_MISO(w_SPI_MISO),
	.w_SPI_MOSI(w_SPI_MOSI),
	.w_SPI_CS_n(w_SPI_CS_n),
	.ANAAEN(ANAEN),
	.HOSC_ENB(HOSC_ENB),
	.ENXCH(ENXCH),
	.ENYCH(ENYCH),
	.ENZCH(ENZCH),
	.RSTN_ADC(RSTN_ADC),
	.fs_i(Is16g),
	.ADCOUT_MSB(ADCOUT_MSB),
	.ADCOUT_LSB(ADCOUT_LSB),
	.CV_DONE(CV_DONE),
	.OSC_OUT(OSC_OUT),
	.CK250K(CK250K),
	.LOSC_OUT(LOSC_OUT),
	.POR_READY(POR_READY)
);     
	
`else
//ANA_TOP
AFE_TOP xAFE_TOP ( 
	.ADCOUT_LSB(ADCOUT_LSB), 
	.ADCOUT_MSB(ADCOUT_MSB), 
	.CK250K(CK250K), 
	.CV_DONE(CV_DONE),
	.DIG_POR(DIG_POR), 
	.LOSC_OUT(LOSC_OUT), 
	.OSC_OUT(OSC_OUT), 
	.avdd_fuse(avdd_fuse), 
	.scl_di(scl_di), 
	.sdio_di(sdio_di), 
	.INT1(INT1), 
	.MEMSGND(MEMSGND), 
	.MEMSGND_2(MEMSGND_2), 
	.MEMSGND_3(MEMSGND_3), 
	.SCL(scl_pad), 
	.SDIO(sdio_pad), 
	.VMZ(VMZ), 
	.ADC_EN(ADC_EN),
	.ADC_GAIN(ADC_GAIN), 
	.ANAEN(ANAEN), 
	.ENXCH(ENXCH), 
	.ENYCH(ENYCH), 
	.ENZCH(ENZCH), 
	.EN_CVC(EN_CVC), 
	.GND(GND), 
	.HOSC_ENB(HOSC_ENB), 
	.IBT(IBT),
	.LDOAENLARG(LDOAENLARG), 
	.OFFSET_CTRL(OFFSET_CTRL), 
	.OFFSET_PNSWAP(OFFSET_PNSWAP), 
	.OFFSET_TRIMX2(OFFSET_TRIMX2), 
	.OP1CFB(OP1CFB),
	.OP3CFB(OP3CFB), 
	.OP3INGAIN(OP3INGAIN), 
	.PDVCOMBUF(PDVCOMBUF), 
	.RSTN_ADC(RSTN_ADC), 
	.SEL_MGND(SEL_MGND), 
	.STG1CMFB(STG1CMFB), 
	.SWXYN(SWXYN),
	.TEMPC_PNSWAP(TEMPC_PNSWAP), 
	.TEMPH_DAC(TEMPH_DAC), 
	.TEMPL_DAC(TEMPL_DAC), 
	.TM(TM_MODE), 
	.TR_HOSC(TR_HOSC), 
	.TR_LOSC(TR_LOSC), 
	.VCAX(VCAX),
	.VCAY(VCAY), 
	.VCAZ(VCAZ), 
	.VCBX(VCBX), 
	.VCBY(VCBY), 
	.VCBZ(VCBZ), 
	.VDD3V(VDD3V), 
	.VDDIO(VDDIO), 
	.VRT(VRT), 
	.bypass_deglitch(bypass_deglitch),
	.fuse_wen(fuse_wen), 
	.from_dig_A(from_dig_A),
	.to_dig_D(to_dig_D),
	.from_dig_AEN(from_dig_AEN),
	.from_dig_RDEN(from_dig_RDEN),
	.from_dig_PGMEN(from_dig_PGMEN),
	.dvddenb_fuse(dvddenb_fuse),
	.int_do(int_do), 
	.int_en_pushpull(int_en_pushpull),
	.scl_enph(scl_enph), 
	.sdio_do(sdio_do), 
	.sdio_doe(sdio_doe),
	.sdio_en_pushpull(sdio_en_pushpull), 
	.sync_sig (int_di),
	.sync_mode(sync_mode)
	);
/*
AFE_TOP xAFE_TOP (
	//clock
	.CK250K		(CK250K		), 	//250~400KHz
	.LOSC_OUT	(LOSC_OUT	),	//32KHz
	.OSC_OUT	(OSC_OUT	),	//1~1.6MHz
	.qnb0		(qnb0		), 	//250~400KHz RSTN_ADC=0 will stop
	//ADC
	.ADCOUT_LSB	(ADCOUT_LSB	),	//see. adder
	.ADCOUT_MSB	(ADCOUT_MSB	),	//

	.CV_DONE	(CV_DONE	), 
	.DIG_POR	(DIG_POR	),	// power on reset
	.IBT		(IBT		),  	//0x8d<5:3>
	.TR_LOSC	(TR_LOSC	),	//0x8e<7:4>
	.VRT		(VRT		),	//0x8d<2:0>
	.TP_SEL		(TP_SEL		),	// test mode
	.OP3INGAIN	(OP3INGAIN	),	//0xd1<2:0>(),0xd1<5:3>(),{0x8c<3>(),0xd1<7:6>}
	.OFFSET_CTRL	(OFFSET_CTRL	),	//0x83<4:0>(),0x84<4:0>(),0x85<4:0>(xyz channel)
	.STG1CMFB	(STG1CMFB	),	//0x8c<5:4>(xyz channel)
	.TEMPH_DAC	(TEMPH_DAC	),	//0x89<>(),0x8a<>(),0x8b<>(xyz channel)
	.TEMPL_DAC	(TEMPL_DAC	),	//0x89<>(),0x8a<>(),0x8b<>(xyz channel)
	.TR_HOSC	(TR_HOSC	),	//0x8e<3:0>
	.ADC_EN		(ADC_EN		),
	.ANAEN		(ANAAEN		),
	.ENXCH		(ENXCH		),
	.ENYCH		(ENYCH		),
	.ENZCH		(ENZCH		),
	.HOSC_ENB	(HOSC_ENB	),
	.EN_CVC		(EN_CVC		),
	.PDVCOMBUF	(PDVCOMBUF	),
	.RSTN_ADC	(RSTN_ADC	),
	.OFFSET_PNSWAP	(OFFSET_PNSWAP	),	//0x83<5>(),0x84<5>(),0x85<5>(xyz channel)
	.OFFSET_TRIMX2	(OFFSET_TRIMX2	),	//{not(0x8c<2:1>)(),1'b1}(xyz channel)
     	.OP1CFB		(OP1CFB		),	//0x8c<2:0>(xyz channel)
	.OP3CFB		(OP3CFB		),			//
	.ADC_GAIN	(ADC_GAIN	),			//
	.SEL_MGND	(SEL_MGND	),	//0x8f<2>
	.SWXYN		(SWXYN		),	//0x8f<5> 
    	.TEMPC_PNSWAP	(TEMPC_PNSWAP	),	//0x89<>(),0x8a<>(),0x8b<>(xyz channel)
	.LDOAENLARG	(LDOAENLARG	),		
	//iopad
	.csb_pad	(csb_pad	),			
	.csb_di		(csb_di		), 
	.csb_enph	(csb_enph	),	//0x8c<7>
	.int2_pad	(int2_pad	), 
	.int2_aoe	(int2_aoe	),
	.int2_do	(int2_do	),
    	.int2_en_pushpull(int2_en_pushpull),
	.int_pad	(int_pad	),
	.int_aoe	(int_aoe	),
	.int_di		(int_di		),
	.int_do		(int_do		),
	.int_en_pushpull(int_en_pushpull),
    	.scl_pad	(scl_pad	),
	.scl_di		(scl_di		),
	.scl_enph	(scl_enph	),	//0x8f<1>
	.sdio_pad	(sdio_pad	),
	.sdio_di	(sdio_di	),
     	.sdio_do	(sdio_do	),
	.sdio_doe	(sdio_doe	),
	.sdio_en_pushpull(sdio_en_pushpull),
	.sdo_pad	(sdo_pad	),
	.sdo_di		(sdo_di		),
	.sdo_do		(sdo_do		),
	.sdo_doe	(sdo_doe	),			
     	.sdo_en_pushpull(sdo_en_pushpull),
     	.bypass_deglitch(bypass_deglitch), 
	.fuse_wen	(fuse_wen	),	//fuse write = 1 else =0	
	.sync_sel(sync_sel),
	.sync_mode(sync_mode),
	//analog 
     	.avdd_fuse	(avdd_fuse	), 
	.VCOM		(VCOM		),
	.VDDA		(VDDA		),
	.VDD3V		(VDD3V		),
	.VDDIO		(VDDIO		),
	.GND		(GND		),
	.int_ana	(int_ana	),
	.int2_ana	(int2_ana	),

	//MEMS
	.MGND		(MGND	), 
	.TP		(TP	),
	.VMZ		(VMZ	),
	.VCAX		(VCAX	),
	.VCAY		(VCAY	),
	.VCAZ		(VCAZ	),
	.VCBX		(VCBX	),
	.VCBY		(VCBY	),
	.VCBZ		(VCBZ	)
		//
		);
*/
`endif

endmodule

