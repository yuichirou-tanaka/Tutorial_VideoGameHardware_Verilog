module wrapper_digits
(
    input wire [0:0] clk,
    input wire [0:0] reset,
    input wire [3:0] keys,
    output wire [0:0] hsync,
    output wire [0:0] vsync,
    output wire [2:0] rgb
);
    reg [0:0] clk_div;
    wire [0:0] left;
    wire [0:0] right;
    assign left=keys[0];
    assign right=keys[1];


    always @(posedge clk, posedge reset)
    begin
        if( reset )
            clk_div <= 1'b0;
        else
            clk_div <= ~ clk_div;
    end
    
    test_numbers_top test_numbers_top_0
    (
        .clk    ( clk_div   ), 
        .reset  ( reset     ), 
        .hsync  ( hsync     ), 
        .vsync  ( vsync     ), 
        .rgb    ( rgb       )
    );

    
endmodule