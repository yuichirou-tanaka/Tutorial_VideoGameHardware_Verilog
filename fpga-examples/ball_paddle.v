module ball_paddle_top
(
    input   wire    [0 : 0]     clk,        // clock
    input   wire    [0 : 0]     reset,      // reset
    input   wire    [0 : 0]     hpaddle,    //
    output  wire    [0 : 0]     hsync,      // horizontal sync
    output  wire    [0 : 0]     vsync,      // vertical sync
    output  wire    [2 : 0]     rgb         // RGB
);

    localparam BRICKS_H = 16;
    localparam BRICKS_V = 8;

    localparam BALL_DIR_LEFT = 0;
    localparam BALL_DIR_RIGHT = 1;
    localparam BALL_DIR_DOWN = 1;
    localparam BALL_DIR_UP = 0;

    localparam PADDLE_WIDTH = 31;
    localparam BALL_SIZE = 6;
 /*******************************************************
    *               WIRE AND REG DECLARATION               *
    *******************************************************/
    reg     [0  : 0]    frame_update;
    reg     [0  : 0]    frame_update_last;
    wire    [0  : 0]    display_on;
    wire    [15 : 0]    hpos;
    wire    [15 : 0]    vpos;
    reg     [15 : 0]    paddle_pos;     // paddle X position
    reg     [15 : 0]    ball_x;         // ball X position
    reg     [15 : 0]    ball_y;         // ball Y position
    reg     [0  : 0]    ball_dir_x;     // ball X direction (0=left, 1=right)
    reg     [0  : 0]    ball_speed_x;   // ball speed (0=1 pixel/frame, 1=2 pixels/frame)
    reg     [0  : 0]    ball_dir_y;     // ball Y direction (0=up, 1=down)
    reg     [0  : 0]    brick_array [0 : BRICKS_H*BRICKS_V-1]; // 16*8 = 128 bits
    wire    [3  : 0]    score0;         // score right digit
    wire    [3  : 0]    score1;         // score left digit
    wire    [3  : 0]    lives;          // # lives remaining
    reg     [0  : 0]    incscore;       // incscore signal 
    wire    [0  : 0]    declives;       // declive 
    wire    [0  : 0]    score_gfx;      // output from score generator
    // horizontal and vertical cells
    wire    [5  : 0]    hcell;          // horizontal brick index
    wire    [5  : 0]    vcell;          // vertical brick index
    wire    [0  : 0]    lr_border;      // along horizontal border?
    // TODO: unsigned compare doesn't work in JS
    reg     [0  : 0]    main_gfx;       // main graphics signal (bricks and borders)
    reg     [0  : 0]    brick_present;  // 1 when we are drawing a brick
    reg     [6  : 0]    brick_index;    // index into array of current brick
    // difference between ball position and video beam
    wire    [15 : 0]    ball_rel_x;
    wire    [15 : 0]    ball_rel_y;
    // brick graphics signal
    wire    [0  : 0]    brick_gfx;
    // player paddle graphics signal
    wire    [0  : 0]    paddle_gfx;
    // ball graphics signal
    wire    [0  : 0]    ball_gfx;
    wire    [8  : 0]    paddle_rel_x;
    // 1 when ball signal intersects main (brick + border) signal
    wire    [0  : 0]    ball_pixel_collide;
    reg     [0  : 0]    ball_collide_paddle;
    reg     [3  : 0]    ball_collide_bits;
    // computes position of ball in relation to center of paddle
    wire    [15 : 0]    ball_paddle_dx; // TODO signed ?

    assign ball_gfx = ball_rel_x < BALL_SIZE && ball_rel_y < BALL_SIZE;

    assign brick_gfx = ir_boarder || (brick_present && (vpos[2 :0] != 0 ) && (hpos[3:1]!=4));
    assign paddle_gfx = (vcell==28) && (paddle_rel_x < PADDLE_WIDTH);
    assign ball_rel_y = (vpos - ball_y);
    assign ball_rel_x = (hpos - ball_x);
    assign hcell = hpos[8:3];
    assign vcell = vpos[8:3];
    assign ir_boarder = (hcell == 0 ) || (hcell==31);
    assign paddle_rel_x = (hpos-paddle_pos & 9'h1ff);
    assign declives = 0;
    assign ball_pixel_collide = main_gfx && ball_gfx;
    assign ball_paddle_dx = ball_x - paddle_pos + 8;

    assign rgb = {
        display_on && ( ball_gfx | paddle_gfx),
        display_on && ( main_gfx | ball_gfx ),
        display_on && (ball_gfx | brick_present)
    };

    always @(posedge clk, posedge reset)
        if( reset )
        begin
            frame_update <= 1'b0;
            frame_update_last <= 1'b0;
        end
        else
        begin
            frame_update <= 1'b0;
            if( ! vsync )
                frame_update_last <= 1'b1;
            else
                frame_update_last <= 1'b0;
            if( ( ! vsync ) && ( ! frame_update_last ) )
                frame_update <= 1'b1;
        end
    
   always @(posedge clk, posedge reset)
        if( reset )
        begin
            brick_index <= 0;
            brick_present <= 0;
        end
        else
        begin
            if((vpos[8:6] == 1 ) && (!lr_border))
            begin
                if(hpos[3:0]==8)
                begin
                    brick_index <= {vpos[5:3], hpos[7:4]};
                end              
                else if(hpos[3:0] == 9)
                begin
                    brick_present <= !brick_array[brick_index];
                end
            end
            else
            begin
                brick_present <= 0;
            end
        end

    always @(posedge hsync)
        if(!hpaddle)
            paddle_pos <= vpos;
    
   always @(posedge clk, posedge reset)
        if( reset )
        begin
            ball_collide_bits <= 0; 
            ball_collide_paddle <= 0;
        end
        else
        begin
            // clear all collide bits for frame
            if( vsync ) 
            begin
                ball_collide_bits <= 0; 
                ball_collide_paddle <= 0;
            end 
            else 
            begin
                if(ball_pixel_collide)
                begin
                    if(paddle_gfx)
                    begin
                        ball_collide_paddle <= 1;
                    end
                    // ball has 4 collision quadrants
                    if( ( ! ball_rel_x[2] ) && ( ! ball_rel_y[2] ) ) ball_collide_bits[0] <= 1;
                    if( (   ball_rel_x[2] ) && ( ! ball_rel_y[2] ) ) ball_collide_bits[1] <= 1;
                    if( ( ! ball_rel_x[2] ) && (   ball_rel_y[2] ) ) ball_collide_bits[2] <= 1;
                    if( (   ball_rel_x[2] ) && (   ball_rel_y[2] ) ) ball_collide_bits[3] <= 1;
                end
            end
        end
    
    // compute ball collisions with brick and increment score
    always @(posedge clk, posedge reset)
        if( reset )
            incscore <= 0;
        else
        begin
            if(ball_pixel_collide && brick_present)
            begin
                brick_array[brick_index ] <= 1;
                incscore <= 1;
            end
            else
            begin
                incscore <= 0;
            end
        end
 // ball bounce: determine new velocity/direction
    always @(posedge clk, posedge reset)
        if( reset ) 
        begin
            ball_dir_y <= BALL_DIR_DOWN;
            ball_dir_x <= BALL_DIR_RIGHT;
            ball_speed_x <= 0;
        end 
        else if( frame_update )
        begin
            // ball collided with paddle?
            if (ball_collide_paddle) 
            begin 
                // bounces upward off of paddle
                ball_dir_y <= BALL_DIR_UP;
                // which side of paddle, left/right?
                ball_dir_x <= ( ball_paddle_dx < 20 ) ? BALL_DIR_LEFT : BALL_DIR_RIGHT;
                // hitting with edge of paddle makes it fast
                ball_speed_x <= ball_collide_bits[3 : 0] != 4'b1100;
            end 
            else 
            begin
                // collided with playfield
                // TODO: can still slip through corners
                // compute left/right bounce
                casez( ball_collide_bits[3 : 0] )
                    4'b01?1 : ball_dir_x <= BALL_DIR_RIGHT; // left edge/corner
                    4'b1101 : ball_dir_x <= BALL_DIR_RIGHT; // left corner
                    4'b101? : ball_dir_x <= BALL_DIR_LEFT;  // right edge/corner
                    4'b1110 : ball_dir_x <= BALL_DIR_LEFT;  // right corner
                    default : ;
                endcase
                // compute top/bottom bounce
                casez( ball_collide_bits[3 : 0] )
                    4'b1011 : ball_dir_y <= BALL_DIR_DOWN;
                    4'b0111 : ball_dir_y <= BALL_DIR_DOWN;
                    4'b001? : ball_dir_y <= BALL_DIR_DOWN;
                    4'b0001 : ball_dir_y <= BALL_DIR_DOWN;
                    4'b0100 : ball_dir_y <= BALL_DIR_UP;
                    4'b1?00 : ball_dir_y <= BALL_DIR_UP;
                    4'b1101 : ball_dir_y <= BALL_DIR_UP;
                    4'b1110 : ball_dir_y <= BALL_DIR_UP;
                    default : ;
                endcase
            end
        end
    // ball motion: update ball position
    always @(posedge clk, posedge reset)
        if( reset )
        begin
            // reset ball position to top center
            ball_x <= 320;
            ball_y <= 240;
        end 
        else if( frame_update )
        begin
            // move ball horizontal and vertical position
            if( ball_dir_x == BALL_DIR_RIGHT )
                ball_x <= ball_x + ( ball_speed_x ? 1 : 0 ) + 1;
            else
                ball_x <= ball_x - ( ball_speed_x ? 1 : 0 ) - 1;
            ball_y <= ball_y + ( ball_dir_y == BALL_DIR_DOWN ? 1 : -1 );
        end

    always @(*)
        case(vpos[8:3])
            0,1,2                   : main_gfx = score_gfx;
            3                       : main_gfx = 0;
            4                       : main_gfx = 1;
            8,9,10,11,12,13,14,15   : main_gfx = brick_gfx;                 // brick rows 1-8
            28                      : main_gfx = paddle_gfx | lr_border;    // paddle
            29                      : main_gfx = hpos[0] ^ vpos[0];         // bottom border
            default                 : main_gfx = lr_border;                 // left/right borders
        endcase

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
