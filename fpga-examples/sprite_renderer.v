module sprite_renderer
(
    input clk,
    input vstart,		// start drawing (top border)
    input load,		// ok to load sprite data?
    input hstart,		// start drawing scanline (left border)
    output reg [3:0] rom_addr,	// select ROM address
    input [7:0] rom_bits,		// input bits from ROM
    output reg gfx,		// output pixel
    output in_progress	// 0 if waiting for vstart
);

    reg [2:0] state;
    reg [3:0] ycount;
    reg [3:0] xcount;
    reg [7:0] outbits;

    localparam      WAIT_FOR_VSTART = 0,
                    WAIT_FOR_LOAD   = 1,
                    LOAD1_SETUP     = 2,
                    LOAD1_FETCH     = 3,
                    WAIT_FOR_HSTART = 4,
                    DRAW            = 5;

    //in_progress出力ビットを割り当てます
    assign in_progress = state != WAIT_FOR_VSTART;

    always @(posedge clk)
        begin
            case (state)
                WAIT_FOR_VSTART: begin
                        gfx <= 0;
                        ycount <= 0;
                        if(vstart)
                            state <= WAIT_FOR_LOAD;
                end
                WAIT_FOR_LOAD:
                begin
                    gfx <= 0;
                    xcount <= 0;
                    if(load)
                        state <= LOAD1_SETUP;
                end 
                LOAD1_SETUP:
                begin
                    outbits <= rom_bits; // latch bits from ROM
                    state   <= WAIT_FOR_HSTART;
                end
                WAIT_FOR_HSTART:
                begin
                    if(hstart)
                        state <= DRAW;
                end
                DRAW: 
                begin
                    gfx <= outbits[xcount < 8 ? xcount[2:0] : ~ xcount[2:0]];
                    xcount <= xcount + 1;
                    if(xcount == 15)
                    begin
                        ycount <= ycount + 1'b1;
                        if(ycount == 15)
                            state <= WAIT_FOR_VSTART;
                        else
                            state <= WAIT_FOR_LOAD;
                    end
                end
                // unknown state -- reset
                default: state <= WAIT_FOR_VSTART; 
            endcase
        end

endmodule

module sprite_render_test_top(
  input clk,
  output hsync,
  output vsync,
  output [2:0] rgb,
  input hpaddle, 
  input vpaddle
);
    wire display_on;
    wire [15:0] hpos;
    wire [15:0] vpos;

    // player position
    reg [15:0] player_x;
    reg [15:0] player_y;
    
    // paddle position
    reg [15:0] paddle_x;
    reg [15:0] paddle_y;

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

    // car bitmap ROM and associated wires
    wire [3:0] car_sprite_addr;
    wire [7:0] car_sprite_bits;

    car_bitmap car(
    .yofs(car_sprite_addr), 
    .bits(car_sprite_bits));

    // convert player X/Y to 9 bits and compare to CRT hpos/vpos
    wire vstart = {1'b0,player_y} == vpos;
    wire hstart = {1'b0,player_x} == hpos;

    wire car_gfx;		// car sprite video signal
    wire in_progress;	// 1 = rendering taking place on scanline

    // sprite renderer module
    sprite_renderer renderer(
        .clk(clk),
        .vstart(vstart),
        .load(hsync),
        .hstart(hstart),
        .rom_addr(car_sprite_addr),
        .rom_bits(car_sprite_bits),
        .gfx(car_gfx),
        .in_progress(in_progress)
        );

    // measure paddle position
    always @(posedge hpaddle)
    paddle_x <= vpos[7:0];

    always @(posedge vpaddle)
    paddle_y <= vpos[7:0];

    always @(posedge vsync)
    begin
        player_x <= paddle_x;
        player_y <= paddle_y;
    end

    // video RGB output
    wire r = display_on && car_gfx;
    wire g = display_on && car_gfx;
    wire b = display_on && in_progress;
    assign rgb = {b,g,r};

endmodule
