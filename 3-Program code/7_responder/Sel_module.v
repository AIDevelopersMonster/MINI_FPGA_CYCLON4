//=======================================================
//  Project      : MINI_FPGA_CYCLON4
//  File         : Sel_module.v
//  Title        : Модуль выбора игрока (Responder, 4 игрока)
//  Description  : Фиксация первого нажатия из 4-х кнопок,
//                 выдача номера игрока и запуска таймера,
//                 формирование короткого сигнала для буззера.
//
//  Function     :
//    - При активном Start ждёт нажатия одной из кнопок K1..K4
//    - Фиксирует первого нажавшего (остальные игнорируются)
//    - Зажигает соответствующий светодиод в LED_Out
//    - Выдаёт номер игрока в Player_Number
//    - Формирует импульс Buzzer_Answer длительностью ~0.5 c
//      (при частоте CLK = 50 МГц)
//    - Формирует сигнал Timer_Start для запуска таймера
//
//  Inputs       :
//    RSTn   - асинхронный сброс, активный низким уровнем
//    CLK    - системный тактовый сигнал
//    Start  - разрешение раунда (когда = 1, можно отвечать)
//    K1..K4 - кнопки игроков (активный низкий уровень, !K = нажато)
//
//  Outputs      :
//    LED_Out[3:0]      - какой игрок успел первым (один бит = 1)
//    Player_Number[3:0]- номер игрока (1..4) для вывода на индикатор
//    Buzzer_Answer     - сигнал на буззер при принятии ответа
//    Timer_Start       - запуск таймера ответа
//
//=======================================================

module Sel_module
(
    RSTn,
    CLK,
    Start,
    K1,
    K2,
    K3,
    K4,
    LED_Out,
    Player_Number,
    Buzzer_Answer,
    Timer_Start
);

    //----------- Порты -------------------------------
    input        CLK;
    input        RSTn;
    input        Start;
    input        K1, K2, K3, K4;

    output reg [3:0] LED_Out;
    output reg [3:0] Player_Number;
    output reg       Buzzer_Answer;
    output reg       Timer_Start;

    //----------- Внутренние регистры -----------------
    reg        Block;          // Блокировка после первого нажатия
    reg [24:0] Count = 25'd0;  // Счётчик для формирования длительности Buzzer_Answer

    //=================================================
    // Основной процесс: сброс, выбор игрока,
    // формирование сигнала для буззера
    //=================================================
    always @ ( posedge CLK or negedge RSTn )
        begin
            if( !RSTn )
                begin
                    // Асинхронный сброс
                    LED_Out       <= 4'b0000;
                    Block         <= 1'b0;
                    Timer_Start   <= 1'b0;
                    Buzzer_Answer <= 1'b0;
                    Count         <= 25'd0;
                    Player_Number <= 4'd0;
                end
            else if( Start == 1'b1 )
                begin
                    // Разрешён новый раунд / приём ответов

                    // Если таймер уже запущен, формируем импульс Buzzer_Answer
                    if( Timer_Start )
                        begin
                            // Пока не досчитали до 24_999_999, держим Buzzer_Answer = 1
                            if( Count == 25'd24_999_999 )
                                begin
                                    Buzzer_Answer <= 1'b0;    // Закончить звуковой импульс
                                    Count         <= Count;   // Счётчик "заморожен"
                                end
                            else
                                begin
                                    Buzzer_Answer <= 1'b1;    // Импульс буззера активен
                                    Count         <= Count + 25'b1;
                                end
                        end
                    // Если таймер ещё не стартовал — ждём первого игрока
                    else if( !K1 && !Block )
                        begin
                            // Игрок 1
                            LED_Out       <= 4'b0001;
                            Block         <= 1'b1;     // Заблокировать остальные нажатия
                            Timer_Start   <= 1'b1;     // Старт таймера
                            Player_Number <= 4'd1;     // Номер игрока
                        end
                    else if( !K2 && !Block )
                        begin
                            // Игрок 2
                            LED_Out       <= 4'b0010;
                            Block         <= 1'b1;
                            Timer_Start   <= 1'b1;
                            Player_Number <= 4'd2;
                        end
                    else if( !K3 && !Block )
                        begin
                            // Игрок 3
                            LED_Out       <= 4'b0100;
                            Block         <= 1'b1;
                            Timer_Start   <= 1'b1;
                            Player_Number <= 4'd3;
                        end
                    else if( !K4 && !Block )
                        begin
                            // Игрок 4
                            LED_Out       <= 4'b1000;
                            Block         <= 1'b1;
                            Timer_Start   <= 1'b1;
                            Player_Number <= 4'd4;
                        end
                end
            // Если Start = 0, модуль просто "держит" текущее состояние
        end

endmodule
