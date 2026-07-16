/***********************************************************************************
** DISCLAIMER                                                                     **
**                                                                                **
**   SMIC hereby provides the quality information to you but makes no claims,     **
** promises or guarantees about the accuracy, completeness, or adequacy of the    **
** information herein. The information contained herein is provided on an "AS IS" **
** basis without any warranty, and SMIC assumes no obligation to provide support  **
** of any kind or otherwise maintain the information.                             **
**   SMIC disclaims any representation that the information does not infringe any **
** intellectual property rights or proprietary rights of any third parties.SMIC   **
** makes no other warranty, whether express, implied or statutory as to any       **
** matter whatsoever,including but not limited to the accuracy or sufficiency of  **
** any information or the merchantability and fitness for a particular purpose.   **
** Neither SMIC nor any of its representatives shall be liable for any cause of   **
** action incurred to connect to this service.                                    **
**                                                                                **
** STATEMENT OF USE AND CONFIDENTIALITY                                           **
**                                                                                **
**   The following/attached material contains confidential and proprietary        **
** information of SMIC. This material is based upon information which SMIC        **
** considers reliable, but SMIC neither represents nor warrants that such         **
** information is accurate or complete, and it must not be relied upon as such.   **
** This information was prepared for informational purposes and is for the use    **
** by SMIC's customer only. SMIC reserves the right to make changes in the        **
** information at any time without notice.                                        **
**   No part of this information may be reproduced, transmitted, transcribed,     **
** stored in a retrieval system, or translated into any human or computer         **
** language, in any form or by any means, electronic, mechanical, magnetic,       **
** optical, chemical, manual, or otherwise, without the prior written consent of  **
** SMIC. Any unauthorized use or disclosure of this material is strictly          **
** prohibited and may be unlawful. By accepting this material, the receiving      **
** party shall be deemed to have acknowledged, accepted, and agreed to be bound   **
** by the foregoing limitations and restrictions. Thank you.                      **
************************************************************************************
**  Check tool version:
**  VCS       :  vcs_2011.12-SP1
**  NC-Verilog:  INCISIV10.20.035
**  ModelSim  :  ams_2012.1_1 
** 
************************************************************************************
**  Project : S0153GEFUSE_PIPO256B (IP DesignKit)                                
**                                                                                 
************************************************************************************
**  History:                                                                       
**  Version   Date         Author       Description                                
************************************************************************************
**  V0.1.1    2014/11/07   Sarah     Initial release
**  V0.3.1    2016/09/09   Ruiming   Improved the data type and expression of d_rd and ctrl_rp for tool compatible.
***********************************************************************************/

`celldefine
`timescale 1ns/10ps
//  -------------------------------------------------------------------------------
//  IMPORTANT!!! Before using the model, must be familiar with:
//  user defined compile directives or options as listed below
//  -------------------------------------------------------------------------------

    ////////////////////////////////////////////////////////////////////////////////
    //NO_TIMING_OP: if defined, no timing check or timing constraint is performed //
    ////////////////////////////////////////////////////////////////////////////////

// `define NO_TIMING_OP 

    ////////////////////////////////////////////////////////////////////////////////
    //NO_SIM_STOP_OP: if defined, simulation won't stop regardless of error or timing
    //                violation, except for:
    //                (1) TPH violation
    //                (2) TPS violation
    //                (3) TAVDD_MAX
    ////////////////////////////////////////////////////////////////////////////////
//  `define NO_SIM_STOP_OP

//  -------------------------------------------------------------------------
//  Macro definition
//  -------------------------------------------------------------------------
    
    /* Timing definitions */
    // Read mode timing definitions
    `define TRD             50
    `define TAEN_R_MIN      100
    `define TSUR_A          10
    `define THR_A           10
    `define TSUR_DVDD       150
    `define THR_DVDD        150
    `define TSUR_RD         100
    `define THR_RD          100
    `define TSQ             45
    `define TSQ_H           0
    // Program mode timing definitions
    `define TAVDD_ACC_MAX   1000000000
    `define TPGM_MIN        9000
    `define TPGM_MAX        11000
    `define TAEN_P_MIN      10000
    `define TSUP_A          50
    `define THP_A           50
    `define TSUP_PGM        100   
    `define THP_PGM         100
    `define TSUP_RD         150
    `define THP_RD          150
    `define TSUP_PG_AVDD    1000
    `define THP_PG_AVDD     1000
    // Power supply sequence
    `define TPS             200
    `define TPH             200

module S0153GEFUSE_PIPO256B (
    AEN,
    RDEN,
    PGMEN,
    A,
    D,
    DVDD,
    AVDD,
//  AVSS,
    DVSS
);

    input         AEN;    // Address enable signal in read or program process
    input         RDEN;   // Active high for read mode;
                          // When in program mode, must be set to logic low
    input         PGMEN;  // High for program mode;
                          // When in read mode, must be set to logic low
    input  [7:0] A;      // Address input
    output [7:0]  D;      // Data out in read mode
    input         DVDD;   // 1.8V power supply
    input         AVDD;   // 3.3V power supply; Must be high during programming
    input         DVSS;   // Ground for 1.8V power supply
//  inout         AVSS;   // Ground for 3.3V power supply

////////////////////////////////////////
//  Parameter definition              //
////////////////////////////////////////

    /***********************/
    /* SIMULATION CONTROLS */
    /***********************/
`ifdef NO_SIM_STOP_OP
    parameter NO_SIM_STOP    = 1;              // if =1, simulation will continue regardless of errors
`else
    parameter NO_SIM_STOP    = 0;              // if =0, simulation will end if simulation errror occurs
`endif
    parameter TAVDD_MAX_TEST = 1;              // if =1, TAVDD_MAX (accumulative) violation will be detected
    parameter LOG_TIME       = 50;             // Simulation continue time after sim_stop/sim_stop_forced flag raised
    parameter TAVDD_MAX      = `TAVDD_ACC_MAX; // AVDD accumulative max high time
    /*********************/
    /* Efuse volumn size */
    /*********************/
    parameter     FUSE_SIZE = 256;   // Total Efuse strorage bit size
    /****************************/
    /* Efuse address/data width */
    /****************************/
    parameter     ADR_WIDTH  =8;     // Program address width
    parameter     ADR_R_WIDTH=5;     // Read address width
    parameter     DAT_WIDTH  =8;      // Read out data width
    
    /* Efuse state machine */
    parameter SM_PWROFF           = "POWER OFF";          // Power off state
    parameter SM_INIT             = "INIT";               // Intial state when power on
    parameter SM_RD_RDY           = "READ READY";         // Read ready state
    parameter SM_PGM_RDY          = "PROGRAM READY";      // Program ready state
    parameter SM_IN_RD            = "IN READING";         // State when in reading process 
    parameter SM_IN_PGM           = "IN PROGRAMMING";     // State when in programming process 
    parameter SM_RD_ERR           = "READ ERROR";         // State when there is a reading error
    parameter SM_NON_RD_ERR       = "NON_RD ERRORS";      // State when there is another error than reading error
    parameter SM_INACTIVE         = "INACTIVE";           // Inactive state
    parameter SM_INACTIVE_AVDDHIGH= "INACTIVE AVDD HIGH"; // Another inactive state when AVDD is high
    parameter SM_STOP             = "SIM STOP";           // State when simulation will be ended due to severe errors     
    parameter SM_DVDD_ERR         = "DVDD ERROR";         // State when DVDD becomes unknown after simulation

