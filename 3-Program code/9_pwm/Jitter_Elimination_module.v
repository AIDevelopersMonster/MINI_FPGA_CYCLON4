//==============================================================
//  Project: MINI_FPGA_CYCLON4 — PWM Experiment
//  File: Jitter_Elimination_module.v
//  Description:
//      Simple button de-bounce / edge-detect filter.
//
//      Works as a 2-stage synchronizer and falling-edge detector:
//          - Synchronizes Button_In to CLK domain
//          - Produces a single-clock pulse on Button_Out
//            when Button_In changes from 1 → 0
//
//      Usage:
//          Connect a mechanical button (active low or high)
//          and use this module to generate a clean one-shot pulse
//          on each key press/release (here: on 1→0 transition).
//
//  Inputs:
//      CLK         – system clock
//      RSTn        – asynchronous reset, active LOW
//      Button_In   – raw button signal (may be noisy)
//
//  Output:
//      Button_Out  – one-clock pulse when Button_In goes 1 → 0
//
//==============================================================

module Jitter_Elimination_module
(
    CLK, RSTn,
    Button_In, Button_Out
);

    input CLK;
    input RSTn;
    input Button_In;      // raw button input
    output Button_Out;    // one-shot pulse on falling edge

    // Two flip-flops for synchronization and edge detection
    reg neg1;
    reg neg2;

    //==========================================================
    //  Synchronize button to clock and store previous state
    //==========================================================
    always @ ( posedge CLK or negedge RSTn )
        if( !RSTn )
            begin
                neg1 <= 1'b1;       // assume idle state = '1'
                neg2 <= 1'b1;
            end
        else
            begin
                neg1 <= Button_In;  // current sampled value
                neg2 <= neg1;       // previous sampled value
            end

    //==========================================================
    //  Falling edge detection:
    //      Button_Out = 1 for one clock when:
    //          neg2 = 1  (previous state)
    //          neg1 = 0  (current state)
    //==========================================================
    assign Button_Out = ( neg2 & ~neg1 ) ? 1'b1 : 1'b0;
    // While Button_In goes from 1 to 0, Button_Out = 1 for one CLK

endmodule
