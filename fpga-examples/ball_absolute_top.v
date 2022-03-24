module ball_absolute_top
(
    input   wire    [0 : 0]     clk,        // clock
    input   wire    [0 : 0]     reset,      // reset
    input   wire    [0 : 0]     hpaddle,    //
    output  wire    [0 : 0]     hsync,      // horizontal sync
    output  wire    [0 : 0]     vsync,      // vertical sync
    output  wire    [2 : 0]     rgb         // RGB
);

    /*******************************************************
    *               WIRE AND REG DECLARATION               *
    *******************************************************/
    wire display_on;
    wire [8:0] hpos;
    wire [8:0] vpos;
    reg [8:0] ball_hpos;
    reg [8:0] ball_vpos;

    reg [8:0] ball_horiz_move = -2;
    reg [8:0] ball_vert_move = 2;

    localparam ball_horiz_initial = 128;
    localparam ball_vert_initial = 128;

    localparam BALL_SIZE = 4;

    always @(posedge vsync, posedge reset)
    begin
        if( reset ) begin
            ball_vpos <= ball_vert_initial;
            ball_hpos <= ball_horiz_initial;
        end else begin
            ball_hpos <= ball_hpos + ball_horiz_move;
            ball_vpos <= ball_vpos + ball_vert_move;
        end
    end

    always @(posedge ball_vert_collide)
    begin
        ball_vert_move <= -ball_vert_move;
    end

    always @(posedge ball_horiz_collide)
    begin
        ball_horiz_move <= -ball_horiz_move;
    end

    wire [8:0] ball_hdiff = hpos - ball_hpos;
    wire [8:0] ball_vdiff = vpos - ball_vpos;

    wire ball_hgfx = ball_hdiff < BALL_SIZE;
    wire ball_vgfx = ball_vdiff < BALL_SIZE;
    wire ball_gfx = ball_hgfx && ball_vgfx;
    
    wire ball_vert_collide = ball_vpos >= 480 - BALL_SIZE;
    wire ball_horiz_collide = ball_hpos >= 640 - BALL_SIZE;

    wire grid_gfx = (((hpos%7)==0) && ((vpos&7)==0));
    wire r = display_on && (ball_hgfx | ball_gfx);
    wire g = display_on && (ball_gfx | ball_gfx);
    wire b = display_on && (ball_vgfx | ball_gfx);
    assign rgb = {b,g,r};

    hvsync_generator hvsync_gen    (
        .clk        ( clk           ),
        .reset      ( reset         ),
        .hsync      ( hsync         ),
        .vsync      ( vsync         ),
        .display_on ( display_on    ),
        .hpos       ( hpos          ),
        .vpos       ( vpos          )
    );
    
endmodule // ball_paddle_top
