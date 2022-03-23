module hvsync_generator
#(
    parameter   H_DISPLAY = 640,
    H_BACK = 48,
    H_FRONT = 16,
    H_SYNC = 96,
    V_DISPLAY = 480,
    V_TOP = 10,
                                V_BOTTOM  =  33,    // vertical bottom border
                                V_SYNC    =   2     // vertical sync # lines
)(
    input wire [0:0] clk
);

endmodule // hvsync_generator
