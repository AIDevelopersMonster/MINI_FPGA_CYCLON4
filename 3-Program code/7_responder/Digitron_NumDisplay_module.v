//=======================================================
//  Project      : MINI_FPGA_CYCLON4
//  File         : Digitron_NumDisplay_module.v
//  Title        : Модуль динамической индикации (Responder)
//  Description  : Мультиплексная индикация на семисегментных индикаторах.
//                 Отображает:
//                   - младший разряд таймера (TimerL)
//                   - старший разряд таймера (TimerH)
//                   - номер игрока (Player_Number)
//
//  Function     :
//    - Перебирает активные разряды индикатора с частотой, заданной T250K
//    - В зависимости от активного разряда выбирает одно из чисел:
//         TimerL / TimerH / Player_Number
//    - По коду числа формирует шаблон сегментов (0–9)
//
//  Inputs       :
//    CLK            - тактовый сигнал
//    Player_Number  - номер игрока (от 0 до 9, реально 1..4)
//    TimerH         - старший разряд таймера (0..9)
//    TimerL         - младший разряд таймера (0..9)
//
//  Outputs      :
//    Digitron_Out[7:0]   - выходы сегментов (a,b,c,d,e,f,g,dp)
//    DigitronCS_Out[5:0] - выбор разряда индикатора (активный 0/1 — см. разводку платы)
//
//=======================================================

module Digitron_NumDisplay_module
(
    CLK,
    Player_Number,
    TimerH,
    TimerL,
    Digitron_Out,
    DigitronCS_Out
);

    input        CLK;
    input [3:0]  Player_Number;
    input [3:0]  TimerH;
    input [3:0]  TimerL;
    output [7:0] Digitron_Out;
    output [5:0] DigitronCS_Out;

    // Период переключения разрядов (условно ~T250K, название из исходника)
    parameter T250K = 16'd200;

    reg [15:0] Count;               // счётчик для временной задержки
    reg [3:0]  SingleNum;           // текущее отображаемое число (0..9)
    reg [7:0]  W_Digitron_Out;      // буфер для сегментов
    reg [7:0]  W_DigitronCS_Out;    // буфер выбора разрядов (используем младшие 6 бит)

    // Шаблоны вывода цифр 0–9 (a..g,dp)
    parameter _0 = 8'b0011_1111,
              _1 = 8'b0000_0110,
              _2 = 8'b0101_1011,
              _3 = 8'b0100_1111,
              _4 = 8'b0110_0110,
              _5 = 8'b0110_1101,
              _6 = 8'b0111_1101,
              _7 = 8'b0000_0111,
              _8 = 8'b0111_1111,
              _9 = 8'b0110_1111;

    //=================================================
    // Мультиплексная индикация:
    //  - счётчик Count задаёт частоту переключения разрядов
    //  - W_DigitronCS_Out «бегает» по нужным разрядам
    //  - по активному разряду выбираем одно из чисел:
    //      TimerL, TimerH, Player_Number
    //=================================================
    always @ ( posedge CLK )
        begin
            if( Count == T250K )
                begin
                    Count <= 16'd0;

                    // Циклический сдвиг разрядов (используем младшие 3 бита)
                    // {3'b111, X, Y[2:1]} — верхние 3 разряда всегда "отключены"
                    W_DigitronCS_Out <= {3'b111, W_DigitronCS_Out[0], W_DigitronCS_Out[2:1]};

                    // Если попали в "лишнюю" комбинацию — перескакиваем на первый используемый разряд
                    if( W_DigitronCS_Out == 8'b00_111000 )
                        W_DigitronCS_Out <= 8'b00_111110; // 6'b11_1110 на младших 6 битах

                    // Выбор, что показываем на текущем разряде:
                    //  11_1110 — TimerL
                    //  11_1101 — TimerH
                    //  11_1011 — Player_Number
                    case( W_DigitronCS_Out[5:0] )
                        6'b11_1110: SingleNum <= TimerL;        // младший разряд времени
                        6'b11_1101: SingleNum <= TimerH;        // старший разряд времени
                        6'b11_1011: SingleNum <= Player_Number; // номер игрока
                        default:    SingleNum <= 4'd0;
                    endcase

                    // Кодирование цифры в шаблон сегментов
                    case( SingleNum )
                        4'd0: W_Digitron_Out <= _0;
                        4'd1: W_Digitron_Out <= _1;
                        4'd2: W_Digitron_Out <= _2;
                        4'd3: W_Digitron_Out <= _3;
                        4'd4: W_Digitron_Out <= _4;
                        4'd5: W_Digitron_Out <= _5;
                        4'd6: W_Digitron_Out <= _6;
                        4'd7: W_Digitron_Out <= _7;
                        4'd8: W_Digitron_Out <= _8;
                        4'd9: W_Digitron_Out <= _9;
                        default: W_Digitron_Out <= 8'b0000_0000;
                    endcase
                end
            else
                Count <= Count + 16'd1;
        end

    // Выводы на верхний уровень
    assign Digitron_Out   = W_Digitron_Out;
    assign DigitronCS_Out = W_DigitronCS_Out[5:0];

endmodule
