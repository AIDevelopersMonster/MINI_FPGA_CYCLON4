//==============================================================
// MINI_FPGA_CYCLON4 — 8-bit D Flip-Flop With Async Set/Clear
// File: trigger_module.v
//
// Description:
//     8-битный D-триггер с асинхронными входами Setn и Clrn.
//     При активном низком Setn — Q принудительно устанавливается в 1.
//     При активном низком Clrn — Q принудительно сбрасывается в 0.
//     При положительном фронте CLK — Q принимает значение D.
//
// Inputs:
//     CLK   — тактовый сигнал
//     Setn  — асинхронная установка (active-low)
//     Clrn  — асинхронный сброс    (active-low)
//     D[7:0] — 8-битная входная шина
//
// Output:
//     Q[7:0] — 8-битное состояние триггера
//
// Логика:
//     If (!Setn)  Q <= 8'b11111111;   // асинхронная установка
//     Else if (!Clrn) Q <= 8'b00000000; // асинхронный сброс
//     Else (posedge CLK) Q <= D;
//
//==============================================================

module trigger_module
(
    CLK, Setn, Clrn, D, Q
);

    input  wire       CLK;      // Clock
    input  wire       Setn;     // Active-low async set
    input  wire       Clrn;     // Active-low async clear
    input  wire [7:0] D;        // Data input
    output reg  [7:0] Q;        // Data output

    //==========================================================
    // 8-bit D Flip-Flop with async Setn and Clrn
    //==========================================================
    always @(posedge CLK or negedge Setn or negedge Clrn)
    begin
        if (!Setn)
            Q <= 8'hFF;            // Асинхронная установка (все 1)
        else if (!Clrn)
            Q <= 8'h00;            // Асинхронный сброс (все 0)
        else
            Q <= D;                // Захват входного значения на фронте CLK
    end

endmodule
