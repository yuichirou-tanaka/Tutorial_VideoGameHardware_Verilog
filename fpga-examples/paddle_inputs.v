module paddles_top
(
    input wire [0:0] clk,
    input wire reset,
    output  wire    [0 : 0]     hsync,      // horizontal sync
    output  wire    [0 : 0]     vsync,      // vertical sync
    input hpaddle,
    input vpaddle,
    output [2:0] rgb
);
    wire display_on;
    wire [15:0] hpos;
    wire [15:0] vpos;

    reg [7:0] player_x;
    reg [7:0] player_y;

    reg [7:0] paddle_x;
    reg [7:0] paddle_y;

    always @(posedge hpaddle)
        paddle_x <= vpos[7:0];

    always @(posedge vpaddle)
        paddle_y <= vpos[7:0];

    always @(posedge vsync)
        begin
            player_x <= paddle_x;
            player_y <= paddle_y;
        end

    hvsync_generator hvsync_gen(
        .clk(clk),
        .reset(reset),
        .hsync(hsync),
        .vsync(vsync),
        .display_on(display_on),
        .hpos(hpos),
        .vpos(vpos)
    );


    wire h = hpos[7:0] >= paddle_x;
    wire v = vpos[7:0] >= paddle_y;

    assign rgb = {
        1'b0,
        display_on && h, 
        display_on && v
    };

endmodule