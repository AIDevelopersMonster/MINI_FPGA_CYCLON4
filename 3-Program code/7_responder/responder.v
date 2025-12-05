//=======================================================
//  Project      : MINI_FPGA_CYCLON4
//  File         : responder.v
//  Title        : 4-х канальный «Responder» с таймером
//  Description  : Верхний уровень системы быстрого ответа:
//                 - 4 игрока (кнопки / клавиши)
//                 - выбор первого нажавшего
//                 - обратный отсчёт времени ответа
//                 - звуковая индикация (правильный ответ / время вышло)
//                 - вывод номера игрока и таймера на динамическую индикацию
//
//  Inputs       : RSTn         — асинхронный сброс (SW0, активный низкий)
//                 CLK          — тактовый сигнал FPGA
//                 Start        — запуск раунда / разрешение ответа (SW1)
//                 Key_In[3:0]  — кнопки игроков 1…4
//
//  Outputs      : LED_Out[3:0]         — индикация активного игрока
//                 Buzzer_Out           — общий выход на буззер
//                 LED_OverTime_Out     — признак превышения времени (LED4)
//                 Digitron_Out[7:0]    — сегменты индикатора
//                 DigitronCS_Out[5:0]  — выбор разрядов индикатора
//
//  Submodules   : Sel_module                  — логика выбора игрока
//                 Timer_module                — таймер ответа
//                 Buzzer_module               — генерация звуковых сигналов
//                 Digitron_NumDisplay_module  — мультиплексная индикация
//
//=======================================================

module responder
(
    RSTn,
    CLK,
    Start,
    Key_In,
    LED_Out,
    Buzzer_Out,
    LED_OverTime_Out,
    Digitron_Out,
    DigitronCS_Out
);
    //----------- Порты верхнего уровня -----------------
    input  RSTn;              // SW0: глобальный сброс (активный 0)
    input  CLK;               // системный тактовый сигнал
    input  Start;             // SW1: старт нового раунда / разрешение ответов
    input  [3:0] Key_In;      // клавиши игроков: K1..K4

    output [3:0] LED_Out;         // светодиоды игроков (кто успел первым)
    output       Buzzer_Out;      // выход на буззер
    output       LED_OverTime_Out;// LED4: время истекло
    output [7:0] Digitron_Out;    // сегменты индикатора
    output [5:0] DigitronCS_Out;  // выбор разряда индикатора (динамическая индикация)

    //----------- Внутренние сигналы --------------------
    wire [3:0] Player_Number;     // номер игрока, который успел первым
    wire [3:0] TimerH;            // старший разряд таймера (десятки секунд / условная величина)
    wire [3:0] TimerL;            // младший разряд таймера (единицы)
    wire       Buzzer_Answer;     // импульс «есть ответ»
    wire       Buzzer_TimeOver;   // импульс «время вышло»
    wire       Timer_Start;       // запуск / сброс таймера

    //----------- Модуль выбора игрока ------------------
    Sel_module U1
    (
        .RSTn         ( RSTn          ),
        .CLK          ( CLK           ),
        .Start        ( Start         ),  // вход от SW1
        .K1           ( Key_In[0]     ),  // кнопка игрока 1
        .K2           ( Key_In[1]     ),  // кнопка игрока 2
        .K3           ( Key_In[2]     ),  // кнопка игрока 3
        .K4           ( Key_In[3]     ),  // кнопка игрока 4
        .LED_Out      ( LED_Out       ),  // индикация победившего игрока
        .Player_Number( Player_Number ),  // номер игрока для вывода на индикатор
        .Buzzer_Answer( Buzzer_Answer ),  // сигнал в буззер: «ответ принят»
        .Timer_Start  ( Timer_Start   )   // запуск таймера
    );

    //----------- Модуль таймера ответа -----------------
    Timer_module U2
    (
        .RSTn          ( RSTn              ),
        .CLK           ( CLK               ),
        .Timer_Start   ( Timer_Start       ),  // старт / сброс таймера
        .TimerH        ( TimerH            ),  // старший разряд времени
        .TimerL        ( TimerL            ),  // младший разряд времени
        .Buzzer_TimeOver( Buzzer_TimeOver  ),  // сигнал «время вышло» для буззера
        .LED_OverTime  ( LED_OverTime_Out  )   // индикация превышения времени
    );

    //----------- Модуль звуковой индикации -------------
    Buzzer_module U3
    (
        .CLK            ( CLK            ),
        .RSTn           ( RSTn           ),
        .Buzzer_Answer  ( Buzzer_Answer  ), // короткий сигнал при ответе
        .Buzzer_TimeOver( Buzzer_TimeOver), // другой тон при окончании времени
        .Buzzer_Out     ( Buzzer_Out     )  // общий выход на буззер
    );

    //----------- Модуль индикации на индикаторе --------
    Digitron_NumDisplay_module U4
    (
        .CLK            ( CLK            ),
        .Player_Number  ( Player_Number  ), // номер игрока
        .TimerH         ( TimerH         ), // старший разряд времени
        .TimerL         ( TimerL         ), // младший разряд времени
        .Digitron_Out   ( Digitron_Out   ),
        .DigitronCS_Out ( DigitronCS_Out )
    );

endmodule
