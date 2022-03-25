module wrapper_switches
(
    input   wire    [0 : 0]     clk,
    input   wire    [0 : 0]     reset,
    input   wire    [3 : 0]     keys,
    output  wire    [0 : 0]     hsync,
    output  wire    [0 : 0]     vsync,
    output  wire    [2 : 0]     rgb
);
    reg [0:0] clk_div;
    always @(posedge clk, posedge reset)
    begin
        if( reset )
            clk_div <= 1'b0;
        else
            clk_div <= ~ clk_div;
    end
    wire [7:0] switches_p1 = keys;
    wire [7:0] switches_p2;
    
    switchs_top switchs_top_0
    (
        .clk    ( clk_div   ), 
        .reset  ( reset     ), 
        .hsync  ( hsync     ), 
        .vsync  ( vsync     ), 
        .switches_p1(switches_p1),
        .switches_p2(switches_p2),
        .rgb    ( rgb       )
    );

    
endmodule