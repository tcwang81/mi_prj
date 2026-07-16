// Library - top, Cell - AFE_TOP, View - schematic
// LAST TIME SAVED: Sep  2 20:20:06 2024
// NETLIST TIME: Sep  2 20:22:51 2024

`timescale 1ns/100ps
module adder(dlsb_i, dmsb_i,clk_i, rstn_i, dout_o);
        input [9:0]dlsb_i;
        input clk_i;
        input rstn_i;
        input [5:0]dmsb_i;
        output [14:0]dout_o;
        reg [14:0]temp,temp_n;

        assign dout_o = temp;//unsigned

        always@(posedge clk_i or negedge rstn_i)begin
                if(rstn_i==1'b0)
                        temp = 15'b000000000000000;
                else
                        temp = dlsb_i[9]?{dmsb_i[5:0],dlsb_i[8:0]}:{(dmsb_i-6'b000001),dlsb_i[8:0]};
        end
endmodule 
/*
module AFE_TOP (
                //clock
                output CK250K,                  //250~400KHz
                output LOSC_OUT,                //32KHz
                output OSC_OUT,                 //1~1.6MHz
                output qnb0,                    //250~400KHz RSTN_ADC=0 will stop
                //
                output [9:0]  ADCOUT_LSB,       //see. adder
                output [5:0]  ADCOUT_MSB,       //


                output CV_DONE, 
                output DIG_POR,                 // power on reset
                input [2:0]  IBT,               //0x8d<5:3>
                input [3:0]  TR_LOSC,           //0x8e<7:4>
                input [2:0]  VRT,               //0x8d<2:0>
                input [1:0]  TP_SEL,            // test mode
                input [2:0]  OP3INGAIN,         //0xd1<2:0>,0xd1<5:3>,{0x8c<3>,0xd1<7:6>}
                input [4:0]  OFFSET_CTRL,       //0x83<4:0>,0x84<4:0>,0x85<4:0>(xyz channel)
                input [1:0]  STG1CMFB,          //0x8c<5:4>(xyz channel)
                input [1:0]  TEMPH_DAC,         //0x89<>,0x8a<>,0x8b<>(xyz channel)
                input [3:0]  TEMPL_DAC,         //0x89<>,0x8a<>,0x8b<>(xyz channel)
                input [3:0]  TR_HOSC,           //0x8e<3:0>
                input ADC_EN,
                input ANAEN,
                input ENXCH,
                input ENYCH,
                input ENZCH,
                input HOSC_ENB,
                input EN_CVC,
                input PDVCOMBUF,
                input RSTN_ADC,
                input OFFSET_PNSWAP,            //0x83<5>,0x84<5>,0x85<5>(xyz channel)
                input OFFSET_TRIMX2,            //{not(0x8c<2:1>),1'b1}(xyz channel)
                input OP1CFB,                   //0x8c<2:0>(xyz channel)
                input OP3CFB,                   //
                input ADC_GAIN,                 //
                input SEL_MGND,                 //0x8f<2>
                input SWXYN,                    //0x8f<5> 
                input TEMPC_PNSWAP,             //0x89<>,0x8a<>,0x8b<>(xyz channel)
                input LDOAENLARG,               
                //iopad
                inout csb_pad,                  
                output csb_di, 
                input csb_enph,                 //0x8c<7>
                inout int2_pad, 
                input int2_aoe,
                input int2_do,
                input int2_en_pushpull,
                inout int_pad,
                input int_aoe,
                input int_do,
                input int_en_pushpull,
		output int_di,
                inout scl_pad,
                output scl_di,
                input scl_enph,                 //0x8f<1>
                inout sdio_pad,
                output sdio_di,
                input sdio_do,
                input sdio_doe,
                input sdio_en_pushpull,
                inout sdo_pad,
                output sdo_di,
                input sdo_do,
                input sdo_doe,                  
                input sdo_en_pushpull,
                input bypass_deglitch, 
                input fuse_wen,                 //fuse write = 1 else =0
		input sync_sel,
		input sync_mode,
                //analog 
                output avdd_fuse, 
                output VCOM,
                output VDDA,
                input VDD3V,
                input VDDIO,
                input GND,
                inout int_ana,
                inout int2_ana,
                //
                //MEMS
                inout MGND, 
                inout TP,
                inout VMZ,
                input VCAX,
                input VCAY,
                input VCAZ,
                input VCBX,
                input VCBY,
                input VCBZ
                //
                );

*/


module AFE_TOP ( ADCOUT_LSB, ADCOUT_MSB, CK250K, CV_DONE,
     DIG_POR, LOSC_OUT, OSC_OUT, avdd_fuse, scl_di, sdio_di, sync_sig,
     INT1, MEMSGND, MEMSGND_2, MEMSGND_3, SCL, SDIO, VMZ, ADC_EN,
     ADC_GAIN, ANAEN, ENXCH, ENYCH, ENZCH, EN_CVC, GND, HOSC_ENB, IBT,
     LDOAENLARG, OFFSET_CTRL, OFFSET_PNSWAP, OFFSET_TRIMX2, OP1CFB,
     OP3CFB, OP3INGAIN, PDVCOMBUF, RSTN_ADC, SEL_MGND, STG1CMFB, SWXYN,
     TEMPC_PNSWAP, TEMPH_DAC, TEMPL_DAC, TM, TR_HOSC, TR_LOSC, VCAX,
     VCAY, VCAZ, VCBX, VCBY, VCBZ, VDD3V, VDDIO, VRT, bypass_deglitch,
     fuse_wen, int_do, int_en_pushpull, scl_enph, sdio_do, sdio_doe,
     sdio_en_pushpull, sync_mode );

//to MEMS
inout  MEMSGND, MEMSGND_2, MEMSGND_3, VMZ;
input  VCAX, VCAY, VCAZ, VCBX, VCBY, VCBZ;
    
// to IOPAD
inout  INT1, SCL, SDIO;
input  GND, VDD3V, VDDIO;
 
//to digital
output  CK250K, CV_DONE, DIG_POR, LOSC_OUT, OSC_OUT, avdd_fuse, scl_di,
     sdio_di, sync_sig;
input  ADC_EN, ADC_GAIN, ANAEN, ENXCH, ENYCH, ENZCH, EN_CVC, 
     HOSC_ENB, LDOAENLARG, OFFSET_PNSWAP, OFFSET_TRIMX2, OP1CFB,
     OP3CFB, PDVCOMBUF, RSTN_ADC, SEL_MGND, SWXYN, TEMPC_PNSWAP,
     bypass_deglitch, fuse_wen, int_do, int_en_pushpull, scl_enph,
     sdio_do, sdio_doe, sdio_en_pushpull, sync_mode;

output [5:0]  ADCOUT_MSB;
output [9:0]  ADCOUT_LSB;

input [3:0]  TR_HOSC;
input [3:0]  TEMPL_DAC;
input [2:0]  IBT;
input [2:0]  OP3INGAIN;
input [4:0]  OFFSET_CTRL;
input [3:0]  TR_LOSC;
input [7:0]  TM;
input [1:0]  TEMPH_DAC;
input [1:0]  STG1CMFB;
input [2:0]  VRT;

// Buses in the design

wire  [0:3]  net040;

wire  [1:0]  TPS;
wire	LOSC_ENB;

specify 
    specparam CDS_LIBNAME  = "top";
    specparam CDS_CELLNAME = "AFE_TOP";
    specparam CDS_VIEWNAME = "schematic";
endspecify
/*
rpposab_ckt  R2 ( .MINUS(TP), .PLUS(I11494_TP));
rpposab_ckt  R0 ( .MINUS(I04460_QC), .PLUS(net012));
rpposab_ckt  R1 ( .MINUS(net012), .PLUS(I04460_PIB));
REFERENCE_V1a I30 ( I8806_QA, I8806_QNA, I8806_Q_OE, I8806_OUT0,
     I8806_OUT1, VDDA, VDDC, VDDB, net6, VREF0, VREF1, I8806_OUTB0,
     I8806_OUTA, I01101_PIBRA0, I01101_PIBRA1, I01101_PIBR0,
     I01101_PIBR1, I8806_NIB4, I8806_NIB5, I8806_NIB6, I04463_NIBR,
     GND, IBT[2:0], LDOAENLARG, I01101_YN, PDBG, PDCMP, PDVCOMBUF,
     VDD3V, VRT[2:0]);
n33_ckt  NM7 ( .D(GND), .B(GND), .G(VDDA), .S(GND));
n33_ckt  NM0 ( .D(GND), .B(GND), .G(VDDA), .S(GND));
n33_ckt  NM2 ( .D(GND), .B(GND), .G(VDDC), .S(GND));
n33_ckt  NM1 ( .D(GND), .B(GND), .G(VDDB), .S(GND));
n33_ckt  NM3 ( .D(GND), .B(GND), .G(VCOM), .S(GND));
n33_ckt  NM4 ( .D(GND), .B(GND), .G(VCOM), .S(GND));
n33_ckt  NM5 ( .D(GND), .B(GND), .G(VCOM), .S(GND));
n33_ckt  NM6 ( .D(GND), .B(GND), .G(VCOM), .S(GND));
POR_DL I35 ( DIG_POR, GND, VDDA, LOSC_OUT, POR);
deglitch I38 ( sdio_di, net095, bypass_deglitch, scl_enph, GND, VDDA);
deglitch I37 ( scl_di, net097, bypass_deglitch, scl_enph, GND, VDDA);
LOSC I3 ( LOSC_OUT, GND, I04460_NIB1, I04460_NIB0, VDDA, LOSC_ENB,
     TR_LOSC[3:0]);
MC_A18_SWITCH I20 ( MGND, net1, GND, VCOM, VDDC);
ANA_MUX I14 ( I11494_TP, net027, net028, PN_SWAP, VCOM, VMZ,
     I11494_VREF, TPS[1], TPS[0], ENXCHH, ENYCHH, ENZCHH, GND,
     I04464_Q_OE, MUX_SEL, VCAX, VCAY, VCAZ, VCBX, VCBY, VCBZ, VDDC);
LSFT_ARRAY_2 I23 ( TPS[1:0], GND, VDDA, VDDC, TP_SEL[1:0]);
LSFT I27 ( I04464_QA0, GND, VDDC, VDDA, OFFSET_TRIMX2);
LSFT I25[2:0] ( {ENXCHH, ENYCHH, ENZCHH}, GND, VDDC, VDDA, {ENXCH,
     ENYCH, ENZCH});
LSFT I18 ( net042, GND, VDDB, VDDA, HOSC_ENB);
LSFT I21 ( net1, GND, VDDC, VDDA, SEL_MGND);
LSFT I24 ( MUX_SEL, GND, VDDC, VDDA, SWXYN);
LSFT I40 ( I01101_Q, GND, VDDC, VDDA, ADC_GAIN);
LSFT I26 ( cvc_enable, GND, VDDC, VDDA, EN_CVC);
MC_A17_SWITCH I15 ( I11494_VREF, net6, GND, I01101_YA, I01101_YA,
     VDDC);
LSFT_ARRAY_4 I17 ( net040[0:3], GND, VDDB, VDDA, TR_HOSC[3:0]);
LSFT2 I22 ( I04464_Q_OE, PDBG, GND, VDDC, VDDA, ANAEN);
CKGEN I28 ( I11496_QA0, I11496_QB2, CK250K, qnb0, qnb1, RSTN_ADC,
     OSC_OUT, I8807_Y_CPN, GND, VDDB);
MC_A2_BANDGAP I04460 ( I04460_NIB0, I04460_NIB1, I04460_PIB, I04460_QC,
     VDDA, GND, VDD3V);
HOSC I74 ( OSC_OUT, GND, I8806_NIB5, VDDC, VDDB, net042, POR,
     net040[0:3]);
MC_A6_ADC I8807 ( ADCOUT_LSB[9:0], ADCOUT_MSB[5:0], CV_DONE,
     I8807_Y_CPN, I8807_Y_RN, I8806_NIB4, VCOM, OSC_OUT, I11496_QB2,
     I11496_QA0, I01101_Q, GND, net2, net030, ADC_EN, RSTN_ADC,
     PN_SWAP, VDDB, VDDC);
iopad_65 I36 ( avdd_fuse, csb_di, net097, net095, sdo_di, GND, VDD3V,
     VDDIO, csb_pad, int2_ana, int2_pad, int_ana, int_pad, scl_pad,
     sdio_pad, sdo_pad, VDDA, csb_enph, fuse_wen, int2_aoe, int2_do,
     int2_en_pushpull, int_aoe, int_do, int_en_pushpull, DIG_POR,
     scl_enph, sdio_do, sdio_doe, sdio_en_pushpull, sdo_do, sdo_doe,
     sdo_en_pushpull);
MC_A11_CMP I04463 ( OTD, I04463_NIBR, GND, I8806_QA, I8806_QNA, VDD3V,
     VDDA, I8806_OUTB0, I8806_OUTA);
MC_A8_AMP I8809 ( VCOM, I8806_NIB6, GND, I8806_Q_OE, VDD3V,
     I8806_OUT0);
CVC_TOP I29 ( net030, net2, net0105, I01101_YA, I01101_YN,
     I01101_PIBR0, I01101_PIBR1, I01101_PIBRA0, I01101_PIBRA1, VCOM,
     VREF0, VREF1, I8807_Y_CPN, qnb0, qnb1, cvc_enable, GND, net027,
     net028, OFFSET_CTRL[4:0], OFFSET_PNSWAP, I04464_QA0, OP1CFB,
     OP3CFB, OP3INGAIN[2:0], STG1CMFB[1], STG1CMFB[0], TEMPC_PNSWAP,
     TEMPH_DAC[0], TEMPH_DAC[1], TEMPL_DAC[0], TEMPL_DAC[1],
     TEMPL_DAC[2], TEMPL_DAC[3], VDDA, VDDC);
MC_A1_UVLO I04471 ( POR, GND, VDDA);
*/
wire	POR;
assign sync_sig = sync_mode ?  INT1:1'b0;
assign	avdd_fuse = fuse_wen ? POR:1'b0;
HOSC	xHOSC(
	//output
	.OSC_OUT(OSC_OUT),
	//input
	.HOSC_ENB(HOSC_ENB),
	.ANAEN(ANAEN),
	.POR(POR)
	);
	
LOSC	LOSC ( 
	//output
	.LOSC_OUT(LOSC_OUT),
	//input
	.LOSC_ENB(LOSC_ENB),
	.TR_LOSC(TR_LOSC)
	);


CKGEN	xCKGEN( 
	//output
	.CK250K(CK250K),
	.qnb0(qnb0),
	//input
	.OSC_OUT(OSC_OUT),
	.RSTN_ADC(RSTN_ADC),
	.POR(POR)
	);

POR_DL  xPOR_DL ( 
	//output
	.DIG_POR(DIG_POR), 
	.LOSC_OUT(LOSC_OUT), 
	.POR(POR)
	);

MC_A6_ADC xMC_A6_ADC( 
	//output
	.ADCOUT_LSB(ADCOUT_LSB), 
	.ADCOUT_MSB(ADCOUT_MSB), 
	.CV_DONE(CV_DONE),
	//input
     	.OSC_OUT(OSC_OUT), 
	.ADC_EN(ADC_EN&(ENXCH|ENYCH|ENZCH)), 
	.RSTN_ADC(RSTN_ADC)
	);
 	
     
iopad_65 iopad_65 (
	//output
	.csb_di(csb_di),
	.scl_di(scl_di),
	.sdo_di(sdo_di),
	.sdio_di(sdio_di),
	//input
	.sdo_pad(sdo_pad),
	.csb_pad(csb_pad),
	.scl_pad(SCL),
	.sdio_pad(SDIO),
	.sdo_do(sdo_do),
	.sdo_doe(sdo_doe),
	.sdio_doe(sdio_doe),
	.csb_enph(csb_enph),
	.scl_enph(scl_enph),
	//inout
	.sdio_do(sdio_do)
	);

endmodule
