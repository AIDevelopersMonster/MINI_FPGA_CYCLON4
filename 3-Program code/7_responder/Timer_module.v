//=======================================================
//  Project      : MINI_FPGA_CYCLON4
//  File         : Timer_module.v
//  Title        : Таймер обратного отсчёта для Responder
//  Description  : Формирует секундный тактовый сигнал, ведёт
//                 обратный отсчёт времени и выдаёт сигнал
//                 "время вышло" на буззер и светодиод.
//
//  Function     :
//    - Делитель частоты: CLK -> CLK1 (примерно 1 Гц при 50 МГц)
//    - Обратный отсчёт от 30 до 00 (формат TimerH:TimerL)
//    - При достижении 00 таймер останавливается
//    - На последней секунде (00:01) формируется сигнал
//      Buzzer_TimeOver и LED_OverTime (однократный импульс)
//
//  Inputs       :
//    RSTn         - асинхронный сброс (активный 0)
//    CLK          - тактовый сигнал (например, 50 МГц)
//    Timer_Start  - разрешение работы таймера
//
//  Outputs      :
//    TimerH[3:0]      - старший разряд таймера (десятки секунд)
//    TimerL[3:0]      - младший разряд таймера (единицы секунд)
//    Buzzer_TimeOver  - импульс на буззер при окончании времени
//    LED_OverTime     - индикация "время вышло"
//
//=======================================================

module Timer_module
(
    RSTn,
    CLK,
    Timer_Start,
    TimerH,
    TimerL,
    Buzzer_TimeOver,
    LED_OverTime
);

    input        RSTn;
    input        CLK;
    input        Timer_Start;

    output reg [3:0] TimerH;
    output reg [3:0] TimerL;
    output reg       Buzzer_TimeOver;
    output reg       LED_OverTime;

    // Делитель частоты до ~1 Гц (при 50 МГц)
    reg        count1 = 1'b0;
    reg        CLK1   = 1'b0;
    reg [24:0] Count  = 25'd0;
    parameter  T1S    = 25'd25_000_000;  // 0.5 с на полпериода CLK1

    //=================================================
    // Формирование CLK1: делитель частоты
    // Timer_Start используется как асинхронный сброс счётчика
    //=================================================
    always @ ( posedge CLK or negedge Timer_Start )
        begin
            if( !Timer_Start )
                Count <= 25'd0;
            else if( Count == T1S - 25'b1 )
                begin
                    Count <= 25'd0;
                    CLK1  <= ~CLK1;   // инвертируем CLK1 каждые T1S тактов
                end
            else
                Count <= Count + 25'd1;
        end

    //=================================================
    // Обратный отсчёт времени (формат MM:SS, тут 30..00)
    //=================================================
    always @ ( posedge CLK1 or negedge RSTn )
        begin
            if( !RSTn )
                begin
                    // Начальное значение таймера: 30 секунд
                    TimerH <= 4'd3;
                    TimerL <= 4'd0;
                end
            else if( Timer_Start == 1'b1 )
                begin
                    // Обратный отсчёт
                    if( TimerL == 4'd0 )
                        begin
                            if( TimerH == 4'd0 )
                                begin
                                    // Достигли 00 — держим это состояние
                                    TimerH <= TimerH;
                                    TimerL <= TimerL;
                                end
                            else
                                begin
                                    // Переход вида 10 -> 09, 20 -> 19 и т.д.
                                    TimerH <= TimerH - 1'b1;
                                    TimerL <= 4'd9;
                                end
                        end
                    else
                        begin
                            // Обычное декрементирование младшего разряда
                            TimerL <= TimerL - 1'b1;
                        end
                end
        end

    //=================================================
    // Сигнал "время вышло"
    // При TimerH:TimerL = 00:01 формируем импульс:
    //  - Buzzer_TimeOver = 1
    //  - LED_OverTime = 1
    // на один такт CLK1 (примерно 1 сек)
    //=================================================
    always @ ( posedge CLK1 )
        begin
            if( (TimerH == 4'd0) && (TimerL == 4'd1) )
                begin
                    if( count1 == 1'b1 )
                        begin
                            Buzzer_TimeOver <= 1'b0;
                            LED_OverTime    <= 1'b0;
                            count1          <= 1'b0;
                        end
                    else
                        begin
                            Buzzer_TimeOver <= 1'b1;
                            LED_OverTime    <= 1'b1;
                            count1          <= count1 + 1'b1;
                        end
                end
            else
                begin
                    Buzzer_TimeOver <= 1'b0;
                    LED_OverTime    <= 1'b0;
                    count1          <= 1'b0;
                end
        end

endmodule
