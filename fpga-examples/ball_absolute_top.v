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
    end


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
