//==============================================================
//  Project: MINI_FPGA_CYCLON4 — PWM Experiment
//  File: PWM_Generate_module.v
//  Description:
//      PWM waveform generator.
//      Uses a free-running counter (Cnt1) from 0 to Count_P-1 and
//      compares it with the threshold Count_D, computed from Duty.
//
//      Duty  : 0…100 (%) – задаёт скважность
//      Count_P : период PWM в тактовых циклах (T = Count_P / 50_000_000)
//
//      Формирование PWM:
//          Count_D = (Duty * Count_P) / 100
//          Пока Cnt1 <= Count_D  →  PWM_Out = 1
//          Иначе                →  PWM_Out = 0
//
//  Inputs:
//      CLK       – 50 MHz clock
//      RSTn      – global reset, active LOW
//      Duty      – duty ratio in percent (0…100)
//      Count_P   – PWM period (in clock cycles)
//
//  Outputs:
//      PWM_Out   – PWM signal
//      Count_D   – сравниваемый порог (кол-во тактов высокого уровня)
//==============================================================

module PWM_Generate_module
(
    CLK, RSTn,
    Duty, Count_P,
    PWM_Out, Count_D
);

    input CLK;
    input RSTn;
    input [7:0]  Duty;         // Duty in percent (0…100)
    input [23:0] Count_P;      // period = Count_P / 50_000_000 (сек.)

    output reg PWM_Out;        // PWM output signal
    output      [23:0] Count_D;// threshold for high-level duration

    // Внутренний счётчик периода PWM
    reg [23:0] Cnt1;

    //==========================================================
    //  Calculation of Count_D from Duty and Count_P
    //
    //  Count_D = Duty% of Count_P:
    //      Count_D = (Duty * Count_P) / 100
    //
    //  Примечание:
    //      Происходит усечение до 24 бит и целочисленное деление,
    //      для PWM это приемлемо (минимальная погрешность).
    //==========================================================
    assign Count_D = (Duty * Count_P) / 8'd100;

    //==========================================================
    //  Free-running counter: 0 … Count_P-1
    //==========================================================
    always @ ( posedge CLK or negedge RSTn )
        begin
            if( RSTn == 1'b0 )
                Cnt1 <= 24'd0;                         // Reset counter
            else if( Cnt1 == Count_P - 1'b1 )
                Cnt1 <= 24'd0;                         // Restart at end of period
            else
                Cnt1 <= Cnt1 + 24'd1;                  // Increment each clock
        end

    //==========================================================
    //  PWM output generation:
    //      While Cnt1 <= Count_D → PWM_Out = 1
    //      Else                  → PWM_Out = 0
    //==========================================================
    always @ ( * )
        begin
            if( Cnt1 <= Count_D )
                PWM_Out <= 1'b1;
            else
                PWM_Out <= 1'b0;
        end

endmodule
