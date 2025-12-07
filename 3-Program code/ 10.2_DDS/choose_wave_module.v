// =======================================================
// Project    : MINI_FPGA_CYCLONE4
// Module     : choose_wave_module
// Function   : Генерация выбранной формы сигнала DDS
//              (синус / меандр / пила) по управляющему
//              слову частоты KW.
// Device     : Cyclone IV
// -------------------------------------------------------
// Описание:
//   - Внутри используется 12-битный фазовый аккумулятор Cnt.
//   - На каждом такте к Cnt прибавляется управляющее слово KW.
//   - Старшие 12 бит (в данном случае весь Cnt) идут как адрес
//     в три ПЗУ с предрассчитанными формами волн:
//       * dds_sin_rom      – синус
//       * dds_square_rom   – меандр
//       * dds_sawtooth_rom – пилообразный сигнал
//   - По состоянию переключателей SW_Sin_In / SW_Square_In / SW_Sawtooth_In
//     выбирается одна из трех форм, которая выдаётся на Wave_Data[7:0].
//
// Важные моменты:
//   * Частота выходного сигнала ~ пропорциональна KW.
//   * При переполнении Cnt происходит "оборачивание" по модулю 4096.
//   * При нескольких активных переключателях приоритет по коду:
//       SW_Sin_In > SW_Square_In > SW_Sawtooth_In.
// -------------------------------------------------------
// Порты:
//   CLK            – системный такт
//   RSTn           – асинхронный сброс (активный 0)
//   SW_Sin_In      – выбрать синус
//   SW_Square_In   – выбрать меандр
//   SW_Sawtooth_In – выбрать пилообразную форму
//   KW[11:0]       – управляющее слово частоты (из frequency_adjust_module)
//   Wave_Data[7:0] – выборки выбранной формы сигнала
// =======================================================

module choose_wave_module
(
	CLK,
	RSTn,
	SW_Sin_In,
	SW_Square_In,
	SW_Sawtooth_In,
	KW,
	Wave_Data
);

	 input CLK;
	 input RSTn;

	 input SW_Sin_In;        // Выбор синусоиды
	 input SW_Square_In;     // Выбор меандра
	 input SW_Sawtooth_In;   // Выбор пилы

	 input  [11:0]KW;        // Управляющее слово частоты
	 output [7:0]Wave_Data;  // Выходные данные выбранной волны

	 // Фазовый аккумулятор DDS (12 бит)
	 reg  [11:0]Cnt;
	 wire [11:0]addr;

	// ---------------------------------------------------
	// Фазовый накопитель:
	//   Cnt = Cnt + KW (с оборачиванием по модулю 4096)
	// ---------------------------------------------------
	always @ ( posedge CLK or negedge RSTn )
		begin
			if( !RSTn ) 
				Cnt <= 12'd0;               // Сброс фазы
			else if( Cnt == 12'd4095 )
				Cnt <= 12'd0;               // Обнуление при достижении максимума
			else	
				Cnt <= Cnt + KW;            // Инкремент фазы с шагом KW
		end
		
	assign addr = Cnt;                       // Адрес в ПЗУ форм волн

	// ---------------------------------------------------
	// Выходы из ПЗУ с разными формами волн
	// ---------------------------------------------------
	 wire [7:0]Sin_Out;	
	 wire [7:0]Square_Out;	
	 wire [7:0]Sawtooth_Out;	
	 reg  [7:0]Wave_Out_r;
	 
	// ROM с таблицей синуса
	dds_sin_rom	Sin_Rom
	(
		.address ( addr ),	// input - from фазового аккумулятора
		.clock   ( CLK  ),	// input - системный такт
		.q       ( Sin_Out )// output - выборка синуса
	);
		
	// ROM с таблицей меандра
	dds_square_rom	Square_Rom
   (
		.address ( addr ),	    // input - общий адрес
		.clock   ( CLK  ),	    // input - такт
		.q       ( Square_Out )	// output - выборка меандра
	);	
	
	// ROM с таблицей пилообразного сигнала
	dds_sawtooth_rom	Sawtooth_Rom 
	(
		.address ( addr ),	    // input - общий адрес
		.clock   ( CLK  ),	    // input - такт
		.q       ( Sawtooth_Out )// output - выборка пилы
	);

	// ---------------------------------------------------
	// Выбор формы сигнала по состоянию переключателей
	// Приоритет: Sin > Square > Sawtooth
	// ---------------------------------------------------
	always @ ( posedge CLK or negedge RSTn )
		begin
			if( !RSTn )
				Wave_Out_r <= 8'd0;
			else if( SW_Sin_In == 1 )
				begin
					Wave_Out_r <= Sin_Out;
				end
			else if( SW_Square_In == 1 )
				begin
					Wave_Out_r <= Square_Out;	
				end
			else if( SW_Sawtooth_In == 1 )
				begin
					Wave_Out_r <= Sawtooth_Out;	
				end
			else
				Wave_Out_r <= 8'd0;          // Ничего не выбрано – ноль
		end
		
	assign Wave_Data = Wave_Out_r;
				
endmodule
