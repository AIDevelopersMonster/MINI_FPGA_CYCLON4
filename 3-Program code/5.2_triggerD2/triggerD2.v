//==============================================================
// MINI_FPGA_CYCLON4 — Trigger D (8-bit) Top Module
// File: triggerD2.v
// Description:
//     Верхний модуль для 8-битного D-триггера с асинхронными
//     входами Setn и Clrn. Передаёт входные данные Sw_In в
//     trigger_module, который выполняет логику D-триггера.
//
// Inputs:
//     CLK   — тактовый сигнал
//     Setn  — асинхронная установка (active-low)
//     Clrn  — асинхронный сброс   (active-low)
//     Sw_In — 8-битный вход D
//
// Output:
//     LED_Out — 8-битный выход Q
//
//==============================================================

module triggerD2
(
    CLK, Setn, Clrn, Sw_In, LED_Out
);

    input  wire        CLK;       // Clock
    input  wire        Setn;      // Async Set  (active-low)
    input  wire        Clrn;      // Async Clear(active-low)
    input  wire [7:0]  Sw_In;     // 8-bit D input
    output wire [7:0]  LED_Out;   // 8-bit Q output

    //==========================================================
    // Instantiate 8-bit trigger module
    //==========================================================
    trigger_module U1
    (
        .CLK ( CLK     ),   // input clk
        .Setn( Setn    ),   // async set
        .Clrn( Clrn    ),   // async clear
        .D   ( Sw_In   ),   // 8-bit input data
        .Q   ( LED_Out )    // 8-bit output data
    );

endmodule
