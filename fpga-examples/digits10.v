module digits10_case(
    input wire [3:0] digit,
    input wire [2:0] yofs,
    output reg [4:0] bits
);
    wire [6:0] caseexpr = {digit, yofs};

    always @(*)
        case(caseexpr)
            7'o00: bits = 5'b11111;
            7'o01: bits = 5'b10001;
            7'o02: bits = 5'b10001;
            7'o03: bits = 5'b10001;
            7'o04: bits = 5'b11111;

            7'o10: bits = 5'b01100;
            7'o11: bits = 5'b00100;
            7'o12: bits = 5'b00100;
            7'o13: bits = 5'b00100;
            7'o14: bits = 5'b11111;

            7'o20: bits = 5'b11111;
            7'o21: bits = 5'b00001;
            7'o22: bits = 5'b11111;
            7'o23: bits = 5'b10000;
            7'o24: bits = 5'b11111;

            7'o30: bits = 5'b11111;
            7'o31: bits = 5'b00001;
            7'o32: bits = 5'b11111;
            7'o33: bits = 5'b00001;
            7'o34: bits = 5'b11111;

            7'o40: bits = 5'b10001;
            7'o41: bits = 5'b10001;
            7'o42: bits = 5'b11111;
            7'o43: bits = 5'b00001;
            7'o44: bits = 5'b00001;

            7'o50: bits = 5'b11111;
            7'o51: bits = 5'b10000;
            7'o52: bits = 5'b11111;
            7'o53: bits = 5'b00001;
            7'o54: bits = 5'b11111;

            7'o60: bits = 5'b11111;
            7'o61: bits = 5'b10000;
            7'o62: bits = 5'b11111;
            7'o63: bits = 5'b10001;
            7'o64: bits = 5'b11111;

            7'o70: bits = 5'b11111;
            7'o71: bits = 5'b00001;
            7'o72: bits = 5'b00001;
            7'o73: bits = 5'b00001;
            7'o74: bits = 5'b00001;

            7'o100: bits = 5'b11111;
            7'o101: bits = 5'b10001;
            7'o102: bits = 5'b11111;
            7'o103: bits = 5'b10001;
            7'o104: bits = 5'b11111;

            7'o110: bits = 5'b11111;
            7'o111: bits = 5'b10001;
            7'o112: bits = 5'b11111;
            7'o113: bits = 5'b00001;
            7'o114: bits = 5'b11111;

            default: bits = 0;
        endcase
endmodule

module digits10_array

(
    input wire [3:0] digit,
    input wire [2:0] yofs,
    output reg [4:0] bits
    /*
    The bits output contains the 5 pixels of the selected horizontal slice of the bitmap.
    ビット出力には、ビットマップの選択された水平スライスの5ピクセルが含まれます。

    This module takes the following inputs: 
    このモジュールは、次の入力を受け取ります。
    */
);
    /*******************************************************
    *               WIRE AND REG DECLARATION               *
    *******************************************************/
    wire    [24 : 0]    help_bits;
    reg     [24 : 0]    bitarray [9 : 0];   // ROM array (16 x 5 x 5 bits)
    /*******************************************************
    *                      ASSIGNMENT                      *
    *******************************************************/
    assign help_bits = digit <= 9 ? bitarray[ digit ] : 0;
    /*******************************************************
    *               OTHER COMB AND SEQ LOGIC               *
    *******************************************************/
    always @(*)
    begin
        bits = 5'b0;
        case( yofs )
            5'd0:   bits = help_bits[20 +: 5];
            5'd1:   bits = help_bits[15 +: 5];
            5'd2:   bits = help_bits[10 +: 5];
            5'd3:   bits = help_bits[5  +: 5];
            5'd4:   bits = help_bits[0  +: 5];
        endcase
    end

    initial
    begin
        $readmemb("digits10.hex",bitarray);
    end
endmodule 


module test_numbers_top
(
    input   wire    [0 : 0]     clk,    // clock
    input   wire    [0 : 0]     reset,  // reset
    output  wire    [0 : 0]     hsync,  // horizontal sync
    output  wire    [0 : 0]     vsync,  // vertical sync
    output  wire    [2 : 0]     rgb     // RGB
);
    /*******************************************************
    *               WIRE AND REG DECLARATION               *
    *******************************************************/
    // wires from hvsync generator
    wire    [0  : 0]    display_on;
    wire    [15 : 0]    hpos;
    wire    [15 : 0]    vpos;
    // 
    wire    [3  : 0]    digit;
    wire    [2  : 0]    xofs;
    wire    [2  : 0]    yofs;
    wire    [4  : 0]    bits;
    /*******************************************************
    *                      ASSIGNMENT                      *
    *******************************************************/
    assign digit = hpos[9 -: 4];
    assign xofs  = hpos[5 -: 3];
    assign yofs  = vpos[3 -: 3];
    assign rgb  =   {  
                        display_on && 0,
                        display_on && bits[xofs ^ 3'b111],
                        display_on && 0
                    };
    /*******************************************************
    *                   MODULE INSTANCES                   *
    *******************************************************/
    // creating one hvsync generator
    hvsync_generator 
    hvsync_gen
    (
        .clk        ( clk           ),
        .reset      ( reset         ),
        .hsync      ( hsync         ),
        .vsync      ( vsync         ),
        .display_on ( display_on    ),
        .hpos       ( hpos          ),
        .vpos       ( vpos          )
    );
    // creating one digits10_array
    digits10_array 
    numbers
    (
        .digit      ( digit         ),
        .yofs       ( yofs          ),
        .bits       ( bits          )
    );

endmodule // test_numbers_top
