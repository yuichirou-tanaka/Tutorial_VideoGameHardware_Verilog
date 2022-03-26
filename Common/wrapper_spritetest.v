module wrapper_spritetest
(
    input   wire    [0 : 0]     clk,
    input   wire    [0 : 0]     reset,
    input   wire    [3 : 0]     keys,
    output  wire    [0 : 0]     hsync,
    output  wire    [0 : 0]     vsync,
    output  wire    [2 : 0]     rgb
);
    reg [0:0] clk_div;
    wire    [0 : 0]     left;
    wire    [0 : 0]     right;
    wire    [0 : 0]     up;
    wire    [0 : 0]     down;

    assign left     = keys[0];
    assign right    = keys[1];
    assign up       = keys[2];
    assign down     = keys[3];

    always @(posedge clk, posedge reset)
    begin
        if( reset )
            clk_div <= 1'b0;
        else
            clk_div <= ~ clk_div;
    end
    

    sprite_bitmap_top sprite_bitmap_top_0
    (
        .clk    ( clk_div   ), 
        .reset  ( reset     ), 
        .hsync  ( hsync     ), 
        .vsync  ( vsync     ), 
        .rgb    ( rgb       )
    );

    
endmodule