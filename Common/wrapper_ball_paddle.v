module wrapper_ball_paddle
(
    input wire [0:0] clk,
    input wire [0:0] reset,
    input wire [3:0] keys,
    output wire [0:0] hsync,
    output wire [0:0] vsync,
    output wire [2:0] rgb
);
    reg [0:0] clk_div;

    always @(posedge clk, posedge reset)
    begin
        if( reset )
            clk_div <= 1'b0;
        else
            clk_div <= ~ clk_div;
    end
    
    ball_paddle_top ball_paddle_top_0
    (
        .clk    ( clk_div   ), 
        .reset  ( reset     ), 
        .hpaddle( 0         ),
        .hsync  ( hsync     ), 
        .vsync  ( vsync     ), 
        .rgb    ( rgb       )
    );

    
endmodule