//  Signal declarations

    /* Buffered signals */
    reg  [DAT_WIDTH-1:0]    d_nxt;                 // Data ready for output
    reg  [DAT_WIDTH-1:0]    d_rd;                  // Data read from Efuse

    /* Notifier signals */
    reg           notify_sur;            // Notifier when setup time violation occurs in read mode
    reg           notify_hr;             // Notifier when hold time violation occurs in read mode
    reg           notify_r_trd;          // Notifier when TRD timing violation occurs in read mode
    reg           notify_r_taen_r_min;   // Notifier when TAEN_R_MIN violation occurs in read mode
    reg           notify_r_tsur_dvdd;    // Notifier when TSUR_DVDD timing violation occurs in read mode
    reg           notify_r_thr_dvdd;     // Notifier when THR_DVDD timing violation occurs in read mode
    reg           notify_sup;            // Notifier when setup time violation occurs in program mode
    reg           notify_hp;             // Notifier when hold time violation occurs in program mode
    reg           notify_p_tpgm_min;     // Notifier when TPGM_MIN occurs in program mode
    reg           notify_p_taen_p_min;   // Notifier when TAEN_P_MIN occurs in program mode
    reg           notify_p_tsup_rd;      // Nofifier when TSUP_RD (setup AVDD high->RDEN negedge) violation occurs
    reg           notify_p_thp_rd;       // Nofifier when THP_RD (hold AVDD low->RDEN posedge) violation occurs
    real          dvdd_trans_to_1_time;  // The time when DVDD transitions to high
    real          avdd_trans_to_0z_time; // The tiem when AVDD tranistions from high to low or floating
    real          avdd_trans_to_1_time;  // The tiem when AVDD tranistions to high
    real          rden_trans_to_0_time_r;// The time when RDEN transitions to low for read check
    real          rden_trans_to_0_time_p;// The time when RDEN transitions to low for program check
    real          pgmen_trans_to_0_time; // The time when PGMEN transitions to low
    reg           tsur_dvdd_violated;    // =1 once there is TSUR_DVDD (DVDD->RDEN) setup time violation
                                         // =0 if RDEN goes low
    reg           thr_dvdd_violated;     // =1 once there is THR_DVDD hold time violation (RDEN low->DVDD low/floating)
    reg           tsup_rd_violated;      // =1 once there is TSUP_RD violation (setup time violation: AVDD high->RDEN negedge)
                                         // =0 if entry into inactive mode
    reg           thp_rd_violated;       // =1 once there is THP_RD violation (hold AVDD low->RDEN posedge)
    reg           tsup_pg_avdd_violated; // =1 once there is TSUP_PG_AVDD violation (setup time AVDD high->PGMEN high)
    reg           thp_pg_avdd_violated;  // =1 once there is THP_PG_AVDD violation (hold time PGMEN low->AVDD low)
    /* Internal control, data and status signals */
    reg           fuse_data [0:FUSE_SIZE-1]; // Initial contents in Efuse storage cells
    reg           sim_stop;                  // =1 cause simulation to stop
    reg           sim_stop_forced;           // =1 force simulation to stop
    /* Program and read control signals */
    reg  [3:0]    ctrl_rp;               // AEN   --> ctrl_rp[3] 
                                         // RDEN  --> ctrl_rp[2]
                                         // PGMEN --> ctrl_rp[1]
                                         // AVDD  --> ctrl_rp[0]
    /* Program address */
    reg [ADR_WIDTH-1:0]    a_in_fuse;
    reg [ADR_WIDTH-1:0]    a_in_fuse_pre;
    /* Previous address for toggle check */
    reg [ADR_WIDTH-1:0]    a_pre;
    /* Efuse mode flags */
    wire          inactive_flg;          // =1 in inactive mode
    wire          inactive_avdd_high_flg;// =1 in inactive other mode: AEN  =0
                                         //                            RDEN =0
                                         //                            PGMEN=0
                                         //                            AVDD =1
    reg           inactive_entered;      // =1 and remain as 1 after inactive mode is entered once
    wire          dvdd_is_1_x;           // =1 if DVDD is high or X
    wire          dvdd_is_1;             // =1 if DVDD is high
    wire          avdd_is_1_x;           // =1 if AVDD is high or X
    wire          avdd_is_1;             // =1 if AVDD is high
    reg           d_change;              // =1 if D will be changed after an coming read
    /* Efuse RD PGM mode state machine */
    reg [255:0]      efuse_sm;
    /* Timing check and record signals */
    real          rden_pos_time;
    real          pgmen_pos_time;
    real          aen_pos_time;
    real          aen_01_time;           // The time when AEN changes to high
    real          aen_10_time;           // The time when AEN changes to low
    reg           avdd_chk;              // TAVDD_MAX check trigger signal
    real          avdd_01_time;          // The time when AVDD changes to high
    real          avdd_10_time;          // The time when AVDD changes to 0/X/Z
    real          avdd_1_sum_time;       // The accumulative time AVDD has been high
    integer       avdd_1_sum_time_int;   // The accumulative time AVDD has been high in integer
    /* Port buffers */
    wire                   aen_buf;
    wire                   rden_buf;
    wire                   pgmen_buf;
    wire [ADR_WIDTH-1:0]   a_buf;
    wire [DAT_WIDTH-1:0]   buf_d;
    wire                   avdd_buf;
    wire                   dvdd_buf;
    // Timing check condition signals
    wire          pgm_chk_en;            // = /* AEN & */!RDEN & PGMEN     &  AVDD          & DVDD 
    wire          pgmrdy_chk_en;         // = !AEN &     !RDEN & !PGMEN /* &  AVDD */       & DVDD
    wire          rd_chk_en;             // = /* AEN & */ RDEN & !PGMEN    & (AVDD===1'b0|AVDD==1'bz) & DVDD
    wire          rdrdy_chk_en;          // = !AEN /*& RDEN */ & !PGMEN    & (AVDD===1'b0|AVDD==1'bz) & DVDD
    /* Other signals */
    integer       i;
    // Inputs buffering
    buf           (aen_buf,      AEN);
    buf           (rden_buf,     RDEN);
    buf           (pgmen_buf,    PGMEN);
    buf           (a_buf[0],     A[0]);
	buf           (a_buf[7],     A[7]);
	buf           (a_buf[6],     A[6]);
	buf           (a_buf[5],     A[5]);
	buf           (a_buf[4],     A[4]);
	buf           (a_buf[3],     A[3]);
	buf           (a_buf[2],     A[2]);
	buf           (a_buf[1],     A[1]);
    // Outputs buffering
    buf           (D[7],         buf_d[7]);
    buf           (D[6],         buf_d[6]);
    buf           (D[5],         buf_d[5]);
    buf           (D[4],         buf_d[4]);
    buf           (D[3],         buf_d[3]);
    buf           (D[2],         buf_d[2]);
    buf           (D[1],         buf_d[1]);
    buf           (D[0],         buf_d[0]);
    // AVDD buffering
    // buf           (avdd_buf,     AVDD);
    assign            avdd_buf    = AVDD;
    // DVDD buffering
    // buf           (dvdd_buf,     DVDD);
    assign            dvdd_buf    = DVDD;

    // Signal assignments
    assign buf_d       = d_rd;
    always  @(d_nxt) d_rd        = d_nxt;
    // Input control signal (read/program) assignment
    always  @(aen_buf)   ctrl_rp[3]= aen_buf;
    always  @(rden_buf)  ctrl_rp[2]= rden_buf;
    always  @(pgmen_buf) ctrl_rp[1]= pgmen_buf;
    always  @(avdd_buf)  ctrl_rp[0]= avdd_buf;
    // State assignments
    assign inactive_flg           = (efuse_sm==SM_INACTIVE);
    assign inactive_avdd_high_flg = (efuse_sm==SM_INACTIVE_AVDDHIGH);
    assign dvdd_is_1_x        = (DVDD===1'b1)|(DVDD===1'bx);
    assign dvdd_is_1          = (DVDD===1'b1);
    assign avdd_is_1_x        = (AVDD===1'b1)|(AVDD===1'bx);
    assign avdd_is_1          = (AVDD===1'b1);
    // Timing check condition signals
    assign pgm_chk_en         = /* AEN & */!RDEN & PGMEN  &  AVDD    & DVDD; 
    assign pgmrdy_chk_en      = !AEN & !RDEN & !PGMEN /*  &  AVDD */ & DVDD; 
    assign rd_chk_en          = /* AEN & */RDEN & !PGMEN  & (AVDD===1'b0|AVDD===1'bz) & DVDD; 
    assign rdrdy_chk_en       = !AEN /*& RDEN */ & !PGMEN & (AVDD===1'b0|AVDD===1'bz) & DVDD; 

    // Intialize signals or states
    initial begin
        ///////////////////////////////
        // Initialize the data in Efuse
        ///////////////////////////////
        $display("------------------------------------------------");
        $display ("Info(@%0.3f ns): all Efuse data initialized as 0s.", $realtime);
        $display("------------------------------------------------");
        INIT_EFUSE;

        ///////////////////////////////
        
        /* Initialize D output */
        SET_D_X;
        /* Initialize control signals */
        sim_stop            = 1'b0;
        sim_stop_forced     = 1'b0;
        /* Initialize previous address */
        a_pre               = {{ADR_WIDTH}{1'b0}};
        /* Initialize signals that record timing */     
        aen_01_time           = -1;
        aen_10_time           = -1;
        avdd_01_time          = -1;
        avdd_10_time          = -1;
        avdd_1_sum_time       = -1;
        dvdd_trans_to_1_time  = -1; 
        avdd_trans_to_0z_time = -1;
        avdd_trans_to_1_time  = -1;
        rden_trans_to_0_time_r= -1;  
        rden_trans_to_0_time_p= -1;  
        pgmen_trans_to_0_time = -1;
      	rden_pos_time         =  0;
	aen_pos_time          =  0;
	pgmen_pos_time        =  0;

        avdd_1_sum_time_int   =  0;
        avdd_chk              =  0;
        /* Initialize efuse state machine */
        efuse_sm            = SM_PWROFF;
        /* Program address being null */
        a_in_fuse           = {{ADR_WIDTH}{1'bx}};
        a_in_fuse_pre       = {{ADR_WIDTH}{1'bx}};
        /* Initialize timing check flag signals */
        notify_r_tsur_dvdd   = 1'b0;
        notify_r_thr_dvdd    = 1'b0;
        notify_p_tsup_rd     = 1'b0;
        notify_p_thp_rd      = 1'b0;
        tsur_dvdd_violated   = 1'b0;
        thr_dvdd_violated    = 1'b0;
        tsup_rd_violated     = 1'b0;
        thp_rd_violated      = 1'b0;
        tsup_pg_avdd_violated= 1'b0;
        thp_pg_avdd_violated = 1'b0;
        /* Initialize status flag signals */
        inactive_entered     = 1'b0;
        d_change             = 1'b0;
    end 
    
    // Efuse status flags
    always @(efuse_sm) if (efuse_sm==SM_INACTIVE) inactive_entered=1'b1;
    
    // Efuse state machine when DVDD is powered on
    always @(ctrl_rp) begin
        if (dvdd_buf===1'b1) begin
        case (efuse_sm) 
        SM_INIT:    
            if (ctrl_rp[3:1]===3'b000&&ctrl_rp[0]!==1'b1&&ctrl_rp[0]!==1'bx)
                               efuse_sm = SM_INACTIVE;
        SM_INACTIVE: begin
            if (ctrl_rp[3:1]===3'b010&&ctrl_rp[0]!==1'b1&&ctrl_rp[0]!==1'bx) 
                               efuse_sm = SM_RD_RDY;
            else if (ctrl_rp===4'b0001)
                               efuse_sm = SM_INACTIVE_AVDDHIGH;
        end
        SM_INACTIVE_AVDDHIGH:
            if (ctrl_rp[3:1]===3'b000&&ctrl_rp[0]!==1'b1&&ctrl_rp[0]!==1'bx) begin
                               efuse_sm = SM_INACTIVE;
            end
            else if (ctrl_rp[3:0]===4'b0011) begin 
                               efuse_sm = SM_PGM_RDY;
            end
        SM_RD_RDY: begin 
            /* Check violation TSUR_DVDD that should avoid read attempt */
            if (tsur_dvdd_violated==1'b1) begin
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): Bad attempt to enter read mode detected!", $realtime); 
                $display("    TSUR_DVDD violation is NOT cleared!");
                $display("    Please enter inactive mode first before any read attempt.");
            end
            /* Check violation THP_RD that should avoid read attempt */
            if (thp_rd_violated==1'b1) begin
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): Bad attempt to enter read mode detected!", $realtime); 
                $display("    THP_RD violation is NOT cleared!");
                $display("    Please enter inactive mode first before any read attempt.");
            end
            if (ctrl_rp[3:1]===3'b000&&ctrl_rp[0]!==1'b1&&ctrl_rp[0]!==1'bx)
                               efuse_sm = SM_INACTIVE;
            else if (ctrl_rp[3:1]===3'b110&&ctrl_rp[0]!==1'b1&&ctrl_rp[0]!==1'bx) 
                               efuse_sm = SM_IN_RD;
        end
        SM_IN_RD:
            if (ctrl_rp[3:1]===3'b010&&ctrl_rp[0]!==1'b1&&ctrl_rp[0]!==1'bx) 
                               efuse_sm = SM_RD_RDY;
        SM_PGM_RDY: begin 
            /* Check violation TSUP_RD that should avoid program attempt */
            if (tsup_rd_violated==1'b1) begin
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): Dangerous attempt to enter program mode detected!", $realtime);
                $display("    TSUP_RD violation is NOT cleared!");
                $display("    Please enter inactive mode first before any program attempt.");
            end
            if (ctrl_rp===4'b0001)
                               efuse_sm = SM_INACTIVE_AVDDHIGH;
            else if (ctrl_rp===4'b1011) 
                               efuse_sm = SM_IN_PGM;
        end
        SM_IN_PGM:
            if (ctrl_rp[3:1]===3'b000&&ctrl_rp[0]!==1'b1&&ctrl_rp[0]!==1'bx)
                               efuse_sm = SM_INACTIVE;
            else if (ctrl_rp[3:0]===4'b0011)  
                               efuse_sm = SM_PGM_RDY; 
        endcase /* efuse_sm */
        end /* if (dvdd===1'b1) */
    end
    // DVDD toggle and X/Z detection 
    always @(dvdd_buf) begin: DVDD_T_XZ_DET
        if (sim_stop_forced) disable DVDD_T_XZ_DET;
        if (dvdd_buf===1'bx) begin
            if (efuse_sm==SM_IN_PGM) begin
                fuse_data[a_in_fuse]         = 1'bx;
                fuse_data[a_buf]             = 1'bx;
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): Unknown DVDD supply detected when programming ...", $realtime);
                $display("    This can severely ruin the fuse data!!!");
                efuse_sm     = SM_STOP;
            end
            else if (inactive_entered==1'b1) begin
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): Unknown DVDD supply detected ...", $realtime);
                $display("    This can severely cause unpredictable efuse operation!!!");
                efuse_sm     = SM_STOP;
            end
        end
        if (dvdd_buf===1'b1) begin
            if (efuse_sm==SM_PWROFF) begin
                /* Clear THR_DVDD timing violation flag */
                thr_dvdd_violated = 1'b0;
                if (ctrl_rp[3:1]===3'b000&&ctrl_rp[0]!==1'b1&&ctrl_rp[0]!==1'bx)
                               efuse_sm = SM_INACTIVE;
                else           efuse_sm = SM_INIT;
                $display("------------------------------------------------");
                $display("Info!!!(@%0.3f ns): DVDD power is switched on.", $realtime);
            end
        end
        if (dvdd_buf===1'b0||dvdd_buf===1'bz) begin
            if (efuse_sm==SM_IN_PGM) begin
                fuse_data[a_in_fuse]         = 1'bx;
                fuse_data[a_buf]             = 1'bx;
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): DVDD power off when programming ...", $realtime);
                $display("    This is causing unkown or ruined fuse data!!!");
                efuse_sm     = SM_STOP;
            end
            else if (efuse_sm==SM_IN_RD) begin
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): DVDD power off when reading ...", $realtime);
                $display("    Read data on D become invalid!");
                efuse_sm     = SM_PWROFF;
            end
            else if (efuse_sm==SM_INACTIVE) begin
                $display("------------------------------------------------");
                $display("Info!!!(@%0.3f ns): DVDD turned off ...", $realtime);
                efuse_sm     = SM_PWROFF;
            end
            else if (efuse_sm!=SM_PWROFF) begin
                $display("------------------------------------------------");
                $display("Warning!!!(@%0.3f ns): DVDD turned off ...", $realtime);
                efuse_sm     = SM_PWROFF;
            end
        end
	if(avdd_buf===1'b1) begin
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): DVDD can not be changed when AVDD is high !!!", $realtime);
	end
    end
     
`ifdef  NO_TIMING_OP
`else
    // RDEN to DVDD timing check
    // $setup(posedge DVDD, posedge RDEN &&& (rdrdy_chk_en==1),Tsur_dvdd, notify_r_tsur_dvdd);// TSUR_DVDD
    // $hold (negedge RDEN &&& (rdrdy_chk_en==1), negedge DVDD,Thr_dvdd,  notify_r_thr_dvdd); // THR_DVDD
    always @(posedge dvdd_is_1_x) begin: TSUR_DVDD_DET
        if (!dvdd_is_1) disable TSUR_DVDD_DET; // Exclude 0/Z->X
        dvdd_trans_to_1_time = $realtime;
        fork
            begin: WAIT_RDEN_HIGH
                @(posedge RDEN);
                if (rdrdy_chk_en==1) begin 
                    if ($realtime-dvdd_trans_to_1_time<`TSUR_DVDD) notify_r_tsur_dvdd = ~notify_r_tsur_dvdd;
                end
                disable STOP_WAIT_RDEN_HIGH;
            end
            begin: STOP_WAIT_RDEN_HIGH
                @(dvdd_is_1) disable WAIT_RDEN_HIGH; // 1->X, 1->0, 1->Z
            end
        join
    end
    always @(negedge RDEN) begin: THR_DVDD_DET
        if (rdrdy_chk_en!=1'b1) disable THR_DVDD_DET; // DVDD = 1
        rden_trans_to_0_time_r  = $realtime;
        fork
            begin: WAIT_DVDD_0Z
                @(negedge dvdd_is_1);
                if (dvdd_buf===1'bx) disable THR_DVDD_DET; // DVDD = 0/Z
                if ($realtime-rden_trans_to_0_time_r<`THR_DVDD) notify_r_thr_dvdd=~notify_r_thr_dvdd;
                disable STOP_WAIT_DVDD_0Z;
            end
            begin: STOP_WAIT_DVDD_0Z
                @(RDEN) disable WAIT_DVDD_0Z;
            end
        join
    end
`endif
    // AVDD toggle detection
    always @(avdd_buf) begin
        if (avdd_buf===1'bx) begin
            if (efuse_sm==SM_IN_PGM) begin
                fuse_data[a_in_fuse]         = 1'bx;
                fuse_data[a_buf]             = 1'bx;
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): Unknown AVDD is detected when in programming...", $realtime);
                $display("    This can damage fuse data!!!");
                efuse_sm     = SM_STOP;
            end 
            else if (inactive_entered==1'b1) begin
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): Unknown AVDD supply is detected! ", $realtime);
                $display("    This can result in unpredictable fuse operation!!!");     
                efuse_sm     = SM_STOP;
            end    
        end
        if (avdd_buf===1'b0||avdd_buf===1'bz) begin
            /* Clear TSUP_RD timing violation flag */
            tsup_rd_violated  = 1'b0;
            if (efuse_sm==SM_IN_PGM) begin
                fuse_data[a_in_fuse]         = 1'bx;
                fuse_data[a_buf]             = 1'bx;
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): AVDD floated or power off when programming ...", $realtime);
                $display("    This can result in ruined fuse data!!!");
                efuse_sm     = SM_STOP;
            end
//////////////////////////////////////////////////  
            else if (efuse_sm==SM_PGM_RDY) begin
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): AVDD floated or power off when programming is ready ...", $realtime);
                efuse_sm     = SM_INIT;
            end
            else begin
                $display("------------------------------------------------");
                $display("Info(@%0.3f ns): AVDD floated or power off ... ", $realtime);
            end
//////////////////////////////////////////////////  
        end
        if (avdd_buf===1'b1) begin
            if (efuse_sm==SM_PWROFF) begin
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): AVDD high detected when DVDD is down", $realtime);
                $display("    AVDD can only be low or floating when DVDD is powered off!", $realtime);
            end
//////////////////////////////////////////////////  
            if (pgmen_buf===1'b1) begin
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): AVDD is powered on when PGMEN is high", $realtime);
                $display("    AVDD cannot be high except when PGMEN is low !!!");
                $display("    Otherwise this can cause unpredicable and severe fuse data error afterwards !!!");
                efuse_sm     = SM_STOP;
            end
//////////////////////////////////////////////////  
            else begin
                /* Clear THP_PG_AVDD timing violation flag */
                thp_pg_avdd_violated = 1'b0;
                if (efuse_sm==SM_RD_RDY) begin
                    $display("------------------------------------------------");
                    $display("Warning!!!(@%0.3f ns): AVDD high is detected when in read mode ...", $realtime);
                    $display("    AVDD cannot be high except RDEN is low.");
                    efuse_sm     = SM_NON_RD_ERR;
                end
            end
        end
    end
`ifdef  NO_TIMING_OP
`else
    /* RDEN to AVDD timing check */
    // $setup(negedge RDEN,   posedge AVDD &&& (pgmrdy_chk_en==1),  Tsup_rd,  notify_p_tsup_rd);// TSUP_RD 
    // $hold (negedge AVDD &&& (pgmrdy_chk_en==1), posedge RDEN,    Thp_rd,   notify_p);        // THP_RD
    always @(negedge RDEN) begin: TSUP_RD_DET
        rden_trans_to_0_time_p = $realtime;
        fork
            begin: WAIT_AVDD_HIGH
                @(posedge avdd_is_1_x);
                if (avdd_buf===1'bx) disable TSUP_RD_DET;
                if (pgmrdy_chk_en==1'b1) begin
                    if ($realtime-rden_trans_to_0_time_p<`TSUP_RD) notify_p_tsup_rd = ~notify_p_tsup_rd; 
                end
                disable STOP_WAIT_AVDD_HIGH;
            end
            begin: STOP_WAIT_AVDD_HIGH
                @(RDEN) disable WAIT_AVDD_HIGH;
            end
        join
    end
    always @(negedge avdd_is_1) begin: THP_RD_DET
        if (avdd_buf===1'bx) disable THP_RD_DET;
        avdd_trans_to_0z_time = $realtime;
        if (pgmrdy_chk_en!=1'b1) disable THP_RD_DET;
        fork
            begin: WAIT_RDEN_HIGH
                @(posedge RDEN);
                if ($realtime-avdd_trans_to_0z_time<`THP_RD) notify_p_thp_rd = ~notify_p_thp_rd;
                disable STOP_WAIT_RDEN_HIGH;
            end
            begin: STOP_WAIT_RDEN_HIGH
                @(avdd_is_1_x) disable WAIT_RDEN_HIGH;
            end
        join
    end
    /* PGMEN to AVDD timing check */
    // $setup(posedge AVDD,   posedge PGMEN &&& (pgm_chk_en==1),    Tsup_pg_avdd, notify_p);  // TSUP_PG_AVDD
    // $hold (negedge PGMEN &&& (pgm_chk_en==1), negedge AVDD,      Thp_pg_avdd,  notify_p);  // THP_PG_AVDD
    always @(posedge avdd_is_1_x) begin: TSUP_PG_AVDD_DET
        if (!avdd_is_1)         disable  TSUP_PG_AVDD_DET;
        avdd_trans_to_1_time = $realtime;
        fork
            begin: WAIT_PGMEN_HIGH
                @(posedge PGMEN);
                if (dvdd_buf==1'b1&&avdd_buf==1'b1&&rden_buf==1'b0&&aen_buf==1'b0) begin
                    if($realtime-avdd_trans_to_1_time<`TSUP_PG_AVDD) begin
                         tsup_pg_avdd_violated = 1'b1;
                         $display("------------------------------------------------");
                         $display("Error!!!(@%0.3f ns): Setup time violation (TSUP_PG_AVDD) occurs!",
                               $realtime);
                         $display("    Please enter inactive mode before any program attempt.");
                    end
                end
                disable STOP_WAIT_PGMEN_HIGH;
            end
            begin: STOP_WAIT_PGMEN_HIGH
                @(avdd_is_1) disable WAIT_PGMEN_HIGH;
            end
        join
    end
    always @(negedge pgmen_buf) begin: THP_PG_AVDD_DET
        pgmen_trans_to_0_time = $realtime;
        if (dvdd_buf!==1'b1||avdd_buf!==1'b1||rden_buf!==1'b0||aen_buf!==1'b0) disable THP_PG_AVDD_DET;
        fork
            begin: WAIT_AVDD_0Z
                @(negedge avdd_is_1);
                if (avdd_buf===1'bx) disable THP_PG_AVDD_DET;
                if ($realtime-pgmen_trans_to_0_time<`THP_PG_AVDD) begin
                    thp_pg_avdd_violated = 1'b1;
                    $display("------------------------------------------------");
                    $display("Error!!!(@%0.3f ns): Hold time violation (THP_PG_AVDD) occurs!",
                               $realtime);
                    $display("    Please enter inactive mode before any program attempt.");
                end
                disable STOP_WAIT_AVDD_0Z;
            end
            begin: STOP_WAIT_AVDD_0Z
                @(pgmen_buf) disable WAIT_AVDD_0Z;
            end
        join
    end
    // AVDD accumulative high time TMAX_AVDD check
    always #1 /*#1000*/ avdd_chk = ~avdd_chk & TAVDD_MAX_TEST;
    always @(posedge avdd_chk)        begin:  TAVDD_MAX_DET
        if (sim_stop|sim_stop_forced) disable TAVDD_MAX_DET;
        if ((avdd_10_time<avdd_01_time)&&($realtime-avdd_01_time+avdd_1_sum_time>TAVDD_MAX)) begin
            $display("------------------------------------------------");
            $display("Error!!!(@%0.3f ns): accumulative time for AVDD in high state exceeds %0.3f ns!",
                     $realtime, TAVDD_MAX);
            $display("    Efuse damaged!");
            SET_FUSE_X;
            sim_stop_forced  = 1'b1;    // Simulation will be forced to stop
        end
    end
    always @(avdd_buf) begin
        if (avdd_buf===1'b1) avdd_01_time  = $realtime; 
        else begin
            avdd_10_time  = $realtime;
            if ((avdd_01_time!=-1)&&(avdd_10_time!=-1)&&(avdd_10_time>avdd_01_time)) begin
                if(avdd_1_sum_time==-1) avdd_1_sum_time = 0;
                avdd_1_sum_time = avdd_1_sum_time+avdd_10_time-avdd_01_time;
                if (avdd_1_sum_time>TAVDD_MAX) begin
                    $display("------------------------------------------------");
                    $display("Error!!!(@%0.3f ns): accumulative time for AVDD in high state exceeds %0.3f ns!",
                              $realtime, TAVDD_MAX);
                    $display("    Efuse damaged!");
                    SET_FUSE_X;
                    sim_stop_forced   = 1'b1; // Simulation forced to stop
                end
                else begin
                    /* avdd_1_sum_time monitoring */
                    avdd_1_sum_time_int = avdd_1_sum_time;
                end
            end
        end
    end
    // Check TPS timing constraint
    always @(posedge dvdd_is_1_x) begin: TPS_DET
        if (!dvdd_is_1)         disable  TPS_DET;
        if (avdd_is_1_x)        disable  TPS_DET;
        fork
            begin: WAIT_AVDD_HIHG
                @(posedge avdd_is_1_x);
                if (!avdd_is_1) disable TPS_DET;
                if ($realtime-dvdd_trans_to_1_time<`TPS) begin
                    $display("------------------------------------------------");
                    $display("Error!!!(@%0.3f ns): AVDD powers on too early after DVDD is up!",$realtime);
                    $display("    Setup time TPS violation occurs.");
                    $display("    The violation will lead to efuse unstability!");
                    sim_stop_forced = 1'b1;
                end
                disable STOP_WAIT_AVDD_HIHG;
            end
            begin: STOP_WAIT_AVDD_HIHG
                @(dvdd_is_1) disable WAIT_AVDD_HIHG;
            end
        join
    end
    // Check TPH timing constraint
    always @(negedge avdd_is_1) begin: TPH_DET
        if (avdd_buf===1'bx)    disable TPH_DET;
        if (!dvdd_is_1)     disable  TPH_DET;
        fork
            begin: WAIT_DVDD_LOW 
                @(negedge dvdd_is_1);
                if (dvdd_buf===1'bx) disable TPH_DET;
                if ($realtime-avdd_trans_to_0z_time<`TPH) begin
                    $display("------------------------------------------------");
                    $display("Error!!!(@%0.3f ns): DVDD shuts down too early after AVDD is down!",$realtime);
                    $display("    Hold time TPH violation occurs.");
                    $display("    The violation will lead to efuse damage!");
                    sim_stop_forced = 1'b1;
                end
                disable STOP_WAIT_DVDD_LOW;
            end
            begin: STOP_WAIT_DVDD_LOW
                @(avdd_is_1_x) disable WAIT_DVDD_LOW;
            end
        join
    end
`endif        
    // Inactive mode detection
    always @(inactive_flg) begin:  INACTIVE_DET
        if (sim_stop|sim_stop_forced)      disable INACTIVE_DET;
        if ($realtime >0) begin
            if (inactive_flg == 1'b1) begin
                $display("------------------------------------------------");
                $display("Info(@%0.3f ns): Efuse enters inactive mode ...",$realtime);
            end
            else begin
                $display("------------------------------------------------");
                $display("Info(@%0.3f ns): Efuse exits inactive mode ...", $realtime);
            end
        end
    end 
    // Address toggle
    always @(a_buf[ADR_R_WIDTH-1:0]) begin // Address toggle in READ mode
        if (efuse_sm==SM_IN_RD) begin
            $display("------------------------------------------------");
            $display("Error!!!(@%0.3f ns): A (address) toggle detected when in read access ...", $realtime);
            $display("    Unknown read access result and D will be invalid.");
            efuse_sm     = SM_RD_ERR;
        end
    end
    always @(a_buf) begin     // Address toggle in PGM mode
        if (efuse_sm==SM_IN_PGM) begin
            $display("------------------------------------------------");
            if (^A[ADR_WIDTH-1:0]===1'bx) begin
                SET_FUSE_X;
                $display("Error!!!(@%0.3f ns): A (address) changed to unknow values when fuse programming ...", $realtime);
                $display("    Programming severely ruined and causing unknown programmed fuse data in whole Efuse!!!");
            end
            else begin
                fuse_data[a_in_fuse]         = 1'bx;
                fuse_data[a_buf]             = 1'bx;
                $display("Error!!!(@%0.3f ns): A (address) toggle detected when fuse programming ...", $realtime);
                $display("    Programming severely ruined and causing unknown programmed fuse data!!!");
            end
            efuse_sm     = SM_STOP;
        end
    end
    always @(a_buf) begin    // Address toggle when DVDD is low
        if(dvdd_buf===1'b0) begin
            for (i=0;i<=ADR_WIDTH-1;i=i+1) begin: ADR_H_DVDD0_CHK
                if (a_buf[i]===1'b1 && a_pre[i]!==1'b1) begin
                    $display("------------------------------------------------");
                    $display("Error!!!(@%0.3f ns): Address(es) cannot be changed to high when DVDD is low!!!", $realtime);	    
                    disable ADR_H_DVDD0_CHK;
                end
	    end
        end
        a_pre  = a_buf;
    end
    // Address X/Z values
    always @(a_buf) begin
        case (efuse_sm)
        SM_RD_RDY: begin
            if (^A[ADR_R_WIDTH-1:0]===1'bx) begin
                $display("------------------------------------------------");
                $display("Warning!!!(@%0.3f ns): X/Z values in A[%2d:0] detected when read is ready ...", 
                                     $realtime,ADR_R_WIDTH-1);
            end
        end
        SM_PGM_RDY: begin
            if (^A[ADR_WIDTH-1:0]===1'bx) begin
                $display("------------------------------------------------");
                $display("Warning!!!(@%0.3f ns): X/Z values of A detected when program is ready ...", $realtime);
            end
        end
        endcase
    end
    always @(efuse_sm) begin
        case (efuse_sm)
        SM_IN_RD: begin
            if (^A[ADR_R_WIDTH-1:0]===1'bx) begin
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): X/Z values in A[%2d:0] found when reading  ...", 
                                   $realtime,ADR_R_WIDTH-1);
                $display("    Unknown read access result and D will be invalid.");
                efuse_sm     = SM_RD_ERR;
            end
        end
        SM_IN_PGM: begin
            if (^A[ADR_WIDTH-1:0]===1'bx) begin
                SET_FUSE_X;
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): X/Z values of A detected when programming ...", $realtime);
                $display("    Programming is causing unkown or ruined fuse data!!!");
                efuse_sm     = SM_STOP;
            end
        end
        endcase
    end
    // AEN toggle
    always @(aen_buf) begin
        if (aen_buf ==1'b1) begin
	    aen_pos_time = $realtime;
            if (dvdd_buf==1'b0||dvdd_buf==1'bz) begin
                $display("------------------------------------------------");
                $display("Info!!!(@%0.3f ns): AEN high not be able to be asserted when DVDD is down.", $realtime);
            end
            else if (efuse_sm!=SM_RD_RDY && efuse_sm!=SM_PGM_RDY) begin
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): AEN high not allowed except in read or program mode ...", $realtime);
                efuse_sm     = SM_NON_RD_ERR;
            end
	    if(dvdd_buf===1'b0) begin
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): AEN cannot be changed to high when DVDD is low!!!", $realtime);	    
	    end
        end
	else if (aen_buf===1'bx) begin
	    aen_pos_time = 0;     
        end
        else if ( (($realtime-aen_pos_time)<`TRD) && (aen_pos_time>0) ) begin
            $display("------------------------------------------------");
            $display("Error!!!(@%0.3f ns): Minimum AEN width must be larger than %0.3fns !!!", $realtime, `TRD);  
            if (efuse_sm==SM_IN_PGM) begin
                fuse_data[a_in_fuse]         = 1'bx;
                fuse_data[a_buf]             = 1'bx;
                $display("Error!!!(@%0.3f ns): Too narrow AEN pulse can cause severe fuse programming error !!! ", $realtime);
                efuse_sm     = SM_STOP;
            end
            if (efuse_sm==SM_IN_RD) begin
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): Too narrow AEN pulse can lead to fuse reading failure !!!", $realtime);
                efuse_sm     = SM_RD_ERR;
                disable READING_FUSE; SET_D_X;
            end
	end	     
    end
    // AEN X/Z detection
    always @(aen_buf) begin
        if (aen_buf===1'bz || aen_buf===1'bx) begin
            if (efuse_sm != SM_INIT) begin
                if (efuse_sm==SM_IN_RD) begin
                    $display("------------------------------------------------");
                    $display("Error!!!(@%0.3f ns): X/Z values of AEN detected when reading ... ", $realtime);
                    $display("    Unknown read access result and D will be invalid.");
                    efuse_sm     = SM_RD_ERR;
                end        
                else if (efuse_sm==SM_IN_PGM) begin
                    fuse_data[a_in_fuse]         = 1'bx;
                    fuse_data[a_buf]             = 1'bx;
                    $display("------------------------------------------------");
                    $display("Error!!!(@%0.3f ns): X/Z values of AEN detected when programming ...", $realtime);
                    $display("    Programming is causing unkown or ruined fuse data!!!");
                    efuse_sm     = SM_STOP;
                end
                else begin
                    $display("------------------------------------------------");
                    $display("Error!!!(@%0.3f ns): X/Z values of AEN is detected ...", $realtime);
                    $display("    X/Z values of AEN is forbidden!");
                    efuse_sm     = SM_NON_RD_ERR;
                end
            end
        end
    end
    // RDEN toggle detection
    always @(rden_buf) begin
        if (rden_buf===1'b1) begin
            if (pgmen_buf===1'b1) begin
                if (efuse_sm==SM_IN_PGM) begin
                    fuse_data[a_in_fuse]         = 1'bx;
                    fuse_data[a_buf]             = 1'bx;
                    $display("------------------------------------------------");
                    $display("Error!!!(@%0.3f ns): RDEN high is detected when programming ...", $realtime);
                    $display("    Circuitry can be damaged!!!");
                    efuse_sm     = SM_STOP;
                end
                else begin
                    $display("------------------------------------------------");
                    $display("Error!!!(@%0.3f ns): RDEN high is detected when PGMEN is high ...", $realtime);
                    $display("    Both RDEN high and PGMEN high is forbidden!!!");
                    efuse_sm     = SM_NON_RD_ERR;
                end
            end
	    if(dvdd_buf===1'b0) begin
                    $display("------------------------------------------------");
                    $display("Error!!!(@%0.3f ns): RDEN can not change to high when DVDD is low!!!", $realtime);	       
	    end
	    if(avdd_buf===1'b1) begin
                    $display("------------------------------------------------");
                    $display("Error!!!(@%0.3f ns): RDEN high is detected when AVDD is high!!!", $realtime);	       
	    end
        end 
        else begin
            /* Clear TSUR_DVDD / THP_RD timing violation flags */
            tsur_dvdd_violated = 1'b0;
            thp_rd_violated    = 1'b0;
            /* RDEN 1->0 toggle in reading */
            if (efuse_sm==SM_IN_RD) begin
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): RDEN 1->0 detected when in reading ...", $realtime);
                $display("    To exit read mode, AEN must be low before RDEN becomes low !!!");
                efuse_sm     = SM_RD_ERR;
                disable READING_FUSE; SET_D_X;
            end
        end
        if (rden_buf===1'b1)
	    rden_pos_time = $realtime;
	else if (rden_buf===1'bx) begin
	    rden_pos_time = 0;    
        end
        else if ( (($realtime-rden_pos_time)<`TRD)&&(rden_pos_time>0) ) begin
            $display("------------------------------------------------");
            $display("Error!!!(@%0.3f ns): Minimal RDEN width must be larger than %0.3fns !!!", $realtime, `TRD);  
	end
    end
    // RDEN X/Z detection
    always @(rden_buf) begin
        if (rden_buf===1'bz || rden_buf===1'bx) begin
            if (efuse_sm != SM_INIT) begin
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): X/Z values of RDEN is detected ...", $realtime);
                $display("    X/Z values of RDEN is forbidden!");
                efuse_sm     = SM_NON_RD_ERR;
            end
        end
    end
    // PGMEN toggle detection
    always @(pgmen_buf) begin
        if (pgmen_buf===1'b1) begin
            /* PGMEN 0->1 toggle when AEN is high */
            if (aen_buf===1'b1) begin
                fuse_data[a_in_fuse]         = 1'bx;
                fuse_data[a_buf]             = 1'bx;
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): PGMEN 0->1 detected when AEN is high ...", $realtime);
                $display("    To start programming, PGMEN must be set to high when AEN is low !!!");
                $display("    Otherwise fuse data can be severely ruined !!!");
                efuse_sm     = SM_STOP;
            end
            if (rden_buf===1'b1) begin
                if (efuse_sm==SM_IN_RD) begin
                    $display("------------------------------------------------");
                    $display("Error!!!(@%0.3f ns): PGMEN high is detected when reading ...", $realtime);
                    $display("    Circuitry can be damaged!!!");
                    efuse_sm     = SM_STOP;
                end
                else begin
                    $display("------------------------------------------------");
                    $display("Error!!!(@%0.3f ns): PGMEN high is detected when RDEN is high ...", $realtime);
                    $display("    Both RDEN high and PGMEN high is forbidden!!!");
                    efuse_sm     = SM_NON_RD_ERR;
                end
            end
            if (rden_buf===1'b0) begin
                if (efuse_sm==SM_INACTIVE) begin
                    $display("------------------------------------------------");
                    $display("Error!(@%0.3f ns): PGMEN high is detected when AVDD is NOT high ...", $realtime);
                    $display("    To enter program mode, pull AVDD high before PGMEN can be high.");
                    efuse_sm     = SM_NON_RD_ERR;
                end
            end
	    if(dvdd_buf===1'b0) begin
                    $display("------------------------------------------------");
                    $display("Error!!! (@%0.3f ns): PGMEN cannot be high when DVDD is low!!!", $realtime);	    
	    end        
        end
        else begin
            /* Clear flags TSUP_PG_AVDD violation flag */
            tsup_pg_avdd_violated = 1'b0;
            /* PGMEN 1->0 toggle in programming */
            if (efuse_sm==SM_IN_PGM) begin
                fuse_data[a_in_fuse]         = 1'bx;
                fuse_data[a_buf]             = 1'bx;
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): PGMEN 1->0 detected when in programming ...", $realtime);
                $display("    To exit program mode, AEN must be low before PGMEN becomes low !!!");
                $display("    Otherwise fuse data can be severely ruined !!!");
                efuse_sm     = SM_STOP;
            end
        end
	if (pgmen_buf===1'b1)
	    pgmen_pos_time = $realtime;
	else if(pgmen_buf===1'bx)
	    pgmen_pos_time = 0;     
	else if ( (($realtime-pgmen_pos_time)<`TPGM_MIN)&&(pgmen_pos_time>0)) begin
            $display("------------------------------------------------");
            $display("Error!!!(@%0.3f ns): Minimal PGMEN width must be larger than %0.3f ns !!!", $realtime, `TPGM_MIN);  
	end
    end
    // PGMEN X/Z detection
    always @(pgmen_buf) begin
        if (pgmen_buf===1'bz || pgmen_buf===1'bx) begin
            if (efuse_sm != SM_INIT) begin
                if (efuse_sm==SM_IN_PGM) begin
                    fuse_data[a_in_fuse]         = 1'bx;
                    fuse_data[a_buf]             = 1'bx;
                    $display("------------------------------------------------");
                    $display("Error!!!(@%0.3f ns): X/Z values of PGMEN detected when programming ...", $realtime);
                    $display("    Programming is causing unkown or ruined fuse data!!!");
                    efuse_sm     = SM_STOP;
                end
                else begin
                    $display("------------------------------------------------");
                    $display("Error!!!(@%0.3f ns): X/Z values of PGMEN is detected ...", $realtime);
                    $display("    X/Z values of PGMEN is forbidden!");
                    efuse_sm     = SM_NON_RD_ERR;
                end
            end
        end
    end
    
    ///////////////////////////////////////////
    // Reading process
    ///////////////////////////////////////////
    always @(efuse_sm) begin
        if (efuse_sm==SM_IN_RD) begin
            fork
                begin: READING_FUSE
                
                `ifdef  NO_TIMING_OP
                `else
                    /* Detect if there is timing violation that should avoid read attempt */
                    if (tsur_dvdd_violated==1'b1) begin
                        $display("------------------------------------------------");
                        $display("Error!!!(@%0.3f ns): Bad attempt of reading at A (address)=%2d'h%h(%2d'd%d)!",
                                           $realtime,ADR_R_WIDTH,a_buf[ADR_R_WIDTH-1:0],ADR_R_WIDTH,a_buf[ADR_R_WIDTH-1:0]);
                        $display("    TSUR_DVDD violation is NOT cleared!");
                        $display("    The output D will be invalid.");
                        $display("    Please enter inactive mode first before any efuse read.");
                    end
                    if (thp_rd_violated==1'b1) begin
                        $display("------------------------------------------------");
                        $display("Error!!!(@%0.3f ns): Bad attempt of reading at A (address)=%2d'h%h(%2d'd%d)!",
                                           $realtime,ADR_R_WIDTH,a_buf[ADR_R_WIDTH-1:0],ADR_R_WIDTH,a_buf[ADR_R_WIDTH-1:0]);
                        $display("    THP_RD violation is NOT cleared!");
                        $display("    The output D will be invalid.");
                        $display("    Please enter inactive mode first before any efuse read.");
                    end
                    if (tsur_dvdd_violated|thp_rd_violated) begin
                        SET_D_X;
                        disable READING_INT;
                        disable READING_FUSE;
                    end
                `endif
                    RD_FUSE; // Read task
                    disable READING_INT;
                end  // READING_FUSE
                begin : READING_INT
                    @(efuse_sm);
                    if (efuse_sm!=SM_RD_RDY) begin disable RD_FUSE;disable READING_FUSE; end
                end
            join
        end
    end     

    // Programming process
    //////////////////////////////////////////
    always @(efuse_sm) begin
        if (efuse_sm==SM_IN_PGM) begin
            fork
                begin: PROGRAMMING_FUSE
                `ifdef  NO_TIMING_OP
                `else
                    /* Detect if there is timing violation that should avoid program attempt */
                    if (tsup_rd_violated==1'b1) begin
                        $display("------------------------------------------------");
                        $display("Error!!!(@%0.3f ns): Seriously bad programming detected!!!", $realtime);
                        $display("    Pervious TSUP_RD violation is NOT cleared!");
                        $display("    Fuse data at address %2d'h%h(%2d'd%d) in danger of being damaged!",
                                                           ADR_WIDTH,a_buf,ADR_WIDTH,a_buf);
                        $display("    Due to TSUP_RD violation, please enter inactive mode before any read/program attempt."); 
                        fuse_data[a_buf] = 1'bx;
                        disable PROGRAMMING_INT;
                        disable PROGRAMMING_FUSE;
                    end
                    if (tsup_pg_avdd_violated==1'b1) begin
                        $display("------------------------------------------------");
                        $display("Error!!!(@%0.3f ns): Seriously bad programming detected!!!", $realtime);
                        $display("    Pervious TSUP_PG_AVDD violation is NOT cleared!");
                        $display("    Fuse data at address %2d'h%h(%2d'd%d) in danger of being damaged!",
                                                           ADR_WIDTH,a_buf,ADR_WIDTH,a_buf);
                        $display("    Due to TSUP_RD violation, please enter inactive mode before any read/program attempt.");
                        fuse_data[a_buf] = 1'bx;
                        disable PROGRAMMING_INT;
                        disable PROGRAMMING_FUSE;
                    end 
                `endif
                    a_in_fuse = a_buf;
                    PGM_FUSE;    // Program task
                    disable PROGRAMMING_INT;
                end
                begin : PROGRAMMING_INT
                    @(efuse_sm);
                    a_in_fuse_pre  = a_in_fuse;
                    a_in_fuse      = {{ADR_WIDTH}{1'bx}};
                    disable PROGRAMMING_FUSE;
                end
            join
        end
    end

    // Cases when D is invalid
    always @(efuse_sm) begin
        if (efuse_sm!=SM_IN_RD&&efuse_sm!=SM_RD_RDY) SET_D_X;
    end
    
`ifdef  NO_TIMING_OP
`else
    // TPGM_MAX measurement
    always @(efuse_sm) begin
        if (efuse_sm==SM_IN_PGM) begin  
            aen_01_time    = $realtime;
            @(efuse_sm);
            if (efuse_sm==SM_PGM_RDY) begin
                aen_10_time    = $realtime;
                if (aen_10_time - aen_01_time > `TPGM_MAX) begin
                    $display("------------------------------------------------");
                    $display("Error!!!(@%0.3f ns): Programming time violation occurs  ...", $realtime);
                    $display("    Programming time priod exceeds %0.3fns. Efuse could be damaged!", `TPGM_MAX);
                    fuse_data[a_in_fuse_pre] = 1'bx; 
                    efuse_sm     = SM_STOP;
                end
            end
        end
    end
`endif

    //////////////////////////////////////
    // Warning and error process
    //////////////////////////////////////

    // Read timing violation
    always @(notify_sur)                begin:  RD_SETUP_ERR
        if (sim_stop|sim_stop_forced) disable   RD_SETUP_ERR;
        $display("------------------------------------------------");
        $display("Error!!!(@%0.3f ns): setup time violation occurs in reading. Output D will be invalid.", $realtime);
        disable READING_FUSE; SET_D_X;
    end
    always @(notify_hr)                begin:  RD_HR_ERR
        if (sim_stop|sim_stop_forced) disable  RD_HR_ERR;
        $display("------------------------------------------------");
        $display("Error!!!(@%0.3f ns): hold time violation occurs in reading. Output D will be invalid.", $realtime);
        disable RD_FUSE; disable READING_FUSE; SET_D_X;
    end
    always @(notify_r_trd)            begin:   RD_TRD_ERR
        if (sim_stop|sim_stop_forced) disable  RD_TRD_ERR;
        $display("------------------------------------------------");
        $display("Error!!!(@%0.3f ns): AEN high too short for reading!", $realtime); 
        $display("    TRD time violation occurs. Output D will be invalid.");
        disable READING_FUSE; SET_D_X;
    end
    always @(notify_r_taen_r_min)       begin: TAEN_R_ERR
        if (sim_stop|sim_stop_forced) disable  TAEN_R_ERR;
        $display("------------------------------------------------");
        $display("Error!!!(@%0.3f ns): AEN cycle time too short for reading!", $realtime); 
        $display("    TAEN_R_MIN time violation occurs. Output D will be invalid.");
        disable READING_FUSE; SET_D_X;
    end
    always @(notify_r_tsur_dvdd)                   begin:  TSUR_DVDD_TIMING_ERR
        if ($realtime<=0|sim_stop|sim_stop_forced) disable TSUR_DVDD_TIMING_ERR;
        $display("------------------------------------------------");
        $display("Error!!!(@%0.3f ns): RDEN becomes high too early after DVDD is up!", $realtime);
        $display("    DVDD to RDEN setup time (TSUR_DVDD) violation occurs in read mode.");
        tsur_dvdd_violated = 1'b1;
    end
    
    always @(notify_r_thr_dvdd)       begin:  THR_DVDD_TIMING_ERR
        if ($realtime<=0|sim_stop|sim_stop_forced) disable THR_DVDD_TIMING_ERR;
        $display("------------------------------------------------");
        $display("Error!!!(@%0.3f ns): DVDD shuts off too early after RDEN becomes low.",$realtime); 
        $display("    DVDD to RDEN hold time THR_DVDD violation occurs in completing reading.");
        SET_D_X;
        thr_dvdd_violated = 1'b1;
    end
    // Program timing violation
    always @(notify_sup)                begin:  PGM_SETUP_ERR
        if (sim_stop|sim_stop_forced) disable   PGM_SETUP_ERR;
        $display("------------------------------------------------");
        $display("Error!!!(@%0.3f ns): timing violation occurs in programming!",$realtime);
        $display("    Efuse bit can be programmed to wrong value or damaged.");
        if (efuse_sm==SM_IN_PGM)
        fuse_data[a_in_fuse] = 1'bx;
    end
    always @(notify_hp)                begin:  PGM_HOLD_ERR
        if (sim_stop|sim_stop_forced) disable  PGM_HOLD_ERR;
        $display("------------------------------------------------");
        $display("Error!!!(@%0.3f ns): timing violation occurs in programming!",$realtime);
        $display("    Efuse bit can be programmed to wrong value or damaged.");
        fuse_data[a_in_fuse_pre] = 1'bx;
    end
    always @(notify_p_tpgm_min)       begin:  PGM_MIN_ERR
        if (sim_stop|sim_stop_forced) disable PGM_MIN_ERR;
        $display("------------------------------------------------");
        $display("Error!!!(@%0.3f ns): AEN width too narrow for programming!",$realtime);
        $display("    Efuse bit can be programmed to wrong value or damaged.");
        fuse_data[a_in_fuse_pre] = 1'bx;
    end
    always @(notify_p_taen_p_min)       begin:  PGM_TAEN_P_MIN_ERR
        if (sim_stop|sim_stop_forced) disable   PGM_TAEN_P_MIN_ERR;
        $display("------------------------------------------------");
        $display("Error!!!(@%0.3f ns): AEN period too short for programming!",$realtime);
        $display("    Efuse bit can be programmed to wrong value or damaged.");
        fuse_data[a_in_fuse_pre] = 1'bx;
        fuse_data[a_buf]         = 1'bx;
    end
    always @(notify_p_tsup_rd)          begin: P_TSUP_RD_ERR
        if ($realtime<=0|sim_stop|sim_stop_forced) disable  P_TSUP_RD_ERR;
        $display("------------------------------------------------");
        $display("Error!!!(@%0.3f ns): AVDD becomes high too early after RDEN is low!", $realtime);
        $display("    Please check upon timing constraint TSUP_RD.");
        $display("    Please re-enter inactive mode (with AVDD=0 or floating) before any read or program attempt.");
        tsup_rd_violated = 1'b1;
    end
    always @(notify_p_thp_rd) begin:          THP_RD_TIMING_ERR
        if ($realtime<=0|sim_stop|sim_stop_forced) disable THP_RD_TIMING_ERR;
        $display("------------------------------------------------");
        $display("Error!!!(@%0.3f ns): RDEN becomes high too early after AVDD is down!", $realtime);
        $display("    Please check upon timing constraint THP_RD.");
        $display("    Try re-enter inactive mode (with RDEN low) before any read or program attempt.");
        thp_rd_violated = 1'b1;
    end

    // Error state process
    always @(efuse_sm) if (efuse_sm==SM_STOP) sim_stop = 1'b1;
    always @(ctrl_rp or dvdd_buf) begin
        case (efuse_sm)
        SM_RD_ERR:    if (dvdd_buf==1'b1) efuse_sm = SM_INIT;
        SM_NON_RD_ERR:if (dvdd_buf==1'b1) efuse_sm = SM_INIT;
        SM_STOP,SM_DVDD_ERR: begin
                      if (NO_SIM_STOP==1)
                      if (dvdd_buf==1'b1) begin
                          if (ctrl_rp[3:1]===3'b000&&ctrl_rp[0]!==1'b1&&ctrl_rp[0]!==1'bx)
                                   efuse_sm = SM_INACTIVE;
                          else     efuse_sm = SM_INIT;
                      end
                      else if (dvdd_buf===1'b1||dvdd_buf===1'bz) efuse_sm = SM_PWROFF;
                      else efuse_sm = SM_DVDD_ERR;
        end
        endcase
    end
    /* Bad fuse operation attempts detection when either DVDD or AVDD is unknown */
    always @(aen_buf or rden_buf or pgmen_buf) begin
        case (efuse_sm) 
        SM_DVDD_ERR: begin
            $display("Error!!!(@%0.3f ns): Bad fuse operation attempt detected when DVDD is still unknown!!", $realtime);
            $display("    Please power on DVDD and set fuse to inactive mode first prior to any fuse operation.");
        end
        SM_INIT: begin
            if (avdd_buf===1'bx&&inactive_entered===1'b1) begin
            $display("Error!!!(@%0.3f ns): Bad fuse operation attempt detected when AVDD is still unknown!!!", $realtime);
            $display("    Please apply AVDD to floating or low and enter inactive mode first prior to any fuse operation.");
            end
        end
        endcase
    end

    // Errors stop simulation
    always @(posedge sim_stop) begin:  SIM_STOP_PROCESS
        if (sim_stop_forced)   disable SIM_STOP_PROCESS;
        if (NO_SIM_STOP==1) begin
            $display("    NO_SIM_STOP is set to 1. Simulation will continue though errors have occurred ...");
            sim_stop = 0;
        end
        else begin
            $display("------------------------------------------------");
            $display("Info(@%0.3f ns): simulation will end after %.3fns due to severe errors ...",
                      $realtime, LOG_TIME);
            #LOG_TIME;
            $display("------------------------------------------------");
            $display("Simulation ends at %.3f ns.", $realtime);
            $display("------------------------------------------------");
            $finish;
        end
    end
    /* Forced simulation stop */
    always @(posedge sim_stop_forced) begin
        $display("------------------------------------------------");
        $display("Info(@%0.3f ns): simulation will end after %.3fns due to severe errors ...",
                      $realtime, LOG_TIME);
        #LOG_TIME;
        $display("------------------------------------------------");
        $display("Simulation ends at %.3f ns.", $realtime);
        $display("------------------------------------------------");
        $finish;
    end
    //////////////////////////////////////
    // End of warning and error process
    //////////////////////////////////////

    ////////////////////////////////////////////////////
    // Function task declaration
    ////////////////////////////////////////////////////

    ///////////////////////////////////////////////////////
    reg  [ADR_WIDTH-1:0]    a_buf_readx8, a_buf_read;
    task RD_FUSE;                // Read efuse task
        begin
	    a_buf_readx8 = a_buf[ADR_R_WIDTH-1:0] <<< 3;
	    a_buf_read = a_buf_readx8/8;
            if (D[0]=== fuse_data[0             + a_buf_read] &&
                D[1]=== fuse_data[FUSE_SIZE/8*1 + a_buf_read] &&
                D[2]=== fuse_data[FUSE_SIZE/8*2 + a_buf_read] && 
                D[3]=== fuse_data[FUSE_SIZE/8*3 + a_buf_read] &&
                D[4]=== fuse_data[FUSE_SIZE/8*4 + a_buf_read] &&
                D[5]=== fuse_data[FUSE_SIZE/8*5 + a_buf_read] &&
                D[6]=== fuse_data[FUSE_SIZE/8*6 + a_buf_read] &&
                D[7]=== fuse_data[FUSE_SIZE/8*7 + a_buf_read])
                 d_change = 1'b0;
            else d_change = 1'b1;
        `ifdef NO_TIMING_OP
            #(`TSQ_H);
            d_nxt   = 8'bxxxxxxxx;
            #(`TSQ-`TSQ_H);
        `endif
            d_nxt[0]= fuse_data[0             + a_buf_read]; 
            d_nxt[1]= fuse_data[FUSE_SIZE/8*1 + a_buf_read];
            d_nxt[2]= fuse_data[FUSE_SIZE/8*2 + a_buf_read]; 
            d_nxt[3]= fuse_data[FUSE_SIZE/8*3 + a_buf_read];
            d_nxt[4]= fuse_data[FUSE_SIZE/8*4 + a_buf_read];
            d_nxt[5]= fuse_data[FUSE_SIZE/8*5 + a_buf_read];
            d_nxt[6]= fuse_data[FUSE_SIZE/8*6 + a_buf_read];
            d_nxt[7]= fuse_data[FUSE_SIZE/8*7 + a_buf_read];
        `ifdef NO_TIMING_OP
            $display("------------------------------------------------");
            $display("Info(@%0.3f ns): Efuse reads data at A (address)=%2d'h%h(%2d'd%d), read data=%2d'h%h(%2d'b%b);",
                $realtime,ADR_R_WIDTH,a_buf[ADR_R_WIDTH-1:0],ADR_R_WIDTH,a_buf[ADR_R_WIDTH-1:0],DAT_WIDTH,D,DAT_WIDTH,D);
        `else
            if (d_change) begin
                @(D); #0;
                if (efuse_sm==SM_IN_RD||efuse_sm==SM_RD_RDY) begin
                    $display("------------------------------------------------");
                    $display("Info(@%0.3f ns): Efuse reads data at A (address)=%2d'h%h(%2d'd%d), read data=%2d'h%h(%2d'b%b);",
                        $realtime,ADR_R_WIDTH,a_buf[ADR_R_WIDTH-1:0],ADR_R_WIDTH,a_buf[ADR_R_WIDTH-1:0],DAT_WIDTH,D,DAT_WIDTH,D);
                end
            end
            else begin
                #(`TSQ);
                if (efuse_sm==SM_IN_RD||efuse_sm==SM_RD_RDY) begin
                    $display("------------------------------------------------");
                    $display("Info(@%0.3f ns): Efuse reads data at A (address)=%2d'h%h(%2d'd%d), read data=%2d'h%h(%2d'b%b);",
                        $realtime,ADR_R_WIDTH,a_buf[ADR_R_WIDTH-1:0],ADR_R_WIDTH,a_buf[ADR_R_WIDTH-1:0],DAT_WIDTH,D,DAT_WIDTH,D);
                end
            end
        `endif
        end
    endtask
    ////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////
    task PGM_FUSE;                     // Program efuse task
        begin
            if (fuse_data[a_buf]===1'b0) begin
                $display("------------------------------------------------");
                $display("Info(@%0.3f ns): Efuse programming at A=%2d'h%h(%2d'd%d).",
                                           $realtime,ADR_WIDTH,a_buf,ADR_WIDTH,a_buf);
                fuse_data[a_buf] = 1'b1;
            end
            else 
            if (fuse_data[a_buf]===1'b1) begin
                $display("------------------------------------------------");
                $display("Errors!!!(@%0.3f ns): Efuse re-programming at A=%2d'h%h(%2d'd%d)!!!",
                                           $realtime,ADR_WIDTH,a_buf,ADR_WIDTH,a_buf);
                $display("    The bit at A=%2d'h%h(%2d'd%d) can already be damaged!!!",
                                        ADR_WIDTH,a_buf,ADR_WIDTH,a_buf);
                fuse_data[a_buf] = 1'bx;
                $display("    Please change A for programming!!!");
            end
            else
            if (fuse_data[a_buf]===1'bx) begin
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): Efuse is trying to program at A=%2d'h%h(%2d'd%d) where data is X.",
                                           $realtime,ADR_WIDTH,a_buf,ADR_WIDTH,a_buf);
                $display("    Data at A=%2d'h%h(%2d'd%d) is already damaged or not intitilized for the simulation.",
                                           ADR_WIDTH,a_buf,ADR_WIDTH,a_buf);
            end
            else if (fuse_data[a_buf] === 1'bz) begin
                $display("------------------------------------------------");
                $display("Error!!!(@%0.3f ns): Efuse is trying to program at A=%2d'h%h(%2d'd%d) where fuse data is Z.",
                                           $realtime,ADR_WIDTH,a_buf,ADR_WIDTH,a_buf);
                $display("    Data at A=%2d'h%h(%2d'd%d) is already damaged or not intitilized for the simulation.",
                                           ADR_WIDTH,a_buf,ADR_WIDTH,a_buf);
            end
        end
    endtask
    ////////////////////////////////////////////////////////
    task SET_FUSE_X;              // Set X to storage cells
        begin
            for(i=0;i<FUSE_SIZE;i=i+1) 
            fuse_data[i] = 1'bx;
        end
    endtask
    ////////////////////////////////////////////////////////
    task SET_D_X;                 // Set X to D
       begin
       d_nxt = 8'hxx;
       end
    endtask
    ////////////////////////////////////////////////////////
    task INIT_EFUSE;  // Initialize storage values for efuse
        begin
            for (i=0;i<FUSE_SIZE;i=i+1) 
            fuse_data[i] = 1'b0;
        end
    endtask
    ////////////////////////////////////////////////////////

    ///////////////////////////////////////
    // END of function task declaration 
    ///////////////////////////////////////


    ///////////////////////////////////////
    // Specify timing paths and constraints
    ///////////////////////////////////////
    
    `ifdef NO_TIMING_OP
        initial begin
            $display("------------------------------------------------");
            $display ("Info(@%0.3f ns): TIMING CHECK is disabled by the user ...",$realtime);
            $display("------------------------------------------------");
        end
    `else

    specify

        // Read mode check parameters

        specparam Trd            = `TRD;
        specparam Taen_r_min     = `TAEN_R_MIN;
        specparam Tsur_a         = `TSUR_A;
        specparam Thr_a          = `THR_A;
//      specparam Tsur_dvdd      = `TSUR_DVDD;
//      specparam Thr_dvdd       = `THR_DVDD;
        specparam Tsur_rd        = `TSUR_RD;
        specparam Thr_rd         = `THR_RD;
        specparam Tsq            = `TSQ;
        specparam Tsqh           = `TSQ_H;
        
        // Program mode check parameters

        specparam Tpgm_min       = `TPGM_MIN;
        specparam Taen_p_min     = `TAEN_P_MIN;
        specparam Tsup_a         = `TSUP_A;
        specparam Thp_a          = `THP_A;
        specparam Tsup_pgm       = `TSUP_PGM;
        specparam Thp_pgm        = `THP_PGM;
//      specparam Tsup_rd        = `TSUP_RD;
//      specparam Thp_rd         = `THP_RD;
        specparam Tsup_pg_avdd   = `TSUP_PG_AVDD;
        specparam Thp_pg_avdd    = `THP_PG_AVDD;

        // Timing violation checks 

        /////////////////////////
        // Read mode timing check
        /////////////////////////
        // AEN min width - minimum read pulse //
        $width(posedge AEN &&&  (rd_chk_en==1),    Trd, 0,  notify_r_trd);                     // TRD
        $period(posedge AEN &&& (rd_chk_en==1),    Taen_r_min, notify_r_taen_r_min);           // TAEN_R_MIN
        // Address to AEN timing check //
        $setup(posedge     A[0], posedge AEN &&& (rd_chk_en==1),    Tsur_a, notify_sur);       // TSUR_A
	$setup(posedge     A[4], posedge AEN &&& (rd_chk_en==1),    Tsur_a, notify_sur);
	$setup(posedge     A[3], posedge AEN &&& (rd_chk_en==1),    Tsur_a, notify_sur);
	$setup(posedge     A[2], posedge AEN &&& (rd_chk_en==1),    Tsur_a, notify_sur);
	$setup(posedge     A[1], posedge AEN &&& (rd_chk_en==1),    Tsur_a, notify_sur);
        $setup(negedge     A[0], posedge AEN &&& (rd_chk_en==1),    Tsur_a, notify_sur);       // TSUR_A
	$setup(negedge     A[4], posedge AEN &&& (rd_chk_en==1),    Tsur_a, notify_sur);
	$setup(negedge     A[3], posedge AEN &&& (rd_chk_en==1),    Tsur_a, notify_sur);
	$setup(negedge     A[2], posedge AEN &&& (rd_chk_en==1),    Tsur_a, notify_sur);
	$setup(negedge     A[1], posedge AEN &&& (rd_chk_en==1),    Tsur_a, notify_sur);
        $hold (negedge AEN &&& (rd_chk_en==1),  posedge A[0] ,      Thr_a, notify_hr);         // THR_A
	$hold (negedge AEN &&& (rd_chk_en==1),  posedge A[4] ,      Thr_a, notify_hr);
	$hold (negedge AEN &&& (rd_chk_en==1),  posedge A[3] ,      Thr_a, notify_hr);
	$hold (negedge AEN &&& (rd_chk_en==1),  posedge A[2] ,      Thr_a, notify_hr);
	$hold (negedge AEN &&& (rd_chk_en==1),  posedge A[1] ,      Thr_a, notify_hr);
        $hold (negedge AEN &&& (rd_chk_en==1),  negedge A[0] ,      Thr_a, notify_hr);         // THR_A
	$hold (negedge AEN &&& (rd_chk_en==1),  negedge A[4] ,      Thr_a, notify_hr);
	$hold (negedge AEN &&& (rd_chk_en==1),  negedge A[3] ,      Thr_a, notify_hr);
	$hold (negedge AEN &&& (rd_chk_en==1),  negedge A[2] ,      Thr_a, notify_hr);
	$hold (negedge AEN &&& (rd_chk_en==1),  negedge A[1] ,      Thr_a, notify_hr);
        

        // RDEN to AEN timing check //
        $setup(posedge RDEN, posedge AEN &&& (rd_chk_en==1),        Tsur_rd, notify_sur);      // TSUR_RD
        $hold (negedge AEN &&& (rd_chk_en==1), negedge RDEN,        Thr_rd,  notify_hr);       // THR_RD

        ////////////////////
        // AEN -> D delay //
        ////////////////////

        // rise,fall,0->Z,Z->1,1->Z,Z->0
        // 0->X,X->1,1->X,X->0,X->Z,Z->X

        if (rd_chk_en==1) (posedge AEN => (D[0]:AEN)) = (Tsq,Tsq,Tsqh,Tsq,Tsqh,Tsq,Tsqh,Tsq,Tsqh,Tsq,Tsqh,Tsqh);// TSQ
        if (rd_chk_en==1) (posedge AEN => (D[1]:AEN)) = (Tsq,Tsq,Tsqh,Tsq,Tsqh,Tsq,Tsqh,Tsq,Tsqh,Tsq,Tsqh,Tsqh);// TSQ
        if (rd_chk_en==1) (posedge AEN => (D[2]:AEN)) = (Tsq,Tsq,Tsqh,Tsq,Tsqh,Tsq,Tsqh,Tsq,Tsqh,Tsq,Tsqh,Tsqh);// TSQ
        if (rd_chk_en==1) (posedge AEN => (D[3]:AEN)) = (Tsq,Tsq,Tsqh,Tsq,Tsqh,Tsq,Tsqh,Tsq,Tsqh,Tsq,Tsqh,Tsqh);// TSQ
        if (rd_chk_en==1) (posedge AEN => (D[4]:AEN)) = (Tsq,Tsq,Tsqh,Tsq,Tsqh,Tsq,Tsqh,Tsq,Tsqh,Tsq,Tsqh,Tsqh);// TSQ
        if (rd_chk_en==1) (posedge AEN => (D[5]:AEN)) = (Tsq,Tsq,Tsqh,Tsq,Tsqh,Tsq,Tsqh,Tsq,Tsqh,Tsq,Tsqh,Tsqh);// TSQ
        if (rd_chk_en==1) (posedge AEN => (D[6]:AEN)) = (Tsq,Tsq,Tsqh,Tsq,Tsqh,Tsq,Tsqh,Tsq,Tsqh,Tsq,Tsqh,Tsqh);// TSQ
        if (rd_chk_en==1) (posedge AEN => (D[7]:AEN)) = (Tsq,Tsq,Tsqh,Tsq,Tsqh,Tsq,Tsqh,Tsq,Tsqh,Tsq,Tsqh,Tsqh);// TSQ

        /////////////////////////////
        // Program mode timing check 
        /////////////////////////////

        // AEN min width and cycle time check //
        $width(posedge AEN &&& (pgm_chk_en==1),    Tpgm_min, 0, notify_p_tpgm_min);            // TPGM_MIN
        $period(posedge AEN &&& (pgm_chk_en==1),   Taen_p_min, notify_p_taen_p_min);           // TAEN_P_MIN
        // Address to AEN timing check //
        $setup(posedge     A[0],  posedge AEN &&& (pgm_chk_en==1),   Tsup_a, notify_sup);      // TSUP_A
	$setup(posedge     A[7],  posedge AEN &&& (pgm_chk_en==1),   Tsup_a, notify_sup);
	$setup(posedge     A[6],  posedge AEN &&& (pgm_chk_en==1),   Tsup_a, notify_sup);
	$setup(posedge     A[5],  posedge AEN &&& (pgm_chk_en==1),   Tsup_a, notify_sup);
	$setup(posedge     A[4],  posedge AEN &&& (pgm_chk_en==1),   Tsup_a, notify_sup);
	$setup(posedge     A[3],  posedge AEN &&& (pgm_chk_en==1),   Tsup_a, notify_sup);
	$setup(posedge     A[2],  posedge AEN &&& (pgm_chk_en==1),   Tsup_a, notify_sup);
	$setup(posedge     A[1],  posedge AEN &&& (pgm_chk_en==1),   Tsup_a, notify_sup);
        $setup(negedge     A[0],  posedge AEN &&& (pgm_chk_en==1),   Tsup_a, notify_sup);      // TSUP_A
	$setup(negedge     A[7],  posedge AEN &&& (pgm_chk_en==1),   Tsup_a, notify_sup);
	$setup(negedge     A[6],  posedge AEN &&& (pgm_chk_en==1),   Tsup_a, notify_sup);
	$setup(negedge     A[5],  posedge AEN &&& (pgm_chk_en==1),   Tsup_a, notify_sup);
	$setup(negedge     A[4],  posedge AEN &&& (pgm_chk_en==1),   Tsup_a, notify_sup);
	$setup(negedge     A[3],  posedge AEN &&& (pgm_chk_en==1),   Tsup_a, notify_sup);
	$setup(negedge     A[2],  posedge AEN &&& (pgm_chk_en==1),   Tsup_a, notify_sup);
	$setup(negedge     A[1],  posedge AEN &&& (pgm_chk_en==1),   Tsup_a, notify_sup);
        $hold (negedge AEN &&& (pgm_chk_en==1),  posedge A[0]    ,   Thp_a, notify_hp);        // THP_A
	$hold (negedge AEN &&& (pgm_chk_en==1),  posedge A[7]    ,   Thp_a, notify_hp); 
	$hold (negedge AEN &&& (pgm_chk_en==1),  posedge A[6]    ,   Thp_a, notify_hp); 
	$hold (negedge AEN &&& (pgm_chk_en==1),  posedge A[5]    ,   Thp_a, notify_hp); 
	$hold (negedge AEN &&& (pgm_chk_en==1),  posedge A[4]    ,   Thp_a, notify_hp); 
	$hold (negedge AEN &&& (pgm_chk_en==1),  posedge A[3]    ,   Thp_a, notify_hp); 
	$hold (negedge AEN &&& (pgm_chk_en==1),  posedge A[2]    ,   Thp_a, notify_hp); 
	$hold (negedge AEN &&& (pgm_chk_en==1),  posedge A[1]    ,   Thp_a, notify_hp); 
        $hold (negedge AEN &&& (pgm_chk_en==1),  negedge A[0]    ,   Thp_a, notify_hp);        // THP_A
	$hold (negedge AEN &&& (pgm_chk_en==1),  negedge A[7]    ,   Thp_a, notify_hp); 
	$hold (negedge AEN &&& (pgm_chk_en==1),  negedge A[6]    ,   Thp_a, notify_hp); 
	$hold (negedge AEN &&& (pgm_chk_en==1),  negedge A[5]    ,   Thp_a, notify_hp); 
	$hold (negedge AEN &&& (pgm_chk_en==1),  negedge A[4]    ,   Thp_a, notify_hp); 
	$hold (negedge AEN &&& (pgm_chk_en==1),  negedge A[3]    ,   Thp_a, notify_hp); 
	$hold (negedge AEN &&& (pgm_chk_en==1),  negedge A[2]    ,   Thp_a, notify_hp); 
	$hold (negedge AEN &&& (pgm_chk_en==1),  negedge A[1]    ,   Thp_a, notify_hp); 
        
        // PGMEN to AEN timing check //
        $setup(posedge PGMEN,  posedge AEN &&& (pgm_chk_en==1),      Tsup_pgm,  notify_sup);   // TSUP_PGM
        $hold (negedge AEN &&& (pgm_chk_en==1), negedge PGMEN,       Thp_pgm,   notify_hp);    // THP_PGM
    endspecify
    `endif

endmodule
`endcelldefine

