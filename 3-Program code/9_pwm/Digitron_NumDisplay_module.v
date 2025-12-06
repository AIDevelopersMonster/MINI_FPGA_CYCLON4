//==============================================================
//  Project: MINI_FPGA_CYCLON4 — PWM Experiment
//  File: Digitron_NumDisplay_module.v
//  Description:
//      6-digit 7-segment display controller.
//      Shows one of the following values depending on control inputs:
//          - Count_D  (when Count_D_Display = 1)
//          - Count_P  (when Count_P_Display = 1)
//          - Duty     (otherwise)
//
//      Display format:
//          - Count_D, Count_P: 6 hex nibbles (24 bits → 6×4)
//          - Duty: lower 2 digits (hex) show Duty[7:0],
//                  others show “blank” (_Wu).
//
//      Multiplexing:
//          - 6 digits are scanned in a ring by W_DigitronCS_Out
//          - Update period controlled by Cnt and T100MS
//
//  Inputs:
//      CLK              – system clock
//      RSTn             – asynchronous reset, active LOW
//      Count_D_Display  – when 1 → display Count_D
//      Count_P_Display  – when 1 → display Count_P
//      Count_D[23:0]    – PWM high-level threshold in clock cycles
//      Count_P[23:0]    – PWM period in clock cycles
//      Duty[7:0]        – PWM duty (interpreted as hex value)
//
//  Outputs:
//      Digitron_Out[7:0]    – segments (a–g + dp)
//      DigitronCS_Out[5:0]  – digit enables (active low)
//==============================================================

