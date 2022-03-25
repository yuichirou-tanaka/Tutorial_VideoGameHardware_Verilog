module RAM_sync
#( parameter A = 10, 
             D = 8
)(
    input wire clk,
    input wire [A-1 : 0 ] addr,
    input wire [D-1 : 0 ] din,
    input wire [D-1 : 0 ] dout,
    output wire [0 : 0] we
);
    reg [D-1: 0] mem[0:(1<<A) -1];

    always @(posedge clk)
    begin
        dout <= mem[addr];
        if(we)
            mem[addr] <= din;
    end

endmodule

module RAM_async
#(
    parameter   A = 10,
                D = 8
)(
    input wire clk,
    input wire [A-1 : 0 ] addr,
    input wire [D-1 : 0 ] din,
    input wire [D-1 : 0 ] dout,
    output wire [0 : 0] we
);
    /*******************************************************
    *               WIRE AND REG DECLARATION               *
    *******************************************************/
    reg [D-1:0] mem[0:(1<<A) -1];
    /*******************************************************
    *                      ASSIGNMENT                      *
    *******************************************************/
    assign dout = mem[addr];
    /*******************************************************
    *               OTHER COMB AND SEQ LOGIC               *
    *******************************************************/    
    always @(posedge clk)
        if(we)
            mem[addr] <= din;

endmodule


module RAM_async_tristate
#(
    parameter                   A = 10, // # of address bits
                                D = 8   // # of data bits
)(
    input   wire    [0   : 0]   clk, 
    input   wire    [A-1 : 0]   addr, 
    inout   wire    [D-1 : 0]   data, 
    input   wire    [0   : 0]   we
);
    /*******************************************************
    *               WIRE AND REG DECLARATION               *
    *******************************************************/
    reg     [D-1 : 0]   mem [0 : ( 1 << A ) - 1]; // (1<<A)xD bit memory
    /*******************************************************
    *                      ASSIGNMENT                      *
    *******************************************************/
    assign data = !we ? mem[addr] : { D { 1'bz } }; // read memory to data (async)
    /*******************************************************
    *               OTHER COMB AND SEQ LOGIC               *
    *******************************************************/    
    always @(posedge clk)
        if( we )
            mem[addr] <= data; // write memory from data

endmodule