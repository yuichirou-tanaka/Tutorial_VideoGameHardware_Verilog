module switchs_top
(
    input wire [0:0] clk,
    input wire reset,
    output  wire    [0 : 0]     hsync,      // horizontal sync
    output  wire    [0 : 0]     vsync,      // vertical sync
    input [7:0] switches_p1,
    input [7:0] switches_p2,
    output [2:0] rgb
);
    wire display_on;
    wire [8:0] hpos;
    wire [8:0] vpos;

    hvsync_generator hvsync_gen(
        .clk(clk),
        .reset(reset),
        .hsync(hsync),
        .vsync(vsync),
        .display_on(display_on),
        .hpos(hpos),
        .vpos(vpos)
    );


    // select p1 bit based on vertical position
    wire p1gfx = switches_p1[vpos[7:5]];
    // select p2 bit based on horizontal position
    wire p2gfx = switches_p2[hpos[7:5]];

    assign rgb = {display_on && p2gfx, 
                display_on && p1gfx,
                1'b0};

endmodule