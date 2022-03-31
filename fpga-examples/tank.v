module minefield(
	input [8:0] hpos,
   input [8:0] vpos,
   output wire mine_gfx
);
    // mine X coordinates in ROM
    reg [3:0] mine_xpos [0:15];

    // 1 bit for each mine
    reg [15:0] mine_exploded;

    wire mine_pattern = ~(hpos[0] ^ hpos[1]) ^ (vpos[0] ^ vpos[1])
                        && hpos[2] && vpos[2];
    
    // limit mine pattern to a rectangular window
    wire mine_field = (hpos >= 64 && hpos < 160)   && (vpos >= 48 && vpos < 176)  && mine_pattern;
    
    wire [3:0] mine_vindex = vpos[6:3]^8;

    wire mine_all = (hpos[6:3] == (minie_xpos[mine_vindex]^8)) && mine_field;

    assign mine_gfx = mine_all && ~mine_exploded[mine_vindex];

    initial begin
        mine_exploded = 0;
        mine_xpos[0] = 2;
        mine_xpos[1] = 10;
        mine_xpos[2] = 6;
        mine_xpos[3] = 0;
        mine_xpos[4] = 9;
        mine_xpos[5] = 3;
        mine_xpos[6] = 7;
        mine_xpos[7] = 11;
        mine_xpos[8] = 4;
        mine_xpos[9] = 1;
        mine_xpos[10] = 10;
        mine_xpos[11] = 5;
        mine_xpos[12] = 11;
        mine_xpos[13] = 3;
        mine_xpos[14] = 8;
        mine_xpos[15] = 0;
    end

endmodule

module playfield(hpos, vpos, playfield_gfx);
    input [8:0] hpos;
    input [8:0] vpos;
    output playfield_gfx;

    reg [31:0] maze [0:27];

    wire [4:0] x = hpos[7:3];
    wire [4:0] y = vpos[7:3] - 2;

    assign playfield_gfx = maze[y][x];

    initial begin
        maze[0]  = 32'b11111111111111111111111111111111;
        maze[1]  = 32'b10000000000100000000001000000001;
        maze[2]  = 32'b10000000000100000000001000000001;
        maze[3]  = 32'b10000000000100000000000000000001;
        maze[4]  = 32'b10011110000000000000000000000001;
        maze[5]  = 32'b10000000000000000000000000000001;
        maze[6]  = 32'b10000000001000000000000011110001;
        maze[7]  = 32'b11100010000000000000000000100001;
        maze[8]  = 32'b10000010000000000000000000100001;
        maze[9]  = 32'b10000011100000000000000000000001;
        maze[10] = 32'b10000000000000000000000000000001;
        maze[11] = 32'b10000000000000000000000000000001;
        maze[12] = 32'b11111000001000000000000000000001;
        maze[13] = 32'b10001000001000000000000111100001;
        maze[14] = 32'b10001000001000000000000000000001;
        maze[15] = 32'b10000000001000000000000000000001;
        maze[16] = 32'b10000000001000000000000000000001;
        maze[17] = 32'b10000000000000000000000000000001;
        maze[18] = 32'b10000010000000000000000100011001;
        maze[19] = 32'b10001110000000000000000100010001;
        maze[20] = 32'b10000000001000000000000100010001;
        maze[21] = 32'b10000000001110000000000100000001;
        maze[22] = 32'b10000000000000000010001100000001;
        maze[23] = 32'b10000000000000000000000000000001;
        maze[24] = 32'b10000010000111100000000000010001;
        maze[25] = 32'b10000010000000100000000000010001;
        maze[26] = 32'b10000010000000000010000000010001;
        maze[27] = 32'b11111111111111111111111111111111;
    end
endmodule

module tank_game_top(
    input clk, 
    input reset,
    input [7:0] switches_p1,
    input [7:0] switches_p2,
    output hsync, 
    output vsync,
    output [2:0] rgb
);
    wire display_on;
    wire [8:0] hpos;
    wire [8:0] vpos;

    wire mine_gfx;
    wire playfield_gfx;
    wire tank1_gfx;
    wire tank2_gfx;


    // video sync generator  
    hvsync_generator hvsync_gen(
        .clk(clk),
        .reset(0),
        .hsync(hsync),
        .vsync(vsync),
        .display_on(display_on),
        .hpos(hpos),
        .vpos(vpos)
    );

    minefield mine_gen(
        .hpos(hpos),
        .vpos(vpos),
        .mine_gfx(mine_gfx)
    );

    playfield playfield_gen(
        .hpos(hpos),
        .vpos(vpos),
        .playfield_gfx(playfield_gfx)
    );

    wire p2sel = hpos > 280;

    wire [7:0] tank1_sprite_addr;
    wire [7:0] tank2_sprite_addr;
    
    wire [7:0] tank_sprite_bits;

    // bitmap ROM is shared between tank 1 and 2
  tank_bitmap tank_bmp(
    .addr(p2sel ? tank2_sprite_addr : tank1_sprite_addr), 
    .bits(tank_sprite_bits));

    // player 1 tank controller  
    tank_controller #(16,36,4) tank1(
        .clk(clk),
        .reset(reset),
        .hpos(hpos),
        .vpos(vpos),
        .hsync(hsync && !p2sel),
        .vsync(vsync),
        .sprite_addr(tank1_sprite_addr), 
        .sprite_bits(tank_sprite_bits),
        .gfx(tank1_gfx),
        .playfield(playfield_gfx),
        .switch_left(switches_p1[0]),
        .switch_right(switches_p1[1]),
        .switch_up(switches_p1[2])
    );

    // player 2 tank controller
    tank_controller #(220,190,12) tank2(
        .clk(clk),
        .reset(reset),
        .hpos(hpos),
        .vpos(vpos),
        .hsync(hsync && p2sel),
        .vsync(vsync),
        .sprite_addr(tank2_sprite_addr), 
        .sprite_bits(tank_sprite_bits),
        .gfx(tank2_gfx),
        .playfield(playfield_gfx),
        .switch_left(switches_p2[0]),
        .switch_right(switches_p2[1]),
        .switch_up(switches_p2[2])
    );
    


    // video signal mixer
    wire r = display_on && (mine_gfx || tank2_gfx);
    wire g = display_on && tank1_gfx;
    wire b = display_on && (playfield_gfx || tank2_gfx);
    assign rgb = {b,g,r};

endmodule

