
module MI2523_TOP (
output  sdo_pad,
output  int2_pad,
output  int_pad,
input  csb_pad,		
input  scl_pad,
inout  sdio_pad
 );



//////////////////////////////////////
wire  CK250K; 			//250~400KHz
wire  LOSC_OUT;		//32KHz
wire  OSC_OUT;			//1~1.6MHz
wire  qnb0; 			//250~400KHz RSTN_ADC=0 will stop
		//
wire  [9:0]  ADCOUT_LSB;	//see. adder
wire  [5:0]  ADCOUT_MSB;	//


wire  CV_DONE; 
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
wire  ANAEN;
wire  ENXCH;
wire  ENYCH;
wire  ENZCH;
wire  HOSC_ENB;
wire  EN_CVC;
wire  PDVCOMBUF;
wire  RSTN_ADC;
wire  OFFSET_PNSWAP;		//0x83<5>;0x84<5>;0x85<5>(xyz channel)
wire  OFFSET_TRIMX2;		//{not(0x8c<2:1>);1'b1}(xyz channel)
wire  OP1CFB;			//0x8c<2:0>(xyz channel)
wire  OP3CFB;			//
wire  ADC_GAIN;			//
wire  SEL_MGND;			//0x8f<2>
wire  SWXYN;			//0x8f<5> 
wire  TEMPC_PNSWAP;		//0x89<>;0x8a<>;0x8b<>(xyz channel)
wire  LDOAENLARG;		
//iopad
		
wire  csb_di; 
wire  csb_enph;			//0x8c<7>
wire  int2_aoe;
wire  int2_do;
wire  int2_en_pushpull;
wire  int_aoe;
wire  int_do;
wire  int_en_pushpull;
wire  scl_di;
wire  scl_enph;			//0x8f<1>
wire  sdio_di;
wire  sdio_do;
wire  sdio_doe;
wire  sdio_en_pushpull;
wire  sdo_di;
wire  sdo_do;
wire  sdo_doe;			
wire  sdo_en_pushpull;
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
wire  int2_ana;
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

/////////////////////////////////////



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
	.TP_SEL		(TP_SEL		),	// test mode
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
	//clock
	.CK250K		(CK250K		), 	//250~400KHz
	.LOSC_OUT	(LOSC_OUT	),	//32KHz
	.OSC_OUT	(OSC_OUT	),	//1~1.6MHz
	.qnb0		(qnb0		), 	//250~400KHz RSTN_ADC=0 will stop
	//iopad
	.csb_di		(csb_di		), 
	.csb_enph	(csb_enph	),	//0x8c<7>
	.int2_aoe	(int2_aoe	),
	.int2_do	(int2_do	),
    	.int2_en_pushpull(int2_en_pushpull),
	.int_aoe	(int_aoe	),
	.int_do		(int_do		),
	.int_en_pushpull(int_en_pushpull),
	.scl_di		(scl_di		),
	.scl_enph	(scl_enph	),	//0x8f<1>
	.sdio_di	(sdio_di	),
     	.sdio_do	(sdio_do	),
	.sdio_doe	(sdio_doe	),
	.sdio_en_pushpull(sdio_en_pushpull),
	.sdo_di		(sdo_di		),
	.sdo_do		(sdo_do		),
	.sdo_doe	(sdo_doe	),			
     	.sdo_en_pushpull(sdo_en_pushpull),
     	.bypass_deglitch(bypass_deglitch), 
	.avdd_fuse	(avdd_fuse	),
	.fuse_wen	(fuse_wen	),	//fuse write = 1 else =0
	.DVDD(DIG_POR),
	.DVSS(1'b0)
    );


//ANA_TOP

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



endmodule

