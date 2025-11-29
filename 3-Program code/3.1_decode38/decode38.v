// ============================================================
// Project: MINI_FPGA_CYCLON4
// File: decode38.v
// Description: Top-level wrapper for 3-to-8 decoder.
// Author: AIDevelopersMonster
// ============================================================

module decode38
(
    Sw_In, 
    LED_Out
);

    // ------------------------------
    // Порты верхнего уровня
    // ------------------------------
    input  wire [2:0] Sw_In;     // Три входных переключателя SW2..SW0
    output wire [7:0] LED_Out;   // Восемь выходных линий для светодиодов

    // ------------------------------
    // Подключение внутреннего модуля decode_module
    // ------------------------------
    decode_module U1
    (
        .a2( Sw_In[2] ),   // input  a2 — старший бит
        .a1( Sw_In[1] ),   // input  a1 — средний бит
        .a0( Sw_In[0] ),   // input  a0 — младший бит

        .y7( LED_Out[7] ), // output y7 — соответствует 111₂
        .y6( LED_Out[6] ), // output y6 — соответствует 110₂
        .y5( LED_Out[5] ), // output y5 — соответствует 101₂
        .y4( LED_Out[4] ), // output y4 — соответствует 100₂
        .y3( LED_Out[3] ), // output y3 — соответствует 011₂
        .y2( LED_Out[2] ), // output y2 — соответствует 010₂
        .y1( LED_Out[1] ), // output y1 — соответствует 001₂
        .y0( LED_Out[0] )  // output y0 — соответствует 000₂
    );

endmodule
