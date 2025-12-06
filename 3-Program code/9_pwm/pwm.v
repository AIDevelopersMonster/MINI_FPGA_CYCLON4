//==============================================================
//  Project: MINI_FPGA_CYCLON4 — PWM Experiment
//  File: pwm.v
//  Description:
//      Top-level module for adjustable PWM generator.
//      Provides control of Duty (скважность) and Period (период PWM)
//      using onboard keys and displays status on 6-digit 7-segment LED.
//
//  Features:
//      - Adjust Duty (KEY3/KEY2)
//      - Adjust Period (KEY1/KEY0)
//      - Display Duty / Count_D / Count_P on digitron (SW1, SW2)
//      - PWM output to LED0 and EPI pin for oscilloscope
//
//  Inputs:
//      CLK               – 50 MHz clock
//      RSTn              – Global reset (active LOW) — SW0
//      AddDuty_In        – Increase Duty       — KEY3
//      SubDuty_In        – Decrease Duty       — KEY2
//      AddPeriod_In      – Increase Period     — KEY1
//      SubPeriod_In      – Decrease Period     — KEY0
//      Count_D_Display   – Show Count_D on 7-seg — SW1
//      Count_P_Display   – Show Count_P on 7-seg — SW2
//
//  Outputs:
//      Digitron_Out[7:0]    – segments a–g + dp
//      DigitronCS_Out[5:0]  – scan select for 6-digit display
//      PWM_LED_Out          – PWM signal to LED0
//      PWM_EPI_Out          – PWM signal to EPI/oscilloscope pin A6
//
//==============================================================

module pwm
(
    CLK, RSTn,
    AddDuty_In, SubDuty_In, AddPeriod_In, SubPeriod_In,
    Count_D_Display, Count_P_Display,
    Digitron_Out, DigitronCS_Out,
    PWM_LED_Out, PWM_EPI_Out
);

    input CLK;
    input RSTn;                     // SW0 — global reset, active low

    // --- PWM Adjustment inputs ---
    input AddDuty_In;               // KEY3: increase Duty
    input SubDuty_In;               // KEY2: decrease Duty
    input AddPeriod_In;             // KEY1: increase Period
    input SubPeriod_In;             // KEY0: decrease Period

    // --- Display mode switches ---
    input Count_D_Display;          // SW1: display Count_D
    input Count_P_Display;          // SW2: display Count_P

    // --- Outputs to 7-segment display ---
    output [7:0] Digitron_Out;
    output [5:0] DigitronCS_Out;

    // --- PWM outputs ---
    output PWM_LED_Out;             // LED0 shows duty by brightness
    output PWM_EPI_Out;             // Output to EPI (oscilloscope)

    // PWM_EPI_Out напрямую повторяет PWM_LED_Out
    assign PWM_EPI_Out = PWM_LED_Out;

    // Internal signals
    wire [7:0]  Duty;               // 0–255 duty cycle control
    wire [23:0] Count_P;            // PWM period in clock cycles
    wire [23:0] Count_D;            // PWM counter (current position)

    //==========================================================
    //  Module U1: Duty & Period Adjustment Logic
    //==========================================================
    Duty_Period_Adjust_module U1
    (
        .CLK( CLK ),
        .RSTn( RSTn ),
        .AddDuty_In( AddDuty_In ),
        .SubDuty_In( SubDuty_In ),
        .AddPeriod_In( AddPeriod_In ),
        .SubPeriod_In( SubPeriod_In ),
        .Duty( Duty ),              // to PWM generator and display
        .Count_P( Count_P )         // to PWM generator and display
    );

    //==========================================================
    //  Module U2: PWM Waveform Generator
    //==========================================================
    PWM_Generate_module U2
    (
        .CLK( CLK ),
        .RSTn( RSTn ),
        .Duty( Duty ),              // 0…255
        .Count_P( Count_P ),        // PWM period in cycles
        .PWM_Out( PWM_LED_Out ),    // output PWM to LED0
        .Count_D( Count_D )         // current position inside period
    );

    //==========================================================
    //  Module U3: 7-Segment Display Controller
    //==========================================================
    Digitron_NumDisplay_module U3
    (
        .CLK( CLK ),
        .RSTn( RSTn ),
        .Count_D_Display( Count_D_Display ),
        .Count_P_Display( Count_P_Display ),
        .Count_D( Count_D ),        // show duty cycle counter
        .Count_P( Count_P ),        // show full period value
        .Duty( Duty ),              // may display raw duty value
        .Digitron_Out( Digitron_Out ),
        .DigitronCS_Out( DigitronCS_Out )
    );

endmodule
