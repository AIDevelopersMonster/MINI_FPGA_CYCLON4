//=======================================================
// 8-to-3 Priority Encoder (Top Module)
// Project: MINI_FPGA_CYCLON4
// File: pencode83.v
// Description:
//   Верхний модуль, подключающий приоритетный 8-3 кодировщик.
//   На вход подаются переключатели SW_In[7:0],
//   работа осуществляется по тактовому сигналу CLK.
//   Результат — 3-битный код в LED_Out и флаг Valid.
//=======================================================

module pencode83
(
    CLK, Sw_In, LED_Out, Valid
);

    input        CLK;
    input  [7:0] Sw_In;
    output [2:0] LED_Out;
    output       Valid;

    //===================================================
    // Instantiate priority encoder module
    //===================================================
    pencode_module U1
    (
        .CLK   ( CLK    ),   // input  - clock
        .x     ( Sw_In  ),   // input  [7:0] — переключатели
        .y     ( LED_Out ),  // output [2:0] — код
        .Valid ( Valid  )    // output — признак корректного входа
    );

endmodule
 