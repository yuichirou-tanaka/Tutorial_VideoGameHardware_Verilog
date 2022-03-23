module test_hvsync_top
(
    input wire [0:0] clk,
    input wire [0:0] reset,
    output wire [0:0] hsync,
    output wire [0:0] vsync,
    output wire [2:0] rgb
);
    /*******************************************************
    *               WIRE AND REG DECLARATION               *
    *******************************************************/
    wire    [0  : 0]    display_on;
    wire    [15 : 0]    hpos;
    wire    [15 : 0]    vpos;
    
endmodule