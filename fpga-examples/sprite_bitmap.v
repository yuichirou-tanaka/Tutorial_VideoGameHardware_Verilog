module car_bitmap(
    input wire [2:0] yofs,
    output wire [7:0] bits
);
    reg [7:0] bitarray[0:15];

    assign bits = bitarray[yofs];

    initial begin
        bitarray[0] = 8'b0;
        bitarray[1] = 8'b1100;
        bitarray[2] = 8'b11001100;
        bitarray[3] = 8'b11111100;
        bitarray[4] = 8'b11101100;
        bitarray[5] = 8'b11100000;
        bitarray[6] = 8'b1100000;
        bitarray[7] = 8'b1110000;
        bitarray[8] = 8'b110000;
        bitarray[9] = 8'b110000;
        bitarray[10] = 8'b110000;
        bitarray[11] = 8'b1101110;
        bitarray[12] = 8'b11101110;
        bitarray[13] = 8'b11111110;
        bitarray[14] = 8'b11101110;
        bitarray[15] = 8'b101110;
    end

endmodule

module sprite_bitmap_top
(
    input wire [0:0] clk,
    input wire reset,
    output  wire    [0 : 0]     hsync,      // horizontal sync
    output  wire    [0 : 0]     vsync,      // vertical sync
    output [2:0] rgb
);
    wire display_on;
    wire [15:0] hpos;
    wire [15:0] vpos;

    reg sprite_active;
    reg [3:0] car_sprite_xofs;
    reg [3:0] car_sprite_yofs;
    wire [7:0] car_sprite_bits;

    reg [8:0] player_x = 128;
    reg [8:0] player_y = 128;

    hvsync_generator hvsync_gen(
        .clk(clk),
        .reset(reset),
        .hsync(hsync),
        .vsync(vsync),
        .display_on(display_on),
        .hpos(hpos),
        .vpos(vpos)
    );

    car_bitmap car(
    .yofs(car_sprite_yofs), 
    .bits(car_sprite_bits));

    // start Y counter when we hit the top border (player_y)
    always @(posedge hsync)
    if (vpos == player_y)
        car_sprite_yofs <= 15;
    else if (car_sprite_yofs != 0)
        car_sprite_yofs <= car_sprite_yofs - 1;

    // restart X counter when we hit the left border (player_x)
    always @(posedge clk)
    if (hpos == player_x)
        car_sprite_xofs <= 15;
    else if (car_sprite_xofs != 0)
        car_sprite_xofs <= car_sprite_xofs - 1;

    // mirror sprite in X direction
    wire [3:0] car_bit = car_sprite_xofs>=8 ? 
                                    15-car_sprite_xofs:
                                    car_sprite_xofs;

    wire car_gfx = car_sprite_bits[car_bit[2:0]];

    wire r = display_on && car_gfx;
    wire g = display_on && car_gfx;
    wire b = display_on && car_gfx;
    assign rgb = {b,g,r};

endmodule

