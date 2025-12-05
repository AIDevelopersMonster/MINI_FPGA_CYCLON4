//=======================================================
//  Project      : MINI_FPGA_CYCLON4
//  File         : Buzzer_module.v
//  Title        : Звуковая индикация для Responder
//  Description  : Формирует два разных тона на буззере:
//                 - тон "ответ принят" (Buzzer_Answer)
//                 - тон "время вышло" (Buzzer_TimeOver)
//
//  Function     :
//    - В зависимости от активного входа выбирает частоту
//      (через делитель на счётчике):
//         Buzzer_Answer   -> частота _Answer
//         Buzzer_TimeOver -> частота _TimeOver
//    - Если ни один сигнал не активен — буззер выключен.
//
//  Inputs       :
//    CLK             - системный тактовый сигнал
//    RSTn            - (не используется в логике, можно задействовать при доработке)
//    Buzzer_Answer   - сигнал "ответ принят"
//    Buzzer_TimeOver - сигнал "время вышло"
//
//  Output       :
//    Buzzer_Out      - выход на буззер
//
//  Notes        :
//    - Параметры _Answer и _TimeOver задают период счётчика,
//      от которого зависит частота выхода.
//    - При одновременной активизации Buzzer_Answer и Buzzer_TimeOver
//      приоритет имеет Buzzer_Answer (он проверяется первым).
//
//=======================================================

module Buzzer_module
(
    CLK,
    RSTn,
    Buzzer_Answer,
    Buzzer_TimeOver,
    Buzzer_Out
);

    input CLK;
    input RSTn;
    input Buzzer_Answer;
    input Buzzer_TimeOver;
    output Buzzer_Out;

    // Делители для разных звуковых тонов
    parameter _Answer   = 17'd95419;
    parameter _TimeOver = 17'd50607;

    reg [22:0] Count;
    reg [22:0] Pulse_x;
    reg        W_buzzer;

    //=================================================
    // Выбор частоты в зависимости от режима:
    //   - ответ принят -> _Answer
    //   - время вышло  -> _TimeOver
    //   - иначе        -> "молчание"
    //=================================================
    always @ ( posedge CLK )
        begin
            if( Buzzer_Answer == 1'b1 )
                Pulse_x <= _Answer;
            else if( Buzzer_TimeOver == 1'b1 )
                Pulse_x <= _TimeOver;
            else
                Pulse_x <= 23'd20000;   // "глушим" звук (Count не доходит до нужного значения)
        end

    //=================================================
    // Делитель частоты для формирования меандра на буззере
    //=================================================
    always @ ( posedge CLK )
        begin
            // Если выбран один из "рабочих" делителей (_Answer или _TimeOver)
            if( (Pulse_x == _Answer) || (Pulse_x == _TimeOver) )
                begin
                    if( Count == Pulse_x )
                        begin
                            Count    <= 23'd0;
                            W_buzzer <= ~W_buzzer;   // инверсия — формирование меандра
                        end
                    else
                        Count <= Count + 23'd1;
                end
            else
                begin
                    // Режим "тишины"
                    W_buzzer <= 1'b1;   // устойчивый уровень (по факту — нет смены)
                    Count    <= 23'd0;
                end
        end

    assign Buzzer_Out = W_buzzer;

endmodule
