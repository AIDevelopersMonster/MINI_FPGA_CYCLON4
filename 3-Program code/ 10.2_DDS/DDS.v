// =======================================================
// Project    : MINI_FPGA_CYCLONE4
// Module     : DDS
// Function   : Цифровой синтезатор частоты (DDS) с выбором формы
//              сигнала и регулировкой частоты.
// Device     : Cyclone IV
// -------------------------------------------------------
// Управление:
//   RSTn          (SW0)  – общий сброс (активный 0)
//   KW_Add_In     (KEY0) – увеличить управляющее слово частоты (KW)
//   KW_Sub_In     (KEY1) – уменьшить управляющее слово частоты (KW)
//   SW_Sin_In     (SW1)  – выбрать синус
//   SW_Square_In  (SW2)  – выбрать меандр
//   SW_Sawtooth_In(SW3)  – выбрать пилообразный сигнал
//
// Выходы:
//   DA_CLK        – тактовый сигнал для внешнего ЦАП/DA-платы
//   DA_Data[7:0]  – 8-битные цифровые данные, кодирующие форму волны
//
// Внутренние блоки:
//   U1 – frequency_adjust_module  : формирует 12-битное KW (управляющее слово частоты)
//   U2 – choose_wave_module       : по KW и выбору формы генерирует Wave_Data[7:0]
//   U3 – dac_module               : выдает DA_CLK и передает Wave_Data в DA_Data
// =======================================================

module DDS
(
	CLK, RSTn,
	KW_Add_In, KW_Sub_In,
	SW_Sin_In, SW_Square_In, SW_Sawtooth_In,
	DA_CLK, DA_Data
);

	 input CLK;               // Системный тактовый сигнал FPGA
	 input RSTn;              // Глобальный сброс (активный ноль), SW0

	 input KW_Add_In;         // Увеличить частоту (KEY0)
	 input KW_Sub_In;         // Уменьшить частоту (KEY1)

	 input SW_Sin_In;         // Выбор синусоиды (SW1)
	 input SW_Square_In;      // Выбор меандра (SW2)
	 input SW_Sawtooth_In;    // Выбор пилообразной формы (SW3)
	 
	 output DA_CLK;           // Тактовый сигнал для DA-платы/ЦАП
	 output [7:0]DA_Data;     // Цифровые данные на вход ЦАП
	 
	 // KW – управляющее слово частоты (частотный коэффициент DDS)
	 wire [11:0]KW;

	 // Wave_Data – 8-битные выборки сформированной волны
	 wire [7:0]Wave_Data;
	 
	// ---------------------------------------------------
	// U1: Регулировка частоты – формирует управляющее слово KW
	// ---------------------------------------------------
	frequency_adjust_module U1
	(
		.CLK       ( CLK      ),
		.RSTn      ( RSTn     ),
		.KW_Add_In ( KW_Add_In ),   // input - from top
		.KW_Sub_In ( KW_Sub_In ),   // input - from top
		.KW        ( KW      )      // output - to U2
	);

	// ---------------------------------------------------
	// U2: Выбор формы волны – по KW и переключателям формирует Wave_Data
	// ---------------------------------------------------
	choose_wave_module U2
	(
		.CLK           ( CLK          ),
		.RSTn          ( RSTn         ),
		.SW_Sin_In     ( SW_Sin_In    ),   // input - from top
		.SW_Square_In  ( SW_Square_In ),   // input - from top
		.SW_Sawtooth_In( SW_Sawtooth_In ), // input - from top
		.KW            ( KW           ),   // input - from U1
		.Wave_Data     ( Wave_Data    )    // output - to U3
	);

	// ---------------------------------------------------
	// U3: Интерфейс с ЦАП – формирует DA_CLK и подает данные на ЦАП
	// ---------------------------------------------------
	dac_module U3
	(
		.CLK        ( CLK       ),
		.Wave_Data  ( Wave_Data ),   // input - from U2
		.DA_CLK     ( DA_CLK    ),   // output - to top
		.DA_Data_Out( DA_Data   )    // output - to top
	);

endmodule
