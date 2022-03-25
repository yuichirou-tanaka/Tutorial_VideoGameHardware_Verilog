module test_ram1_top(
    input wire clk,
    input wire reset, 
    output wire hsync,
    output wire vsync,
    output wire [2:0] rgb
);

    wire display_on;
    wire [15:0] hpos;
    wire [15:0] vpos;

    wire [9:0] ram_addr;
    wire [7:0] ram_read;
    reg [7:0] ram_write;
    reg ram_writeenable = 0;

    RAM_sync ram(
        .clk(clk),
        .reset(reset),
        .hsync(hsync),
        .vsync(vsync),
        .display_on(display_on),
        .hpos(hpos),
        .vpos(vpos)
    );

    hvsync_generator hvsync_gen(
        .clk(clk),
        .reset(reset),
        .hsync(hsync),
        .vsync(vsync),
        .display_on(display_on),
        .hpos(hpos),
        .vpos(vpos)
    );


    wire [4:0] row = vpos[7:3];
    wire [4:0] col = hpos[7:3];
    wire [4:0] rom_yofs = vpos[2:0];
    wire [4:0] rom_bits;

    wire [3:0] digit = ram_read[3:0];
    wire [2:0] xofs = hpos[2:0];

    assign ram_addr = {row, col};

    digit10_case numbers(
        .digit(digit),
        .yofs(ram_yofs),
        .bits(ram_bits)
    );

    wire r = display_on && 0;
    wire g = display_on && rom_bits[~xofs];
    wire b = display_on && 0;
    assign rgb = {b,g,r};

    // increment the current RAM cell
    always @(posedge clk)
        case (hpos[2:0])
            // on 7th pixel of cell
            6: begin
                // increment RAM cell
                ram_write <= (ram_read + 1);
                // only enable write on last scanline of cell
                ram_writeenable <= display_on && rom_yofs == 7;
            end
            // on 8th pixel of cell
            7: begin
                // disable write
                ram_writeenable <= 0;
            end
        endcase
    
endmodule // test_ram1_top