module Digitron_NumDisplay_module
(
    CLK, RSTn,
    Count_D_Display, Count_P_Display,
    Count_D, Count_P, Duty,
    Digitron_Out, DigitronCS_Out
);

    input CLK;
    input RSTn;

    input Count_D_Display;          // 1 → show Count_D
    input Count_P_Display;          // 1 → show Count_P
    input [23:0] Count_D;           // value of Count_D to display
    input [23:0] Count_P;           // value of Count_P to display
    input [7:0]  Duty;              // duty value to display (when no Count_* selected)

    output [7:0] Digitron_Out;      // segments a–g + dp
    output [5:0] DigitronCS_Out;    // digit select (active low)

    //==========================================================
    //  Multiplexing timer
    //  T100MS defines how many clock ticks between digit updates.
    //  Here it is just "200" abstract units (depends on CLK prescaling
    //  in surrounding design / simulation).
    //==========================================================
    parameter T100MS = 16'd200;

    reg [7:0] Cnt;                  // refresh counter
    reg [4:0] SingleNum;            // current hex digit (0..15), 5'b11111 → special pattern
    reg [7:0] W_Digitron_Out;       // registered segment data
    reg [7:0] W_DigitronCS_Out;     // registered digit select

    // 7-segment codes (common-cathode-like encoding):
    //     bit mapping: {dp, g, f, e, d, c, b, a}
    parameter _0  = 8'b0011_1111,
              _1  = 8'b0000_0110,
              _2  = 8'b0101_1011,
              _3  = 8'b0100_1111,
              _4  = 8'b0110_0110,
              _5  = 8'b0110_1101,
              _6  = 8'b0111_1101,
              _7  = 8'b0000_0111,
              _8  = 8'b0111_1111,
              _9  = 8'b0110_1111,
              _A  = 8'b0111_0111,
              _B  = 8'b0111_1100,
              _C  = 8'b0011_1001,
              _D  = 8'b0101_1110,
              _E  = 8'b0111_1001,
              _F  = 8'b0111_0001,
              _Wu = 8'b0100_0000;   // special pattern (e.g. dash or custom symbol)

    //==========================================================
    //  Digit scan and data selection
    //==========================================================
    always @ ( posedge CLK or negedge RSTn )
        begin
            if( !RSTn )
                begin
                    Cnt              <= 8'd0;
                    W_DigitronCS_Out <= 6'b11_1111;     // all digits off (active low)
                end
            else if( Cnt == T100MS )
                begin
                    // time to switch to next digit
                    Cnt <= 8'd0;

                    // rotate active digit (ring counter, active low bits)
                    W_DigitronCS_Out = {W_DigitronCS_Out[0], W_DigitronCS_Out[5:1]};

                    // if all digits are off – start from the first (LSB active low)
                    if( W_DigitronCS_Out == 6'b11_1111 )
                        W_DigitronCS_Out = 6'b11_1110;

                    //==================================================
                    //  Select which number to display
                    //==================================================
                    if( Count_D_Display == 1'b1 )
                        begin
                            // Display Count_D (24-bit) as 6 hex digits
                            case( W_DigitronCS_Out )
                                6'b11_1110: SingleNum = {1'b0, Count_D[3:0]};     // lowest digit
                                6'b11_1101: SingleNum = {1'b0, Count_D[7:4]};
                                6'b11_1011: SingleNum = {1'b0, Count_D[11:8]};
                                6'b11_0111: SingleNum = {1'b0, Count_D[15:12]};
                                6'b10_1111: SingleNum = {1'b0, Count_D[19:16]};
                                6'b01_1111: SingleNum = {1'b0, Count_D[23:20]};   // highest digit
                                default:    SingleNum = 5'b11111;
                            endcase
                        end
                    else if( Count_P_Display == 1'b1 )
                        begin
                            // Display Count_P (24-bit) as 6 hex digits
                            case( W_DigitronCS_Out )
                                6'b11_1110: SingleNum = {1'b0, Count_P[3:0]};
                                6'b11_1101: SingleNum = {1'b0, Count_P[7:4]};
                                6'b11_1011: SingleNum = {1'b0, Count_P[11:8]};
                                6'b11_0111: SingleNum = {1'b0, Count_P[15:12]};
                                6'b10_1111: SingleNum = {1'b0, Count_P[19:16]};
                                6'b01_1111: SingleNum = {1'b0, Count_P[23:20]};
                                default:    SingleNum = 5'b11111;
                            endcase
                        end
                    else
                        begin
                            // Display Duty (8-bit) only on the two lowest digits
                            case( W_DigitronCS_Out )
                                6'b11_1110: SingleNum = {1'b0, Duty[3:0]};    // low nibble
                                6'b11_1101: SingleNum = {1'b0, Duty[7:4]};    // high nibble
                                default:    SingleNum = 5'b11111;             // other digits: _Wu
                            endcase
                        end

                    //==================================================
                    //  Hex digit → 7-seg code
                    //==================================================
                    case( SingleNum )
                        0  : W_Digitron_Out = _0;
                        1  : W_Digitron_Out = _1;
                        2  : W_Digitron_Out = _2;
                        3  : W_Digitron_Out = _3;
                        4  : W_Digitron_Out = _4;
                        5  : W_Digitron_Out = _5;
                        6  : W_Digitron_Out = _6;
                        7  : W_Digitron_Out = _7;
                        8  : W_Digitron_Out = _8;
                        9  : W_Digitron_Out = _9;
                        10 : W_Digitron_Out = _A;
                        11 : W_Digitron_Out = _B;
                        12 : W_Digitron_Out = _C;
                        13 : W_Digitron_Out = _D;
                        14 : W_Digitron_Out = _E;
                        15 : W_Digitron_Out = _F;
                        default: W_Digitron_Out = _Wu;  // unknown / blank symbol
                    endcase
                end
            else
                begin
                    // wait until Cnt reaches T100MS
                    Cnt <= Cnt + 8'd1;
                end
        end

    //==========================================================
    //  Output assignments
    //==========================================================
    assign Digitron_Out    = W_Digitron_Out;
    assign DigitronCS_Out  = W_DigitronCS_Out;

endmodule
