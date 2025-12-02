//=======================================================
// 8:1 Multiplexer Core (mux81_module)
// Плата: MINI_FPGA (Cyclone IV)
// Назначение:
//   Параметризуемый мультиплексор 8→1
//   - width — разрядность данных (по умолчанию 1 бит)
//   - CSn — сигнал разрешения (активный 0)
//   - A[2:0] — выбор канала
//   - D0..D7 — входные данные
//   - Y — выход
//
// Принцип работы:
//   При CSn = 0 мультиплексор выбирает один из входов D0..D7.
//   При CSn = 1 выход Y принудительно сбрасывается в 0.
//=======================================================

module mux81_module
(
    CSn, A,
    D0, D1, D2, D3, D4, D5, D6, D7,
    Y
);

    input            CSn;                    // Chip Select (active low)
    input      [2:0] A;                      // Selector 0..7
    input  [width-1:0] D0;                   // Channel 0
    input  [width-1:0] D1;                   // Channel 1
    input  [width-1:0] D2;                   // Channel 2
    input  [width-1:0] D3;                   // Channel 3
    input  [width-1:0] D4;                   // Channel 4
    input  [width-1:0] D5;                   // Channel 5
    input  [width-1:0] D6;                   // Channel 6
    input  [width-1:0] D7;                   // Channel 7

    output reg [width-1:0] Y;                // Multiplexer output

    // Параметр ширины данных
    parameter width = 1;

    // Мультиплексор 8 к 1
    always @(*) begin
        if (!CSn) begin                      // While CSn = 0, mux81 works
            case (A)
                3'b000: Y <= D0;
                3'b001: Y <= D1;
                3'b010: Y <= D2;
                3'b011: Y <= D3;
                3'b100: Y <= D4;
                3'b101: Y <= D5;
                3'b110: Y <= D6;
                3'b111: Y <= D7;
            endcase
        end
        else begin
            Y <= 0;                           // While CSn = 1, output reset
        end
    end

endmodule
