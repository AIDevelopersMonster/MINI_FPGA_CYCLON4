//=======================================================
// 8:1 Multiplexer (mux81) — top level
// Плата: MINI_FPGA (Cyclone IV)
// Назначение:
//   - Sw_In[2:0] — выбор одного из 8 каналов
//   - Key_In0..Key_In7 — входные данные (ширина параметризуется)
//   - LED_Out — выбранный выход
//   - CSn — сигнал разрешения (активный 0)
//=======================================================

module mux81
(
    CSn,
    Sw_In,
    Key_In0, Key_In1, Key_In2, Key_In3,
    Key_In4, Key_In5, Key_In6, Key_In7,
    LED_Out
);
    input           CSn;                 // Chip Select, активный низкий
    input  [2:0]    Sw_In;               // Линии выбора канала
    input  [width-1:0] Key_In0;          // Входной канал 0
    input  [width-1:0] Key_In1;          // Входной канал 1
    input  [width-1:0] Key_In2;          // Входной канал 2
    input  [width-1:0] Key_In3;          // Входной канал 3
    input  [width-1:0] Key_In4;          // Входной канал 4
    input  [width-1:0] Key_In5;          // Входной канал 5
    input  [width-1:0] Key_In6;          // Входной канал 6
    input  [width-1:0] Key_In7;          // Входной канал 7

    output [width-1:0] LED_Out;          // Выход мультиплексора

    // Параметр ширины данных: 1 бит по умолчанию
    parameter width = 1;

    // Экземпляр внутреннего модуля 8:1 mux
    mux81_module #(
        .width ( width )
    ) U1
    (
        .CSn ( CSn ),        // input  CSn_sig
        .A   ( Sw_In ),      // input [2:0] - селектор
        .D0  ( Key_In0 ),    // input [width-1:0] - канал 0
        .D1  ( Key_In1 ),    // input [width-1:0] - канал 1
        .D2  ( Key_In2 ),    // input [width-1:0] - канал 2
        .D3  ( Key_In3 ),    // input [width-1:0] - канал 3
        .D4  ( Key_In4 ),    // input [width-1:0] - канал 4
        .D5  ( Key_In5 ),    // input [width-1:0] - канал 5
        .D6  ( Key_In6 ),    // input [width-1:0] - канал 6
        .D7  ( Key_In7 ),    // input [width-1:0] - канал 7
        .Y   ( LED_Out )     // output [width-1:0] - выбранный канал
    );

endmodule
