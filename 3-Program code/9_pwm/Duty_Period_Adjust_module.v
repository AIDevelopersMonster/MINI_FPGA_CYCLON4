//==============================================================
//  Project: MINI_FPGA_CYCLON4 — PWM Experiment
//  File: Duty_Period_Adjust_module.v
//  Description:
//      Duty and Period adjustment block for PWM generator.
//      Processes push-buttons with debounce and edge-detect,
//      then updates:
//          - Duty      (0–100 % with 10 % step)
//          - Count_P   (PWM period in clock cycles)
//
//  Buttons (after debouncing):
//      neg_AddDuty    – single pulse on KEY3 falling edge  (AddDuty_In)
//      neg_SubDuty    – single pulse on KEY2 falling edge  (SubDuty_In)
//      neg_AddPeriod  – single pulse on KEY1 falling edge  (AddPeriod_In)
//      neg_SubPeriod  – single pulse on KEY0 falling edge  (SubPeriod_In)
//
//  Duty behaviour:
//      - Range: 0 … 100 (interpreted as %)
//      - Step: 10
//      - Wrap around: 100 → 0, 0 → 100
//
//  Period behaviour (Count_P, 50 MHz clock):
//      Count_P =  50_000  →  T = 1 ms   →  f = 1000 Hz
//      Count_P = 250_000  →  T = 5 ms   →  f = 200 Hz (default)
//      Count_P = 500_000  →  T = 10 ms  →  f = 100 Hz
//      Step: 50_000, wrap between 50_000 and 500_000
//
//==============================================================

module Duty_Period_Adjust_module
(
    CLK, RSTn,
    AddDuty_In, SubDuty_In,
    AddPeriod_In, SubPeriod_In,
    Duty, Count_P
);

    input CLK;
    input RSTn;

    // Raw button inputs
    input AddDuty_In;       // Add Duty Ratio       (KEY3)
    input SubDuty_In;       // Subtract Duty Ratio  (KEY2)
    input AddPeriod_In;     // Add Period           (KEY1)
    input SubPeriod_In;     // Subtract Period      (KEY0)

    // Adjusted outputs
    output reg [7:0]  Duty;      // Duty Ratio of PWM (0–100, step 10)
    output reg [23:0] Count_P;   // Period of PWM in clk cycles (T = Count_P / 50_000_000)

    // One-shot pulses after debounce / edge-detect
    wire neg_AddDuty;
    wire neg_SubDuty;
    wire neg_AddPeriod;
    wire neg_SubPeriod;

    //==========================================================
    //  Debounce & edge-detect for buttons (active on 1→0)
    //==========================================================
    Jitter_Elimination_module U1
    (
        .CLK( CLK ),
        .RSTn( RSTn ),
        .Button_In( AddDuty_In ),       // While AddDuty_In from 1 to 0, neg_AddDuty = 1
        .Button_Out( neg_AddDuty )
    );

    Jitter_Elimination_module U2
    (
        .CLK( CLK ),
        .RSTn( RSTn ),
        .Button_In( SubDuty_In ),       // While SubDuty_In from 1 to 0, neg_SubDuty = 1
        .Button_Out( neg_SubDuty )
    );

    Jitter_Elimination_module U3
    (
        .CLK( CLK ),
        .RSTn( RSTn ),
        .Button_In( AddPeriod_In ),     // While AddPeriod_In from 1 to 0, neg_AddPeriod = 1
        .Button_Out( neg_AddPeriod )
    );

    Jitter_Elimination_module U4
    (
        .CLK( CLK ),
        .RSTn( RSTn ),
        .Button_In( SubPeriod_In ),     // While SubPeriod_In from 1 to 0, neg_SubPeriod = 1
        .Button_Out( neg_SubPeriod )
    );

    //==========================================================
    //  Duty adjustment logic (0–100 %, step 10, wrap around)
    //==========================================================
    always @ ( posedge CLK or negedge RSTn )
        begin
            if( !RSTn )
                Duty <= 8'd50;          // Default duty = 50 %
            else if( neg_AddDuty == 1'b1 )
                if( Duty == 8'd100 )
                    Duty <= 8'd0;       // Wrap 100 → 0
                else
                    Duty <= Duty + 8'd10;
            else if( neg_SubDuty == 1'b1 )
                if( Duty == 8'd0 )
                    Duty <= 8'd100;     // Wrap 0 → 100
                else
                    Duty <= Duty - 8'd10;
            else
                Duty <= Duty;           // Hold value
        end

    /*******************************************************
     *  Count_P vs PWM period and frequency (50 MHz clock):
     *
     *  Count_P = 500_000 → T = 10 ms,  f = 100 Hz
     *  Count_P = 250_000 → T = 5 ms,   f = 200 Hz (default)
     *  Count_P =  50_000 → T = 1 ms,   f = 1000 Hz
     *******************************************************/

    //==========================================================
    //  Period adjustment logic (Count_P: 50_000…500_000, step 50_000)
    //==========================================================
    always @ ( posedge CLK or negedge RSTn )
        begin
            if( !RSTn )
                Count_P <= 24'd250_000;             // Default period → 5 ms (200 Hz)
            else if( neg_AddPeriod == 1'b1 )
                begin
                    if( Count_P == 24'd500_000 )
                        Count_P <= 24'd50_000;      // Wrap 500_000 → 50_000
                    else
                        Count_P <= Count_P + 24'd50_000;
                end
            else if( neg_SubPeriod == 1'b1 )
                begin
                    if( Count_P == 24'd50_000 )
                        Count_P <= 24'd500_000;     // Wrap 50_000 → 500_000
                    else
                        Count_P <= Count_P - 24'd50_000;
                end
            else
                Count_P <= Count_P;                 // Hold value
        end

endmodule
